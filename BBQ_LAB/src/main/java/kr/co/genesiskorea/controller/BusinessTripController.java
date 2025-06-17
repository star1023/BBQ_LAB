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
	
	@RequestMapping(value = "/list")
	public String list( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) {
		return "/businessTrip/list";
	}
	
	@RequestMapping("/selectBusinessTripListAjax")
	@ResponseBody
	public Map<String, Object> selectBusinessTripListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = reportService.selectBusinessTripList(param);
		return returnMap;
	}
	
	@RequestMapping(value = "/insert")
	public String insert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) {
		return "/businessTrip/insert";
	}
	
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
	
	@RequestMapping("/view")
	public String view(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
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
				
		return "/businessTrip/view";
	}
	
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
			return "/businessTrip/update";	
		} else {
			model.addAttribute("returnPage", "/businessTrip/list");
			return "/error/noAuth";
		}
		
			
	}
	
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
	
	@RequestMapping("/selectHistoryAjax")
	@ResponseBody
	public List<Map<String, Object>> selectHistoryAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return reportService.selectHistory(param);
	}
}
