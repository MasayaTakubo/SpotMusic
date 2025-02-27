package command;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.json.JSONArray;
import org.json.JSONObject;

import context.RequestContext;
import context.ResponseContext;

public class SpotifySearchCommand extends AbstractCommand {
    private static final String SPOTIFY_API_URL = "https://api.spotify.com/v1/search";

    @Override
    public ResponseContext execute(ResponseContext responseContext) {
        System.out.println("?? SpotifySearchCommand: execute() called");

        RequestContext reqContext = getRequestContext();
        HttpServletRequest request = (HttpServletRequest) reqContext.getRequest();

        String action = request.getParameter("action");
        String query = request.getParameter("query");
        String id = request.getParameter("id");
        System.out.println("?? Received action: " + action + ", query: " + query + ", id: " + id + "&market=JP&locale=ja_JP");

        String accessToken = (String) request.getSession().getAttribute("access_token");
        if (accessToken == null) {
            System.out.println("?? ERROR: Spotify にログインしていません。");
            return createErrorResponse(responseContext, "Spotifyにログインしていません。");
        }

        try {
            if ("album".equals(action) && id != null) {
                return handleAlbumDetail(responseContext, request, id, accessToken);
            } else if ("artist".equals(action) && id != null) {
                return handleArtistDetail(responseContext, request, id, accessToken);
            } else if ("playlist".equals(action) && id != null) {
                return handlePlaylistDetail(responseContext, request, id, accessToken);
            } else if (query != null && !query.trim().isEmpty()) {
                return handleSearch(responseContext, request, query, accessToken);
            } else {
                System.out.println("?? ERROR: 無効なリクエスト");
                return createErrorResponse(responseContext, "無効なリクエスト");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return createErrorResponse(responseContext, "Internal Server Error: " + e.getMessage());
        }
    }


    /*** ?? Spotify検索を実行 ***/
    private ResponseContext handleSearch(ResponseContext responseContext, HttpServletRequest request, String query, String accessToken) throws IOException {
        System.out.println("?? Executing Spotify search for query: " + query);

        JSONObject json = new JSONObject(searchSpotify(query, accessToken));

        // **?? 各カテゴリーのデータ取得**
        JSONArray tracksArray = json.optJSONObject("tracks") != null ? json.optJSONObject("tracks").optJSONArray("items") : null;
        JSONArray albumsArray = json.optJSONObject("albums") != null ? json.optJSONObject("albums").optJSONArray("items") : null;
        JSONArray artistsArray = json.optJSONObject("artists") != null ? json.optJSONObject("artists").optJSONArray("items") : null;
        JSONArray playlistsArray = json.optJSONObject("playlists") != null ? json.optJSONObject("playlists").optJSONArray("items") : null;

        // **?? 各リストを JSP 用に変換**
        List<Map<String, Object>> trackList = convertTracks(tracksArray);
        List<Map<String, Object>> albumList = convertAlbums(albumsArray);
        List<Map<String, Object>> artistList = convertArtists(artistsArray);
        List<Map<String, Object>> playlistList = convertPlaylists(playlistsArray);

        // **?? ユーザーのプレイリストを取得**
        String userPlaylistsUrl = "https://api.spotify.com/v1/me/playlists";
        JSONObject playlistResponse = new JSONObject(sendSpotifyRequest(userPlaylistsUrl, accessToken));
        JSONArray userPlaylistsArray = playlistResponse.optJSONArray("items");
        List<Map<String, Object>> userPlaylists = convertPlaylists(userPlaylistsArray);

        // **?? JSP にデータを渡す**
        request.setAttribute("tracks", trackList);
        request.setAttribute("albums", albumList);
        request.setAttribute("artists", artistList);
        request.setAttribute("playlists", playlistList);
        request.setAttribute("query", query);
        request.setAttribute("userPlaylists", userPlaylists); // ?? ユーザーのプレイリストもセット！
        // **?? JSP のパスを設定**
        responseContext.setTarget("search");

        System.out.println("?? Target set to: " + responseContext.getTarget());
        return responseContext;
    }






    /*** ?? JSONデータをリストに変換 ***/
    public static class JsonToListConverter {
        public static List<Map<String, Object>> convertJSONArrayToList(JSONArray jsonArray) {
            List<Map<String, Object>> list = new ArrayList<>();
            if (jsonArray == null) return list;

            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject jsonObject = jsonArray.optJSONObject(i);
                Map<String, Object> map = new HashMap<>();
                for (String key : jsonObject.keySet()) {
                    map.put(key, jsonObject.get(key));
                }
                list.add(map);
            }
            return list;
        }
    }

