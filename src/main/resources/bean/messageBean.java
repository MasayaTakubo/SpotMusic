package bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class messageBean implements Serializable{
	private int messageId;
	private int relationId;
	private String userId;
	private Timestamp sendTime;
	private String sendMessage;
	
	public messageBean() {}
	public messageBean(int messageId, int relationId, String userId, Timestamp sendTime, String sendMessage){
		this.messageId=messageId;
		this.relationId=relationId;
		this.userId=userId;
		this.sendTime=sendTime;
		this.sendMessage=sendMessage;
	}
	public int getMessageId() {
		return messageId;
	}
	public void setMessageId(int messageId) {
		this.messageId=messageId;
	}
	public int getRelationId() {
		return relationId;
	}
	public void setRelationId(int relationId) {
		this.relationId=relationId;
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
	public String getSendMessage() {
		return sendMessage;
	}
	public void setSendMessage(String sendMessage) {
		this.sendMessage=sendMessage;
	}
}