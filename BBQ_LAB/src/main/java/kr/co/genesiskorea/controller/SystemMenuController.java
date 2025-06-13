package kr.co.genesiskorea.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.SystemMenuService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/systemMenu")
public class SystemMenuController {
	private Logger logger = LogManager.getLogger(SystemMenuController.class);
	
	@Autowired
	SystemMenuService menuService;
	
	@RequestMapping("/list")
	public String list(HttpServletRequest request, HttpServletResponse response, Model model , @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return "/systemMenu/list";
	}
	
	@RequestMapping("/menuListAjax")
	@ResponseBody
	public Map<String, Object> menuListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, Object> returnMap = menuService.menuList(param);
		return returnMap;
	}
	
	@RequestMapping("/selectAllMenuListAjax")
	@ResponseBody
	public List<Map<String, Object>> selectAllMenuListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		List<Map<String, Object>> returnList = menuService.selectAllMenuList(param);
		return returnList;
	}
	
	@RequestMapping("/insertMenuAjax")
	@ResponseBody
	public Map<String, String> insertMenuAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, String> returnMap = new HashMap<String,String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			menuService.insertMenu(param);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}		
		return returnMap;
	}
	
	@RequestMapping("/insertMenu2Ajax")
	@ResponseBody
	public Map<String, String> insertMenu2Ajax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, String> returnMap = new HashMap<String,String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			menuService.insertMenu2(param);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}		
		return returnMap;
	}
	
	@RequestMapping("/pMenuListAjax")
	@ResponseBody
	public List<Map<String, Object>> pMenuListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		List<Map<String, Object>> returnList = menuService.pMenuList(param);
		return returnList;
	}
	
	@RequestMapping("/selectMenuDataAjax")
	@ResponseBody
	public Map<String, Object> selectMenuDataAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, Object> returnMap = menuService.selectMenuData(param);
		return returnMap;
	}
	
	@RequestMapping("/updateMenuAjax")
	@ResponseBody
	public Map<String, String> updateMenuAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, String> returnMap = new HashMap<String,String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			menuService.updateMenu(param);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}		
		return returnMap;
	}
	
	@RequestMapping("/deleteMenuAjax")
	@ResponseBody
	public Map<String, String> deleteMenuAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, String> returnMap = new HashMap<String,String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			menuService.deleteMenu(param);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}		
		return returnMap;
	}
}
