package service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

import org.json.JSONObject;

public class SpotifyAuth {
    private static final String TOKEN_URL = "https://accounts.spotify.com/api/token";

    public static String getAccessToken(String authorizationCode) throws IOException {
        URL url = new URL(TOKEN_URL);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("POST");
        connection.setDoOutput(true);

        // POSTデータ
        String postData = "code=" + authorizationCode
                          + "&redirect_uri=http://localhost:8080/SpotMusic/auth"
                          + "&grant_type=authorization_code"
                          + "&client_id=277b350dfbe146e8b5b48171bc6ceaed"
                          + "&client_secret=5cdda2ff3df040de9b8ba8cbf0122885";

        // 出力ストリームにデータを書き込む
        try (var os = connection.getOutputStream()) {
            byte[] input = postData.getBytes("UTF-8");
            os.write(input, 0, input.length);
        }

        // レスポンスを受け取る
        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        String inputLine;
        StringBuilder response = new StringBuilder();
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        // レスポンスからアクセストークンを取得
        JSONObject jsonResponse = new JSONObject(response.toString());
        return jsonResponse.getString("access_token");
    }

    public static String getUserId(String accessToken) throws IOException {
        URL url = new URL("https://api.spotify.com/v1/me");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Accept", "application/json");

        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        String inputLine;
        StringBuilder response = new StringBuilder();
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        // レスポンスからユーザーIDを取得
        JSONObject jsonResponse = new JSONObject(response.toString());
        return jsonResponse.getString("id");
    }
}
