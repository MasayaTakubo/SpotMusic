package command;

import java.util.List;

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
        List<relationBean> relations = relationDAO.getRelation(user1Id);
        resc.setResult(relations);
        resc.setTarget("friendList");
        return resc;
    }
}
