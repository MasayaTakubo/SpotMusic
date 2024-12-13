package command;

import java.util.List;

import bean.MessageBean;
import context.ResponseContext;
import dao.MessageDAO;

public class GetMessageCommand extends AbstractCommand {

    @Override
    public ResponseContext execute(ResponseContext resc) {
//        RequestContext reqc = getRequestContext();
//        // relationIdをStringからintに変換
//        int relationId = Integer.parseInt(reqc.getParameter("relationId")[0]);
//        // ダミーデータとして relationId を固定
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
        resc.setTarget("chat"); // チャット画面にリダイレクト
        return resc;
    }
}
