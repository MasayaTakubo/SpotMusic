package connector;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class MySQLConnector {
    static {
        try {
            // JDBCドライバのクラスを手動でロード
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConn() {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/spotmusic?useSSL=false&serverTimezone=Asia/Tokyo&useUnicode=true&characterEncoding=UTF-8", 
                    "info", "pro");
            // AWS RDSのエンドポイント（画像から取得）　下記はAWS用
            //String url = "jdbc:mysql://aws-mysql.cfvaqwoyhysi.us-east-1.rds.amazonaws.com:3306/admin"
                       //+ "?useSSL=false&serverTimezone=Asia/Tokyo&useUnicode=true&characterEncoding=UTF-8";
            //String user = "";  // RDSのユーザー名　使う時入れる
            //String password = ""; // RDSのパスワード 使う時入れる

            //conn = DriverManager.getConnection(url, user, password);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return conn;
    }

    public static void close(ResultSet resultSet, Statement statement, Connection conn) {
        if (resultSet != null) {
            try {
                resultSet.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (statement != null) {
            try {
                statement.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
