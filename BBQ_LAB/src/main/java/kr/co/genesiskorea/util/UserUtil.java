package kr.co.genesiskorea.util;

import javax.servlet.http.HttpServletRequest;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;

//
public class UserUtil {
	public static String getUserId( HttpServletRequest request ) {
		String userId = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			userId = auth.getUserId();
		} catch( Exception e ) {
			e.printStackTrace();
		}
		return userId;
	}
	
	public static String getUserName( HttpServletRequest request ) {
		String userName = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			userName = auth.getUserName();
		} catch( Exception e ) {
			
		}
		return userName;
	}
	
	public static String getEmail( HttpServletRequest request ) {
		String email = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			email = auth.getEmail();
		} catch( Exception e ) {
			
		}
		return email;
	}
	/*
	public static String getDeptCode( HttpServletRequest request ) {
		String deptCode = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			deptCode = auth.getDeptCode();
		} catch( Exception e ) {
			
		}
		return deptCode;
	}
	
	public static String getDeptCodeName( HttpServletRequest request ) {
		String deptCodeName = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			deptCodeName = auth.getDeptCodeName();
		} catch( Exception e ) {
			
		}
		return deptCodeName;
	}
	
	public static String getTeamCode( HttpServletRequest request ) {
		String teamCode = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			teamCode = auth.getTeamCode();
		} catch( Exception e ) {
			
		}
		return teamCode;
	}
	
	public static String getTeamCodeName( HttpServletRequest request ) {
		String teamCodeName = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			teamCodeName = auth.getTeamCodeName();
		} catch( Exception e ) {
			
		}
		return teamCodeName;
	}
	
	public static String getUserGrade( HttpServletRequest request ) {
		String userGrade = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			userGrade = auth.getUserGrade();
		} catch( Exception e ) {
			
		}
		return userGrade;
	}
	
	public static String getUserGradeName( HttpServletRequest request ) {
		String userGradeName = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			userGradeName = auth.getUserGradeName();
		} catch( Exception e ) {
			
		}
		return userGradeName;
	}*/
	
	/*public static String getUserAuth( HttpServletRequest request ) {
		String userAuth = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			userAuth = auth.getUserAuth();
		} catch( Exception e ) {
			
		}
		return userAuth;
	}
	
	public static String getUserAuthName( HttpServletRequest request ) {
		String userAuthName = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			userAuthName = auth.getUserAuthName();
		} catch( Exception e ) {
			
		}
		return userAuthName;
	}*/
	
	public static String getUserIp( HttpServletRequest request ) {
		String userIp = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			userIp = auth.getUserIp();
		} catch( Exception e ) {
			
		}
		return userIp;
	}
	
	public static String getIsAdmin( HttpServletRequest request ) {
		String isAdmin = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			isAdmin = auth.getIsAdmin();
		} catch( Exception e ) {
			
		}
		return isAdmin;
	}
	
	public static String getTheme( HttpServletRequest request ) {
		String theme = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			theme = auth.getTheme();
		} catch( Exception e ) {
			
		}
		return theme;
	}
	
	public static String getContentMode( HttpServletRequest request ) {
		String contentMode = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			contentMode = auth.getContentMode();
		} catch( Exception e ) {
			
		}
		return contentMode;
	}
	
	public static String getWidthMode( HttpServletRequest request ) {
		String widthMode = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			widthMode = auth.getWidthMode();
		} catch( Exception e ) {
			
		}
		return widthMode;
	}
	
	public static String getMailCheck1( HttpServletRequest request ) {
		String mailCheck1 = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			mailCheck1 = auth.getMailCheck1();
		} catch( Exception e ) {
			
		}
		return mailCheck1;
	}
	
	public static String getMailCheck2( HttpServletRequest request ) {
		String mailCheck2 = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			mailCheck2 = auth.getMailCheck2();
		} catch( Exception e ) {
			
		}
		return mailCheck2;
	}
	
	public static String getMailCheck3( HttpServletRequest request ) {
		String mailCheck3 = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			mailCheck3 = auth.getMailCheck3();
		} catch( Exception e ) {
			
		}
		return mailCheck3;
	}
	
	public static String getRoleCode( HttpServletRequest request ) {
		String roleCode = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			roleCode = auth.getRoleCode();
		} catch( Exception e ) {
			
		}
		return roleCode;
	}
	
	public static String getDeptName( HttpServletRequest request ) {
		String roleCode = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			roleCode = auth.getOBJTTX();
		} catch( Exception e ) {
			
		}
		return roleCode;
	}
	
	public static String getTitleName( HttpServletRequest request ) {
		String roleCode = "";
		try {
			Auth auth = AuthUtil.getAuth(request);
			roleCode = auth.getTITL_TXT();
		} catch( Exception e ) {
			
		}
		return roleCode;
	}
	
}
