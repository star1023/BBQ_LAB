package kr.co.genesiskorea.controller;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.ApprovalService;
import kr.co.genesiskorea.service.SenseQualityService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/senseQuality")
public class SenseQualityController {
	private Logger logger = LogManager.getLogger(SenseQualityController.class);
	
	@Autowired
	SenseQualityService reportService;
	
	@Autowired
	ApprovalService approvalService;
	
	@RequestMapping(value = "/list")
	public String senseQualityList( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/senseQuality/list";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectSenseQualityListAjax")
	@ResponseBody
	public Map<String, Object> selectSenseQualityListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = reportService.selectSenseQualityList(param);
		return returnMap;
	}
	
	@RequestMapping(value = "/insert")
	public String senseQualityInsert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/senseQuality/insert";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/insertSenseQualityTmpAjax")
	@ResponseBody
	public Map<String, Object> insertSenseQualityTmpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			JSONParser parser = new JSONParser();
			JSONArray contentsDivArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("contentsDivArr")));
			JSONArray contentsResultArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("contentsResultArr")));
			JSONArray contentsNoteArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("contentsNoteArr")));
			JSONArray resultArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("resultArr")));
			JSONArray imageIndexArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("imageIndexMap")));
			
			
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			HashMap<String, Object> listMap = new HashMap<String, Object>();			
			
			listMap.put("contentsDivArr", contentsDivArr);
			listMap.put("contentsResultArr", contentsResultArr);
			listMap.put("contentsNoteArr", contentsNoteArr);
			listMap.put("resultArr", resultArr);
			listMap.put("imageIndexArr", imageIndexArr);
			int reportIdx = reportService.insertSenseQualityTmp(param, listMap, file);
			returnMap.put("IDX", reportIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/insertSenseQualityAjax")
	@ResponseBody
	public Map<String, Object> insertSenseQualityAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			//, @RequestParam(value = "contentsDivArr", required = false) List<String> contentsDivArr
			//, @RequestParam(value = "contentsResultArr", required = false) List<String> contentsResultArr
			//, @RequestParam(value = "contentsNoteArr", required = false) List<String> contentsNoteArr
			//, @RequestParam(value = "resultArr", required = false) List<String> resultArr
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			JSONParser parser = new JSONParser();
			JSONArray contentsDivArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("contentsDivArr")));
			JSONArray contentsResultArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("contentsResultArr")));
			JSONArray contentsNoteArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("contentsNoteArr")));
			JSONArray resultArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("resultArr")));
			JSONArray imageIndexArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("imageIndexMap")));
			
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			HashMap<String, Object> listMap = new HashMap<String, Object>();			
			
			listMap.put("contentsDivArr", contentsDivArr);
			listMap.put("contentsResultArr", contentsResultArr);
			listMap.put("contentsNoteArr", contentsNoteArr);
			listMap.put("resultArr", resultArr);
			listMap.put("imageIndexArr", imageIndexArr);
			//int reportIdx = 0;
			int reportIdx = reportService.insertSenseQuality(param, listMap, file);
			returnMap.put("IDX", reportIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/view")
	public String view(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//유저정보 DOC_OWNER 확인용
		Auth auth = AuthUtil.getAuth(request);
		String userId = auth.getUserId();
		model.addAttribute("userId", userId);
		
		Map<String, Object> senseQualityData = reportService.selectSenseQualityData(param);
		model.addAttribute("senseQualityData", senseQualityData);
		
		param.put("docIdx", param.get("idx"));
		param.put("docType", "SENSE_QUALITY");
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
		
		return "/senseQuality/view";
	}
	
	@RequestMapping("/update")
	public String update(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		
		//해당 문서가 내 문서인지 확인한다.
		if( reportService.selectMyDataCheck(param) > 0 ) {
			Map<String, Object> senseQualityData = reportService.selectSenseQualityData(param);
			model.addAttribute("senseQualityData", senseQualityData);
			
			param.put("docIdx", param.get("idx"));
			param.put("docType", "SENSE_QUALITY");
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
			return "/senseQuality/update";
		} else {
			model.addAttribute("returnPage", "/senseQuality/list");
			return "/error/noAuth";
		}
	}
	
	@RequestMapping("/updateSenseQualityTmpAjax")
	@ResponseBody
	public Map<String, Object> updateSenseQualityTmpAjax(HttpServletRequest request, HttpServletResponse response,
	        @RequestParam(required = false) Map<String, Object> param,
	        @RequestParam(value = "displayOrderArr", required = false) List<String> displayOrderArr,
	        @RequestParam(value = "orderArr", required = false) List<String> orderArr,
	        @RequestParam(value = "dataStatusArr", required = false) List<String> dataStatusArr,
	        @RequestParam(value = "contentsIdxArr", required = false) List<String> contentsIdxArr,
	        @RequestParam(required = false) MultipartFile... file) throws Exception {

	    Map<String, Object> returnMap = new HashMap<>();

	    try {
//	        System.err.println("===== [컨트롤러 진입] updateSenseQualityTmpAjax =====");

	        // 1. JSON 파싱
	        JSONParser parser = new JSONParser();
	        JSONArray contentsDivArr       = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String) param.get("contentsDivArr")));
	        JSONArray contentsResultArr    = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String) param.get("contentsResultArr")));
	        JSONArray contentsNoteArr      = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String) param.get("contentsNoteArr")));
	        JSONArray resultArr            = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String) param.get("resultArr")));
	        JSONArray imageIndexArr        = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String) param.get("imageIndexMap")));
	        JSONArray deleteImageIdxArr    = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String) param.get("deleteImageIdxList")));
	        JSONArray deleteContentIdxArr  = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String) param.get("deleteContentIdxList")));

