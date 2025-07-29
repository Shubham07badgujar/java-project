<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONObject" %>
<%
    response.setContentType("application/json");
    String pageId = request.getParameter("pageId");
    JSONObject record = new JSONObject();

    if (pageId == null || pageId.trim().isEmpty()) {
        record.put("error", "No PageID provided");
        out.print(record.toString());
        return;
    }

    String dbPath = getServletContext().getRealPath("/") + "spacecraft.db";
    
    Connection conn = null;
    PreparedStatement pstmtInfo = null;
    PreparedStatement pstmtData = null;
    ResultSet rsInfo = null;
    ResultSet rsData = null;

    try {
        Class.forName("org.sqlite.JDBC");
        conn = DriverManager.getConnection("jdbc:sqlite:" + dbPath);

        // Get page info
        String sqlInfo = "SELECT * FROM Page_Info WHERE PageID = ?";
        pstmtInfo = conn.prepareStatement(sqlInfo);
        pstmtInfo.setString(1, pageId);
        rsInfo = pstmtInfo.executeQuery();

        if (!rsInfo.next()) {
            record.put("error", "Record not found");
            out.print(record.toString());
            return;
        }

        record.put("pageId", rsInfo.getString("PageID"));
        record.put("pageNo", rsInfo.getInt("PageNo"));
        record.put("spacecraftName", rsInfo.getString("SpacecraftName"));
        record.put("subsystemName", rsInfo.getString("SubsystemName"));
        record.put("recordTitle", rsInfo.getString("RecordTitle"));

        // Get page data
        String sqlData = "SELECT * FROM Page_Data WHERE PageID = ?";
        pstmtData = conn.prepareStatement(sqlData);
        pstmtData.setString(1, pageId);
        rsData = pstmtData.executeQuery();

        if (rsData.next()) {
            ResultSetMetaData meta = rsData.getMetaData();
            int columnCount = meta.getColumnCount();

            for (int i = 1; i <= columnCount; i++) {
                String columnName = meta.getColumnName(i);
                record.put(columnName, rsData.getString(i));
            }
        }
    } catch (Exception e) {
        record.put("error", "Database error: " + e.getMessage());
    } finally {
        if (rsInfo != null) try { rsInfo.close(); } catch (Exception ex) {}
        if (rsData != null) try { rsData.close(); } catch (Exception ex) {}
        if (pstmtInfo != null) try { pstmtInfo.close(); } catch (Exception ex) {}
        if (pstmtData != null) try { pstmtData.close(); } catch (Exception ex) {}
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }

    out.print(record.toString());
%> 