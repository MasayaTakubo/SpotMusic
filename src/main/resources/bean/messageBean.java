package bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class messageBean implements Serializable{
	private int MESSAGE_ID;
	private int RELATION_ID;
	private String USER_ID;
	private Timestamp SEND_TIME;
	private String SEND_MESSAGE;
	
	public messageBean() {}
	public messageBean(int MESSAGE_ID, int RELATION_ID, String USER_ID, Timestamp SEND_TIME, String SEND_MESSAGE){
		this.MESSAGE_ID=MESSAGE_ID;
		this.RELATION_ID=RELATION_ID;
		this.USER_ID=USER_ID;
		this.SEND_TIME=SEND_TIME;
		this.SEND_MESSAGE=SEND_MESSAGE;
	}
	public int getMESSAGE_ID() {
		return MESSAGE_ID;
	}
	public void setMESSAGE_ID(int MESSAGE_ID) {
		this.MESSAGE_ID=MESSAGE_ID;
	}
	public int getRELATION_ID() {
		return RELATION_ID;
	}
	public void setRELATION_ID(int RELATION_ID) {
		this.RELATION_ID=RELATION_ID;
	}
	public String getUSER_ID() {
		return USER_ID;
	}
	public void setUSER_ID(String USER_ID) {
		this.USER_ID=USER_ID;
	}
	public Timestamp getSEND_TIME() {
		return SEND_TIME;
	}
	public void setSEND_TIME(Timestamp SEND_TIME) {
		this.SEND_TIME=SEND_TIME;
	}
	public String getSEND_MESSAGE() {
		return SEND_MESSAGE;
	}
	public void setSEND_MESSAGE(String SEND_MESSAGE) {
		this.SEND_MESSAGE=SEND_MESSAGE;
	}
}