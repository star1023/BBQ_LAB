package kr.co.genesiskorea.controller;
/**
* @packageName    	: kr.co.genesiskorea.controller
* @fileName        	: ApprovalController
* @author        	: ssung
* @date            	: 2025.04
* @description      : 결재 Controller 클래스
* ===========================================================
* DATE              AUTHOR             NOTE
* -----------------------------------------------------------
* 2025.04        	ssung       	최초 생성
*/
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
import kr.co.genesiskorea.service.CodeManagementService;
import kr.co.genesiskorea.service.DesignReportService;
import kr.co.genesiskorea.service.EtcReportService;
import kr.co.genesiskorea.service.MarketResearchService;
import kr.co.genesiskorea.service.MenuService;
import kr.co.genesiskorea.service.NewProductResultService;
import kr.co.genesiskorea.service.PackageInfoService;
import kr.co.genesiskorea.service.ProductService;
import kr.co.genesiskorea.service.RecipeService;
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
	MenuService menuService;
	
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
	CodeManagementService codeManagementService;
	
	@Autowired
	PackageInfoService packageInfoService;
	
	@Autowired
	RecipeService recipeService;
	
	@Autowired
	EtcReportService etcReportService;
	
	/**
 	* 사용자 조회 Ajax 
	* @methodName   : searchUserAjax
	* @date        	: 2025.04.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/searchUserAjax")
	@ResponseBody
	public List<Map<String, Object>> searchUserAjax(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//lab_product 테이블 조회, lab_file 테이블 조회
		List<Map<String, Object>> list = approvalService.searchUser(param);
		return list;
	}
	
	/**
	* 결재라인 등록 Ajax
	* @methodName    : insertApprLineAjax
	* @date        : 2025.09.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @param apprLine
	* @param model
	* @return
	* @throws Exception
	 */
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
	
	/**
	 * 사용자가 저장한 결재라인 정보 조회 Ajax
	* @methodName    : selectApprovalLineAjax
	* @date        : 2025.09.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/selectApprovalLineAjax")
	@ResponseBody
	public List<Map<String, Object>> selectApprovalLineAjax(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//lab_product 테이블 조회, lab_file 테이블 조회
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		List<Map<String, Object>> list = approvalService.selectApprovalLine(param);
		return list;
	}
	
	/**
	 * 사용자가 저장한 결재라인 결재자 정보 조회 Ajax
	* @methodName    : selectApprovalLineItemAjax
	* @date        : 2025.09.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/selectApprovalLineItemAjax")
	@ResponseBody
	public List<Map<String, Object>> selectApprovalLineItemAjax(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//lab_product 테이블 조회, lab_file 테이블 조회
		List<Map<String, Object>> list = approvalService.selectApprovalLineItem(param);
		return list;
	}
	
	/**
	 * 결재라인 삭제 Ajax
	* @methodName    : deleteApprLineAjax
	* @date        : 2025.09.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @param model
	* @return
	* @throws Exception
	 */
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
	
	/**
	 * 결재 임시 저장.
	 * @param session
	 * @param request
	 * @param response
	 * @param param
	 * @param apprLine
	 * @param refLine
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/insertApprTmpAjax")
	@ResponseBody
	public Map<String, String> insertApprTmpAjax(HttpSession session,HttpServletRequest request, HttpServletResponse response
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
			approvalService.insertApprTmp(param);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	/**
	 * 결재라인 저장.
	* @methodName    : insertApprAjax
	* @date        : 2025.09.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @param apprLine
	* @param refLine
	* @param model
	* @return
	* @throws Exception
	 */
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
	
	/**
	 * 결재 리스트 화면
	* @methodName    : list
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/list")
	public String list(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		return "/approval/list";
	}
	
	/**
	 * 결재 리스트 조회 Ajax
	* @methodName    : selectListAjax
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
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
	
	/**
	 * 내가 결재할 문서 리스트 조회 Ajax
	* @methodName    : selectMyApprListAjax
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
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
	
	/**
	 * 참조리스트 조회 Ajax
	* @methodName    : selectMyRefListAjax
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
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
	
	/**
	 * 결재완료 리스트 조회 Ajax
	* @methodName    : selectMyCompListAjax
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
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
	
	/**
	 * 상신취소 Ajax
	* @methodName    : cancelApprAjax
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/cancelApprAjax")
	@ResponseBody
	public Map<String, String> cancelApprAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			logger.debug("param {}", param);
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			returnMap = approvalService.cancelAppr(param);
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	/**
	 * 재상신 Ajax
	* @methodName    : reApprAjax
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/reApprAjax")
	@ResponseBody
	public Map<String, String> reApprAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			logger.debug("param {}", param);
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			returnMap = approvalService.reAppr(param);
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	/**
	 * 제품완료 보고서 팝업
	* @methodName    : productPopup
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
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
	
	/**
	 * 메뉴완료보고서 팝업
	* @methodName    : menuPopup
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/menuPopup")
	public String menuPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		//결재 정보 조회
		param.put("userId", AuthUtil.getAuth(request).getUserId());
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		List<Map<String, Object>> apprItem = approvalService.selectApprItemList(param);
		List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
		Map<String, Object> menuData = menuService.selectMenuData(param);
		List<Map<String, String>> addInfoList = menuService.selectAddInfo(param);		
		List<Map<String, String>> newDataList = menuService.selectNewDataList(param);
		if( param != null && "myRefList".equals(param.get("viewType").toString())) {
			try {
				approvalService.updateRefIsRead(param);
			} catch( Exception e ) {
				
			}
		}
		model.addAttribute("apprHeader", apprHeader);
		model.addAttribute("apprItem", apprItem);
		model.addAttribute("refList", refList);
		model.addAttribute("menuData", menuData);
		model.addAttribute("addInfoList", addInfoList);
		model.addAttribute("newDataList", newDataList);
		model.addAttribute("paramVO", param);
		//lab_product_materisl 테이블 조회
		model.addAttribute("menuMaterialData", menuService.selectMenuMaterial(param));
		return "/approval/menuPopup";
	}
	
	/**
	 * 상품설계변경 보고서 팝업
	* @methodName    : designPopup
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/designPopup")
	public String designPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
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
	
	/**
	 * 출장계획보고서 팝업
	* @methodName    : businessTripPlanPopup
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/businessTripPlanPopup")
	public String businessTripPlanPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
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
	
	/**
	 * 출장결과보고서 팝업
	* @methodName    : businessTripPopup
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
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
	
	/**
	 * 시장조사결과보고서 팝업
	* @methodName    : marketResearchPopup
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/marketResearchPopup")
	public String marketResearchPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
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
	
	/**
	 * 관능&품질평가보고서 팝업
	* @methodName    : senseQualityReportPopup
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
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
	
	/**
	 * 이화학검사의뢰서 팝업
	* @methodName    : chemicalTestPopup
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/chemicalTestPopup")
	public String chemicalTestPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
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
	
	/**
	 * 메뉴품질점검결과 보고서 팝업
	* @methodName    : newProductResultPopup
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/newProductResultPopup")
	public String newProductResultPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		//결재 정보 조회
		param.put("userId", AuthUtil.getAuth(request).getUserId());
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		List<Map<String, Object>> apprItem = approvalService.selectApprItemList(param);
		List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
		Map<String, Object> newProductResultData = newProductResultService.selectNewProductResultData(param);
		List<Map<String, Object>> newProductResultItemList = newProductResultService.selectNewProductResultItemList(param);
		List<Map<String, Object>> newProductResultImageList = newProductResultService.selectNewProductResultItemImageList(param);
		//참조 문서를 조회하는 경우 참조 테이블의 IS_READ 데이터를 Y로 변경한다.
		if( param != null && "myRefList".equals(param.get("viewType").toString())) {
			try {
				approvalService.updateRefIsRead(param);
			} catch( Exception e ) {
				
			}
		}
		Map<String, String> codeParam = new HashMap<>();
		codeParam.put("groupCode", "COLUMN");
		List<HashMap<String, Object>> columnCodeList = codeManagementService.getItemList(codeParam);
		model.addAttribute("codeList", columnCodeList);
		model.addAttribute("apprHeader", apprHeader);
		model.addAttribute("apprItem", apprItem);
		model.addAttribute("refList", refList);
		model.addAttribute("newProductResultData", newProductResultData);
		model.addAttribute("newProductResultItemList", newProductResultItemList);
		model.addAttribute("newProductResultImageList", newProductResultImageList);
		model.addAttribute("paramVO", param);
		
		return "/approval/newProductResultPopup";
	}
	
	/**
	 * 사전원가서 팝업
	* @methodName    : recipePopup
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/recipePopup")
	public String recipePopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		//결재 정보 조회
		param.put("userId", AuthUtil.getAuth(request).getUserId());
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		List<Map<String, Object>> apprItem = approvalService.selectApprItemList(param);
		List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
		Map<String, Object> recipeData = recipeService.selectRecipeData(param);
		model.addAttribute("recipeData", recipeData);
		//2.lab_recipe_material 조회
		List<Map<String, Object>> materialList = recipeService.selectMaterialList(param);
		model.addAttribute("materialList", materialList);
		//3.lab_recipe_purchase
		List<Map<String, Object>> purchaseList = recipeService.selectPurchaseList(param);
		model.addAttribute("purchaseList", purchaseList);
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
		model.addAttribute("paramVO", param);
		
		return "/approval/recipePopup";
	}
	
	/**
	 * 기타보고서 팝업
	* @methodName    : etcPopup
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/etcPopup")
	public String etcPopup(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		//결재 정보 조회
		param.put("userId", AuthUtil.getAuth(request).getUserId());
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(param);
		List<Map<String,Object>> apprItem = approvalService.selectApprItemList(param);
		List<Map<String, Object>> refList = approvalService.selectReferenceList(param);
		Map<String, Object> etcData = etcReportService.selectEtcData(param);
		
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
		model.addAttribute("etcData", etcData);
		model.addAttribute("paramVO", param);
		
		return "/approval/etcPopup";
	}
	
	/**
	 * 결재 승인 Ajax
	* @methodName    : approvalSubmitAjax
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/approvalSubmitAjax")
	@ResponseBody
	public Map<String, String> approvalSubmitAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			
			returnMap = approvalService.approvalSubmit(param);
			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	/**
	 * 부분승인 Ajax
	* @methodName    : approvalCondSubmitAjax
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/approvalCondSubmitAjax")
	@ResponseBody
	public Map<String, String> approvalCondSubmitAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			
			returnMap = approvalService.approvalCondSubmit(param);
			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	/**
	 * 반려 Ajax
	* @methodName    : approvalRejectAjax
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/approvalRejectAjax")
	@ResponseBody
	public Map<String, String> approvalRejectAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			param.put("userId", AuthUtil.getAuth(request).getUserId());
			
			returnMap = approvalService.approvalReject(param);
			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	/**
	 * 결재라인 아이템 조회 Ajax
	* @methodName    : selectApprItemAjax
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/selectApprItemAjax")
	@ResponseBody
	public Map<String, Object> selectApprItemAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		return approvalService.selectApprItem(param);
	}
	
	/**
	 * 참조자 등록 Ajax
	* @methodName    : addReferenceAjax
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/addReferenceAjax")
	@ResponseBody
	public Map<String, Object> addReferenceAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		return approvalService.addReference(param);
	}
	
	/**
	 * 참조자 조회 Ajax
	* @methodName    : selectRefInfoListAjax
	* @date        : 2025.09.16
	* @param param
	* @param request
	* @param response
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/selectRefInfoListAjax")
	@ResponseBody
	public List<Map<String, Object>> selectRefInfoListAjax(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		return approvalService.selectRefInfoList(param);
	}
}