//	        System.err.println("📌 contentsDivArr: " + contentsDivArr);
//	        System.err.println("📌 contentsResultArr: " + contentsResultArr);
//	        System.err.println("📌 contentsNoteArr: " + contentsNoteArr);
//	        System.err.println("📌 imageIndexMap: " + imageIndexArr);
//	        System.err.println("📌 deleteImageIdxList: " + deleteImageIdxArr);
//	        System.err.println("📌 deleteContentIdxList: " + deleteContentIdxArr);
//	        System.err.println("📌 contentsIdxArr: " + contentsIdxArr);

	        // 2. 사용자 정보 추가
	        Auth auth = AuthUtil.getAuth(request);
	        param.put("userId", auth.getUserId());

	        // 3. 데이터 초기화
	        HashMap<String, Object> dataListMap = new HashMap<>();
	        HashMap<String, Object> fileMap = new HashMap<>();

	        // 4. deleteContentIdxList 를 고려한 기본 정보 맵핑
	        int displayOrderCounter = 1;
	        for (int i = 0; i < contentsDivArr.size(); i++) {
	            // 삭제될 대상이면 스킵
	            String contentsIdx = i < contentsIdxArr.size() ? contentsIdxArr.get(i).trim() : "";
	            if (deleteContentIdxArr.contains(contentsIdx)) {
//	                System.err.println("❌ 삭제 대상 제외: contentsIdx=" + contentsIdx + " (index=" + i + ")");
	                continue;
	            }

	            String displayOrder = String.valueOf(displayOrderCounter++);
	            HashMap<String, Object> dataMap = new HashMap<>();

	            dataMap.put("displayOrder", displayOrder);
	            dataMap.put("contentsDiv", contentsDivArr.get(i));
	            dataMap.put("contentsResult", contentsResultArr.get(i));
	            dataMap.put("contentsIdx", contentsIdx);
	            dataMap.put("dataStatus", contentsIdx.isEmpty() ? "I" : "U");

	            dataListMap.put(displayOrder, dataMap);
	        }

