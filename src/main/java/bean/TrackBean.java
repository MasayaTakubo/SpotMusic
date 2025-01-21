package bean;

public class TrackBean {
    private String trackId;
    private String trackName;
    private String artistName;
    private String previewUrl;

    // コンストラクタ
    public TrackBean(String trackId, String trackName, String artistName) {
        this.trackId = trackId;
        this.trackName = trackName;
        this.artistName = artistName;
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
    
    public String getPreviewUrl() {
        return previewUrl;
    }

    public void setPreviewUrl(String previewUrl) {
        this.previewUrl = previewUrl;
    }
}
