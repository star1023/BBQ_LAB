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
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.ApprovalService;
import kr.co.genesiskorea.service.BusinessTripPlanService;
import kr.co.genesiskorea.service.BusinessTripService;
import kr.co.genesiskorea.service.ChemicalTestService;
import kr.co.genesiskorea.service.DesignReportService;
import kr.co.genesiskorea.service.MarketResearchService;
import kr.co.genesiskorea.service.NewProductResultService;
import kr.co.genesiskorea.service.PackageInfoService;
import kr.co.genesiskorea.service.ProductService;
import kr.co.genesiskorea.service.SenseQualityService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/approval")
public class ApprovalController {
	private Logger logger = LogManager.getLogger(ApprovalController.class);
	
	@Autowired
	ApprovalService approvalService;
	
	@Autowired
	ProductService productService;
	
	@Autowired
	DesignReportService designReportService;
	
	@Autowired
	BusinessTripPlanService businessTripPlanService;
	
	@Autowired
	BusinessTripService businessTripService;
	
	@Autowired
	MarketResearchService marketResearchService;
	
	@Autowired
	SenseQualityService senseQualityService;
	
	@Autowired
	ChemicalTestService chemicalTestService;
	
	@Autowired
	NewProductResultService newProductResultService;
	
	@Autowired
	PackageInfoService packageInfoService;
	
	@RequestMapping("/searchUserAjax")
	@ResponseBody
	public List<Map<String, Object>> searchUserAjax(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//lab_product 테이블 조회, lab_file 테이블 조회
		List<Map<String, Object>> list = approvalService.searchUser(param);
		return list;
	}
	
