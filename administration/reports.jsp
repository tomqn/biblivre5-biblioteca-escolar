<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="biblivre.core.utils.DatabaseUtils" %>
<%
    String type = request.getParameter("type");
    String limitStr = request.getParameter("limit");
    int limit = 10;
    try {
        if (limitStr != null) limit = Integer.parseInt(limitStr);
    } catch(Exception e) {}

    // Identifica o schema ativo
    String schema = (String) request.getAttribute("schema");
    if (schema == null || schema.trim().isEmpty()) {
        schema = (String) session.getAttribute("schema");
    }
    if (schema == null || schema.trim().isEmpty()) {
        schema = "single";
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        // TENTATIVA 1: DatabaseUtils.getConnection(schema)
        try {
            Method m = DatabaseUtils.class.getMethod("getConnection", String.class);
            con = (Connection) m.invoke(null, schema);
        } catch (Throwable t1) {
            // TENTATIVA 2: DatabaseUtils.getConnection()
            try {
                Method m = DatabaseUtils.class.getMethod("getConnection");
                con = (Connection) m.invoke(null);
            } catch (Throwable t2) {
                // TENTATIVA 3: DatabaseUtils.getDataSource()
                try {
                    Method m = DatabaseUtils.class.getMethod("getDataSource");
                    DataSource ds = (DataSource) m.invoke(null);
                    con = ds.getConnection();
                } catch (Throwable t3) {
                    // TENTATIVA 4: DriverManager fallback padrão Biblivre PostgreSQL
                    Class.forName("org.postgresql.Driver");
                    con = DriverManager.getConnection("jdbc:postgresql://localhost:5432/biblivre4", "biblivre", "abracadabra");
                }
            }
        }

        if (con == null) {
            throw new Exception("Não foi possível obter uma conexão com o PostgreSQL do Biblivre.");
        }

        // -------------------------------------------------------------
        // 1. TOP LIVROS MAIS EMPRESTADOS
        // -------------------------------------------------------------
        if ("top_books".equals(type)) {
%>
            <table class="report_table" id="exportTable">
                <thead>
                    <tr>
                        <th style="width: 45px;">Pos.</th>
                        <th>Título da Obra</th>
                        <th>Autor / Responsável</th>
                        <th style="width: 120px;">Total de Saídas</th>
                    </tr>
                </thead>
                <tbody>
<%
            String sql = "SELECT b.id as record_id, " +
                         "       COALESCE(title.phrase, 'Sem título') as title, " +
                         "       COALESCE(author.phrase, 'Autor não informado') as author, " +
                         "       COUNT(l.id) as total_lendings " +
                         "FROM " + schema + ".lendings l " +
                         "INNER JOIN " + schema + ".biblio_holdings h ON l.holding_id = h.id " +
                         "INNER JOIN " + schema + ".biblio_records b ON h.record_id = b.id " +
                         "LEFT JOIN " + schema + ".biblio_search_indexes title ON title.record_id = b.id AND title.indexing_group_id = 1 " +
                         "LEFT JOIN " + schema + ".biblio_search_indexes author ON author.record_id = b.id AND author.indexing_group_id = 2 " +
                         "GROUP BY b.id, title.phrase, author.phrase " +
                         "ORDER BY total_lendings DESC LIMIT ?";

            ps = con.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();

            int pos = 1;
            boolean hasData = false;
            while (rs.next()) {
                hasData = true;
%>
                <tr>
                    <td><span class="rank_pill">#<%= pos++ %></span></td>
                    <td><strong><%= rs.getString("title") %></strong></td>
                    <td><%= rs.getString("author") %></td>
                    <td><strong style="color: #059669;"><%= rs.getInt("total_lendings") %> saídas</strong></td>
                </tr>
<%
            }
            if (!hasData) {
%>
                <tr><td colspan="4" style="text-align:center; padding:15px; color:#64748b;">Nenhum histórico de empréstimo registrado no banco até o momento.</td></tr>
<%
            }
%>
                </tbody>
            </table>
<%
        }

        // -------------------------------------------------------------
        // 2. LEITORES MAIS ASSÍDUOS
        // -------------------------------------------------------------
        else if ("top_users".equals(type)) {
%>
            <table class="report_table" id="exportTable">
                <thead>
                    <tr>
                        <th style="width: 45px;">Pos.</th>
                        <th>Nome do Usuário</th>
                        <th>Matrícula / ID</th>
                        <th style="width: 120px;">Livros Retirados</th>
                    </tr>
                </thead>
                <tbody>
<%
            String sql = "SELECT u.id, u.name, u.enrollment, COUNT(l.id) as total_lendings " +
                         "FROM " + schema + ".lendings l " +
                         "INNER JOIN " + schema + ".users u ON l.user_id = u.id " +
                         "GROUP BY u.id, u.name, u.enrollment " +
                         "ORDER BY total_lendings DESC LIMIT ?";

            ps = con.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();

            int pos = 1;
            boolean hasData = false;
            while (rs.next()) {
                hasData = true;
%>
                <tr>
                    <td><span class="rank_pill">#<%= pos++ %></span></td>
                    <td><strong><%= rs.getString("name") %></strong></td>
                    <td><%= (rs.getString("enrollment") != null && !rs.getString("enrollment").trim().isEmpty() ? rs.getString("enrollment") : "ID: " + rs.getInt("id")) %></td>
                    <td><strong style="color: #059669;"><%= rs.getInt("total_lendings") %> retiradas</strong></td>
                </tr>
<%
            }
            if (!hasData) {
%>
                <tr><td colspan="4" style="text-align:center; padding:15px; color:#64748b;">Nenhum registro de empréstimo encontrado no banco.</td></tr>
<%
            }
%>
                </tbody>
            </table>
<%
        }

        // -------------------------------------------------------------
        // 3. ATRASOS ATUAIS
        // -------------------------------------------------------------
        else if ("late_lendings".equals(type)) {
%>
            <table class="report_table" id="exportTable">
                <thead>
                    <tr>
                        <th>Leitor</th>
                        <th>Matrícula</th>
                        <th>Data Prevista</th>
                        <th style="width: 100px;">Dias Atraso</th>
                    </tr>
                </thead>
                <tbody>
<%
            String sql = "SELECT u.name, u.enrollment, l.expected_return_date, " +
                         "       CURRENT_DATE - l.expected_return_date::date as days_late " +
                         "FROM " + schema + ".lendings l " +
                         "INNER JOIN " + schema + ".users u ON l.user_id = u.id " +
                         "WHERE l.return_date IS NULL AND l.expected_return_date < CURRENT_DATE " +
                         "ORDER BY days_late DESC LIMIT ?";

            ps = con.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();

            boolean hasData = false;
            while (rs.next()) {
                hasData = true;
%>
                <tr>
                    <td><strong><%= rs.getString("name") %></strong></td>
                    <td><%= (rs.getString("enrollment") != null ? rs.getString("enrollment") : "-") %></td>
                    <td><%= rs.getDate("expected_return_date") %></td>
                    <td><span class="late_badge"><%= rs.getInt("days_late") %> dias</span></td>
                </tr>
<%
            }
            if (!hasData) {
%>
                <tr><td colspan="4" style="text-align:center; padding:15px; color:#059669; font-weight:700;">✅ Nenhum empréstimo em atraso no momento!</td></tr>
<%
            }
%>
                </tbody>
            </table>
<%
        }
    } catch (Exception ex) {
%>
        <div style="background:#fef2f2; color:#b91c1c; padding:12px; border-radius:6px; font-size:11px;">
            <strong>Aviso do Banco de Dados:</strong> <%= ex.getMessage() %>
        </div>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (ps != null) try { ps.close(); } catch(Exception e) {}
        if (con != null) try { con.close(); } catch(Exception e) {}
    }
%>