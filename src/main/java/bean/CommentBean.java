package bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class CommentBean implements Serializable{
    private int commentId;
    private String playlistId;
    private String userId;
    private String userName;
    private Timestamp sendTime;
    private String sendComment;
    
    public CommentBean() {}
    public CommentBean(int commentId, String playlistId, String userId, String userName,Timestamp sendTime, String sendComment){
        this.commentId=commentId;
        this.playlistId=playlistId;
        this.userId=userId;
        this.userName=userName;
        this.sendTime=sendTime;
        this.sendComment=sendComment;
    }
    
	public int getCommentId() {
        return commentId;
    }
    public void setCommentId(int commentId) {
        this.commentId=commentId;
    }
    
    public String getPlayListId() {
        return playlistId;
    }
    public void setPlayListId(String playlistId) {
        this.playlistId=playlistId;
    }
    
    public String getUserId() {
        return userId;
    }
    public void setUserId(String userId) {
        this.userId=userId;
    }
    
    public String getUserName() {
        return userName;
    }
    public void setUserName(String userName) {
        this.userName=userName;
    }
    
    public Timestamp getSendTime() {
        return sendTime;
    }
    public void setSendTime(Timestamp sendTime) {
        this.sendTime=sendTime;
    }
    public String getSendComment() {
        return sendComment;
    }
    public void setSendComment(String sendComment) {
        this.sendComment=sendComment;
    }   
}