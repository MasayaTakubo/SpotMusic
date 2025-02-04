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

public class RemoveBlockUserCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String userId = reqc.getParameter("userId")[0];
        String blockId = reqc.getParameter("blockId")[0];
        // データベースに保存
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        blockDAO.removeBlock(blockId);
        
        Map<String, List<?>> data = getShowData(userId);
        resc.setResult(data);
        resc.setTarget("blockList");
        return resc;
    }
    
    private Map<String, List<?>> getShowData(String userId){
    	//jspの表示に使うものは基本relation,users,blockedUsers表しかないからまとめる
        RelationDAO relationDAO = new RelationDAO();
        List<relationBean> isfriend = relationDAO.getRelation(userId);
        UsersDAO usersDAO = new UsersDAO();
        List<usersBean> users = usersDAO.getUsersData();
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        List<blockBean> blockusers = blockDAO.getBlockList(userId);
        Map<String, List<?>> data = new HashMap<>();
        data.put("users",users);
        data.put("relations",isfriend);
        data.put("blockusers", blockusers);
    	return data;
    }
}
