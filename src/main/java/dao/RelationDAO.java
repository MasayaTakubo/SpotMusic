package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import bean.relationBean;
import connector.MySQLConnector;

public class RelationDAO {

    public void addRelation(relationBean relationBean) {
        String sql = "INSERT INTO Relation (USER1_ID, USER2_ID) VALUES ( ?, ?)";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, relationBean.getUser1Id()); 
            stmt.setString(2, relationBean.getUser2Id());
            System.out.println(relationBean.getUser1Id()+"1-2"+relationBean.getUser2Id());
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<relationBean> getRelation(String userId) {
        List<relationBean> Relations = new ArrayList<>();
        String sql = "SELECT * FROM Relation WHERE User1_Id = ? OR User2_Id = ?";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, userId);
            stmt.setString(2, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                relationBean Relation = new relationBean(
                        rs.getInt("Relation_ID"),
                        rs.getString("USER1_ID"),
                        rs.getString("USER2_ID"),
                        rs.getString("Status")
                );
                Relations.add(Relation);  // メッセージをリストに追加
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return Relations;
    }

    public void acceptRelation(relationBean relationBean) {
        String sql = "UPDATE Relation SET status = ? WHERE Relation_ID = ?";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, relationBean.getStatus());
            stmt.setInt(2, relationBean.getRelationId());  // RelationIdはint型
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void cancelRelation(relationBean relationBean) {
        String sql = "UPDATE Relation SET status = ? WHERE Relation_ID = ?";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, relationBean.getStatus());
            stmt.setInt(2, relationBean.getRelationId());  // RelationIdはint型
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public List<String> getUsersId() {
        String sql = "SELECT user_id FROM users";
        List<String> userIds = new ArrayList<>();
        
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                userIds.add(rs.getString("user_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return userIds;  // ユーザーIDのリストを返す
    }
    public void deleteRelation(int relationId) {
    	String sql = "DELETE from relation where relation_Id = ?";
    	try (Connection conn = MySQLConnector.getConn();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
               stmt.setInt(1, relationId);
               stmt.executeUpdate();
           } catch (SQLException e) {
               e.printStackTrace();
           }
    }

}
