package service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

import service.SpotifySearchServlet.JsonToListConverter;

@WebServlet("/SpotifyCheckFollowStatusServlet")
public class SpotifyCheckFollowStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String accessToken = (String) session.getAttribute("access_token");

        if (accessToken == null) {
            request.setAttribute("error", "Spotifyにログインしていません。");
            request.getRequestDispatcher("/WEB-INF/jsp/search.jsp").forward(request, response);
            return;
        }

        String artistId = request.getParameter("artistId");

        if (artistId == null || artistId.isEmpty()) {
            request.setAttribute("error", "アーティストIDが指定されていません。");
            request.getRequestDispatcher("/WEB-INF/jsp/search.jsp").forward(request, response);
            return;
        }

        try {
            // ✅ アーティスト情報を取得
            String artistUrl = "https://api.spotify.com/v1/artists/" + artistId;
            JSONObject artistJson = new JSONObject(sendSpotifyRequest(artistUrl, accessToken));
            Map<String, Object> artist = convertArtistDetails(artistJson);

            // ✅ プレイリスト情報を取得（追加）
            String userPlaylistsUrl = "https://api.spotify.com/v1/me/playlists";
            JSONObject playlistResponse = new JSONObject(sendSpotifyRequest(userPlaylistsUrl, accessToken));
            JSONArray userPlaylistsArray = playlistResponse.optJSONArray("items");
            List<Map<String, Object>> userPlaylists = JsonToListConverter.convertJSONArrayToList(userPlaylistsArray);
            request.setAttribute("userPlaylists", userPlaylists); // 🔹 JSP に渡す
            
            // ✅ 人気曲の取得
            String topTracksUrl = "https://api.spotify.com/v1/artists/" + artistId + "/top-tracks?market=JP";
            JSONObject topTracksResponse = new JSONObject(sendSpotifyRequest(topTracksUrl, accessToken));
            JSONArray topTracksArray = topTracksResponse.optJSONArray("tracks");
            List<Map<String, Object>> topTracks = JsonToListConverter.convertJSONArrayToList(topTracksArray);

            // ✅ アルバム一覧の取得
            String albumsUrl = "https://api.spotify.com/v1/artists/" + artistId + "/albums?include_groups=album&market=JP&limit=10";
            JSONObject albumsResponse = new JSONObject(sendSpotifyRequest(albumsUrl, accessToken));
            JSONArray albumsArray = albumsResponse.optJSONArray("items");
            List<Map<String, Object>> albums = JsonToListConverter.convertJSONArrayToList(albumsArray);

            // ✅ フォロー状態を確認
            boolean isFollowed = isArtistFollowed(artistId, accessToken);

            // JSP にデータを渡す
            request.setAttribute("artist", artist);
            request.setAttribute("top_tracks", topTracks);
            request.setAttribute("albums", albums);
            session.setAttribute("isFollowed", isFollowed);

            // ✅ `searchartist.jsp` に遷移
            request.getRequestDispatcher("/WEB-INF/jsp/searchartist.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "データの取得に失敗しました: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/jsp/search.jsp").forward(request, response);
        }
    }

    private String sendSpotifyRequest(String urlString, String accessToken) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Content-Type", "application/json");

        int responseCode = connection.getResponseCode();
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
        return response.toString();
    }

    private boolean isArtistFollowed(String artistId, String accessToken) throws IOException {
        String urlString = "https://api.spotify.com/v1/me/following/contains?type=artist&ids=" + artistId;
        String response = sendSpotifyRequest(urlString, accessToken);
        return response.contains("true");
    }
    
 // アーティスト情報を Map に変換
    private static Map<String, Object> convertArtistDetails(JSONObject artistJson) {
        Map<String, Object> artist = new HashMap<>();

        artist.put("id", artistJson.optString("id", ""));
        artist.put("name", artistJson.optString("name", "不明なアーティスト"));
        artist.put("followers", artistJson.optJSONObject("followers") != null 
            ? artistJson.optJSONObject("followers").optInt("total", 0) 
            : 0);

        // images の処理
        JSONArray imagesArray = artistJson.optJSONArray("images");
        List<Map<String, Object>> imagesList = new ArrayList<>();
        if (imagesArray != null) {
            for (int i = 0; i < imagesArray.length(); i++) {
                JSONObject imageObject = imagesArray.optJSONObject(i);
                if (imageObject != null) {
                    Map<String, Object> imageMap = new HashMap<>();
                    imageMap.put("url", imageObject.optString("url", "no_image.png"));
                    imagesList.add(imageMap);
                }
            }
        }
        artist.put("images", imagesList);

        return artist;
    }

}
