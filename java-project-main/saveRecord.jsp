<%@ page import="java.sql.*, org.json.JSONObject, java.util.*, java.io.*" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

JSONObject result = new JSONObject();

// Debug: Log all received parameters
System.out.println("=== saveRecord.jsp Debug ===");
Enumeration<String> allParams = request.getParameterNames();
while (allParams.hasMoreElements()) {
    String paramName = allParams.nextElement();
    String paramValue = request.getParameter(paramName);
    System.out.println("Parameter: " + paramName + " = " + paramValue);
}
System.out.println("=== End Debug ===");

String pageId = request.getParameter("pageId");
String spacecraftName = request.getParameter("spacecraftName");
String subsystemName = request.getParameter("subsystemName");
String pageNoStr = request.getParameter("pageNo");
String recordTitle = request.getParameter("recordTitle");

    // Validate required fields
    if (pageId == null || spacecraftName == null || subsystemName == null || recordTitle == null ||
        pageId.trim().isEmpty() || spacecraftName.trim().isEmpty() || subsystemName.trim().isEmpty() || recordTitle.trim().isEmpty()) {
        response.setStatus(400);
        StringBuilder missingParams = new StringBuilder("Missing or empty required parameters: ");
        if (pageId == null || pageId.trim().isEmpty()) missingParams.append("pageId ");
        if (spacecraftName == null || spacecraftName.trim().isEmpty()) missingParams.append("spacecraftName ");
        if (subsystemName == null || subsystemName.trim().isEmpty()) missingParams.append("subsystemName ");
        if (recordTitle == null || recordTitle.trim().isEmpty()) missingParams.append("recordTitle ");
        result.put("error", missingParams.toString());
        out.print(result.toString());
        return;
    }
    
    // Validate page number
    if (pageNoStr == null || pageNoStr.trim().isEmpty()) {
        response.setStatus(400);
        result.put("error", "Page number is required");
        out.print(result.toString());
        return;
    }

// Validate page number
int pageNo = 1;
if (pageNoStr != null && !pageNoStr.trim().isEmpty()) {
    try {
        pageNo = Integer.parseInt(pageNoStr.trim());
        if (pageNo < 1) {
            response.setStatus(400);
            result.put("error", "Page number must be a positive integer");
            out.print(result.toString());
            return;
        }
    } catch (NumberFormatException e) {
        response.setStatus(400);
        result.put("error", "Invalid page number format");
        out.print(result.toString());
        return;
    }
}

Connection conn = null;
PreparedStatement checkStmt = null;
PreparedStatement updateInfo = null;
PreparedStatement insertInfo = null;
PreparedStatement dataStmt = null;
Statement stmt = null;
ResultSet rs = null;