//	        System.err.println("✅ Step 1 - dataListMap (삭제 제외 후 구성): " + dataListMap);

	        // 5. 이미지가 있는 행 처리
	        for (int i = 0; i < imageIndexArr.size(); i++) {
	            int rowIndex = Integer.parseInt(imageIndexArr.get(i).toString());

	            if (rowIndex < 0 || rowIndex >= contentsDivArr.size()) {
//	                System.err.println("❌ imageIndexArr[" + i + "]의 rowIndex=" + rowIndex + "가 contentsDivArr 범위를 초과함");
	                continue;
	            }

	            String displayOrder = String.valueOf(rowIndex + 1);
	            HashMap<String, Object> dataMap = (HashMap<String, Object>) dataListMap.get(displayOrder);

	            if (dataMap != null) {
	                // 기존 row (업데이트 대상)
	                dataMap.put("hasImage", "Y");
	                // 파일도 넣기
	                if (i < file.length) {
	                    fileMap.put(displayOrder, file[i]);
	                }
	            } else {
	                // 신규 row만 생성 (이 경우 contentsIdx 없음)
	                HashMap<String, Object> newMap = new HashMap<>();
	                newMap.put("displayOrder", displayOrder);
	                newMap.put("contentsDiv", contentsDivArr.get(rowIndex));
	                newMap.put("contentsResult", contentsResultArr.get(rowIndex));
	                newMap.put("contentsIdx", "");
	                newMap.put("dataStatus", "I");
	                newMap.put("hasImage", "Y");

	                dataListMap.put(displayOrder, newMap);
	                if (i < file.length) {
	                    fileMap.put(displayOrder, file[i]);
	                }
	            }
	        }

//	        System.err.println("✅ Step 2 - fileMap (신규 이미지): " + fileMap);

	        

//	        System.err.println("✅ Step 3 - hasImage 표시 반영: " + dataListMap);

	        HashMap<String, Object> listMap = new HashMap<>();
	        // 7. 삭제 관련 파라미터 추가
	        listMap.put("deleteImageIdxArr", deleteImageIdxArr);
	        listMap.put("deleteContentIdxArr", deleteContentIdxArr);

	        // 8. 결과 리스트 구성
	        listMap.put("contentsNoteArr", contentsNoteArr);
	        listMap.put("resultArr", resultArr);

	        // 9. 서비스 호출
	        reportService.updateSenseQualityTmp(param, dataListMap, fileMap, listMap, file);

//	        System.err.println("🎉 [서비스 호출 완료] updateSenseQualityTmp 호출");

	        returnMap.put("RESULT", "S");

	    } catch (Exception e) {
	        logger.error(StringUtil.getStackTrace(e, this.getClass()));
	        returnMap.put("RESULT", "E");
	        returnMap.put("MESSAGE", e.getMessage());
	    }

	    return returnMap;
	}
	
	@RequestMapping("/updateSenseQualityAjax")
	@ResponseBody
	public Map<String, Object> updateSenseQualityAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "displayOrderArr", required = false) List<String> displayOrderArr
			, @RequestParam(value = "orderArr", required = false) List<String> orderArr
			, @RequestParam(value = "dataStatusArr", required = false) List<String> dataStatusArr
			, @RequestParam(value = "contentsIdxArr", required = false) List<String> contentsIdxArr
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			JSONParser parser = new JSONParser();
			JSONArray contentsDivArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("contentsDivArr")));
			JSONArray contentsResultArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("contentsResultArr")));
			JSONArray contentsNoteArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("contentsNoteArr")));
			JSONArray resultArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("resultArr")));
			JSONArray imageIndexArr        = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String) param.get("imageIndexMap")));
	        JSONArray deleteImageIdxArr    = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String) param.get("deleteImageIdxList")));
	        JSONArray deleteContentIdxArr  = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String) param.get("deleteContentIdxList")));
			
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			// 3. 데이터 초기화
	        HashMap<String, Object> dataListMap = new HashMap<>();
	        HashMap<String, Object> fileMap = new HashMap<>();

	        // 4. deleteContentIdxList 를 고려한 기본 정보 맵핑
	        int displayOrderCounter = 1;
	        for (int i = 0; i < contentsDivArr.size(); i++) {
	            // 삭제될 대상이면 스킵
	            String contentsIdx = i < contentsIdxArr.size() ? contentsIdxArr.get(i).trim() : "";
	            if (deleteContentIdxArr.contains(contentsIdx)) {
//	                System.err.println("❌ 삭제 대상 제외: contentsIdx=" + contentsIdx + " (index=" + i + ")");
	                continue;
	            }

	            String displayOrder = String.valueOf(displayOrderCounter++);
	            HashMap<String, Object> dataMap = new HashMap<>();

	            dataMap.put("displayOrder", displayOrder);
	            dataMap.put("contentsDiv", contentsDivArr.get(i));
	            dataMap.put("contentsResult", contentsResultArr.get(i));
	            dataMap.put("contentsIdx", contentsIdx);
	            dataMap.put("dataStatus", contentsIdx.isEmpty() ? "I" : "U");

	            dataListMap.put(displayOrder, dataMap);
	        }

