package command;

import java.util.List;

import bean.MessageBean;
import context.RequestContext;
import context.ResponseContext;
import dao.MessageDAO;

public class UpdateMessageCommand extends AbstractCommand {
//メモ更新後、リダイレクト処理未成功
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        int messageId = Integer.parseInt(reqc.getParameter("messageId")[0]);
        String newMessage = reqc.getParameter("message")[0];

        MessageBean messageBean = new MessageBean();
        messageBean.setMessageId(messageId);
        messageBean.setSendMessage(newMessage);

        MessageDAO messageDAO = new MessageDAO();
        messageDAO.updateMessage(messageBean);

        // メッセージ更新後、最新のメッセージを取得
        List<MessageBean> messages = messageDAO.getMessages(Integer.parseInt(reqc.getParameter("relationId")[0]));
        resc.setResult(messages);
        resc.setTarget("json");  // jsonで返却
        return resc;
    }
}
