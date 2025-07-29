<%@ page import="java.sql.*, org.json.JSONObject" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

JSONObject result = new JSONObject();
String query = request.getParameter("query");

if (query == null || query.trim().isEmpty()) {
    response.setStatus(400);
    result.put("error", "Query parameter is required");
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

    String sql = "SELECT PageID FROM Page_Info " +
                 "WHERE SpacecraftName LIKE ? OR SubsystemName LIKE ? OR RecordTitle LIKE ? " +
                 "LIMIT 1";

    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + query + "%");
    pstmt.setString(2, "%" + query + "%");
    pstmt.setString(3, "%" + query + "%");

    rs = pstmt.executeQuery();
    if (rs.next()) {
        result.put("pageId", rs.getString("PageID"));
    } else {
        result.put("error", "No matching records found");
    }
} catch (SQLException e) {
    response.setStatus(500);
    result.put("error", "Database error: " + e.getMessage());
} catch (Exception e) {
    response.setStatus(500);
    result.put("error", "Server error: " + e.getMessage());
} finally {
    if (rs != null) try { rs.close(); } catch (Exception ex) {}
    if (pstmt != null) try { pstmt.close(); } catch (Exception ex) {}
    if (conn != null) try { conn.close(); } catch (Exception ex) {}
    out.print(result.toString());
}
%> 