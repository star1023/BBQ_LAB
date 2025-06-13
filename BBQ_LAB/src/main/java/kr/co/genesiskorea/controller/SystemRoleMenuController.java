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
import kr.co.genesiskorea.service.SystemRoleMenuService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/systemRoleMenu")
public class SystemRoleMenuController {
	private Logger logger = LogManager.getLogger(SystemRoleMenuController.class);
	
	@Autowired
	SystemRoleMenuService rMenuService;
	
	@Autowired
	SystemMenuService menuService;
	
	@RequestMapping("/list")
	public String list(HttpServletRequest request, HttpServletResponse response, Model model , @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return "/systemRoleMenu/list";
	}
	
	@RequestMapping("/selectAllMenuAjax")
	@ResponseBody
	public List<Map<String, Object>> selectAllMenuAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		List<Map<String, Object>> returnMap = menuService.selectAllMenu(param);
		return returnMap;
	}
	
	@RequestMapping("/selectRoleMenuListAjax")
	@ResponseBody
	public List<Map<String, Object>> selectRoleMenuListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		List<Map<String, Object>> returnMap = rMenuService.selectRoleMenuList(param);
		return returnMap;
	}
	
	@RequestMapping("/updateRoleMenuAjax")
	@ResponseBody
	public Map<String, String> updateRoleMenuAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(value="selectedMenu") List<String> selectedMenu
			, @RequestParam(value = "selectedRoleIdx", required = false) String selectedRoleIdx) throws Exception {
		//List<Map<String, String>> returnMap = testService.selectRoleMenuList(param);
		//return returnMap;
		Map<String, String> returnMap = new HashMap<String,String>();
		try {
			Map<String, Object> param = new HashMap<String, Object>();
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			param.put("selectedMenu", selectedMenu);
			param.put("selectedRoleIdx", selectedRoleIdx);
			rMenuService.updateRoleMenu(param);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
}
