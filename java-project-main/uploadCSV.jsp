<%@ page import="java.sql.*, org.json.JSONObject, java.util.*, java.io.*" %>
<%@ page import="jakarta.servlet.*, jakarta.servlet.http.*" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

JSONObject result = new JSONObject();
Connection conn = null;
PreparedStatement pstmt = null;
Statement stmt = null;
ResultSet rs = null;
InputStream fileContent = null;

try {
    // 1. Check content type and log for debugging
    String contentType = request.getContentType();
    System.out.println("Content-Type: " + contentType);
    
    // 2. Parse parameters
    String pageId = request.getParameter("pageId");
    String spacecraftName = request.getParameter("spacecraftName");
    String subsystemName = request.getParameter("subsystemName");
    String csvData = request.getParameter("csvData");
    
    System.out.println("PageId: " + pageId);
    System.out.println("SpacecraftName: " + spacecraftName);
    System.out.println("SubsystemName: " + subsystemName);
    System.out.println("CSV Data length: " + (csvData != null ? csvData.length() : "null"));
    
    if (csvData == null || csvData.trim().isEmpty()) {
        response.setStatus(400);
        result.put("error", "No CSV data provided");
        out.print(result.toString());
        return;
    }

    // 3. Validate required parameters
    if (pageId == null || pageId.trim().isEmpty()) {
        response.setStatus(400);
        result.put("error", "Missing pageId parameter");
        out.print(result.toString());
        return;
    }
    
    if (spacecraftName == null || spacecraftName.trim().isEmpty()) {
        spacecraftName = "Unknown";
    }
    
    if (subsystemName == null || subsystemName.trim().isEmpty()) {
        subsystemName = "General";
    }

    // 4. Database setup
    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    System.out.println("Database path: " + dbPath);
    
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);
    conn.setAutoCommit(false);

    // 5. Get next PageNo (will be overridden by CSV data if available)
    int pageNo = 1;
    try {
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT MAX(PageNo) FROM Page_Info");
        if (rs.next() && !rs.wasNull()) {
            pageNo = rs.getInt(1) + 1;
        }
    } catch (SQLException e) {
        // Table might not exist yet, use default pageNo = 1
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ex) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ex) {}
    }

    // 6. Page_Info will be inserted for each row during CSV processing

    // 7. Process CSV data
    System.out.println("Processing CSV data...");
    System.out.println("CSV data length: " + csvData.length());
    System.out.println("CSV data preview: " + csvData.substring(0, Math.min(200, csvData.length())));
    
    String[] lines = csvData.split("\n");
    System.out.println("Number of lines: " + lines.length);
    
    if (lines.length == 0) {
        response.setStatus(400);
        result.put("error", "CSV data appears to be empty");
        out.print(result.toString());
        return;
    }
    
    String headerLine = lines[0];
    System.out.println("Header line: " + headerLine);
    
    String[] headers = headerLine.split(",");
    System.out.println("Number of headers: " + headers.length);
    
    for (int i = 0; i < headers.length; i++) {
        headers[i] = headers[i].trim().replaceAll("^\"|\"$", "");
        System.out.println("Header " + i + ": " + headers[i]);
    }
    
    // 8. Check if columns exist in Page_Data table, add them if they don't
    stmt = conn.createStatement();
    
    // First, get existing columns
    ResultSet rsColumns = conn.getMetaData().getColumns(null, null, "Page_Data", null);
    Set<String> existingColumns = new HashSet<>();
    while (rsColumns.next()) {
        existingColumns.add(rsColumns.getString("COLUMN_NAME"));
    }
    rsColumns.close();
    
    // Only add columns that don't exist
    for (String header : headers) {
        if (!existingColumns.contains(header)) {
            try {
                String alterSql = "ALTER TABLE Page_Data ADD COLUMN \"" + header + "\" TEXT";
                stmt.executeUpdate(alterSql);
                System.out.println("Added new column: " + header);
            } catch (SQLException e) {
                System.out.println("Error adding column " + header + ": " + e.getMessage());
            }
        } else {
            System.out.println("Column " + header + " already exists, skipping");
        }
    }
    stmt.close();
    
    // 9. Build dynamic SQL for Page_Data
    StringBuilder insertDataSql = new StringBuilder("INSERT OR REPLACE INTO Page_Data (PageID");
    for (String header : headers) {
        insertDataSql.append(", \"").append(header).append("\"");
    }
    insertDataSql.append(") VALUES (?");
    for (int i = 0; i < headers.length; i++) {
        insertDataSql.append(", ?");
    }
    insertDataSql.append(")");

    // 10. Process each data line
    int recordCount = 0;
    for (int lineIndex = 1; lineIndex < lines.length; lineIndex++) {
        String dataLine = lines[lineIndex].trim();
        if (dataLine.isEmpty()) continue;
        
        String[] values = dataLine.split(",");
        for (int i = 0; i < values.length; i++) {
            values[i] = values[i].trim().replaceAll("^\"|\"$", "");
        }
        
        if (values.length != headers.length) {
            System.out.println("Skipping malformed line: " + dataLine);
            continue;
        }
        
        // Find PageNo and RecordTitle from the data
        int csvPageNo = pageNo; // Default to auto-generated pageNo
        String recordTitle = "CSV Import";
        
        for (int i = 0; i < headers.length; i++) {
            if (headers[i].equalsIgnoreCase("PageNo") || headers[i].equalsIgnoreCase("Page No")) {
                try {
                    csvPageNo = Integer.parseInt(values[i]);
                } catch (NumberFormatException e) {
                    System.out.println("Invalid PageNo in CSV: " + values[i] + ", using default: " + pageNo);
                }
            } else if (headers[i].equalsIgnoreCase("RecordTitle") || headers[i].equalsIgnoreCase("Record Title")) {
                recordTitle = values[i];
            }
        }
        
        // Create unique pageId for this row
        String rowPageId = pageId + "_" + csvPageNo;
        
        // Insert into Page_Info for this row
        String insertInfoSql = "INSERT OR REPLACE INTO Page_Info (PageID, PageNo, SpacecraftName, SubsystemName, RecordTitle) VALUES (?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(insertInfoSql);
        pstmt.setString(1, rowPageId);
        pstmt.setInt(2, csvPageNo);
        pstmt.setString(3, spacecraftName);
        pstmt.setString(4, subsystemName);
        pstmt.setString(5, recordTitle);
        pstmt.executeUpdate();
        pstmt.close();
        
        // Insert into Page_Data for this row
        pstmt = conn.prepareStatement(insertDataSql.toString());
        pstmt.setString(1, rowPageId);
        
        for (int i = 0; i < values.length; i++) {
            pstmt.setString(i + 2, values[i]);
        }
        
        pstmt.executeUpdate();
        pstmt.close();
        recordCount++;
    }

    conn.commit();
    
    // 11. Success response
    result.put("status", "success");
    result.put("success", true);
    result.put("pageId", pageId);
    result.put("pageNo", pageNo);
    result.put("fileName", "uploaded_data.csv");
    result.put("recordsProcessed", recordCount);
    result.put("message", "Successfully processed " + recordCount + " records from CSV");
    
    response.setStatus(200);

} catch (Exception e) {
    if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
    response.setStatus(500);
    result.put("status", "error");
    result.put("message", "Error processing CSV data: " + e.getMessage());
    result.put("error", e.getMessage());
    result.put("stackTrace", e.getStackTrace().toString());
    System.err.println("CSV Upload Error: " + e.getMessage());
    e.printStackTrace();
} finally {
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
    out.print(result.toString());
}
%> 