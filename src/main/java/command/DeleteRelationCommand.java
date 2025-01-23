package command;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import bean.relationBean;
import context.RequestContext;
import context.ResponseContext;
import dao.RelationDAO;

public class DeleteRelationCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String relationIdstr = reqc.getParameter("relationId")[0];
        int relationId = Integer.parseInt(relationIdstr);
        // relation表のrelationIdを削除
        RelationDAO relationDAO = new RelationDAO();
        relationDAO.deleteRelation(relationId);
        //表示データ取得用
    	String userId = reqc.getParameter("userId")[0];
        List<String> users = relationDAO.getUsersId();
        List<relationBean> isfriend = relationDAO.getRelation(userId);
        Map<String, List<?>> data = new HashMap<>();
        data.put("users",users);
        data.put("isfriend",isfriend);
        resc.setResult(data);
        resc.setTarget("usersList");
        return resc;
    }
}
