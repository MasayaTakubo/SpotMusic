package bean;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

public class SpotifyPlayListBean {
    private String playlistId;
    private String playlistName;
    private List<String> trackNames = new ArrayList<>(); // トラック名など、プレイリスト内の情報
    private List<TrackBean> trackList = new ArrayList<>(); // トラック情報（TrackBean）
    private String userId;
    private String playlistCoverImageUrl; // プレイリストのカバー画像URL

    // コンストラクタでJSONをBeanに変換
    public SpotifyPlayListBean(JSONObject playlist, String userId) {
        this.playlistId = playlist.getString("id");  // プレイリストID
        this.playlistName = playlist.getString("name");  // プレイリスト名
        this.userId = userId;  // ユーザーID
        
        // プレイリスト内のトラック情報が存在するか確認
        if (playlist.has("tracks") && playlist.getJSONObject("tracks").has("items")) {
            JSONArray tracks = playlist.getJSONObject("tracks").getJSONArray("items");  // プレイリスト内のトラック情報
            for (int i = 0; i < tracks.length(); i++) {
                JSONObject track = tracks.getJSONObject(i);
                // トラック情報が正しく存在するかを確認し、名前を取得
                if (track.has("track") && track.getJSONObject("track").has("name")) {
                    String trackName = track.getJSONObject("track").getString("name");  // トラック名
                    String trackId = track.getJSONObject("track").getString("id"); // トラックID
                    String artistName = track.getJSONObject("track").getJSONArray("artists")
                        .getJSONObject(0).getString("name"); // アーティスト名
                    trackNames.add(trackName);  // トラック名

                    // TrackBeanを作成し、trackListに追加
                    trackList.add(new TrackBean(trackId, trackName, artistName));
                }
            }
        } else {
            System.out.println("このプレイリストにはトラック情報がありません");
        }

        // プレイリストのカバー画像URLを取得
        if (playlist.has("images")) {
            JSONArray images = playlist.getJSONArray("images");
            if (images.length() > 0) {
                JSONObject image = images.getJSONObject(0);  // 最初の画像（一般的には最大サイズのもの）
                this.playlistCoverImageUrl = image.getString("url");  // 画像URLを取得
            }
        }
    }

    // プレイリストのIDを取得
    public String getPlaylistId() {
        return playlistId;
    }

    // プレイリストの名前を取得
    public String getPlaylistName() {
        return playlistName;
    }

    // プレイリスト内のトラック名を取得
    public List<String> getTrackNames() {
        return trackNames;
    }

    // プレイリスト内のトラックリストを取得
    public List<TrackBean> getTrackList() {
        return trackList;
    }

    // ユーザーIDを取得
    public String getUserId() {
        return userId;
    }

    // プレイリストのカバー画像URLを取得
    public String getPlaylistCoverImageUrl() {
        return playlistCoverImageUrl;
    }

    // TrackリストをセットするためのsetTrackListメソッド
    public void setTrackList(List<TrackBean> trackList) {
        this.trackList = trackList;
    }
}
