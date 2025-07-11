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

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.BusinessTripPlanService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/businessTripPlan")
public class BusinessTripPlanController {
private Logger logger = LogManager.getLogger(BusinessTripPlanController.class);
	
	@Autowired
	private Properties config;
	
	@Autowired
	BusinessTripPlanService reportService;
	
	@RequestMapping(value = "/list")
	public String businessTripPlanList( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) {
		return "/businessTripPlan/list";
	}
	
	@RequestMapping("/selectBusinessTripPlanListAjax")
	@ResponseBody
	public Map<String, Object> selectBusinessTripPlanListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = reportService.selectBusinessTripPlanList(param);
		return returnMap;
	}
	
	@RequestMapping(value = "/insert")
	public String insert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) {
		return "/businessTripPlan/insert";
	}
	
	@RequestMapping("/insertBusinessTripPlanTmpAjax")
	@ResponseBody
	public Map<String, Object> insertBusinessTripPlanTmpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			HashMap<String, Object> listMap = new HashMap<String, Object>();

			int planIdx = reportService.insertBusinessTripPlanTmp(param, file);
			returnMap.put("IDX", planIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/insertBusinessTripPlanAjax")
	@ResponseBody
	public Map<String, Object> insertBusinessTripPlanAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			int planIdx = reportService.insertBusinessTripPlan(param, file);
			returnMap.put("IDX", planIdx);
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
		Auth auth = AuthUtil.getAuth(request);
		model.addAttribute("userId", auth.getUserId());
		
		//1.lab_business_trip_plan 조회
		Map<String, Object> planData = reportService.selectBusinessTripPlanData(param);
		//2.lab_business_trip_plan_user 조회
		List<Map<String, Object>> userList = reportService.selectBusinessTripPlanUserList(param);
		//3.lab_business_trip_plan_add_info 조회
		List<Map<String, Object>> infoList = reportService.selectBusinessTripPlanAddInfoList(param);
		//4.lab_business_trip_plan_contents 조회
		List<Map<String, Object>> contentsList = reportService.selectBusinessTripPlanContentsList(param);
		
		model.addAttribute("planData", planData);
		model.addAttribute("userList", userList);
		model.addAttribute("infoList", infoList);
		model.addAttribute("contentsList", contentsList);
		return "/businessTripPlan/view";
	}
	
	@RequestMapping(value = "/update")
	public String update( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model ) throws Exception{
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			if( reportService.selectMyDataCheck(param) > 0 ) {
				//1.lab_business_trip_plan 조회
				Map<String, Object> planData = reportService.selectBusinessTripPlanData(param);
				//2.lab_business_trip_plan_user 조회
				List<Map<String, Object>> userList = reportService.selectBusinessTripPlanUserList(param);
				//3.lab_business_trip_plan_add_info 조회
				List<Map<String, Object>> infoList = reportService.selectBusinessTripPlanAddInfoList(param);
				//4.lab_business_trip_plan_contents 조회
				List<Map<String, Object>> contentsList = reportService.selectBusinessTripPlanContentsList(param);
				
				model.addAttribute("planData", planData);
				model.addAttribute("userList", userList);
				model.addAttribute("infoList", infoList);
				model.addAttribute("contentsList", contentsList);
				return "/businessTripPlan/update";
			} else {
				model.addAttribute("returnPage", "/businessTripPlan/list");
				return "/error/noAuth";
			}
			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
		
	}
	
	@RequestMapping("/updateBusinessTripPlanTmpAjax")
	@ResponseBody
	public Map<String, Object> updateBusinessTripPlanTmpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			reportService.updateBusinessTripPlanTmp(param, file);			
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/updateBusinessTripPlanAjax")
	@ResponseBody
	public Map<String, Object> updateBusinessTripPlanAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			reportService.updateBusinessTripPlan(param, file);			
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/searchBusinessTripPlanListAjax")
	@ResponseBody
	public List<Map<String, Object>> searchBusinessTripPlanListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		List<Map<String, Object>> returnList = reportService.searchBusinessTripPlanList(param);
		return returnList;
	}
	
	@RequestMapping("/selectBusinessTripPlanDataAjax")
	@ResponseBody
	public Map<String, Object> selectBusinessTripPlanDataAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		//1.lab_business_trip_plan 조회
		Map<String, Object> planData = reportService.selectBusinessTripPlanData(param);
		//2.lab_business_trip_plan_user 조회
		List<Map<String, Object>> userList = reportService.selectBusinessTripPlanUserList(param);
		//3.lab_business_trip_plan_add_info 조회
		List<Map<String, Object>> infoList = reportService.selectBusinessTripPlanAddInfoList(param);
		//4.lab_business_trip_plan_contents 조회
		List<Map<String, Object>> contentsList = reportService.selectBusinessTripPlanContentsList(param);
		
		returnMap.put("planData", planData);
		returnMap.put("userList", userList);
		returnMap.put("infoList", infoList);
		returnMap.put("contentsList", contentsList);
		
		return returnMap;
	}
	
	@RequestMapping("/selectHistoryAjax")
	@ResponseBody
	public List<Map<String, Object>> selectHistoryAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return reportService.selectHistory(param);
	}
}
