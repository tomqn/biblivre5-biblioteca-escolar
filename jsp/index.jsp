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

    private String getIniciais(String nomeCompleto) {
        if (nomeCompleto == null || nomeCompleto.trim().isEmpty()) return "?";
        String[] partes = nomeCompleto.trim().split("\\s+");
        StringBuilder sb = new StringBuilder();
        sb.append(partes[0].charAt(0));
        if (partes.length > 1) sb.append(partes[partes.length - 1].charAt(0));
        return sb.toString().toUpperCase();
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
    <link href="https://fonts.googleapis.com/css2?family=Lora:wght@400;500;600;700&family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <style type="text/css">
        /* =========================================================
           BIBLIOTECA — design system (ui-ux-pro-max-skill)
           P1 Acessibilidade · P2 Toque · P3 Performance
           P4 Estilo (editorial, sem AI purple/pink)
           P5 Layout responsivo com clamp()
           ========================================================= */
        :root {
            --ink: #0f172a;
            --ink-2: #1e293b;
            --ink-muted: #475569;   /* contraste AA 5.1:1 sobre branco */
            --paper: #ffffff;
            --paper-warm: #f8fafc;
            --rule: #e2e8f0;
            --rule-soft: #f1f5f9;
            --accent: #2563eb;
            --accent-dark: #1d4ed8;
            --bronze: #8b6914;
            --gold-1: #f59e0b;
            --gold-2: #d97706;
            --burgundy: #991b1b;
            --focus-ring: #d97706;
        }

        *:focus { outline: none; }
        button:focus-visible,
        a:focus-visible,
        input:focus-visible,
        [tabindex]:focus-visible {
            outline: 2px solid var(--focus-ring);
            outline-offset: 3px;
            border-radius: 6px;
        }

        .sr-only {
            position: absolute;
            width: 1px; height: 1px;
            padding: 0; margin: -1px;
            overflow: hidden;
            clip: rect(0,0,0,0);
            white-space: nowrap;
            border: 0;
        }

        .library-dashboard {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            width: 100%;
            max-width: 1240px;
            margin: 0 auto;
            padding: 16px 0 60px;
            color: var(--ink);
            box-sizing: border-box;
            font-size: 14px;
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
        }
        .library-dashboard * { box-sizing: border-box; }

        /* =========================================================
           HERO
           ========================================================= */
        .library-hero {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            border-radius: 20px;
            padding: 40px 40px 32px;
            margin-bottom: 30px;
            color: #ffffff;
            position: relative;
            overflow: hidden;
            box-shadow: 0 12px 32px rgba(15, 23, 42, 0.14);
        }
        .library-hero::after {
            content: '';
            position: absolute;
            right: -60px; bottom: -80px;
            width: 280px; height: 280px;
            background: radial-gradient(circle, rgba(59, 130, 246, 0.22) 0%, rgba(255, 255, 255, 0) 70%);
            border-radius: 50%;
            pointer-events: none;
        }
        .library-hero::before {
            content: '';
            position: absolute;
            left: -80px; top: -80px;
            width: 240px; height: 240px;
            background: radial-gradient(circle, rgba(217, 119, 6, 0.12) 0%, rgba(255, 255, 255, 0) 70%);
            border-radius: 50%;
            pointer-events: none;
        }
        .hero-top-row {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 24px;
            margin-bottom: 30px;
            position: relative;
            z-index: 1;
        }
        .hero-greeting {
            font-size: 11px;
            font-weight: 700;
            color: #cbd5e1;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .hero-greeting::before {
            content: '';
            width: 24px; height: 1px;
            background: var(--gold-1);
            display: inline-block;
        }
        .hero-title {
            font-family: 'Lora', Georgia, serif;
            font-size: clamp(1.375rem, 3vw, 2.125rem);
            font-weight: 500;
            line-height: 1.2;
            letter-spacing: -0.015em;
            color: #ffffff;
            margin: 0;
            max-width: 560px;
        }

        .hero-stats-pills {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .hero-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.14);
            padding: 8px 16px;
            min-height: 40px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            color: #e2e8f0;
            backdrop-filter: blur(10px);
        }
        .hero-pill svg { flex-shrink: 0; opacity: 0.9; color: var(--gold-1); }
        .hero-pill strong {
            font-family: 'Lora', Georgia, serif;
            font-size: 16px;
            font-weight: 600;
            letter-spacing: 0;
            text-transform: none;
            color: #ffffff;
        }

        /* ---------- Busca ---------- */
        .hero-search-area {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            max-width: 900px;
            position: relative;
            z-index: 1;
        }
        .hero-search-box {
            display: flex;
            align-items: center;
            background: #ffffff;
            border-radius: 14px;
            padding: 5px 6px 5px 18px;
            box-shadow: 0 8px 28px rgba(0, 0, 0, 0.28), 0 2px 6px rgba(0, 0, 0, 0.12);
            flex: 1;
            min-width: 280px;
            transition: box-shadow 0.18s ease;
        }
        .hero-search-box:focus-within {
            box-shadow: 0 0 0 3px rgba(217, 119, 6, 0.45), 0 8px 28px rgba(0,0,0,0.28);
        }
        .hero-search-icon {
            color: #64748b;
            margin-right: 12px;
            flex-shrink: 0;
        }
        .hero-search-input {
            flex: 1;
            border: none;
            outline: none;
            font-size: 14px;
            color: var(--ink);
            font-family: inherit;
            background: transparent;
            padding: 12px 0;
        }
        .hero-search-input::placeholder { color: #94a3b8; }
        .hero-search-btn {
            background: linear-gradient(135deg, var(--accent) 0%, var(--accent-dark) 100%);
            color: #ffffff;
            border: none;
            padding: 12px 24px;
            min-height: 44px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 700;
            font-family: inherit;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            cursor: pointer;
            transition: transform 0.15s ease, box-shadow 0.15s ease;
            box-shadow: 0 3px 10px rgba(37, 99, 235, 0.35);
            white-space: nowrap;
        }
        .hero-search-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(37, 99, 235, 0.45);
        }

        .hero-surprise-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: linear-gradient(135deg, var(--gold-1) 0%, var(--gold-2) 100%);
            color: #ffffff;
            border: none;
            padding: 12px 24px;
            min-height: 44px;
            border-radius: 14px;
            font-size: 12px;
            font-weight: 800;
            font-family: inherit;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            cursor: pointer;
            box-shadow: 0 6px 20px rgba(217, 119, 6, 0.4);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            white-space: nowrap;
        }
        .hero-surprise-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 28px rgba(217, 119, 6, 0.55);
        }

        /* ---------- Temas em alta ---------- */
        .hero-trending-topics {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            margin-top: 28px;
            padding-top: 24px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            position: relative;
            z-index: 1;
        }
        .hero-trending-label {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 10px;
            font-weight: 700;
            color: #cbd5e1;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            margin-right: 8px;
        }
        .hero-topic-pill {
            display: inline-flex;
            align-items: center;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.14);
            color: #f1f5f9;
            padding: 10px 16px;
            min-height: 40px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.18s ease, color 0.18s ease, transform 0.18s ease;
            backdrop-filter: blur(6px);
            user-select: none;
            font-family: inherit;
        }
        .hero-topic-pill:hover {
            background: #ffffff;
            color: var(--ink);
            border-color: #ffffff;
        }

        /* =========================================================
           SEÇÕES
           ========================================================= */
        .library-section {
            background: #ffffff;
            border: 1px solid var(--rule);
            border-radius: 18px;
            margin-bottom: 28px;
            overflow: hidden;
            box-shadow: 0 2px 12px rgba(15, 23, 42, 0.04);
        }
        .library-section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 22px 28px;
            border-bottom: 1px solid var(--rule-soft);
            gap: 16px;
            flex-wrap: wrap;
        }
        .library-section-title-area {
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .library-section-icon {
            width: 46px; height: 46px;
            min-width: 46px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.1);
        }
        .library-section-icon svg { width: 22px; height: 22px; }

        .section-popular .library-section-icon {
            background: linear-gradient(135deg, #ea580c 0%, #c2410c 100%);
            box-shadow: 0 4px 14px rgba(234, 88, 12, 0.32);
        }
        .section-classrooms .library-section-icon {
            background: linear-gradient(135deg, #0284c7 0%, #075985 100%);
            box-shadow: 0 4px 14px rgba(2, 132, 199, 0.32);
        }
        .section-suggestions .library-section-icon {
            background: linear-gradient(135deg, #059669 0%, #065f46 100%);
            box-shadow: 0 4px 14px rgba(5, 150, 105, 0.32);
        }
        .section-new .library-section-icon {
            /* skill: anti-padrão AI purple removido → teal sóbrio */
            background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
            box-shadow: 0 4px 14px rgba(13, 148, 136, 0.32);
        }
        .section-club .library-section-icon {
            background: linear-gradient(135deg, var(--gold-1) 0%, var(--gold-2) 100%);
            box-shadow: 0 4px 14px rgba(217, 119, 6, 0.32);
        }
        .library-section-overdue .library-section-icon {
            background: linear-gradient(135deg, #dc2626 0%, var(--burgundy) 100%);
            box-shadow: 0 4px 14px rgba(220, 38, 38, 0.32);
        }

        .library-section-title {
            font-family: 'Lora', Georgia, serif;
            font-size: clamp(1.125rem, 2vw, 1.375rem);
            font-weight: 600;
            letter-spacing: -0.01em;
            color: var(--ink);
            margin: 0;
            line-height: 1.2;
        }
        .library-section-subtitle {
            font-size: 12px;
            color: var(--ink-muted);
            margin-top: 4px;
            letter-spacing: 0.01em;
        }
        .library-section-badge {
            padding: 7px 14px;
            border-radius: 999px;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: 0.16em;
            text-transform: uppercase;
            background: var(--paper-warm);
            color: var(--ink-muted);
            border: 1px solid var(--rule);
            white-space: nowrap;
        }
        .section-popular .library-section-badge { background: #fff7ed; color: #c2410c; border-color: #fed7aa; }
        .section-classrooms .library-section-badge { background: #f0f9ff; color: #075985; border-color: #bae6fd; }
        .section-suggestions .library-section-badge { background: #ecfdf5; color: #065f46; border-color: #a7f3d0; }
        .section-new .library-section-badge { background: #f0fdfa; color: #0f766e; border-color: #99f6e4; }
        .section-club .library-section-badge { background: #fffbeb; color: #b45309; border-color: #fde68a; }
        .library-section-overdue { background: #fffdfd; border-color: #fecaca; }
        .library-section-overdue .library-section-header { background: #fff5f5; border-bottom-color: #fee2e2; }
        .library-section-overdue .library-section-title { color: var(--burgundy); }
        .library-section-overdue .library-section-badge { background: #fef2f2; color: #b91c1c; border-color: #fecaca; }

        /* ---------- Filtros temáticos ---------- */
        .library-theme-filters {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 14px 22px;
            background: var(--paper-warm);
            border-bottom: 1px solid var(--rule-soft);
            overflow-x: auto;
            scrollbar-width: thin;
        }
        .theme-filter-btn {
            border: 1px solid var(--rule);
            background: #ffffff;
            color: var(--ink-muted);
            padding: 10px 16px;
            min-height: 40px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            white-space: nowrap;
            transition: background 0.18s ease, color 0.18s ease, border-color 0.18s ease;
            font-family: inherit;
        }
        .theme-filter-btn:hover { background: var(--paper-warm); color: var(--ink); border-color: #cbd5e1; }
        .theme-filter-btn.active {
            background: var(--ink);
            color: #ffffff;
            border-color: var(--ink);
            box-shadow: 0 3px 10px rgba(15, 23, 42, 0.18);
        }

        /* =========================================================
           CARROSSEL + CAPAS 3D
           ========================================================= */
        .library-books-scroll {
            display: flex;
            gap: 20px;
            overflow-x: auto;
            padding: 26px 28px 30px;
            scrollbar-width: thin;
            scrollbar-color: #cbd5e1 transparent;
        }
        .library-books-scroll::-webkit-scrollbar { height: 6px; }
        .library-books-scroll::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }

        a.library-book-card,
        .library-book-card {
            flex: 0 0 172px;
            width: 172px;
            cursor: pointer;
            transition: transform 0.26s cubic-bezier(0.34, 1.4, 0.64, 1);
            position: relative;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        .library-book-card:hover { transform: translateY(-6px); }

        .library-book-cover {
            width: 100%;
            aspect-ratio: 172 / 235;
            border-radius: 10px;
            overflow: hidden;
            position: relative;
            margin-bottom: 14px;
            background: var(--rule);
            box-shadow:
                0 10px 22px rgba(15, 23, 42, 0.14),
                0 3px 6px rgba(15, 23, 42, 0.07);
            transition: box-shadow 0.26s ease;
        }
        .library-book-card:hover .library-book-cover {
            box-shadow:
                0 20px 36px rgba(15, 23, 42, 0.24),
                0 6px 12px rgba(15, 23, 42, 0.12);
        }
        .library-book-cover::after {
            content: '';
            position: absolute;
            left: 0; top: 0; bottom: 0;
            width: 12px;
            background: linear-gradient(to right,
                rgba(0,0,0,0.32) 0%,
                rgba(255,255,255,0.16) 35%,
                rgba(0,0,0,0.12) 70%,
                rgba(0,0,0,0) 100%);
            pointer-events: none;
            z-index: 2;
        }
        .library-book-cover img {
            width: 100%; height: 100%;
            object-fit: cover;
            display: block;
        }

        .status-badge {
            position: absolute;
            top: 10px; right: 10px;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 9px;
            font-weight: 800;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            z-index: 3;
            backdrop-filter: blur(8px);
            box-shadow: 0 2px 8px rgba(0,0,0,0.22);
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .status-badge svg { flex-shrink: 0; }
        .status-available { background: rgba(22, 101, 52, 0.92); color: #f0fdf4; }
        .status-lent { background: rgba(154, 52, 18, 0.92); color: #fff7ed; }

        /* Fallback — capa dura em gradiente */
        .book-styled-cover {
            width: 100%; height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 18px 14px;
            color: #ffffff;
            text-align: center;
            position: relative;
        }
        .book-styled-cover::before {
            content: '';
            position: absolute;
            inset: 9px;
            border: 1px solid rgba(255,255,255,0.16);
            border-radius: 3px;
            pointer-events: none;
        }
        .styled-cover-icon {
            font-family: 'Lora', Georgia, serif;
            font-size: 14px;
            letter-spacing: 0.4em;
            opacity: 0.75;
            margin-top: 6px;
        }
        .styled-cover-title {
            font-family: 'Lora', Georgia, serif;
            font-size: 13px;
            font-weight: 600;
            line-height: 1.35;
            display: -webkit-box;
            -webkit-line-clamp: 4;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-shadow: 0 1px 6px rgba(0,0,0,0.4);
            padding: 0 4px;
        }
        .styled-cover-author {
            font-size: 9px;
            letter-spacing: 0.14em;
            text-transform: uppercase;
            opacity: 0.82;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .library-book-title {
            font-family: 'Lora', Georgia, serif;
            font-size: 13px;
            font-weight: 600;
            line-height: 1.35;
            color: var(--ink);
            margin-bottom: 4px;
            min-height: 36px;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
        .library-book-author {
            font-size: 11px;
            color: var(--ink-muted);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            letter-spacing: 0.01em;
        }
        .library-book-footer {
            font-size: 10px;
            font-weight: 700;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            margin-top: 8px;
        }
        .section-popular .library-book-footer { color: #ea580c; }
        .section-suggestions .library-book-footer { color: #059669; }
        .section-new .library-book-footer { color: #0d9488; }

        /* =========================================================
           DESAFIO DAS TURMAS
           ========================================================= */
        .classrooms-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
            gap: 16px;
            padding: 24px 28px 28px;
        }
        .classroom-card {
            background: var(--paper-warm);
            border: 1px solid var(--rule);
            border-radius: 14px;
            padding: 18px 20px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            position: relative;
        }
        .classroom-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 22px rgba(15, 23, 42, 0.08);
        }
        .classroom-card.rank-1 {
            background: linear-gradient(180deg, #fffbeb 0%, #ffffff 80%);
            border-color: #fde68a;
            box-shadow: 0 4px 16px rgba(217, 119, 6, 0.1);
        }
        .classroom-card.rank-2 { background: linear-gradient(180deg, #f8fafc 0%, #ffffff 80%); }
        .classroom-card.rank-3 { background: linear-gradient(180deg, #fff7ed 0%, #ffffff 80%); border-color: #fed7aa; }

        .classroom-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 14px;
            gap: 12px;
        }
        .classroom-name {
            font-family: 'Lora', Georgia, serif;
            font-size: 17px;
            font-weight: 600;
            color: var(--ink);
            letter-spacing: -0.01em;
        }
        .classroom-medal {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-family: 'Lora', Georgia, serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.04em;
            color: var(--ink-muted);
        }
        .classroom-medal svg { flex-shrink: 0; }
        .rank-1 .classroom-medal { color: var(--gold-2); }
        .rank-2 .classroom-medal { color: #64748b; }
        .rank-3 .classroom-medal { color: #ea580c; }

        .classroom-bar-container {
            width: 100%;
            height: 6px;
            background: var(--rule);
            border-radius: 999px;
            overflow: hidden;
            margin-bottom: 12px;
        }
        .classroom-bar-fill {
            height: 100%;
            border-radius: 999px;
            background: linear-gradient(90deg, var(--accent) 0%, var(--accent-dark) 100%);
            transition: width 0.9s ease;
        }
        .rank-1 .classroom-bar-fill { background: linear-gradient(90deg, var(--gold-1) 0%, var(--gold-2) 100%); }
        .rank-2 .classroom-bar-fill { background: linear-gradient(90deg, #94a3b8 0%, #475569 100%); }
        .rank-3 .classroom-bar-fill { background: linear-gradient(90deg, #fb923c 0%, #ea580c 100%); }

        .classroom-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 11px;
            color: var(--ink-muted);
            font-weight: 500;
        }
        .classroom-footer strong {
            color: var(--ink);
            font-weight: 700;
            font-size: 12px;
        }

        /* =========================================================
           CLUBE DA LEITURA
           ========================================================= */
        .reader-card {
            flex: 0 0 220px;
            width: 220px;
            background: #ffffff;
            border: 1px solid var(--rule);
            border-radius: 16px;
            padding: 20px;
            position: relative;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .reader-card:hover { transform: translateY(-4px); box-shadow: 0 10px 26px rgba(15, 23, 42, 0.09); }
        .reader-card.podium-1 {
            background: linear-gradient(180deg, #fffbeb 0%, #ffffff 60%);
            border-color: #fde68a;
            box-shadow: 0 4px 18px rgba(217, 119, 6, 0.12);
        }
        .reader-card.podium-2 { background: linear-gradient(180deg, #f8fafc 0%, #ffffff 60%); }
        .reader-card.podium-3 { background: linear-gradient(180deg, #fff7ed 0%, #ffffff 60%); border-color: #fed7aa; }

        .podium-badge {
            position: absolute;
            top: 16px; right: 16px;
            font-family: 'Lora', Georgia, serif;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            color: var(--ink-muted);
        }
        .podium-1 .podium-badge { color: var(--gold-2); }
        .podium-2 .podium-badge { color: #64748b; }
        .podium-3 .podium-badge { color: #ea580c; }

        .reader-avatar {
            width: 48px; height: 48px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Lora', Georgia, serif;
            font-size: 17px;
            font-weight: 600;
            background: var(--paper-warm);
            color: var(--ink);
            margin-bottom: 14px;
            box-shadow: inset 0 0 0 1px var(--rule);
        }
        .podium-1 .reader-avatar {
            background: linear-gradient(135deg, var(--gold-1) 0%, var(--gold-2) 100%);
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(217, 119, 6, 0.35);
        }
        .podium-2 .reader-avatar {
            background: linear-gradient(135deg, #94a3b8 0%, #475569 100%);
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(71, 85, 105, 0.3);
        }
        .podium-3 .reader-avatar {
            background: linear-gradient(135deg, #fb923c 0%, #ea580c 100%);
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(234, 88, 12, 0.3);
        }

        .reader-name {
            font-family: 'Lora', Georgia, serif;
            font-size: 14px;
            font-weight: 600;
            color: var(--ink);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .reader-class {
            font-size: 11px;
            color: var(--ink-muted);
            margin-top: 5px;
        }
        .reader-count {
            margin-top: 16px;
            padding-top: 12px;
            border-top: 1px solid var(--rule-soft);
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: var(--accent);
        }
        .podium-1 .reader-count { color: var(--gold-2); }

        /* =========================================================
           ATRASOS
           ========================================================= */
        .overdue-card {
            flex: 0 0 210px;
            width: 210px;
            background: #ffffff;
            border: 1px solid #fecaca;
            border-radius: 14px;
            padding: 12px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .overdue-card:hover { transform: translateY(-3px); box-shadow: 0 8px 20px rgba(153, 27, 27, 0.1); }
        .overdue-cover {
            width: 100%;
            aspect-ratio: 210 / 155;
            border-radius: 8px;
            overflow: hidden;
            background: #fef2f2;
            margin-bottom: 12px;
            position: relative;
            box-shadow: 0 4px 12px rgba(153, 27, 27, 0.12);
        }
        .overdue-cover::after {
            content: '';
            position: absolute;
            left: 0; top: 0; bottom: 0;
            width: 8px;
            background: linear-gradient(to right, rgba(0,0,0,0.28), rgba(255,255,255,0.12) 60%, transparent);
            pointer-events: none;
        }
        .overdue-cover img { width: 100%; height: 100%; object-fit: cover; display: block; }
        .overdue-book {
            font-family: 'Lora', Georgia, serif;
            font-size: 12px;
            font-weight: 600;
            color: var(--burgundy);
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            line-height: 1.4;
        }
        .overdue-student {
            font-size: 11px;
            color: var(--ink-2);
            font-weight: 600;
            margin-top: 8px;
        }
        .overdue-meta {
            font-size: 10px;
            color: var(--ink-muted);
            margin-top: 4px;
            letter-spacing: 0.02em;
        }
        .overdue-days {
            margin-top: 10px;
            padding-top: 9px;
            border-top: 1px solid #fee2e2;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: #dc2626;
        }

        /* ---------- Estado vazio ---------- */
        .no-results {
            width: 100%;
            padding: 40px 20px;
            text-align: center;
            color: var(--ink-muted);
            font-size: 13px;
            font-style: italic;
        }

        /* ---------- Prefers-reduced-motion (skill P1) ---------- */
        @media (prefers-reduced-motion: reduce) {
            .library-book-card,
            .library-book-card:hover,
            .hero-surprise-btn,
            .hero-surprise-btn:hover,
            .hero-search-btn,
            .hero-search-btn:hover,
            .classroom-card,
            .classroom-card:hover,
            .reader-card,
            .reader-card:hover,
            .overdue-card,
            .overdue-card:hover {
                transform: none !important;
                transition: none !important;
            }
        }

        @media screen and (max-width: 768px) {
            .library-hero { padding: 28px 22px; }
            .hero-pill { padding: 6px 12px; font-size: 10px; min-height: 36px; }
            .hero-pill strong { font-size: 14px; }
            .hero-surprise-btn { width: 100%; justify-content: center; }
            .library-section-header { padding: 18px 20px; }
            .library-section-icon { width: 38px; height: 38px; min-width: 38px; border-radius: 11px; }
            .library-section-icon svg { width: 18px; height: 18px; }
            .library-theme-filters { padding: 12px 16px; }
            .library-books-scroll { padding: 20px 18px 24px; gap: 16px; }
            .library-book-card { flex-basis: 148px; width: 148px; }
        }
    </style>

    <script type="text/javascript">
        // Paleta sem roxo/rosa (anti-padrão AI do skill)
        var COVER_PALETTE = [
            'linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%)',   /* navy */
            'linear-gradient(135deg, #065f46 0%, #10b981 100%)',   /* verde */
            'linear-gradient(135deg, #7c2d12 0%, #ea580c 100%)',   /* laranja */
            'linear-gradient(135deg, #134e4a 0%, #14b8a6 100%)',   /* teal */
            'linear-gradient(135deg, #78350f 0%, #d97706 100%)',   /* ouro */
            'linear-gradient(135deg, #0f172a 0%, #475569 100%)',   /* slate */
            'linear-gradient(135deg, #831843 0%, #be123c 100%)',   /* bordô */
            'linear-gradient(135deg, #064e3b 0%, #047857 100%)'    /* floresta */
        ];

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
            if (input) executarBuscaTermo(input.value);
        }

        function abrirLivroSurpresa() {
            if (!LISTA_SURPRESA || LISTA_SURPRESA.length === 0) {
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
                var grad = COVER_PALETTE[Math.abs(hash) % COVER_PALETTE.length];

                el.innerHTML =
                    '<div class="book-styled-cover" style="background:' + grad + ';">' +
                    '  <div class="styled-cover-icon">&#9670;</div>' +
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
            if (target) target.style.display = 'flex';
            var btns = document.querySelectorAll('.theme-filter-btn');
            for (var j = 0; j < btns.length; j++) {
                btns[j].className = 'theme-filter-btn';
                btns[j].setAttribute('aria-selected', 'false');
            }
            if (btn) {
                btn.className = 'theme-filter-btn active';
                btn.setAttribute('aria-selected', 'true');
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
    <link rel="stylesheet" type="text/css" href="static/styles/biblivre.modern.css" />
</layout:head>

<layout:body>
<%
ExtendedRequest req = (ExtendedRequest) request;

if (!req.isGlobalSchema()) {
    String schema = req.getSchema();
    Connection conn = null;

    String[] nomesMeses = {"janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"};
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
    LISTA_SURPRESA = [
        <% for (int i = 0; i < titulosParaSorteio.size(); i++) { %>
            "<%= StringEscapeUtils.escapeEcmaScript(titulosParaSorteio.get(i)) %>"<%= (i < titulosParaSorteio.size() - 1) ? "," : "" %>
        <% } %>
    ];
</script>

<div class="library-dashboard">

    <!-- =========================================================
         HERO
         ========================================================= -->
    <div class="library-hero">
        <div class="hero-top-row">
            <div>
                <div class="hero-greeting"><%= saudacao %>, seja bem-vindo</div>
                <h1 class="hero-title">O que você gostaria de ler hoje?</h1>
            </div>
            <div class="hero-stats-pills">
                <div class="hero-pill">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                    <strong><%= totalObras %></strong> obras
                </div>
                <div class="hero-pill">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="m7.5 4.27 9 5.15"/><path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/></svg>
                    <strong><%= totalExemplares %></strong> exemplares
                </div>
                <div class="hero-pill">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"/><polyline points="16 7 22 7 22 13"/></svg>
                    <strong><%= totalLeiturasMes %></strong> leituras em <%= mesAtual %>
                </div>
            </div>
        </div>

        <div class="hero-search-area">
            <div class="hero-search-box">
                <svg class="hero-search-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
                <label for="heroSearchInput" class="sr-only">Pesquisar no acervo</label>
                <input type="text"
                       id="heroSearchInput"
                       class="hero-search-input"
                       placeholder="Pesquise por título, autor, assunto ou palavra-chave"
                       autocomplete="off"
                       onkeydown="if(event.key === 'Enter' || event.keyCode === 13){ executarBuscaHero(); event.preventDefault(); return false; }" />
                <button type="button" class="hero-search-btn" onclick="executarBuscaHero();">Buscar</button>
            </div>
            <button type="button" class="hero-surprise-btn" onclick="abrirLivroSurpresa();" aria-label="Descobrir um livro aleatório do acervo">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M2 18h1.4c1.3 0 2.5-.6 3.3-1.7l6.1-8.6c.7-1.1 2-1.7 3.3-1.7H22"/><path d="m18 2 4 4-4 4"/><path d="M2 6h1.9c1.5 0 2.9.7 3.8 1.9"/><path d="M22 18h-5.9c-1.3 0-2.6-.7-3.3-1.8l-.5-.8"/><path d="m18 14 4 4-4 4"/></svg>
                Descobrir
            </button>
        </div>

        <div class="hero-trending-topics">
            <span class="hero-trending-label">
                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"/><polyline points="16 7 22 7 22 13"/></svg>
                Temas em alta
            </span>
            <button type="button" class="hero-topic-pill" onclick="executarBuscaTermo('dinossauro');">Dinossauros</button>
            <button type="button" class="hero-topic-pill" onclick="executarBuscaTermo('mitologia');">Mitologia</button>
            <button type="button" class="hero-topic-pill" onclick="executarBuscaTermo('super-heroi');">Super-Heróis</button>
            <button type="button" class="hero-topic-pill" onclick="executarBuscaTermo('magia');">Magia</button>
            <button type="button" class="hero-topic-pill" onclick="executarBuscaTermo('quadrinho');">HQs &amp; Gibis</button>
            <button type="button" class="hero-topic-pill" onclick="executarBuscaTermo('animais');">Natureza</button>
            <button type="button" class="hero-topic-pill" onclick="executarBuscaTermo('espaco');">Espaço</button>
            <button type="button" class="hero-topic-pill" onclick="executarBuscaTermo('contos');">Contos de Fadas</button>
        </div>
    </div>

    <!-- =========================================================
         1. MAIS LIDOS
         ========================================================= -->
    <div class="library-section section-popular">
        <div class="library-section-header">
            <div class="library-section-title-area">
                <div class="library-section-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/><path d="M4 22h16"/><path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/><path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/><path d="M18 2H6v7a6 6 0 0 0 12 0V2Z"/></svg>
                </div>
                <div>
                    <h2 class="library-section-title">Em alta na biblioteca</h2>
                    <div class="library-section-subtitle">Os títulos mais procurados pelos leitores</div>
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
            <a class="library-book-card" href="?action=search_bibliographic#query=<%= URLEncoder.encode(title, "UTF-8") %>&material=all">
                <div class="library-book-cover" data-title="<%= StringEscapeUtils.escapeHtml4(title) %>" data-author="<%= StringEscapeUtils.escapeHtml4(author) %>">
                    <span class="status-badge <%= disp ? "status-available" : "status-lent" %>">
                        <svg width="6" height="6" viewBox="0 0 6 6" aria-hidden="true" focusable="false"><circle cx="3" cy="3" r="3" fill="currentColor"/></svg>
                        <%= disp ? "Disponível" : "Emprestado" %>
                    </span>
                    <% if (capaUrl != null) { %>
                        <img src="<%= capaUrl %>" alt="Capa de <%= StringEscapeUtils.escapeHtml4(title) %>" loading="lazy" decoding="async" onerror="handleImgError(this)" />
                    <% } %>
                </div>
                <div class="library-book-title" title="<%= StringEscapeUtils.escapeHtml4(title) %>"><%= StringEscapeUtils.escapeHtml4(title) %></div>
                <div class="library-book-author" title="<%= StringEscapeUtils.escapeHtml4(author) %>"><%= StringEscapeUtils.escapeHtml4(author) %></div>
                <div class="library-book-footer"><%= rs1.getInt("total_lido") %> empréstimos</div>
            </a>
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
         2. DESAFIO DAS TURMAS
         ========================================================= -->
    <div class="library-section section-classrooms">
        <div class="library-section-header">
            <div class="library-section-title-area">
                <div class="library-section-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><circle cx="12" cy="8" r="6"/><path d="M15.477 12.89 17 22l-5-3-5 3 1.523-9.11"/></svg>
                </div>
                <div>
                    <h2 class="library-section-title">Desafio das turmas · <%= mesAtual %></h2>
                    <div class="library-section-subtitle">Turmas com maior número de empréstimos no mês</div>
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
                String posicao = rankTurma + "º";
        %>
            <div class="classroom-card <%= cardClass %>">
                <div class="classroom-header">
                    <div class="classroom-name"><%= StringEscapeUtils.escapeHtml4(turmaNome) %></div>
                    <div class="classroom-medal">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><circle cx="12" cy="8" r="6"/><path d="M15.477 12.89 17 22l-5-3-5 3 1.523-9.11"/></svg>
                        <%= posicao %>
                    </div>
                </div>
                <div class="classroom-bar-container">
                    <div class="classroom-bar-fill" style="width: <%= porcentagem %>%;"></div>
                </div>
                <div class="classroom-footer">
                    <span><%= posicao %> lugar no ranking</span>
                    <strong><%= qtd %> <%= qtd == 1 ? "livro" : "livros" %></strong>
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
                Registre empréstimos para os alunos com a turma cadastrada para ativar o Desafio das Turmas.
            </div>
        <% } %>
        </div>
    </div>

    <!-- =========================================================
         3. EXPLORE POR TEMAS
         ========================================================= -->
    <div class="library-section section-suggestions">
        <div class="library-section-header">
            <div class="library-section-title-area">
                <div class="library-section-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/></svg>
                </div>
                <div>
                    <h2 class="library-section-title">Explore por temas</h2>
                    <div class="library-section-subtitle">Seleções do acervo organizadas por assunto</div>
                </div>
            </div>
            <div class="library-section-badge">Curadoria</div>
        </div>

        <div class="library-theme-filters" role="tablist" aria-label="Filtros temáticos">
            <button type="button" class="theme-filter-btn active" role="tab" aria-selected="true" onclick="switchTheme('todas', this)">Todas</button>
            <button type="button" class="theme-filter-btn" role="tab" aria-selected="false" onclick="switchTheme('fantasia', this)">Fantasia &amp; Magia</button>
            <button type="button" class="theme-filter-btn" role="tab" aria-selected="false" onclick="switchTheme('princesa', this)">Princesas &amp; Fadas</button>
            <button type="button" class="theme-filter-btn" role="tab" aria-selected="false" onclick="switchTheme('quadrinhos', this)">HQ &amp; Gibis</button>
            <button type="button" class="theme-filter-btn" role="tab" aria-selected="false" onclick="switchTheme('animais', this)">Animais &amp; Bichos</button>
            <button type="button" class="theme-filter-btn" role="tab" aria-selected="false" onclick="switchTheme('humor', this)">Humor</button>
            <button type="button" class="theme-filter-btn" role="tab" aria-selected="false" onclick="switchTheme('terror', this)">Terror &amp; Mistério</button>
            <button type="button" class="theme-filter-btn" role="tab" aria-selected="false" onclick="switchTheme('romance', this)">Romance &amp; Amizade</button>
            <button type="button" class="theme-filter-btn" role="tab" aria-selected="false" onclick="switchTheme('aventura', this)">Aventura &amp; Ação</button>
            <button type="button" class="theme-filter-btn" role="tab" aria-selected="false" onclick="switchTheme('ciencia', this)">Ciência &amp; Espaço</button>
            <button type="button" class="theme-filter-btn" role="tab" aria-selected="false" onclick="switchTheme('classicos', this)">Clássicos Infantis</button>
        </div>

        <%
        String[][] configuracaoTemas = {
            {"todas", "Todas", ""},
            {"fantasia", "Fantasia & Magia", "fantasia|magia|magic|brux|dragon|dragao|feitic|narnia|potter|hobbit|elfo|unicor|encant|monstro|duende|mitolog|percy jackson|varinha"},
            {"princesa", "Princesas & Fadas", "princes|princip|fada|castel|rainha|rei|cinderel|branca de neve|adormecid|reino|coroa|sapo|rapunzel|sereia|bela e a fera"},
            {"quadrinhos", "HQ & Gibis", "quadrinho|gibi|hq|manga|monica|cebolinha|cascao|magali|super-heroi|heroi|vingador|batman|homem-aranha|marvel|dc|graphic novel"},
            {"animais", "Animais & Bichos", "animal|animais|bicho|cao|cachorr|gato|felino|filhote|passaro|passarinho|dinossaur|fauna|floresta|selva|inseto|cavalo|leao|urso|lobo"},
            {"humor", "Humor", "humor|engracad|comedia|piada|risad|travessur|banana|diario de um banana|divert|palhaco|confusao|bagunca|rir"},
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
                <a class="library-book-card" href="?action=search_bibliographic#query=<%= URLEncoder.encode(title, "UTF-8") %>&material=all">
                    <div class="library-book-cover" data-title="<%= StringEscapeUtils.escapeHtml4(title) %>" data-author="<%= StringEscapeUtils.escapeHtml4(author) %>">
                        <span class="status-badge <%= disp ? "status-available" : "status-lent" %>">
                            <svg width="6" height="6" viewBox="0 0 6 6" aria-hidden="true" focusable="false"><circle cx="3" cy="3" r="3" fill="currentColor"/></svg>
                            <%= disp ? "Disponível" : "Emprestado" %>
                        </span>
                        <% if (capaUrl != null) { %>
                            <img src="<%= capaUrl %>" alt="Capa de <%= StringEscapeUtils.escapeHtml4(title) %>" loading="lazy" decoding="async" onerror="handleImgError(this)" />
                        <% } %>
                    </div>
                    <div class="library-book-title" title="<%= StringEscapeUtils.escapeHtml4(title) %>"><%= StringEscapeUtils.escapeHtml4(title) %></div>
                    <div class="library-book-author" title="<%= StringEscapeUtils.escapeHtml4(author) %>"><%= StringEscapeUtils.escapeHtml4(author) %></div>
                    <div class="library-book-footer"><%= themeLabel %></div>
                </a>
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
         4. NOVIDADES
         ========================================================= -->
    <div class="library-section section-new">
        <div class="library-section-header">
            <div class="library-section-title-area">
                <div class="library-section-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="10"/><path d="M8 12h8"/><path d="M12 8v8"/></svg>
                </div>
                <div>
                    <h2 class="library-section-title">Novos no acervo</h2>
                    <div class="library-section-subtitle">Títulos recém-adicionados e disponíveis para empréstimo</div>
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
            <a class="library-book-card" href="?action=search_bibliographic#query=<%= URLEncoder.encode(title, "UTF-8") %>&material=all">
                <div class="library-book-cover" data-title="<%= StringEscapeUtils.escapeHtml4(title) %>" data-author="<%= StringEscapeUtils.escapeHtml4(author) %>">
                    <span class="status-badge <%= disp ? "status-available" : "status-lent" %>">
                        <svg width="6" height="6" viewBox="0 0 6 6" aria-hidden="true" focusable="false"><circle cx="3" cy="3" r="3" fill="currentColor"/></svg>
                        <%= disp ? "Disponível" : "Emprestado" %>
                    </span>
                    <% if (capaUrl != null) { %>
                        <img src="<%= capaUrl %>" alt="Capa de <%= StringEscapeUtils.escapeHtml4(title) %>" loading="lazy" decoding="async" onerror="handleImgError(this)" />
                    <% } %>
                </div>
                <div class="library-book-title" title="<%= StringEscapeUtils.escapeHtml4(title) %>"><%= StringEscapeUtils.escapeHtml4(title) %></div>
                <div class="library-book-author" title="<%= StringEscapeUtils.escapeHtml4(author) %>"><%= StringEscapeUtils.escapeHtml4(author) %></div>
                <div class="library-book-footer">Adicionado em <%= dataCadastro %></div>
            </a>
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
         5. CLUBE DA LEITURA
         ========================================================= -->
    <div class="library-section section-club">
        <div class="library-section-header">
            <div class="library-section-title-area">
                <div class="library-section-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                </div>
                <div>
                    <h2 class="library-section-title">Clube da leitura · <%= mesAtual %></h2>
                    <div class="library-section-subtitle">Leitores com maior número de empréstimos no mês</div>
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
                String badge = (rank <= 3) ? (rank + "º lugar") : "";
        %>
            <div class="reader-card <%= podiumClass %>">
                <% if (!badge.isEmpty()) { %><span class="podium-badge"><%= badge %></span><% } %>
                <div class="reader-avatar" aria-hidden="true"><%= getIniciais(nomeCompleto) %></div>
                <div class="reader-name" title="<%= StringEscapeUtils.escapeHtml4(nomeCompleto) %>"><%= StringEscapeUtils.escapeHtml4(getNomeCurto(nomeCompleto)) %></div>
                <div class="reader-class">Turma: <%= StringEscapeUtils.escapeHtml4(turma) %></div>
                <div class="reader-count"><%= qtdLivros %> <%= qtdLivros == 1 ? "livro lido" : "livros lidos" %></div>
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
         6. ATRASOS (somente logados)
         ========================================================= -->
    <% if (isLogged) { %>
    <div class="library-section library-section-overdue">
        <div class="library-section-header">
            <div class="library-section-title-area">
                <div class="library-section-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><path d="M12 9v4"/><path d="M12 17h.01"/></svg>
                </div>
                <div>
                    <h2 class="library-section-title">Devoluções em atraso</h2>
                    <div class="library-section-subtitle">Empréstimos que ultrapassaram o prazo previsto de devolução</div>
                </div>
            </div>
            <div class="library-section-badge">Administrativo</div>
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
                        <img src="<%= capaUrl %>" alt="Capa de <%= StringEscapeUtils.escapeHtml4(livro) %>" loading="lazy" decoding="async" onerror="handleImgError(this)" />
                    <% } %>
                </div>
                <div class="overdue-book" title="<%= StringEscapeUtils.escapeHtml4(livro) %>"><%= StringEscapeUtils.escapeHtml4(livro) %></div>
                <div class="overdue-student"><%= StringEscapeUtils.escapeHtml4(getNomeCurto(aluno)) %></div>
                <div class="overdue-meta"><%= StringEscapeUtils.escapeHtml4(rs5.getString("turma")) %> · venceu em <%= rs5.getString("prazo") %></div>
                <div class="overdue-days"><%= rs5.getInt("dias_atraso") %> dias de atraso</div>
            </div>
        <%  }
        } catch (Exception e) {
        } finally {
            closeQuietly(rs5);
            closeQuietly(st5);
        }
        if (!hasAtrasados) { %><div class="no-results" style="color:#15803d; font-style: normal;">Nenhum exemplar em atraso no momento.</div><% }
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
    <div style="max-width:900px; margin:30px auto; padding:32px; border:1px solid #e2e8f0; border-radius:2px; background:#fff;">
        <h2 style="margin-top:0; font-family:'Lora',Georgia,serif; font-size:20px; font-weight:500; letter-spacing:-0.01em; color:#0f172a; padding-left:16px; position:relative;">
            <span style="position:absolute; left:0; top:4px; bottom:4px; width:3px; background:#8b6914;"></span>
            <i18n:text key="text.multi_schema.select_library" />
        </h2>
        <% for (SchemaDTO schemaDto : Schemas.getSchemas()) {
            if (schemaDto.isDisabled()) continue; %>
            <div style="padding:16px 0; border-bottom:1px solid #e2e8f0;">
                <a href="<%= schemaDto.getSchema() %>/" style="color:#0f172a; font-family:'Lora',Georgia,serif; font-size:16px; font-weight:500; text-decoration:none;"><%= Configurations.getHtml(schemaDto.getSchema(), Constants.CONFIG_TITLE) %></a>
                <div style="color:#475569; font-size:12px; margin-top:4px;"><%= Configurations.getHtml(schemaDto.getSchema(), Constants.CONFIG_SUBTITLE) %></div>
            </div>
        <% } %>
    </div>
<% } %>
<script type="text/javascript" src="static/scripts/menu-inicio.js"></script>
</layout:body>