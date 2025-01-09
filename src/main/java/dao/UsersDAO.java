package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import connector.MySQLConnector;

public class UsersDAO {

    // INSERT または UPDATE を行う SQL
    private static final String INSERT_OR_UPDATE_USER_SQL = 
        "INSERT INTO users (user_id, access_token, refresh_token, expires_in) " +
        "VALUES (?, ?, ?, ?) " +
        "ON DUPLICATE KEY UPDATE " +
        "access_token = VALUES(access_token), " +
        "refresh_token = VALUES(refresh_token), " +
        "expires_in = VALUES(expires_in)";

    // ユーザー情報をデータベースに保存または更新するメソッド
    public void saveUser(String userId, String accessToken, String refreshToken, int expiresIn) throws SQLException {
        try (Connection connection = MySQLConnector.getConn();
             PreparedStatement ps = connection.prepareStatement(INSERT_OR_UPDATE_USER_SQL)) {
            
            ps.setString(1, userId);
            ps.setString(2, accessToken);
            ps.setString(3, refreshToken); // refreshTokenがない場合はnullを渡す
            ps.setInt(4, expiresIn);
            
            ps.executeUpdate(); // SQL文を実行してデータを挿入または更新
        } catch (SQLException e) {
            e.printStackTrace();
            throw new SQLException("データベースエラーが発生しました。");
        }
    }
}
