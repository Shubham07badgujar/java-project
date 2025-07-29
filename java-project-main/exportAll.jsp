<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%
response.setContentType("text/csv");
response.setHeader("Content-Disposition", "attachment; filename=\"all_spacecraft_data.csv\"");
response.setCharacterEncoding("UTF-8");

Connection conn = null;
Statement stmt = null;
ResultSet rs = null;

try {
    // Database setup
    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);
    
    // Get all column names from Page_Data table
    stmt = conn.createStatement();
    rs = conn.getMetaData().getColumns(null, null, "Page_Data", null);
    
    StringBuilder csvContent = new StringBuilder();
    StringBuilder headerRow = new StringBuilder();
    
    // Start with basic columns (all required fields)
    headerRow.append("RecordTitle,PageNo,SpacecraftName,SubsystemName,PageID");
    
    // Add all dynamic columns from Page_Data
    while (rs.next()) {
        String columnName = rs.getString("COLUMN_NAME");
        if (!columnName.equals("PageID")) { // Skip PageID as it's used for joining
            headerRow.append(",").append(columnName);
        }
    }
    rs.close();
    
    csvContent.append(headerRow.toString()).append("\n");
    
    // Query to get all data joined between Page_Info and Page_Data
    String query = "SELECT pi.RecordTitle, pi.PageNo, pi.SpacecraftName, pi.SubsystemName, pi.PageID, pd.* " +
                   "FROM Page_Info pi " +
                   "LEFT JOIN Page_Data pd ON pi.PageID = pd.PageID " +
                   "ORDER BY pi.PageNo";
    
    rs = stmt.executeQuery(query);
    
    while (rs.next()) {
        StringBuilder dataRow = new StringBuilder();
        
        // Add basic fields (all required fields)
        dataRow.append(escapeCsvValue(rs.getString("RecordTitle"))).append(",");
        dataRow.append(rs.getInt("PageNo")).append(",");
        dataRow.append(escapeCsvValue(rs.getString("SpacecraftName"))).append(",");
        dataRow.append(escapeCsvValue(rs.getString("SubsystemName"))).append(",");
        dataRow.append(escapeCsvValue(rs.getString("PageID")));
        
        // Add all dynamic columns
        ResultSetMetaData metaData = rs.getMetaData();
        for (int i = 6; i <= metaData.getColumnCount(); i++) { // Start from 6 to skip PageID from Page_Data
            String value = rs.getString(i);
            dataRow.append(",").append(escapeCsvValue(value));
        }
        
        csvContent.append(dataRow.toString()).append("\n");
    }
    
    out.print(csvContent.toString());
    
} catch (Exception e) {
    response.setContentType("application/json");
    response.setStatus(500);
    out.print("{\"error\": \"Error exporting data: " + e.getMessage() + "\"}");
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}

// Helper function to escape CSV values
private String escapeCsvValue(String value) {
    if (value == null) return "";
    
    // If value contains comma, quote, or newline, wrap in quotes and escape internal quotes
    if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
        return "\"" + value.replace("\"", "\"\"") + "\"";
    }
    
    return value;
}
%> 