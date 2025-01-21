package service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/auth")
public class SpotifyAuthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private SpotifyAuthService spotifyAuthService = new SpotifyAuthService();
    private String frontURL = "FrontServlet?command=MyPlayListCommand";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String command = request.getParameter("command");
        System.out.println("最初のcommand:" + command);

        if (request.getParameter("code") == null) {
            // 認証コードがない場合はSpotify認証ページへリダイレクト
            String authUrl = "https://accounts.spotify.com/authorize"
                    + "?client_id=" + SpotifyAuthService.CLIENT_ID
                    + "&response_type=code"
                    + "&redirect_uri=" + java.net.URLEncoder.encode(SpotifyAuthService.REDIRECT_URI, "UTF-8")
                    + "&scope=streaming user-read-playback-state user-modify-playback-state playlist-read-private playlist-read-collaborative user-follow-read"
                    + "&scope=playlist-read-private,user-follow-read,user-read-private,user-read-email,user-top-read"; 
            response.sendRedirect(authUrl);
            return;
        }

        // 認証コードを取得
        String authorizationCode = request.getParameter("code");
        System.out.println("認証コード取得完了");
        if (authorizationCode != null) {
            try {
                // アクセストークンとリフレッシュトークンを取得
                Map<String, String> tokens = spotifyAuthService.getRefreshToken(authorizationCode);
                String accessToken = tokens.get("access_token");
                String refreshToken = tokens.get("refresh_token");

                System.out.println("アクセストークン取得完了: " + accessToken);
                System.out.println("リフレッシュトークン取得完了: " + refreshToken);

                // ユーザーIDを取得
                String userId = spotifyAuthService.getUserId(accessToken);

                // ユーザー情報をデータベースに保存
                spotifyAuthService.saveUser(userId, accessToken, refreshToken, 3600);

                // セッションにユーザー情報を保存
                session.setAttribute("access_token", accessToken);
                session.setAttribute("refresh_token", refreshToken);
                session.setAttribute("user_id", userId);
                session.setAttribute("command", command);

                // Listを保存する
                List<String> artistIds = spotifyAuthService.getArtistIds(accessToken, 50);
                List<String> artistNames = spotifyAuthService.getArtistNames(accessToken, 50);
                session.setAttribute("artistIds", artistIds);
                session.setAttribute("artistNames", artistNames);
                System.out.println("アーティスト情報取得完了");

                // Mapを保存する
                Map<String, String> userInfoMap = Map.of("userId", userId, "accessToken", accessToken, "refreshToken", refreshToken);
                session.setAttribute("userInfoMap", userInfoMap);
                System.out.println("ユーザー情報Map登録完了");

                // リダイレクト先へ
                response.sendRedirect(frontURL);
                System.out.println("リダイレクト完了");

            } catch (IOException | SQLException e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Spotify API処理に失敗しました。");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "予期しないエラーが発生しました。");
            }
        }
    }

    // アクセストークンのリフレッシュ処理
    protected void refreshAccessToken(HttpSession session) throws IOException {
        String refreshToken = (String) session.getAttribute("refresh_token");
        if (refreshToken == null) {
            throw new IllegalStateException("リフレッシュトークンがセッションに存在しません。再ログインしてください。");
        }

        // SpotifyAuthService を使用して新しいアクセストークンを取得
        SpotifyAuthService sas = new SpotifyAuthService();
        String newAccessToken = sas.refreshAccessToken(refreshToken);

        // セッションに新しいアクセストークンを保存
        session.setAttribute("access_token", newAccessToken);
        System.out.println("アクセストークンがリフレッシュされました。");
    }
}
