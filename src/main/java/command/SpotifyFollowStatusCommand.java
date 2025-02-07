package command;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

@WebServlet("/SpotifyFollowStatusServlet")
public class SpotifyFollowStatusCommand extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Boolean isFollowed = (Boolean) session.getAttribute("isFollowed"); // セッションからフォロー状態を取得

        // デフォルト値を false に設定
        if (isFollowed == null) {
            isFollowed = false;
        }

        // JSONレスポンスを作成
        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("isFollowed", isFollowed);

        // レスポンス設定
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(jsonResponse.toString());
    }
}
