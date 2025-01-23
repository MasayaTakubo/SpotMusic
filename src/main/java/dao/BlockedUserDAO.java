package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import bean.blockBean;
import connector.MySQLConnector;

public class BlockedUserDAO {

    public void addBlock(blockBean blockBean) {
        String sql = "Insert into blocked_user(BLOCKER_ID,BLOCKED_ID) values(?,?)";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
        	stmt.setString(1, blockBean.getUserId());
        	stmt.setString(2, blockBean.getRelationId());
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    public void removeBlock(String blockId) {
        String sql = "Delete from blocked_user where block_Id = ?";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
        	stmt.setString(1, blockId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    public String getBlockedId(String relationId) {
    	String sql = "Select user1_Id,user2_Id from relation where relation_Id=?";
    	String blockedId="";
        try (Connection conn = MySQLConnector.getConn();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
           	stmt.setString(1, relationId);
           	ResultSet rs = stmt.executeQuery();
           	String user1Id = rs.getString("USER1_ID");
           	String user2Id = rs.getString("USER2_ID");
           	//自分が相手をブロックする。
           	if (user1Id.equals(relationId)) {
           		blockedId = user2Id;
           	} else {
           		blockedId = user1Id;
           	}

           } catch (SQLException e) {
               e.printStackTrace();
           }
        return blockedId;
    }
    public List getBlockList(String userId) {
    	String sql = "Select blocked_id from blocked_user where blocker_ID = ?";
    	List<String> blocklist = new ArrayList<>();
        try (Connection conn = MySQLConnector.getConn();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
           	stmt.setString(1, userId);
           	ResultSet rs = stmt.executeQuery();
           	while (rs.next()) {
                blocklist.add(rs.getString("blocked_id"));  // 自分がブロックしている相手のIDをリストに追加
            }
           } catch (SQLException e) {
               e.printStackTrace();
           }
        return blocklist;
    }
}
