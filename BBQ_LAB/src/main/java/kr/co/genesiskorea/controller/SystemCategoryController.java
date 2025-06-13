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
import kr.co.genesiskorea.service.SystemCategoryService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/systemCategory")
public class SystemCategoryController {
	private Logger logger = LogManager.getLogger(SystemCategoryController.class);
	
	@Autowired
	SystemCategoryService categoryService;
	
	@RequestMapping("/list")
	public String list(HttpServletRequest request, HttpServletResponse response, Model model , @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return "/systemCategory/list";
	}
	
	@RequestMapping("/selectCategoryAjax")
	@ResponseBody
	public List<Map<String, Object>> selectCategoryAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		List<Map<String, Object>> returnMap = categoryService.selectCategory(param);
		return returnMap;
	}
	
	@RequestMapping("/insertCategoryAjax")
	@ResponseBody
	public Map<String, String> insertCategoryAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, String> returnMap = new HashMap<String,String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			categoryService.insertCategory(param);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/deleteCategoryAjax")
	@ResponseBody
	public Map<String, String> deleteCategoryAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, String> returnMap = new HashMap<String,String>();
		try {
			categoryService.deleteCategory(param);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/updateCategoryAjax")
	@ResponseBody
	public Map<String, String> updateCategoryAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, String> returnMap = new HashMap<String,String>();
		try {
			System.err.println(param);
			categoryService.updateCategory(param);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/updateMoveCategoryAjax")
	@ResponseBody
	public Map<String, String> updateMoveCategoryAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, String> returnMap = new HashMap<String,String>();
		try {
			returnMap = categoryService.updateMoveCategory(param);
			//returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
}
