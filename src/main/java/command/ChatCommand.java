package command;

import java.util.List;

import bean.MessageBean;
import context.RequestContext;
import context.ResponseContext;
import dao.MessageDAO;

public class ChatCommand extends AbstractCommand {
    
    @Override
    public ResponseContext execute(ResponseContext resc) {
    	RequestContext reqc = getRequestContext();
    	int relationId = Integer.parseInt(reqc.getParameter("relationId")[0]);

        // メッセージの取得
        MessageDAO messageDAO = new MessageDAO();
        List<MessageBean> messages = messageDAO.getMessages(relationId);

        // 結果をレスポンスに設定
        resc.setResult(messages);
        resc.setTarget("chat"); // レスポンスターゲットを設定
        return resc;
    }
}
