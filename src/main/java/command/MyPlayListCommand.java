package command;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

import bean.SpotifyPlayListBean;
import bean.TrackBean;
import context.RequestContext;
import context.ResponseContext;
import dao.PlayListDAO; // 追加
import service.SpotifyAuthService;

public class MyPlayListCommand extends AbstractCommand {

    @Override
    public ResponseContext execute(ResponseContext responseContext) {
        RequestContext reqContext = getRequestContext();
        
        // HttpServletRequestを取得
        HttpServletRequest request = (HttpServletRequest) reqContext.getRequest();
        
        // HTTPセッションからアクセストークンを取得
        HttpSession session = request.getSession();
        String accessToken = (String) session.getAttribute("access_token");
        
        // アクセストークンがない場合はエラーとして処理を中断
        if (accessToken == null) {
            responseContext.setResult("error");
            responseContext.setTarget("main.jsp"); // ログインページへ転送
            return responseContext;
        }
        
        try {
            SpotifyAuthService sas = new SpotifyAuthService();
            PlayListDAO playlistDAO = new PlayListDAO(); // 追加

            // プレイリスト情報の取得
            JSONObject playlistsJson = sas.getSpotifyPlaylists(accessToken);
            JSONArray playlistArray = playlistsJson.getJSONArray("items");
            
            // SpotifyPlayListBeanのリストを作成
            List<SpotifyPlayListBean> playlistBeans = new ArrayList<>();
            String userId = (String) session.getAttribute("user_id"); // ユーザーIDをセッションから取得
            for (int i = 0; i < playlistArray.length(); i++) {
                JSONObject playlistJson = playlistArray.getJSONObject(i);
                SpotifyPlayListBean bean = new SpotifyPlayListBean(playlistJson, userId);
                
                // プレイリストIDを保存
                playlistDAO.savePlaylistReview(bean.getPlaylistId(), userId); // 追加

                // 各プレイリストに対するトラック情報を取得し、Track Beanに格納
                List<TrackBean> trackList = new ArrayList<>();
                List<JSONObject> allTracks = sas.getAllPlaylistTracks(accessToken, bean.getPlaylistId());
                for (JSONObject trackJson : allTracks) {
                    JSONObject trackInfo = trackJson.getJSONObject("track");
                    String trackId = trackInfo.getString("id");
                    String trackName = trackInfo.getString("name");
                    String artistName = trackInfo.getJSONArray("artists").getJSONObject(0).getString("name");
                    
                    JSONObject albumInfo = trackInfo.optJSONObject("album");
                    JSONArray trackImages = (albumInfo != null) ? albumInfo.optJSONArray("images") : null;
                    String trackImageUrl = (trackImages != null && trackImages.length() > 0)
                        ? trackImages.getJSONObject(0).optString("url", "/img/no_image.png")
                        : "/img/no_image.png";
                    
                    TrackBean track = new TrackBean(trackId, trackName, artistName, trackImageUrl);
                    trackList.add(track);
                }

                // Track情報もBeanに設定
                bean.setTrackList(trackList);
                
                playlistBeans.add(bean);
            }

            // フォロー中のアーティスト情報の取得
            JSONObject followedArtistsJson = sas.getFollowedArtists(accessToken);
            JSONArray artistArray = followedArtistsJson.getJSONObject("artists").getJSONArray("items");
            List<String> followedArtistNames = new ArrayList<>();
            List<String> followedArtistImages = new ArrayList<>(); // 画像URLを格納するリスト
            for (int i = 0; i < artistArray.length(); i++) {
                JSONObject artistJson = artistArray.getJSONObject(i);
                followedArtistNames.add(artistJson.getString("name"));

                JSONArray artistImages = artistJson.optJSONArray("images");
                if (artistImages != null && artistImages.length() > 0) {
                    String artistImageUrl = artistImages.getJSONObject(0).optString("url", "/img/no_image.png");
                    followedArtistImages.add(artistImageUrl);
                } else {
                    followedArtistImages.add("/img/no_image.png");
                }
            }

            // セッションスコープにデータを保存
            session.setAttribute("playlistBeans", playlistBeans);
            session.setAttribute("followedArtistNames", followedArtistNames);
            session.setAttribute("followedArtistImages", followedArtistImages);

            // レスポンスに設定
            responseContext.setResult(playlistBeans);
            responseContext.setTarget("main");

        } catch (SQLException e) {
            e.printStackTrace();
            responseContext.setResult("database_error");
            responseContext.setTarget("error");
        } catch (Exception e) {
            e.printStackTrace();
            responseContext.setResult("error");
            responseContext.setTarget("error");
        }
        
        return responseContext;
    }
}