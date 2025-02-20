package servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import context.RequestContext;
import context.ResponseContext;
import controller.ApplicationController;
import controller.WebApplicationController;

public class FrontServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doPost(req, res);
    }       
    
    public void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {

        res.setContentType("application/json");
        req.setCharacterEncoding("UTF-8");
        System.out.println("FrontServletに処理が来ました。");

        ApplicationController app = new WebApplicationController();    
        HttpSession session = req.getSession();
        
        String userId = req.getParameter("userId");
        if(userId != null && !userId.isEmpty()) {
            session.setAttribute("userId", userId);
        }
        
        // リクエストデータをログ出力
        System.out.println("Request Received:");
        System.out.println("Request URI: " + req.getRequestURI());
        System.out.println("Command: " + session.getAttribute("command"));
        System.out.println("RelationId: " + req.getParameter("relationId"));
        System.out.println("UserId: " + req.getParameter("userId"));
        System.out.println("SessionUserId: " + session.getAttribute("user_id"));
        
        try {
            // リクエストコンテキスト取得
            RequestContext reqc = app.getRequest(req);

            // デバッグ用ログ出力
            System.out.println("Command Path: " + reqc.getCommandPath());

            // リクエスト処理（ここで CommandFactory からコマンド取得などが行われる）
            ResponseContext resc = app.handleRequest(reqc);
            
            // LogoutCommand の場合、HTML を直接レスポンスとして出力
            if ("LogoutCommand".equals(reqc.getCommandPath())) {
                res.setContentType("text/html");
                res.getWriter().write((String) resc.getResult());
                return;
            }

            // レスポンスに設定
            resc.setResponse(res);

            // ターゲットURIのログ出力
            System.out.println("Target URI: " + resc.getTarget());
            
            // トラックデバッグ
            System.out.println("Command: " + req.getParameter("command"));
            System.out.println("Track ID: " + req.getParameter("trackId"));

            // レスポンス処理
            app.handleResponse(reqc, resc);
        } catch (RuntimeException e) {
            // 例外発生時（例：コマンドが見つからない等）
            e.printStackTrace();
            // WEB-INF内の error.jsp にフォワード
            req.getRequestDispatcher("/WEB-INF/jsp/error.jsp").forward(req, res);
        }
    }
}
