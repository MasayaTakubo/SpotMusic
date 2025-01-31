package controller;
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;

import command.AbstractCommand;
import command.CommandFactory;
import context.RequestContext;
import context.ResponseContext;
import context.WebRequestContext;
import context.WebResponseContext;


public class WebApplicationController implements ApplicationController {
	public RequestContext getRequest(Object request) {
		RequestContext reqc = new WebRequestContext();
		reqc.setRequest(request);
		return reqc;
	}
	public ResponseContext handleRequest(RequestContext req) {
		AbstractCommand command = CommandFactory.getCommand(req);
		command.init(req);
		ResponseContext resc = command.execute(new WebResponseContext());
		return resc;
	}
	public void handleResponse(RequestContext reqc, ResponseContext resc) {
	    HttpServletRequest req = (HttpServletRequest)reqc.getRequest();
	    HttpServletResponse res = (HttpServletResponse)resc.getResponse();
	    Object result = resc.getResult();
	    String command = req.getParameter("command");
	    String playlistId = req.getParameter("playlistId");
	    try {
		    if ("AddMessage".equals(command)) {
		        res.setContentType("application/json");
		        PrintWriter out = res.getWriter();
		        String jsonResponse = new Gson().toJson(result);
		        out.write(jsonResponse);
		        out.flush();
		    }else if( "ChatCommand".equals(command)){
		        res.setContentType("application/json");
		        PrintWriter out = res.getWriter();
		        String jsonResponse = new Gson().toJson(result);
		        req.setAttribute("messages", jsonResponse);
			    req.getRequestDispatcher(resc.getTarget()).forward(req, res);
		    } else // サーバーサイドのレスポンスでJavaScriptを送信する例
		    	if ("AddComment".equals(command)) {
		    	    res.setContentType("text/html");
		    	    PrintWriter out = res.getWriter();
		    	    out.write("<script>");
		    	    out.write("window.location.replace('FrontServlet?command=MyPlayListCommand');"); // 非同期に遷移
		    	    
		    	    out.write("window.onload = function() {");
		    	    out.write("loadPlaylistPage('");  // シングルクォーテーションで囲む
		    	    out.write(playlistId);  // 変数の内容
		    	    out.write("')");  // 閉じのシングルクォーテーション
		    	    out.write("};");
		    	    out.write("</script>");
		    	    out.flush();
		    	}  else {
		    	req.setAttribute("messages", result);
			    req.getRequestDispatcher(resc.getTarget()).forward(req, res);
		    }
	    }catch(IOException e) {
	    	e.printStackTrace();
	    } catch (ServletException e) {
			e.printStackTrace();
		}
	}

}
