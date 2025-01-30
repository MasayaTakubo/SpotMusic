package bean;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class ArtistBean {
    private String artistId; // アーティストID
    private String artistName; // アーティスト名
    private String artistGenres; // アーティストのジャンル（カンマ区切り）
    private int followers; // フォロワー数
    private String artistImageUrl; // アーティストの画像URL
    private List<TrackBean> topTracks = new ArrayList<>(); // 人気曲のリスト
    private List<SpotifyPlayListBean> playlists = new ArrayList<>(); // アーティストのプレイリスト

    // コンストラクタでJSONをBeanに変換
    public ArtistBean(JSONObject artist, JSONArray topTracksJson, JSONArray playlistsJson, String trackImagesJson) {
        this.artistId = artist.getString("id"); 
        this.artistName = artist.getString("name"); 
        this.artistGenres = extractGenres(artist.getJSONArray("genres")); 
        this.followers = artist.getJSONObject("followers").getInt("total"); 

        // アーティスト画像URLの取得
        if (artist.has("images") && artist.getJSONArray("images").length() > 0) {
            this.artistImageUrl = artist.getJSONArray("images").getJSONObject(0).getString("url");
        }

        // 人気曲リストの取得
        for (int i = 0; i < topTracksJson.length(); i++) {
            JSONObject track = topTracksJson.getJSONObject(i);
            String trackId = track.getString("id");
            String trackName = track.getString("name");
            String trackArtistName = track.getJSONArray("artists").getJSONObject(0).getString("name");

            JSONObject album = track.getJSONObject("album");
            String trackImage = album.optString("url", "");

            topTracks.add(new TrackBean(trackId, trackName, trackArtistName, trackImage));
        }

        // プレイリスト情報の取得
        for (int i = 0; i < playlistsJson.length(); i++) {
            JSONObject playlist = playlistsJson.getJSONObject(i);
            SpotifyPlayListBean playlistBean = new SpotifyPlayListBean(playlist, this.artistId);
            playlists.add(playlistBean);
        }

        // trackImagesJsonを処理
        if (trackImagesJson != null && !trackImagesJson.isEmpty()) {
            try {
                JSONObject trackImagesJsonObject = new JSONObject(trackImagesJson);
                // 必要な処理をここで行う
            } catch (JSONException e) {
                System.err.println("Invalid JSON format for trackImagesJson: " + trackImagesJson);
            }
        }
    }


    // アーティストIDを取得
    public String getArtistId() {
        return artistId;
    }

    // アーティスト名を取得
    public String getArtistName() {
        return artistName;
    }

    // アーティストのジャンルを取得
    public String getArtistGenres() {
        return artistGenres;
    }

    // アーティストのフォロワー数を取得
    public int getFollowers() {
        return followers;
    }

    // アーティストの画像URLを取得
    public String getArtistImageUrl() {
        return artistImageUrl;
    }

    // 人気曲リストを取得
    public List<TrackBean> getTopTracks() {
        return topTracks;
    }

    // プレイリスト情報を取得
    public List<SpotifyPlayListBean> getPlaylists() {
        return playlists;
    }

    // アーティストのジャンルをカンマ区切りの文字列として取得
    private String extractGenres(JSONArray genresJson) {
        StringBuilder genres = new StringBuilder();
        for (int i = 0; i < genresJson.length(); i++) {
            if (i > 0) {
                genres.append(", ");
            }
            genres.append(genresJson.getString(i));
        }
        return genres.toString();
    }
}
