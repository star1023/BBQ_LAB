package kr.co.genesiskorea.controller;

import java.text.DateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.co.genesiskorea.service.BatchService;
import kr.co.genesiskorea.service.CommonService;
import kr.co.genesiskorea.service.TestService;
import kr.co.genesiskorea.service.impl.BatchServiceImpl;
import kr.co.genesiskorea.service.impl.CommonServiceImpl;
import kr.co.genesiskorea.service.impl.TestServiceImpl;
import kr.co.genesiskorea.util.SecurityUtil;

/**
 * Handles requests for the application home page.
 */
@Controller
public class TestController {
	
	//private static final Logger logger = LoggerFactory.getLogger(HomeController.class);
	
	
	private Logger logger = LogManager.getLogger(TestController.class);
	
	@Autowired
	TestService testService;
	
	@Autowired
	TestServiceImpl testServiceImpl;
	
	@Autowired
	CommonService commonService;
	
	@Autowired
	BatchService batchService;
	
	/**
	 * Simply selects the home view to render by returning its name.
	 */
	@RequestMapping(value = "/Test", method = RequestMethod.GET)
	public String home(Locale locale, Model model) {
		logger.info("Welcome home! The client locale is {}.", locale);
		
		Date date = new Date();
		DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, locale);
		
		String formattedDate = dateFormat.format(date);
		
		model.addAttribute("serverTime", formattedDate );
		
		logger.debug("[debug] log!");
        logger.info("[info] log!");
        logger.warn("[warn] log!");
        logger.error("[error] log!");
        try {
        	HashMap<String,Object> param = new HashMap<String,Object>();
        	List<HashMap<String,Object>> list = testService.selectUser(param);
        	logger.debug(list);
        } catch( Exception e ) {
        	logger.error("[error] log!" + e.getMessage() );
        }
		
        return "home";
	}
	
	@RequestMapping(value = "/test2", method = RequestMethod.GET)
	public String Test2(Locale locale, Model model) {
        return "test2";
	}
	
	@RequestMapping(value = "/notiTest")
	public String notiTest(Locale locale, Model model) {		
		try {
			HashMap<String, Object> notiMap = new HashMap<String, Object>();
			notiMap.put("targetUser", "team_admin");
			notiMap.put("type", "I");
			notiMap.put("typeTxt", "알림 Type 내용");
			notiMap.put("message", "알림메세지를 작성합니다.");
			notiMap.put("userId", "admin");
			commonService.notification(notiMap);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		 return "home";
	}
	
	@RequestMapping(value = "/notiAll")
	public String notiAll(Locale locale, Model model) {		
		try {
			commonService.notificationAll();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		 return "home";
	}
	
	@RequestMapping(value = "/refTest")
	public String refTest() {		
		Map<String, Object> importParams = new HashMap<String, Object>();
		batchService.material(importParams);
		return "";
	}
	
	@RequestMapping(value = "/erpTestAjax")
	@ResponseBody
	public String erpTest(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) {		
		batchService.erpMaterial(param);
		return "테스트";
	}
	
	@RequestMapping("/insertTestAjax")
	@ResponseBody
	public String trTestAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		testServiceImpl.insertTrText();
		return "테스트";
	}
	
	@RequestMapping("/selectOrgAjax")
	@ResponseBody
	public String selectOrgAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		testServiceImpl.selectOrg();
		return "테스트";
	}
	
	@RequestMapping("/selectHrInfoAjax")
	@ResponseBody
	public String selectHrInfoAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		testServiceImpl.selectHrInfo();
		return "테스트";
	}
	
	@RequestMapping("/selectMasterCodeAjax")
	@ResponseBody
	public String selectMasterCodeAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		testServiceImpl.selectMasterCode();
		return "테스트";
	}
	
	@RequestMapping("/userTestAjax")
	@ResponseBody
	public String userTestAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		List<Map<String,Object>> userList = testServiceImpl.selecUserList();
		for( int i = 0 ; i < userList.size() ; i++ ) {
			HashMap<String,Object> userData = (HashMap<String,Object>)userList.get(i);
			String userId = (String)userData.get("userId");
			String encPwd = SecurityUtil.getEncrypt(userId, userId);
//			System.err.println(userId +"  :  "+ encPwd);
			param.put("userId", userId);
			param.put("encPwd", encPwd);
			param.put("pwdInit", "Y");
			testServiceImpl.updateUserPwd(param);
			
		}
		return "테스트";
	}
}
