package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import bean.MessageBean;

public class MessageDAO {
    private static final String INSERT_MESSAGE_SQL = 
        "INSERT INTO MESSAGE (RELATION_ID, USER_ID, SEND_MESSAGE) VALUES (?, ?, ?)";
    private static final String SELECT_MESSAGES_SQL = 
        "SELECT * FROM MESSAGE WHERE RELATION_ID = ? AND USER_ID = ?";
    private static final String UPDATE_MESSAGE_SQL = 
        "UPDATE MESSAGE SET SEND_MESSAGE = ? WHERE MESSAGE_ID = ?";
    private static final String DELETE_MESSAGE_SQL = 
        "DELETE FROM MESSAGE WHERE MESSAGE_ID = ?";

    public void addMessage(MessageBean message) throws SQLException {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(INSERT_MESSAGE_SQL)) {
            ps.setInt(1, message.getRelationId());
            ps.setString(2, message.getUserId());
            ps.setString(3, message.getSendMessage());
            ps.executeUpdate();
        }
    }
    public List<MessageBean> getMessages(MessageBean filter) throws SQLException {
        List<MessageBean> messages = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_MESSAGES_SQL)) {
            ps.setInt(1, filter.getRelationId());
            ps.setString(2, filter.getUserId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MessageBean message = new MessageBean();
                    message.setMessageId(rs.getInt("MESSAGE_ID"));
                    message.setRelationId(rs.getInt("RELATION_ID"));
                    message.setUserId(rs.getString("USER_ID"));
                    message.setSendTime(rs.getTimestamp("SEND_TIME"));
                    message.setSendMessage(rs.getString("SEND_MESSAGE"));
                    messages.add(message);
                }
            }
        }
        return messages;
    }
    public void updateMessage(MessageBean message) throws SQLException {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(UPDATE_MESSAGE_SQL)) {
            ps.setString(1, message.getSendMessage());
            ps.setInt(2, message.getMessageId());
            ps.executeUpdate();
        }
    }
    public boolean deleteMessage(MessageBean message) throws SQLException {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(DELETE_MESSAGE_SQL)) {
            ps.setInt(1, message.getMessageId());
            return ps.executeUpdate() > 0;
        }
    }
}
