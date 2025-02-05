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
        try{
            // 接続URLに文字エンコーディングの設定を追加
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/spotmusic?useSSL=false&serverTimezone=Asia/Tokyo&useUnicode=true&characterEncoding=UTF-8", 
                "info", "pro");
        }catch(SQLException e){
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