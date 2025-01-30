package command;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import bean.blockBean;
import bean.relationBean;
import bean.usersBean;
import context.RequestContext;
import context.ResponseContext;
import dao.BlockedUserDAO;
import dao.RelationDAO;
import dao.UsersDAO;

public class AddRelationCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String user1Id = reqc.getParameter("user1Id")[0];
        String user2Id = reqc.getParameter("user2Id")[0];
        
        relationBean relationBean = new relationBean();
        relationBean.setUser1Id(user1Id);
        relationBean.setUser2Id(user2Id);
        // データベースに保存
        RelationDAO relationDAO = new RelationDAO();
        relationDAO.addRelation(relationBean);
        Map<String, List<?>> data = getShowData(user1Id);
        resc.setResult(data);
        resc.setTarget("friendList");
        return resc;
    }
    
    private Map<String, List<?>> getShowData(String userId){
    	//jspの表示に使うものは基本relation,users,blockedUsers表しかないからまとめる
        RelationDAO relationDAO = new RelationDAO();
        List<relationBean> relations = relationDAO.getRelation(userId);
        UsersDAO usersDAO = new UsersDAO();
        List<usersBean> users = usersDAO.getUsersData();
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        List<blockBean> blockusers = blockDAO.getBlockList(userId);
        Map<String, List<?>> data = new HashMap<>();
        data.put("users",users);
        data.put("relations",relations);
        data.put("blockusers", blockusers);
    	return data;
    }
}
