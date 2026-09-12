<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.Normalizer"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="biblivre.core.utils.Constants"%>
<%@page import="biblivre.core.configurations.Configurations"%>
<%@page import="org.apache.commons.lang3.StringEscapeUtils"%>
<%@page import="biblivre.core.schemas.SchemaDTO"%>
<%@page import="biblivre.core.schemas.Schemas"%>
<%@page import="biblivre.core.ExtendedRequest"%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>

<%@ taglib prefix="layout" uri="/WEB-INF/tlds/layout.tld" %>
<%@ taglib prefix="i18n" uri="/WEB-INF/tlds/translations.tld" %>

<%!
    private String getNomeCurto(String nomeCompleto) {
        if (nomeCompleto == null) return "Desconhecido";
        String[] partes = nomeCompleto.trim().split("\\s+");
        return partes.length >= 2 ? partes[0] + " " + partes[1] : partes[0];
    }

    private void closeQuietly(ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
    }

    private void closeQuietly(Statement st) {
        if (st != null) try { st.close(); } catch (Exception ignored) {}
    }

    private void closeQuietly(Connection c) {
        if (c != null) try { c.close(); } catch (Exception ignored) {}
    }

    private String codificarBase64(String texto) {
        try {
            return java.util.Base64.getEncoder().encodeToString(texto.getBytes("UTF-8"));
        } catch (Throwable t) {
            try {
                return org.apache.commons.codec.binary.Base64.encodeBase64String(texto.getBytes("UTF-8"));
            } catch (Throwable t2) {
                return "";
            }
        }
    }

    private String normalizarTexto(String s) {
        if (s == null) return "";
        String nfd = Normalizer.normalize(s.toLowerCase(), Normalizer.Form.NFD);
        return nfd.replaceAll("\\p{InCombiningDiacriticalMarks}+", "").replaceAll("[^a-z0-9]", "");
    }

    private static class MediaItem {
        int id;
        String name;
        String normalizedName;
        MediaItem(int id, String name, String normalizedName) {
            this.id = id;
            this.name = name;
            this.normalizedName = normalizedName;
        }
    }

    private List<MediaItem> carregarTodasMedias(Connection conn, String schema) {
        List<MediaItem> lista = new ArrayList<MediaItem>();
        if (conn == null) return lista;
        Statement st = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT id, name FROM " + schema + ".digital_media " +
                         "WHERE name ~* '\\.(jpg|jpeg|png|webp|gif)$' ORDER BY id ASC";
            st = conn.createStatement();
            rs = st.executeQuery(sql);
            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                String semExt = name.replaceFirst("(?i)\\.(jpg|jpeg|png|webp|gif)$", "");
                lista.add(new MediaItem(id, name, normalizarTexto(semExt)));
            }
        } catch (Exception ignored) {
        } finally {
            closeQuietly(rs);
            closeQuietly(st);
        }
        return lista;
    }

    private String obterUrlCapa(Connection conn, String schema, int recordId, String titulo, List<MediaItem> todasMedias) {
        if (conn == null || todasMedias == null || todasMedias.isEmpty()) return null;

        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sqlMarc = "SELECT iso2709::text AS marc_data FROM " + schema + ".biblio_records WHERE id = ?";
            ps = conn.prepareStatement(sqlMarc);
            ps.setInt(1, recordId);
            rs = ps.executeQuery();
            if (rs.next()) {
                String marcData = rs.getString("marc_data");
                if (marcData != null) {
                    for (MediaItem m : todasMedias) {
                        if (marcData.contains(m.name) || marcData.contains(m.id + ":" + m.name)) {
                            return "DigitalMediaController/?id=" + codificarBase64(m.id + ":" + m.name);
                        }
                    }
                }
            }
        } catch (Exception ignored) {
        } finally {
            closeQuietly(rs);
            closeQuietly(ps);
        }

        if (titulo != null && !titulo.isEmpty()) {
            String tituloNorm = normalizarTexto(titulo);
            for (MediaItem m : todasMedias) {
                if (m.normalizedName.length() >= 3) {
                    if (tituloNorm.equals(m.normalizedName) || 
                        tituloNorm.contains(m.normalizedName) || 
                        m.normalizedName.contains(tituloNorm)) {
                        return "DigitalMediaController/?id=" + codificarBase64(m.id + ":" + m.name);
                    }
                }
            }
        }
        return null;
    }

    private boolean isDisponivel(Connection conn, String schema, int recordId) {
        if (conn == null || recordId <= 0) return true;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT COUNT(h.id) AS total_holdings, " +
                         "COUNT(l.id) AS total_lent " +
                         "FROM " + schema + ".biblio_holdings h " +
                         "LEFT JOIN " + schema + ".lendings l ON h.id = l.holding_id AND l.return_date IS NULL " +
                         "WHERE h.record_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, recordId);
            rs = ps.executeQuery();
            if (rs.next()) {
                int total = rs.getInt("total_holdings");
                int emprestados = rs.getInt("total_lent");
                return (total > emprestados);
            }
        } catch (Exception ignored) {
        } finally {
            closeQuietly(rs);
            closeQuietly(ps);
        }
        return true;
    }
%>

