package command;

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

            // プレイリスト情報の取得
            JSONObject playlistsJson = sas.getSpotifyPlaylists(accessToken);
            JSONArray playlistArray = playlistsJson.getJSONArray("items");
            
            // SpotifyPlayListBeanのリストを作成
            List<SpotifyPlayListBean> playlistBeans = new ArrayList<>();
            String userId = (String) session.getAttribute("user_id"); // ユーザーIDをセッションから取得
            for (int i = 0; i < playlistArray.length(); i++) {
                JSONObject playlistJson = playlistArray.getJSONObject(i);
                SpotifyPlayListBean bean = new SpotifyPlayListBean(playlistJson, userId);

                // 画像URLを取得
                JSONArray images = playlistJson.getJSONArray("images");
                if (images.length() > 0) {
                    String imageUrl = images.getJSONObject(0).getString("url"); // 最初の画像を取得
                    bean.setImageUrl(imageUrl); // Beanに画像URLを設定
                }
                
                // 各プレイリストに対するトラック情報を取得し、Track Beanに格納
                List<TrackBean> trackList = new ArrayList<>();
                List<JSONObject> allTracks = sas.getAllPlaylistTracks(accessToken, bean.getPlaylistId());
                for (JSONObject trackJson : allTracks) {
                    JSONObject trackInfo = trackJson.getJSONObject("track");
                    String trackId = trackInfo.getString("id");
                    String trackName = trackInfo.getString("name");
                    String artistName = trackInfo.getJSONArray("artists").getJSONObject(0).getString("name");

                    // トラック画像URLを取得
                    JSONObject albumInfo = trackInfo.getJSONObject("album");  // albumはJSONObject
                    JSONArray trackImages = albumInfo.getJSONArray("images");  // imagesはJSONArray
                    String trackImageUrl = trackImages.length() > 0 ? trackImages.getJSONObject(0).getString("url") : null;

                    TrackBean track = new TrackBean(trackId, trackName, artistName, trackImageUrl); // TrackBeanに画像URLを追加
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

                // アーティストの画像を取得
                JSONArray artistImages = artistJson.getJSONArray("images");
                if (artistImages.length() > 0) {
                    String artistImageUrl = artistImages.getJSONObject(0).getString("url"); // 最初の画像を取得
                    followedArtistImages.add(artistImageUrl); // アーティストの画像URLを追加
                }
            }

            // セッションスコープにデータを保存
            session.setAttribute("playlistBeans", playlistBeans); // プレイリストBeanリスト
            session.setAttribute("followedArtistNames", followedArtistNames); // フォロー中のアーティスト名リスト
            session.setAttribute("followedArtistImages", followedArtistImages); // フォロー中のアーティスト画像URLリスト

            // レスポンスに設定
            responseContext.setResult(playlistBeans); // プレイリスト情報を結果に設定
            responseContext.setTarget("main");       // 転送先JSPを設定

        } catch (Exception e) {
            e.printStackTrace();
            responseContext.setResult("error");
            responseContext.setTarget("error");
        }
        
        return responseContext;
    }
}