try {
    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);
    conn.setAutoCommit(false);

    // Ensure Page_Data table exists
    stmt = conn.createStatement();
    try {
        stmt.executeQuery("SELECT 1 FROM Page_Data LIMIT 1");
    } catch (SQLException e) {
        // Table doesn't exist, create it
        stmt.executeUpdate("CREATE TABLE IF NOT EXISTS Page_Data (PageID TEXT PRIMARY KEY)");
    }
    stmt.close();

    // Check if record exists and if page number is already taken
    boolean recordExists = false;
    boolean pageNoExists = false;
    
    // Check if the page number is already taken by another record
    checkStmt = conn.prepareStatement("SELECT PageID FROM Page_Info WHERE PageNo = ? AND PageID != ?");
    checkStmt.setInt(1, pageNo);
    checkStmt.setString(2, pageId);
    ResultSet checkRs = checkStmt.executeQuery();
    if (checkRs.next()) {
        pageNoExists = true;
    }
    checkRs.close();
    checkStmt.close();
    
    if (pageNoExists) {
        response.setStatus(400);
        result.put("error", "Page number " + pageNo + " is already taken by another record");
        out.print(result.toString());
        return;
    }
    
    // Check if current record exists
    checkStmt = conn.prepareStatement("SELECT PageNo FROM Page_Info WHERE PageID = ?");
    checkStmt.setString(1, pageId);
    checkRs = checkStmt.executeQuery();
    if (checkRs.next()) {
        recordExists = true;
    }
    checkRs.close();
    checkStmt.close();

    
    if (recordExists) {
        // Update existing record
        updateInfo = conn.prepareStatement(
            "UPDATE Page_Info SET PageNo = ?, SpacecraftName = ?, SubsystemName = ?, RecordTitle = ? WHERE PageID = ?");
        updateInfo.setInt(1, pageNo);
        updateInfo.setString(2, spacecraftName);
        updateInfo.setString(3, subsystemName);
        updateInfo.setString(4, recordTitle);
        updateInfo.setString(5, pageId);
        updateInfo.executeUpdate();
        updateInfo.close();
    } else {
        // Insert new record
        insertInfo = conn.prepareStatement(
            "INSERT INTO Page_Info (PageID, PageNo, SpacecraftName, SubsystemName, RecordTitle) VALUES (?, ?, ?, ?, ?)");
        insertInfo.setString(1, pageId);
        insertInfo.setInt(2, pageNo);
        insertInfo.setString(3, spacecraftName);
        insertInfo.setString(4, subsystemName);
        insertInfo.setString(5, recordTitle);
        insertInfo.executeUpdate();
        insertInfo.close();
    }

    // Handle Page_Data
    Enumeration<String> params = request.getParameterNames();
    List<String> paramNames = new ArrayList<>();
    List<String> paramValues = new ArrayList<>();

    while (params.hasMoreElements()) {
        String param = params.nextElement();
        if (!param.equals("pageId") && !param.equals("spacecraftName") && !param.equals("subsystemName") && 
            !param.equals("pageNo") && !param.equals("recordTitle")) {
            
            // Use the parameter name as-is since it should be the actual column name
            String actualParamName = param;
            
            // Skip empty parameter names
            if (actualParamName != null && !actualParamName.trim().isEmpty()) {
                paramNames.add(actualParamName);
                paramValues.add(request.getParameter(param));
            }
        }
    }

    System.out.println("Processing Page_Data with " + paramNames.size() + " parameters");
    System.out.println("Parameter names: " + paramNames);
    
    // Ensure all parameter columns exist in Page_Data table
    if (!paramNames.isEmpty()) {
        stmt = conn.createStatement();
        for (String paramName : paramNames) {
            try {
                // Check if column exists first
                stmt.executeQuery("SELECT \"" + paramName + "\" FROM Page_Data LIMIT 1");
                System.out.println("Column " + paramName + " already exists");
            } catch (SQLException e) {
                // Column doesn't exist, add it
                try {
                    stmt.executeUpdate("ALTER TABLE Page_Data ADD COLUMN \"" + paramName + "\" TEXT");
                    System.out.println("Added column: " + paramName);
                } catch (SQLException addEx) {
                    System.out.println("Failed to add column " + paramName + ": " + addEx.getMessage());
                }
            }
        }
        stmt.close();
    }
    
    // Ensure Page_Data record exists for this PageID
    stmt = conn.createStatement();
    try {
        stmt.executeQuery("SELECT PageID FROM Page_Data WHERE PageID = '" + pageId + "'");
        System.out.println("Page_Data record already exists for " + pageId);
    } catch (SQLException e) {
        // Page_Data record doesn't exist, create it
        stmt.executeUpdate("INSERT INTO Page_Data (PageID) VALUES ('" + pageId + "')");
        System.out.println("Created Page_Data record for " + pageId);
    }
    stmt.close();
    
    if (!paramNames.isEmpty()) {
        if (recordExists) {
            // Build UPDATE statement
            StringBuilder updateDataSql = new StringBuilder("UPDATE Page_Data SET ");
            for (String param : paramNames) {
                updateDataSql.append("\"").append(param).append("\" = ?, ");
            }
            updateDataSql.setLength(updateDataSql.length() - 2); // Remove last comma
            updateDataSql.append(" WHERE PageID = ?");
            
            System.out.println("UPDATE SQL: " + updateDataSql.toString());
            dataStmt = conn.prepareStatement(updateDataSql.toString());

            int paramIndex = 1;
            for (String value : paramValues) {
                dataStmt.setString(paramIndex++, value);
            }
            dataStmt.setString(paramIndex, pageId);
            dataStmt.executeUpdate();

        } else {
            // Build INSERT statement
            StringBuilder insertDataSql = new StringBuilder("INSERT INTO Page_Data (PageID");
            for (String param : paramNames) {
                insertDataSql.append(", \"").append(param).append("\"");
            }
            insertDataSql.append(") VALUES (?"); // PageID
            for (int i = 0; i < paramNames.size(); i++) {
                insertDataSql.append(", ?");
            }
            insertDataSql.append(")");
            
            System.out.println("INSERT SQL: " + insertDataSql.toString());
            dataStmt = conn.prepareStatement(insertDataSql.toString());

            int paramIndex = 1;
            dataStmt.setString(paramIndex++, pageId);
            for (String value : paramValues) {
                dataStmt.setString(paramIndex++, value);
            }
            dataStmt.executeUpdate();
        }
    } else {
        System.out.println("No additional parameters to insert/update in Page_Data.");
    }

    conn.commit();
    result.put("success", true);
    result.put("pageId", pageId);
    result.put("pageNo", pageNo);
    out.print(result.toString());

} catch (SQLException e) {
    e.printStackTrace(); // for debugging
    if (conn != null) {
        try { conn.rollback(); } catch (SQLException rollbackEx) {}
    }
    response.setStatus(500);
    result.put("error", "Database error: " + e.getMessage());
    out.print(result.toString());

} catch (Exception e) {
    e.printStackTrace(); // for debugging
    if (conn != null) {
        try { conn.rollback(); } catch (SQLException rollbackEx) {}
    }
    response.setStatus(500);
    result.put("error", "Server error: " + e.getMessage());
    out.print(result.toString());

} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
    if (checkStmt != null) try { checkStmt.close(); } catch (SQLException e) {}
    if (updateInfo != null) try { updateInfo.close(); } catch (SQLException e) {}
    if (insertInfo != null) try { insertInfo.close(); } catch (SQLException e) {}
    if (dataStmt != null) try { dataStmt.close(); } catch (SQLException e) {}
    if (conn != null) {
        try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) {}
    }
}
%> 