package command;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import context.RequestContext;
import context.ResponseContext;

public class LogoutCommand extends AbstractCommand {

    @Override
    public ResponseContext execute(ResponseContext responseContext) {
        RequestContext reqContext = getRequestContext();
        HttpServletRequest request = (HttpServletRequest) reqContext.getRequest();
        HttpServletResponse response = (HttpServletResponse) responseContext.getResponse();

        // セッション無効化
        HttpSession session = request.getSession();
        session.invalidate(); // セッションの無効化

        // レスポンスをHTMLとして返す
        responseContext.setContentType("text/html");

        // Spotifyのログアウト処理 + リダイレクト
        String logoutScript = "<html><body>"
                + "<script>"
                + "var popup = window.open('https://accounts.spotify.com/logout', '_blank', 'width=500,height=500');"
                + "setTimeout(function() { window.location = '/SpotMusic/'; }, 3000);"
                + "</script>"
                + "</body></html>";

        responseContext.setResult(logoutScript);
        responseContext.setTarget(""); // 直接レスポンスを返すためJSPは不要

        return responseContext;
    }
}
