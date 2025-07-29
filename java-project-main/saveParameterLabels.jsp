<%@ page import="java.sql.*, org.json.JSONObject, java.util.*" %>
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
Statement createStmt = null;

try {
    String dbPath = getServletContext().getRealPath("/spacecraft.db");
    System.out.println("saveParameterLabels.jsp - Database path: " + dbPath);
    System.out.println("saveParameterLabels.jsp - PageID: " + pageId);
    
    Class.forName("org.sqlite.JDBC");
    
    // Use simple connection without WAL mode to avoid locks
    String dbUrl = "jdbc:sqlite:" + dbPath;
    conn = DriverManager.getConnection(dbUrl);
    // Don't use transactions to avoid locks
    
    // Set SQLite-specific settings for better reliability
    Statement pragmaStmt = conn.createStatement();
    pragmaStmt.executeUpdate("PRAGMA busy_timeout = 10000");
    pragmaStmt.executeUpdate("PRAGMA journal_mode = DELETE"); // Use DELETE mode instead of WAL
    pragmaStmt.executeUpdate("PRAGMA synchronous = NORMAL");
    pragmaStmt.close();

    // Ensure Parameter_Labels table exists with correct structure
    createStmt = conn.createStatement();
    
    // Check if table exists
    ResultSet tableCheck = createStmt.executeQuery(
        "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table' AND name='Parameter_Labels'");
    tableCheck.next();
    boolean tableExists = tableCheck.getInt("count") > 0;
    tableCheck.close();
    
    if (!tableExists) {
        // Create table if it doesn't exist
        createStmt.executeUpdate("CREATE TABLE Parameter_Labels (" +
            "PageID TEXT NOT NULL, " +
            "ParameterIndex INTEGER NOT NULL, " +
            "CustomLabel TEXT NOT NULL, " +
            "PRIMARY KEY (PageID, ParameterIndex))");
        System.out.println("Created Parameter_Labels table");
    } else {
        System.out.println("Parameter_Labels table already exists");
    }
    createStmt.close();

    // Delete existing labels for this PageID
    stmt = conn.prepareStatement("DELETE FROM Parameter_Labels WHERE PageID = ?");
    stmt.setString(1, pageId);
    stmt.executeUpdate();
    stmt.close();

    // Insert new labels
    stmt = conn.prepareStatement("INSERT INTO Parameter_Labels (PageID, ParameterIndex, CustomLabel) VALUES (?, ?, ?)");
    
    int savedCount = 0;
    for (int i = 1; i <= 38; i++) {
        String labelParam = "paramLabel" + i;
        String customLabel = request.getParameter(labelParam);
        
        if (customLabel != null && !customLabel.trim().isEmpty()) {
            stmt.setString(1, pageId);
            stmt.setInt(2, i);
            stmt.setString(3, customLabel.trim());
            stmt.executeUpdate();
            savedCount++;
        }
    }

    // No commit needed since we're not using transactions
    result.put("success", true);
    result.put("savedLabels", savedCount);
    result.put("pageId", pageId);

} catch (Exception e) {
    System.err.println("Error in saveParameterLabels.jsp:");
    System.err.println("PageID: " + pageId);
    System.err.println("Error message: " + e.getMessage());
    e.printStackTrace();
    
    response.setStatus(500);
    result.put("error", "Database error: " + e.getMessage());
    result.put("pageId", pageId);
    result.put("details", e.getClass().getSimpleName());

} finally {
    // Ensure all resources are properly closed
    if (stmt != null) {
        try { 
            stmt.close(); 
        } catch (SQLException e) { 
            System.err.println("Error closing PreparedStatement: " + e.getMessage());
        }
    }
    if (createStmt != null) {
        try { 
            createStmt.close(); 
        } catch (SQLException e) { 
            System.err.println("Error closing Statement: " + e.getMessage());
        }
    }
    if (conn != null) {
        try { 
            conn.close(); 
            System.out.println("Database connection closed successfully");
        } catch (SQLException e) { 
            System.err.println("Error closing Connection: " + e.getMessage());
        }
    }
}

out.print(result.toString());
%>
