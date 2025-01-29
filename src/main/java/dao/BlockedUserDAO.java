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
        	stmt.setString(1, blockBean.getBlockerId());
        	stmt.setString(2, blockBean.getBlockedId());
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
    public String getBlockedId(blockBean blockBean) {
    	String sql = "Select user1_Id,user2_Id from relation where relation_Id=?";
    	String blockedId="";
        try (Connection conn = MySQLConnector.getConn();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
        	String userId = blockBean.getUserId();
        	String relationId = blockBean.getRelationId();
           	stmt.setString(1, relationId);
           	ResultSet rs = stmt.executeQuery();
        	String user1Id="";
        	String user2Id="";
           	if (rs.next()) {
	           	user1Id = rs.getString("USER1_ID");
	           	user2Id = rs.getString("USER2_ID");
           	}
           	//自分が相手をブロックする。
           	if (user1Id.equals(userId)) {
           		blockedId = user2Id;
           	} else {
           		blockedId = user1Id;
           	}

           } catch (SQLException e) {
               e.printStackTrace();
           }
        return blockedId;
    }
    public List<blockBean> getBlockList(String userId) {
    	String sql = "Select block_id,blocked_id from blocked_user where blocker_ID = ?";
    	List<blockBean> blocklist = new ArrayList<>();
        try (Connection conn = MySQLConnector.getConn();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
           	stmt.setString(1, userId);
           	ResultSet rs = stmt.executeQuery();
           	while (rs.next()) {
           		blockBean blockBean = new blockBean();
           		blockBean.setBlockId(rs.getString("block_id"));
                blockBean.setBlockedId(rs.getString("blocked_id"));  // 自分がブロックしている相手のIDをリストに追加
                blocklist.add(blockBean);
            }
           } catch (SQLException e) {
               e.printStackTrace();
           }
        return blocklist;
    }
}
