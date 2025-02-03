package service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
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


@WebServlet("/SpotifySearchServlet")
public class SpotifySearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String SPOTIFY_API_URL = "https://api.spotify.com/v1/search";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String id = request.getParameter("id");
        String query = request.getParameter("query");

        System.out.println("DEBUG: action=" + action + ", id=" + id + ", query=" + query);

        HttpSession session = request.getSession();
        String accessToken = (String) session.getAttribute("access_token");

        if (accessToken == null) {
            request.setAttribute("error", "Spotifyにログインしていません。");
            request.getRequestDispatcher("/WEB-INF/jsp/search.jsp").forward(request, response);
            return;
        }

        try {
            if (query != null && !query.trim().isEmpty()) {
                // ?? Spotify検索を実行
                System.out.println("DEBUG: Spotify検索を実行します - " + query);
                String jsonResponse = searchSpotify(query, accessToken);
                System.out.println("DEBUG: Spotify API Response - " + jsonResponse);

                JSONObject json = new JSONObject(jsonResponse);

                // ?? 各検索結果のデータを取得
                JSONArray artistsArray = json.optJSONObject("artists").optJSONArray("items");
                JSONArray albumsArray = json.optJSONObject("albums").optJSONArray("items");
                JSONArray playlistsArray = json.optJSONObject("playlists").optJSONArray("items");
                JSONArray tracksArray = json.optJSONObject("tracks").optJSONArray("items"); // ?? 曲のデータを取得

                System.out.println("DEBUG: artistsArray = " + artistsArray);
                System.out.println("DEBUG: albumsArray = " + albumsArray);
                System.out.println("DEBUG: playlistsArray = " + playlistsArray);
                System.out.println("DEBUG: tracksArray = " + tracksArray);

                // ?? JSON → List に変換
                List<Map<String, Object>> artistList = JsonToListConverter.convertJSONArrayToList(artistsArray);
                List<Map<String, Object>> albumList = JsonToListConverter.convertJSONArrayToList(albumsArray);
                List<Map<String, Object>> playlistList = JsonToListConverter.convertJSONArrayToList(playlistsArray);
                List<Map<String, Object>> trackList = JsonToListConverter.convertJSONArrayToList(tracksArray); // ?? 曲リストに変換

                System.out.println("DEBUG: 結果データ (tracks) - " + trackList);


             // ?? trackList に画像URLをセットする
             for (Map<String, Object> track : trackList) {
                 JSONObject album = (JSONObject) track.get("album"); // アルバム情報を取得
                 JSONArray imagesArray = (album != null) ? album.optJSONArray("images") : null;

                 String imageUrl = "no_image.png"; // デフォルト画像
                 if (imagesArray != null && imagesArray.length() > 0) {
                     JSONObject firstImage = imagesArray.optJSONObject(0);
                     if (firstImage != null) {
                         imageUrl = firstImage.optString("url", "no_image.png");
                     }
                 }

                 track.put("image", imageUrl); // ?? 画像URLをセット
             }

             // ?? デバッグログで確認
             System.out.println("DEBUG: 修正後の trackList:");
             for (Map<String, Object> track : trackList) {
                 System.out.println("Track: " + track.get("name") + ", Image: " + track.get("image"));
             }
                // ?? JSP にデータを渡す
                request.setAttribute("artists", artistList);
                request.setAttribute("albums", albumList);
                request.setAttribute("playlists", playlistList);
                request.setAttribute("tracks", trackList);
                request.setAttribute("query", query);

                // ?? ユーザーのプレイリストを取得
                String userPlaylistsUrl = "https://api.spotify.com/v1/me/playlists";
                JSONObject playlistResponse = new JSONObject(sendSpotifyRequest(userPlaylistsUrl, accessToken));
                JSONArray userPlaylistsArray = playlistResponse.optJSONArray("items");
                List<Map<String, Object>> userPlaylists = JsonToListConverter.convertJSONArrayToList(userPlaylistsArray);
                request.setAttribute("userPlaylists", userPlaylists);

                // ?? 検索結果をJSPに渡す
                request.getRequestDispatcher("/WEB-INF/jsp/search.jsp").forward(request, response);
            } 
            else if ("playlist".equals(action)) {
                System.out.println("DEBUG: プレイリスト詳細取得 - ID: " + id);
                JSONObject playlist = getSpotifyDetails("playlists", id, accessToken);
                System.out.println("DEBUG: プレイリスト情報 - " + playlist.toString());

                // プレイリスト情報を変換
                Map<String, Object> playlistInfo = convertPlaylistDetails(playlist);

                // トラック情報を変換
                JSONArray tracksArray = playlist.optJSONObject("tracks").optJSONArray("items");
                List<Map<String, Object>> trackList = convertPlaylistTracks(tracksArray);

                // ?? 変換されたデータをリクエストにセット
                request.setAttribute("playlist", playlistInfo);
                request.setAttribute("tracks", trackList);

                request.getRequestDispatcher("/WEB-INF/jsp/searchplaylist.jsp").forward(request, response);
            } 
            else if ("artist".equals(action)) {
                // アーティスト詳細を取得
                System.out.println("DEBUG: アーティスト詳細取得 - ID: " + id);
                JSONObject artistJson = getSpotifyDetails("artists", id, accessToken);
                System.out.println("DEBUG: アーティスト情報 - " + artistJson.toString());

                // JSONObject を Map に変換
                Map<String, Object> artist = convertArtistDetails(artistJson);

                // 人気曲の取得
                String topTracksUrl = "https://api.spotify.com/v1/artists/" + id + "/top-tracks?market=JP";
                JSONObject topTracksResponse = new JSONObject(sendSpotifyRequest(topTracksUrl, accessToken));
                JSONArray topTracksArray = topTracksResponse.optJSONArray("tracks");

                // アルバム一覧の取得
                String albumsUrl = "https://api.spotify.com/v1/artists/" + id + "/albums?include_groups=album&market=JP&limit=10";
                JSONObject albumsResponse = new JSONObject(sendSpotifyRequest(albumsUrl, accessToken));
                JSONArray albumsArray = albumsResponse.optJSONArray("items");

                // JSON を List<Map<String, Object>> に変換
                List<Map<String, Object>> topTracks = JsonToListConverter.convertJSONArrayToList(topTracksArray);
                List<Map<String, Object>> albums = JsonToListConverter.convertJSONArrayToList(albumsArray);

                // JSP にデータを渡す
                request.setAttribute("artist", artist);
                request.setAttribute("top_tracks", topTracks);
                request.setAttribute("albums", albums);

                request.getRequestDispatcher("/WEB-INF/jsp/searchartist.jsp").forward(request, response);
            } 
            else if ("album".equals(action)) {
                // アルバム詳細を取得
                System.out.println("DEBUG: アルバム詳細取得 - ID: " + id);
                JSONObject albumJson = getSpotifyDetails("albums", id, accessToken);
                System.out.println("DEBUG: アルバム情報 - " + albumJson.toString());

                // JSONObject を Map に変換
                Map<String, Object> album = convertAlbumDetails(albumJson);

                // 収録曲の取得
                JSONArray tracksArray = albumJson.optJSONObject("tracks").optJSONArray("items");
                List<Map<String, Object>> tracks = JsonToListConverter.convertJSONArrayToList(tracksArray);

                // JSP にデータを渡す
                request.setAttribute("album", album);
                request.setAttribute("tracks", tracks);

                request.getRequestDispatcher("/WEB-INF/jsp/searchalbum.jsp").forward(request, response);
            } 
            else {
                request.getRequestDispatcher("/WEB-INF/jsp/search.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.out.println("ERROR: 例外が発生しました - " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "エラーが発生しました: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/jsp/search.jsp").forward(request, response);
        }
    }


    // ?? Spotify検索API
    private String searchSpotify(String query, String accessToken) throws IOException {
        String encodedQuery = URLEncoder.encode(query, StandardCharsets.UTF_8.toString());
        String urlString = SPOTIFY_API_URL + "?q=" + encodedQuery + "&type=track,album,artist,playlist&limit=10";
        return sendSpotifyRequest(urlString, accessToken);
    }

    // Spotify詳細取得API
    private JSONObject getSpotifyDetails(String type, String id, String accessToken) throws IOException {
        String urlString = "https://api.spotify.com/v1/" + type + "/" + id;
        String response = sendSpotifyRequest(urlString, accessToken);
        return new JSONObject(response);
    }

    // ?? Spotify API リクエスト送信
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


    public static class JsonToListConverter {
        public static List<Map<String, Object>> convertJSONArrayToList(JSONArray jsonArray) {
            List<Map<String, Object>> list = new ArrayList<>();
            if (jsonArray == null) return list; // nullチェック

            for (int i = 0; i < jsonArray.length(); i++) {
                Object element = jsonArray.get(i);
                if (!(element instanceof JSONObject)) {
                    System.out.println("WARNING: Skipping non-JSONObject element at index " + i + ": " + element);
                    continue; // JSONObject でない場合はスキップ
                }

                JSONObject jsonObject = (JSONObject) element;
                Map<String, Object> map = new HashMap<>();

                for (String key : jsonObject.keySet()) {
                    Object value = jsonObject.get(key);

                    // images フィールドの場合は List<Map<String, Object>> に変換
                    if ("images".equals(key) && value instanceof JSONArray) {
                        map.put(key, convertJSONArrayToList((JSONArray) value));
                    } else {
                        map.put(key, value);
                    }
                }

                list.add(map);
            }
            return list;
        }
    }

    // プレイリストの詳細情報を変換するメソッド
    public static Map<String, Object> convertPlaylistDetails(JSONObject playlist) {
        Map<String, Object> playlistInfo = new HashMap<>();
        if (playlist == null) return playlistInfo;

        playlistInfo.put("name", playlist.optString("name", "不明なプレイリスト"));
        playlistInfo.put("owner", playlist.optJSONObject("owner") != null ? playlist.optJSONObject("owner").optString("display_name", "不明な作成者") : "不明な作成者");

        // images の処理
        JSONArray imagesArray = playlist.optJSONArray("images");
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
        playlistInfo.put("images", imagesList);

        return playlistInfo;
    }

    // プレイリストのトラック情報を変換するメソッド
 // プレイリストのトラック情報を変換するメソッド
    public static List<Map<String, Object>> convertPlaylistTracks(JSONArray tracksArray) {
        List<Map<String, Object>> trackList = new ArrayList<>();
        if (tracksArray == null) return trackList; // nullチェック

        for (int i = 0; i < tracksArray.length(); i++) {
            JSONObject trackObject = tracksArray.optJSONObject(i);
            if (trackObject == null || !trackObject.has("track")) continue;

            JSONObject track = trackObject.getJSONObject("track");
            Map<String, Object> trackInfo = new HashMap<>();
            trackInfo.put("name", track.optString("name", "不明なトラック"));
            trackInfo.put("track_number", track.optInt("track_number", 0));
            trackInfo.put("id", track.optString("id", "unknown_id"));

            // 🔹 **アルバム画像の取得**
            JSONObject album = track.optJSONObject("album");
            JSONArray imagesArray = (album != null) ? album.optJSONArray("images") : null;

            String imageUrl = "no_image.png"; // デフォルト画像
            if (imagesArray != null && imagesArray.length() > 0) {
                imageUrl = imagesArray.getJSONObject(0).optString("url", "no_image.png");
            }

            // 🔹 **デバッグログ追加**
            System.out.println("DEBUG: Track - Name: " + track.optString("name", "Unknown") + 
                               ", Album: " + (album != null ? album.optString("name", "Unknown Album") : "No Album") + 
                               ", Image: " + imageUrl);

            trackInfo.put("image", imageUrl);
            trackList.add(trackInfo);
        }
        return trackList;
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
    
 // アルバム情報を Map に変換
    private static Map<String, Object> convertAlbumDetails(JSONObject albumJson) {
        Map<String, Object> album = new HashMap<>();
        
        album.put("id", albumJson.optString("id", ""));
        album.put("name", albumJson.optString("name", "不明なアルバム"));
        album.put("release_date", albumJson.optString("release_date", "不明な日付"));

        // images の処理
        JSONArray imagesArray = albumJson.optJSONArray("images");
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
        album.put("images", imagesList);

        return album;
    }


}




