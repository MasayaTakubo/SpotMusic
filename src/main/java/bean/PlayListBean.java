package bean;

public class PlayListBean {
    private String playlistId;
    private String playlistName;
    private String userId;


    // コンストラクタでJSONをBeanに変換
    public PlayListBean(String playlistId,String playlistName, String userId) {
        this.playlistId = playlistId;  // プレイリストID
        this.playlistName = playlistName; // プレイリスト名
        this.userId = userId;  // ユーザーID
    }
    
    public PlayListBean(String playlistId, String userId) {
        this.playlistId = playlistId;  // プレイリストID
        this.userId = userId;  // ユーザーID
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

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
}
