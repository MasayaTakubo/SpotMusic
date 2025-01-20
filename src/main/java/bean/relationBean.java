package bean;

import java.io.Serializable;

public class relationBean implements Serializable{
	int relationId;
	String user1Id;
	String user2Id; 
	String status;
	public relationBean(){}
	public relationBean(int relationId,String user1Id, String user2Id,String status) {
		this.relationId = relationId;
		this.user1Id = user1Id;
		this.user2Id = user2Id;
		this.status = status;
	}
	public int getRelationId() {
		return relationId;
	}
	public void setRelationId(int relationId) {
		this.relationId = relationId;
	}
	public String getUser1Id() {
		return user1Id;
	}
	public void setUser1Id(String user1Id) {
		this.user1Id = user1Id;
	}
	public String getUser2Id() {
		return user2Id;
	}
	public void setUser2Id(String user2Id) {
		this.user2Id = user2Id;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	
}