package command;

import java.sql.Timestamp;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import bean.CommentBean;
import context.RequestContext;
import context.ResponseContext;
import dao.CommentDAO;

public class AddCommentCommand extends AbstractCommand {
	
	public ResponseContext execute(ResponseContext resc) {
        RequestContext reqc = getRequestContext();
        HttpServletRequest request = (HttpServletRequest) reqc.getRequest();
        HttpSession session = request.getSession();
        
        String playlistId = reqc.getParameter("playlistId")[0];
        String userId     = (String)session.getAttribute("user_id");
        String userName = (String) session.getAttribute("user_name");
        String comment    = reqc.getParameter("comment") != null ? reqc.getParameter("comment")[0] : "Default Comment";
        
        //確認用(全部OK)
        //System.out.println("プレイリストID : "+playlistId);
        //System.out.println("ユーザーID : "+userId);		   
        //System.out.println("コメント : "+comment);		
        //System.out.println("ユーザー名 : "+userName);
        
        
        if (comment.isEmpty()) {
            throw new IllegalArgumentException("Comment cannot be empty.");
        }

        // コメントをセット
        CommentBean commentBean = new CommentBean();
        commentBean.setPlayListId(playlistId);
        commentBean.setUserId(userId);
        commentBean.setUserName(userName);
        commentBean.setSendComment(comment);
        commentBean.setSendTime(new Timestamp(System.currentTimeMillis()));

        // データベースに保存
        CommentDAO commentDAO = new CommentDAO();
        commentDAO.addComment(commentBean);

        // 最新のコメントを取得
        //GetCommentCommand getCommentCommand = new GetCommentCommand();
        //getCommentCommand.init(reqc);
        //ResponseContext getCommentResc = getCommentCommand.execute(new WebResponseContext());
        
        
        List<CommentBean> comments = commentDAO.getComment(playlistId);
        session.setAttribute("playlistId", playlistId); // ここでセット
        
        //確認用
        //System.out.println("表示する内容"+getCommentResc.getResult())     ;   
        
        // レスポンスに結果をセット
        //resc.setResult(getCommentResc.getResult());
        request.setAttribute("comments",comments);
        //resc.setTarget("playList");
        

        resc.setResult(null); // 結果は不要
        resc.setTarget(null);
        
        //確認
        //System.out.println("とれたやつ"+comments);        
        
        return resc;
	}
}