	@RequestMapping("/insertApprLineAjax")
	@ResponseBody
	public Map<String, String> insertApprLineAjax(HttpSession session,HttpServletRequest request, HttpServletResponse response
			, @RequestParam Map<String, Object> param
			, @RequestParam(value = "apprLine", required = false) List<String> apprLine
			, ModelMap model) throws Exception{
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			param.put("apprLine", apprLine);
			approvalService.insertApprLine(param);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/selectApprovalLineAjax")
	@ResponseBody
	public List<Map<String, Object>> selectApprovalLineAjax(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//lab_product 테이블 조회, lab_file 테이블 조회
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		List<Map<String, Object>> list = approvalService.selectApprovalLine(param);
		return list;
	}
	
	@RequestMapping("/selectApprovalLineItemAjax")
	@ResponseBody
	public List<Map<String, Object>> selectApprovalLineItemAjax(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//lab_product 테이블 조회, lab_file 테이블 조회
		List<Map<String, Object>> list = approvalService.selectApprovalLineItem(param);
		return list;
	}
	
	@RequestMapping("/deleteApprLineAjax")
	@ResponseBody
	public Map<String, String> deleteApprLineAjax(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//lab_product 테이블 조회, lab_file 테이블 조회
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			approvalService.deleteApprLine(param);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/insertApprAjax")
	@ResponseBody
	public Map<String, String> insertApprAjax(HttpSession session,HttpServletRequest request, HttpServletResponse response
			, @RequestParam Map<String, Object> param
			, @RequestParam(value = "apprLine", required = false) List<String> apprLine
			, @RequestParam(value = "refLine", required = false) List<String> refLine
			, ModelMap model) throws Exception{
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			//Map<String, Object> paramMap = new HashMap<String, Object>();
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			param.put("apprLine", apprLine);
			param.put("refLine", refLine);
			approvalService.insertAppr(param);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/list")
	public String list(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		return "/approval/list";
	}
	
	@RequestMapping("/selectListAjax")
	@ResponseBody
	public Map<String, Object> selectListAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		try {
			logger.debug("param {}", param);
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			//param.put("state", "0");
			return approvalService.selectList(param);
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectMyApprListAjax")
	@ResponseBody
	public Map<String, Object> selectMyApprListAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		try {
			logger.debug("param {}", param);
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			//param.put("state", "0");
			return approvalService.selectMyApprList(param);
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectMyRefListAjax")
	@ResponseBody
	public Map<String, Object> selectMyRefListAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		try {
			logger.debug("param {}", param);
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			//param.put("state", "0");
			return approvalService.selectMyRefList(param);
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectMyCompListAjax")
	@ResponseBody
	public Map<String, Object> selectMyCompListAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		try {
			logger.debug("param {}", param);
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			//param.put("state", "0");
			return approvalService.selectMyCompList(param);
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/cancelApprAjax")
	@ResponseBody
	public Map<String, String> cancelApprAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			logger.debug("param {}", param);
			System.err.println(param);
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			returnMap = approvalService.cancelAppr(param);
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/reApprAjax")
	@ResponseBody
	public Map<String, String> reApprAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			logger.debug("param {}", param);
			System.err.println(param);
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			returnMap = approvalService.reAppr(param);
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/productPopup")
	public String productPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		//결재 정보 조회
		param.put("userId", AuthUtil.getAuth(request).getUserId());
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		List<Map<String, Object>> apprItem = approvalService.selectApprItemList(param);
		List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
		Map<String, Object> productData = productService.selectProductData(param);
		List<Map<String, Object>> addInfoList = productService.selectAddInfo(param);		
		List<Map<String, Object>> newDataList = productService.selectNewDataList(param);
		//참조 문서를 조회하는 경우 참조 테이블의 IS_READ 데이터를 Y로 변경한다.
		if( param != null && "myRefList".equals(param.get("viewType").toString())) {
			try {
				approvalService.updateRefIsRead(param);
			} catch( Exception e ) {
				
			}
		}
		model.addAttribute("apprHeader", apprHeader);
		model.addAttribute("apprItem", apprItem);
		model.addAttribute("refList", refList);
		model.addAttribute("productData", productData);
		model.addAttribute("addInfoList", addInfoList);
		model.addAttribute("newDataList", newDataList);
		model.addAttribute("paramVO", param);
		//lab_product_materisl 테이블 조회
		model.addAttribute("productMaterialData", productService.selectProductMaterial(param));
		return "/approval/productPopup";
	}
	
	@RequestMapping("/designPopup")
	public String designPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		System.err.println(param);
		//결재 정보 조회
		param.put("userId", AuthUtil.getAuth(request).getUserId());
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		List<Map<String,Object>> apprItem = approvalService.selectApprItemList(param);
		List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
		Map<String, Object> designData = designReportService.selectDesignData(param);
		
		//lab_design_change_info 테이블 조회
		List<Map<String, Object>> designChangeList =  designReportService.selectDesignChangeList(param);
		//lab_design_add_info 테이블 조회
		List<Map<String, Object>> addInfoList = designReportService.selectAddInfoList(param);
		//참조 문서를 조회하는 경우 참조 테이블의 IS_READ 데이터를 Y로 변경한다.
		if( param != null && "myRefList".equals(param.get("viewType").toString())) {
			try {
				approvalService.updateRefIsRead(param);
			} catch( Exception e ) {
				
			}
		}
		model.addAttribute("apprHeader", apprHeader);
		model.addAttribute("apprItem", apprItem);
		model.addAttribute("refList", refList);
		model.addAttribute("designData", designData);
		model.addAttribute("designChangeList", designChangeList);
		model.addAttribute("addInfoList", addInfoList);
		model.addAttribute("paramVO", param);
		//lab_product_materisl 테이블 조회
		
		model.addAttribute("designChangeList", designReportService.selectDesignChangeList(param));
		return "/approval/designPopup";
	}
	
	@RequestMapping("/businessTripPlanPopup")
	public String businessTripPlanPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		System.err.println(param);
		//결재 정보 조회
		param.put("userId", AuthUtil.getAuth(request).getUserId());
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		List<Map<String, Object>> apprItem = approvalService.selectApprItemList(param);
		List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
		//1.lab_business_trip_plan 조회
		Map<String, Object> planData = businessTripPlanService.selectBusinessTripPlanData(param);
		//2.lab_business_trip_plan_user 조회
		List<Map<String, Object>> userList = businessTripPlanService.selectBusinessTripPlanUserList(param);
		//3.lab_business_trip_plan_add_info 조회
		List<Map<String, Object>> infoList = businessTripPlanService.selectBusinessTripPlanAddInfoList(param);
		//4.lab_business_trip_plan_contents 조회
		List<Map<String, Object>> contentsList = businessTripPlanService.selectBusinessTripPlanContentsList(param);
		//참조 문서를 조회하는 경우 참조 테이블의 IS_READ 데이터를 Y로 변경한다.
		if( param != null && "myRefList".equals(param.get("viewType").toString())) {
			try {
				approvalService.updateRefIsRead(param);
			} catch( Exception e ) {
				
			}
		}
		model.addAttribute("apprHeader", apprHeader);
		model.addAttribute("apprItem", apprItem);
		model.addAttribute("refList", refList);
		model.addAttribute("planData", planData);
		model.addAttribute("userList", userList);
		model.addAttribute("infoList", infoList);
		model.addAttribute("contentsList", contentsList);
		model.addAttribute("paramVO", param);

		return "/approval/businessTripPlanPopup";
	}
	
	@RequestMapping("/businessTripPopup")
	public String businessTripPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		//결재 정보 조회
		param.put("userId", AuthUtil.getAuth(request).getUserId());
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		List<Map<String, Object>> apprItem = approvalService.selectApprItemList(param);
		List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
		//1.lab_business_trip 조회
		Map<String, Object> businessTripData = businessTripService.selectBusinessTripData(param);
		//2.lab_business_trip_user 조회
		List<Map<String, Object>> userList = businessTripService.selectBusinessTripUserList(param);
		//3.lab_business_trip_add_info 조회
		List<Map<String, Object>> infoList = businessTripService.selectBusinessTripAddInfoList(param);
		//4.lab_business_trip_contents 조회
		List<Map<String, Object>> contentsList = businessTripService.selectBusinessTripContentsList(param);
		//참조 문서를 조회하는 경우 참조 테이블의 IS_READ 데이터를 Y로 변경한다.
		if( param != null && "myRefList".equals(param.get("viewType").toString())) {
			try {
				approvalService.updateRefIsRead(param);
			} catch( Exception e ) {
				
			}
		}
		model.addAttribute("apprHeader", apprHeader);
		model.addAttribute("apprItem", apprItem);
		model.addAttribute("refList", refList);
		model.addAttribute("businessTripData", businessTripData);
		model.addAttribute("userList", userList);
		model.addAttribute("infoList", infoList);
		model.addAttribute("contentsList", contentsList);
		model.addAttribute("paramVO", param);

		return "/approval/businessTripPopup";
	}
	
	@RequestMapping("/marketResearchPopup")
	public String marketResearchPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		System.err.println(param);
		//결재 정보 조회
		param.put("userId", AuthUtil.getAuth(request).getUserId());
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		List<Map<String, Object>> apprItem = approvalService.selectApprItemList(param);
		List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
		//1.lab_market_research 조회
		Map<String, Object> researchData = marketResearchService.selectMarketResearchData(param);
		//2.lab_market_research_user 조회
		List<Map<String, Object>> userList = marketResearchService.selectMarketResearchUserList(param);
		//3.lab_market_research_add_info 조회
		List<Map<String, Object>> infoList = marketResearchService.selectMarketResearchAddInfoList(param);
		//참조 문서를 조회하는 경우 참조 테이블의 IS_READ 데이터를 Y로 변경한다.
		if( param != null && "myRefList".equals(param.get("viewType").toString())) {
			try {
				approvalService.updateRefIsRead(param);
			} catch( Exception e ) {
				
			}
		}
		model.addAttribute("apprHeader", apprHeader);
		model.addAttribute("apprItem", apprItem);
		model.addAttribute("refList", refList);
		model.addAttribute("researchData", researchData);
		model.addAttribute("userList", userList);
		model.addAttribute("infoList", infoList);
		model.addAttribute("paramVO", param);

		return "/approval/marketResearchPopup";
	}
	
	@RequestMapping("/senseQualityReportPopup")
	public String senseQualityReportPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		//결재 정보 조회
		param.put("userId", AuthUtil.getAuth(request).getUserId());
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		List<Map<String, Object>> apprItem = approvalService.selectApprItemList(param);
		List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
		Map<String, Object> senseQualityData = senseQualityService.selectSenseQualityData(param);
		//참조 문서를 조회하는 경우 참조 테이블의 IS_READ 데이터를 Y로 변경한다.
		if( param != null && "myRefList".equals(param.get("viewType").toString())) {
			try {
				approvalService.updateRefIsRead(param);
			} catch( Exception e ) {
				
			}
		}
		
		model.addAttribute("apprHeader", apprHeader);
		model.addAttribute("apprItem", apprItem);
		model.addAttribute("refList", refList);
		model.addAttribute("senseQualityData", senseQualityData);
		model.addAttribute("paramVO", param);

		return "/approval/senseQualityReportPopup";
	}
	
	@RequestMapping("/chemicalTestPopup")
	public String chemicalTestPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		System.err.println(param);
		//결재 정보 조회
		param.put("userId", AuthUtil.getAuth(request).getUserId());
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		List<Map<String, Object>> apprItem = approvalService.selectApprItemList(param);
		List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
		Map<String, Object> chemicalTestData = chemicalTestService.selectChemicalTestData(param);
		List<Map<String, Object>> chemicalTestItemList = chemicalTestService.selectChemicalTestItemList(param);
		List<Map<String, Object>> chemicalTestStandardList = chemicalTestService.selectChemicalTestStandardList(param);
		//참조 문서를 조회하는 경우 참조 테이블의 IS_READ 데이터를 Y로 변경한다.
		if( param != null && "myRefList".equals(param.get("viewType").toString())) {
			try {
				approvalService.updateRefIsRead(param);
			} catch( Exception e ) {
				
			}
		}
		model.addAttribute("apprHeader", apprHeader);
		model.addAttribute("apprItem", apprItem);
		model.addAttribute("refList", refList);
		model.addAttribute("chemicalTestData", chemicalTestData);
		model.addAttribute("chemicalTestItemList", chemicalTestItemList);
		model.addAttribute("chemicalTestStandardList", chemicalTestStandardList);
		model.addAttribute("paramVO", param);
		
		return "/approval/chemicalTestPopup";
	}
	
