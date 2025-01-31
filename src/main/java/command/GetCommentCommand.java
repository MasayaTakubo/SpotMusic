package command;

import java.util.List;

import bean.CommentBean;
import context.RequestContext;
import context.ResponseContext;
import dao.CommentDAO;

public class GetCommentCommand extends AbstractCommand {
    @Override
    public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();

        // playlistId を取得
        String playlistId = reqc.getParameter("playlistId")[0];
        
        // DAOを使ってコメントを取得
        CommentDAO commentDAO = new CommentDAO();
        List<CommentBean> comments = commentDAO.getComment(playlistId);
        	
        for (CommentBean comment : comments) {
            System.out.println("レスポンス！！！！！！UserID: " + comment.getUserId() + ", Comment: " + comment.getSendComment() + ", Time: " + comment.getSendTime());
        }
               
        // 取得したコメントをレスポンスにセット
        resc.setResult(comments);
        resc.setTarget("playList");
        return resc;
    }
}

