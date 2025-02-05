package bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class blockBean implements Serializable{
	String userId;
	String relationId;
	String blockId;
	String blockerId;
	String blockedId;
	Timestamp blockTime;
	public blockBean() {}
	public blockBean(String blockerId, String blockedId) {
		this.blockerId = blockerId;
		this.blockedId = blockedId;
	}
	
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public String getRelationId() {
		return relationId;
	}
	public void setRelationId(String relationId) {
		this.relationId = relationId;
	}
	public String getBlockId() {
		return blockId;
	}
	public void setBlockId(String blockId) {
		this.blockId = blockId;
	}
	public String getBlockerId() {
		return blockerId;
	}
	public void setBlockerId(String blockerId) {
		this.blockerId = blockerId;
	}
	public String getBlockedId() {
		return blockedId;
	}
	public void setBlockedId(String blockedId) {
		this.blockedId = blockedId;
	}
	public Timestamp getBlockTime() {
		return blockTime;
	}
	public void setBlockTime(Timestamp blockTime) {
		this.blockTime = blockTime;
	}
	
}