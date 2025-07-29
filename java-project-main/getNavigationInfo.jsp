<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

JSONObject result = new JSONObject();
String currentPageNo = request.getParameter("currentPageNo");
String direction = request.getParameter("direction"); // "first", "prev", "next", "last", "goto"

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);
    
    JSONObject navigationInfo = new JSONObject();
    
    if ("first".equals(direction)) {
        // Get first page
        pstmt = conn.prepareStatement("SELECT PageNo, PageID FROM Page_Info ORDER BY PageNo ASC LIMIT 1");
        rs = pstmt.executeQuery();
        if (rs.next()) {
            navigationInfo.put("pageNo", rs.getInt("PageNo"));
            navigationInfo.put("pageId", rs.getString("PageID"));
            navigationInfo.put("action", "first");
        }
        
    } else if ("prev".equals(direction)) {
        // Get previous page
        pstmt = conn.prepareStatement("SELECT PageNo, PageID FROM Page_Info WHERE PageNo < ? ORDER BY PageNo DESC LIMIT 1");
        pstmt.setInt(1, Integer.parseInt(currentPageNo));
        rs = pstmt.executeQuery();
        if (rs.next()) {
            navigationInfo.put("pageNo", rs.getInt("PageNo"));
            navigationInfo.put("pageId", rs.getString("PageID"));
            navigationInfo.put("action", "prev");
        }
        
    } else if ("next".equals(direction)) {
        // Get next page
        pstmt = conn.prepareStatement("SELECT PageNo, PageID FROM Page_Info WHERE PageNo > ? ORDER BY PageNo ASC LIMIT 1");
        pstmt.setInt(1, Integer.parseInt(currentPageNo));
        rs = pstmt.executeQuery();
        if (rs.next()) {
            navigationInfo.put("pageNo", rs.getInt("PageNo"));
            navigationInfo.put("pageId", rs.getString("PageID"));
            navigationInfo.put("action", "next");
        }
        
    } else if ("last".equals(direction)) {
        // Get last page
        pstmt = conn.prepareStatement("SELECT PageNo, PageID FROM Page_Info ORDER BY PageNo DESC LIMIT 1");
        rs = pstmt.executeQuery();
        if (rs.next()) {
            navigationInfo.put("pageNo", rs.getInt("PageNo"));
            navigationInfo.put("pageId", rs.getString("PageID"));
            navigationInfo.put("action", "last");
        }
        
    } else if ("goto".equals(direction)) {
        // Go to specific page
        pstmt = conn.prepareStatement("SELECT PageNo, PageID FROM Page_Info WHERE PageNo = ?");
        pstmt.setInt(1, Integer.parseInt(currentPageNo));
        rs = pstmt.executeQuery();
        if (rs.next()) {
            navigationInfo.put("pageNo", rs.getInt("PageNo"));
            navigationInfo.put("pageId", rs.getString("PageID"));
            navigationInfo.put("action", "goto");
        }
    }
    
    // Get total count and current position
    pstmt = conn.prepareStatement("SELECT COUNT(*) as total FROM Page_Info");
    rs = pstmt.executeQuery();
    int totalPages = 0;
    if (rs.next()) {
        totalPages = rs.getInt("total");
    }
    
    // Get current position if currentPageNo is provided
    int currentPosition = 0;
    if (currentPageNo != null && !currentPageNo.isEmpty()) {
        pstmt = conn.prepareStatement("SELECT COUNT(*) as position FROM Page_Info WHERE PageNo <= ?");
        pstmt.setInt(1, Integer.parseInt(currentPageNo));
        rs = pstmt.executeQuery();
        if (rs.next()) {
            currentPosition = rs.getInt("position");
        }
    }
    
    // Check if previous/next are available
    boolean hasPrevious = false;
    boolean hasNext = false;
    
    if (currentPageNo != null && !currentPageNo.isEmpty()) {
        // Check for previous
        pstmt = conn.prepareStatement("SELECT COUNT(*) as count FROM Page_Info WHERE PageNo < ?");
        pstmt.setInt(1, Integer.parseInt(currentPageNo));
        rs = pstmt.executeQuery();
        if (rs.next()) {
            hasPrevious = rs.getInt("count") > 0;
        }
        
        // Check for next
        pstmt = conn.prepareStatement("SELECT COUNT(*) as count FROM Page_Info WHERE PageNo > ?");
        pstmt.setInt(1, Integer.parseInt(currentPageNo));
        rs = pstmt.executeQuery();
        if (rs.next()) {
            hasNext = rs.getInt("count") > 0;
        }
    }
    
    result.put("success", true);
    result.put("navigationInfo", navigationInfo);
    result.put("totalPages", totalPages);
    result.put("currentPosition", currentPosition);
    result.put("hasPrevious", hasPrevious);
    result.put("hasNext", hasNext);
    
} catch (Exception e) {
    result.put("success", false);
    result.put("error", "Navigation error: " + e.getMessage());
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
    out.print(result.toString());
}
%> 