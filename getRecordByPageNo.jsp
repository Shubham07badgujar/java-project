<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONObject" %>
<%
    response.setContentType("application/json");
    String pageNoStr = request.getParameter("pageNo");
    JSONObject result = new JSONObject();

    if (pageNoStr == null || pageNoStr.trim().isEmpty()) {
        result.put("error", "No PageNo provided");
        out.print(result.toString());
        return;
    }

    int pageNo;
    try {
        pageNo = Integer.parseInt(pageNoStr);
    } catch (NumberFormatException e) {
        result.put("error", "Invalid PageNo");
        out.print(result.toString());
        return;
    }

    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.sqlite.JDBC");
        conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);

        String sql = "SELECT PageID FROM Page_Info WHERE PageNo = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, pageNo);

        rs = pstmt.executeQuery();
        if (rs.next()) {
            result.put("pageId", rs.getString("PageID"));
        } else {
            result.put("error", "Record not found");
        }
    } catch (Exception e) {
        result.put("error", "Database error: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ex) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception ex) {}
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }

    out.print(result.toString());
%> 