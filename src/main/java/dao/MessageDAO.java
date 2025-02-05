package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import bean.MessageBean;
import connector.MySQLConnector;

public class MessageDAO {

    public void addMessage(MessageBean messageBean) {
        String sql = "INSERT INTO MESSAGE (RELATION_ID, USER_ID, SEND_MESSAGE) VALUES (?, ?, ?)";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            // 現在の時刻を設定
            //Timestamp currentTime = new Timestamp(System.currentTimeMillis());
            //↑は日本時間じゃないことが分かったのでDBのDEFAULTを使う
            stmt.setInt(1, messageBean.getRelationId());  // relationIdはint型
            stmt.setString(2, messageBean.getUserId()); 
            stmt.setString(3, messageBean.getSendMessage());
            //stmt.setTimestamp(4, currentTime);  // 
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<MessageBean> getMessages(int relationId) {
        List<MessageBean> messages = new ArrayList<>();
        String sql = "SELECT * FROM MESSAGE WHERE RELATION_ID = ? ORDER BY SEND_TIME";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, relationId);  // relationIdはint型
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                MessageBean message = new MessageBean(
                        rs.getInt("MESSAGE_ID"),
                        rs.getInt("RELATION_ID"),
                        rs.getString("USER_ID"),
                        rs.getTimestamp("SEND_TIME"),
                        rs.getString("SEND_MESSAGE")
                );
                messages.add(message);  // メッセージをリストに追加
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return messages;
    }

    public void updateMessage(MessageBean messageBean) {
        String sql = "UPDATE MESSAGE SET SEND_MESSAGE = ? WHERE MESSAGE_ID = ?";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, messageBean.getSendMessage());
            stmt.setInt(2, messageBean.getMessageId());  // messageIdはint型
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void removeMessage(int messageId) {
        String sql = "DELETE FROM MESSAGE WHERE MESSAGE_ID = ?";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, messageId);  // messageIdはint型
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    public Map<String, String> getUserMap(int relationId) {
        Map<String, String> userMap = new HashMap<>();
        String sql = "SELECT u1.user_id AS user1_id, u1.user_name AS user1_name, " +
                     "       u2.user_id AS user2_id, u2.user_name AS user2_name " +
                     "FROM relation r " +
                     "JOIN users u1 ON r.user1_id = u1.user_id " +
                     "JOIN users u2 ON r.user2_id = u2.user_id " +
                     "WHERE r.relation_id = ?";

        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, relationId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                userMap.put(rs.getString("user1_id"), rs.getString("user1_name"));
                userMap.put(rs.getString("user2_id"), rs.getString("user2_name"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return userMap;
    }

}
