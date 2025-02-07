package command;

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

import org.json.JSONObject;

@WebServlet("/SpotifyCreatePlaylistServlet")
public class SpotifyCreatePlaylistCommand extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String SPOTIFY_API_URL = "https://api.spotify.com/v1/users/";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String accessToken = (String) session.getAttribute("access_token");

        if (accessToken == null) {
            System.out.println("ERROR: アクセストークンが null です。ログインしてください。");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<script>parent.alert('Spotify にログインしてください。');</script>");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String playlistName = request.getParameter("playlistName");

        System.out.println("DEBUG: 受け取ったプレイリスト名 = " + playlistName);

        if (playlistName == null || playlistName.isEmpty()) {
            System.out.println("ERROR: プレイリスト名が空です。");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<script>parent.alert('プレイリスト名を入力してください。');</script>");
            return;
        }

        String userId = getCurrentUserId(accessToken);
        if (userId == null) {
            System.out.println("ERROR: ユーザー情報の取得に失敗しました。");
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<script>parent.alert('ユーザー情報の取得に失敗しました。');</script>");
            return;
        }
        System.out.println("DEBUG: 現在のユーザーID = " + userId);

        boolean success = createPlaylist(userId, playlistName, accessToken);
        System.out.println("DEBUG: プレイリスト作成結果 = " + success);

        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().write("<script>parent.location.reload();</script>");
    }


    private boolean createPlaylist(String userId, String playlistName, String accessToken) throws IOException {
        String urlString = SPOTIFY_API_URL + userId + "/playlists";
        System.out.println("DEBUG: プレイリスト作成リクエスト URL = " + urlString);
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();

        connection.setRequestMethod("POST");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setDoOutput(true);

        String jsonBody = "{\"name\":\"" + playlistName + "\", \"public\":false}";
        System.out.println("DEBUG: 送信 JSON = " + jsonBody);

        try (OutputStream os = connection.getOutputStream()) {
            byte[] input = jsonBody.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }

        int responseCode = connection.getResponseCode();
        System.out.println("DEBUG: APIレスポンスコード = " + responseCode);

        if (responseCode != 201) {
            BufferedReader errorReader = new BufferedReader(new InputStreamReader(connection.getErrorStream(), StandardCharsets.UTF_8));
            StringBuilder errorResponse = new StringBuilder();
            String inputLine;
            while ((inputLine = errorReader.readLine()) != null) {
                errorResponse.append(inputLine);
            }
            errorReader.close();
            System.out.println("ERROR: APIエラーレスポンス = " + errorResponse.toString());
            return false;
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8));
        StringBuilder response = new StringBuilder();
        String inputLine;
        while ((inputLine = reader.readLine()) != null) {
            response.append(inputLine);
        }
        reader.close();
        System.out.println("DEBUG: APIレスポンスボディ = " + response.toString());

        return true;
    }

    private String getCurrentUserId(String accessToken) throws IOException {
        String urlString = "https://api.spotify.com/v1/me";
        System.out.println("DEBUG: ユーザー情報取得 URL = " + urlString);
        String response = sendSpotifyRequest(urlString, accessToken);
        System.out.println("DEBUG: ユーザー情報レスポンス = " + response);
        JSONObject json = new JSONObject(response);
        return json.getString("id");
    }

    private String sendSpotifyRequest(String urlString, String accessToken) throws IOException {
        System.out.println("DEBUG: Spotify API リクエスト - " + urlString);
        
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Content-Type", "application/json");

        int responseCode = connection.getResponseCode();
        System.out.println("DEBUG: Spotify API Response Code - " + responseCode);

        if (responseCode != 200) {
            BufferedReader errorReader = new BufferedReader(new InputStreamReader(connection.getErrorStream(), StandardCharsets.UTF_8));
            StringBuilder errorResponse = new StringBuilder();
            String inputLine;
            while ((inputLine = errorReader.readLine()) != null) {
                errorResponse.append(inputLine);
            }
            errorReader.close();
            System.out.println("ERROR: Spotify APIエラーレスポンス = " + errorResponse.toString());
            throw new IOException("Spotify API Error: HTTP " + responseCode);
        }

        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8));
        StringBuilder response = new StringBuilder();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        return response.toString();
    }
}
