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

public class AlbumCommand extends AbstractCommand {

    @Override
    public ResponseContext execute(ResponseContext responseContext) {
        System.out.println("AlbumCommandが実行されます");
        RequestContext reqContext = getRequestContext();
        HttpServletRequest request = (HttpServletRequest) reqContext.getRequest();
        HttpSession session = request.getSession();

        String albumId = request.getParameter("albumId");
        String accessToken = (String) session.getAttribute("access_token");

        System.out.println("AlbumCommand Start");
        System.out.println("Received albumId: " + albumId);
        System.out.println("AccessToken from session: " + accessToken);

        if (albumId == null || accessToken == null) {
            System.err.println("Error: albumId or accessToken is missing");
            responseContext.setResult("error");
            responseContext.setTarget("error.jsp");
            return responseContext;
        }

        try {
            SpotifyAuthService sas = new SpotifyAuthService();

            // **アルバムのトラック情報を取得**
            List<TrackBean> trackList = new ArrayList<>();
            JSONArray allTracks = sas.getAllAlbumTracks(accessToken, albumId);
            JSONObject albumDetails = sas.getAlbumDetails(accessToken, albumId);

            // **アルバム画像URLを取得**
            String albumImageUrl = null;
            if (albumDetails.has("images") && albumDetails.getJSONArray("images").length() > 0) {
                albumImageUrl = albumDetails.getJSONArray("images").getJSONObject(0).getString("url");
            }

            // **トラック情報を処理**
            for (int i = 0; i < allTracks.length(); i++) {
                JSONObject trackJson = allTracks.getJSONObject(i);
                String trackId = trackJson.getString("id");
                String trackName = trackJson.getString("name");
                String artistName = trackJson.getJSONArray("artists").getJSONObject(0).getString("name");

                String trackImageUrl = null;
                if (trackJson.has("album")) {
                    JSONArray images = trackJson.getJSONObject("album").optJSONArray("images");
                    if (images != null && images.length() > 0) {
                        trackImageUrl = images.getJSONObject(0).getString("url");
                    }
                }
                trackList.add(new TrackBean(trackId, trackName, artistName, trackImageUrl));
            }

            System.out.println("Saving trackList to session...");
            session.setAttribute("trackList", trackList);

            // **ユーザーのプレイリストを取得**
            System.out.println("Fetching user playlists...");
            JSONArray userPlaylistsArray = sas.getUserPlaylists(accessToken);
            List<SpotifyPlayListBean> userPlaylists = new ArrayList<>();

            for (int i = 0; i < userPlaylistsArray.length(); i++) {
                JSONObject playlistJson = userPlaylistsArray.getJSONObject(i);
                String userId = playlistJson.getJSONObject("owner").getString("id");
                userPlaylists.add(new SpotifyPlayListBean(playlistJson, userId));
            }

            System.out.println("取得したプレイリスト数: " + userPlaylists.size());
            session.setAttribute("userPlaylists", userPlaylists);

            // **リダイレクト先を設定**
            responseContext.setTarget("album");

        } catch (Exception e) {
            System.err.println("Exception occurred in AlbumCommand");
            e.printStackTrace();
            responseContext.setResult("error");
            responseContext.setTarget("error.jsp");
        }

        return responseContext;
    }
}
