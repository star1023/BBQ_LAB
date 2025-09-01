package kr.co.genesiskorea.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.annotation.JsonIgnore;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.ApprovalService;
import kr.co.genesiskorea.service.RecipeService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/recipe")
public class RecipeController {
	private Logger logger = LogManager.getLogger(RecipeController.class);
	
	@Autowired
	RecipeService recipeService;
	
	@Autowired
	ApprovalService approvalService;
	
	@RequestMapping(value = "/list")
	public String productList( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/recipe/list";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectRecipeListAjax")
	@ResponseBody
	public Map<String, Object> selectRecipeListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = recipeService.selectRecipeList(param);
		return returnMap;
	}
	
	@RequestMapping(value = "/insert")
	public String compInsert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/recipe/insert";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/insertTmpRecipeAjax")
	@ResponseBody
	public Map<String, Object> insertTmpRecipeAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) {
		System.err.println(param);
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			int recipeIdx = recipeService.insertTmpRecipe(param);			
			returnMap.put("IDX", recipeIdx);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		
		return returnMap;
	}
	
	@RequestMapping("/insertRecipeAjax")
	@ResponseBody
	public Map<String, Object> insertRecipeAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) {
		System.err.println(param);
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			int recipeIdx = recipeService.insertRecipe(param);			
			returnMap.put("IDX", recipeIdx);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		
		return returnMap;
	}
	
	@RequestMapping(value = "/view")
	public String view( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model ) throws Exception{
		logger.debug("param : {} ",param.toString());
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		model.addAttribute("userId", auth.getUserId());
		
		Map<String, Object> recipeData = recipeService.selectRecipeData(param);
		model.addAttribute("recipeData", recipeData);
		//2.lab_recipe_material 조회
		List<Map<String, Object>> materialList = recipeService.selectMaterialList(param);
		model.addAttribute("materialList", materialList);
		//3.lab_recipe_purchase
		List<Map<String, Object>> purchaseList = recipeService.selectPurchaseList(param);
		model.addAttribute("purchaseList", purchaseList);
		
		param.put("docIdx", param.get("idx"));
		param.put("docType", "RECIPE");
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		if( apprHeader != null && apprHeader.get("APPR_IDX") != null && !"".equals(apprHeader.get("APPR_IDX")) ) {
			model.addAttribute("apprHeader", apprHeader);
			//lab_approval_item 테이블 조회
			param.put("apprIdx", apprHeader.get("APPR_IDX"));
			List<Map<String, Object>> apprItemList = approvalService.selectApprItemList(param);
			model.addAttribute("apprItemList", apprItemList);
			
			//lab_approval_reference 테이블 조회
			List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
			model.addAttribute("refList", refList);
		}
		
		return "/recipe/view";
	}
	
	@RequestMapping(value = "/update")
	public String update( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			//해당 문서가 내 문서인지 확인한다.
			if( recipeService.selectMyDataCheck(param) > 0 ) {
				//1.lab_recipe 조회
				Map<String, Object> recipeData = recipeService.selectRecipeData(param);
				model.addAttribute("recipeData", recipeData);
				//2.lab_recipe_material 조회
				List<Map<String, Object>> materialList = recipeService.selectMaterialList(param);
				model.addAttribute("materialList", materialList);
				//3.lab_recipe_purchase
				List<Map<String, Object>> purchaseList = recipeService.selectPurchaseList(param);
				model.addAttribute("purchaseList", purchaseList);
				
				param.put("docIdx", param.get("idx"));
				param.put("docType", "RECIPE");
				Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
				if( apprHeader != null && apprHeader.get("APPR_IDX") != null && !"".equals(apprHeader.get("APPR_IDX")) ) {
					model.addAttribute("apprHeader", apprHeader);
					//lab_approval_item 테이블 조회
					param.put("apprIdx", apprHeader.get("APPR_IDX"));
					List<Map<String, Object>> apprItemList = approvalService.selectApprItemList(param);
					model.addAttribute("apprItemList", apprItemList);
					
					//lab_approval_reference 테이블 조회
					List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
					model.addAttribute("refList", refList);
				}
				
				return "/recipe/update";
			} else {
				model.addAttribute("returnPage", "/recipe/list");
				return "/error/noAuth";
			}
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/updateTmpRecipeAjax")
	@ResponseBody
	public Map<String, Object> updateTmpRecipeAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) {
		System.err.println(param);
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			recipeService.updateTmpRecipe(param);			
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		
		return returnMap;
	}
	
	@RequestMapping("/updateRecipeAjax")
	@ResponseBody
	public Map<String, Object> updateRecipeAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) {
		System.err.println(param);
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			recipeService.updateRecipe(param);			
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		
		return returnMap;
	}
	
	@RequestMapping("/insertErpAjax")
	@ResponseBody
	public Map<String, Object> insertErpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) {
		System.err.println(param);
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			if( recipeService.selectMyDataCheck(param) > 0 ) {
				returnMap = recipeService.insertErp(param);				
			} else {
				returnMap.put("RESULT", "E");
				returnMap.put("MESSAGE","해당 문서에 권한이 없거나,\n ERP 반영이 불가능한 문서입니다.");
			}	
		} catch( Exception e ) {
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		
		return returnMap;
	}
	
	@RequestMapping(value = "/versionUp")
	public String versionUp( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			//해당 문서가 내 문서인지 확인한다.
			if( recipeService.selectMyDataCheck(param) > 0 ) {
				//1.lab_recipe 조회
				Map<String, Object> recipeData = recipeService.selectRecipeData(param);
				model.addAttribute("recipeData", recipeData);
				//2.lab_recipe_material 조회
				List<Map<String, Object>> materialList = recipeService.selectMaterialList(param);
				model.addAttribute("materialList", materialList);
				//3.lab_recipe_purchase
				List<Map<String, Object>> purchaseList = recipeService.selectPurchaseList(param);
				model.addAttribute("purchaseList", purchaseList);
				
				return "/recipe/versionUp";
			} else {
				model.addAttribute("returnPage", "/recipe/list");
				return "/error/noAuth";
			}
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/versionUpTmpRecipeAjax")
	@ResponseBody
	public Map<String, Object> versionUpTmpRecipeAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) {
		System.err.println(param);
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			int idx = recipeService.versionUpTmpRecipe(param);			
			returnMap.put("IDX", idx);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		
		return returnMap;
	}
	
	@RequestMapping("/versionUpRecipeAjax")
	@ResponseBody
	public Map<String, Object> versionUpRecipeAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) {
		System.err.println(param);
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			int idx = recipeService.versionUpRecipe(param);			
			returnMap.put("IDX", idx);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		
		return returnMap;
	}
	
	@RequestMapping("/applyErpAjax")
	@ResponseBody
	public Map<String, Object> applyErpAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = recipeService.applyErp(param);
		return returnMap;
	}
	
	
	@RequestMapping("/selectHistoryAjax")
	@ResponseBody
	@JsonIgnore
	public List<Map<String, Object>> selectHistoryAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return recipeService.selectHistory(param);
	}
	
	@RequestMapping("/selectRecipeErpMaterialListAjax")
	@ResponseBody
	public Map<String, Object> selectErpMaterialListAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return recipeService.selectRecipeErpMaterialList(param);
	}
}
