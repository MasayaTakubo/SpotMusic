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
    private String albumImageUrl; // アルバムの画像URL（新しく追加）

    // コンストラクタでJSONをBeanに変換
    public SpotifyPlayListBean(JSONObject playlist, String userId) {
        this.playlistId = playlist.optString("id", "");  // プレイリストID
        this.playlistName = playlist.optString("name", "");  // プレイリスト名
        this.userId = userId;  // ユーザーID

        // プレイリスト内のトラック情報が存在するか確認
        if (playlist.has("tracks") && playlist.getJSONObject("tracks").has("items")) {
            JSONArray tracks = playlist.getJSONObject("tracks").getJSONArray("items");  // プレイリスト内のトラック情報
            for (int i = 0; i < tracks.length(); i++) {
                JSONObject track = tracks.getJSONObject(i);
                // トラック情報が正しく存在するかを確認し、名前を取得
                if (track.has("track") && track.getJSONObject("track").has("name")) {
                    String trackName = track.getJSONObject("track").optString("name", "Unknown Track");  // トラック名
                    String trackId = track.getJSONObject("track").optString("id", "Unknown ID"); // トラックID
                    String artistName = track.getJSONObject("track")
                        .optJSONArray("artists").optJSONObject(0).optString("name", "Unknown Artist"); // アーティスト名

                    // トラック画像URLを取得
                    String trackImageUrl = "";
                    if (track.getJSONObject("track").has("album")) {
                        JSONArray albumImages = track.getJSONObject("track").getJSONObject("album").optJSONArray("images");
                        if (albumImages != null && albumImages.length() > 0) {
                            trackImageUrl = albumImages.getJSONObject(0).optString("url", ""); // 最初の画像URL
                        }
                    }

                    trackNames.add(trackName);  // トラック名

                    // TrackBeanを作成し、trackListに追加
                    trackList.add(new TrackBean(trackId, trackName, artistName, trackImageUrl));
                }
            }
        } else {
            System.out.println("このプレイリストにはトラック情報がありません");
        }


     // プレイリストのカバー画像URLを取得
        JSONArray images = playlist.optJSONArray("images");
        if (images != null && images.length() > 0) {
            this.playlistCoverImageUrl = images.getJSONObject(0).optString("url", null); // null ならデフォルト適用
        } else {
            this.playlistCoverImageUrl = null; // ここでは null にしておく
        }

        // `null` または `""`（空文字）の場合は `JSP` 側で `no_image.png` を適用


        // アルバム画像URLも同じように設定
        this.albumImageUrl = this.playlistCoverImageUrl;

    }

    // 以下、GetterとSetter（省略なし）
    public String getPlaylistId() {
        return playlistId;
    }

    public void setPlaylistId(String playlistId) {
        this.playlistId = playlistId;
    }

    public String getPlaylistName() {
        return playlistName;
    }

    public void setPlaylistName(String playlistName) {
        this.playlistName = playlistName;
    }

    public List<String> getTrackNames() {
        return trackNames;
    }

    public void setTrackNames(List<String> trackNames) {
        this.trackNames = trackNames;
    }

    public List<TrackBean> getTrackList() {
        return trackList;
    }

    public void setTrackList(List<TrackBean> trackList) {
        this.trackList = trackList;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getPlaylistCoverImageUrl() {
        return playlistCoverImageUrl;
    }

    public void setPlaylistCoverImageUrl(String playlistCoverImageUrl) {
        this.playlistCoverImageUrl = playlistCoverImageUrl;
    }

    public String getAlbumImageUrl() {
        return albumImageUrl;
    }

    public void setAlbumImageUrl(String albumImageUrl) {
        this.albumImageUrl = albumImageUrl;
    }

    public String getImageUrl() {
        return albumImageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.albumImageUrl = imageUrl;
    }
}
