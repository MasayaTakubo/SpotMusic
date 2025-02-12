package command;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

import context.RequestContext;
import context.ResponseContext;

public class SpotifyDeletePlaylistCommand extends AbstractCommand {
    private static final String SPOTIFY_API_URL = "https://api.spotify.com/v1/playlists/";

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

        String playlistId = request.getParameter("playlistId");
        String responseType = request.getParameter("responseType"); // クライアントが HTML か JSON を指定
        
        if (playlistId == null || playlistId.isEmpty()) {
            jsonResponse.put("error", "Bad Request: playlistId is required");
            responseContext.setContentType("application/json");
            responseContext.setResult(jsonResponse.toString());
            return responseContext;
        }

        try {
            boolean success = deletePlaylist(playlistId, accessToken);
            jsonResponse.put("success", success);
            if (success) {
                session.removeAttribute("playlistBeans");
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

    private boolean deletePlaylist(String playlistId, String accessToken) throws IOException {
        String urlString = SPOTIFY_API_URL + playlistId + "/followers";
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        
        connection.setRequestMethod("DELETE");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setDoOutput(true);

        int responseCode = connection.getResponseCode();
        return responseCode == 200 || responseCode == 202; // 200または202なら削除成功
    }
}
