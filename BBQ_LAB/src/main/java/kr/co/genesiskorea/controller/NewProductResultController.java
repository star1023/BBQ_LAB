package kr.co.genesiskorea.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

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
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.NewProductResultService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/newProductResult")
public class NewProductResultController {
	private Logger logger = LogManager.getLogger(NewProductResultController.class);
	
	@Autowired
	private Properties config;
	
	@Autowired
	NewProductResultService newProductResult;
	
	@RequestMapping("/selectHistoryAjax")
	@ResponseBody
	public List<Map<String, Object>> selectHistoryAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return newProductResult.selectHistory(param);
	}
	
	@RequestMapping(value = "/list")
	public String newProductResultList( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/newProductResult/list";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectNewProductResultListAjax")
	@ResponseBody
	public Map<String, Object> newProductResultListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = newProductResult.selectNewProductResultList(param);
		return returnMap;
	}
	
	@RequestMapping(value = "/insert")
	public String newProductResultInsert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		return "/newProductResult/insert";
	}
	
	@RequestMapping("/searchNewProductResultListAjax")
	@ResponseBody
	public List<Map<String, Object>> searchNewProductResultListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		List<Map<String, Object>> returnList = newProductResult.searchNewProductResultListAjax(param);
		return returnList;
	}
	
	@RequestMapping("/insertNewProductResultAjax")
	@ResponseBody
	public Map<String, Object> insertNewProductResultAjax(
	    HttpServletRequest request,
	    HttpServletResponse response,
	    @RequestParam(required = false) Map<String, Object> param,
	    @RequestParam(value = "file", required = false) MultipartFile[] file,
	    @RequestParam(value = "resultItemArr", required = false) String resultItemArrStr,
	    @RequestParam(value = "itemImageArr", required = false) String itemImageArrStr,
	    @RequestParam(value = "imageFiles", required = false) List<MultipartFile> imageFiles
	) {
	    Map<String, Object> result = new HashMap<String, Object>();

	    try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

	        ObjectMapper objectMapper = new ObjectMapper();

	        List<List<Map<String, Object>>> resultItemArr = objectMapper.readValue(
	            resultItemArrStr, new TypeReference<List<List<Map<String, Object>>>>() {}
	        );

	        List<Map<String, Object>> itemImageArr = objectMapper.readValue(
	            itemImageArrStr, new TypeReference<List<Map<String, Object>>>() {}
	        );

	        int resultIdx = newProductResult.insertNewProductResult(param, resultItemArr, itemImageArr, imageFiles, file);
	        
	        result.put("RESULT", "S");
	        result.put("MESSAGE", "정상 수신");
	        result.put("IDX", resultIdx);

	    } catch (Exception e) {
	        e.printStackTrace();
	        result.put("RESULT", "E");
	        result.put("MESSAGE", "파라미터 처리 오류: " + e.getMessage());
	    }

	    return result;
	}

	@RequestMapping("/view")
	public String newProductResultView(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//1. lab_new_product_result 테이블 조회, lab_chemical_test 테이블 조회
		Map<String, Object> newProductResultData = newProductResult.selectNewProductResultData(param);
		//2. lab_new_product_result_item 조회
		List<Map<String, Object>> itemList = newProductResult.selectNewProductResultItemList(param);
		//3. lab_new_product_result_item_images 조회
		List<Map<String, Object>> itemImageList = newProductResult.selectNewProductResultItemImageList(param);
		
		model.addAttribute("newProductResultData", newProductResultData);
		model.put("itemList", itemList);
		model.put("itemImageList", itemImageList);
		
		return "/newProductResult/view";
	}

	@RequestMapping("/update")
	public String newProductResultUpdate(HttpSession session, HttpServletRequest request, HttpServletResponse response,
	                                     @RequestParam Map<String, Object> param, ModelMap model) throws Exception {
	    
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		if( newProductResult.selectMyDataCheck(param) > 0 ) {
			// 1. lab_new_product_result 테이블 조회
		    Map<String, Object> newProductResultData = newProductResult.selectNewProductResultData(param);
		    // 2. lab_new_product_result_item 조회
		    List<Map<String, Object>> itemList = newProductResult.selectNewProductResultItemList(param);
		    // 3. lab_new_product_result_item_images 조회
		    List<Map<String, Object>> itemImageList = newProductResult.selectNewProductResultItemImageList(param);

		    // 5. 모델에 데이터 추가
		    model.addAttribute("newProductResultData", newProductResultData);
		    model.addAttribute("itemList", itemList);
		    model.addAttribute("itemImageList", itemImageList);

		    // 6. update 화면 JSP로 이동
		    return "/newProductResult/update";
		} else {
			model.addAttribute("returnPage", "/newProductResult/list");
			return "/error/noAuth";
		}
		
	}
	
	@RequestMapping("/updateNewProductResult")
	@ResponseBody
	public Map<String, Object> updateNewProductResult(HttpServletRequest request, HttpServletResponse response,
		@RequestParam(required = false) Map<String, Object> param,
	    @RequestParam(value = "file", required = false) MultipartFile[] file,
	    @RequestParam(value = "resultItemArr", required = false) String resultItemArrStr,
	    @RequestParam(value = "itemImageArr", required = false) String itemImageArrStr,
	    @RequestParam(value = "deletedFileList", required = false) List<String> deletedFiles,
	    @RequestParam(value = "imageFiles", required = false) List<MultipartFile> imageFiles
	) {
	    Map<String, Object> result = new HashMap<String, Object>();

	    try {
	        Auth auth = AuthUtil.getAuth(request);
	        param.put("userId", auth.getUserId());

	        ObjectMapper objectMapper = new ObjectMapper();

	        // ✅ JSON 파싱
	        List<List<Map<String, Object>>> resultItemArr = objectMapper.readValue(
	            resultItemArrStr, new TypeReference<List<List<Map<String, Object>>>>() {}
	        );

	        List<Map<String, Object>> itemImageArr = objectMapper.readValue(
	            itemImageArrStr, new TypeReference<List<Map<String, Object>>>() {}
	        );

	        // ✅ 서비스 호출
	        int resultIdx = newProductResult.updateNewProductResult(param, resultItemArr, itemImageArr, file, imageFiles, deletedFiles);

	        result.put("RESULT", "S");
	        result.put("MESSAGE", "정상 처리");
	        result.put("IDX", resultIdx);

	    } catch (Exception e) {
	        e.printStackTrace();
	        result.put("RESULT", "E");
	        result.put("MESSAGE", "업데이트 처리 오류: " + e.getMessage());
	    }

	    return result;
	}
	
	@RequestMapping("/selectNewProductResultDataAjax")
	@ResponseBody
	public Map<String, Object> selectNewProductResultDataAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {		
		Map<String, Object> returnMap = new HashMap<String, Object>();
		//1. lab_new_product_result 테이블 조회, lab_chemical_test 테이블 조회
		Map<String, Object> newProductResultData = newProductResult.selectNewProductResultData(param);
		//2. lab_new_product_result_item 조회
		List<Map<String, Object>> itemList = newProductResult.selectNewProductResultItemList(param);
		//3. lab_new_product_result_item_images 조회
		List<Map<String, Object>> itemImageList = newProductResult.selectNewProductResultItemImageList(param);

		returnMap.put("newProductResultData", newProductResultData);
		returnMap.put("itemList", itemList);
		returnMap.put("itemImageList", itemImageList);
		
		return returnMap;
	}
}
