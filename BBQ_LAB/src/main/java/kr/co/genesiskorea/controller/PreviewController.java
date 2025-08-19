package kr.co.genesiskorea.controller;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.itextpdf.html2pdf.ConverterProperties;
import com.itextpdf.html2pdf.HtmlConverter;
import com.itextpdf.io.font.PdfEncodings;
import com.itextpdf.kernel.events.PdfDocumentEvent;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfPage;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.kernel.pdf.canvas.PdfCanvas;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.font.FontProvider;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.ApprovalService;
import kr.co.genesiskorea.service.BusinessTripPlanService;
import kr.co.genesiskorea.service.BusinessTripService;
import kr.co.genesiskorea.service.ChemicalTestService;
import kr.co.genesiskorea.service.CodeManagementService;
import kr.co.genesiskorea.service.CommonService;
import kr.co.genesiskorea.service.DesignReportService;
import kr.co.genesiskorea.service.EtcReportService;
import kr.co.genesiskorea.service.MarketResearchService;
import kr.co.genesiskorea.service.MenuService;
import kr.co.genesiskorea.service.NewProductResultService;
import kr.co.genesiskorea.service.PackageInfoService;
import kr.co.genesiskorea.service.ProductService;
import kr.co.genesiskorea.service.RecipeService;
import kr.co.genesiskorea.service.SenseQualityService;
import kr.co.genesiskorea.service.UserService;

@Controller
@RequestMapping("/preview")
public class PreviewController {

	@Autowired
	MenuService menuService;
	
	@Autowired
	ProductService productService;
	
	@Autowired
	DesignReportService designService;
	
	@Autowired
	BusinessTripPlanService businessTripPlanService;
	
	@Autowired
	BusinessTripService businessTripService;
	
	@Autowired
	MarketResearchService marketResearchService;
	
	@Autowired
	ChemicalTestService chemicalTestService;
	
	@Autowired
	SenseQualityService senseQualityService;
	
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
	
	@Autowired
	UserService userService;
	
	@Autowired
	ApprovalService approvalService;
	
	@Autowired
	CommonService commonService;
	
    @RequestMapping("/productPopup")
    public String productPrevPopup() {
        return "preview/productPrevPopup";
    }

    @RequestMapping("/menuPopup")
    public String menuPrevPopup() {
        return "preview/menuPrevPopup";
    }
    
    @RequestMapping("/productVersionUpPopup")
    public String productVersionUpPopup() {
    	return "preview/productVersionUpPrevPopup";
    }
    
    @RequestMapping("/menuVersionUpPopup")
    public String menuVersionUpPopup() {
    	return "preview/menuVersionUpPrevPopup";
    }
    
    @RequestMapping("/productUpdatePopup")
    public String productUpdatePopup() {
    	return "preview/productUpdatePrevPopup";
    }
    
    @RequestMapping("/menuUpdatePopup")
    public String menuUpdatePopup() {
    	return "preview/menuUpdatePrevPopup";
    }
    
    @RequestMapping("/menuViewPopup")
    public String menuViewPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//lab_menu 테이블 조회, lab_file 테이블 조회
		Map<String, Object> menuData = menuService.selectMenuData(param);
		model.addAttribute("menuData", menuData);
		
	    // 1) 중첩 구조 안전 해제
	    @SuppressWarnings("unchecked")
	    Map<String, Object> data = (Map<String, Object>) menuData.get("data");
	    if (data == null) {
	        data = menuData; // 혹시나 평탄 구조일 경우 대비
	    }
	    
		// 문서 담당자의 기본 정보 조회
		Map<String, Object> userData = userService.getUserData((String)data.get("DOC_OWNER"));
		model.addAttribute("userData", userData);
		
		Map<String, Object> headerParam = new HashMap<>();

		headerParam.put("docIdx", data.get("MENU_IDX"));
		headerParam.put("docType", "MENU");
		headerParam.put("lastStatus", "Y");
		
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(headerParam);
		model.addAttribute("apprHeader", apprHeader);
		// APPR_IDX로 결재 아이템/참조 조회
		if (apprHeader != null && apprHeader.get("APPR_IDX") != null) {
		    Map<String, Object> apprOnly = new HashMap<>();
		    apprOnly.put("apprIdx", apprHeader.get("APPR_IDX"));

		    List<Map<String, Object>> apprItem = approvalService.selectApprItemList(apprOnly);
		    
		    apprItem.sort((a, b) -> {
		        int x = Integer.parseInt(String.valueOf(a.get("APPR_NO")));
		        int y = Integer.parseInt(String.valueOf(b.get("APPR_NO")));
		        return Integer.compare(x, y);
		    });
		    
		    for (Map<String, Object> row : apprItem) {
		        String targetId = (String) row.get("TARGET_USER_ID");
		        if (targetId != null && !targetId.isEmpty()) {
		            Map<String, Object> u = userService.getUserData(targetId);
		            if (u != null) {
		                // 프로젝트마다 키가 다를 수 있어 안전하게 처리
		                Object dept =
		                    u.get("OBJTTX") != null ? u.get("OBJTTX") : "";
		                row.put("OBJTTX", dept);
		            }
		        }
		    }
		    
		    model.addAttribute("apprItem", apprItem);
		}
		
