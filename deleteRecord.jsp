<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONObject" %>
<%
    response.setContentType("application/json");
    String pageId = request.getParameter("pageId");
    JSONObject result = new JSONObject();

    if (pageId == null || pageId.trim().isEmpty()) {
        result.put("error", "No PageID provided");
        out.print(result.toString());
        return;
    }

    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    
    Connection conn = null;
    PreparedStatement pstmt1 = null;
    PreparedStatement pstmt2 = null;

    try {
        Class.forName("org.sqlite.JDBC");
        conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);
        conn.setAutoCommit(false);

        // Delete from Page_Data first
        String sql1 = "DELETE FROM Page_Data WHERE PageID = ?";
        pstmt1 = conn.prepareStatement(sql1);
        pstmt1.setString(1, pageId);
        pstmt1.executeUpdate();

        // Then delete from Page_Info
        String sql2 = "DELETE FROM Page_Info WHERE PageID = ?";
        pstmt2 = conn.prepareStatement(sql2);
        pstmt2.setString(1, pageId);
        int rowsAffected = pstmt2.executeUpdate();

        conn.commit();

        if (rowsAffected > 0) {
            result.put("success", true);
        } else {
            result.put("error", "No record found with that PageID");
        }
    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (Exception ex) {}
        result.put("error", e.getMessage());
    } finally {
        if (pstmt1 != null) try { pstmt1.close(); } catch (Exception ex) {}
        if (pstmt2 != null) try { pstmt2.close(); } catch (Exception ex) {}
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }

    out.print(result.toString());
%> 