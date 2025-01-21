package command;

import java.util.List;

import context.RequestContext;
import context.ResponseContext;
import dao.RelationDAO;

public class UsersListCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        String userId = reqc.getParameter("userId")[0];
        
        // データベースに保存
        RelationDAO relationDAO = new RelationDAO();
        List<String> users = relationDAO.getUsersId(userId);
        resc.setResult(users);
        resc.setTarget("usersList"); // 画面にリダイレクト
        return resc;
    }
}
