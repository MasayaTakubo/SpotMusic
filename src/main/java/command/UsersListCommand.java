package command;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import bean.blockBean;
import bean.relationBean;
import context.RequestContext;
import context.ResponseContext;
import dao.BlockedUserDAO;
import dao.RelationDAO;

public class UsersListCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
    	RequestContext reqc = getRequestContext();
    	String userId = reqc.getParameter("userId")[0];
        RelationDAO relationDAO = new RelationDAO();
        List<String> users = relationDAO.getUsersId();
        List<relationBean> isfriend = relationDAO.getRelation(userId);
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        List<blockBean> blockusers = blockDAO.getBlockList(userId);
        Map<String, List<?>> data = new HashMap<>();
        data.put("users",users);
        data.put("isfriend",isfriend);
        data.put("blockusers", blockusers);
        resc.setResult(data);
        resc.setTarget("usersList");
        return resc;
    }
}
