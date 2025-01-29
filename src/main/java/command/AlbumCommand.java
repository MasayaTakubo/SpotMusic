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

        // デバッグ用：パラメータとセッション情報の確認
        System.out.println("AlbumCommand Start");
        System.out.println("Received albumId: " + albumId);
        System.out.println("AccessToken from session: " + accessToken);

        if (albumId == null || accessToken == null) {
            // 必須データが不足している場合エラー
            System.err.println("Error: albumId or accessToken is missing");
            responseContext.setResult("error");
            responseContext.setTarget("error.jsp");
            return responseContext;
        }

        try {
            SpotifyAuthService sas = new SpotifyAuthService();

            // デバッグ用：サービスのインスタンス作成
            System.out.println("SpotifyAuthService instance created");

            // アルバムのトラック情報を取得
            List<TrackBean> trackList = new ArrayList<>();
            JSONArray allTracks = sas.getAllAlbumTracks(accessToken, albumId);

            // アルバム詳細情報を取得
            JSONObject albumDetails = sas.getAlbumDetails(accessToken, albumId);

            // アルバム画像URLを取得
            String albumImageUrl = null;
            if (albumDetails.has("images") && albumDetails.getJSONArray("images").length() > 0) {
                albumImageUrl = albumDetails.getJSONArray("images").getJSONObject(0).getString("url");
            }

            // デバッグ用：トラック情報の内容をログ出力
            System.out.println("Fetched " + allTracks.length() + " tracks from album");

            // トラック情報の処理
         // トラック情報の処理
            for (int i = 0; i < allTracks.length(); i++) {
                JSONObject trackJson = allTracks.getJSONObject(i);
                String trackId = trackJson.getString("id");
                String trackName = trackJson.getString("name");
                String artistName = trackJson.getJSONArray("artists").getJSONObject(0).getString("name");

                // トラックの画像URLを取得
                String trackImageUrl = null;
                if (trackJson.has("images")) {
                    JSONArray images = trackJson.getJSONArray("images");
                    if (images.length() > 0) {
                        trackImageUrl = images.getJSONObject(0).getString("url");  // 最初の画像を使用
                        
                    }
                    
                }
                System.out.println("＊＊＊＊画像＊＊＊＊＊＊" + trackImageUrl);
                // TrackBeanに画像URLを追加
                TrackBean track = new TrackBean(trackId, trackName, artistName, trackImageUrl);
                trackList.add(track);
            }


            // セッションにトラック情報を保存
            System.out.println("Saving trackList to session...");
            session.setAttribute("trackList", trackList);

            // リダイレクト先を設定
            System.out.println("Redirecting to album page");
            responseContext.setTarget("album");

        } catch (Exception e) {
            // エラー発生時のデバッグ情報出力
            System.err.println("Exception occurred in AlbumCommand");
            e.printStackTrace();  // 詳細なエラートレース

            // デバッグ用：エラーメッセージを出力
            responseContext.setResult("error");
            responseContext.setTarget("error.jsp");
        }

        return responseContext;
    }
}
