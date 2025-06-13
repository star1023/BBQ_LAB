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
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.CodeManagementService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/code")
public class CodeManagementController {
	private Logger logger = LogManager.getLogger(CodeManagementController.class);
	
	@Autowired
	CodeManagementService codeManagementService;
	
	@RequestMapping(value = "/groupList")
	public String getGroupList(HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		return "/code/groupList";
	}
	
	@RequestMapping(value = "/groupListAjax")
	@ResponseBody
	public List<HashMap<String,Object>> getGroupListAjax(HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		List<HashMap<String,Object>> groupList = codeManagementService.getGroupList();
		return groupList;
	}
	
	@RequestMapping(value = "/gruopInsertAjax", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String,String> gruopInsertAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> param) throws Exception {
		HashMap<String,String> resultMap = new HashMap<String,String>();
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId",auth.getUserId());
		try {
			int count = codeManagementService.groupCount(param, request);
			if( count == 0 ) {
				codeManagementService.groupInsert(param, request);
				resultMap.put("RESULT", "Y");
			} else {
				resultMap.put("RESULT", "F");
				resultMap.put("MESSAGE", "동일한 코드값이 존재합니다.");								
			}
		} catch (Exception e) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			resultMap.put("RESULT", "E");
			resultMap.put("MESSAGE", e.getMessage());			
		}
		return resultMap;
	}
	
	@RequestMapping(value = "/gruopUpdateAjax", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String,String> gruopUpdateAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> param) throws Exception {
		HashMap<String,String> resultMap = new HashMap<String,String>();
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId",auth.getUserId());
		try {
			int count = codeManagementService.groupCount(param, request);
			if( count == 1 ) {
				codeManagementService.groupUpdate(param, request);
				resultMap.put("RESULT", "Y");
			} else {
				resultMap.put("RESULT", "F");
				resultMap.put("MESSAGE", "코드가 존재하지 않습니다.");
			}
		} catch (Exception e) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			resultMap.put("RESULT", "E");
			resultMap.put("MESSAGE", e.getMessage());		
		}
		return resultMap;
	}
	
	@RequestMapping(value = "/gruopDeleteAjax", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String,String> gruopDeleteAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> param) throws Exception {
		HashMap<String,String> resultMap = new HashMap<String,String>();
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId",auth.getUserId());
		try {
			int count = codeManagementService.groupCount(param, request);
			if( count == 1 ) {
				int itemCount = codeManagementService.groupItemCount(param, request);
				if( itemCount == 0 ) {
					codeManagementService.groupDelete(param, request);
					resultMap.put("RESULT", "Y");
				} else {
					resultMap.put("RESULT", "F");
					resultMap.put("MESSAGE", "코드아이템이 존재하여 삭제할 수 없습니다.");					
				}
			} else {
				resultMap.put("RESULT", "F");
				resultMap.put("MESSAGE", "해당 코드가 존재하지 않습니다.");				
			}
		} catch (Exception e) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			resultMap.put("RESULT", "E");
			resultMap.put("MESSAGE", e.getMessage());		
		}
		return resultMap;
	}
	
	@RequestMapping(value = "/itemList")
	public String itemList(HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		try {
			model.addAttribute("groupCode", request.getParameter("groupCode"));
			return "/code/itemList";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping(value = "/itemListAjax")
	@ResponseBody
	public List<HashMap<String,Object>> getItemListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> param) throws Exception {
		try {
			List<HashMap<String,Object>> itemList = codeManagementService.getItemList(param);
			return itemList;
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping(value = "/itemInsertAjax", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String,String> itemInsertAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> param) throws Exception {
		HashMap<String,String> resultMap = new HashMap<String,String>();
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId",auth.getUserId());
		try {
			int count = codeManagementService.itemCount(param, request);
			if( count == 0 ) {
				codeManagementService.itemInsert(param, request);
				resultMap.put("RESULT", "Y");
			} else {
				resultMap.put("RESULT", "F");
				resultMap.put("MESSAGE", "동일한 코드값이 존재합니다.");
			}
		} catch (Exception e) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			resultMap.put("RESULT", "E");
			resultMap.put("MESSAGE", e.getMessage());
		}
		return resultMap;
	}
	
	@RequestMapping(value = "/itemUpdateAjax", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String,String> itemUpdateAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> param) throws Exception {
		HashMap<String,String> resultMap = new HashMap<String,String>();
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId",auth.getUserId());
		try {
			int count = codeManagementService.itemCount(param, request);
			if( count == 1 ) {
				codeManagementService.itemUpdate(param, request);
				resultMap.put("RESULT", "Y");
			} else {
				resultMap.put("RESULT", "F");
				resultMap.put("MESSAGE", "삭제된 코드입니다. 다시 시도해주세요.");								
			}
		} catch (Exception e) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			resultMap.put("RESULT", "E");
			resultMap.put("MESSAGE", e.getMessage());
		}
		return resultMap;
	}
	
	@RequestMapping(value = "/itemDeleteAjax", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String,String> itemDeleteAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> param) throws Exception {
		HashMap<String,String> resultMap = new HashMap<String,String>();
		try {
			int count = codeManagementService.itemCount(param, request);
			if( count == 1 ) {
				codeManagementService.itemOrderUpdate(param, request);
				codeManagementService.itemDelete(param, request);
				resultMap.put("RESULT", "Y");
			} else {
				resultMap.put("RESULT", "F");
				resultMap.put("MESSAGE", "삭제된 코드입니다. 다시 시도해주세요.");
			}
		} catch (Exception e) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			resultMap.put("RESULT", "E");
			resultMap.put("MESSAGE", e.getMessage());
		}
		return resultMap;
	}
	
	@RequestMapping(value = "/itemOrderUpdateAjax", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String,String> itemOrderUpdateAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> param) throws Exception {
		HashMap<String,String> resultMap = new HashMap<String,String>();
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId",auth.getUserId());
		try {
			int count = codeManagementService.itemCount(param, request);
			if( count == 1 ) {
				//변경할 대상의 위,아래 아이템의 순서를 변경한다.
				codeManagementService.itemOrderUpDown(param, request);				
				codeManagementService.itemOrderUpdateAjax(param, request);
				resultMap.put("RESULT", "Y");
			} else {
				resultMap.put("RESULT", "F");
				resultMap.put("MESSAGE", "삭제된 코드입니다. 다시 시도해주세요.");		
			}
		} catch (Exception e) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			resultMap.put("RESULT", "E");
			resultMap.put("MESSAGE", e.getMessage());
		}
		return resultMap;
	}
}
