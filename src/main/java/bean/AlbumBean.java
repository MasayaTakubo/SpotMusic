package bean;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

public class AlbumBean {
    private String albumId;  // アルバムID
    private String albumName;  // アルバム名
    private List<String> trackNames = new ArrayList<>();  // アルバム内のトラック名
    private List<TrackBean> trackList = new ArrayList<>();  // アルバム内のトラック情報（TrackBean）
    private String artistName;  // アーティスト名
    private String albumCoverImageUrl;  // アルバムのカバー画像URL

    // コンストラクタでJSONをBeanに変換
    public AlbumBean(JSONObject album, String artistName,String trackImagesJson) {
        this.albumId = album.getString("id");  // アルバムID
        this.albumName = album.getString("name");  // アルバム名
        this.artistName = artistName;  // アーティスト名

        // アルバム内のトラック情報が存在するか確認
        if (album.has("tracks") && album.getJSONObject("tracks").has("items")) {
            JSONArray tracks = album.getJSONObject("tracks").getJSONArray("items");  // アルバム内のトラック情報
            for (int i = 0; i < tracks.length(); i++) {
                JSONObject track = tracks.getJSONObject(i);
                // トラック情報が正しく存在するかを確認し、名前を取得
                if (track.has("name")) {
                    String trackName = track.getString("name");  // トラック名
                    String trackId = track.getString("id");  // トラックID

                    trackNames.add(trackName);  // トラック名

                    // TrackBeanを作成し、trackListに追加
                    trackList.add(new TrackBean(trackId, trackName, artistName,trackImagesJson));
                }
            }
        } else {
            System.out.println("このアルバムにはトラック情報がありません");
        }

        // アルバムのカバー画像URLを取得
        if (album.has("images")) {
            JSONArray images = album.getJSONArray("images");
            if (images.length() > 0) {
                JSONObject image = images.getJSONObject(0);  // 最初の画像（一般的には最大サイズのもの）
                this.albumCoverImageUrl = image.getString("url");  // 画像URLを取得
            }
        }
    }

    // アルバムのIDを取得
    public String getAlbumId() {
        return albumId;
    }

    // アルバムの名前を取得
    public String getAlbumName() {
        return albumName;
    }

    // アルバム内のトラック名を取得
    public List<String> getTrackNames() {
        return trackNames;
    }

    // アルバム内のトラックリストを取得
    public List<TrackBean> getTrackList() {
        return trackList;
    }

    // アーティスト名を取得
    public String getArtistName() {
        return artistName;
    }

    // アルバムのカバー画像URLを取得
    public String getAlbumCoverImageUrl() {
        return albumCoverImageUrl;
    }

    // TrackリストをセットするためのsetTrackListメソッド
    public void setTrackList(List<TrackBean> trackList) {
        this.trackList = trackList;
    }
}
