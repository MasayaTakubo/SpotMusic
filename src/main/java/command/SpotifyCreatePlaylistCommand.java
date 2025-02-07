package command;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

import context.RequestContext;
import context.ResponseContext;

public class SpotifyCreatePlaylistCommand extends AbstractCommand {
    private static final String SPOTIFY_API_URL = "https://api.spotify.com/v1/users/";

    @Override
    public ResponseContext execute(ResponseContext responseContext) {
        RequestContext reqContext = getRequestContext();
        HttpServletRequest request = (HttpServletRequest) reqContext.getRequest();
        HttpSession session = request.getSession();
        
        String accessToken = (String) session.getAttribute("access_token");
        JSONObject jsonResponse = new JSONObject();
        
        if (accessToken == null) {
            jsonResponse.put("error", "Unauthorized");
            responseContext.setContentType("application/json");
            responseContext.setResult(jsonResponse.toString());
            return responseContext;
        }

        String playlistName = request.getParameter("playlistName");
        String responseType = request.getParameter("responseType"); // クライアントが HTML か JSON を指定
        
        if (playlistName == null || playlistName.isEmpty()) {
            jsonResponse.put("error", "Bad Request: playlistName is required");
            responseContext.setContentType("application/json");
            responseContext.setResult(jsonResponse.toString());
            return responseContext;
        }

        try {
            String userId = getCurrentUserId(accessToken);
            if (userId == null) {
                jsonResponse.put("error", "Failed to retrieve user ID");
            } else {
                boolean success = createPlaylist(userId, playlistName, accessToken);
                jsonResponse.put("success", success);
            }
        } catch (IOException e) {
            jsonResponse.put("error", "Internal Server Error");
            e.printStackTrace();
        }

        if ("html".equalsIgnoreCase(responseType)) {
            responseContext.setContentType("text/html; charset=UTF-8");
            responseContext.setResult("<script>parent.location.reload();</script>");
        } else {
            responseContext.setContentType("application/json");
            responseContext.setResult(jsonResponse.toString());
        }

        return responseContext;
    }
    

    private boolean createPlaylist(String userId, String playlistName, String accessToken) throws IOException {
        String urlString = SPOTIFY_API_URL + userId + "/playlists";
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setDoOutput(true);

        String jsonBody = "{\"name\":\"" + playlistName + "\", \"public\":false}";
        
        try (OutputStream os = connection.getOutputStream()) {
            byte[] input = jsonBody.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }

        int responseCode = connection.getResponseCode();
        return responseCode == 201;
    }

    private String getCurrentUserId(String accessToken) throws IOException {
        String urlString = "https://api.spotify.com/v1/me";
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Content-Type", "application/json");

        int responseCode = connection.getResponseCode();
        if (responseCode != 200) {
            return null;
        }

        try (BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            JSONObject json = new JSONObject(response.toString());
            return json.getString("id");
        }
    }
}
