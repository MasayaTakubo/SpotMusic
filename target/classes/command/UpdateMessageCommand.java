package command;
//

public class UpdateMessageCommand extends AbstractCommand {
    public ResponseContext execute(ResponseContext resc){
        RequestContext reqc = getRequestContext();
        String[] messageIds = reqc.getParameter("messageId");//仮。多分jspら辺
        String messageId = messageIds[0];
        String[] sendMessages = reqc.getParameter("sendMessage");//仮。多分jspら辺
        String sendMessage= sendMessages[0];
        messageBean messageBean = new messageBean();
        messageBean.setmessageId(messageId);//タンチヤウと相談
        messageBean.setsendMessage(sendMessage);//タンチヤウと相談
        MessageDAO messageDAO= new MessageDAO();//チヨウと相談
        messageDAO.UpdateMessage(sendMessages);//チヨウと相談
        resc.setTarget("message");//多分メッセージ画面に戻すので仮に設定
        return resc;
    }
}
