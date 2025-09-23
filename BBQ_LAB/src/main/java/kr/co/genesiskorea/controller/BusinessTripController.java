package kr.co.genesiskorea.controller;
/**
* @packageName    	: kr.co.genesiskorea.controller
* @fileName        	: BusinessTripController
* @author        	: ssung
* @date            	: 2025.04
* @description      : 출장결과 보고서 Controller 클래스
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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.ApprovalService;
import kr.co.genesiskorea.service.BusinessTripService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/businessTrip")
public class BusinessTripController {
	private Logger logger = LogManager.getLogger(BusinessTripController.class);
	
	@Autowired
	private Properties config;
	
	@Autowired
	BusinessTripService reportService;
	
	@Autowired
	ApprovalService approvalService;
	
	/**
	 * 출장결과 보고서 리스트 화면
	* @methodName    : list
	* @date        : 2025.09.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @return
	 */
	@RequestMapping(value = "/list")
	public String list( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) {
		return "/businessTrip/list";
	}
	
	/**
	 * 출장결과 보고서 리스트 조회 Ajax
	* @methodName    : selectBusinessTripListAjax
	* @date        : 2025.09.16
	* @param request
	* @param response
	* @param param
	* @return
	* @throws Exception
	 */
	@RequestMapping("/selectBusinessTripListAjax")
	@ResponseBody
	public Map<String, Object> selectBusinessTripListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = reportService.selectBusinessTripList(param);
		return returnMap;
	}
	
	/**
	 * 출장결과 보고서 등록 화면
	* @methodName    : insert
	* @date        : 2025.09.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @return
	 */
	@RequestMapping(value = "/insert")
	public String insert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) {
		return "/businessTrip/insert";
	}
	
	/**
	 * 출장결과 보고서 임시저장 Ajax
	* @methodName    : insertBusinessTripTmpAjax
	* @date        : 2025.09.16
	* @param request
	* @param response
	* @param param
	* @param file
	* @return
	* @throws Exception
	 */
	@RequestMapping("/insertBusinessTripTmpAjax")
	@ResponseBody
	public Map<String, Object> insertBusinessTripTmpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			int tripIdx = reportService.insertBusinessTripTmp(param, file);
			returnMap.put("IDX", tripIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	/**
	 * 출장결과 보고서 저장 Ajax
	* @methodName    : insertBusinessTripAjax
	* @date        : 2025.09.16
	* @param request
	* @param response
	* @param param
	* @param file
	* @return
	* @throws Exception
	 */
	@RequestMapping("/insertBusinessTripAjax")
	@ResponseBody
	public Map<String, Object> insertBusinessTripAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			int tripIdx = reportService.insertBusinessTrip(param, file);
			returnMap.put("IDX", tripIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	/**
	 * 출장결과 보고서 상세화면
	* @methodName    : view
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
	public String view(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		Auth auth = AuthUtil.getAuth(request);
		model.addAttribute("userId", auth.getUserId());
		//lab_design 테이블 조회, lab_file 테이블 조회
		Map<String, Object> businessTripData = reportService.selectBusinessTripData(param);
		//2.lab_business_trip_user 조회
		List<Map<String, Object>> userList = reportService.selectBusinessTripUserList(param);
		//3.lab_business_trip_add_info 조회
		List<Map<String, Object>> infoList = reportService.selectBusinessTripAddInfoList(param);
		//4.lab_business_trip_contents 조회
		List<Map<String, Object>> contentsList = reportService.selectBusinessTripContentsList(param);
		
		model.addAttribute("businessTripData", businessTripData);
		model.put("userList", userList);
		model.put("infoList", infoList);
		model.put("contentsList", contentsList);
		
		//lab_approval_header 테이블 조회
		param.put("docIdx", param.get("idx"));
		param.put("docType", "TRIP");
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
				
		return "/businessTrip/view";
	}
	
	/**
	 * 출장결과 보고서 수정 화면
	* @methodName    : update
	* @date        : 2025.09.16
	* @param session
	* @param request
	* @param response
	* @param param
	* @param model
	* @return
	* @throws Exception
	 */
	@RequestMapping(value = "/update")
	public String update( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model ) throws Exception{
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		
		if( reportService.selectMyDataCheck(param) > 0 ) {
			//lab_design 테이블 조회, lab_file 테이블 조회
			Map<String, Object> businessTripData = reportService.selectBusinessTripData(param);
			//2.lab_business_trip_user 조회
			List<Map<String, Object>> userList = reportService.selectBusinessTripUserList(param);
			//3.lab_business_trip_add_info 조회
			List<Map<String, Object>> infoList = reportService.selectBusinessTripAddInfoList(param);
			//4.lab_business_trip_contents 조회
			List<Map<String, Object>> contentsList = reportService.selectBusinessTripContentsList(param);
			
			model.addAttribute("businessTripData", businessTripData);
			model.put("userList", userList);
			model.put("infoList", infoList);
			model.put("contentsList", contentsList);
			
			//lab_approval_header 테이블 조회
			param.put("docIdx", param.get("idx"));
			param.put("docType", "TRIP");
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
			return "/businessTrip/update";	
		} else {
			model.addAttribute("returnPage", "/businessTrip/list");
			return "/error/noAuth";
		}
		
			
	}
	
	/**
	 * 출장결과 보고서 수정 임시저장
	* @methodName    : updateBusinessTripTmpAjax
	* @date        : 2025.09.16
	* @param request
	* @param response
	* @param param
	* @param file
	* @return
	* @throws Exception
	 */
	@RequestMapping("/updateBusinessTripTmpAjax")
	@ResponseBody
	public Map<String, Object> updateBusinessTripTmpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			reportService.updateBusinessTripTmp(param, file);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	/**
	 * 출장결과 보고서 수정
	* @methodName    : updateBusinessTripAjax
	* @date        : 2025.09.16
	* @param request
	* @param response
	* @param param
	* @param fileType
	* @param fileTypeText
	* @param file
	* @return
	* @throws Exception
	 */
	@RequestMapping("/updateBusinessTripAjax")
	@ResponseBody
	public Map<String, Object> updateBusinessTripAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			reportService.updateBusinessTrip(param, file);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	/**
	 * 이력조회 Ajax
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
	 * 출장결과 보고서 삭제
	* @methodName    : deleteTripAjax
	* @date        : 2025.09.16
	* @param respose
	* @param request
	* @param param
	* @return
	* @throws Exception
	 */
	@RequestMapping(value = "/deleteTripAjax")
	@ResponseBody
	public Map<String, Object> deleteTripAjax(HttpServletResponse respose, HttpServletRequest request, @RequestParam Map<String, Object> param) throws Exception{
		Map<String, Object> map = new HashMap<String, Object>();
		try {
			reportService.deleteTrip(param);
			map.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			map.put("RESULT", "E");
			map.put("MESSAGE", e.getMessage());
		}
		return map;
	}
}
