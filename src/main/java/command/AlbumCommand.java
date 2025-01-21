package command;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

import bean.TrackBean;
import context.RequestContext;
import context.ResponseContext;
import service.SpotifyAuthService;

public class AlbumCommand extends AbstractCommand {

    @Override
    public ResponseContext execute(ResponseContext responseContext) {
        RequestContext reqContext = getRequestContext();

        // HttpServletRequestを取得
        HttpServletRequest request = (HttpServletRequest) reqContext.getRequest();

        // HTTPセッションを取得
        HttpSession session = request.getSession();

        // パラメータから albumId を取得
        String albumId = request.getParameter("albumId");
        String accessToken = (String) session.getAttribute("access_token");

        if (albumId == null || accessToken == null) {
            // 必須データが不足している場合エラー
            responseContext.setResult("error");
            responseContext.setTarget("error.jsp");
            return responseContext;
        }

        try {
            SpotifyAuthService sas = new SpotifyAuthService();

            // アルバムのトラック情報を取得
            List<TrackBean> trackList = new ArrayList<>();
            List<JSONObject> allTracks = sas.getAllAlbumTracks(accessToken, albumId);

            
            System.out.println("allTracksの内容:");
            for (JSONObject trackJson : allTracks) {
                System.out.println(trackJson.toString(4)); // JSONオブジェクトを整形して出力
            }
            
            
            
            
            
            
            for (JSONObject trackJson : allTracks) {
            	    // trackJson 自体がトラック情報を持っているので、直接アクセス
            	    String trackId = trackJson.getString("id");
            	    String trackName = trackJson.getString("name");
            	    String artistName = trackJson.getJSONArray("artists").getJSONObject(0).getString("name");

            	    // TrackBean に追加
            	    TrackBean track = new TrackBean(trackId, trackName, artistName);
            	    trackList.add(track);
            }

            // セッションにトラック情報を保存
            session.setAttribute("trackList", trackList);

            // リダイレクト先を設定
            responseContext.setTarget("album");

        } catch (Exception e) {
            e.printStackTrace();
            responseContext.setResult("error");
            responseContext.setTarget("album");
        }

        return responseContext;
    }
}
