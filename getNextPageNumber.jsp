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
    
    // Get the highest page number from Page_Info table
    rs = stmt.executeQuery("SELECT MAX(PageNo) as maxPageNo FROM Page_Info");
    
    int nextPageNo = 1; // Default to 1 if no records exist
    if (rs.next()) {
        int maxPageNo = rs.getInt("maxPageNo");
        if (maxPageNo > 0) {
            nextPageNo = maxPageNo + 1;
        }
    }
    
    result.put("success", true);
    result.put("nextPageNo", nextPageNo);
    
} catch (Exception e) {
    System.err.println("Error in getNextPageNumber.jsp: " + e.getMessage());
    result.put("success", false);
    result.put("error", e.getMessage());
    result.put("nextPageNo", 1); // Default to 1 on error
    
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}

out.print(result.toString());
%>
