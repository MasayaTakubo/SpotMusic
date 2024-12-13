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
        
        // ダミーデータを使用（relationId = 1を固定）
        String relationIdStr = "1"; // relationIdを固定
        int relationId = Integer.parseInt(relationIdStr);

        // ダミーデータとして userId を固定
        String userId = "user1";
        
        // リクエストからメッセージを取得
        String message = reqc.getParameter("message") != null ? reqc.getParameter("message")[0] : "Default Message";
        
        if (message.isEmpty()) {
            throw new IllegalArgumentException("Message cannot be empty.");
        }

        // メッセージデータを設定
        MessageBean messageBean = new MessageBean();
        messageBean.setRelationId(relationId);
        messageBean.setUserId(userId);
        messageBean.setSendMessage(message);
        messageBean.setSendTime(new Timestamp(System.currentTimeMillis()));

        // データベースに保存
        MessageDAO messageDAO = new MessageDAO();
        messageDAO.addMessage(messageBean);

        // 最新メッセージリストを取得
        GetMessageCommand getMessageCommand = new GetMessageCommand();
        getMessageCommand.init(reqc);
        ResponseContext getMessageResc = getMessageCommand.execute(new WebResponseContext());

        // レスポンスに結果をセット
        resc.setResult(getMessageResc.getResult());
        resc.setTarget("chat"); // チャット画面にリダイレクト
        return resc;
    }
}
