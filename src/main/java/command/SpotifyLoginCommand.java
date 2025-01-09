//package command;
//
//import javax.servlet.http.HttpSession;
//
//import org.json.JSONObject;
//
//import context.ResponseContext;
//import service.SpotifyAuthService;
//
//public class SpotifyLoginCommand extends AbstractCommand {
//
//    private SpotifyAuthService spotifyAuthService = new SpotifyAuthService();
//
//    @Override
//    public ResponseContext execute(ResponseContext resc) {
//        try {
//            // Spotify認証フローを開始
//            String code = getRequestContext().getParameter("code")[0];
//            if (code != null) {
//                // Spotify APIでトークンを取得
//                String accessToken = spotifyAuthService.getAccessToken(code);
//                String spotifyUserId = spotifyAuthService.getUserId(accessToken);
//
//                // データベースにユーザー情報を保存
//                spotifyAuthService.saveUser(spotifyUserId, accessToken, null, 3600); // 例：リフレッシュトークンと有効期限を適宜変更
//
//                // セッションにユーザー情報を保存
//                HttpSession session = (HttpSession) getRequestContext().getRequest();
//                session.setAttribute("spotifyUserId", spotifyUserId);
//
//                // プレイリストを取得してレスポンスに設定
//                JSONObject playlists = spotifyAuthService.getSpotifyPlaylists(accessToken);
//                resc.setResult(playlists);
//
//                // メインページへ遷移
//                resc.setTarget("main");
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return resc;
//    }
//}
