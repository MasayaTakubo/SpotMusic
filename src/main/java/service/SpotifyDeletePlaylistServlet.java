package service;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SpotifyDeletePlaylistServlet")
public class SpotifyDeletePlaylistServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String SPOTIFY_API_URL = "https://api.spotify.com/v1/playlists/";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String accessToken = (String) session.getAttribute("access_token");

        if (accessToken == null) {
            System.out.println("ERROR: アクセストークンが null です。ログインしてください。");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<script>parent.alert('Spotify にログインしてください。');</script>");
            return;
        }

        String playlistId = request.getParameter("playlistId");
        if (playlistId == null || playlistId.isEmpty()) {
            System.out.println("ERROR: プレイリストIDが空です。");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<script>parent.alert('プレイリストIDが無効です。');</script>");
            return;
        }

        boolean success = deletePlaylist(playlistId, accessToken);
        System.out.println("DEBUG: プレイリスト削除結果 = " + success);

        if (success) {
            // セッションからプレイリストを削除
            session.removeAttribute("playlistBeans");
        }

        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().write("<script>parent.location.reload();</script>");
    }

    private boolean deletePlaylist(String playlistId, String accessToken) throws IOException {
        String urlString = SPOTIFY_API_URL + playlistId + "/followers";
        System.out.println("DEBUG: プレイリスト削除リクエスト URL = " + urlString);
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();

        connection.setRequestMethod("DELETE");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setDoOutput(true);

        int responseCode = connection.getResponseCode();
        System.out.println("DEBUG: APIレスポンスコード = " + responseCode);

        return responseCode == 200 || responseCode == 202; // 200または202なら削除成功
    }
}
