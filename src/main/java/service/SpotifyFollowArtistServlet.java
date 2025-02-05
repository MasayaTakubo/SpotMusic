package service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SpotifyFollowArtistServlet")
public class SpotifyFollowArtistServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String SPOTIFY_API_URL = "https://api.spotify.com/v1/me/following?type=artist&ids=";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String accessToken = (String) session.getAttribute("access_token");

        if (accessToken == null) {
            sendResponse(response, "Spotify にログインしてください。");
            return;
        }

        String artistId = request.getParameter("artistId");
        String action = request.getParameter("action");  // "follow" or "unfollow"

        if (artistId == null || action == null) {
            sendResponse(response, "アーティスト ID またはアクションが不足しています。");
            return;
        }

        boolean success = sendFollowRequest(artistId, accessToken, action.equals("follow") ? "PUT" : "DELETE");
        boolean isFollowed = isArtistFollowed(artistId, accessToken);  // 最新のフォロー状態を取得

        // **セッションに更新されたフォロー状態を保存**
        session.setAttribute("isFollowed", isFollowed);

        System.out.println("DEBUG: アーティストフォロー結果 = " + success);
        System.out.println("DEBUG: フォロー状態 (更新後) = " + isFollowed);

        sendResponse(response, success ? "成功" : "失敗");
    }

    private boolean sendFollowRequest(String artistId, String accessToken, String method) throws IOException {
        String urlString = SPOTIFY_API_URL + artistId;
        System.out.println("DEBUG: フォロー/リフォローリクエスト URL = " + urlString);

        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod(method);
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setRequestProperty("Content-Length", "0");  // 411エラー回避
        connection.setDoOutput(true);

        try (OutputStream os = connection.getOutputStream()) {
            os.write(new byte[0]);  // 空のリクエストボディ
            os.flush();
        }

        int responseCode = connection.getResponseCode();
        System.out.println("DEBUG: APIレスポンスコード = " + responseCode);

        return responseCode == 204;
    }

    private boolean isArtistFollowed(String artistId, String accessToken) throws IOException {
        String urlString = "https://api.spotify.com/v1/me/following/contains?type=artist&ids=" + artistId;
        System.out.println("DEBUG: フォロー状態確認 URL = " + urlString);

        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Content-Type", "application/json");

        int responseCode = connection.getResponseCode();
        System.out.println("DEBUG: フォロー状態 API レスポンスコード = " + responseCode);

        if (responseCode != 200) {
            System.out.println("ERROR: フォロー状態の取得に失敗しました。");
            return false;
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8));
        String response = reader.readLine();  // true/false の配列が返る
        reader.close();

        System.out.println("DEBUG: フォロー状態 API レスポンス = " + response);

        return response.contains("true");  // フォロー済みなら true を返す
    }

    private void sendResponse(HttpServletResponse response, String message) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().write("<script>parent.location.reload();</script>");  // 親ページをリロード
    }
}
