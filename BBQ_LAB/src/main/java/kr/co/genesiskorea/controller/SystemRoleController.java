package kr.co.genesiskorea.controller;

import java.util.HashMap;
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
import kr.co.genesiskorea.service.SystemRoleService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/systemRole")
public class SystemRoleController {
	private Logger logger = LogManager.getLogger(SystemRoleController.class);
	
	@Autowired
	 SystemRoleService  roleService;
	
	@RequestMapping("/list")
	public String list(HttpServletRequest request, HttpServletResponse response, Model model , @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return "/systemRole/list";
	}
	
	@RequestMapping("/roleListAjax")
	@ResponseBody
	public Map<String, Object> roleListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, Object> returnMap = roleService.selectRoleList(param);
		return returnMap;
	}
	
	@RequestMapping("/insertRoleAjax")
	@ResponseBody
	public Map<String, String> insertRoleAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, String> returnMap = new HashMap<String,String>();
		try {
			Map<String, Object> roleData = roleService.selectRoleData(param);
			System.err.println(roleData);
			if( roleData != null && roleData.get("ROLE_ID") != null && !"".equals(roleData.get("ROLE_ID")) ) {
				returnMap.put("RESULT", "F");
				returnMap.put("MESSAGE","동일한 권한이 등록되어있습니다.");
			} else {
				Auth auth = AuthUtil.getAuth(request);
				param.put("userId", auth.getUserId());
				roleService.insertRole(param);
				returnMap.put("RESULT", "S");
			}
			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}		
		return returnMap;
	}
	
	@RequestMapping("/selectRoleDataAjax")
	@ResponseBody
	public Map<String, Object> selectRoleDataAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, Object> returnMap = roleService.selectRoleData(param);
		return returnMap;
	}
	
	@RequestMapping("/updateRoleAjax")
	@ResponseBody
	public Map<String, String> updateRoleAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, String> returnMap = new HashMap<String,String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			roleService.updateRole(param);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}		
		return returnMap;
	}
	
	@RequestMapping("/deleteRoleAjax")
	@ResponseBody
	public Map<String, String> deleteRoleAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, String> returnMap = new HashMap<String,String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			roleService.deleteRole(param);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}		
		return returnMap;
	}
}
