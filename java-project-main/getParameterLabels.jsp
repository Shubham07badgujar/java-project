<%@ page import="java.sql.*, org.json.JSONObject" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

JSONObject result = new JSONObject();

String pageId = request.getParameter("pageId");
if (pageId == null || pageId.trim().isEmpty()) {
    response.setStatus(400);
    result.put("error", "PageID is required");
    out.print(result.toString());
    return;
}

Connection conn = null;
PreparedStatement stmt = null;
ResultSet rs = null;

try {
    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);

    // Get custom parameter labels for this PageID
    stmt = conn.prepareStatement("SELECT ParameterIndex, CustomLabel FROM Parameter_Labels WHERE PageID = ? ORDER BY ParameterIndex");
    stmt.setString(1, pageId);
    rs = stmt.executeQuery();

    JSONObject labels = new JSONObject();
    while (rs.next()) {
        int paramIndex = rs.getInt("ParameterIndex");
        String customLabel = rs.getString("CustomLabel");
        labels.put("param" + paramIndex, customLabel);
    }

    result.put("success", true);
    result.put("labels", labels);
    result.put("pageId", pageId);

} catch (Exception e) {
    e.printStackTrace();
    response.setStatus(500);
    result.put("error", "Database error: " + e.getMessage());

} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}

out.print(result.toString());
%>
