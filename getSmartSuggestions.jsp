<%@ page import="java.sql.*, org.json.JSONArray, org.json.JSONObject" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

String query = request.getParameter("query");
JSONArray suggestions = new JSONArray();

if (query == null || query.trim().isEmpty()) {
    out.print(suggestions.toString());
    return;
}

query = query.trim();
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);

    // Get spacecraft suggestions
    String spacecraftSQL = "SELECT DISTINCT SpacecraftName, COUNT(*) as subsystem_count " +
                          "FROM Page_Info " +
                          "WHERE SpacecraftName LIKE ? " +
                          "GROUP BY SpacecraftName " +
                          "ORDER BY SpacecraftName LIMIT 5";
    
    pstmt = conn.prepareStatement(spacecraftSQL);
    pstmt.setString(1, "%" + query + "%");
    rs = pstmt.executeQuery();
    
    while (rs.next()) {
        JSONObject suggestion = new JSONObject();
        suggestion.put("text", rs.getString("SpacecraftName"));
        suggestion.put("type", "spacecraft");
        suggestion.put("icon", "");
        suggestion.put("subsystems", rs.getInt("subsystem_count"));
        suggestion.put("description", rs.getInt("subsystem_count") + " subsystem(s)");
        suggestions.put(suggestion);
    }
    rs.close();
    pstmt.close();

    // Get subsystem suggestions
    String subsystemSQL = "SELECT DISTINCT SubsystemName, SpacecraftName, COUNT(*) as count " +
                         "FROM Page_Info " +
                         "WHERE SubsystemName LIKE ? " +
                         "GROUP BY SubsystemName, SpacecraftName " +
                         "ORDER BY SubsystemName LIMIT 5";
    
    pstmt = conn.prepareStatement(subsystemSQL);
    pstmt.setString(1, "%" + query + "%");
    rs = pstmt.executeQuery();
    
    while (rs.next()) {
        JSONObject suggestion = new JSONObject();
        suggestion.put("text", rs.getString("SubsystemName"));
        suggestion.put("type", "subsystem");
        suggestion.put("icon", "");
        suggestion.put("spacecraft", rs.getString("SpacecraftName"));
        suggestion.put("description", "in " + rs.getString("SpacecraftName"));
        suggestions.put(suggestion);
    }
    rs.close();
    pstmt.close();

    // If no specific matches, try partial matches
    if (suggestions.length() == 0) {
        String partialSQL = "SELECT DISTINCT SpacecraftName " +
                           "FROM Page_Info " +
                           "WHERE SpacecraftName LIKE ? " +
                           "ORDER BY SpacecraftName LIMIT 3";
        
        pstmt = conn.prepareStatement(partialSQL);
        pstmt.setString(1, "%" + query + "%");
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            JSONObject suggestion = new JSONObject();
            suggestion.put("text", rs.getString("SpacecraftName"));
            suggestion.put("type", "spacecraft");
            suggestion.put("icon", "");
            suggestion.put("description", "Spacecraft");
            suggestions.put(suggestion);
        }
        rs.close();
        pstmt.close();
    }

} catch (Exception e) {
    e.printStackTrace();
    response.setStatus(500);
    JSONObject error = new JSONObject();
    error.put("error", e.getMessage());
    suggestions.put(error);
} finally {
    if (rs != null) try { rs.close(); } catch (Exception ex) {}
    if (pstmt != null) try { pstmt.close(); } catch (Exception ex) {}
    if (conn != null) try { conn.close(); } catch (Exception ex) {}
}

out.print(suggestions.toString());
%>
