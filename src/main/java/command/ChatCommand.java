package command;

import java.util.List;

import bean.MessageBean;
import context.ResponseContext;
import dao.MessageDAO;

public class ChatCommand extends AbstractCommand {
    
    @Override
    public ResponseContext execute(ResponseContext resc) {
        int relationId = 1; // 常にrelationId=1を使用

        // メッセージの取得
        MessageDAO messageDAO = new MessageDAO();
        List<MessageBean> messages = messageDAO.getMessages(relationId);

        // デバッグログ
        System.out.println("Messages retrieved: " + messages.size());
        for (MessageBean message : messages) {
            System.out.println("Message: " + message.getUserId() + " - " + message.getSendMessage());
        }
        // 結果をレスポンスに設定
        resc.setResult(messages);
        resc.setTarget("chat"); // レスポンスターゲットを設定
        return resc;
    }
}
