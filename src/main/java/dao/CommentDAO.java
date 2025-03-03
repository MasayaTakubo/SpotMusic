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
		String sql = "insert into comment (playlist_id, user_id, user_name, send_comment, send_time) values (?,?,?,?,?)";
		try (Connection conn = MySQLConnector.getConn();
			PreparedStatement stmt = conn.prepareStatement(sql)) {
			
			conn.setAutoCommit(false);
			// 現在の時刻を設定
            Timestamp currentTime = new Timestamp(System.currentTimeMillis());
         
            stmt.setString(1, commentBean.getPlayListId());
            stmt.setString(2, commentBean.getUserId()); 
            stmt.setString(3, commentBean.getUserName());
            stmt.setString(4, commentBean.getSendComment());
            stmt.setTimestamp(5, currentTime);  // 投稿時間を追加
            stmt.executeUpdate();
            conn.commit();
        } catch (SQLException e) {
            e.printStackTrace();
        }
	}
	
	public List<CommentBean> getComment(String playlistId) {
        List<CommentBean> comments = new ArrayList<>();
        String sql = "select * from comment where playlist_id = ? order by send_time desc";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, playlistId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
            	CommentBean commentBean = new CommentBean(
                        rs.getInt("comment_id"),
                        rs.getString("playlist_id"),
                        rs.getString("user_id"),
                        rs.getString("user_name"),
                        rs.getTimestamp("send_time"),
                        rs.getString("send_comment")
                );
                comments.add(commentBean);  // メッセージをリストに追加
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }
	
	public void updateComment(CommentBean commentBean) {
		String sql = "UPDATE comment SET send_comment = ? WHERE comment_id = ?";
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
		String sql = "DELETE FROM comment WHERE comment_id  = ?";
		try (Connection conn = MySQLConnector.getConn();
				 PreparedStatement stmt = conn.prepareStatement(sql)) {
			stmt.setInt(1, commentId);
			stmt.executeUpdate();
		} catch(SQLException e) {
			e.printStackTrace();
		}
	}
}