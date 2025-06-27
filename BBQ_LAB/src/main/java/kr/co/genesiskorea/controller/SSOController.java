package kr.co.genesiskorea.controller;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.UserService;

@Controller
public class SSOController {
	private Logger logger = LogManager.getLogger(SSOController.class);
	
	@Autowired
	UserService userService;
	
	@RequestMapping(value = "/ssoLogin")
	public String ssoLogin(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, Model model) throws Exception {
		String result = "";
		String referer = request.getHeader("referer");
		if(referer == null)
			referer = "null";
		else if("".equals(referer))
			referer = "empty value";
		//referer를 체크할 경우 사용한다.
		
		String ssoId = (String)param.get("ssoId");
		if( ssoId != null && !"".equals(ssoId) ) {
			//ssoId를 복호화 한다.
			String userId = ssoId;
			Map<String, Object> userData = userService.selectUserData(userId);
			
			if( userData == null ) {
				//사용자 정보 없음.
				model.addAttribute("USER_ID", userId);
				model.addAttribute("RESULT", "NO_USER");
				return "/error/ssoError";
			}
			
			if( userData != null && "Y".equals(userData.get("isLock")) ) {
				//사용자 잠금
				model.addAttribute("USER_ID", userId);
				model.addAttribute("RESULT", "IS_LOCK");
				return "/error/ssoError";
			}
			
			if( userData != null && "3".equals(userData.get("EMSTAT")) ) {
				//퇴직자
				model.addAttribute("USER_ID", userId);
				model.addAttribute("RESULT", "RETIRED");
				return "/error/ssoError";
			}
			
			if( result != null && !"".equals(result) ) {
				param.put("userId", userId);
				param.put("roleCode", userData.get("roleCode"));
				List<Map<String,Object>> userMenu = userService.selectUserMenu(param);
				
				JSONArray jArr = new JSONArray();
				for (Map<String, Object> menu : userMenu) {
					Iterator<String> itr = menu.keySet().iterator();

					JSONObject jObj = new JSONObject();
					while (itr.hasNext()) {
						String key = itr.next();
						String value = String.valueOf(menu.get(key));
						jObj.put(key, value);
					}
					jArr.add(jObj);
				}
				
				
				List<Map<String,Object>> userAuth = userService.selectUserAuth(param);
				Map<String,Object> authMap = new HashMap<String,Object>();
				for (Map<String, Object> userAuthMap : userAuth) {
					authMap.put(userAuthMap.get("url").toString(), userAuthMap.get("url"));
				}
				
				HttpSession session = request.getSession(false);
				session.setAttribute("USER_MENU", jArr);
				session.setAttribute("USER_AUTH", authMap);
				
				Auth auth = new Auth();
				BeanUtils.copyProperties(auth, userData);
				AuthUtil.setAuth(request, auth);
				userService.insertLginLog(userData);
				result = "redirect:/main/main";	
			}	
		} else {
			//sso 파라미터가 없는 경우.
			model.addAttribute("RESULT", "NO_DATA");
			result = "/error/ssoError";
		}		
		return result;
	}
	
}
