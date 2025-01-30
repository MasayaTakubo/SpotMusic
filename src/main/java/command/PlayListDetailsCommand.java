package command;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

import bean.TrackBean;
import context.RequestContext;
import context.ResponseContext;
import service.SpotifyAuthService;

public class PlayListDetailsCommand extends AbstractCommand {

    @Override
    public ResponseContext execute(ResponseContext responseContext) {
        RequestContext reqContext = getRequestContext();

        // HttpServletRequestを取得
        HttpServletRequest request = (HttpServletRequest) reqContext.getRequest();

        // HTTPセッションを取得
        HttpSession session = request.getSession();

        // パラメータから playlistId を取得
        String playlistId = request.getParameter("playlistId");
        String accessToken = (String) session.getAttribute("access_token");

        if (playlistId == null || accessToken == null) {
            // 必須データが不足している場合エラー
            responseContext.setResult("error");
            responseContext.setTarget("error.jsp");
            return responseContext;
        }

        try {
            SpotifyAuthService spotifyService = new SpotifyAuthService();

            // プレイリストのトラック情報を取得
            List<TrackBean> trackList = new ArrayList<>();
            List<JSONObject> allTracks = spotifyService.getAllPlaylistTracks(accessToken, playlistId);

            for (JSONObject trackJson : allTracks) {
                JSONObject trackInfo = trackJson.getJSONObject("track");

                // トラック情報取得
                String trackId = trackInfo.getString("id");
                String trackName = trackInfo.getString("name");
                String artistName = trackInfo.getJSONArray("artists").getJSONObject(0).getString("name");

                // アルバム画像URLを取得
                String trackImageUrl = "";
                JSONArray images = trackInfo.getJSONObject("album").getJSONArray("images");
                if (images.length() > 0) {
                    trackImageUrl = images.getJSONObject(0).getString("url"); // 一番大きい画像を取得
                }

                // 画像URLが空ならデフォルト画像を設定
                if (trackImageUrl.isEmpty()) {
                    trackImageUrl = "/path/to/default/image.jpg";  // デフォルト画像パス
                }

                // TrackBean に追加
                TrackBean track = new TrackBean(trackId, trackName, artistName, trackImageUrl);
                trackList.add(track);
            }

            // セッションにトラック情報を保存
            session.setAttribute("trackList", trackList);

            // リダイレクト先を設定
            responseContext.setTarget("playList");

        } catch (Exception e) {
            e.printStackTrace();
            responseContext.setResult("error");
            responseContext.setTarget("error.jsp");
        }

        return responseContext;
    }
}
