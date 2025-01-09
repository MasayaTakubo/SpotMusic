package bean;

import java.io.Serializable;

public class UsersBean implements Serializable {
    private String userId;
    private String accessToken;
    private String refreshToken;
    private int expiresIn;
    private String spotifyId;

    // デフォルトコンストラクタ
    public UsersBean() {}

    // コンストラクタ（すべてのフィールドを初期化）
    public UsersBean(String userId, String accessToken, String refreshToken, int expiresIn, String spotifyId) {
        this.userId = userId;
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
        this.expiresIn = expiresIn;
        this.spotifyId = spotifyId;
    }

    // GetterおよびSetterメソッド
    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public int getExpiresIn() {
        return expiresIn;
    }

    public void setExpiresIn(int expiresIn) {
        this.expiresIn = expiresIn;
    }

    public String getSpotifyId() {
        return spotifyId;
    }

    public void setSpotifyId(String spotifyId) {
        this.spotifyId = spotifyId;
    }

    @Override
    public String toString() {
        return "UsersBean{" +
                "userId='" + userId + '\'' +
                ", accessToken='" + accessToken + '\'' +
                ", refreshToken='" + refreshToken + '\'' +
                ", expiresIn=" + expiresIn +
                ", spotifyId='" + spotifyId + '\'' +
                '}';
    }
}
