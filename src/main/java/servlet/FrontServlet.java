package servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import context.RequestContext;
import context.ResponseContext;
import controller.ApplicationController;
import controller.WebApplicationController;

public class FrontServlet extends HttpServlet{
    protected void doGet(HttpServletRequest req,HttpServletResponse res)
        throws ServletException,IOException{
            doPost(req,res);
        }       
    public void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {
        req.setCharacterEncoding("Windows-31J");
        
        
        ApplicationController app = new WebApplicationController();

        // リクエストデータをログ出力
        System.out.println("Request Received:");
        System.out.println("Request URI: " + req.getRequestURI());
        System.out.println("Command: " + req.getParameter("command"));
        System.out.println("RelationId: " + req.getParameter("relationId"));
        System.out.println("UserId: " + req.getParameter("userId"));

        // リクエストコンテキスト取得
        RequestContext reqc = app.getRequest(req);

        // デバッグ用のログ
        System.out.println("Command Path: " + reqc.getCommandPath());

        // リクエスト処理
        ResponseContext resc = app.handleRequest(reqc);

        // レスポンスに設定
        resc.setResponse(res);

        // ターゲットの確認
        System.out.println("Target URI: " + resc.getTarget());

        // レスポンス処理
        app.handleResponse(reqc, resc);
    }

}
