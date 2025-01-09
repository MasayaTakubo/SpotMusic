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

import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.entity.UrlEncodedFormEntity;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.message.BasicNameValuePair;
import org.json.JSONArray;
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

        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        String inputLine;
        StringBuilder response = new StringBuilder();
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        JSONObject jsonResponse = new JSONObject(response.toString());
        System.out.println("Service" + jsonResponse.getString("id"));
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

}
