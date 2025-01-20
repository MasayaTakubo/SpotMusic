package command;

import bean.relationBean;
import context.RequestContext;
import context.ResponseContext;
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
        // レスポンスに結果をセット
        resc.setTarget("friendList"); // チャット画面にリダイレクト
        return resc;
    }
}