<layout:head>
    <link rel="stylesheet" type="text/css" href="static/styles/biblivre.index.css" />
    <link rel="stylesheet" type="text/css" href="static/styles/biblivre.multi_schema.css" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <style type="text/css">
        .library-dashboard {
            font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif;
            width: 100%;
            max-width: 1260px;
            margin: 0 auto;
            padding: 8px 0 50px 0;
            color: #0f172a;
            box-sizing: border-box;
        }

        /* HERO CONTEMPORÂNEO */
        .library-hero {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            border-radius: 20px;
            padding: 36px 36px 30px 36px;
            margin-bottom: 28px;
            color: #ffffff;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.12);
        }
        .library-hero::after {
            content: '';
            position: absolute;
            right: -60px;
            bottom: -60px;
            width: 240px;
            height: 240px;
            background: radial-gradient(circle, rgba(59, 130, 246, 0.18) 0%, rgba(255, 255, 255, 0) 70%);
            border-radius: 50%;
            pointer-events: none;
        }
        .hero-top-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 22px;
        }
        .hero-greeting {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            font-weight: 600;
            color: #94a3b8;
            letter-spacing: 0.3px;
            text-transform: uppercase;
        }
        .hero-greeting-pulse {
            width: 8px;
            height: 8px;
            background: #10b981;
            border-radius: 50%;
            display: inline-block;
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.25);
        }
        .hero-title {
            font-size: 26px;
            font-weight: 800;
            line-height: 1.25;
            letter-spacing: -0.5px;
            color: #ffffff;
            margin: 4px 0 0 0;
        }
        .hero-stats-pills {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .hero-pill {
            display: flex;
            align-items: center;
            gap: 7px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.12);
            padding: 7px 14px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
            color: #cbd5e1;
            backdrop-filter: blur(8px);
        }
        .hero-pill strong { color: #ffffff; }

        /* Barra de pesquisa + Botão Me Surpreenda */
        .hero-search-area {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            max-width: 900px;
        }
        .hero-search-box {
            display: flex;
            align-items: center;
            background: #ffffff;
            border-radius: 14px;
            padding: 5px 6px 5px 18px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
            flex: 1;
            min-width: 280px;
        }
        .hero-search-icon {
            font-size: 17px;
            color: #64748b;
            margin-right: 12px;
            user-select: none;
        }
        .hero-search-input {
            flex: 1;
            border: none;
            outline: none;
            font-size: 14px;
            color: #0f172a;
            font-family: inherit;
            background: transparent;
        }
        .hero-search-input::placeholder { color: #94a3b8; }
        .hero-search-btn {
            background: #2563eb;
            color: #ffffff;
            border: none;
            outline: none;
            padding: 11px 22px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 700;
            font-family: inherit;
            cursor: pointer;
            transition: all 0.2s ease;
            white-space: nowrap;
        }
        .hero-search-btn:hover { background: #1d4ed8; }

        /* BOTÃO ME SURPREENDA */
        .hero-surprise-btn {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: #ffffff;
            border: none;
            outline: none;
            padding: 13px 20px;
            border-radius: 14px;
            font-size: 13px;
            font-weight: 800;
            font-family: inherit;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 16px rgba(217, 119, 6, 0.35);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            white-space: nowrap;
        }
        .hero-surprise-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 22px rgba(217, 119, 6, 0.5);
        }

        /* PÍLULAS DE ASSUNTOS POPULARES */
        .hero-trending-topics {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            margin-top: 18px;
            font-size: 12px;
        }
        .hero-trending-label {
            color: #94a3b8;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .hero-topic-pill {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.15);
            color: #f1f5f9;
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            backdrop-filter: blur(4px);
            user-select: none;
        }
        .hero-topic-pill:hover {
            background: #ffffff;
            color: #0f172a;
            border-color: #ffffff;
            transform: translateY(-1px);
        }

        /* SEÇÕES DO DASHBOARD */
        .library-section {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 18px;
            margin-bottom: 26px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(15, 23, 42, 0.04);
        }
        .library-section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 24px;
            border-bottom: 1px solid #f1f5f9;
        }
        .library-section-title-area {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .library-section-icon {
            width: 44px;
            height: 44px;
            min-width: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }
        .library-section-title {
            margin: 0;
            font-size: 17px;
            font-weight: 800;
            letter-spacing: -0.3px;
            color: #0f172a;
        }
        .library-section-subtitle {
            margin-top: 3px;
            font-size: 12px;
            color: #64748b;
        }
        .library-section-badge {
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.3px;
            border: 1px solid #e2e8f0;
            background: #f8fafc;
            color: #475569;
        }

        /* FILTROS TEMÁTICOS */
        .library-theme-filters {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px 20px;
            background: #f8fafc;
            border-bottom: 1px solid #edf2f7;
            overflow-x: auto;
            scrollbar-width: thin;
        }
        .theme-filter-btn {
            border: 1px solid #e2e8f0;
            background: #ffffff;
            color: #475569;
            padding: 7px 15px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            white-space: nowrap;
            transition: all 0.2s ease;
            outline: none;
            font-family: inherit;
        }
        .theme-filter-btn:hover { background: #f1f5f9; color: #0f172a; border-color: #cbd5e1; }
        .theme-filter-btn.active {
            background: #0f172a;
            color: #ffffff;
            border-color: #0f172a;
            box-shadow: 0 2px 8px rgba(15, 23, 42, 0.2);
        }

        /* CARROSSEL DE LIVROS */
        .library-books-scroll {
            display: flex;
            gap: 20px;
            overflow-x: auto;
            padding: 22px 24px 26px 24px;
            scrollbar-width: thin;
            scrollbar-color: #cbd5e1 transparent;
        }
        .library-books-scroll::-webkit-scrollbar { height: 6px; }
        .library-books-scroll::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }

        .library-book-card {
            flex: 0 0 178px;
            width: 178px;
            background: transparent;
            box-sizing: border-box;
            cursor: pointer;
            transition: transform 0.24s cubic-bezier(0.34, 1.56, 0.64, 1);
            position: relative;
        }
        .library-book-card:hover { transform: translateY(-6px); }

        /* CAPA 3D */
        .library-book-cover {
            width: 100%;
            height: 235px;
            border-radius: 10px;
            overflow: hidden;
            position: relative;
            margin-bottom: 12px;
            background: #e2e8f0;
            box-shadow: 0 8px 18px rgba(15, 23, 42, 0.12), 0 2px 5px rgba(15, 23, 42, 0.06);
            transition: box-shadow 0.24s ease;
        }
        .library-book-card:hover .library-book-cover {
            box-shadow: 0 16px 30px rgba(15, 23, 42, 0.22), 0 4px 8px rgba(15, 23, 42, 0.1);
        }
        .library-book-cover::after {
            content: '';
            position: absolute;
            left: 0; top: 0; bottom: 0;
            width: 10px;
            background: linear-gradient(to right, rgba(0,0,0,0.3) 0%, rgba(255,255,255,0.18) 40%, rgba(0,0,0,0.1) 80%, rgba(0,0,0,0) 100%);
            pointer-events: none;
        }
        .library-book-cover img { width: 100%; height: 100%; object-fit: cover; display: block; }

        .status-badge {
            position: absolute;
            top: 8px;
            right: 8px;
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 10px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 4px;
            backdrop-filter: blur(8px);
            z-index: 2;
            box-shadow: 0 2px 6px rgba(0,0,0,0.2);
        }
        .status-available { background: rgba(22, 101, 52, 0.88); color: #f0fdf4; }
        .status-lent { background: rgba(154, 52, 18, 0.88); color: #fff7ed; }

        .book-styled-cover {
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 16px 12px;
            box-sizing: border-box;
            color: #ffffff;
            text-align: center;
        }
        .styled-cover-icon { font-size: 28px; opacity: 0.9; margin-top: 4px; }
        .styled-cover-title {
            font-size: 12px;
            font-weight: 800;
            line-height: 1.35;
            display: -webkit-box;
            -webkit-line-clamp: 4;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-shadow: 0 1px 4px rgba(0,0,0,0.5);
        }
        .styled-cover-author {
            font-size: 10px;
            opacity: 0.85;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .library-book-title {
            font-size: 13px;
            line-height: 1.4;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 4px;
            min-height: 36px;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
        .library-book-author {
            font-size: 11px;
            color: #64748b;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .library-book-footer {
            display: flex;
            align-items: center;
            gap: 5px;
            margin-top: 8px;
            font-size: 10px;
            font-weight: 700;
        }

        .section-popular .library-section-icon { background: #fff7ed; color: #ea580c; }
        .section-popular .library-book-footer { color: #ea580c; }
        .section-suggestions .library-section-icon { background: #ecfdf5; color: #059669; }
        .section-suggestions .library-book-footer { color: #059669; }
        .section-new .library-section-icon { background: #f5f3ff; color: #7c3aed; }
        .section-new .library-book-footer { color: #7c3aed; }
        .section-classrooms .library-section-icon { background: #e0f2fe; color: #0284c7; }

        /* DESAFIO DAS TURMAS */
        .classrooms-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            padding: 22px 24px;
        }
        .classroom-card {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 16px 18px;
            position: relative;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .classroom-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 18px rgba(15, 23, 42, 0.06);
        }
        .classroom-card.rank-1 {
            background: linear-gradient(180deg, #fffbeb 0%, #ffffff 80%);
            border-color: #fde68a;
        }
        .classroom-card.rank-2 {
            background: linear-gradient(180deg, #f8fafc 0%, #ffffff 80%);
            border-color: #e2e8f0;
        }
        .classroom-card.rank-3 {
            background: linear-gradient(180deg, #fff7ed 0%, #ffffff 80%);
            border-color: #fed7aa;
        }
        .classroom-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
        }
        .classroom-name {
            font-size: 15px;
            font-weight: 800;
            color: #0f172a;
        }
        .classroom-medal {
            font-size: 20px;
        }
        .classroom-bar-container {
            width: 100%;
            height: 8px;
            background: #e2e8f0;
            border-radius: 999px;
            overflow: hidden;
            margin-bottom: 10px;
        }
        .classroom-bar-fill {
            height: 100%;
            border-radius: 999px;
            background: #2563eb;
            transition: width 0.8s ease;
        }
        .rank-1 .classroom-bar-fill { background: #d97706; }
        .rank-2 .classroom-bar-fill { background: #64748b; }
        .rank-3 .classroom-bar-fill { background: #ea580c; }
        .classroom-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 11px;
            color: #64748b;
            font-weight: 600;
        }
        .classroom-footer strong {
            color: #0f172a;
            font-size: 12px;
        }

        /* CLUBE DO LEITOR */
        .reader-card {
            flex: 0 0 215px;
            width: 215px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            padding: 18px;
            box-sizing: border-box;
            position: relative;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .reader-card:hover { transform: translateY(-4px); box-shadow: 0 8px 24px rgba(15, 23, 42, 0.08); }
        .reader-card.podium-1 { background: linear-gradient(180deg, #fffbeb 0%, #ffffff 60%); border-color: #fde68a; }
        .reader-card.podium-2 { background: linear-gradient(180deg, #f8fafc 0%, #ffffff 60%); border-color: #e2e8f0; }
        .reader-card.podium-3 { background: linear-gradient(180deg, #fff7ed 0%, #ffffff 60%); border-color: #fed7aa; }
        .podium-badge { position: absolute; top: 14px; right: 14px; font-size: 18px; }
        .reader-avatar {
            width: 44px; height: 44px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px; background: #f1f5f9; margin-bottom: 12px;
        }
        .podium-1 .reader-avatar { background: #fef3c7; color: #b45309; }
        .podium-2 .reader-avatar { background: #e2e8f0; color: #475569; }
        .podium-3 .reader-avatar { background: #ffedd5; color: #c2410c; }
        .reader-name { font-size: 13px; font-weight: 800; color: #0f172a; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .reader-class { font-size: 11px; color: #64748b; margin-top: 4px; }
        .reader-count { margin-top: 14px; padding-top: 10px; border-top: 1px solid #f1f5f9; font-size: 11px; font-weight: 700; color: #2563eb; }

        /* PAINEL DE ATRASOS */
        .library-section-overdue { background: #fffdfd; border-color: #fecaca; }
        .library-section-overdue .library-section-header { background: #fff5f5; border-bottom-color: #fee2e2; }
        .overdue-card {
            flex: 0 0 220px; width: 220px; background: #ffffff;
            border: 1px solid #fecaca; border-radius: 14px; padding: 12px; box-sizing: border-box;
        }
        .overdue-cover {
            width: 100%; height: 160px; border-radius: 8px;
            overflow: hidden; background: #fef2f2; margin-bottom: 10px;
        }
        .overdue-cover img { width: 100%; height: 100%; object-fit: cover; }
        .overdue-book {
            font-size: 12px; font-weight: 700; color: #991b1b;
            display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
        }
        .overdue-student { font-size: 11px; color: #334155; font-weight: 600; margin-top: 6px; }
        .overdue-days { margin-top: 10px; padding-top: 8px; border-top: 1px solid #fee2e2; font-size: 11px; font-weight: 800; color: #dc2626; }

        .no-results { width: 100%; padding: 36px 20px; text-align: center; color: #94a3b8; font-size: 13px; }

        @media screen and (max-width: 768px) {
            .library-hero { padding: 24px; }
            .hero-title { font-size: 20px; }
            .hero-surprise-btn { width: 100%; justify-content: center; }
            .library-book-card { flex-basis: 145px; width: 145px; }
            .library-book-cover { height: 195px; }
        }
    </style>

    <script type="text/javascript">
        var GRADIENT_PALETTE = [
            'linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%)',
            'linear-gradient(135deg, #065f46 0%, #10b981 100%)',
            'linear-gradient(135deg, #7c2d12 0%, #ea580c 100%)',
            'linear-gradient(135deg, #581c87 0%, #a855f7 100%)',
            'linear-gradient(135deg, #831843 0%, #ec4899 100%)',
            'linear-gradient(135deg, #134e4a 0%, #14b8a6 100%)',
            'linear-gradient(135deg, #0f172a 0%, #475569 100%)'
        ];

        // Lista de títulos para o sorteio instantâneo do 'Me Surpreenda'
        var LISTA_SURPRESA = [];

        function executarBuscaTermo(termo) {
            if (!termo) return;
            termo = termo.trim();
            if (termo.length === 0) return;
            var queryFormatada = encodeURIComponent(termo).replace(/%20/g, '+');
            window.location.href = '?action=search_bibliographic#query=' + queryFormatada + '&material=all';
        }

        function executarBuscaHero() {
            var input = document.getElementById('heroSearchInput');
            if (input) {
                executarBuscaTermo(input.value);
            }
        }

        function abrirLivroSurpresa() {
            if (!LISTA_SURPRESA || LISTA_SURPRESA.length === 0) {
                // Fallback para uma busca de exploração caso a lista esteja vazia
                window.location.href = '?action=search_bibliographic#query=*&material=all';
                return;
            }
            var sorteado = LISTA_SURPRESA[Math.floor(Math.random() * LISTA_SURPRESA.length)];
            executarBuscaTermo(sorteado);
        }

        function handleImgError(img) {
            if (!img) return;
            var parent = img.parentElement;
            if (!parent) return;
            img.style.display = 'none';
            parent.removeAttribute('data-processed');
            renderizarCapasNaoCadastradas();
        }

        function renderizarCapasNaoCadastradas() {
            var containers = document.querySelectorAll('.library-book-cover, .overdue-cover');
            for (var i = 0; i < containers.length; i++) {
                var el = containers[i];
                var img = el.querySelector('img');
                if (img && img.style.display !== 'none') continue;
                if (el.getAttribute('data-processed') === 'true') continue;
                el.setAttribute('data-processed', 'true');

                var rawTitle = el.getAttribute('data-title') || 'Sem título';
                var rawAuthor = el.getAttribute('data-author') || '';

                var hash = 0;
                for (var h = 0; h < rawTitle.length; h++) {
                    hash = rawTitle.charCodeAt(h) + ((hash << 5) - hash);
                }
                var gradIndex = Math.abs(hash) % GRADIENT_PALETTE.length;
                var grad = GRADIENT_PALETTE[gradIndex];

                el.innerHTML = 
                    '<div class="book-styled-cover" style="background:' + grad + ';">' +
                    '  <div class="styled-cover-icon">📖</div>' +
                    '  <div class="styled-cover-title">' + escapeHtml(rawTitle) + '</div>' +
                    '  <div class="styled-cover-author">' + escapeHtml(rawAuthor) + '</div>' +
                    '</div>';
            }
        }

        function escapeHtml(str) {
            if (!str) return '';
            return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }

        function switchTheme(themeKey, btn) {
            var shelves = document.querySelectorAll('.theme-shelf');
            for (var i = 0; i < shelves.length; i++) {
                shelves[i].style.display = 'none';
            }
            var target = document.getElementById('shelf-' + themeKey);
            if (target) {
                target.style.display = 'flex';
            }
            var btns = document.querySelectorAll('.theme-filter-btn');
            for (var j = 0; j < btns.length; j++) {
                btns[j].className = 'theme-filter-btn';
            }
            if (btn) {
                btn.className = 'theme-filter-btn active';
            }
            renderizarCapasNaoCadastradas();
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', renderizarCapasNaoCadastradas);
        } else {
            renderizarCapasNaoCadastradas();
        }
        window.addEventListener('load', renderizarCapasNaoCadastradas);
    </script>
</layout:head>

<layout:body>
<%
ExtendedRequest req = (ExtendedRequest) request;

if (!req.isGlobalSchema()) {
    String schema = req.getSchema();
    Connection conn = null;

    String[] nomesMeses = {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"};
    Calendar cal = Calendar.getInstance();
    String mesAtual = nomesMeses[cal.get(Calendar.MONTH)];
    int hora = cal.get(Calendar.HOUR_OF_DAY);
    String saudacao = (hora >= 5 && hora < 12) ? "Bom dia" : (hora >= 12 && hora < 18) ? "Boa tarde" : "Boa noite";

    boolean isLogged = false;
    try {
        HttpSession sess = request.getSession(false);
        if (sess != null) {
            Enumeration attrNames = sess.getAttributeNames();
            while (attrNames.hasMoreElements()) {
                String name = (String) attrNames.nextElement();
                Object val = sess.getAttribute(name);
                if (val != null) {
                    String className = val.getClass().getName();
                    if (className.indexOf("Login") != -1 || className.indexOf("User") != -1 || 
                        name.toLowerCase().indexOf("login") != -1 || name.toLowerCase().indexOf("user") != -1) {
                        isLogged = true;
                        break;
                    }
                }
            }
        }
    } catch (Throwable ignored) {}

    int totalObras = 0;
    int totalExemplares = 0;
    int totalLeiturasMes = 0;
    List<String> titulosParaSorteio = new ArrayList<String>();

    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/biblivre4", "postgres", "abracadabra");

        // 1. Métricas do Acervo
        Statement stMeta = null;
        ResultSet rsMeta = null;
        try {
            stMeta = conn.createStatement();
            rsMeta = stMeta.executeQuery("SELECT " +
                "(SELECT COUNT(*) FROM " + schema + ".biblio_records) AS obras, " +
                "(SELECT COUNT(*) FROM " + schema + ".biblio_holdings) AS exemplares, " +
                "(SELECT COUNT(*) FROM " + schema + ".lendings WHERE created >= DATE_TRUNC('month', CURRENT_DATE)) AS leituras");
            if (rsMeta.next()) {
                totalObras = rsMeta.getInt("obras");
                totalExemplares = rsMeta.getInt("exemplares");
                totalLeiturasMes = rsMeta.getInt("leituras");
            }
        } catch (Exception ignored) {
        } finally {
            closeQuietly(rsMeta);
            closeQuietly(stMeta);
        }

        // 2. Coleta de livros para o sorteio do "Me Surpreenda"
        Statement stRand = null;
        ResultSet rsRand = null;
        try {
            stRand = conn.createStatement();
            rsRand = stRand.executeQuery("SELECT phrase FROM " + schema + ".biblio_idx_sort WHERE indexing_group_id = 3 ORDER BY RANDOM() LIMIT 40");
            while (rsRand.next()) {
                String t = rsRand.getString("phrase");
                if (t != null && !t.trim().isEmpty()) {
                    titulosParaSorteio.add(t.trim());
                }
            }
        } catch (Exception ignored) {
        } finally {
            closeQuietly(rsRand);
            closeQuietly(stRand);
        }

        List<MediaItem> todasMedias = carregarTodasMedias(conn, schema);
%>

<script type="text/javascript">
    // Alimenta a lista de sorteio dinamicamente do banco
    LISTA_SURPRESA = [
        <% for (int i = 0; i < titulosParaSorteio.size(); i++) { %>
            "<%= StringEscapeUtils.escapeEcmaScript(titulosParaSorteio.get(i)) %>"<%= (i < titulosParaSorteio.size() - 1) ? "," : "" %>
        <% } %>
    ];
</script>

<div class="library-dashboard">

    <!-- =========================================================
         HERO CONTEMPORÂNEO + BUSCA + BOTÃO ME SURPREENDA + PÍLULAS
         ========================================================= -->
    <div class="library-hero">
        <div class="hero-top-row">
            <div>
                <div class="hero-greeting"><span class="hero-greeting-pulse"></span> <%= saudacao %>, seja bem-vindo(a)</div>
                <h1 class="hero-title">O que você gostaria de ler hoje?</h1>
            </div>
            <div class="hero-stats-pills">
                <div class="hero-pill">📚 <strong><%= totalObras %></strong> obras</div>
                <div class="hero-pill">📦 <strong><%= totalExemplares %></strong> exemplares</div>
                <div class="hero-pill">🔥 <strong><%= totalLeiturasMes %></strong> leituras em <%= mesAtual %></div>
            </div>
        </div>

        <div class="hero-search-area">
            <div class="hero-search-box">
                <span class="hero-search-icon">🔍</span>
                <input type="text" 
                       id="heroSearchInput" 
                       class="hero-search-input" 
                       placeholder="Pesquisar por título, autor, assunto ou palavra-chave..." 
                       autocomplete="off" 
                       onkeydown="if(event.key === 'Enter' || event.keyCode === 13){ executarBuscaHero(); event.preventDefault(); return false; }" />
                <button type="button" class="hero-search-btn" onclick="executarBuscaHero();">Buscar</button>
            </div>
            <button type="button" class="hero-surprise-btn" onclick="abrirLivroSurpresa();" title="Sorteie um livro aleatório do acervo!">
                <span>🎲</span> Me surpreenda!
            </button>
        </div>

        <!-- PÍLULAS DE ASSUNTOS POPULARES -->
        <div class="hero-trending-topics">
            <span class="hero-trending-label">🔥 Temas em alta:</span>
            <span class="hero-topic-pill" onclick="executarBuscaTermo('dinossauro');">🦕 Dinossauros</span>
            <span class="hero-topic-pill" onclick="executarBuscaTermo('mitologia');">⚡ Mitologia Grega</span>
            <span class="hero-topic-pill" onclick="executarBuscaTermo('super-heroi');">🦸‍♂️ Super-Heróis</span>
            <span class="hero-topic-pill" onclick="executarBuscaTermo('magia');">🧙‍♂️ Magia & Bruxaria</span>
            <span class="hero-topic-pill" onclick="executarBuscaTermo('quadrinho');">💬 HQs & Gibis</span>
            <span class="hero-topic-pill" onclick="executarBuscaTermo('animais');">🐾 Bichos & Natureza</span>
            <span class="hero-topic-pill" onclick="executarBuscaTermo('espaco');">🚀 Espaço & Planetas</span>
            <span class="hero-topic-pill" onclick="executarBuscaTermo('contos');">👑 Contos de Fadas</span>
        </div>
    </div>

    <!-- =========================================================
         1. LIVROS MAIS LIDOS
         ========================================================= -->
    <div class="library-section section-popular">
        <div class="library-section-header">
            <div class="library-section-title-area">
                <div class="library-section-icon">🏆</div>
                <div>
                    <h2 class="library-section-title">Em alta na biblioteca</h2>
                    <div class="library-section-subtitle">Os títulos favoritos mais lidos pelos alunos e leitores</div>
                </div>
            </div>
            <div class="library-section-badge">Mais lidos</div>
        </div>
        <div class="library-books-scroll">
        <%
        Statement st1 = null;
        ResultSet rs1 = null;
        boolean hasMaisLidos = false;
        try {
            String sqlMaisLidos = 
                "SELECT top_books.record_id, top_books.total_lido, " +
                "(SELECT phrase FROM " + schema + ".biblio_idx_sort WHERE record_id = top_books.record_id AND indexing_group_id = 3 LIMIT 1) AS titulo, " +
                "(SELECT phrase FROM " + schema + ".biblio_idx_sort WHERE record_id = top_books.record_id AND indexing_group_id = 2 LIMIT 1) AS autor " +
                "FROM (SELECT bh.record_id, COUNT(l.id) AS total_lido FROM " + schema + ".lendings l " +
                "JOIN " + schema + ".biblio_holdings bh ON l.holding_id = bh.id " +
                "GROUP BY bh.record_id ORDER BY total_lido DESC LIMIT 10) AS top_books";

            st1 = conn.createStatement();
            rs1 = st1.executeQuery(sqlMaisLidos);
            while (rs1.next()) {
                hasMaisLidos = true;
                int recordId = rs1.getInt("record_id");
                String title = rs1.getString("titulo") != null ? rs1.getString("titulo") : "Sem título";
                String author = rs1.getString("autor") != null ? rs1.getString("autor") : "Autor desconhecido";
                String capaUrl = obterUrlCapa(conn, schema, recordId, title, todasMedias);
                boolean disp = isDisponivel(conn, schema, recordId);
        %>
            <div class="library-book-card" onclick="location.href='?action=search_bibliographic#query=<%= URLEncoder.encode(title, "UTF-8") %>&material=all'">
                <div class="library-book-cover" data-title="<%= StringEscapeUtils.escapeHtml4(title) %>" data-author="<%= StringEscapeUtils.escapeHtml4(author) %>">
                    <span class="status-badge <%= disp ? "status-available" : "status-lent" %>">
                        <%= disp ? "🟢 Na estante" : "🟠 Emprestado" %>
                    </span>
                    <% if (capaUrl != null) { %>
                        <img src="<%= capaUrl %>" alt="<%= StringEscapeUtils.escapeHtml4(title) %>" onerror="handleImgError(this)" />
                    <% } %>
                </div>
                <div class="library-book-title" title="<%= StringEscapeUtils.escapeHtml4(title) %>"><%= StringEscapeUtils.escapeHtml4(title) %></div>
                <div class="library-book-author" title="<%= StringEscapeUtils.escapeHtml4(author) %>"><%= StringEscapeUtils.escapeHtml4(author) %></div>
                <div class="library-book-footer">🔥 <%= rs1.getInt("total_lido") %> empréstimos</div>
            </div>
        <%  }
        } catch (Exception e) {
        } finally {
            closeQuietly(rs1);
            closeQuietly(st1);
        }
        if (!hasMaisLidos) { %><div class="no-results">Nenhum empréstimo registrado ainda.</div><% }
        %>
        </div>
    </div>

    <!-- =========================================================
         2. DESAFIO DAS TURMAS (RANKING COLETIVO)
         ========================================================= -->
    <div class="library-section section-classrooms">
        <div class="library-section-header">
            <div class="library-section-title-area">
                <div class="library-section-icon">🎖️</div>
                <div>
                    <h2 class="library-section-title">Desafio das turmas · <%= mesAtual %></h2>
                    <div class="library-section-subtitle">Qual sala mais retirou livros para leitura este mês</div>
                </div>
            </div>
            <div class="library-section-badge">Gincana da leitura</div>
        </div>

        <div class="classrooms-grid">
        <%
        Statement stTurmas = null;
        ResultSet rsTurmas = null;
        boolean hasTurmas = false;
        try {
            String sqlTurmas = 
                "SELECT " +
                "  uv.value AS turma, " +
                "  COUNT(l.id) AS total_lidos " +
                "FROM " + schema + ".lendings l " +
                "JOIN " + schema + ".users u ON l.user_id = u.id " +
                "JOIN " + schema + ".users_values uv ON u.id = uv.user_id " +
                "WHERE l.created >= DATE_TRUNC('month', CURRENT_DATE) " +
                "  AND l.created < (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month') " +
                "  AND uv.value IS NOT NULL AND LENGTH(TRIM(uv.value)) > 0 " +
                "  AND (uv.value ~ '^[0-9]' OR uv.value ~ '[0-9][A-Z]' OR uv.value ~* '(ano|série|serie|turma|classe)') " +
                "GROUP BY uv.value " +
                "ORDER BY total_lidos DESC " +
                "LIMIT 4";

            stTurmas = conn.createStatement();
            rsTurmas = stTurmas.executeQuery(sqlTurmas);
            int rankTurma = 0;
            int maxLidos = 1;

            while (rsTurmas.next()) {
                hasTurmas = true;
                rankTurma++;
                String turmaNome = rsTurmas.getString("turma");
                int qtd = rsTurmas.getInt("total_lidos");
                if (rankTurma == 1) { maxLidos = qtd > 0 ? qtd : 1; }
                int porcentagem = (int) Math.round(((double) qtd / (double) maxLidos) * 100);
                String cardClass = (rankTurma == 1) ? "rank-1" : (rankTurma == 2) ? "rank-2" : (rankTurma == 3) ? "rank-3" : "";
                String medal = (rankTurma == 1) ? "🥇" : (rankTurma == 2) ? "🥈" : (rankTurma == 3) ? "🥉" : "🎯";
        %>
            <div class="classroom-card <%= cardClass %>">
                <div class="classroom-header">
                    <div class="classroom-name"><%= StringEscapeUtils.escapeHtml4(turmaNome) %></div>
                    <div class="classroom-medal"><%= medal %></div>
                </div>
                <div class="classroom-bar-container">
                    <div class="classroom-bar-fill" style="width: <%= porcentagem %>%;"></div>
                </div>
                <div class="classroom-footer">
                    <span><%= rankTurma %>º Lugar no ranking</span>
                    <strong><%= qtd %> <%= qtd == 1 ? "livro lido" : "livros lidos" %></strong>
                </div>
            </div>
        <%  }
        } catch (Exception e) {
        } finally {
            closeQuietly(rsTurmas);
            closeQuietly(stTurmas);
        }
        if (!hasTurmas) {
        %>
            <div class="no-results" style="grid-column: 1 / -1;">
                📖 Registre empréstimos para os alunos com a turma cadastrada para ativar o Desafio das Turmas!
            </div>
        <% } %>
        </div>
    </div>

    <!-- =========================================================
         3. SUGESTÕES DO ACERVO (11 TEMÁTICAS)
         ========================================================= -->
    <div class="library-section section-suggestions">
        <div class="library-section-header">
            <div class="library-section-title-area">
                <div class="library-section-icon">✨</div>
                <div>
                    <h2 class="library-section-title">Explore por temas</h2>
                    <div class="library-section-subtitle">Descubra histórias incríveis separadas para você</div>
                </div>
            </div>
            <div class="library-section-badge">Curadoria</div>
        </div>

        <div class="library-theme-filters">
            <button type="button" class="theme-filter-btn active" onclick="switchTheme('todas', this)">✨ Todas</button>
            <button type="button" class="theme-filter-btn" onclick="switchTheme('fantasia', this)">🧙‍♂️ Fantasia & Magia</button>
            <button type="button" class="theme-filter-btn" onclick="switchTheme('princesa', this)">👑 Princesas & Fadas</button>
            <button type="button" class="theme-filter-btn" onclick="switchTheme('quadrinhos', this)">🦸 HQ & Gibis</button>
            <button type="button" class="theme-filter-btn" onclick="switchTheme('animais', this)">🐾 Animais & Bichos</button>
            <button type="button" class="theme-filter-btn" onclick="switchTheme('humor', this)">🤣 Humor & Diversão</button>
            <button type="button" class="theme-filter-btn" onclick="switchTheme('terror', this)">👻 Terror & Mistério</button>
            <button type="button" class="theme-filter-btn" onclick="switchTheme('romance', this)">💖 Romance & Amizade</button>
            <button type="button" class="theme-filter-btn" onclick="switchTheme('aventura', this)">🗺️ Aventura & Ação</button>
            <button type="button" class="theme-filter-btn" onclick="switchTheme('ciencia', this)">🔬 Ciência & Espaço</button>
            <button type="button" class="theme-filter-btn" onclick="switchTheme('classicos', this)">📚 Clássicos Infantis</button>
        </div>

        <%
        String[][] configuracaoTemas = {
            {"todas", "Todas", ""},
            {"fantasia", "Fantasia & Magia", "fantasia|magia|magic|brux|dragon|dragao|feitic|narnia|potter|hobbit|elfo|unicor|encant|monstro|duende|mitolog|percy jackson|varinha"},
            {"princesa", "Princesas & Fadas", "princes|princip|fada|castel|rainha|rei|cinderel|branca de neve|adormecid|reino|coroa|sapo|rapunzel|sereia|bela e a fera"},
            {"quadrinhos", "HQ & Gibis", "quadrinho|gibi|hq|manga|monica|cebolinha|cascao|magali|super-heroi|heroi|vingador|batman|homem-aranha|marvel|dc|graphic novel"},
            {"animais", "Animais & Bichos", "animal|animais|bicho|cao|cachorr|gato|felino|filhote|passaro|passarinho|dinossaur|fauna|floresta|selva|inseto|cavalo|leao|urso|lobo"},
            {"humor", "Humor & Diversão", "humor|engracad|comedia|piada|risad|travessur|banana|diario de um banana|divert|palhaco|confusao|bagunca|rir"},
            {"terror", "Terror & Mistério", "terror|horror|mister|suspens|fantas|assombr|vampir|zumbi|medo|pesadel|crime|detetiv|morte|sombra|arrepio|goosebumps"},
            {"romance", "Romance & Amizade", "romance|amor|paixao|namor|namorado|beijo|coracao|amizade|sentimento|encontro|declaracao|amigas|amigos"},
            {"aventura", "Aventura & Ação", "aventur|viag|exped|tesour|ilha|batalh|sobreviv|pirat|espac|mar|navio|guerra|corrida|floresta|desafio"},
            {"ciencia", "Ciência & Espaço", "ciencia|cientist|espaco|planeta|astronom|terra|dinossauro|corpo humano|experiencia|descoberta|universo|robo|tecnolog|inven"},
            {"classicos", "Clássicos Infantis", "lobato|sitio do picapau|ruth rocha|ziraldo|ana maria machado|menino maluquinho|pedro bandeira|eva furnari|walcyr carrasco"}
        };

        for (int t = 0; t < configuracaoTemas.length; t++) {
            String themeKey = configuracaoTemas[t][0];
            String themeLabel = configuracaoTemas[t][1];
            String regex = configuracaoTemas[t][2];
            boolean isFirst = (t == 0);

            Statement stTheme = null;
            ResultSet rsTheme = null;
            boolean hasThemeBooks = false;
        %>
            <div class="library-books-scroll theme-shelf" id="shelf-<%= themeKey %>" style="<%= isFirst ? "" : "display:none;" %>">
            <%
            try {
                String sqlTheme;
                if (regex.length() == 0) {
                    sqlTheme = 
                        "SELECT br.id AS record_id, " +
                        "(SELECT phrase FROM " + schema + ".biblio_idx_sort WHERE record_id = br.id AND indexing_group_id = 3 LIMIT 1) AS titulo, " +
                        "(SELECT phrase FROM " + schema + ".biblio_idx_sort WHERE record_id = br.id AND indexing_group_id = 2 LIMIT 1) AS autor " +
                        "FROM " + schema + ".biblio_records br " +
                        "WHERE br.id IN (SELECT id FROM " + schema + ".biblio_records ORDER BY RANDOM() LIMIT 10)";
                } else {
                    sqlTheme = 
                        "SELECT matched.record_id, " +
                        "(SELECT phrase FROM " + schema + ".biblio_idx_sort WHERE record_id = matched.record_id AND indexing_group_id = 3 LIMIT 1) AS titulo, " +
                        "(SELECT phrase FROM " + schema + ".biblio_idx_sort WHERE record_id = matched.record_id AND indexing_group_id = 2 LIMIT 1) AS autor " +
                        "FROM (" +
                        "   SELECT s.record_id FROM " + schema + ".biblio_idx_sort s " +
                        "   WHERE s.phrase ~* '" + regex + "' " +
                        "   GROUP BY s.record_id " +
                        "   ORDER BY RANDOM() LIMIT 10" +
                        ") matched";
                }

                stTheme = conn.createStatement();
                rsTheme = stTheme.executeQuery(sqlTheme);
                while (rsTheme.next()) {
                    hasThemeBooks = true;
                    int recordId = rsTheme.getInt("record_id");
                    String title = rsTheme.getString("titulo") != null ? rsTheme.getString("titulo") : "Sem título";
                    String author = rsTheme.getString("autor") != null ? rsTheme.getString("autor") : "Autor desconhecido";
                    String capaUrl = obterUrlCapa(conn, schema, recordId, title, todasMedias);
                    boolean disp = isDisponivel(conn, schema, recordId);
            %>
                <div class="library-book-card" onclick="location.href='?action=search_bibliographic#query=<%= URLEncoder.encode(title, "UTF-8") %>&material=all'">
                    <div class="library-book-cover" data-title="<%= StringEscapeUtils.escapeHtml4(title) %>" data-author="<%= StringEscapeUtils.escapeHtml4(author) %>">
                        <span class="status-badge <%= disp ? "status-available" : "status-lent" %>">
                            <%= disp ? "🟢 Na estante" : "🟠 Emprestado" %>
                        </span>
                        <% if (capaUrl != null) { %>
                            <img src="<%= capaUrl %>" alt="<%= StringEscapeUtils.escapeHtml4(title) %>" onerror="handleImgError(this)" />
                        <% } %>
                    </div>
                    <div class="library-book-title" title="<%= StringEscapeUtils.escapeHtml4(title) %>"><%= StringEscapeUtils.escapeHtml4(title) %></div>
                    <div class="library-book-author" title="<%= StringEscapeUtils.escapeHtml4(author) %>"><%= StringEscapeUtils.escapeHtml4(author) %></div>
                    <div class="library-book-footer">✨ <%= themeLabel %></div>
                </div>
            <%  }
            } catch (Exception e) {
            } finally {
                closeQuietly(rsTheme);
                closeQuietly(stTheme);
            }
            if (!hasThemeBooks) {
            %>
                <div class="no-results">Nenhum livro encontrado na temática <strong><%= themeLabel %></strong> ainda.</div>
            <% } %>
            </div>
        <% } %>
    </div>

    <!-- =========================================================
         4. NOVIDADES NO ACERVO
         ========================================================= -->
    <div class="library-section section-new">
        <div class="library-section-header">
            <div class="library-section-title-area">
                <div class="library-section-icon">🆕</div>
                <div>
                    <h2 class="library-section-title">Novos no acervo</h2>
                    <div class="library-section-subtitle">Títulos recém-chegados e prontos para empréstimo</div>
                </div>
            </div>
            <div class="library-section-badge">Recém-adicionados</div>
        </div>
        <div class="library-books-scroll">
        <%
        Statement st3 = null;
        ResultSet rs3 = null;
        boolean hasNovidades = false;
        try {
            String sqlNovidades = 
                "SELECT top_books.record_id, top_books.data_cadastro, " +
                "(SELECT phrase FROM " + schema + ".biblio_idx_sort WHERE record_id = top_books.record_id AND indexing_group_id = 3 LIMIT 1) AS titulo, " +
                "(SELECT phrase FROM " + schema + ".biblio_idx_sort WHERE record_id = top_books.record_id AND indexing_group_id = 2 LIMIT 1) AS autor " +
                "FROM (SELECT record_id, TO_CHAR(MIN(created), 'DD/MM/YYYY') AS data_cadastro FROM " + schema + ".biblio_holdings " +
                "WHERE record_id IS NOT NULL GROUP BY record_id ORDER BY MIN(created) DESC LIMIT 10) AS top_books";

            st3 = conn.createStatement();
            rs3 = st3.executeQuery(sqlNovidades);
            while (rs3.next()) {
                hasNovidades = true;
                int recordId = rs3.getInt("record_id");
                String title = rs3.getString("titulo") != null ? rs3.getString("titulo") : "Sem título";
                String author = rs3.getString("autor") != null ? rs3.getString("autor") : "Autor desconhecido";
                String dataCadastro = rs3.getString("data_cadastro") != null ? rs3.getString("data_cadastro") : "Recente";
                String capaUrl = obterUrlCapa(conn, schema, recordId, title, todasMedias);
                boolean disp = isDisponivel(conn, schema, recordId);
        %>
            <div class="library-book-card" onclick="location.href='?action=search_bibliographic#query=<%= URLEncoder.encode(title, "UTF-8") %>&material=all'">
                <div class="library-book-cover" data-title="<%= StringEscapeUtils.escapeHtml4(title) %>" data-author="<%= StringEscapeUtils.escapeHtml4(author) %>">
                    <span class="status-badge <%= disp ? "status-available" : "status-lent" %>">
                        <%= disp ? "🟢 Na estante" : "🟠 Emprestado" %>
                    </span>
                    <% if (capaUrl != null) { %>
                        <img src="<%= capaUrl %>" alt="<%= StringEscapeUtils.escapeHtml4(title) %>" onerror="handleImgError(this)" />
                    <% } %>
                </div>
                <div class="library-book-title" title="<%= StringEscapeUtils.escapeHtml4(title) %>"><%= StringEscapeUtils.escapeHtml4(title) %></div>
                <div class="library-book-author" title="<%= StringEscapeUtils.escapeHtml4(author) %>"><%= StringEscapeUtils.escapeHtml4(author) %></div>
                <div class="library-book-footer">📅 <%= dataCadastro %></div>
            </div>
        <%  }
        } catch (Exception e) {
        } finally {
            closeQuietly(rs3);
            closeQuietly(st3);
        }
        if (!hasNovidades) { %><div class="no-results">Nenhum livro recente cadastrado ainda.</div><% }
        %>
        </div>
    </div>

    <!-- =========================================================
         5. CLUBE DA LEITURA (PÓDIO GAMIFICADO DE ALUNOS)
         ========================================================= -->
    <div class="library-section">
        <div class="library-section-header">
            <div class="library-section-title-area">
                <div class="library-section-icon" style="background:#fff7ed; color:#d97706;">🌟</div>
                <div>
                    <h2 class="library-section-title">Clube da leitura · <%= mesAtual %></h2>
                    <div class="library-section-subtitle">Os leitores com maior número de empréstimos este mês</div>
                </div>
            </div>
            <div class="library-section-badge">Ranking individual</div>
        </div>
        <div class="library-books-scroll">
        <%
        Statement st4 = null;
        ResultSet rs4 = null;
        boolean hasLeitores = false;
        try {
            String sqlLeitoresMes = 
                "SELECT u.name AS aluno, " +
                "COALESCE((SELECT uv.value FROM " + schema + ".users_values uv " +
                "          WHERE uv.user_id = u.id " +
                "          AND (uv.value ~ '^[0-9]' OR uv.value LIKE '%@%' OR uv.value ~ '[0-9][A-Z]') " +
                "          LIMIT 1), 'Aluno') AS turma, " +
                "COUNT(l.id) AS total_lido " +
                "FROM " + schema + ".users u " +
                "JOIN " + schema + ".lendings l ON u.id = l.user_id " +
                "WHERE l.created >= DATE_TRUNC('month', CURRENT_DATE) " +
                "  AND l.created < (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month') " +
                "GROUP BY u.id, u.name " +
                "ORDER BY total_lido DESC " +
                "LIMIT 10";

            st4 = conn.createStatement();
            rs4 = st4.executeQuery(sqlLeitoresMes);
            int rank = 0;
            while (rs4.next()) {
                hasLeitores = true;
                rank++;
                String nomeCompleto = rs4.getString("aluno") != null ? rs4.getString("aluno") : "Aluno desconhecido";
                String turma = rs4.getString("turma");
                int qtdLivros = rs4.getInt("total_lido");
                String podiumClass = (rank == 1) ? "podium-1" : (rank == 2) ? "podium-2" : (rank == 3) ? "podium-3" : "";
                String medalha = (rank == 1) ? "🥇" : (rank == 2) ? "🥈" : (rank == 3) ? "🥉" : "";
        %>
            <div class="reader-card <%= podiumClass %>">
                <% if (!medalha.isEmpty()) { %><span class="podium-badge"><%= medalha %></span><% } %>
                <div class="reader-avatar"><%= (rank == 1) ? "👑" : "👤" %></div>
                <div class="reader-name" title="<%= StringEscapeUtils.escapeHtml4(nomeCompleto) %>"><%= StringEscapeUtils.escapeHtml4(getNomeCurto(nomeCompleto)) %></div>
                <div class="reader-class">Turma: <%= StringEscapeUtils.escapeHtml4(turma) %></div>
                <div class="reader-count">📖 <%= qtdLivros %> <%= qtdLivros == 1 ? "livro lido" : "livros lidos" %></div>
            </div>
        <%  }
        } catch (Exception e) {
        } finally {
            closeQuietly(rs4);
            closeQuietly(st4);
        }
        if (!hasLeitores) { %><div class="no-results">Nenhum empréstimo registrado em <%= mesAtual %> ainda.</div><% }
        %>
        </div>
    </div>

    <!-- =========================================================
         6. PAINEL DE ATRASOS (Apenas administradores/logados)
         ========================================================= -->
    <% if (isLogged) { %>
    <div class="library-section library-section-overdue">
        <div class="library-section-header">
            <div class="library-section-title-area">
                <div class="library-section-icon" style="background:#fef2f2; color:#dc2626;">⚠️</div>
                <div>
                    <h2 class="library-section-title" style="color:#991b1b;">Gestão de devoluções em atraso</h2>
                    <div class="library-section-subtitle" style="color:#b91c1c;">Empréstimos que ultrapassaram o prazo estimado de devolução</div>
                </div>
            </div>
            <div class="library-section-badge" style="background:#fef2f2; color:#b91c1c; border-color:#fecaca;">Administrativo</div>
        </div>
        <div class="library-books-scroll">
        <%
        Statement st5 = null;
        ResultSet rs5 = null;
        boolean hasAtrasados = false;
        try {
            String sqlAtrasados = 
                "SELECT u.name AS aluno, " +
                "COALESCE((SELECT uv.value FROM " + schema + ".users_values uv WHERE uv.user_id = u.id AND (uv.value ~ '^[0-9]' OR uv.value ~ '[0-9][A-Z]') LIMIT 1), 'Sem turma') AS turma, " +
                "bh.record_id, " +
                "TO_CHAR(l.expected_return_date, 'DD/MM/YYYY') AS prazo, " +
                "(CURRENT_DATE - l.expected_return_date::date) AS dias_atraso, " +
                "(SELECT phrase FROM " + schema + ".biblio_idx_sort WHERE record_id = bh.record_id AND indexing_group_id = 3 LIMIT 1) AS livro " +
                "FROM " + schema + ".lendings l " +
                "JOIN " + schema + ".users u ON u.id = l.user_id " +
                "JOIN " + schema + ".biblio_holdings bh ON l.holding_id = bh.id " +
                "WHERE l.return_date IS NULL AND l.expected_return_date < CURRENT_DATE " +
                "ORDER BY dias_atraso DESC LIMIT 10";

            st5 = conn.createStatement();
            rs5 = st5.executeQuery(sqlAtrasados);
            while (rs5.next()) {
                hasAtrasados = true;
                int recordId = rs5.getInt("record_id");
                String aluno = rs5.getString("aluno") != null ? rs5.getString("aluno") : "Desconhecido";
                String livro = rs5.getString("livro") != null ? rs5.getString("livro") : "Livro sem título";
                String capaUrl = obterUrlCapa(conn, schema, recordId, livro, todasMedias);
        %>
            <div class="overdue-card">
                <div class="overdue-cover" data-title="<%= StringEscapeUtils.escapeHtml4(livro) %>" data-author="">
                    <% if (capaUrl != null) { %>
                        <img src="<%= capaUrl %>" alt="<%= StringEscapeUtils.escapeHtml4(livro) %>" onerror="handleImgError(this)" />
                    <% } %>
                </div>
                <div class="overdue-book" title="<%= StringEscapeUtils.escapeHtml4(livro) %>"><%= StringEscapeUtils.escapeHtml4(livro) %></div>
                <div class="overdue-student">👤 <%= StringEscapeUtils.escapeHtml4(getNomeCurto(aluno)) %></div>
                <div style="font-size:10px; color:#64748b; margin-top:3px;"><%= StringEscapeUtils.escapeHtml4(rs5.getString("turma")) %> · Venceu em <%= rs5.getString("prazo") %></div>
                <div class="overdue-days">⏱ <%= rs5.getInt("dias_atraso") %> dias de atraso</div>
            </div>
        <%  }
        } catch (Exception e) {
        } finally {
            closeQuietly(rs5);
            closeQuietly(st5);
        }
        if (!hasAtrasados) { %><div class="no-results" style="color:#15803d;">🎉 Nenhum exemplar em atraso no momento.</div><% }
        %>
        </div>
    </div>
    <% } %>

</div>

<%
    } catch (Exception e) {
    } finally {
        closeQuietly(conn);
    }
} else {
%>
    <div style="max-width:900px; margin:30px auto; padding:24px; border:1px solid #e2e8f0; border-radius:16px; background:#fff;">
        <h2 style="margin-top:0; font-size:18px; font-weight:700;"><i18n:text key="text.multi_schema.select_library" /></h2>
        <% for (SchemaDTO schemaDto : Schemas.getSchemas()) {
            if (schemaDto.isDisabled()) continue; %>
            <div style="padding:14px 0; border-bottom:1px solid #f1f5f9;">
                <a href="<%= schemaDto.getSchema() %>/" style="color:#2563eb; font-size:16px; font-weight:700; text-decoration:none;"><%= Configurations.getHtml(schemaDto.getSchema(), Constants.CONFIG_TITLE) %></a>
                <div style="color:#64748b; font-size:12px; margin-top:3px;"><%= Configurations.getHtml(schemaDto.getSchema(), Constants.CONFIG_SUBTITLE) %></div>
            </div>
        <% } %>
    </div>
<% } %>
</layout:body>