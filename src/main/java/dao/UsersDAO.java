package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import bean.usersBean;
import connector.MySQLConnector;

public class UsersDAO {

    // INSERT または UPDATE を行う SQL
    private static final String INSERT_OR_UPDATE_USER_SQL = 
		"INSERT INTO users (user_id, access_token, refresh_token, expires_in, user_name) " +
				"VALUES (?, ?, ?, ?, ?) " +
				"ON DUPLICATE KEY UPDATE " +
				"access_token = VALUES(access_token), " +
				"refresh_token = VALUES(refresh_token), " +
				"expires_in = VALUES(expires_in), " +
				"user_name = VALUES(user_name)";


    // ユーザー情報をデータベースに保存または更新するメソッド
    public void saveUser(String userId, String accessToken, String refreshToken, int expiresIn, String userName) throws SQLException {
        try (Connection connection = MySQLConnector.getConn();
             PreparedStatement ps = connection.prepareStatement(INSERT_OR_UPDATE_USER_SQL)) {
            
            ps.setString(1, userId);
            ps.setString(2, accessToken);
            ps.setString(3, refreshToken); // refreshTokenがない場合はnullを渡す
            ps.setInt(4, expiresIn);
            ps.setString(5, userName);
            
            ps.executeUpdate(); // SQL文を実行してデータを挿入または更新
        } catch (SQLException e) {
            e.printStackTrace();
            throw new SQLException("データベースエラーが発生しました。");
        }
    }
    public List<usersBean> getUsersData() {
        String sql = "SELECT user_id,user_name FROM users";
        List<usersBean> users = new ArrayList<>();
        usersBean user = null;
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
            	user = new usersBean();
                user.setUserId(rs.getString("user_id"));
                user.setUserName(rs.getString("user_name"));
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return users;  // ユーザーIDのリストを返す
    }
}
