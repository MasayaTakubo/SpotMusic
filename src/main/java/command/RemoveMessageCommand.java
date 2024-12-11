package command;

import java.util.Optional;


import dao.MessageDAO;
import bean.messageBean;

public class RemoveMessageCommand extends AbstractCommand {

    public ResponseContext execute(ResponseContext resc) {
        // DAOファクトリーを取得
        AbstractDaoFactory factory = AbstractDaoFactory.getFactory();
        MessageDAO dao = factory.getMessageDao();

        // リクエストから削除対象のメッセージIDを取得
        RequestContext reqc = getRequestContext();
        String messageIdParam = reqc.getParameter("messageId"); //Parameter名は仮
        Optional<Long> messageIdOpt = parseMessageId(messageIdParam);

        if (messageIdOpt.isPresent()) {
            long messageId = messageIdOpt.get();
            // メッセージを削除
            boolean isRemoved =dao.removeMessageById(messageId);　//メソッド名は仮

            // 結果を設定　setResultの引数は仮
            if (isRemoved) {
                resc.setResult("Message with ID " + messageId + " was successfully deleted.");
            } else {
                resc.setResult("Failed to delete message with ID " + messageId + ".");
            }
        } else {
            resc.setResult("Invalid or missing message ID.");
        }

        // 遷移先のビューを設定
        resc.setTarget("chat"); //Target先は仮

        return resc;
    }

    // メッセージIDのパース処理
    private Optional<Long> parseMessageId(String messageIdParam) {
        try {
            return Optional.of(Long.parseLong(messageIdParam));
        } catch (NumberFormatException e) {
            return Optional.empty();
        }
    }
}
