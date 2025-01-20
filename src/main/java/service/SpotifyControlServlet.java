package service;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/spotifyControl")
public class SpotifyControlServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private SpotifyAuthService spotifyService = new SpotifyAuthService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String action = request.getParameter("action"); // "play", "pause", "setup"
        String trackId = request.getParameter("trackId");
        String accessToken = (String) session.getAttribute("access_token");

        if (accessToken == null || accessToken.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Error: Access token is missing or invalid");
            return;
        }

        try {
            switch (action) {
                case "setup":
                    String deviceId = request.getParameter("deviceId");
                    if (deviceId == null || deviceId.isEmpty()) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        response.getWriter().write("Error: Device ID is missing");
                        return;
                    }
                    spotifyService.setupDevice(accessToken, deviceId);
                    response.setStatus(HttpServletResponse.SC_OK);
                    break;

                case "play":
                    System.out.println("再生リクエストのトラック ID: " + trackId); // デバッグ用
                    if (trackId == null || trackId.isEmpty()) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        response.getWriter().write("Error: Track ID is missing");
                        return;
                    }
                    spotifyService.playTrack(accessToken, "spotify:track:" + trackId);
                    response.setStatus(HttpServletResponse.SC_OK);
                    break;



                case "pause":
                    spotifyService.pausePlayback(accessToken);
                    response.setStatus(HttpServletResponse.SC_OK);
                    break;

                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("Error: Invalid action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error processing request: " + e.getMessage());
        }
    }
}
