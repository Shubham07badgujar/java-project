<%@ page import="java.sql.*, org.json.JSONObject" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

JSONObject result = new JSONObject();

Connection conn = null;
Statement stmt = null;
ResultSet rs = null;

try {
    String dbPath = getServletContext().getRealPath("/spacecraft.db");
    Class.forName("org.sqlite.JDBC");
    
    String dbUrl = "jdbc:sqlite:" + dbPath;
    conn = DriverManager.getConnection(dbUrl);
    
    stmt = conn.createStatement();
    
    // Check if Page_Info table exists and has records
    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM Page_Info");
    rs.next();
    int recordCount = rs.getInt("count");
    rs.close();
    
    result.put("success", true);
    result.put("databaseReady", recordCount > 0);
    result.put("recordCount", recordCount);
    
    if (recordCount > 0) {
        // Get the first record
        rs = stmt.executeQuery("SELECT PageID, PageNo, SpacecraftName, SubsystemName FROM Page_Info ORDER BY PageNo ASC LIMIT 1");
        if (rs.next()) {
            JSONObject firstRecord = new JSONObject();
            firstRecord.put("pageId", rs.getString("PageID"));
            firstRecord.put("pageNo", rs.getInt("PageNo"));
            firstRecord.put("spacecraftName", rs.getString("SpacecraftName"));
            firstRecord.put("subsystemName", rs.getString("SubsystemName"));
            result.put("firstRecord", firstRecord);
        }
        rs.close();
    }
    
} catch (Exception e) {
    System.err.println("Error in getDatabaseStatus.jsp: " + e.getMessage());
    result.put("success", false);
    result.put("error", e.getMessage());
    result.put("databaseReady", false);
    result.put("recordCount", 0);
    
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}

out.print(result.toString());
%>
