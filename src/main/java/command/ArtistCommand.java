package command;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

import bean.ArtistBean;
import context.RequestContext;
import context.ResponseContext;
import service.SpotifyAuthService;

public class ArtistCommand extends AbstractCommand {

    @Override
    public ResponseContext execute(ResponseContext responseContext) {
        RequestContext reqContext = getRequestContext();

        // HttpServletRequestを取得
        HttpServletRequest request = (HttpServletRequest) reqContext.getRequest();

        // HTTPセッションを取得
        HttpSession session = request.getSession();

        // パラメータから artistId を取得
        String artistId = request.getParameter("artistId");
        String accessToken = (String) session.getAttribute("access_token");

        if (artistId == null || accessToken == null) {
            // 必須データが不足している場合エラー
            responseContext.setResult("error");
            responseContext.setTarget("error.jsp");
            return responseContext;
        }
        System.out.println("アーティストのID：：" + artistId);

        try {
            SpotifyAuthService sas = new SpotifyAuthService();

            // アーティストの詳細情報を取得
            JSONObject artistDetails = sas.getArtistDetails(accessToken, artistId);
            
            
            
            // アーティストのアイコン画像URLを取得
            JSONArray artistImages = artistDetails.getJSONArray("images");
            String artistImageUrl = (artistImages.length() > 0) ? artistImages.getJSONObject(0).getString("url") : null;

            // アーティストの人気曲を取得
            JSONArray topTracksJson = sas.getArtistTopTracks(accessToken, artistId);
            // トラックのアイコン画像URLを取得
            for (int i = 0; i < topTracksJson.length(); i++) {
                JSONObject trackJson = topTracksJson.getJSONObject(i);
                JSONObject albumJson = trackJson.getJSONObject("album");
                JSONArray albumImages = albumJson.getJSONArray("images");
                String albumImageUrl = (albumImages.length() > 0) ? albumImages.getJSONObject(0).getString("url") : null;
                trackJson.put("albumImageUrl", albumImageUrl); // トラックにアルバムの画像URLを追加
            }

            // アーティストのプレイリストを取得
            JSONArray playlistsJson = sas.getArtistPlaylists(accessToken, artistId);

            // プレイリストにアルバム画像URLを追加
            for (int i = 0; i < playlistsJson.length(); i++) {
                JSONObject playlistJson = playlistsJson.getJSONObject(i);
                JSONArray playlistImages = playlistJson.has("images") ? playlistJson.getJSONArray("images") : null;
                String playlistImageUrl = (playlistImages != null && playlistImages.length() > 0)
                        ? playlistImages.getJSONObject(0).getString("url")
                        : null;
                playlistJson.put("albumImageUrl", playlistImageUrl); // プレイリストに画像URLを追加
            }

            // `ArtistBean` クラスに情報をセット（コンストラクタで処理）
            ArtistBean artistBean = new ArtistBean(artistDetails, topTracksJson, playlistsJson, artistImageUrl);

            // セッションに保存
            session.setAttribute("artistBean", artistBean);

            // リダイレクト先を設定
            responseContext.setTarget("artist");

        } catch (Exception e) {
            e.printStackTrace();
            responseContext.setResult("error");
            responseContext.setTarget("artist");
        }

        return responseContext;
    }
}
