package kr.co.genesiskorea.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.CommonService;
import kr.co.genesiskorea.service.SystemRoleService;
import kr.co.genesiskorea.service.UserService;
import kr.co.genesiskorea.util.CommonException;
import kr.co.genesiskorea.util.SecurityUtil;
import kr.co.genesiskorea.util.StringUtil;

@Controller
public class UserController {
	private Logger logger = LogManager.getLogger(UserController.class);
	
	@Autowired
	private Properties config;
	
	@Autowired
	UserService userService;
	
	@Autowired
	SystemRoleService  roleService;
	
	@Autowired
	private CommonService commonService;
	
	@RequestMapping(value = {"","/", "/login" }, method = RequestMethod.GET)
	public String login(HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		return "redirect:/user/login";
	}
	
	@RequestMapping(value = "/user/login", method = RequestMethod.GET)
	public String userLogin(HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		logger.debug("로그인");
		if (AuthUtil.hasAuth(request)) {
			return "redirect:/main/main";
		}
		return "user/login";
	}
	
	@RequestMapping(value = "/user/loginProcAjax", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String,Object> loginProc(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception {
		logger.info("id: {}, autoLogin: {}", param.get("userId"));
		String pwd = config.getProperty("admin.pwd");
		logger.info("pwd: {}", pwd);
		//logger.debug("userVO.getUserPw(): {}", userVO.getUserPw());
		String chkSave = request.getParameter("chkSave");
		logger.info("chkSave: {}", chkSave);
		
		HashMap<String,Object> resultMap = new HashMap<String,Object>();
		
		try {
			logger.info("userPwd: {}", param.get("userPwd"));
			if( param.get("userPwd") != null && pwd.equals(param.get("userPwd")) ) {
				userService.login(param, request);
				resultMap.put("RESULT", "S");
			} else {
				if( param.get("userPwd") != null && !"".equals(param.get("userPwd")) ) {
					userService.loginPwd(param, request);
					resultMap.put("RESULT", "S");
				} else {
					resultMap.put("RESULT", "E");
					resultMap.put("RESULT_TYPE", "FAIL");
					resultMap.put("MESSAGE", "입력하신 비밀번호가 올바르지 않거나 \n 존재하지 않는 사용자 입니다.");
				}
			}
		} catch(CommonException ce) {
			if(ce.getMessage().equals("USER_LOCK")){
				resultMap.put("RESULT", "E");
				resultMap.put("RESULT_TYPE", "LOCK");
				resultMap.put("MESSAGE", "계정이 잠긴 사용자입니다.");		
			} else if(ce.getMessage().equals("USER_DELETE")){
				resultMap.put("RESULT", "E");
				resultMap.put("RESULT_TYPE", "DELETE");
				resultMap.put("MESSAGE", "삭제 된 사용자입니다.");		
			} else if(ce.getMessage().equals("USER_RETIRED")){
				resultMap.put("RESULT", "E");
				resultMap.put("RESULT_TYPE", "RETIRED");
				resultMap.put("MESSAGE", "퇴직자입니다.");		
			} else if(ce.getMessage().equals("USER_PWD_INIT")){
				resultMap.put("RESULT", "E");
				resultMap.put("RESULT_TYPE", "PWD_INIT");
				resultMap.put("MESSAGE", "비밀번호 초기화 대상자 입니다.");		
			} else {
				resultMap.put("RESULT", "E");
				resultMap.put("RESULT_TYPE", "FAIL");
				resultMap.put("MESSAGE", "입력하신 비밀번호가 올바르지 않거나 \n 존재하지 않는 사용자 입니다.");
			}
		} catch (Exception e) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			resultMap.put("RESULT", "E");
			resultMap.put("RESULT_TYPE", "ERROR");
			resultMap.put("MESSAGE", "오류가 발생하였습니다. \n 관리자에게 문의하시기 바랍니다.");			
		}
		return resultMap;
	}
	
	@RequestMapping(value = "/user/logout", method = RequestMethod.GET)
	public String logout(HttpServletRequest request, HttpServletResponse response) throws Exception {
		userService.logout(request);
		return "/user/logout";
	}
	
	@RequestMapping(value="/user/userList")
	public String manageUserList(Model model, HttpServletRequest request) throws Exception{
		try {
			HashMap<String,String> param = new HashMap<String,String>();
			/*param.put("code", "DEPT");
			List<HashMap<String,String>> deptList = commonService.getCodeList(param);			
			param.put("code", "GRADE");			
			List<HashMap<String,String>> gradeList = commonService.getCodeList(param); 
			param.put("code", "GRADE");		
			List<HashMap<String,String>> teamList = commonService.getCodeList(param);
			model.addAttribute("deptList", deptList);
			model.addAttribute("gradeList", gradeList);
			model.addAttribute("teamList", teamList);*/
			List<HashMap<String,Object>> roleList = roleService.selectRoleList(); 
			model.addAttribute("roleList", roleList);
			return "/user/userList";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@ResponseBody
	@RequestMapping(value="/user/userListAjax")
	public Map<String, Object> userList(Model model, @RequestParam Map<String, Object> param ) {
		 Map<String, Object> resultMap = new HashMap<String, Object>();
		try{
			
			resultMap = userService.getUserList(param);
			resultMap.put("RESULT", "S");
			
		}catch(Exception e){
			resultMap.put("RESULT", "F");
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
		}
		return resultMap;
	}
	
	/**
	 * 아이디 중복체크
	 * @param userId
	 * @return
	 */
	@ResponseBody
	@RequestMapping(value="/user/checkId", method = RequestMethod.POST)
	public Map<String, Object> checkId(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="userId") String userId ){
		Map<String, Object> resultMap = new HashMap<String, Object>();
		try{
			int checkId = userService.checkId(userId);
			if( checkId > 0 ) {
				resultMap.put("RESULT", "F");
			} else {
				resultMap.put("RESULT", "S");
			}						
		}catch(Exception e){
			resultMap.put("RESULT", "E");
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
		}
		return resultMap;
	}
	
	@ResponseBody
	@RequestMapping(value = "/user/inserUserAjax", method = RequestMethod.POST)
	public Map<String, Object> inserUser(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param){
		Map<String, Object> resultMap = new HashMap<String, Object>();
		try{
			userService.inserUser(param);
			Map<String, Object> logParam = new HashMap<String, Object>();
			Auth auth = AuthUtil.getAuth(request);
			logParam.put("type", "C");
			logParam.put("description", "사용자 생성");
			logParam.put("userId", param.get("userId"));
			logParam.put("regUserId",auth.getUserId());
			userService.insertLog(logParam);
			resultMap.put("RESULT", "S");			
		}catch(Exception e){
			resultMap.put("RESULT", "F");
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
		}
		return resultMap;
	}
	
	@ResponseBody
	@RequestMapping(value = "/user/selectUserAjax", method = RequestMethod.POST)
	public Map<String, Object> selectUser(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="userId") String userId){
		Map<String, Object> resultMap = userService.selectUserData(userId);
		return resultMap;
	}
	
	@ResponseBody
	@RequestMapping(value = "/user/updateUserAjax", method = RequestMethod.POST)
	public Map<String, Object> updateUser(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param){
		Map<String, Object> resultMap = new HashMap<String, Object>();
		try{
			userService.updateUser(param);
			Map<String, Object> logParam = new HashMap<String, Object>();
			Auth auth = AuthUtil.getAuth(request);
			logParam.put("logType", "U");
			logParam.put("description", "사용자 정보 변경");
			logParam.put("userId", param.get("userId"));
			logParam.put("regUserId",auth.getUserId());
			userService.insertLog(logParam);
			resultMap.put("RESULT", "S");			
		}catch(Exception e){
			resultMap.put("RESULT", "F");
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
		}
		return resultMap;
	}
	
	@ResponseBody
	@RequestMapping(value = "/user/deleteUserAjax", method = RequestMethod.POST)
	public Map<String, Object> deleteUser(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="userId") String userId){
		Map<String, Object> resultMap = new HashMap<String, Object>();
		try{
			userService.deleteUser(userId);
			Map<String, Object> logParam = new HashMap<String, Object>();
			Auth auth = AuthUtil.getAuth(request);
			logParam.put("logType", "D");
			logParam.put("description", "사용자 퇴직처리");
			logParam.put("userId", userId);
			logParam.put("regUserId",auth.getUserId());
			userService.insertLog(logParam);
			resultMap.put("RESULT", "S");			
		}catch(Exception e){
			resultMap.put("RESULT", "F");
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
		}
		return resultMap;
	}
	