//	        System.err.println("✅ Step 1 - dataListMap (삭제 제외 후 구성): " + dataListMap);

	        // 5. 이미지가 있는 행 처리
	        for (int i = 0; i < imageIndexArr.size(); i++) {
	            int rowIndex = Integer.parseInt(imageIndexArr.get(i).toString());

	            if (rowIndex < 0 || rowIndex >= contentsDivArr.size()) {
//	                System.err.println("❌ imageIndexArr[" + i + "]의 rowIndex=" + rowIndex + "가 contentsDivArr 범위를 초과함");
	                continue;
	            }

	            String displayOrder = String.valueOf(rowIndex + 1);
	            HashMap<String, Object> dataMap = (HashMap<String, Object>) dataListMap.get(displayOrder);

	            if (dataMap != null) {
	                // 기존 row (업데이트 대상)
	                dataMap.put("hasImage", "Y");
	                // 파일도 넣기
	                if (i < file.length) {
	                    fileMap.put(displayOrder, file[i]);
	                }
	            } else {
	                // 신규 row만 생성 (이 경우 contentsIdx 없음)
	                HashMap<String, Object> newMap = new HashMap<>();
	                newMap.put("displayOrder", displayOrder);
	                newMap.put("contentsDiv", contentsDivArr.get(rowIndex));
	                newMap.put("contentsResult", contentsResultArr.get(rowIndex));
	                newMap.put("contentsIdx", "");
	                newMap.put("dataStatus", "I");
	                newMap.put("hasImage", "Y");

	                dataListMap.put(displayOrder, newMap);
	                if (i < file.length) {
	                    fileMap.put(displayOrder, file[i]);
	                }
	            }
	        }
			
	        HashMap<String, Object> listMap = new HashMap<>();
	        // 7. 삭제 관련 파라미터 추가
	        listMap.put("deleteImageIdxArr", deleteImageIdxArr);
	        listMap.put("deleteContentIdxArr", deleteContentIdxArr);		
			listMap.put("contentsNoteArr", contentsNoteArr);
			listMap.put("resultArr", resultArr);
			
			reportService.updateSenseQuality(param, dataListMap, fileMap, listMap, file);			
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/deleteSenseQualityContenstsDataAjax")
	@ResponseBody
	public Map<String, Object> deleteSenseQualityContenstsDataAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			reportService.deleteSenseQualityContenstsData(param);
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/selectHistoryAjax")
	@ResponseBody
	public List<Map<String, Object>> selectHistoryAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return reportService.selectHistory(param);
	}
	
	@RequestMapping(value = "/deleteSenseQualityAjax", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> deleteSenseQualityAjax(HttpServletResponse respose, HttpServletRequest request, @RequestParam Map<String, Object> param) throws Exception{
		Map<String, Object> map = new HashMap<String, Object>();
		try {
			reportService.deleteSenseQuality(param);
			map.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			map.put("RESULT", "E");
			map.put("MESSAGE", e.getMessage());
		}
		return map;
	}
}
