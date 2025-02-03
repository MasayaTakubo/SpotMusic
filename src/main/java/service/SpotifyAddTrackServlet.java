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

import org.json.JSONObject;

@WebServlet("/SpotifyAddTrackServlet")
public class SpotifyAddTrackServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String SPOTIFY_API_URL = "https://api.spotify.com/v1/playlists";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String accessToken = (String) session.getAttribute("access_token");

        if (accessToken == null) {
            System.out.println("ERROR: アクセストークンが null です。ログインしてください。");
            response.getWriter().write("<script>parent.alert('Spotify にログインしてください。');</script>");
            return;
        }

        String playlistId = request.getParameter("playlistId");
        String trackId = request.getParameter("trackId");

        System.out.println("DEBUG: 受け取ったプレイリストID = " + playlistId);
        System.out.println("DEBUG: 受け取ったトラックID = " + trackId);

        if (playlistId == null || trackId == null || playlistId.isEmpty() || trackId.isEmpty()) {
            System.out.println("ERROR: プレイリストID または トラックID が不足しています。");
            response.getWriter().write("<script>parent.alert('プレイリストIDまたはトラックIDが不足しています。');</script>");
            return;
        }
        
        // ?? プレイリストのオーナーを確認
        String playlistOwner = getPlaylistOwner(playlistId, accessToken);
        String currentUserId = getCurrentUserId(accessToken);

        System.out.println("DEBUG: プレイリストのオーナーID = " + playlistOwner);
        System.out.println("DEBUG: 現在のユーザーID = " + currentUserId);

        if (!playlistOwner.equals(currentUserId)) {
            System.out.println("ERROR: このプレイリストは現在のユーザーが作成したものではありません。");
            response.getWriter().write("<script>parent.alert('このプレイリストには曲を追加できません (オーナー権限なし)。');</script>");
            return;
        }

        boolean success = addTrackToPlaylist(playlistId, trackId, accessToken);

        System.out.println("DEBUG: APIリクエスト完了 - 成功: " + success);

        // ?? 結果を JavaScript で親ページに通知
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().write("<script>parent.alert('" + (success ? "追加成功！" : "追加に失敗しました。") + "');</script>");
    }

    private boolean addTrackToPlaylist(String playlistId, String trackId, String accessToken) throws IOException {
        String urlString = SPOTIFY_API_URL + "/" + playlistId + "/tracks";
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();

        connection.setRequestMethod("POST");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setDoOutput(true);

        String jsonBody = "{\"uris\": [\"spotify:track:" + trackId + "\"]}";

        System.out.println("DEBUG: 送信URL = " + urlString);
        System.out.println("DEBUG: 送信JSON = " + jsonBody);

        try (OutputStream os = connection.getOutputStream()) {
            byte[] input = jsonBody.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }

        int responseCode = connection.getResponseCode();
        System.out.println("DEBUG: APIレスポンスコード = " + responseCode);

        if (responseCode != 201) {
            System.out.println("ERROR: APIリクエスト失敗 - HTTP " + responseCode);
            return false;
        }

        return true;
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
            throw new IOException("Spotify API Error: HTTP " + responseCode);
        }

        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8));
        StringBuilder response = new StringBuilder();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        System.out.println("DEBUG: Spotify API Response Body - " + response.toString());

        return response.toString();
    }

    // ?? プレイリストのオーナーを取得
    private String getPlaylistOwner(String playlistId, String accessToken) throws IOException {
        String urlString = "https://api.spotify.com/v1/playlists/" + playlistId;
        String response = sendSpotifyRequest(urlString, accessToken);
        JSONObject json = new JSONObject(response);
        return json.getJSONObject("owner").getString("id");
    }

    // ?? 現在のユーザーの ID を取得
    private String getCurrentUserId(String accessToken) throws IOException {
        String urlString = "https://api.spotify.com/v1/me";
        String response = sendSpotifyRequest(urlString, accessToken);
        JSONObject json = new JSONObject(response);
        return json.getString("id");
    }
}
