package kr.co.genesiskorea.util;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 쿠키설정 유틸리티
 *
 * @author
 *
 */
public class CookieUtil {
	private HttpServletResponse response;
	private HttpServletRequest request;
	private String comment;
	private String domain;
	private int maxAge;
	private String path;
	private boolean secure;
	private int version;
	private String encodeCharSet;
	private String decodeCharSet;

	public CookieUtil(HttpServletRequest request, HttpServletResponse response) {
		this.request = request;
		this.response = response;
		comment = null;
		domain = null;
		maxAge = -2147483648;
		path = "/";
		secure = false;
		version = 0;
		encodeCharSet = "UTF-8";
		decodeCharSet = "UTF-8";
	}

	/**
	 * 쿠키 정보 set
	 *
	 * @param cookieName
	 *            쿠키명
	 * @param value
	 */
	public void setCookie(String cookieName, String value) {
		try {
			value = URLEncoder.encode(value, encodeCharSet);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		Cookie cookie = new Cookie(cookieName, value);
		if (domain != null) {
			cookie.setDomain(domain);
		}
		if (comment != null) {
			cookie.setComment(comment);
		}
		if (maxAge > -2147483648) {
			cookie.setMaxAge(maxAge);
		}
		if (path != null) {
			cookie.setPath(path);
		}
		if (secure) {
			cookie.setSecure(secure);
		}
		if (version > 0) {
			cookie.setVersion(version);
		}
		response.addCookie(cookie);
	}

	/**
	 * 쿠키정보 get
	 *
	 * @param cookieName
	 *            쿠키명
	 * @return
	 */
	public String getCookie(String cookieName) {
		Cookie cookies[] = request.getCookies();
		if (cookies == null) {
			return "";
		}
		String value = "";
		int i = 0;
		do {
			if (i >= cookies.length) {
				break;
			}
			if (cookieName.equals(cookies[i].getName())) {
				try {
					value = URLDecoder.decode(cookies[i].getValue(), decodeCharSet);
				} catch (UnsupportedEncodingException e) {
				}
				break;
			}
			i++;
		} while (true);
		return value;
	}

	public Map<String, String> toMap() {
		HashMap<String, String> cookieMap = new HashMap<String, String>();
		Cookie cookies[] = request.getCookies();
		if (cookies == null || cookies.length == 0) {
			return cookieMap;
		}
		for (int idx = 0; idx < cookies.length; idx++) {
			cookieMap.put(cookies[idx].getName(), cookies[idx].getValue());
		}
		return cookieMap;
	}

	/**
	 * 쿠키 clear
	 *
	 * @param cookieName
	 *            쿠키명
	 * @return
	 */
	public int clearCookie(String cookieName) {
		int i = 0;
		if (request == null)
			return i;
		Cookie acookie[] = request.getCookies();
		if (acookie == null)
			return i;
		if (cookieName == null) {
			for (int j = 0; j < acookie.length; j++) {
				if (domain != null)
					acookie[j].setDomain(domain);
				acookie[j].setMaxAge(0);
				acookie[j].setPath("/");
				response.addCookie(acookie[j]);
				i++;
			}
		} else {
			for (int k = 0; k < acookie.length; k++) {
				Cookie cookie = acookie[k];
				if (!cookieName.equalsIgnoreCase(cookie.getName()))
					continue;
				if (domain != null)
					cookie.setDomain(domain);
				cookie.setMaxAge(0);
				cookie.setPath("/");
				response.addCookie(cookie);
				i++;
			}
		}
		return i;
	}

	public HttpServletResponse getResponse() {
		return response;
	}

	public void setResponse(HttpServletResponse response) {
		this.response = response;
	}

	public HttpServletRequest getRequest() {
		return request;
	}

	public void setRequest(HttpServletRequest request) {
		this.request = request;
	}

	public String getComment() {
		return comment;
	}

	public void setComment(String comment) {
		this.comment = comment;
	}

	public String getDomain() {
		return domain;
	}

	public void setDomain(String domain) {
		this.domain = domain;
	}

	public int getMaxAge() {
		return maxAge;
	}

	public void setMaxAge(int maxAge) {
		this.maxAge = maxAge;
	}

	public String getPath() {
		return path;
	}

	public void setPath(String path) {
		this.path = path;
	}

	public boolean isSecure() {
		return secure;
	}

	public void setSecure(boolean secure) {
		this.secure = secure;
	}

	public int getVersion() {
		return version;
	}

	public void setVersion(int version) {
		this.version = version;
	}

	public String getEncodeCharSet() {
		return encodeCharSet;
	}

	public void setEncodeCharSet(String encodeCharSet) {
		this.encodeCharSet = encodeCharSet;
	}

	public String getDecodeCharSet() {
		return decodeCharSet;
	}

	public void setDecodeCharSet(String decodeCharSet) {
		this.decodeCharSet = decodeCharSet;
	}
}
