package command;

import bean.relationBean;
import context.RequestContext;
import context.ResponseContext;
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
        // レスポンスに結果をセット
        resc.setTarget("friendList"); // 画面にリダイレクト
        return resc;
    }
}
