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

public class AddBlockFriendCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String userId = reqc.getParameter("userId")[0];
        String relationId = reqc.getParameter("relationId")[0];
        
        blockBean blockBean = new blockBean();
        blockBean.setUserId(userId);
        blockBean.setRelationId(relationId);
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        String blockedId = blockDAO.getBlockedId(blockBean);
        blockBean.setBlockerId(userId);
        blockBean.setBlockedId(blockedId);
        blockDAO.addBlock(blockBean);
        Map<String, List<?>> data = getShowData(userId);
        resc.setResult(data);
        resc.setTarget("blockList");
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
