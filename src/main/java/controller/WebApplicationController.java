package controller;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

import javax.servlet.RequestDispatcher;
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
	/*	public void handleResponse(RequestContext reqc, ResponseContext resc) {
		    HttpServletRequest req = (HttpServletRequest)reqc.getRequest();
		    HttpServletResponse res = (HttpServletResponse)resc.getResponse();
		    Object result = resc.getResult();
		    String command = req.getParameter("command");
		    String playlistId = req.getParameter("playlistId");
		    
		    try {
		    	if ("AddMessage".equals(command) || "SpotifyRemoveTrack".equals(command) || "SpotifyCreatePlaylistCommand".equals(command) || "SpotifyDeletePlaylistCommand".equals(command)) {
		    	    res.setContentType("application/json");
		    	    res.setCharacterEncoding("UTF-8");
		    	    PrintWriter out = res.getWriter();
		    	    String jsonResponse = new Gson().toJson(result);
		    	    out.write(jsonResponse);
		    	    out.flush();
		    	} else if( "ChatCommand".equals(command)){
			    	WebResponseContext wresc = (WebResponseContext)resc;
			    	Map<String,String> userMap = (Map)wresc.getResult("userMap");
			        res.setContentType("application/json");
			        PrintWriter out = res.getWriter();
			        String jsonResponse = new Gson().toJson(result);
			        req.setAttribute("userMap",userMap);
			        req.setAttribute("messages", jsonResponse);
				    req.getRequestDispatcher(resc.getTarget()).forward(req, res);
			    }else if ("AddComment".equals(command)) {
			    	res.sendRedirect("FrontServlet?command=MyPlayListCommand&playlistId=" + playlistId + "&commentAdded=true");
		    	}else {
			    	req.setAttribute("messages", result);
				    req.getRequestDispatcher(resc.getTarget()).forward(req, res);
			    }
		    }catch(IOException e) {
		    	e.printStackTrace();
		    } catch (ServletException e) {
				e.printStackTrace();
			}
		}*/
	//0207修正テスト
	public void handleResponse(RequestContext reqc, ResponseContext resc) {
	    HttpServletRequest req = (HttpServletRequest) reqc.getRequest();
	    HttpServletResponse res = (HttpServletResponse) resc.getResponse();
	    Object result = resc.getResult();
	    String command = req.getParameter("command");
	    String playlistId = req.getParameter("playlistId");
	    String target = resc.getTarget(); // コマンドが設定したターゲット
	    System.out.println("?? Handling response. Target: " + resc.getTarget());


	    try {
	    	if ("SpotifySearchCommand".equals(command)) {
	            // `resc.getTarget()` を使用して動的に JSP にフォワード
	            if (target == null || target.isEmpty()) {
	                target = "search"; // デフォルトのページ
	            }
	            RequestDispatcher dispatcher = req.getRequestDispatcher(target);
	            dispatcher.forward(req, res);

	    	} else if ("SpotifyDeletePlaylistCommand".equals(command)) {
	            // SpotifyDeletePlaylistCommand の場合、HTML または JSON を適切に処理
	            String responseType = req.getParameter("responseType");

	            if ("html".equalsIgnoreCase(responseType)) {
	                res.setContentType("text/html; charset=UTF-8");
	                res.setCharacterEncoding("UTF-8");
	                PrintWriter out = res.getWriter();
	                out.write((String) result); // HTMLを直接出力
	                out.flush();
	            } else {
	                res.setContentType("application/json");
	                res.setCharacterEncoding("UTF-8");
	                PrintWriter out = res.getWriter();
	                String jsonResponse = new Gson().toJson(result);
	                out.write(jsonResponse);
	                out.flush();
	            } 
	        	}else if ("SpotifyCreatePlaylistCommand".equals(command)) {
		            // SpotifyCreatePlaylistCommand の場合、HTML または JSON を適切に処理
		            String responseType = req.getParameter("responseType");

		            if ("html".equalsIgnoreCase(responseType)) {
		                res.setContentType("text/html; charset=UTF-8");
		                res.setCharacterEncoding("UTF-8");
		                PrintWriter out = res.getWriter();
		                out.write((String) result); // HTMLを直接出力
		                out.flush();
		            } else {
		                res.setContentType("application/json");
		                res.setCharacterEncoding("UTF-8");
		                PrintWriter out = res.getWriter();
		                String jsonResponse = new Gson().toJson(result);
		                out.write(jsonResponse);
		                out.flush();
		            }
		        }else if ("AddMessage".equals(command) || "SpotifyRemoveTrack".equals(command) || "SpotifyCreatePlaylistCommand".equals(command)) {
	            // 他の JSON のみを返すコマンド
	            res.setContentType("application/json");
	            res.setCharacterEncoding("UTF-8");
	            PrintWriter out = res.getWriter();
	            String jsonResponse = new Gson().toJson(result);
	            out.write(jsonResponse);
	            out.flush();
	        } else if ("ChatCommand".equals(command)) {
	            WebResponseContext wresc = (WebResponseContext) resc;
	            Map<String, String> userMap = (Map) wresc.getResult("userMap");
	            res.setContentType("application/json");
	            PrintWriter out = res.getWriter();
	            String jsonResponse = new Gson().toJson(result);
	            req.setAttribute("userMap", userMap);
	            req.setAttribute("messages", jsonResponse);
	            req.getRequestDispatcher(resc.getTarget()).forward(req, res);
	        } else if ("AddComment".equals(command)) {
	            res.sendRedirect("FrontServlet?command=MyPlayListCommand&playlistId=" + playlistId + "&commentAdded=true");
	        } else {
	            req.setAttribute("messages", result);
	            req.getRequestDispatcher(resc.getTarget()).forward(req, res);
	        }
	    } catch (IOException e) {
	        e.printStackTrace();
	    } catch (ServletException e) {
	        e.printStackTrace();
	    }
	}


}