	@ResponseBody
	@RequestMapping(value = "/user/restoreUserAjax", method = RequestMethod.POST)
	public Map<String, Object> restoreUser(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="userId") String userId){
		Map<String, Object> resultMap = new HashMap<String, Object>();
		try{
			userService.restoreUser(userId);
			Map<String, Object> logParam = new HashMap<String, Object>();
			Auth auth = AuthUtil.getAuth(request);
			logParam.put("logType", "R");
			logParam.put("description", "사용자 재직처리");
			logParam.put("userId", userId);
			logParam.put("regUserId",auth.getUserId());
			userService.insertLog(logParam);
			resultMap.put("RESULT", "S");			
		}catch(Exception e){
			resultMap.put("RESULT", "F");
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
		}
		return resultMap;
	}
	
	@ResponseBody
	@RequestMapping(value = "/user/unlockUserAjax", method = RequestMethod.POST)
	public Map<String, Object> unlockUser(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="userId") String userId){
		Map<String, Object> resultMap = new HashMap<String, Object>();
		try{
			userService.unlockUser(userId);
			Map<String, Object> logParam = new HashMap<String, Object>();
			Auth auth = AuthUtil.getAuth(request);
			logParam.put("type", "O");
			logParam.put("description", "사용자 잠금해제");
			logParam.put("userId", userId);
			logParam.put("regUserId",auth.getUserId());
			userService.insertLog(logParam);
			resultMap.put("RESULT", "S");			
		}catch(Exception e){
			resultMap.put("RESULT", "F");
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
		}
		return resultMap;
	}
	
	@ResponseBody
	@RequestMapping(value="/user/setPersonalizationAjax")
	public Map<String, Object> setPersonalization(@RequestParam Map<String, Object> param, HttpServletRequest request, HttpServletResponse response ,Model model ) {
		 Map<String, Object> map = new HashMap<String, Object>();
		try{
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			userService.setPersonalization(param);
			if( param.get("type") != null && "theme".equals((String)param.get("type")) ) {
				 AuthUtil.getAuth(request).setTheme((String)param.get("value"));
			} else if( param.get("type") != null && "contentMode".equals((String)param.get("type")) ) {
				AuthUtil.getAuth(request).setContentMode((String)param.get("value"));
			} else if( param.get("type") != null && "widthMode".equals((String)param.get("type")) ) {
				AuthUtil.getAuth(request).setWidthMode((String)param.get("value"));
			} else if( param.get("type") != null && "mailCheck1".equals((String)param.get("type")) ) {
				AuthUtil.getAuth(request).setMailCheck1((String)param.get("value"));
			} else if( param.get("type") != null && "mailCheck2".equals((String)param.get("type")) ) {
				AuthUtil.getAuth(request).setMailCheck2((String)param.get("value"));
			} else if( param.get("type") != null && "mailCheck3".equals((String)param.get("type")) ) {
				AuthUtil.getAuth(request).setMailCheck3((String)param.get("value"));
			}
			map.put("resultCd", "S");
			
		}catch(Exception e){
			map.put("resultCd", "F");
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
		}
		return map;
	}
	
	@RequestMapping(value = "/user/pwdInit", method = RequestMethod.POST)
	public String pwdInit(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="userIdTemp") String userIdTemp, Model model) throws Exception {
		logger.debug("비밀번호 초기화");
		model.addAttribute("userId", userIdTemp);
		return "/user/pwdInit";
	}
	
	@RequestMapping(value = "/user/pwdCheckAjax", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String,Object> pwdCheckAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception {
		HashMap<String,Object> resultMap = new HashMap<String,Object>();
		try {
			String pattern = config.getProperty("user.pwd.pattern");
			String sLimit = config.getProperty("user.pwd.limit");		
			int limit = 0;
			try {
				limit = Integer.parseInt(sLimit);
			} catch( Exception e ) {
				limit = 3;
			}
			
			String userId = (String)param.get("userId");
			String newPassword = (String)param.get("newPassword");
			Matcher match = Pattern.compile(pattern).matcher(newPassword);
			
			if( !match.find() ) {
				resultMap.put("RESULT", "F");
				resultMap.put("MESSAGE", "비밀번호는 최소8자 이상, 하나 이상의 영문자,숫자,특수문자를 포함하여야 합니다.");
			} else if( this.continuousPwd(newPassword,limit) ) {
				resultMap.put("RESULT", "F");
				resultMap.put("MESSAGE", "연속된 알파벳 또는 숫자로 조합된 비밀번호는 사용할 수 없습니다.");
			} else if( newPassword.contains(userId) ) {
				resultMap.put("RESULT", "F");
				resultMap.put("MESSAGE", "아이디가 포함 된 비밀번호는 사용할 수 없습니다.");
			} else {
				resultMap.put("RESULT", "S");
			}
		} catch( Exception e ) {
			resultMap.put("RESULT", "E");
			resultMap.put("MESSAGE", "시스템 오류가 발생했습니다.\n관리자에게 문의하시기 바랍니다.");
		}
		return resultMap;
	}
	
	@RequestMapping(value = "/user/pwdUpdateAjax", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String,Object> pwdUpdateAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception {
		HashMap<String,Object> resultMap = new HashMap<String,Object>();
		try {
			//1. 비밀번호를 업데이트 한다.
			String userId = (String)param.get("userId");
			String newPassword = (String)param.get("newPassword");
			String encPwd = SecurityUtil.getEncrypt(newPassword, userId); 
			param.put("encPwd", encPwd);
			param.put("pwdInit", "N");			
			userService.updateUserPwd(param);
			//2. 로그인 처리를 한다.
			userService.login(param, request);
			resultMap.put("RESULT", "S");
		} catch(CommonException ce) {
			if(ce.getMessage().equals("USER_LOCK")){
				resultMap.put("RESULT", "E");
				resultMap.put("RESULT_TYPE", "LOCK");
				resultMap.put("MESSAGE", "계정이 잠긴 사용자입니다.");		
			} else if(ce.getMessage().equals("USER_DELETE")){
				resultMap.put("RESULT", "E");
				resultMap.put("RESULT_TYPE", "DELETE");
				resultMap.put("MESSAGE", "삭제 된 사용자입니다.");		
			} else if(ce.getMessage().equals("USER_RETIRED")){
				resultMap.put("RESULT", "E");
				resultMap.put("RESULT_TYPE", "RETIRED");
				resultMap.put("MESSAGE", "퇴직자입니다.");		
			} else if(ce.getMessage().equals("USER_PWD_INIT")){
				resultMap.put("RESULT", "E");
				resultMap.put("RESULT_TYPE", "PWD_INIT");
				resultMap.put("MESSAGE", "비밀번호 초기화 대상자 입니다.");		
			} else {
				resultMap.put("RESULT", "E");
				resultMap.put("RESULT_TYPE", "FAIL");
				resultMap.put("MESSAGE", "입력하신 비밀번호가 올바르지 않거나 \n 존재하지 않는 사용자 입니다.");
			}
		} catch( Exception e ) {
			resultMap.put("RESULT", "E");
			resultMap.put("MESSAGE", "시스템 오류가 발생했습니다.\n관리자에게 문의하시기 바랍니다.");
		}
		return resultMap;
	}
	
	@RequestMapping(value = "/user/pwdInitAjax", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String,Object> pwdInitAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception {
		HashMap<String,Object> resultMap = new HashMap<String,Object>();
		try {
			//1. 비밀번호를 업데이트 한다.
			String userId = (String)param.get("userId");
			String encPwd = SecurityUtil.getEncrypt(userId, userId); 
			param.put("encPwd", encPwd);
			param.put("pwdInit", "Y");			
			userService.updateUserPwd(param);
			resultMap.put("RESULT", "S");
			
			Auth auth = AuthUtil.getAuth(request);
			Map<String, Object> logParam = new HashMap<String, Object>();
			logParam.put("logType", "PU");
			logParam.put("description", "사용자 비밀번호 초기화");
			logParam.put("userId", userId);
			logParam.put("regUserId",auth.getUserId());
			userService.insertLog(logParam);
		} catch( Exception e ) {
			resultMap.put("RESULT", "E");
			resultMap.put("MESSAGE", "시스템 오류가 발생했습니다.\n관리자에게 문의하시기 바랍니다.");
		}
		return resultMap;
	}
	
	private boolean continuousPwd(String pwd, int limit) {
		int o = 0;
		int d = 0;
		int p = 0;
		int n = 0;
		//int limit = 3;
		for(int i=0; i<pwd.length(); i++) {
			char tempVal = pwd.charAt(i);
			if(i > 0 && (p = o - tempVal) > -2 && (n = p == d ? n + 1 :0) > limit -3) {
				return true;
			}
			d = p;
			o = tempVal;
		}
		return false;
	}
}
