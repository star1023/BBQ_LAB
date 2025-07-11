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

import kr.co.genesiskorea.service.BusinessTripPlanService;
import kr.co.genesiskorea.service.BusinessTripService;
import kr.co.genesiskorea.service.CommonService;
import kr.co.genesiskorea.service.DesignReportService;
import kr.co.genesiskorea.service.MarketResearchService;
import kr.co.genesiskorea.service.MenuService;
import kr.co.genesiskorea.service.ProductService;

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
    
    @RequestMapping("/downloadPdf")
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
                      .moveText(540, 20)
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