package service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // セッション無効化
        HttpSession session = request.getSession();
        session.invalidate(); // セッションの無効化

        // JavaScriptを使って、Spotifyのログアウト画面を表示し、自前のページにリダイレクト
        response.setContentType("text/html");
        response.getWriter().println("<html><body>");
        response.getWriter().println("<script>");
        
        // Spotifyのログアウト画面をポップアップで開く
        response.getWriter().println("var popup = window.open('https://accounts.spotify.com/logout', '_blank', 'width=500,height=500');");
        
        // 少し遅れてログイン画面にリダイレクト
        response.getWriter().println("setTimeout(function() { window.location = '/SpotMusic/'; }, 3000);");

        response.getWriter().println("</script>");
        response.getWriter().println("</body></html>");
    }

}
