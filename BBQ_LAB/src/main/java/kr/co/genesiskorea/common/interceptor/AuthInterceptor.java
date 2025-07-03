package kr.co.genesiskorea.common.interceptor;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import kr.co.genesiskorea.service.UserService;
import kr.co.genesiskorea.util.MessageUtil;
import kr.co.genesiskorea.common.auth.AuthUtil;

public class AuthInterceptor extends HandlerInterceptorAdapter {
	private static final Logger logger = LoggerFactory.getLogger(AuthInterceptor.class);
	
	@Autowired
	private MessageSourceAccessor msa;
	
	@Autowired
	UserService userService;
	
	@SuppressWarnings({ "static-access", "unchecked" })
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		HttpSession session = request.getSession();
		Map<String,Object> authMap = (HashMap<String,Object>)session.getAttribute("USER_AUTH");
		
		String sRequestUri = request.getRequestURI();
		String sRefUri = request.getHeader("referer");
		String baseUri = "";
		logger.info("요청 URL : "+sRequestUri);
		logger.info("referer URL : "+sRefUri);
		
		boolean isExcept = false;
		boolean hasAuth = AuthUtil.hasAuth(request);
		logger.info("hasAuth : "+hasAuth);
		
		List<String> exceptUriList = new ArrayList<String>();
		exceptUriList.add("Ajax");
		exceptUriList.add("/");
		exceptUriList.add("/user/login");
		exceptUriList.add("/login");
		exceptUriList.add("/user/logout");
		exceptUriList.add("/user/pwdInit");
		exceptUriList.add("/ssoLogin");
		exceptUriList.add("/subscribe");
		exceptUriList.add("send-data");
		exceptUriList.add("resources");

		
		for (String exceptUri : exceptUriList) {
			if(sRequestUri.startsWith(exceptUri)){
				isExcept = true;
			}
			if(sRequestUri.indexOf(exceptUri) != -1){
				isExcept = true;
			}
		}
		//hasAuth = true;
		 // 예외로 지정된 URL을 호출한 경우 사용자 로그인 Check를 하지 않음
		if(!isExcept) {
            // 일반URL을 호출한 경우 Login 했는지 체크
			if(!hasAuth) {
				logger.debug("비정상접근 ");
				MessageUtil.showAlert(request, response, msa.getMessage("login.ing.use"), "/user/logout");
				return false;	
			}
			
			/*if( authMap != null && authMap.get(sRequestUri) == null ) {
				logger.debug("메뉴 사용권한 없음.");
				MessageUtil.showAlert(request, response, "권한이 없습니다.", sRefUri);
				return false;
			}*/
		}
		
		
		if(!isExcept) {
			HashMap<String, Object> param = new HashMap<String, Object>();
			
			Enumeration<String> paramsEnum = request.getParameterNames();
			Map<String, String> requestParam = new HashMap<String, String>();
			
			JSONObject json = new JSONObject();
			
			while (paramsEnum.hasMoreElements()) {
				String paramName = paramsEnum.nextElement();
				String pramValue = request.getParameter(paramName);
				requestParam.put(paramName, pramValue);
			}
			json.putAll(requestParam);
			
			//SimpleDateFormat 선언
			Date date = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            //SimpleDateFormat 을 이용해 String 타입으로 가져오기  
			String serverTime = dateFormat.format(date);
			
			String logStr = "==== User Access Log ====";
			logStr += "\nsRequestUri : " + sRequestUri;
			logStr += "\ngetUserId : " + AuthUtil.getAuth(request).getUserId();
			logStr += "\nserverTime : " + serverTime;
			logger.debug(logStr);
			
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			param.put("url", sRequestUri);
			param.put("time", serverTime);
			param.put("requestParams", json.toJSONString(requestParam));
			
			userService.insertAccessLog(param);
		}
		
		return true;
	}
}