	@RequestMapping("/newProductResultPopup")
	public String newProductResultPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		System.err.println(param);
		//결재 정보 조회
		param.put("userId", AuthUtil.getAuth(request).getUserId());
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		List<Map<String, Object>> apprItem = approvalService.selectApprItemList(param);
		List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
		Map<String, Object> newProductResultData = newProductResultService.selectNewProductResultData(param);
		List<Map<String, Object>> newProductResultItemList = newProductResultService.selectNewProductResultItemList(param);
		List<Map<String, Object>> newProductResultImageList = newProductResultService.selectNewProductResultItemList(param);
		//참조 문서를 조회하는 경우 참조 테이블의 IS_READ 데이터를 Y로 변경한다.
		if( param != null && "myRefList".equals(param.get("viewType").toString())) {
			try {
				approvalService.updateRefIsRead(param);
			} catch( Exception e ) {
				
			}
		}
		model.addAttribute("apprHeader", apprHeader);
		model.addAttribute("apprItem", apprItem);
		model.addAttribute("refList", refList);
		model.addAttribute("newProductResultData", newProductResultData);
		model.addAttribute("newProductResultItemList", newProductResultItemList);
		model.addAttribute("newProductResultImageList", newProductResultImageList);
		model.addAttribute("paramVO", param);
		
		return "/approval/newProductResultPopup";
	}

	@RequestMapping("/approvalSubmitAjax")
	@ResponseBody
	public Map<String, String> approvalSubmitAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			System.err.println(param);
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			
			returnMap = approvalService.approvalSubmit(param);
			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/approvalCondSubmitAjax")
	@ResponseBody
	public Map<String, String> approvalCondSubmitAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			System.err.println(param);
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			
			returnMap = approvalService.approvalCondSubmit(param);
			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/approvalRejectAjax")
	@ResponseBody
	public Map<String, String> approvalRejectAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			System.err.println(param);
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			
			returnMap = approvalService.approvalReject(param);
			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/selectApprItemAjax")
	@ResponseBody
	public Map<String, Object> selectApprItemAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		return approvalService.selectApprItem(param);
	}
}
