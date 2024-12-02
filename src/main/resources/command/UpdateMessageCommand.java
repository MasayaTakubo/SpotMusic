package command;
//

public class UpdateMessageCommand extends AbstractCommand {
    public ResponseContext execute(ResponseContext resc){
        RequestContext reqc = getRequestContext();
        String[] mIds = reqc.getParameter("messageId");//仮。多分jspら辺
        String mId = mIds[0];
        String[] sendMs = reqc.getParameter("sendMessage");//仮。多分jspら辺
        String sendM = sendMs[0];
        messageBean mBean = new messageBean();
        mBean.setmessageId(mId);//タンチヤウと相談
        mBean.setsendMessage(sendM);//タンチヤウと相談
        MessageDAO mDAO= new MessageDAO();//チヨウと相談
        mDAO.UpdateMessage(sendMs);//チヨウと相談
        resc.setTarget("start");//startとは,,,
        return resc;
    }
}
