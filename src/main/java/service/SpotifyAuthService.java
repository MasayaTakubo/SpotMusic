package service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.entity.UrlEncodedFormEntity;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import bean.SpotifyPlayListBean;
import dao.PlayListDAO;
import dao.UsersDAO;

public class SpotifyAuthService {

    static final String CLIENT_ID = "277b350dfbe146e8b5b48171bc6ceaed";
    private static final String CLIENT_SECRET = "5cdda2ff3df040de9b8ba8cbf0122885";
    static final String REDIRECT_URI = "http://localhost:8080/SpotMusic/auth";
    private static final String TOKEN_URL = "https://accounts.spotify.com/api/token";
    private UsersDAO userDAO = new UsersDAO();
    private PlayListDAO playListDAO = new PlayListDAO();
    // HTTPクライアントのインスタンスをフィールドとして定義
    private static final CloseableHttpClient httpClient = HttpClients.createDefault();
    // アクセストークンを取得する処理
    public static String getAccessToken(String authorizationCode) throws IOException {

        HttpPost httpPost = new HttpPost(TOKEN_URL);

        String auth = CLIENT_ID + ":" + CLIENT_SECRET;
        String encodedAuth = java.util.Base64.getEncoder().encodeToString(auth.getBytes(StandardCharsets.UTF_8));
        httpPost.setHeader("Authorization", "Basic " + encodedAuth);

        List<BasicNameValuePair> params = new ArrayList<>();
        params.add(new BasicNameValuePair("grant_type", "authorization_code"));
        params.add(new BasicNameValuePair("code", authorizationCode));  // 認証コード
        params.add(new BasicNameValuePair("redirect_uri", REDIRECT_URI)); // リダイレクトURI
        httpPost.setEntity(new UrlEncodedFormEntity(params));

        try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
            int statusCode = response.getCode();
            String jsonResponse = new String(response.getEntity().getContent().readAllBytes(), StandardCharsets.UTF_8);

            if (statusCode == 200) {
                JSONObject json = new JSONObject(jsonResponse);
                return json.getString("access_token");  // アクセストークンを返す
            } else {
                throw new IOException("HTTP Error: " + statusCode + ", Response: " + jsonResponse);
            }
        }
    }

    public String getUserId(String accessToken) throws IOException {
        // アクセストークンを使ってSpotifyからユーザー情報を取得
        URL url = new URL("https://api.spotify.com/v1/me");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        System.out.println("ここまで来ています。");
        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        String inputLine;
        StringBuilder response = new StringBuilder();
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        JSONObject jsonResponse = new JSONObject(response.toString());
        System.out.println("Service::" + jsonResponse);
        return jsonResponse.getString("id"); // ユーザーIDを返す
    }

    // ユーザー情報をデータベースに保存する処理
    public void saveUser(String userId, String accessToken, String refreshToken, int expiresIn) throws Exception {
        userDAO.saveUser(userId, accessToken, refreshToken, expiresIn);
    }

    public void saveUserPlaylists(String accessToken, String userId) throws Exception {
        // Spotify APIを使ってプレイリスト情報を取得
        JSONObject playlists = getSpotifyPlaylists(accessToken);  // プレイリスト情報を取得

        // プレイリストの情報を1つずつ処理
        if (playlists.has("items")) {  // "items"が存在するか確認
            JSONArray items = playlists.getJSONArray("items");
            for (int i = 0; i < items.length(); i++) {
                JSONObject playlist = items.getJSONObject(i);

                // Beanに変換
                SpotifyPlayListBean playListBean = new SpotifyPlayListBean(playlist, userId);

                // プレイリストIDとユーザーIDをデータベースに保存
                playListDAO.savePlaylistReview(playListBean.getPlaylistId(), playListBean.getUserId());

                // ここでプレイリスト名やトラック情報はBean内に保持
                System.out.println("プレイリスト名: " + playListBean.getPlaylistName());
                System.out.println("トラック名: " + String.join(", ", playListBean.getTrackNames()));
            }
        } else {
            System.out.println("プレイリストが存在しません");
        }
    }



    public JSONObject getSpotifyPlaylists(String accessToken) throws Exception {
        // Spotifyのプレイリスト情報を取得するURL
        URL url = new URL("https://api.spotify.com/v1/me/playlists");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);

        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        String inputLine;
        StringBuilder response = new StringBuilder();
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        // レスポンスをJSONObjectに変換して返す
        return new JSONObject(response.toString());
    }
    
    
    
    public List<Map<String, Object>> convertJsonArrayToList(JSONArray jsonArray) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObject = jsonArray.getJSONObject(i);
            Map<String, Object> map = new HashMap<>();
            for (String key : jsonObject.keySet()) {
                map.put(key, jsonObject.get(key));
            }
            list.add(map);
        }
        return list;
    }
    
    public JSONObject getFollowedArtists(String accessToken) throws Exception {
        // Spotifyのフォロー中アーティスト情報を取得するURL
        URL url = new URL("https://api.spotify.com/v1/me/following?type=artist");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Accept-Language", "ja");
        
        // レスポンスを読み込む
        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        String inputLine;
        StringBuilder response = new StringBuilder();
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        // レスポンスをJSONObjectに変換して返す
        return new JSONObject(response.toString());
    }
    //track情報を取得
    public JSONObject getPlaylistTracks(String accessToken, String playlistId) throws Exception {
        // Spotifyのプレイリスト内のトラック情報を取得するURL
        URL url = new URL("https://api.spotify.com/v1/playlists/" + playlistId + "/tracks");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);

        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        String inputLine;
        StringBuilder response = new StringBuilder();
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        // レスポンスをJSONObjectに変換して返す
        return new JSONObject(response.toString());
    }

    
    //全てのtrack情報を取得する。
    public List<JSONObject> getAllPlaylistTracks(String accessToken, String playlistId) throws Exception {
        List<JSONObject> allTracks = new ArrayList<>();
        String nextUrl = "https://api.spotify.com/v1/playlists/" + playlistId + "/tracks";

        while (nextUrl != null) {
            URL url = new URL(nextUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Authorization", "Bearer " + accessToken);

            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            StringBuilder response = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();

            JSONObject responseJson = new JSONObject(response.toString());
            JSONArray items = responseJson.getJSONArray("items");
            for (int i = 0; i < items.length(); i++) {
                allTracks.add(items.getJSONObject(i));
            }

            // 次のページがある場合、URLを取得
            nextUrl = responseJson.optString("next", null);
        }

        return allTracks;
    }
    
    public void playTrack(String accessToken, String trackUri) throws Exception {
        if (accessToken == null || accessToken.isEmpty()) {
            throw new IllegalArgumentException("アクセストークンが指定されていません");
        }
        if (trackUri == null || trackUri.isEmpty()) {
            throw new IllegalArgumentException("トラック URI が指定されていません");
        }

        URL url = new URL("https://api.spotify.com/v1/me/player/play");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("PUT");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        String jsonPayload = "{\"uris\": [\"" + trackUri + "\"]}";
        System.out.println("送信する JSON ペイロード: " + jsonPayload); // デバッグ用

        try (OutputStream os = conn.getOutputStream()) {
            os.write(jsonPayload.getBytes(StandardCharsets.UTF_8));
        }

        int responseCode = conn.getResponseCode();
        if (responseCode != HttpURLConnection.HTTP_NO_CONTENT) {
            String errorResponse = new BufferedReader(new InputStreamReader(conn.getErrorStream()))
                .lines().reduce("", String::concat);
            throw new IOException("Spotify API エラー: HTTP " + responseCode + " - " + errorResponse);
        }
    }


    public static String refreshAccessToken(String refreshToken) throws IOException {
        HttpPost httpPost = new HttpPost(TOKEN_URL);

        String auth = CLIENT_ID + ":" + CLIENT_SECRET;
        String encodedAuth = java.util.Base64.getEncoder().encodeToString(auth.getBytes(StandardCharsets.UTF_8));
        httpPost.setHeader("Authorization", "Basic " + encodedAuth);

        List<BasicNameValuePair> params = new ArrayList<>();
        params.add(new BasicNameValuePair("grant_type", "refresh_token"));
        params.add(new BasicNameValuePair("refresh_token", refreshToken));  
        httpPost.setEntity(new UrlEncodedFormEntity(params));

        try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
            int statusCode = response.getCode();
            String jsonResponse = new String(response.getEntity().getContent().readAllBytes(), StandardCharsets.UTF_8);

            if (statusCode == 200) {
                JSONObject json = new JSONObject(jsonResponse);
                return json.getString("access_token");
            } else {
                throw new IOException("HTTP Error: " + statusCode + ", Response: " + jsonResponse);
            }
        }
    }

    public Map<String, String> getRefreshToken(String authorizationCode) throws IOException {
        HttpPost httpPost = new HttpPost(TOKEN_URL);

        String auth = CLIENT_ID + ":" + CLIENT_SECRET;
        String encodedAuth = java.util.Base64.getEncoder().encodeToString(auth.getBytes(StandardCharsets.UTF_8));
        httpPost.setHeader("Authorization", "Basic " + encodedAuth);

        List<BasicNameValuePair> params = new ArrayList<>();
        params.add(new BasicNameValuePair("grant_type", "authorization_code"));
        params.add(new BasicNameValuePair("code", authorizationCode));
        params.add(new BasicNameValuePair("redirect_uri", REDIRECT_URI));
        httpPost.setEntity(new UrlEncodedFormEntity(params, StandardCharsets.UTF_8));

        try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
            int statusCode = response.getCode();
            String jsonResponse = new String(response.getEntity().getContent().readAllBytes(), StandardCharsets.UTF_8);

            if (statusCode == 200) {
                JSONObject json = new JSONObject(jsonResponse);
                Map<String, String> tokens = new HashMap<>();
                tokens.put("access_token", json.getString("access_token"));
                if (json.has("refresh_token")) {
                    tokens.put("refresh_token", json.getString("refresh_token"));
                }
                return tokens;
            } else {
                throw new IOException("Spotify APIエラー: HTTP " + statusCode + " - " + jsonResponse);
            }
        }
    }
    public void setupDevice(String accessToken, String deviceId) throws IOException {
        URL url = new URL("https://api.spotify.com/v1/me/player");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("PUT");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        String jsonPayload = String.format("{\"device_ids\": [\"%s\"], \"play\": false}", deviceId);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(jsonPayload.getBytes(StandardCharsets.UTF_8));
        }

        int responseCode = conn.getResponseCode();
        if (responseCode != HttpURLConnection.HTTP_NO_CONTENT) {
            throw new IOException("Device setup failed with HTTP code " + responseCode);
        }
    }

    public void pausePlayback(String accessToken) throws IOException {
        URL url = new URL("https://api.spotify.com/v1/me/player/pause");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("PUT");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);

        int responseCode = conn.getResponseCode();
        if (responseCode != HttpURLConnection.HTTP_NO_CONTENT) {
            throw new IOException("Pause playback failed with HTTP code " + responseCode);
        }
    }
    
    
    public List<String> getArtistNames(String accessToken, int limit) throws IOException {
        // アクセストークンを使ってSpotifyからフォローしているアーティストの情報を取得
        URL url = new URL("https://api.spotify.com/v1/me/following?type=artist&limit=" + limit);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        System.out.println("リクエスト送信中...");

        // ステータスコードを確認
        int responseCode = connection.getResponseCode();
        if (responseCode != 200) {
            throw new IOException("Failed to get artist data: HTTP code " + responseCode);
        }

        // レスポンスを読み取る
        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        StringBuilder response = new StringBuilder();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        // JSONを解析してアーティスト名を取得する
        return extractArtistNames(response.toString());
    }

    private List<String> extractArtistNames(String jsonResponse) {
        List<String> artistNames = new ArrayList<>();
        try {
            // JSONレスポンスを解析する
            JSONObject jsonObject = new JSONObject(jsonResponse);

            // artistsオブジェクトが存在するか確認
            if (jsonObject.has("artists")) {
                JSONObject artists = jsonObject.getJSONObject("artists");

                // "items" 配列を取得
                if (artists.has("items")) {
                    JSONArray itemsArray = artists.getJSONArray("items");

                    // 各アーティスト名をリストに追加
                    for (int i = 0; i < itemsArray.length(); i++) {
                        JSONObject artist = itemsArray.getJSONObject(i);
                        String artistName = artist.getString("name");
                        System.out.println("アーティスト名：" + artistName);
                        artistNames.add(artistName);
                    }
                } else {
                    System.out.println("items 配列が見つかりませんでした");
                }
            } else {
                System.out.println("artists オブジェクトが見つかりませんでした");
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return artistNames;
    }

    
    
    
    
    
    
    
    public List<String> getArtistIds(String accessToken, int limit) throws IOException {
        // アクセストークンを使ってSpotifyからフォローしているアーティスト情報を取得
        URL url = new URL("https://api.spotify.com/v1/me/following?type=artist&limit=" + limit);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        System.out.println("リクエスト送信中...");

        // ステータスコードを確認
        int responseCode = connection.getResponseCode();
        if (responseCode != 200) {
            throw new IOException("Failed to get artist data: HTTP code " + responseCode);
        }

        // レスポンスを読み取る
        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        StringBuilder response = new StringBuilder();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        // JSONを解析してアーティストIDを取得する
        return extractArtistIds(response.toString());
    }

    /**
     * JSONレスポンスからアーティストIDのリストを抽出するメソッド
     */
    private List<String> extractArtistIds(String jsonResponseString) {
        List<String> artistIds = new ArrayList<>();

        try {
            // JSONレスポンスをパース
            JSONObject jsonResponse = new JSONObject(jsonResponseString);
            if (jsonResponse.has("artists")) {
                JSONObject artistsObject = jsonResponse.getJSONObject("artists");
                JSONArray items = artistsObject.getJSONArray("items");

                // 各アーティストIDをリストに追加
                for (int i = 0; i < items.length(); i++) {
                    JSONObject artist = items.getJSONObject(i);
                    artistIds.add(artist.getString("id"));
                }
            }
        } catch (Exception e) {
            System.err.println("JSON解析中にエラーが発生しました: " + e.getMessage());
        }

        return artistIds;
    }

    
 // アーティストの詳細情報を取得
    public JSONObject getArtistDetails(String accessToken, String artistId) throws Exception {
        String url = "https://api.spotify.com/v1/artists/" + artistId;
        return sendGetRequest(accessToken, url);
    }

    // アーティストの人気曲を取得
    public JSONArray getArtistTopTracks(String accessToken, String artistId) throws Exception {
        String url = "https://api.spotify.com/v1/artists/" + artistId + "/top-tracks?market=US";
        JSONObject response = sendGetRequest(accessToken, url);
        return response.getJSONArray("tracks");
    }

    // アーティストのプレイリスト(アルバム？)を取得
    //もしかしたらplaylistでエンドポイントが違ったのでアルバムかもしれないです。
    public JSONArray getArtistPlaylists(String accessToken, String artistId) throws Exception {
    	String url = "https://api.spotify.com/v1/artists/" + artistId + "/albums";
        JSONObject response = sendGetRequest(accessToken, url);
        return response.getJSONArray("items");
    }
    
    //アーティストに紐づいたアルバムの中のtrackを取得
    public List<JSONObject> getAllAlbumTracks(String accessToken, String albumId) throws Exception {
        List<JSONObject> allTracks = new ArrayList<>();
        String nextUrl = "https://api.spotify.com/v1/albums/" + albumId + "/tracks";

        while (nextUrl != null) {
            URL url = new URL(nextUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Authorization", "Bearer " + accessToken);

            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            StringBuilder response = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();

            JSONObject responseJson = new JSONObject(response.toString());
            JSONArray items = responseJson.getJSONArray("items");
            for (int i = 0; i < items.length(); i++) {
                allTracks.add(items.getJSONObject(i));
            }

            // 次のページがある場合、URLを取得
            nextUrl = responseJson.optString("next", null);
        }

        return allTracks;
    }

    
    
    


    // 汎用的なGETリクエストを送信するメソッド
    private JSONObject sendGetRequest(String accessToken, String urlString) throws Exception {
        HttpURLConnection connection = null;
        try {
            URL url = new URL(urlString);
            connection = (HttpURLConnection) url.openConnection();

            // HTTPリクエストの設定
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Authorization", "Bearer " + accessToken);
            connection.setRequestProperty("Content-Type", "application/json");

            // ステータスコードを取得
            int responseCode = connection.getResponseCode();

            // ストリームを取得
            InputStream inputStream;
            if (responseCode >= 200 && responseCode < 300) {
                inputStream = connection.getInputStream(); // 正常なレスポンス
            } else {
                inputStream = connection.getErrorStream(); // エラーレスポンス
                if (inputStream == null) {
                    throw new RuntimeException("HTTPエラーコード: " + responseCode + "、エラーストリームが存在しません。");
                }
            }

            // レスポンスを読み取る
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
                StringBuilder responseBuilder = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    responseBuilder.append(line);
                }
                return new JSONObject(responseBuilder.toString());
            }
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

}
