<%@ page import="java.sql.*, org.json.JSONObject, java.util.*, java.io.*" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

JSONObject result = new JSONObject();
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    String pageId = request.getParameter("pageId");
    String action = request.getParameter("action");
    String spacecraftName = request.getParameter("spacecraftName");
    String subsystemName = request.getParameter("subsystemName");
    
    if (pageId == null || !"updateCSV".equals(action)) {
        response.setStatus(400);
        result.put("error", "Invalid parameters");
        out.print(result.toString());
        return;
    }
    
    // Database setup
    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);
    
    // Get all parameter names for the CSV header
    String[] parameterNames = {
        "", // Index 0 unused
        "Spacecraft Name", "Mission ID", "Launch Date", "Orbit Type",
        "Payload Capacity", "Fuel Capacity", "Max Thrust", "Engine Type",
        "Communication Band", "Power Output", "Solar Array Size",
        "Battery Capacity", "Attitude Control", "Navigation System",
        "Thermal Control", "Structural Material", "Dry Mass", "Wet Mass",
        "Dimensions", "Operational Lifetime", "Data Rate", "Onboard Storage",
        "Redundancy Level", "Failure Rate", "Reliability", "Radiation Tolerance",
        "Temperature Range", "Software Version", "Firmware Version",
        "Autonomy Level", "Mission Objectives", "Scientific Instruments",
        "Propulsion System", "Delta-V Capacity", "Communication Delay",
        "Ground Stations", "Mission Cost", "Development Time"
    };
    
    // Build CSV content
    StringBuilder csvContent = new StringBuilder();
    
    // Add header
    csvContent.append("Spacecraft Name,Subsystem Name");
    for (int i = 1; i <= 38; i++) {
        csvContent.append(",").append(parameterNames[i]);
    }
    csvContent.append("\n");
    
    // Add data row
    csvContent.append(escapeCsvValue(spacecraftName != null ? spacecraftName : ""));
    csvContent.append(",").append(escapeCsvValue(subsystemName != null ? subsystemName : ""));
    
    for (int i = 1; i <= 38; i++) {
        String paramValue = request.getParameter(parameterNames[i]);
        csvContent.append(",").append(escapeCsvValue(paramValue != null ? paramValue : ""));
    }
    csvContent.append("\n");
    
    // Save CSV file
    String csvFileName = (spacecraftName != null ? spacecraftName.replaceAll("[^a-zA-Z0-9]", "_") : "spacecraft") + "_parameters.csv";
    String csvFilePath = getServletContext().getRealPath("/") + csvFileName;
    
    try (FileWriter writer = new FileWriter(csvFilePath)) {
        writer.write(csvContent.toString());
    }
    
    // Also update the database
    // First update Page_Info
    pstmt = conn.prepareStatement("UPDATE Page_Info SET SpacecraftName = ?, SubsystemName = ? WHERE PageID = ?");
    pstmt.setString(1, spacecraftName);
    pstmt.setString(2, subsystemName);
    pstmt.setString(3, pageId);
    pstmt.executeUpdate();
    pstmt.close();
    
    // Update Page_Data
    StringBuilder updateSql = new StringBuilder("UPDATE Page_Data SET ");
    List<String> setClauses = new ArrayList<>();
    List<String> values = new ArrayList<>();
    
    for (int i = 1; i <= 38; i++) {
        String paramValue = request.getParameter(parameterNames[i]);
        if (paramValue != null) {
            setClauses.add("\"" + parameterNames[i] + "\" = ?");
            values.add(paramValue);
        }
    }
    
    if (!setClauses.isEmpty()) {
        updateSql.append(String.join(", ", setClauses));
        updateSql.append(" WHERE PageID = ?");
        
        pstmt = conn.prepareStatement(updateSql.toString());
        for (int i = 0; i < values.size(); i++) {
            pstmt.setString(i + 1, values.get(i));
        }
        pstmt.setString(values.size() + 1, pageId);
        pstmt.executeUpdate();
    }
    
    result.put("success", true);
    result.put("csvFile", csvFileName);
    result.put("message", "CSV file updated successfully");
    
} catch (Exception e) {
    response.setStatus(500);
    result.put("error", "Error updating CSV: " + e.getMessage());
    e.printStackTrace();
} finally {
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
    out.print(result.toString());
}
%>

<%!
// Helper method to escape CSV values
private String escapeCsvValue(String value) {
    if (value == null) return "";
    
    // If value contains comma, quote, or newline, wrap in quotes and escape quotes
    if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
        return "\"" + value.replace("\"", "\"\"") + "\"";
    }
    return value;
}
%>
