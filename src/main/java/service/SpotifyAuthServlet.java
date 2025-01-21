package service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

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
    private String frontURL =  "FrontServlet?command=MyPlayListCommand";
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	String command = request.getParameter("command");
    	System.out.println("最初のcommand:" + command);
    	
    	//System.out.println(code+"codeの中身");
    	// 認証コードがない場合はSpotify認証ページへリダイレクト
    	if (request.getParameter("code") == null) {
            String authUrl = "https://accounts.spotify.com/authorize"
                    + "?client_id=" + SpotifyAuthService.CLIENT_ID
                    + "&response_type=code"
                    + "&redirect_uri=" + java.net.URLEncoder.encode(SpotifyAuthService.REDIRECT_URI, "UTF-8")
                    + "&scope=playlist-read-private,user-follow-read,user-read-private,user-read-email,user-top-read"; // スコープは必要に応じて変更
            response.sendRedirect(authUrl); // Spotify認証ページにリダイレクト
            return;
        }

        // 認証コードを取得
        
        String authorizationCode = request.getParameter("code");
        System.out.println("認証コード取得完了");
        System.out.println("認証コード？："+authorizationCode);
        if (authorizationCode != null) {
            try {
                // アクセストークンを取得
            	SpotifyAuthService sas = new SpotifyAuthService();
                String accessToken = sas.getAccessToken(authorizationCode);
                String userId = spotifyAuthService.getUserId(accessToken);
                //ここにアーティストの情報も一緒に取得するコードを記述したい。
                List<String> artistIds = spotifyAuthService.getArtistIds(accessToken,50);
                List<String> artistNames = spotifyAuthService.getArtistNames(accessToken,50);
                System.out.println("AuthのUserId取れてる？" + userId);
                System.out.println("アクセストークン取得完了");
                // ユーザー情報をデータベースに保存
                spotifyAuthService.saveUser(userId, accessToken, null, 3600); // 例：リフレッシュトークンと有効期限を適宜変更

                // プレイリスト情報をデータベースに保存
                //spotifyAuthService.saveUserPlaylists(accessToken, userId);
                

                // セッションにユーザー情報を保存
                HttpSession session = request.getSession();
                session.setAttribute("access_token", accessToken);
                session.setAttribute("user_id", userId);
                session.setAttribute("command", command);
                session.setAttribute("artistIds", artistIds);
                session.setAttribute("artistNames", artistNames);
                System.out.println("SpotifyAuth" + session.getAttribute("user_id"));
                //session.setAttribute("playList", authorizationCode);
                System.out.println("セッション登録完了");
                // メインページに遷移し、commandパラメータを追加
//                String redirectUrl = "/WEB-INF/jsp/main.jsp";
//                RequestDispatcher dispatcher = request.getRequestDispatcher(redirectUrl);
//                dispatcher.forward(request, response);
//                
                System.out.println("帰ってきたデータたち："+response);
//                RequestDispatcher dispatcher = request.getRequestDispatcher("/FrontServlet");  // FrontServlet の URL パターン
//                dispatcher.forward(request, response);
                response.sendRedirect(frontURL);
                System.out.println("forward完了しました。");
                

            } catch (IOException | SQLException e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Spotify API処理に失敗しました。");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "予期しないエラーが発生しました。");
            }
        }
    }
}
