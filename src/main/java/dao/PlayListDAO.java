package dao;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;

import bean.PlayListBean;
import connector.MySQLConnector;

public class PlayListDAO {
	//MySQLに保存するメソッド
	public void savePlaylistReview(String playlistId, String userId, String playlistName) throws SQLException {
	    String checkSql = "SELECT COUNT(*) FROM playlists WHERE playlist_id = ?";
	    String insertSql = "INSERT INTO playlists (playlist_id, user_id, playlist_name) VALUES (?, ?, ?)";

	    try (Connection con = MySQLConnector.getConn();
	         PreparedStatement checkStmt = con.prepareStatement(checkSql);
	         PreparedStatement insertStmt = con.prepareStatement(insertSql)) {
	        
	        checkStmt.setString(1, playlistId);
	        ResultSet rs = checkStmt.executeQuery();
	        if (rs.next() && rs.getInt(1) > 0) {
	            return; // すでに登録されている場合は何もしない
	        }

	        insertStmt.setString(1, playlistId);
	        insertStmt.setString(2, userId);
	        insertStmt.setString(3, playlistName);
	        insertStmt.executeUpdate();
	    }
	}

	
	//Spotifyから取得するコード達
	public JSONObject getSpotifyPlaylists(String accessToken) throws Exception {
	    // Spotifyのプレイリスト情報を取得するURL
	    URL url = new URL("https://api.spotify.com/v1/me/playlists");
	    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
	    connection.setRequestMethod("GET");
	    connection.setRequestProperty("Authorization", "Bearer " + accessToken);

	    BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
	    String inputLine;
	    StringBuilder response = new StringBuilder();
	    while ((inputLine = in.readLine()) != null) {
	        response.append(inputLine);
	    }
	    in.close();

	    // レスポンスをJSONObjectに変換して返す
	    return new JSONObject(response.toString());
	}
	
	public List<String> getPlaylistNames(String accessToken) throws Exception {
        JSONObject playlists = getSpotifyPlaylists(accessToken);
        List<String> playlistNames = new ArrayList<>();
        if (playlists.has("items")) {
            JSONArray items = playlists.getJSONArray("items");
            for (int i = 0; i < items.length(); i++) {
                String name = items.getJSONObject(i).getString("name");
                playlistNames.add(name);
            }
        }
        return playlistNames;
    }

    /**
     * プレイリストの説明を取得するメソッド
     */
    public List<String> getPlaylistDescriptions(String accessToken) throws Exception {
        JSONObject playlists = getSpotifyPlaylists(accessToken);
        List<String> playlistDescriptions = new ArrayList<>();
        if (playlists.has("items")) {
            JSONArray items = playlists.getJSONArray("items");
            for (int i = 0; i < items.length(); i++) {
                String description = items.getJSONObject(i).optString("description", "説明なし");
                playlistDescriptions.add(description);
            }
        }
        return playlistDescriptions;
    }

    /**
     * プレイリスト内のトラック情報を取得するメソッド
     */
    public Map<String, List<String>> getPlaylistTracks(String accessToken) throws Exception {
        JSONObject playlists = getSpotifyPlaylists(accessToken);
        Map<String, List<String>> playlistTracks = new HashMap<>();
        if (playlists.has("items")) {
            JSONArray items = playlists.getJSONArray("items");
            for (int i = 0; i < items.length(); i++) {
                JSONObject playlist = items.getJSONObject(i);
                String playlistName = playlist.getString("name");
                String tracksUrl = playlist.getJSONObject("tracks").getString("href");

                // トラック情報を取得
                JSONObject tracksResponse = getSpotifyAPIResponse(tracksUrl, accessToken);
                List<String> trackNames = new ArrayList<>();
                if (tracksResponse.has("items")) {
                    JSONArray tracks = tracksResponse.getJSONArray("items");
                    for (int j = 0; j < tracks.length(); j++) {
                        JSONObject track = tracks.getJSONObject(j).getJSONObject("track");
                        trackNames.add(track.getString("name"));
                    }
                }
                playlistTracks.put(playlistName, trackNames);
            }
        }
        return playlistTracks;
    }

    /**
     * プレイリストのカバー画像情報を取得するメソッド
     */
    public Map<String, String> getPlaylistCovers(String accessToken) throws Exception {
        JSONObject playlists = getSpotifyPlaylists(accessToken);
        Map<String, String> playlistCovers = new HashMap<>();
        if (playlists.has("items")) {
            JSONArray items = playlists.getJSONArray("items");
            for (int i = 0; i < items.length(); i++) {
                JSONObject playlist = items.getJSONObject(i);
                String playlistName = playlist.getString("name");
                JSONArray images = playlist.getJSONArray("images");
                String coverUrl = images.length() > 0 ? images.getJSONObject(0).getString("url") : "カバー画像なし";
                playlistCovers.put(playlistName, coverUrl);
            }
        }
        return playlistCovers;
    }

    /**
     * Spotify APIへのGETリクエストを送信してレスポンスを取得
     */
    private JSONObject getSpotifyAPIResponse(String urlString, String accessToken) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);

        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        String inputLine;
        StringBuilder response = new StringBuilder();
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        return new JSONObject(response.toString());
    }
    public List<String> getFriends(String userId) {
        List<String> Friends = new ArrayList<>();
        String sql = "SELECT USER1_ID,USER2_ID FROM Relation WHERE (User1_Id = ? OR User2_Id = ?) AND status = 'ACCEPT'";
        String user1 = null;
        String user2 = null;
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, userId);
            stmt.setString(2, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                user1 = rs.getString("USER1_ID");
                user2 = rs.getString("USER2_ID");
                if(user2.equals(userId)) {
                	Friends.add(user1);//user2が自分ならuser1をフレンドリストに入れる
                }else {
                	Friends.add(user2);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return Friends;
    }
    
    public List<PlayListBean> getFriendPlayList(String friendsId){
        List<PlayListBean> FriendsPlayLists = new ArrayList<>();
        String sql = "SELECT playlist_id,user_id, playlist_name FROM playlists where user_Id = ?";
        try (Connection conn = MySQLConnector.getConn();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, friendsId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
            	PlayListBean FriendsPlayList = new PlayListBean(
            		rs.getString("PLAYLIST_ID"),
            		rs.getString("PLAYLIST_NAME"),
            		rs.getString("USER_ID")
                );
                FriendsPlayLists.add(FriendsPlayList);  // メッセージをリストに追加
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return FriendsPlayLists;
    }
}



