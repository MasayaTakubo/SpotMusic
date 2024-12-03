package tera;

import dao.AbstractDaoFactory;
import dao.ProductsDao;

public class AddMessageCommand extends AbstractCommand {

    @Override
    public ResponseContext execute(ResponseContext res) {
        // リクエストコンテキストの取得
        RequestContext reqc = getRequestContext();

        // リクエストからパラメータを取得
        String[] r_id = reqc.getParameter("r_id");
        String relation_id =  r_id[0];  

        String[] u_id = reqc.getParameter("u_id");
        String user_id = u_id[0];

        String[] messages = reqc.getParameter("message");
        String message = messages[0];

        // MessageBeanオブジェクトの作成とデータの設定
        MessageBean p = new MessageBean();
        p.setRelation_Id(relation_id);         
        p.setuser_Id(user_id);      
        p.setMessage(message);  
        
        // MessageDAOを使ってデータベースに保存
        MessageDAO ms = new MessageDAO();
        ms.execute(p);

        // リストを更新後、適切なページにリダイレクト
        res.setTarget("chat"); // 成功ページにリダイレクト

        return res;
    }
}
