package command;

import java.util.List;

import bean.relationBean;
import context.RequestContext;
import context.ResponseContext;
import dao.RelationDAO;

public class AcceptRelationCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String relationIdstr = reqc.getParameter("relationId")[0];
        int relationId = Integer.parseInt(relationIdstr);
        String status = "Accept";
        
        relationBean relationBean = new relationBean();
        relationBean.setRelationId(relationId);
        relationBean.setStatus(status);
        // データベースに保存
        RelationDAO relationDAO = new RelationDAO();
        relationDAO.acceptRelation(relationBean);
        //表示のためのデータ取得
        String userId = reqc.getParameter("userId")[0];
        List<relationBean> relations = relationDAO.getRelation(userId);
        resc.setResult(relations);
        resc.setTarget("friendList");
        return resc;
    }
}
