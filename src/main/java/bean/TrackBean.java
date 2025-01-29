package bean;

public class TrackBean {
    private String trackId;
    private String trackName;
    private String artistName;
    private String trackImageUrl; // トラック画像URL
    private String albumImageUrl; // アルバム画像URL
    private String artistImageUrl; // アーティスト画像URL

    // プレイリストのコンストラクタ（4引数）
    public TrackBean(String trackId, String trackName, String artistName, String trackImageUrl) {
        this.trackId = trackId;
        this.trackName = trackName;
        this.artistName = artistName;
        this.trackImageUrl = trackImageUrl;
    }

    // アーティストの情報を登録するときに使用するコンストラクタ（6引数）
    public TrackBean(String trackId, String trackName, String artistName, String trackImageUrl, String albumImageUrl, String artistImageUrl) {
        this.trackId = trackId;
        this.trackName = trackName;
        this.artistName = artistName;
        this.trackImageUrl = trackImageUrl;
        this.albumImageUrl = albumImageUrl;
        this.artistImageUrl = artistImageUrl;
    }

    // GetterとSetter
    public String getTrackId() {
        return trackId;
    }

    public void setTrackId(String trackId) {
        this.trackId = trackId;
    }

    public String getTrackName() {
        return trackName;
    }

    public void setTrackName(String trackName) {
        this.trackName = trackName;
    }

    public String getArtistName() {
        return artistName;
    }

    public void setArtistName(String artistName) {
        this.artistName = artistName;
    }

    public String getTrackImageUrl() {
        return trackImageUrl;
    }

    public void setTrackImageUrl(String trackImageUrl) {
        this.trackImageUrl = trackImageUrl;
    }

    public String getAlbumImageUrl() {
        return albumImageUrl;
    }

    public void setAlbumImageUrl(String albumImageUrl) {
        this.albumImageUrl = albumImageUrl;
    }

    public String getArtistImageUrl() {
        return artistImageUrl;
    }

    public void setArtistImageUrl(String artistImageUrl) {
        this.artistImageUrl = artistImageUrl;
    }
}
