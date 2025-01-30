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

public class RemoveBlockUserCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String userId = reqc.getParameter("userId")[0];
        String blockId = reqc.getParameter("blockId")[0];
        // データベースに保存
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        blockDAO.removeBlock(blockId);
        RelationDAO relationDAO = new RelationDAO();
        List<relationBean> relations = relationDAO.getRelation(userId);
        List<blockBean> blockusers = blockDAO.getBlockList(userId);
        Map<String, List<?>> data = new HashMap<>();
        data.put("relations",relations);
        data.put("blockusers",blockusers);
        resc.setResult(data);
        resc.setTarget("friendList");
        return resc;
    }
}
