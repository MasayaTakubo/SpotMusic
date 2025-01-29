package command;

import java.sql.Timestamp;

import bean.MessageBean;
import context.RequestContext;
import context.ResponseContext;
import context.WebResponseContext;
import dao.MessageDAO;

public class AddMessageCommand extends AbstractCommand {
    
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        int relationId = Integer.parseInt(reqc.getParameter("relationId")[0]);
        String userId = reqc.getParameter("userId")[0];
        String message = reqc.getParameter("message") != null ? reqc.getParameter("message")[0] : "Default Message";
        if (message.isEmpty()) {
            throw new IllegalArgumentException("Message cannot be empty.");
        }
        MessageBean messageBean = new MessageBean();
        messageBean.setRelationId(relationId);
        messageBean.setUserId(userId);
        messageBean.setSendMessage(message);
        messageBean.setSendTime(new Timestamp(System.currentTimeMillis()));

        MessageDAO messageDAO = new MessageDAO();
        messageDAO.addMessage(messageBean);
        
        GetMessageCommand getMessageCommand = new GetMessageCommand();
        getMessageCommand.init(reqc);
        ResponseContext getMessageResc = getMessageCommand.execute(new WebResponseContext());

        resc.setResult(getMessageResc.getResult());
        resc.setTarget("chat"); // チャット画面にリダイレクト
        return resc;
    }
}
