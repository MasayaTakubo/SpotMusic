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
        List<relationBean> relations = relationDAO.getRelation(user1Id);
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        List<blockBean> blockusers = blockDAO.getBlockList(user1Id);
        Map<String, List<?>> data = new HashMap<>();
        data.put("relations",relations);
        data.put("blockusers",blockusers);
        resc.setResult(data);
        resc.setTarget("friendList");
        return resc;
    }
}
