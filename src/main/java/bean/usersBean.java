package bean;

import java.io.Serializable;

public class usersBean implements Serializable {
    private String userId;
    private String accessToken;
    private String refreshToken;
    private int expiresIn;
    private String spotifyId;
    private String userName;

    // デフォルトコンストラクタ
    public usersBean() {}

    // コンストラクタ（すべてのフィールドを初期化）
    public usersBean(String userId, String accessToken, String refreshToken, int expiresIn, String spotifyId) {
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

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
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
