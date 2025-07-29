import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseHelper {

    public static Connection getConnection(String webappPath) throws SQLException, ClassNotFoundException {
        String dbPath = webappPath + "spacecraft.db";

        File dbFile = new File(dbPath);
        if (!dbFile.exists()) {
            // Try alternative locations
            String[] alternatePaths = {
                    webappPath + "../spacecraft.db",
                    webappPath + "spacecraft.db",
                    System.getProperty("user.dir") + "/spacecraft.db"
            };

            for (String altPath : alternatePaths) {
                dbFile = new File(altPath);
                if (dbFile.exists()) {
                    dbPath = altPath;
                    break;
                }
            }
        }

        System.out.println("Using database path: " + dbPath);

        Class.forName("org.sqlite.JDBC");
        return DriverManager.getConnection("jdbc:sqlite:" + dbPath);
    }
}
