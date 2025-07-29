<%@ page import="java.sql.*" %>
<%
    response.setContentType("text/plain");
    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    int count = 0;
    try {
        Class.forName("org.sqlite.JDBC");
        conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT COUNT(*) FROM Page_Info");
        if (rs.next()) {
            count = rs.getInt(1);
        }
    } catch (Exception e) {
        count = 0;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ex) {}
        if (stmt != null) try { stmt.close(); } catch (Exception ex) {}
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
    out.print(count);
%> 