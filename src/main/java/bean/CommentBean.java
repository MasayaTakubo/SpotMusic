package bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class CommentBean implements Serializable{
    private int commentId;
    private String userId;
    private String playlistId;
    private Timestamp sendTime;
    private String sendComment;
    
    public CommentBean() {}
    public CommentBean(int commentId, String playlistId, String userId, Timestamp sendTime, String sendComment){
        this.commentId=commentId;
        this.playlistId=playlistId;
        this.userId=userId;
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