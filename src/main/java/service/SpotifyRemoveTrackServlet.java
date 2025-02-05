package service;

import java.io.IOException;
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

@WebServlet("/SpotifyRemoveTrackServlet")
public class SpotifyRemoveTrackServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String SPOTIFY_API_URL = "https://api.spotify.com/v1/playlists";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String accessToken = (String) session.getAttribute("access_token");

        if (accessToken == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String playlistId = request.getParameter("playlistId");
        String trackId = request.getParameter("trackId");

        if (playlistId == null || trackId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        boolean success = removeTrackFromPlaylist(playlistId, trackId, accessToken);

        response.setContentType("application/json");
        response.getWriter().write(new JSONObject().put("success", success).toString());
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
