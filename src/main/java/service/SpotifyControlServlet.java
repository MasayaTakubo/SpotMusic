package service;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

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
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //System.out.println("サーブレット受信: " + request.getRequestURI());
        //System.out.println("リクエスト受信アクション: " + request.getParameter("action"));
        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        String trackId = request.getParameter("trackId");
        String accessToken = (String) session.getAttribute("access_token");

        if (accessToken == null || accessToken.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Error: Access token is missing or invalid");
            return;
        }

        // トラックリストをセッションから取得
        @SuppressWarnings("unchecked")
        List<String> trackIds = (List<String>) session.getAttribute("trackIds");

        if (trackIds == null || trackIds.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Error: No tracks available");
            return;
        }

        // 現在のトラック位置をセッションで管理
        Integer currentIndex = (Integer) session.getAttribute("currentTrackIndex");
        if (currentIndex == null) {
            currentIndex = 0;
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
                    // Spotify APIにデバイスIDをセットアップ
                    spotifyService.setupDevice(accessToken, deviceId);
                    session.setAttribute("device_id", deviceId);
                    response.setStatus(HttpServletResponse.SC_OK);
                    break;

                case "play":
                    if (trackId == null || trackId.isEmpty()) {
                        trackId = trackIds.get(currentIndex);
                    } else {
                        currentIndex = trackIds.indexOf(trackId);
                        session.setAttribute("currentTrackIndex", currentIndex);
                    }

                    spotifyService.playTrack(session, accessToken, "spotify:track:" + trackId);
                    response.setStatus(HttpServletResponse.SC_OK);
                    break;



                case "nextTrack":
                    // 現在のシャッフル状態を安全に取得
                    Object shuffleStateObj = session.getAttribute("shuffle");
                    boolean shuffleState = false; // デフォルトはOFF

                    if (shuffleStateObj instanceof Boolean) {
                        shuffleState = (Boolean) shuffleStateObj;
                    } else if (shuffleStateObj instanceof String) {
                        shuffleState = Boolean.parseBoolean((String) shuffleStateObj);
                    }

                    System.out.println("現在のシャッフル状態: " + shuffleState);

                    if (currentIndex < trackIds.size() - 1) {
                        currentIndex++;
                    } else {
                        currentIndex = 0; // ループ再生
                    }
                    session.setAttribute("currentTrackIndex", currentIndex);

                    spotifyService.playTrack(session, accessToken, "spotify:track:" + trackIds.get(currentIndex));

                    response.setStatus(HttpServletResponse.SC_OK);
                    break;


                case "previousTrack":
                    if (currentIndex > 0) {
                        currentIndex--;
                    } else {
                        currentIndex = trackIds.size() - 1; // 最後のトラックへ
                    }
                    session.setAttribute("currentTrackIndex", currentIndex);
                    System.out.println("前の曲へ: " + trackIds.get(currentIndex));

                    spotifyService.playTrack(session, accessToken, "spotify:track:" + trackIds.get(currentIndex));

                    response.setStatus(HttpServletResponse.SC_OK);
                    break;

                case "pause":
                    spotifyService.pausePlayback(accessToken);
                    response.setStatus(HttpServletResponse.SC_OK);
                    break;
                //Repeat
				/*                case "repeatTrack":
				        String repeatState = request.getParameter("state"); // "track", "context", "off"
				        if (repeatState == null) repeatState = "track"; // デフォルトは1曲リピート
				        spotifyService.setRepeatMode(accessToken, repeatState);
				        response.setStatus(HttpServletResponse.SC_OK);
				        break;*/
                case "toggleRepeat":
                    // 現在のリピート状態をセッションから取得
                    String currentRepeatState = (String) session.getAttribute("repeatState");
                    if (currentRepeatState == null) currentRepeatState = "off";

                    // 次のリピート状態を決定
                    String nextRepeatState;
                    switch (currentRepeatState) {
                        case "off":
                            nextRepeatState = "context"; // プレイリストリピート
                            break;
                        case "context":
                            nextRepeatState = "track"; // 1曲リピート
                            break;
                        case "track":
                        default:
                            nextRepeatState = "off"; // リピートなし
                            break;
                    }

                    // 新しいリピート状態をSpotify APIに送信
                    spotifyService.setRepeatMode(accessToken, nextRepeatState);
                    session.setAttribute("repeatState", nextRepeatState);

                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("Repeat mode set to: " + nextRepeatState);
                    break;

                case "seek":
                    String positionMs = request.getParameter("positionMs"); // ミリ秒単位で取得
                    if (positionMs == null) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        response.getWriter().write("Error: Position is missing");
                        return;
                    }
                    spotifyService.seekPlayback(accessToken, positionMs);
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("Playback position set to: " + positionMs);
                    break;
                    
                case "getPlaybackState":
                    String playbackState = spotifyService.getPlaybackState(accessToken);
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write(playbackState);
                    break;

                case "toggleShuffle":
                    // セッションから現在のシャッフル状態を取得し、切り替える
                    Boolean currentShuffleState = (Boolean) session.getAttribute("shuffle");
                    if (currentShuffleState == null) {
                        currentShuffleState = false; // デフォルトはOFF
                    }

                    // シャッフルのON/OFFを切り替え
                    boolean newShuffleState = !currentShuffleState;
                    session.setAttribute("shuffle", newShuffleState);

                    try {
                        // シャッフル状態をエンコードしてSpotify APIに送信
                        String encodedState = URLEncoder.encode(String.valueOf(newShuffleState), StandardCharsets.UTF_8.toString());
                        spotifyService.setShuffleMode(accessToken, encodedState);

                        response.setStatus(HttpServletResponse.SC_OK);
                        response.getWriter().write("シャッフル状態を " + newShuffleState + " に設定しました");
                    } catch (Exception e) {
                        e.printStackTrace();
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        response.getWriter().write("Error processing shuffle request: " + e.getMessage());
                    }
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


