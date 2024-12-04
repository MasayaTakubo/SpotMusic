package connector;
import java.sql.ResultSet;
import java.sql.Statement;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class MySQLConnector {
    public static Connection getConn() {
        Connection conn = null;
        try{
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/world?characterEncoding=UTF-8&serverTimezone=JST",
                "info","pro");
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