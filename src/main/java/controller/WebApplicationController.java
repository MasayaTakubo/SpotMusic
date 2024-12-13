package controller;
import java.io.IOException;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
	    
	    // コマンドの結果（メッセージリストなど）をリクエストにセット
	    Object result = resc.getResult();
	    
	    // チャットメッセージリストの場合は "messages" という属性名でセット
	    //chat機能以外を作る時、修正が必要
	    if (result instanceof List) {
	        req.setAttribute("messages", result);
	    } else {
	        // その他の結果を処理（必要に応じて）
	        req.setAttribute("result", result);
	    }
	    
	    // ターゲットにリダイレクト
	    RequestDispatcher rd = req.getRequestDispatcher(resc.getTarget());
	    try {
	        rd.forward(req, res);
	    } catch (ServletException e) {
	        e.printStackTrace();
	    } catch (IOException e) {
	        e.printStackTrace();
	    }
	}

}
