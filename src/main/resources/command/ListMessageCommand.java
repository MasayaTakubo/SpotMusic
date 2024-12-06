import dao.MessageDAO;
import java.util.List;
import dao.MessageDAO;
import bean.messageBean;


public class ListMessageCommand extends AbstractCommand {

 
    public ResponseContext execute(ResponseContext resc) {
        // リクエストからrelationIdとuserIdを取得
        int relationId = Integer.parseInt(resc.getParameter("relationId")); 
        String userId = resc.getParameter("userId");  
        
        MessageBean mb = new MessageBean();
        mb.setRelationId(relationId);
        mb.setUserId(userId);
        // Commandファクトリを使ってMessageDAOを取得
        CommandFactory factory = CommandFactory.getFactory();
        MessageDAO messageDAO = factory.getMessageDao();
        
        
        // relationIdとuserIdを使ってメッセージリストを取得
        List<messageBean> messages = messageDAO.getMessages(mb);
        
        // レスポンスコンテキストにメッセージリストを設定
        resc.setResult(messages);
        
        // 遷移先のJSPページを設定（例: "chat.jsp"）
        resc.setTarget("chat");  

        return resc;  // レスポンスを返す
    }
}