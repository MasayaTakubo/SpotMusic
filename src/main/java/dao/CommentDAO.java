package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import bean.CommentBean;
import connector.MySQLConnector;

public class CommentDAO {
	
	public void addComment(CommentBean commentBean) {
		String sql = "INSERT INTO COMMENT (PLAYLIST_ID, USER_ID, SEND_COMMENT, SEND_TIME) VALUES (?,?,?,?)";
		try (Connection conn = MySQLConnector.getConn();
			PreparedStatement stmt = conn.prepareStatement(sql)) {
			
			conn.setAutoCommit(false);
			// 現在の時刻を設定
            Timestamp currentTime = new Timestamp(System.currentTimeMillis());
         
            stmt.setString(1, commentBean.getPlayListId());
            stmt.setString(2, commentBean.getUserId()); 
            stmt.setString(3, commentBean.getSendComment());
            stmt.setTimestamp(4, currentTime);  // 投稿時間を追加
            stmt.executeUpdate();
            conn.commit();
        } catch (SQLException e) {
            e.printStackTrace();
        }
	}
	
	public List<CommentBean> getComment(String playlistId) {
        List<CommentBean> comments = new ArrayList<>();
        String sql = "SELECT * FROM COMMENT WHERE PLAYLIST_ID = ? ORDER BY SEND_TIME";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, playlistId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
            	CommentBean commentBean = new CommentBean(
                        rs.getInt("COMMENT_ID"),
                        rs.getString("PLAYLIST_ID"),
                        rs.getString("USER_ID"),
                        rs.getTimestamp("SEND_TIME"),
                        rs.getString("SEND_COMMENT")
                );
                comments.add(commentBean);  // メッセージをリストに追加
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }
	
	public void updateComment(CommentBean commentBean) {
		String sql = "UPDATE COMMENT SET SEND_COMMENT = ? WHERE COMMENT_ID = ?";
		try (Connection conn = MySQLConnector.getConn();
			 PreparedStatement stmt = conn.prepareStatement(sql)) {
			stmt.setString(1, commentBean.getSendComment());
			stmt.setInt(2, commentBean.getCommentId());
			stmt.executeUpdate();
		} catch(SQLException e) {
			e.printStackTrace();
		}
	}
	
	public void removeComment(int commentId) {
		String sql = "DELETE FROM COMMENT WHERE COMMENT_ID  = ?";
		try (Connection conn = MySQLConnector.getConn();
				 PreparedStatement stmt = conn.prepareStatement(sql)) {
			stmt.setInt(1, commentId);
			stmt.executeUpdate();
		} catch(SQLException e) {
			e.printStackTrace();
		}
	}
}