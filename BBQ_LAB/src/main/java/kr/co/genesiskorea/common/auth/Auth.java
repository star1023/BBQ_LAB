package kr.co.genesiskorea.common.auth;

import java.io.Serializable;

public class Auth implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private String userId;
	private String userName;
	private String email;
	
	private String userGrade;
	private String userGradeName;
	private String deptCode;
	private String teamCode;
	private String teamCodeName;
	private String deptCodeName;
	
	private String userIp;
	private String sessionId;
	
	private String isAdmin;
	private String theme;
	private String contentMode;
	private String widthMode;
	private String mailCheck1;
	private String mailCheck2;
	private String mailCheck3;
	
	
	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}
	
	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getUserIp() {
		return userIp;
	}

	public void setUserIp(String userIp) {
		this.userIp = userIp;
	}

	public String getSessionId() {
		return sessionId;
	}

	public void setSessionId(String sessionId) {
		this.sessionId = sessionId;
	}
	
	public String getIsAdmin() {
		return isAdmin;
	}

	public void setIsAdmin(String isAdmin) {
		this.isAdmin = isAdmin;
	}
	
	public String getTheme() {
		return theme;
	}

	public void setTheme(String theme) {
		this.theme = theme;
	}
	
	public String getContentMode() {
		return contentMode;
	}

	public void setContentMode(String contentMode) {
		this.contentMode = contentMode;
	}
	
	public String getWidthMode() {
		return widthMode;
	}

	public void setWidthMode(String widthMode) {
		this.widthMode = widthMode;
	}
	
	public String getMailCheck1() {
		return mailCheck1;
	}

	public void setMailCheck1(String mailCheck1) {
		this.mailCheck1 = mailCheck1;
	}
	
	public String getMailCheck2() {
		return mailCheck2;
	}

	public void setMailCheck2(String mailCheck2) {
		this.mailCheck2 = mailCheck2;
	}
	
	public String getMailCheck3() {
		return mailCheck3;
	}

	public void setMailCheck3(String mailCheck3) {
		this.mailCheck3 = mailCheck3;
	}

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
}
