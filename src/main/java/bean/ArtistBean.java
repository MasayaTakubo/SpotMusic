package bean;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
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
    public ArtistBean(JSONObject artist, JSONArray topTracksJson, JSONArray playlistsJson) {
        this.artistId = artist.getString("id"); // アーティストID
        this.artistName = artist.getString("name"); // アーティスト名
        this.artistGenres = extractGenres(artist.getJSONArray("genres")); // ジャンル
        this.followers = artist.getJSONObject("followers").getInt("total"); // フォロワー数

        // アーティスト画像URLの取得
        if (artist.has("images") && artist.getJSONArray("images").length() > 0) {
            this.artistImageUrl = artist.getJSONArray("images").getJSONObject(0).getString("url");
        }

        // 人気曲のリストを取得
        for (int i = 0; i < topTracksJson.length(); i++) {
            JSONObject track = topTracksJson.getJSONObject(i);
            String trackId = track.getString("id");
            String trackName = track.getString("name");
            String artistName = track.getJSONArray("artists").getJSONObject(0).getString("name");
            topTracks.add(new TrackBean(trackId, trackName, artistName));
        }

        // プレイリスト情報のリストを取得
        for (int i = 0; i < playlistsJson.length(); i++) {
            JSONObject playlist = playlistsJson.getJSONObject(i);
            SpotifyPlayListBean playlistBean = new SpotifyPlayListBean(playlist, this.artistId);
            playlists.add(playlistBean);
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
