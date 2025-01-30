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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

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
    public void saveUser(String userId, String accessToken, String refreshToken, int expiresIn, String userName) throws Exception {
        userDAO.saveUser(userId, accessToken, refreshToken, expiresIn, userName);
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


    //自分の登録しているプレイリストを取得？
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
    
    
    //ユーザーがフォローしているアーティストを取得
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
    
    public void playTrack(HttpSession session, String accessToken, String trackUri) throws Exception {
        if (accessToken == null || accessToken.isEmpty()) {
            throw new IllegalArgumentException("アクセストークンが指定されていません");
        }
        if (trackUri == null || trackUri.isEmpty()) {
            throw new IllegalArgumentException("トラック URI が指定されていません");
        }

        // セッションからシャッフル状態を取得し、安全に処理
        Object shuffleStateObj = session.getAttribute("shuffle");
        boolean shuffleState = false;

        if (shuffleStateObj instanceof Boolean) {
            shuffleState = (Boolean) shuffleStateObj;
        } else if (shuffleStateObj instanceof String) {
            shuffleState = Boolean.parseBoolean((String) shuffleStateObj);
        }

        String endpoint = "https://api.spotify.com/v1/me/player/shuffle?state=" + shuffleState;
        sendPutRequest(endpoint, accessToken);

        URL url = new URL("https://api.spotify.com/v1/me/player/play");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("PUT");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        String jsonPayload = "{\"uris\": [\"" + trackUri + "\"]}";
        try (OutputStream os = conn.getOutputStream()) {
            os.write(jsonPayload.getBytes(StandardCharsets.UTF_8));
        }

        int responseCode = conn.getResponseCode();
        if (responseCode != HttpURLConnection.HTTP_NO_CONTENT) {
            throw new IOException("Spotify API エラー: HTTP " + responseCode);
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
    
	/*//アーティストに紐づいたアルバムの中のtrackを取得
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
	*/
    
    
    
    public JSONArray getAllAlbumTracks(String accessToken, String albumId) throws Exception {
        JSONArray allTracks = new JSONArray();  // 変更：JSONArrayに変更
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
                allTracks.put(items.getJSONObject(i));  // 変更：JSONArrayに追加
            }

            // デバッグ用に最初の3件を出力
            System.out.println("取得データ（最大3件）:");
            for (int i = 0; i < Math.min(3, items.length()); i++) {
                System.out.println(items.getJSONObject(i).toString(2)); // 2スペースのインデントで整形
            }

            // 次のページがある場合、URLを取得
            nextUrl = responseJson.optString("next", null);
        }

        return allTracks;  // 変更：JSONArrayを返す
    }

	
    
    
    public JSONObject getAlbumDetails(String accessToken, String albumId) throws Exception {
        // アルバム詳細情報を格納するJSONObject
        JSONObject albumDetails = new JSONObject();
        
        // アルバム詳細情報の取得URL
        String albumDetailsUrl = "https://api.spotify.com/v1/albums/" + albumId;

        // APIリクエストを送信してレスポンスを取得
        URL url = new URL(albumDetailsUrl);
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

        // レスポンスJSONをパース
        JSONObject responseJson = new JSONObject(response.toString());

        // アルバム情報を抽出
        albumDetails.put("albumName", responseJson.getString("name"));
        albumDetails.put("albumReleaseDate", responseJson.getString("release_date"));
        
        // 画像データの取得
        JSONArray images = responseJson.getJSONArray("images");
        if (images.length() > 0) {
            // 最初の画像URLを使用
            String imageUrl = images.getJSONObject(0).getString("url");
            albumDetails.put("albumImageUrl", imageUrl);
        }

        return albumDetails;
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
    
    
    
    public Map<String, String> getRecentlyPlayedTrackNamesAndIds(String accessToken, int limit) throws IOException {
        // Spotify APIのエンドポイントURL
        URL url = new URL("https://api.spotify.com/v1/me/player/recently-played?limit=" + limit);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);

        // ステータスコードを確認
        int responseCode = connection.getResponseCode();
        if (responseCode != 200) {
            throw new IOException("Failed to get recently played tracks: HTTP code " + responseCode);
        }

        // レスポンスを読み取る
        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        StringBuilder response = new StringBuilder();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        // デバッグ用：取得したJSONレスポンスを出力
        System.out.println("Recently Played JSON Response: " + response.toString());

        // JSONからトラック名とIDを抽出
        Map<String, String> trackData = extractTrackNamesAndIds(response.toString());

        // デバッグ用：抽出したデータを出力
        trackData.forEach((key, value) -> System.out.println("Track Name: " + key + ", Track ID: " + value));

        return trackData;
    }

    // TopMixの中の曲を取得
    public Map<String, String> getTopMixTracks(String accessToken, int limit) throws IOException {
        // Spotify APIのエンドポイントURL
        URL url = new URL("https://api.spotify.com/v1/me/top/tracks?limit=" + limit);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);

        // ステータスコードを確認
        int responseCode = connection.getResponseCode();
        if (responseCode != 200) {
            throw new IOException("Failed to get TopMix tracks: HTTP code " + responseCode);
        }

        // レスポンスを読み取る
        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        StringBuilder response = new StringBuilder();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        // デバッグ用：取得したJSONレスポンスを出力
        System.out.println("TopMix JSON Response: " + response.toString());

        // JSONからトラック名とIDを抽出
        Map<String, String> trackData = extractTrackNamesAndIds(response.toString());

        // デバッグ用：抽出したデータを出力
        trackData.forEach((key, value) -> System.out.println("Track Name: " + key + ", Track ID: " + value));

        return trackData;
    }

    // 再生履歴に基づくおすすめ曲取得
    public Map<String, String> getRecommendedTracks(String accessToken, int limit) throws IOException {
        // Spotify APIのエンドポイントURL
        URL url = new URL("https://api.spotify.com/v1/recommendations?limit=" + limit);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);

        // ステータスコードを確認
        int responseCode = connection.getResponseCode();
        if (responseCode != 200) {
            throw new IOException("Failed to get recommended tracks: HTTP code " + responseCode);
        }

        // レスポンスを読み取る
        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        StringBuilder response = new StringBuilder();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        // デバッグ用：取得したJSONレスポンスを出力
        System.out.println("Recommended Tracks JSON Response: " + response.toString());

        // JSONからトラック名とIDを抽出
        Map<String, String> trackData = extractTrackNamesAndIds(response.toString());

        // デバッグ用：抽出したデータを出力
        trackData.forEach((key, value) -> System.out.println("Track Name: " + key + ", Track ID: " + value));

        return trackData;
    }

    /**
     * JSONレスポンスからトラック名とIDを抽出するメソッド
     */
    private Map<String, String> extractTrackNamesAndIds(String jsonResponseString) {
        Map<String, String> trackNamesAndIds = new LinkedHashMap<>();

        try {
            // JSONレスポンスを解析
            JSONObject jsonResponse = new JSONObject(jsonResponseString);

            // "items"が存在するか確認
            if (jsonResponse.has("items")) {
                JSONArray items = jsonResponse.getJSONArray("items");

                // 各トラックの名前とIDをマップに追加
                for (int i = 0; i < items.length(); i++) {
                    JSONObject item = items.getJSONObject(i);

                    // "track"が存在しない場合もIDと名前を取得する
                    if (item.has("track")) {
                        JSONObject trackObject = item.getJSONObject("track");
                        String trackName = trackObject.getString("name");
                        String trackId = trackObject.getString("id");
                        trackNamesAndIds.put(trackName, trackId);
                    } else if (item.has("name") && item.has("id")) {
                        // "track"がない場合でも直接"items"内の"name"と"id"を取得
                        String trackName = item.getString("name");
                        String trackId = item.getString("id");
                        trackNamesAndIds.put(trackName, trackId);
                    } else {
                        System.err.println("Warning: 'track' or 'name' and 'id' not found in item: " + item.toString());
                    }
                }
            } else {
                // "items"が存在しない場合の警告
                System.err.println("Warning: 'items' not found in response.");
            }
        } catch (Exception e) {
            System.err.println("JSON解析中にエラーが発生しました: " + e.getMessage());
        }

        // デバッグ用：抽出結果を出力
        trackNamesAndIds.forEach((key, value) -> System.out.println("Extracted Track Name: " + key + ", Track ID: " + value));

        return trackNamesAndIds;
    }

    private void sendPutRequest(String urlString, String accessToken) throws IOException {
        HttpURLConnection connection = null;
        try {
            URL url = new URL(urlString);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("PUT");
            connection.setRequestProperty("Authorization", "Bearer " + accessToken);
            connection.setRequestProperty("Content-Type", "application/json");
            
            // 空のリクエストボディを送信して Content-Length をセット
            connection.setDoOutput(true);
            String jsonPayload = "{}";  // 空のJSONボディ
            byte[] outputBytes = jsonPayload.getBytes(StandardCharsets.UTF_8);
            connection.setRequestProperty("Content-Length", String.valueOf(outputBytes.length));

            try (OutputStream os = connection.getOutputStream()) {
                os.write(outputBytes);
            }

            int responseCode = connection.getResponseCode();
            System.out.println("Spotify API PUT response code: " + responseCode);

            if (responseCode == HttpURLConnection.HTTP_NO_CONTENT) {
                System.out.println("Spotify API PUT success (No Content)");
                return;  // 204レスポンスの場合、ストリームは存在しないためここで処理を終了
            }

            // エラーハンドリング: レスポンスコードが204以外のときに処理
            InputStream errorStream = connection.getErrorStream();
            if (errorStream != null) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(errorStream));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                reader.close();
                throw new IOException("Spotify APIエラー: HTTP " + responseCode + " - " + response.toString());
            }
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }




    public void setRepeatMode(String accessToken, String state) throws IOException {
        String endpoint = "https://api.spotify.com/v1/me/player/repeat?state=" + state;
        sendPutRequest(endpoint, accessToken);
    }

    
    
    public void seekPlayback(String accessToken, String positionMs) throws IOException {
        String endpoint = "https://api.spotify.com/v1/me/player/seek?position_ms=" + positionMs;
        sendPutRequest(endpoint, accessToken);
    }
    
    public String getPlaybackState(String accessToken) throws IOException {
        URL url = new URL("https://api.spotify.com/v1/me/player");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);

        BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        StringBuilder response = new StringBuilder();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        return response.toString();
    }

    public void setShuffleMode(String accessToken, String state) throws IOException {
        String endpoint = "https://api.spotify.com/v1/me/player/shuffle?state=" + state;

        System.out.println("Spotifyへ送信するシャッフルリクエスト: " + endpoint);

        sendPutRequest(endpoint, accessToken);
    }
    
 // SpotifyAuthServiceにユーザー名を取得するメソッドを追加
    public String getUserName(String accessToken) throws IOException {
        String url = "https://api.spotify.com/v1/me";
        URL obj = new URL(url);
        HttpURLConnection con = (HttpURLConnection) obj.openConnection();
        con.setRequestMethod("GET");
        con.setRequestProperty("Authorization", "Bearer " + accessToken);

        BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
        String inputLine;
        StringBuffer response = new StringBuffer();
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        // JSONパースしてユーザー名を取り出す
        JSONObject jsonResponse = new JSONObject(response.toString());
        return jsonResponse.getString("display_name");
    }







}