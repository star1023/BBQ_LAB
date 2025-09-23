package kr.co.genesiskorea.controller;
/**
* @packageName    	: kr.co.genesiskorea.controller
* @fileName        	: ChemicalTestController
* @author        	: ssung
* @date            	: 2025.04
* @description      : 이화학검사 의뢰서 Controller 클래스
* ===========================================================
* DATE              AUTHOR             NOTE
* -----------------------------------------------------------
* 2025.04        	ssung       	최초 생성
*/

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.ChemicalTestService;
import kr.co.genesiskorea.util.StringUtil;
import kr.co.genesiskorea.util.UserUtil;

@Controller
@RequestMapping("/chemicalTest")
public class ChemicalTestController {
	private Logger logger = LogManager.getLogger(ChemicalTestController.class);
	
	@Autowired
	private Properties config;
	
	@Autowired
	ChemicalTestService reportService;
	
	/**
	 * 이화학검사 의뢰서 이력조회 Ajax
	* @methodName    : selectHistoryAjax
	* @date        : 2025.09.16
	* @param request
	* @param response
	* @param param
	* @return
	* @throws Exception
	 */
	@RequestMapping("/selectHistoryAjax")
	@ResponseBody
	public List<Map<String, Object>> selectHistoryAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return reportService.selectHistory(param);
	}
	
	/**
	 * 이화학검사 의뢰서 리스트 조회 Ajax
	* @methodName    : selectChemicalTestListAjax
	* @date        : 2025.09.16
	* @param request
	* @param response
	* @param param
	* @return
	* @throws Exception
	 */
	@RequestMapping("/selectChemicalTestListAjax")
	@ResponseBody
	public Map<String, Object> selectChemicalTestListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
	    param.put("isSafeTeam", String.valueOf(param.get("isSafeTeam")));
	    param.put("isRequestList", String.valueOf(param.get("isRequestList")));
		
		Map<String, Object> returnMap = reportService.selectChemicalTestList(param);
		return returnMap;
	}
	
	/**
	 * 이화학 검사 의뢰서 리스트 화면
	* @methodName    : chemicalTestList
	* @date        : 2025.09.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @return
	* @throws Exception
	 */
	@RequestMapping(value = "/list")
	public String chemicalTestList( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/chemicalTest/list";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	/**
	 * 이화학 검사 의뢰서 등록 화면
	* @methodName    : chemicalTestInsert
	* @date        : 2025.09.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping(value = "/insert")
	public String chemicalTestInsert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model ) throws Exception{
		//유저정보 DOC_OWNER 확인용
		Auth auth = AuthUtil.getAuth(request);
		String userName = auth.getUserName();
		model.addAttribute("userName", userName);
		
		return "/chemicalTest/insert";
	}
	
	/**
	 * 이화학 검사 의뢰서 등록 Ajax
	* @methodName    : insertChemicalTestAjax
	* @date        : 2025.09.16
	* @param request
	* @param response
	* @param param
	* @param file
	* @param imageFile
	* @return
	* @throws Exception
	 */
	@RequestMapping("/insertChemicalTestAjax")
	@ResponseBody
	public Map<String, Object> insertChemicalTestAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "file", required = false) MultipartFile[] file
	        , @RequestParam(value = "imageFile", required = false) MultipartFile imageFile) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			JSONParser parser = new JSONParser();
			JSONArray typeCodeArr = (JSONArray) parser.parse((String)param.get("typeCodeArr"));
			JSONArray itemContentArr = (JSONArray) parser.parse((String)param.get("itemContentArr"));
			JSONArray standard1Arr = (JSONArray) parser.parse((String)param.get("standard1Arr"));
			JSONArray standard2Arr = (JSONArray) parser.parse((String)param.get("standard2Arr"));
			
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			HashMap<String, Object> listMap = new HashMap<String, Object>();			
			
			listMap.put("typeCodeArr", typeCodeArr);
			listMap.put("itemContentArr", itemContentArr);
			listMap.put("standard1Arr", standard1Arr);
			listMap.put("standard2Arr", standard2Arr);
			int reportIdx = reportService.insertChemicalTest(param, listMap, file, imageFile);
			returnMap.put("IDX", reportIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.toString());
		}
		return returnMap;
	}
	
	/**
	 * 이화학검사 외릐소 상세보기 화면
	* @methodName    : chemicalTestView
	* @date        : 2025.09.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/view")
	public String chemicalTestView(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//유저정보 DOC_OWNER 확인용
		Auth auth = AuthUtil.getAuth(request);
		String userId = auth.getUserId();
		model.addAttribute("userId", userId);
		
		//1. lab_chemical_test 테이블 조회, lab_chemical_test 테이블 조회
		Map<String, Object> chemicalData = reportService.selectChemicalTestData(param);
		//2. lab_chemical_test_item 조회
		List<Map<String, Object>> itemList = reportService.selectChemicalTestItemList(param);
		//3. lab_chemical_test_standard 조회
		List<Map<String, Object>> standardList = reportService.selectChemicalTestStandardList(param);
		
		model.addAttribute("chemicalTestData", chemicalData);
		model.put("itemList", itemList);
		model.put("standardList", standardList);
				
		return "/chemicalTest/view";
	}
	
	/**
	 * 이화학검사 의뢰서 수정 화면
	* @methodName    : chemicalTestUpdate
	* @date        : 2025.09.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping("/update")
	public String chemicalTestUpdate(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		try {
			Auth auth = AuthUtil.getAuth(request);
			String userId = auth.getUserId();
			param.put("userId", userId);
			String userRole = UserUtil.getRoleCode(request);
			
			if( reportService.selectMyDataCheck(param) > 0 || "6".equals(userRole) || "7".equals(userRole)) {
				//1. lab_chemical_test 테이블 조회, lab_chemical_test 테이블 조회
				Map<String, Object> chemicalData = reportService.selectChemicalTestData(param);
				//2. lab_chemical_test_item 조회
				List<Map<String, Object>> itemList = reportService.selectChemicalTestItemList(param);
				//3. lab_chemical_test_standard 조회
				List<Map<String, Object>> standardList = reportService.selectChemicalTestStandardList(param);
				
				model.addAttribute("userId", userId);
				model.addAttribute("chemicalTestData", chemicalData);
				model.put("itemList", itemList);
				model.put("standardList", standardList);
				
				return "/chemicalTest/update";
			} else {
				model.addAttribute("returnPage", "/chemicalTest/list");
				return "/error/noAuth";
			}
			
			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
		
		
	}
	
	/**
	 * 이화학검사 의뢰서 검색 Ajax
	* @methodName    : searchChemicalTestAjax
	* @date        : 2025.09.16
	* @param request
	* @param response
	* @param param
	* @return
	* @throws Exception
	 */
	@RequestMapping("/searchChemicalTestAjax")
	@ResponseBody
	public List<Map<String, Object>> searchChemicalTestAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		List<Map<String, Object>> returnList = reportService.searchChemicalTestList(param);
		return returnList;
	}

	/**
	 * 이화학검사 의뢰서 정보 조회 Ajax
	* @methodName    : selectChemicalTestDataAjax
	* @date        : 2025.09.16
	* @param request
	* @param response
	* @param param
	* @return
	* @throws Exception
	 */
	@RequestMapping("/selectChemicalTestDataAjax")
	@ResponseBody
	public Map<String, Object> selectChemicalTestDataAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		//1. lab_chemical_test 테이블 조회, lab_chemical_test 테이블 조회
		Map<String, Object> chemicalData = reportService.selectChemicalTestData(param);
		//2. lab_chemical_test_item 조회
		List<Map<String, Object>> itemList = reportService.selectChemicalTestItemList(param);
		//3. lab_chemical_test_standard 조회
		List<Map<String, Object>> standardList = reportService.selectChemicalTestStandardList(param);
		
		returnMap.put("chemicalTestData", chemicalData);
		returnMap.put("itemList", itemList);
		returnMap.put("standardList", standardList);
		
		return returnMap;
	}
	
	/**
	 * 이화학검사 의뢰서 수정 Ajax
	* @methodName    : updateChemicalTestAjax
	* @date        : 2025.09.16
	* @param request
	* @param response
	* @param param
	* @param file
	* @param deletedFileList
	* @param imageFile
	* @return
	* @throws Exception
	 */
	@RequestMapping("/updateChemicalTestAjax")
	@ResponseBody
	public Map<String, Object> updateChemicalTestAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "file", required = false) MultipartFile[] file
			, @RequestParam(value = "deletedFileList", required = false) List<String> deletedFileList
	        , @RequestParam(value = "imageFile", required = false) MultipartFile imageFile) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			JSONParser parser = new JSONParser();
			JSONArray typeCodeArr = (JSONArray) parser.parse((String)param.get("typeCodeArr"));
			JSONArray itemContentArr = (JSONArray) parser.parse((String)param.get("itemContentArr"));
			JSONArray standard1Arr = (JSONArray) parser.parse((String)param.get("standard1Arr"));
			JSONArray standard2Arr = (JSONArray) parser.parse((String)param.get("standard2Arr"));
			
			// 삭제할 파일 리스트도 파라미터에 함께 전달
			param.put("deletedFileList", deletedFileList);
			
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			HashMap<String, Object> listMap = new HashMap<String, Object>();			
			
			listMap.put("typeCodeArr", typeCodeArr);
			listMap.put("itemContentArr", itemContentArr);
			listMap.put("standard1Arr", standard1Arr);
			listMap.put("standard2Arr", standard2Arr);
			reportService.updateChemicalTest(param, listMap, file, imageFile);

			returnMap.put("RESULT", "S");			
			returnMap.put("IDX", param.get("idx")); // 또는 returnMap.put("IDX", reportIdx);
			
		} catch( Exception e ) {
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.toString());
		}
		return returnMap;

	}
	
	/**
	 * 식품안전팀 이화학검사 의뢰서 결과 등록
	* @methodName    : updateSafeTeamResult
	* @date        : 2025.09.16
	* @param request
	* @param param
	* @return
	 */
	@RequestMapping("/updateSafeResult")
	@ResponseBody
    public Map<String, Object> updateSafeTeamResult( HttpServletRequest request, @RequestBody Map<String, Object> param) {
		Map<String, Object> returnMap = new HashMap<String, Object>();
	    try {
	        Auth auth = AuthUtil.getAuth(request);
	        String userId = auth.getUserId();
	        param.put("userId", userId);  // 통합 서비스에서 사용 가능하도록 넣어줌

	        // 전체 처리 통합 호출
	        reportService.updateBySafeTeam(param);

	        returnMap.put("RESULT", "S");
	        returnMap.put("IDX", param.get("idx"));
	    } catch (Exception e) {
	        e.printStackTrace();
	        returnMap.put("RESULT", "E");
	        returnMap.put("MESSAGE", e.toString());
	    }
	    return returnMap;
    }
	
	/**
	 * 이화학검사 의뢰서 삭제 Ajax
	* @methodName    : deleteChemicalTestAjax
	* @date        : 2025.09.16
	* @param respose
	* @param request
	* @param param
	* @return
	* @throws Exception
	 */
	@RequestMapping(value = "/deleteChemicalTestAjax")
	@ResponseBody
	public Map<String, Object> deleteChemicalTestAjax(HttpServletResponse respose, HttpServletRequest request, @RequestParam Map<String, Object> param) throws Exception{
		Map<String, Object> map = new HashMap<String, Object>();
		try {
			reportService.deleteChemicalTest(param);
			map.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			map.put("RESULT", "E");
			map.put("MESSAGE", e.getMessage());
		}
		return map;
	}
}

