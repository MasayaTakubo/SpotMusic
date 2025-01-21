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
        System.out.println("アーティストのID：："+artistId);

        try {
            SpotifyAuthService sas = new SpotifyAuthService();

            // アーティストの詳細情報を取得
            JSONObject artistDetails = sas.getArtistDetails(accessToken, artistId);

            // アーティストの人気曲を取得
            JSONArray topTracksJson = sas.getArtistTopTracks(accessToken, artistId);

            // アーティストのプレイリストを取得
            JSONArray playlistsJson = sas.getArtistPlaylists(accessToken, artistId);

            // `ArtistBean` クラスに情報をセット（コンストラクタで処理）
            ArtistBean artistBean = new ArtistBean(artistDetails, topTracksJson, playlistsJson);

            // セッションに保存
            session.setAttribute("artistBean", artistBean);

            // リダイレクト先を設定
            responseContext.setTarget("artist");

        } catch (Exception e) {
            e.printStackTrace();
            responseContext.setResult("error");
            responseContext.setTarget("error.jsp");
        }

        return responseContext;
    }
}
