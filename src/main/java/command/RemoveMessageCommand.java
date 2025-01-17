package command;

import java.util.List;

import bean.MessageBean;
import context.RequestContext;
import context.ResponseContext;
import dao.MessageDAO;

public class RemoveMessageCommand extends AbstractCommand {
	//メモ削除後、リダイレクト処理未成功
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        int messageId = Integer.parseInt(reqc.getParameter("messageId")[0]);

        MessageDAO messageDAO = new MessageDAO();
        messageDAO.removeMessage(messageId);

        int relationId = Integer.parseInt(reqc.getParameter("relationId")[0]);
        List<MessageBean> messages = messageDAO.getMessages(relationId);
        
        resc.setResult(messages);
        resc.setTarget("chat");
        return resc;
    }
}
