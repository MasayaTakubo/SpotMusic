package command;

import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

import context.RequestContext;
import context.ResponseContext;

public class SpotifyRemoveTrackCommand extends AbstractCommand {
    private static final String SPOTIFY_API_URL = "https://api.spotify.com/v1/playlists";

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
            responseContext.setResult(jsonResponse.toString()); // ← 修正
            return responseContext;
        }

        String playlistId = request.getParameter("playlistId");
        String trackId = request.getParameter("trackId");

        if (playlistId == null || trackId == null) {
            jsonResponse.put("error", "Bad Request");
            responseContext.setContentType("application/json");
            responseContext.setResult(jsonResponse.toString()); // ← 修正
            return responseContext;
        }

        boolean success = false;
        try {
            success = removeTrackFromPlaylist(playlistId, trackId, accessToken);
        } catch (IOException e) {
            e.printStackTrace();
            jsonResponse.put("error", "Internal Server Error");
            responseContext.setContentType("application/json");
            responseContext.setResult(jsonResponse.toString()); // ← 修正
            return responseContext;
        }

        jsonResponse.put("success", success);
        
        responseContext.setContentType("application/json");
        responseContext.setResult(jsonResponse.toString()); // ← 修正
        
        return responseContext;
    }


    private boolean removeTrackFromPlaylist(String playlistId, String trackId, String accessToken) throws IOException {
        String urlString = SPOTIFY_API_URL + "/" + playlistId + "/tracks";
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();

        connection.setRequestMethod("DELETE");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setDoOutput(true);

        String jsonBody = "{\"tracks\": [{\"uri\": \"spotify:track:" + trackId + "\"}]}";

        try (OutputStream os = connection.getOutputStream()) {
            byte[] input = jsonBody.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }

        int responseCode = connection.getResponseCode();
        return responseCode == 200;
    }
}