    /*** ?? Spotify API リクエスト送信 ***/
    private String sendSpotifyRequest(String urlString, String accessToken) throws IOException {
        System.out.println("?? Sending Spotify API request: " + urlString);

        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        connection.setRequestProperty("Content-Type", "application/json");

        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8));
        StringBuilder response = new StringBuilder();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        System.out.println("?? Spotify API Response: " + response.toString());
        return response.toString();
    }

    /*** ?? Spotify検索APIを実行 ***/
    private String searchSpotify(String query, String accessToken) throws IOException {
        String encodedQuery = URLEncoder.encode(query, StandardCharsets.UTF_8.toString());
        String urlString = SPOTIFY_API_URL + "?q=" + encodedQuery + "&type=track,album,artist,playlist&limit=10&market=JP&locale=ja_JP";
        return sendSpotifyRequest(urlString, accessToken);
    }

    /*** ?? エラーレスポンスを作成 ***/
    private ResponseContext createErrorResponse(ResponseContext responseContext, String message) {
        System.out.println("?? createErrorResponse called with message: " + message);

        JSONObject errorResponse = new JSONObject();
        errorResponse.put("error", message);

        responseContext.setContentType("application/json");
        responseContext.setResult(errorResponse.toString());

        System.out.println("?? Returning responseContext with error. Target: " + responseContext.getTarget());
        return responseContext;
    }
    
    private List<Map<String, Object>> convertTracks(JSONArray jsonArray) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (jsonArray == null) return list;

        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObject = jsonArray.optJSONObject(i);
            Map<String, Object> map = new HashMap<>();
            map.put("id", jsonObject.optString("id"));
            map.put("name", jsonObject.optString("name"));
            map.put("track_number", jsonObject.optInt("track_number", 0));
            map.put("image", extractImageUrl(jsonObject.optJSONObject("album")));
            System.out.println("?? Track name: " + map.get("name") + ", Image URL: " + map.get("image"));
            list.add(map);
        }
        return list;
    }

    private List<Map<String, Object>> convertAlbums(JSONArray jsonArray) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (jsonArray == null) return list;

        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObject = jsonArray.optJSONObject(i);
            if (jsonObject == null) continue;
            
            Map<String, Object> map = new HashMap<>();
            map.put("id", jsonObject.optString("id"));
            map.put("name", jsonObject.optString("name"));
            map.put("image", extractImageUrl(jsonObject)); // ?? String に統一

            list.add(map);
        }
        return list;
    }




    private List<Map<String, Object>> convertArtists(JSONArray jsonArray) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (jsonArray == null) return list;

        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObject = jsonArray.optJSONObject(i);
            if (jsonObject == null) continue;

            Map<String, Object> map = new HashMap<>();
            map.put("id", jsonObject.optString("id"));
            map.put("name", jsonObject.optString("name"));
            map.put("image", extractImageUrl(jsonObject)); // ?? String に統一

            list.add(map);
        }
        return list;
    }



    private List<Map<String, Object>> convertPlaylists(JSONArray jsonArray) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (jsonArray == null) {
            System.out.println("?? convertPlaylists: jsonArray is null. Returning empty list.");
            return list;
        }

        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObject = jsonArray.optJSONObject(i);
            if (jsonObject == null) {
                System.out.println("?? convertPlaylists: jsonObject at index " + i + " is null. Skipping.");
                continue;
            }

            Map<String, Object> map = new HashMap<>();
            map.put("id", jsonObject.optString("id", "unknown_id"));
            map.put("name", jsonObject.optString("name", "No Name"));
            map.put("image", extractImageUrl(jsonObject)); // ?? String に統一

            list.add(map);
        }
        return list;
    }



    private String extractImageUrl(JSONObject jsonObject) {
        if (jsonObject == null) {
            System.out.println("?? extractImageUrl: jsonObject is null, returning default image.");
            return "/img/no_image.png";
        }
        
        JSONArray imagesArray = jsonObject.optJSONArray("images");
        if (imagesArray != null && imagesArray.length() > 0) {
            JSONObject firstImage = imagesArray.optJSONObject(0);
            if (firstImage != null) {
                return firstImage.optString("url", "/img/no_image.png");
            }
        }
        
        return "/img/no_image.png";
    }
    private ResponseContext handleAlbumDetail(ResponseContext responseContext, HttpServletRequest request, String albumId, String accessToken) throws IOException {
        System.out.println("?? Fetching album details for ID: " + albumId);

        // **アルバム情報の取得**
        String urlString = "https://api.spotify.com/v1/albums/" + albumId + "?market=JP&locale=ja_JP";
        JSONObject albumJson = new JSONObject(sendSpotifyRequest(urlString, accessToken));

        // **アルバムの基本情報を取得**
        Map<String, Object> album = new HashMap<>();
        album.put("id", albumJson.optString("id"));
        album.put("name", albumJson.optString("name"));
        album.put("release_date", albumJson.optString("release_date"));

        // **アルバム画像の取得**
        JSONArray imagesArray = albumJson.optJSONArray("images");
        List<Map<String, Object>> imagesList = new ArrayList<>();
        if (imagesArray != null) {
            for (int i = 0; i < imagesArray.length(); i++) {
                JSONObject imageObject = imagesArray.optJSONObject(i);
                if (imageObject != null) {
                    Map<String, Object> imageMap = new HashMap<>();
                    imageMap.put("url", imageObject.optString("url", "/img/no_image.png"));
                    imagesList.add(imageMap);
                }
            }
        }
        album.put("images", imagesList);

        // **収録曲の取得**
        JSONArray tracksArray = albumJson.optJSONObject("tracks") != null ? albumJson.optJSONObject("tracks").optJSONArray("items") : null;
        List<Map<String, Object>> trackList = new ArrayList<>();
        if (tracksArray != null) {
            for (int i = 0; i < tracksArray.length(); i++) {
                JSONObject trackObject = tracksArray.optJSONObject(i);
                if (trackObject == null) continue;

                Map<String, Object> trackInfo = new HashMap<>();
                trackInfo.put("id", trackObject.optString("id"));
                trackInfo.put("name", trackObject.optString("name"));
                trackInfo.put("track_number", trackObject.optInt("track_number", 0));

                // **アルバム画像の取得**
                String trackImageUrl = imagesList.isEmpty() ? "/img/no_image.png" : imagesList.get(0).get("url").toString();
                trackInfo.put("image", trackImageUrl);

                trackList.add(trackInfo);
            }
        }

        // **ユーザーのプレイリスト情報を取得**
        String userPlaylistsUrl = "https://api.spotify.com/v1/me/playlists";
        JSONObject playlistResponse = new JSONObject(sendSpotifyRequest(userPlaylistsUrl, accessToken));
        JSONArray userPlaylistsArray = playlistResponse.optJSONArray("items");
        List<Map<String, Object>> userPlaylists = convertPlaylists(userPlaylistsArray);

        // **もともとの検索ワード (`query`) を取得**
        String query = request.getParameter("query");
        if (query == null || query.trim().isEmpty()) {
            query = "top albums";  // デフォルト検索ワード
        }
        System.out.println("?? Using search query: " + query);

        // **Spotify検索データも取得 (タブ用データ)**
        JSONObject json = new JSONObject(searchSpotify(query, accessToken));

        JSONArray albumsArray = json.optJSONObject("albums") != null ? json.optJSONObject("albums").optJSONArray("items") : null;
        JSONArray artistsArray = json.optJSONObject("artists") != null ? json.optJSONObject("artists").optJSONArray("items") : null;
        JSONArray playlistsArray = json.optJSONObject("playlists") != null ? json.optJSONObject("playlists").optJSONArray("items") : null;

        // **データを変換**
        List<Map<String, Object>> albumList = convertAlbums(albumsArray);
        List<Map<String, Object>> artistList = convertArtists(artistsArray);
        List<Map<String, Object>> playlistList = convertPlaylists(playlistsArray);

        // **JSP にデータを渡す**
        request.setAttribute("album", album);
        request.setAttribute("tracks", trackList);
        request.setAttribute("userPlaylists", userPlaylists);
        request.setAttribute("albums", albumList);
        request.setAttribute("artists", artistList);
        request.setAttribute("playlists", playlistList);
        request.setAttribute("query", query);

        // **JSP のターゲットを設定**
        responseContext.setTarget("searchalbum");

        return responseContext;
    }




    // 収録曲の画像情報を渡すために修正したconvertTracksメソッド
    private List<Map<String, Object>> convertTracks(JSONArray jsonArray, List<Map<String, Object>> albumImages) {
        List<Map<String, Object>> trackList = new ArrayList<>();
        if (jsonArray == null) return trackList;

        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObject = jsonArray.optJSONObject(i);
            Map<String, Object> map = new HashMap<>();
            map.put("id", jsonObject.optString("id"));
            map.put("name", jsonObject.optString("name"));
            map.put("track_number", jsonObject.optInt("track_number", 0));

            // アルバム画像を収録曲に追加
            String imageUrl = albumImages.isEmpty() ? "no_image.png" : (String) albumImages.get(0).get("url");
            map.put("image", imageUrl);

            System.out.println("?? Track name: " + map.get("name") + ", Image URL: " + map.get("image"));
            trackList.add(map);
        }
        return trackList;
    }

    
 // アーティスト詳細を処理するメソッド
    private ResponseContext handleArtistDetail(ResponseContext responseContext, HttpServletRequest request, String artistId, String accessToken) throws IOException {
        System.out.println("?? Fetching artist details for ID: " + artistId);

        // **アーティスト情報の取得**
        String urlString = "https://api.spotify.com/v1/artists/" + artistId + "?market=JP&locale=ja_JP";
        JSONObject artistJson;
        try {
            artistJson = new JSONObject(sendSpotifyRequest(urlString, accessToken));
        } catch (IOException e) {
            System.out.println("?? ERROR: Failed to fetch artist details.");
            return createErrorResponse(responseContext, "アーティスト情報の取得に失敗しました。");
        }

        // **アーティストの基本情報**
        Map<String, Object> artist = new HashMap<>();
        artist.put("id", artistJson.optString("id", "unknown_id"));
        artist.put("name", artistJson.optString("name", "No Name"));
        artist.put("followers", artistJson.optJSONObject("followers") != null ? artistJson.optJSONObject("followers").optInt("total") : 0);

        // **アーティストの画像**
        JSONArray imagesArray = artistJson.optJSONArray("images");
        List<Map<String, Object>> imagesList = new ArrayList<>();
        if (imagesArray != null) {
            for (int i = 0; i < imagesArray.length(); i++) {
                JSONObject imageObject = imagesArray.optJSONObject(i);
                if (imageObject != null) {
                    Map<String, Object> imageMap = new HashMap<>();
                    imageMap.put("url", imageObject.optString("url", "/img/no_image.png"));
                    imagesList.add(imageMap);
                }
            }
        }
        artist.put("images", imagesList);

        // **人気曲の取得**
        System.out.println("?? Fetching top tracks for artist.");
        String topTracksUrl = "https://api.spotify.com/v1/artists/" + artistId + "/top-tracks?market=JP&locale=ja_JP";
        JSONObject topTracksResponse;
        try {
            topTracksResponse = new JSONObject(sendSpotifyRequest(topTracksUrl, accessToken));
        } catch (IOException e) {
            System.out.println("?? ERROR: Failed to fetch top tracks.");
            return createErrorResponse(responseContext, "アーティストの人気曲の取得に失敗しました。");
        }

        JSONArray topTracksArray = topTracksResponse.optJSONArray("tracks");
        List<Map<String, Object>> topTracksList = convertTracksWithImages(topTracksArray);

        // **ログイン中のユーザーのプレイリスト情報を取得**
        System.out.println("?? Fetching user's playlists.");
        String userPlaylistsUrl = "https://api.spotify.com/v1/me/playlists";
        JSONObject playlistResponse;
        try {
            playlistResponse = new JSONObject(sendSpotifyRequest(userPlaylistsUrl, accessToken));
        } catch (IOException e) {
            System.out.println("?? ERROR: Failed to fetch user's playlists.");
            return createErrorResponse(responseContext, "ユーザーのプレイリスト情報の取得に失敗しました。");
        }

        JSONArray userPlaylistsArray = playlistResponse.optJSONArray("items");
        List<Map<String, Object>> userPlaylists = convertPlaylists(userPlaylistsArray);

        // **検索ワード (query) を取得**
        String query = request.getParameter("query");
        if (query == null || query.trim().isEmpty()) {
            query = "top artists";  // 空の場合はデフォルトワード
        }
        System.out.println("?? Using search query: " + query);

        // **Spotify検索データの取得**
        System.out.println("?? Fetching related search data.");
        JSONObject json;
        try {
            json = new JSONObject(searchSpotify(query, accessToken));
        } catch (IOException e) {
            System.out.println("?? ERROR: Failed to fetch search data.");
            return createErrorResponse(responseContext, "関連検索データの取得に失敗しました。");
        }

        JSONArray albumsArray = json.optJSONObject("albums") != null ? json.optJSONObject("albums").optJSONArray("items") : null;
        JSONArray artistsArray = json.optJSONObject("artists") != null ? json.optJSONObject("artists").optJSONArray("items") : null;
        JSONArray playlistsArray = json.optJSONObject("playlists") != null ? json.optJSONObject("playlists").optJSONArray("items") : null;

        // **データの変換**
        List<Map<String, Object>> albumList = convertAlbums(albumsArray);
        List<Map<String, Object>> artistList = convertArtists(artistsArray);
        List<Map<String, Object>> playlistList = convertPlaylists(playlistsArray);

        // **JSP にデータを渡す**
        request.setAttribute("artist", artist);
        request.setAttribute("top_tracks", topTracksList);
        request.setAttribute("userPlaylists", userPlaylists);
        request.setAttribute("albums", albumList);
        request.setAttribute("artists", artistList);
        request.setAttribute("playlists", playlistList);
        request.setAttribute("query", query);

        // **JSP のターゲットを設定**
        responseContext.setTarget("searchartist");

        return responseContext;
    }



    // 人気曲に画像をセットするメソッド
    private List<Map<String, Object>> convertTracksWithImages(JSONArray tracksArray) {
        List<Map<String, Object>> trackList = new ArrayList<>();
        if (tracksArray == null) return trackList;

        for (int i = 0; i < tracksArray.length(); i++) {
            JSONObject trackObject = tracksArray.optJSONObject(i);
            if (trackObject == null) continue;

            JSONObject track = trackObject;
            Map<String, Object> trackInfo = new HashMap<>();
            trackInfo.put("name", track.optString("name", "不明なトラック"));
            trackInfo.put("id", track.optString("id", "unknown_id"));

            // アルバム情報から画像を取得
            JSONObject album = track.optJSONObject("album");
            JSONArray imagesArray = (album != null) ? album.optJSONArray("images") : null;
            String imageUrl = "no_image.png"; // デフォルト画像
            if (imagesArray != null && imagesArray.length() > 0) {
                imageUrl = imagesArray.optJSONObject(0).optString("url", "no_image.png");
            }

            trackInfo.put("image", imageUrl); // トラックの画像URLをセット
            trackList.add(trackInfo);
        }
        return trackList;
    }


    private ResponseContext handlePlaylistDetail(ResponseContext responseContext, HttpServletRequest request, String playlistId, String accessToken) throws IOException {
        System.out.println("?? Fetching playlist details for ID: " + playlistId);

        // **プレイリスト情報の取得**
        String urlString = "https://api.spotify.com/v1/playlists/" + playlistId + "?market=JP&locale=ja_JP";
        JSONObject playlistJson;
        try {
            playlistJson = new JSONObject(sendSpotifyRequest(urlString, accessToken));
        } catch (IOException e) {
            System.out.println("?? ERROR: Failed to fetch playlist details.");
            return createErrorResponse(responseContext, "プレイリスト情報の取得に失敗しました。");
        }

        // **プレイリストの基本情報を取得**
        Map<String, Object> playlist = new HashMap<>();
        playlist.put("id", playlistJson.optString("id", "unknown_id"));
        playlist.put("name", playlistJson.optString("name", "No Name"));
        playlist.put("owner", playlistJson.optJSONObject("owner") != null ? playlistJson.optJSONObject("owner").optString("display_name", "Unknown") : "Unknown");

        // **画像情報の取得**
        JSONArray imagesArray = playlistJson.optJSONArray("images");
        List<Map<String, Object>> imagesList = new ArrayList<>();
        if (imagesArray != null) {
            for (int i = 0; i < imagesArray.length(); i++) {
                JSONObject imageObject = imagesArray.optJSONObject(i);
                if (imageObject != null) {
                    Map<String, Object> imageMap = new HashMap<>();
                    imageMap.put("url", imageObject.optString("url", "/img/no_image.png"));
                    imagesList.add(imageMap);
                }
            }
        }
        playlist.put("images", imagesList);

        // **収録トラックの取得**
        JSONArray tracksArray = playlistJson.optJSONObject("tracks") != null ? playlistJson.optJSONObject("tracks").optJSONArray("items") : null;
        List<Map<String, Object>> trackList = new ArrayList<>();
        if (tracksArray != null) {
            for (int i = 0; i < tracksArray.length(); i++) {
                JSONObject trackObject = tracksArray.optJSONObject(i);
                if (trackObject == null || !trackObject.has("track")) continue;

                JSONObject track = trackObject.getJSONObject("track");
                Map<String, Object> trackInfo = new HashMap<>();
                trackInfo.put("id", track.optString("id", "unknown_id"));
                trackInfo.put("name", track.optString("name", "No Name"));
                trackInfo.put("track_number", track.optInt("track_number", 0));

                // **アルバム画像の取得**
                JSONObject album = track.optJSONObject("album");
                String trackImageUrl = extractImageUrl3(album);
                trackInfo.put("image", trackImageUrl);

                trackList.add(trackInfo);
            }
        }

        // **ログイン中のユーザーのプレイリスト情報を取得**
        System.out.println("?? Fetching user's playlists.");
        String userPlaylistsUrl = "https://api.spotify.com/v1/me/playlists";
        JSONObject playlistResponse;
        try {
            playlistResponse = new JSONObject(sendSpotifyRequest(userPlaylistsUrl, accessToken));
        } catch (IOException e) {
            System.out.println("?? ERROR: Failed to fetch user's playlists.");
            return createErrorResponse(responseContext, "ユーザーのプレイリスト情報の取得に失敗しました。");
        }

        JSONArray userPlaylistsArray = playlistResponse.optJSONArray("items");
        List<Map<String, Object>> userPlaylists = convertPlaylists(userPlaylistsArray);

        // **検索クエリの取得**
        String query = request.getParameter("query");
        if (query == null || query.trim().isEmpty()) {
            query = "top playlists";  // 空の場合はデフォルトワード
        }
        System.out.println("?? Using search query: " + query);

        // **Spotify検索データの取得**
        JSONObject json = new JSONObject(searchSpotify(query, accessToken));

        JSONArray albumsArray = json.optJSONObject("albums") != null ? json.optJSONObject("albums").optJSONArray("items") : null;
        JSONArray artistsArray = json.optJSONObject("artists") != null ? json.optJSONObject("artists").optJSONArray("items") : null;
        JSONArray playlistsArray = json.optJSONObject("playlists") != null ? json.optJSONObject("playlists").optJSONArray("items") : null;

        // **データの変換**
        List<Map<String, Object>> albumList = convertAlbums(albumsArray);
        List<Map<String, Object>> artistList = convertArtists(artistsArray);
        List<Map<String, Object>> playlistList = convertPlaylists(playlistsArray);

        // **JSP にデータを渡す**
        request.setAttribute("playlist", playlist);
        request.setAttribute("tracks", trackList);
        request.setAttribute("userPlaylists", userPlaylists);
        request.setAttribute("albums", albumList); // 追加
        request.setAttribute("artists", artistList); // 追加
        request.setAttribute("playlists", playlistList); // 追加
        request.setAttribute("query", query); // 追加

        // **JSP のターゲットを設定**
        responseContext.setTarget("searchplaylist");

        return responseContext;
    }



    // 曲のアルバムから画像URLを抽出するメソッド
    private String extractImageUrl3(JSONObject albumJson) {
        if (albumJson == null) {
            return "/img/no_image.png"; // デフォルト画像
        }

        JSONArray imagesArray = albumJson.optJSONArray("images");
        if (imagesArray != null && imagesArray.length() > 0) {
            JSONObject firstImage = imagesArray.optJSONObject(0);
            if (firstImage != null) {
                return firstImage.optString("url", "/img/no_image.png");
            }
        }
        
        return "/img/no_image.png";
    }



}
