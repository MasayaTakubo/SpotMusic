package command;

import dao.AbstractDaoFactory;
import dao.MessageDao;
import bean.MessageBean;

public class AddMessageCommand extends AbstractCommand {

    @Override
    public ResponseContext execute(ResponseContext res) {
        // リクエストコンテキストの取得
        RequestContext reqc = getRequestContext();

        // リクエストからパラメータを取得
        String[] relationalIds = reqc.getParameter("relationId");
        String relationId =  relationalIds[0];  

        String[] usersIds = reqc.getParameter("userId");
        String userId = usersIds[0];

        String[] messages = reqc.getParameter("message");
        String message = messages[0];

        // MessageBeanオブジェクトの作成とデータの設定
        MessageBean mb = new MessageBean();
        mb.setRelationId(relationId);         
        mb.setUserId(userId);      
        mb.setMessage(message);  
        
        // MessageDAOを使ってデータベースに保存
        MessageDAO ms = new MessageDAO();
        ms.execute(p);

        // リストを更新後、適切なページにリダイレクト
        res.setTarget("chat"); // 成功ページにリダイレクト

        return res;
    }
}
