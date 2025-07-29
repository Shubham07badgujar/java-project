<%@ page import="java.sql.*, org.json.JSONArray" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

String type = request.getParameter("type");
String query = request.getParameter("query");
String spacecraft = request.getParameter("spacecraft");

JSONArray suggestions = new JSONArray();

if (type == null) {
    response.setStatus(400);
    out.print(suggestions.toString());
    return;
}

String column = null;
if ("spacecraft".equals(type)) {
    column = "SpacecraftName";
    if (query == null) {
        response.setStatus(400);
        out.print(suggestions.toString());
        return;
    }
} else if ("subsystem".equals(type)) {
    column = "SubsystemName";
    if (query == null && spacecraft == null) {
        response.setStatus(400);
        out.print(suggestions.toString());
        return;
    }
} else {
    response.setStatus(400);
    out.print(suggestions.toString());
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);

    String sql;
    if ("subsystem".equals(type) && spacecraft != null) {
        // Get subsystems for specific spacecraft
        sql = "SELECT DISTINCT " + column + " FROM Page_Info WHERE SpacecraftName = ? AND " + column + " LIKE ? LIMIT 10";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, spacecraft);
        pstmt.setString(2, "%" + (query != null ? query : "") + "%");
    } else {
        // General search
        sql = "SELECT DISTINCT " + column + " FROM Page_Info WHERE " + column + " LIKE ? LIMIT 10";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, "%" + query + "%");
    }

    rs = pstmt.executeQuery();
    while (rs.next()) {
        suggestions.put(rs.getString(1));
    }
} catch (Exception e) {
    e.printStackTrace();
    response.setStatus(500);
} finally {
    if (rs != null) try { rs.close(); } catch (Exception ex) {}
    if (pstmt != null) try { pstmt.close(); } catch (Exception ex) {}
    if (conn != null) try { conn.close(); } catch (Exception ex) {}
    out.print(suggestions.toString());
}
%> 