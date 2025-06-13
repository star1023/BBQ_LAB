package kr.co.genesiskorea.common.auth;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import kr.co.genesiskorea.util.CookieUtil;
import kr.co.genesiskorea.util.StringUtil;

public class AuthUtil {
	public static final String COOKIE_KEY = "BBQLAB_AUTH";
	public static final String COOKIE_SAVE_ID = "BBQLAB_SAVE_ID";
	public static final String SESSION_KEY = "SESS_AUTH";
	public static final String AUTH_KEY = "AUTH";
	public static int SESSION_TIME = 60 * 60 * 2;
	
	
	public static Auth getAuth(HttpServletRequest request) throws Exception {
		HttpSession session = request.getSession();
		Auth auth = (Auth) session.getAttribute(SESSION_KEY);
		return auth != null ? auth : new Auth();
	}
	
	public static Auth getAuth(HttpServletRequest request, HttpServletResponse response) throws Exception {
		Auth auth = getAuth(request);
		return auth != null ? auth : new Auth();
	}
	
	public static void setAuth(HttpServletRequest request, Auth auth) throws Exception {
		removeAuth(request);
		HttpSession session = request.getSession();

		if (auth == null) {
			auth = new Auth();
		}

		auth.setUserIp(getClientIpAddress(request));
		auth.setSessionId(session.getId());

		session.setAttribute(SESSION_KEY, auth);
		session.setMaxInactiveInterval(SESSION_TIME);
	}
	
	public static void setAuth(HttpServletRequest request, HttpServletResponse response, Auth auth) throws Exception {
		setAuth(request, auth);
	}
	
	public static void removeAuth(HttpServletRequest request) throws Exception {
		HttpSession session = request.getSession();
		session.removeAttribute(SESSION_KEY);
	}
	
	public static boolean hasAuth(HttpServletRequest request) throws Exception {
		Auth auth = getAuth(request);
		
		return StringUtil.isNotEmpty(auth.getUserId());
	}
	
	public static Auth getAuthByToekn(HttpServletRequest request, HttpServletResponse response) throws Exception {
		Auth auth = null;
		return auth;
	}
	
	public static String getAuthToken(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CookieUtil cu = new CookieUtil(request, response);
		return cu.getCookie(COOKIE_KEY);
	}
	
	public static Auth parseAuthToken(String authToken) throws Exception {
		Map<String, String> map = new HashMap<String, String>();
		String[] auths = StringUtil.split(authToken, ",");
		for (String row : auths) {
			String[] data = StringUtil.split(row, "=");
			String key = data[0].trim();
			String value = data[1].trim();
			map.put(key, value);
		}

		Auth auth = new Auth();
		return auth;
	}
	
	public static String getClientIpAddress(HttpServletRequest request) {
		
		String ip = request.getHeader("X-Forwarded-For");
        if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
		return ip;
	}
	
	public static boolean isEmpty(String str) {
		return ((str == null) || (str.length() == 0));
	}

	public static boolean isEmpty(Object str) {
		
		if(str == null) {
			return true;
		}
		
		return isEmpty(str.toString()) ;
	}
}
