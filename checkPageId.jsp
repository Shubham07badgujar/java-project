<%@ page import="java.sql.*, java.io.File, org.json.JSONObject" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

String pageId = request.getParameter("pageId");
JSONObject result = new JSONObject();

if (pageId == null || pageId.trim().isEmpty()) {
    response.setStatus(400);
    result.put("error", "Missing pageId");
    out.print(result.toString());
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);

    pstmt = conn.prepareStatement("SELECT 1 FROM Page_Info WHERE PageID = ?");
    pstmt.setString(1, pageId);
    rs = pstmt.executeQuery();

    result.put("exists", rs.next());
    out.print(result.toString());

} catch (Exception e) {
    e.printStackTrace();
    response.setStatus(500);
    result.put("error", "Database error: " + e.getMessage());
    out.print(result.toString());
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%> 