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

public class AddBlockUserCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String blockedId = reqc.getParameter("blockedId")[0];
        String blockerId = reqc.getParameter("blockerId")[0];
        
        blockBean blockBean = new blockBean();
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        blockBean.setBlockerId(blockerId);
        blockBean.setBlockedId(blockedId);
        blockDAO.addBlock(blockBean);
        Map<String, List<?>> data = getShowData(blockerId);
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