		Map<String, Object> addInfoCount = menuService.selectAddInfoCount(param);
		model.addAttribute("addInfoCount", addInfoCount);
		List<Map<String, String>> addInfoList = menuService.selectAddInfo(param);
		model.addAttribute("addInfoList", addInfoList);
		List<Map<String, String>> imporvePurposeList = menuService.selectImporvePurposeList(param);
		model.addAttribute("imporvePurposeList", imporvePurposeList);
		List<Map<String, String>> newDataList = menuService.selectNewDataList(param);
		model.addAttribute("newDataList", newDataList);
		model.addAttribute("menuMaterialData", menuService.selectMenuMaterial(param));
		List<Map<String, String>> sharedUserList = menuService.selectSharedUser(param);
		model.addAttribute("sharedUserList", sharedUserList);
    	
    	return "preview/menuViewPrevPopup";
    }
    
    @RequestMapping("/productViewPopup")
    public String productViewPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//lab_product 테이블 조회, lab_file 테이블 조회
		Map<String, Object> productData = productService.selectProductData(param);
		model.addAttribute("productData", productData);
		
		// 1) 중첩 구조 안전 해제
	    @SuppressWarnings("unchecked")
	    Map<String, Object> data = (Map<String, Object>) productData.get("data");
	    if (data == null) {
	        data = productData; // 혹시나 평탄 구조일 경우 대비
	    }
	    
		// 문서 담당자의 기본 정보 조회
		Map<String, Object> userData = userService.getUserData((String)data.get("DOC_OWNER"));
		model.addAttribute("userData", userData);
		
		Map<String, Object> headerParam = new HashMap<>();

		headerParam.put("docIdx", data.get("PRODUCT_IDX"));
		headerParam.put("docType", "PROD");
		headerParam.put("lastStatus", "Y");
		
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(headerParam);
		model.addAttribute("apprHeader", apprHeader);
		// APPR_IDX로 결재 아이템/참조 조회
		if (apprHeader != null && apprHeader.get("APPR_IDX") != null) {
		    Map<String, Object> apprOnly = new HashMap<>();
		    apprOnly.put("apprIdx", apprHeader.get("APPR_IDX"));

		    List<Map<String, Object>> apprItem = approvalService.selectApprItemList(apprOnly);
		    
		    apprItem.sort((a, b) -> {
		        int x = Integer.parseInt(String.valueOf(a.get("APPR_NO")));
		        int y = Integer.parseInt(String.valueOf(b.get("APPR_NO")));
		        return Integer.compare(x, y);
		    });
		    
		    for (Map<String, Object> row : apprItem) {
		        String targetId = (String) row.get("TARGET_USER_ID");
		        if (targetId != null && !targetId.isEmpty()) {
		            Map<String, Object> u = userService.getUserData(targetId);
		            if (u != null) {
		                // 프로젝트마다 키가 다를 수 있어 안전하게 처리
		                Object dept =
		                    u.get("OBJTTX") != null ? u.get("OBJTTX") : "";
		                row.put("OBJTTX", dept);
		            }
		        }
		    }
		    
		    model.addAttribute("apprItem", apprItem);
		}
		
		Map<String, Object> addInfoCount = productService.selectAddInfoCount(param);
		model.addAttribute("addInfoCount", addInfoCount);
		List<Map<String, Object>> addInfoList = productService.selectAddInfo(param);
		model.addAttribute("addInfoList", addInfoList);
		List<Map<String, Object>> imporvePurposeList = productService.selectImporvePurposeList(param);
		model.addAttribute("imporvePurposeList", imporvePurposeList);
		List<Map<String, Object>> newDataList = productService.selectNewDataList(param);
		model.addAttribute("newDataList", newDataList);
		model.addAttribute("productMaterialData", productService.selectProductMaterial(param));
		List<Map<String, String>> sharedUserList = productService.selectSharedUser(param);
		model.addAttribute("sharedUserList", sharedUserList);
    	
    	return "preview/productViewPrevPopup";
    }
    
    @RequestMapping("/designReportViewPopup")
    public String designReportViewPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//lab_design 테이블 조회, lab_file 테이블 조회
		Map<String, Object> designData = designService.selectDesignData(param);
		model.addAttribute("designData", designData);
		
		// 1) 중첩 구조 안전 해제
	    @SuppressWarnings("unchecked")
	    Map<String, Object> data = (Map<String, Object>) designData.get("data");
	    if (data == null) {
	        data = designData; // 혹시나 평탄 구조일 경우 대비
	    }
	    
		// 문서 담당자의 기본 정보 조회
		Map<String, Object> userData = userService.getUserData((String)data.get("DOC_OWNER"));
		model.addAttribute("userData", userData);
		
		Map<String, Object> headerParam = new HashMap<>();

		headerParam.put("docIdx", data.get("DESIGN_IDX"));
		headerParam.put("docType", "DESIGN");
		headerParam.put("lastStatus", "Y");
		
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(headerParam);
		model.addAttribute("apprHeader", apprHeader);
		// APPR_IDX로 결재 아이템/참조 조회
		if (apprHeader != null && apprHeader.get("APPR_IDX") != null) {
		    Map<String, Object> apprOnly = new HashMap<>();
		    apprOnly.put("apprIdx", apprHeader.get("APPR_IDX"));

		    List<Map<String, Object>> apprItem = approvalService.selectApprItemList(apprOnly);
		    
		    apprItem.sort((a, b) -> {
		        int x = Integer.parseInt(String.valueOf(a.get("APPR_NO")));
		        int y = Integer.parseInt(String.valueOf(b.get("APPR_NO")));
		        return Integer.compare(x, y);
		    });
		    
		    for (Map<String, Object> row : apprItem) {
		        String targetId = (String) row.get("TARGET_USER_ID");
		        if (targetId != null && !targetId.isEmpty()) {
		            Map<String, Object> u = userService.getUserData(targetId);
		            if (u != null) {
		                // 프로젝트마다 키가 다를 수 있어 안전하게 처리
		                Object dept =
		                    u.get("OBJTTX") != null ? u.get("OBJTTX") : "";
		                row.put("OBJTTX", dept);
		            }
		        }
		    }
		    
		    model.addAttribute("apprItem", apprItem);
		}
		
		//lab_design_change_info 테이블 조회
		model.addAttribute("designChangeList", designService.selectDesignChangeList(param));
		//lab_design_add_info 테이블 조회
		model.addAttribute("addInfoList", designService.selectAddInfoList(param));
    	
    	return "preview/designReportViewPopup";
    }
    
    @RequestMapping("/designReportPrevPopup")
    public String designReportPrevPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	return "preview/designReportPrevPopup";
    }
    
    @RequestMapping("/businessTripPlanViewPopup")
    public String businessTripPlanViewPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	//1.lab_business_trip_plan 조회
		Map<String, Object> planData = businessTripPlanService.selectBusinessTripPlanData(param);
		
		// 1) 중첩 구조 안전 해제
	    @SuppressWarnings("unchecked")
	    Map<String, Object> data = (Map<String, Object>) planData.get("data");
	    if (data == null) {
	        data = planData; // 혹시나 평탄 구조일 경우 대비
	    }
	    
		// 문서 담당자의 기본 정보 조회
		Map<String, Object> userData = userService.getUserData((String)data.get("DOC_OWNER"));
		model.addAttribute("userData", userData);
		
		Map<String, Object> headerParam = new HashMap<>();

		headerParam.put("docIdx", data.get("PLAN_IDX"));
		headerParam.put("docType", "PLAN");
		headerParam.put("lastStatus", "Y");
		
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(headerParam);
		model.addAttribute("apprHeader", apprHeader);
		// APPR_IDX로 결재 아이템/참조 조회
		if (apprHeader != null && apprHeader.get("APPR_IDX") != null) {
		    Map<String, Object> apprOnly = new HashMap<>();
		    apprOnly.put("apprIdx", apprHeader.get("APPR_IDX"));

		    List<Map<String, Object>> apprItem = approvalService.selectApprItemList(apprOnly);
		    
		    apprItem.sort((a, b) -> {
		        int x = Integer.parseInt(String.valueOf(a.get("APPR_NO")));
		        int y = Integer.parseInt(String.valueOf(b.get("APPR_NO")));
		        return Integer.compare(x, y);
		    });
		    
		    for (Map<String, Object> row : apprItem) {
		        String targetId = (String) row.get("TARGET_USER_ID");
		        if (targetId != null && !targetId.isEmpty()) {
		            Map<String, Object> u = userService.getUserData(targetId);
		            if (u != null) {
		                // 프로젝트마다 키가 다를 수 있어 안전하게 처리
		                Object dept =
		                    u.get("OBJTTX") != null ? u.get("OBJTTX") : "";
		                row.put("OBJTTX", dept);
		            }
		        }
		    }
		    
		    model.addAttribute("apprItem", apprItem);
		}
		
		//2.lab_business_trip_plan_user 조회
		List<Map<String, Object>> userList = businessTripPlanService.selectBusinessTripPlanUserList(param);
		//3.lab_business_trip_plan_add_info 조회
		List<Map<String, Object>> infoList = businessTripPlanService.selectBusinessTripPlanAddInfoList(param);
		//4.lab_business_trip_plan_contents 조회
		List<Map<String, Object>> contentsList = businessTripPlanService.selectBusinessTripPlanContentsList(param);
		
		model.addAttribute("planData", planData);
		model.addAttribute("userList", userList);
		model.addAttribute("infoList", infoList);
		model.addAttribute("contentsList", contentsList);
    	
    	return "preview/businessTripPlanViewPopup";
    }
    
    @RequestMapping("/businessTripPlanPrevPopup")
    public String businessTripPlanPrevPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	return "preview/businessTripPlanPrevPopup";
    }
    @RequestMapping("/businessTripViewPopup")
    public String businessTripViewPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//lab_design 테이블 조회, lab_file 테이블 조회
		Map<String, Object> businessTripData = businessTripService.selectBusinessTripData(param);
		
		// 1) 중첩 구조 안전 해제
	    @SuppressWarnings("unchecked")
	    Map<String, Object> data = (Map<String, Object>) businessTripData.get("data");
	    if (data == null) {
	        data = businessTripData; // 혹시나 평탄 구조일 경우 대비
	    }
	    
		// 문서 담당자의 기본 정보 조회
		Map<String, Object> userData = userService.getUserData((String)data.get("DOC_OWNER"));
		model.addAttribute("userData", userData);
		
		Map<String, Object> headerParam = new HashMap<>();

		headerParam.put("docIdx", data.get("TRIP_IDX"));
		headerParam.put("docType", "TRIP");
		headerParam.put("lastStatus", "Y");
		
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(headerParam);
		model.addAttribute("apprHeader", apprHeader);
		// APPR_IDX로 결재 아이템/참조 조회
		if (apprHeader != null && apprHeader.get("APPR_IDX") != null) {
		    Map<String, Object> apprOnly = new HashMap<>();
		    apprOnly.put("apprIdx", apprHeader.get("APPR_IDX"));

		    List<Map<String, Object>> apprItem = approvalService.selectApprItemList(apprOnly);
		    
		    apprItem.sort((a, b) -> {
		        int x = Integer.parseInt(String.valueOf(a.get("APPR_NO")));
		        int y = Integer.parseInt(String.valueOf(b.get("APPR_NO")));
		        return Integer.compare(x, y);
		    });
		    
		    for (Map<String, Object> row : apprItem) {
		        String targetId = (String) row.get("TARGET_USER_ID");
		        if (targetId != null && !targetId.isEmpty()) {
		            Map<String, Object> u = userService.getUserData(targetId);
		            if (u != null) {
		                // 프로젝트마다 키가 다를 수 있어 안전하게 처리
		                Object dept =
		                    u.get("OBJTTX") != null ? u.get("OBJTTX") : "";
		                row.put("OBJTTX", dept);
		            }
		        }
		    }
		    
		    model.addAttribute("apprItem", apprItem);
		}
		
		//2.lab_business_trip_user 조회
		List<Map<String, Object>> userList = businessTripService.selectBusinessTripUserList(param);
		//3.lab_business_trip_add_info 조회
		List<Map<String, Object>> infoList = businessTripService.selectBusinessTripAddInfoList(param);
		//4.lab_business_trip_contents 조회
		List<Map<String, Object>> contentsList = businessTripService.selectBusinessTripContentsList(param);
		
		model.addAttribute("businessTripData", businessTripData);
		model.put("userList", userList);
		model.put("infoList", infoList);
		model.put("contentsList", contentsList);
    	
    	return "preview/businessTripViewPopup";
    }
    
    @RequestMapping("/businessTripPrevPopup")
    public String businessTripPrevPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	return "preview/businessTripPrevPopup";
    }
    
    @RequestMapping("/marketResearchViewPopup")
    public String marketResearchViewPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	//1.lab_market_research 조회
		Map<String, Object> researchData = marketResearchService.selectMarketResearchData(param);
		
		// 1) 중첩 구조 안전 해제
	    @SuppressWarnings("unchecked")
	    Map<String, Object> data = (Map<String, Object>) researchData.get("data");
	    if (data == null) {
	        data = researchData; // 혹시나 평탄 구조일 경우 대비
	    }
	    
		// 문서 담당자의 기본 정보 조회
		Map<String, Object> userData = userService.getUserData((String)data.get("DOC_OWNER"));
		model.addAttribute("userData", userData);
		
		Map<String, Object> headerParam = new HashMap<>();

		headerParam.put("docIdx", data.get("RESEARCH_IDX"));
		headerParam.put("docType", "RESEARCH");
		headerParam.put("lastStatus", "Y");
		
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(headerParam);
		model.addAttribute("apprHeader", apprHeader);
		// APPR_IDX로 결재 아이템/참조 조회
		if (apprHeader != null && apprHeader.get("APPR_IDX") != null) {
		    Map<String, Object> apprOnly = new HashMap<>();
		    apprOnly.put("apprIdx", apprHeader.get("APPR_IDX"));

		    List<Map<String, Object>> apprItem = approvalService.selectApprItemList(apprOnly);
		    
		    apprItem.sort((a, b) -> {
		        int x = Integer.parseInt(String.valueOf(a.get("APPR_NO")));
		        int y = Integer.parseInt(String.valueOf(b.get("APPR_NO")));
		        return Integer.compare(x, y);
		    });
		    
		    for (Map<String, Object> row : apprItem) {
		        String targetId = (String) row.get("TARGET_USER_ID");
		        if (targetId != null && !targetId.isEmpty()) {
		            Map<String, Object> u = userService.getUserData(targetId);
		            if (u != null) {
		                // 프로젝트마다 키가 다를 수 있어 안전하게 처리
		                Object dept =
		                    u.get("OBJTTX") != null ? u.get("OBJTTX") : "";
		                row.put("OBJTTX", dept);
		            }
		        }
		    }
		    
		    model.addAttribute("apprItem", apprItem);
		}
		
		//2.lab_market_research_user 조회
		List<Map<String, Object>> userList = marketResearchService.selectMarketResearchUserList(param);
		//3.lab_market_research_add_info 조회
		List<Map<String, Object>> infoList = marketResearchService.selectMarketResearchAddInfoList(param);
		
		model.addAttribute("researchData", researchData);
		model.addAttribute("userList", userList);
		model.addAttribute("infoList", infoList);
    	
    	return "preview/marketResearchViewPopup";
    }
    
    @RequestMapping("/marketResearchPrevPopup")
    public String marketResearchPrevPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	return "preview/marketResearchPrevPopup";
    }
    
    @RequestMapping("/chemicalTestViewPopup")
    public String chemicalTestViewPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	//1. lab_chemical_test 테이블 조회, lab_chemical_test 테이블 조회
		Map<String, Object> chemicalData = chemicalTestService.selectChemicalTestData(param);
		
		//2. lab_chemical_test_item 조회
		List<Map<String, Object>> itemList = chemicalTestService.selectChemicalTestItemList(param);
		//3. lab_chemical_test_standard 조회
		List<Map<String, Object>> standardList = chemicalTestService.selectChemicalTestStandardList(param);
		
		model.addAttribute("chemicalTestData", chemicalData);
		model.put("itemList", itemList);
		model.put("standardList", standardList);
    	
    	return "preview/chemicalTestViewPopup";
    }
    
    @RequestMapping("/chemicalTestPrevPopup")
    public String chemicalTestPrevPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	return "preview/chemicalTestPrevPopup";
    }
    
    @RequestMapping("/senseQualityViewPopup")
    public String senseQualityViewPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		Map<String, Object> senseQualityData = senseQualityService.selectSenseQualityData(param);
		model.addAttribute("userId", AuthUtil.getAuth(request).getUserId());
		model.addAttribute("senseQualityData", senseQualityData);
		
		// 1) 중첩 구조 안전 해제
	    @SuppressWarnings("unchecked")
	    Map<String, Object> data = (Map<String, Object>) senseQualityData.get("reportMap");
	    if (data == null) {
	        data = senseQualityData; // 혹시나 평탄 구조일 경우 대비
	    }
	    
		// 문서 담당자의 기본 정보 조회
		Map<String, Object> userData = userService.getUserData((String)data.get("DOC_OWNER"));
		model.addAttribute("userData", userData);
		
		Map<String, Object> headerParam = new HashMap<>();

		headerParam.put("docIdx", data.get("REPORT_IDX"));
		headerParam.put("docType", "SENSE_QUALITY");
		headerParam.put("lastStatus", "Y");
		
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(headerParam);
		model.addAttribute("apprHeader", apprHeader);
		// APPR_IDX로 결재 아이템/참조 조회
		if (apprHeader != null && apprHeader.get("APPR_IDX") != null) {
		    Map<String, Object> apprOnly = new HashMap<>();
		    apprOnly.put("apprIdx", apprHeader.get("APPR_IDX"));

		    List<Map<String, Object>> apprItem = approvalService.selectApprItemList(apprOnly);
		    
		    apprItem.sort((a, b) -> {
		        int x = Integer.parseInt(String.valueOf(a.get("APPR_NO")));
		        int y = Integer.parseInt(String.valueOf(b.get("APPR_NO")));
		        return Integer.compare(x, y);
		    });
		    
		    for (Map<String, Object> row : apprItem) {
		        String targetId = (String) row.get("TARGET_USER_ID");
		        if (targetId != null && !targetId.isEmpty()) {
		            Map<String, Object> u = userService.getUserData(targetId);
		            if (u != null) {
		                // 프로젝트마다 키가 다를 수 있어 안전하게 처리
		                Object dept =
		                    u.get("OBJTTX") != null ? u.get("OBJTTX") : "";
		                row.put("OBJTTX", dept);
		            }
		        }
		    }
		    
		    model.addAttribute("apprItem", apprItem);
		}
		
    	return "preview/senseQualityViewPopup";
    }
    
    @RequestMapping("/senseQualityPrevPopup")
    public String senseQualityPrevPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	return "preview/senseQualityPrevPopup";
    }
    
    @RequestMapping("/newProductViewPopup")
    public String newProductViewPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	//결재 정보 조회
		Map<String, Object> newProductResultData = newProductResultService.selectNewProductResultData(param);
		
		// 1) 중첩 구조 안전 해제
	    @SuppressWarnings("unchecked")
	    Map<String, Object> data = (Map<String, Object>) newProductResultData.get("data");
	    if (data == null) {
	        data = newProductResultData; // 혹시나 평탄 구조일 경우 대비
	    }
	    
		// 문서 담당자의 기본 정보 조회
		Map<String, Object> userData = userService.getUserData((String)data.get("DOC_OWNER"));
		model.addAttribute("userData", userData);
		
		Map<String, Object> headerParam = new HashMap<>();

		headerParam.put("docIdx", data.get("RESULT_IDX"));
		headerParam.put("docType", "RESULT");
		headerParam.put("lastStatus", "Y");
		
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(headerParam);
		model.addAttribute("apprHeader", apprHeader);
		// APPR_IDX로 결재 아이템/참조 조회
		if (apprHeader != null && apprHeader.get("APPR_IDX") != null) {
		    Map<String, Object> apprOnly = new HashMap<>();
		    apprOnly.put("apprIdx", apprHeader.get("APPR_IDX"));

		    List<Map<String, Object>> apprItem = approvalService.selectApprItemList(apprOnly);
		    
		    apprItem.sort((a, b) -> {
		        int x = Integer.parseInt(String.valueOf(a.get("APPR_NO")));
		        int y = Integer.parseInt(String.valueOf(b.get("APPR_NO")));
		        return Integer.compare(x, y);
		    });
		    
		    for (Map<String, Object> row : apprItem) {
		        String targetId = (String) row.get("TARGET_USER_ID");
		        if (targetId != null && !targetId.isEmpty()) {
		            Map<String, Object> u = userService.getUserData(targetId);
		            if (u != null) {
		                // 프로젝트마다 키가 다를 수 있어 안전하게 처리
		                Object dept =
		                    u.get("OBJTTX") != null ? u.get("OBJTTX") : "";
		                row.put("OBJTTX", dept);
		            }
		        }
		    }
		    
		    model.addAttribute("apprItem", apprItem);
		}
		
		List<Map<String, Object>> newProductResultItemList = newProductResultService.selectNewProductResultItemList(param);
		List<Map<String, Object>> newProductResultImageList = newProductResultService.selectNewProductResultItemImageList(param);
		Map<String, String> codeParam = new HashMap<>();
		codeParam.put("groupCode", "COLUMN");
		List<HashMap<String, Object>> columnCodeList = codeManagementService.getItemList(codeParam);
		model.addAttribute("codeList", columnCodeList);
		model.addAttribute("newProductResultData", newProductResultData);
		model.addAttribute("newProductResultItemList", newProductResultItemList);
		model.addAttribute("newProductResultImageList", newProductResultImageList);
    	return "preview/newProductViewPopup";
    }
    
    @RequestMapping("/newProductPrevPopup")
    public String newProductPrevPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	return "preview/newProductPrevPopup";
    }
    
    @RequestMapping("/packageInfoViewPopup")
    public String packageInfoViewPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		Map<String, Object> packageInfoData = packageInfoService.selectPackageInfoData(param);
		List<Map<String, Object>> addInfoList = packageInfoService.selectAddInfoList(param);
		
		model.addAttribute("packageInfoData", packageInfoData);
		
		// 문서 담당자의 기본 정보 조회
		Map<String, Object> userData = userService.getUserData((String)packageInfoData.get("DOC_OWNER"));
		model.addAttribute("userData", userData);
		
		model.addAttribute("addInfoList", addInfoList);
    	
    	return "preview/packageInfoViewPopup";
    }
    
    @RequestMapping("/packageInfoPrevPopup")
    public String packageInfoPrevPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	return "preview/packageInfoPrevPopup";
    }
    
    @RequestMapping("/recipeViewPopup")
    public String recipeViewPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{

    	Map<String, Object> recipeData = recipeService.selectRecipeData(param);
		model.addAttribute("recipeData", recipeData);
		//2.lab_recipe_material 조회
		List<Map<String, Object>> materialList = recipeService.selectMaterialList(param);
		model.addAttribute("materialList", materialList);
		//3.lab_recipe_purchase
		List<Map<String, Object>> purchaseList = recipeService.selectPurchaseList(param);
		model.addAttribute("purchaseList", purchaseList);
    	
		// 1) 중첩 구조 안전 해제
	    @SuppressWarnings("unchecked")
	    Map<String, Object> data = (Map<String, Object>) recipeData.get("data");
	    if (data == null) {
	        data = recipeData; // 혹시나 평탄 구조일 경우 대비
	    }
	    
		// 문서 담당자의 기본 정보 조회
		Map<String, Object> userData = userService.getUserData((String)data.get("DOC_OWNER"));
		model.addAttribute("userData", userData);
		
		Map<String, Object> headerParam = new HashMap<>();

		headerParam.put("docIdx", data.get("RECIPE_IDX"));
		headerParam.put("docType", "RECIPE");
		headerParam.put("lastStatus", "Y");
		
		Map<String, Object> apprHeader = approvalService.selectApprHeaderData(headerParam);
		model.addAttribute("apprHeader", apprHeader);
		// APPR_IDX로 결재 아이템/참조 조회
		if (apprHeader != null && apprHeader.get("APPR_IDX") != null) {
		    Map<String, Object> apprOnly = new HashMap<>();
		    apprOnly.put("apprIdx", apprHeader.get("APPR_IDX"));

		    List<Map<String, Object>> apprItem = approvalService.selectApprItemList(apprOnly);
		    
		    apprItem.sort((a, b) -> {
		        int x = Integer.parseInt(String.valueOf(a.get("APPR_NO")));
		        int y = Integer.parseInt(String.valueOf(b.get("APPR_NO")));
		        return Integer.compare(x, y);
		    });
		    
		    for (Map<String, Object> row : apprItem) {
		        String targetId = (String) row.get("TARGET_USER_ID");
		        if (targetId != null && !targetId.isEmpty()) {
		            Map<String, Object> u = userService.getUserData(targetId);
		            if (u != null) {
		                // 프로젝트마다 키가 다를 수 있어 안전하게 처리
		                Object dept =
		                    u.get("OBJTTX") != null ? u.get("OBJTTX") : "";
		                row.put("OBJTTX", dept);
		            }
		        }
		    }
		    
		    model.addAttribute("apprItem", apprItem);
		}
    	
    	
    	return "preview/recipeViewPopup";
    }
    
    @RequestMapping("/recipePrevPopup")
    public String recipePrevPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	return "preview/recipePrevPopup";
    }
    
    @RequestMapping("/etcReportViewPopup")
    public String etcReportViewPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	
    	Map<String, Object> etcData = etcReportService.selectEtcData(param);
    	model.addAttribute("etcData", etcData);
    	
    	// 1) 중첩 구조 안전 해제
    	@SuppressWarnings("unchecked")
    	Map<String, Object> data = (Map<String, Object>) etcData.get("data");
    	if (data == null) {
    		data = etcData; // 혹시나 평탄 구조일 경우 대비
    	}
    	
    	// 문서 담당자의 기본 정보 조회
    	Map<String, Object> userData = userService.getUserData((String)data.get("DOC_OWNER"));
    	model.addAttribute("userData", userData);
    	
    	Map<String, Object> headerParam = new HashMap<>();
    	
    	headerParam.put("docIdx", data.get("ETC_IDX"));
    	headerParam.put("docType", "ETC");
    	headerParam.put("lastStatus", "Y");
    	
    	Map<String, Object> apprHeader = approvalService.selectApprHeaderData(headerParam);
    	model.addAttribute("apprHeader", apprHeader);
    	// APPR_IDX로 결재 아이템/참조 조회
    	if (apprHeader != null && apprHeader.get("APPR_IDX") != null) {
    		Map<String, Object> apprOnly = new HashMap<>();
    		apprOnly.put("apprIdx", apprHeader.get("APPR_IDX"));
    		
    		List<Map<String, Object>> apprItem = approvalService.selectApprItemList(apprOnly);
    		
    		apprItem.sort((a, b) -> {
    			int x = Integer.parseInt(String.valueOf(a.get("APPR_NO")));
    			int y = Integer.parseInt(String.valueOf(b.get("APPR_NO")));
    			return Integer.compare(x, y);
    		});
    		
    		for (Map<String, Object> row : apprItem) {
    			String targetId = (String) row.get("TARGET_USER_ID");
    			if (targetId != null && !targetId.isEmpty()) {
    				Map<String, Object> u = userService.getUserData(targetId);
    				if (u != null) {
    					// 프로젝트마다 키가 다를 수 있어 안전하게 처리
    					Object dept =
    							u.get("OBJTTX") != null ? u.get("OBJTTX") : "";
    					row.put("OBJTTX", dept);
    				}
    			}
    		}
    		
    		model.addAttribute("apprItem", apprItem);
    	}
    	
    	
    	return "preview/etcReportViewPopup";
    }
    
    @RequestMapping("/etcReportPrevPopup")
    public String etcReportPrevPopup(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
    	return "preview/etcReportPrevPopup";
    }
    
    @PostMapping("/downloadPdf")
    public void downloadPdf(@RequestParam("htmlContent") String htmlContent, HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) {
        try {
            ByteArrayOutputStream pdfStream = new ByteArrayOutputStream();

            // 1. 폰트 경로 및 PdfFont 미리 생성
            String fontPath = request.getServletContext().getRealPath("/resources/font/NotoSansKR-Regular.otf");
            File fontFile = new File(fontPath);
            if (!fontFile.exists()) {
                throw new RuntimeException("❌ 폰트 파일을 찾을 수 없습니다: " + fontPath);
            }
            PdfFont koreanFont = PdfFontFactory.createFont(fontPath, PdfEncodings.IDENTITY_H);

            // 2. FontProvider 구성
            FontProvider fontProvider = new FontProvider();
            fontProvider.addFont(fontPath);
            ConverterProperties props = new ConverterProperties();
            props.setFontProvider(fontProvider);
            props.setCharset("UTF-8");

            // 3. PDF 작성 시작
            PdfWriter writer = new PdfWriter(pdfStream);
            PdfDocument pdfDoc = new PdfDocument(writer);

            // 4. 페이지 번호 이벤트 등록
            pdfDoc.addEventHandler(PdfDocumentEvent.END_PAGE, event -> {
                PdfDocumentEvent docEvent = (PdfDocumentEvent) event;
                PdfPage page = docEvent.getPage();
                int pageNumber = pdfDoc.getPageNumber(page);
                PdfCanvas canvas = new PdfCanvas(page.newContentStreamAfter(), page.getResources(), pdfDoc);
                canvas.beginText()
                      .setFontAndSize(koreanFont, 10)
                      .moveText(540, 10)
                      .showText("Page " + pageNumber)
                      .endText()
                      .release();
            });

            // 5. 변환 진행 (PdfDocument 직접 사용)
            HtmlConverter.convertToPdf(htmlContent, pdfDoc, props);
            pdfDoc.close();

            // 6. 응답 전송
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=preview.pdf");
            response.setContentLength(pdfStream.size());

            OutputStream out = response.getOutputStream();
            pdfStream.writeTo(out);
            out.flush();
            
          //history 저장
		  Map<String, Object> historyParam = new HashMap<String, Object>();
		  historyParam.put("docIdx", param.get("docIdx"));
		  historyParam.put("docType", param.get("docType"));
		  historyParam.put("historyType", "P");
		  historyParam.put("historyData", "PDF 다운로드: " + param.get("docType") + " - " + param.get("docIdx") + ", 파일명: " + param.get("title"));
		  historyParam.put("userId", param.get("userId"));
		  commonService.insertHistory(historyParam);
		  
        } catch (Exception e) {
            e.printStackTrace();
            try {
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write("PDF 생성 중 오류 발생: " + e.getMessage());
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

}