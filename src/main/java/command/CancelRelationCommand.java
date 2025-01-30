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

public class CancelRelationCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String relationIdstr = reqc.getParameter("relationId")[0];
        int relationId = Integer.parseInt(relationIdstr);
        String status = "Cancel";
        
        relationBean relationBean = new relationBean();
        relationBean.setRelationId(relationId);
        relationBean.setStatus(status);
        // データベースに保存
        RelationDAO relationDAO = new RelationDAO();
        relationDAO.cancelRelation(relationBean);
        //表示データ取得用
        String userId = reqc.getParameter("userId")[0];
        List<relationBean> relations = relationDAO.getRelation(userId);
        BlockedUserDAO blockDAO = new BlockedUserDAO();
        List<blockBean> blockusers = blockDAO.getBlockList(userId);
        Map<String, List<?>> data = new HashMap<>();
        data.put("relations",relations);
        data.put("blockusers",blockusers);
        resc.setResult(data);
        resc.setTarget("friendList");
        return resc;
    }
}
