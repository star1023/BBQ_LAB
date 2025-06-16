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
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.CommonService;
import kr.co.genesiskorea.service.PackageInfoService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/package")
public class PackageInfoController {
private Logger logger = LogManager.getLogger(PackageInfoController.class);
	
	@Autowired
	PackageInfoService packageInfoService;
	
	@Autowired
	CommonService commonService;
	
	@RequestMapping(value = "/list")
	public String list( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/package/list";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectPackageInfoListAjax")
	@ResponseBody
	public Map<String, Object> selectPackageInfoListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = packageInfoService.selectPackageInfoList(param);
		return returnMap;
	}
	
	@RequestMapping(value = "/insert")
	public String insert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/package/insert";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/insertPackageInfoTmpAjax")
	@ResponseBody
	public Map<String, Object> insertPackageInfoTmpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			int infoIdx = packageInfoService.insertPackageInfoTmp(param, file);
			returnMap.put("IDX", infoIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/insertPackageInfoAjax")
	@ResponseBody
	public Map<String, Object> insertPackageInfoAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			int infoIdx = packageInfoService.insertPackageInfo(param, file);
			returnMap.put("IDX", infoIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping(value = "/view")
	public String view( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		Map<String, Object> packageInfoData = packageInfoService.selectPackageInfoData(param);
		List<Map<String, Object>> addInfoList = packageInfoService.selectAddInfoList(param);
		
		model.addAttribute("packageInfoData", packageInfoData);		
		model.addAttribute("addInfoList", addInfoList);
		return "/package/view";
	}
	
	@RequestMapping(value = "/update")
	public String update( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		
		if( packageInfoService.selectMyDataCheck(param) > 0 ) {
			HashMap<String,String> paramMap = new HashMap<String,String>();
			paramMap.put("code", "KEEP_CONDITION");
			List<HashMap<String, String>> keepConditonList = commonService.getCodeList(paramMap);
			
			paramMap.put("code", "FOOD_TYPE");
			List<HashMap<String, String>> foodTypeList = commonService.getCodeList(paramMap);
			
			paramMap.put("code", "DISCHARGE_DISPLAY");
			List<HashMap<String, String>> dischargeDisplayList = commonService.getCodeList(paramMap);
			
			Map<String,Object> map = new HashMap<String,Object>();
			map.put("keepConditonList", keepConditonList);
			map.put("foodTypeList", foodTypeList);
			map.put("dischargeDisplayList", dischargeDisplayList);
			
			Map<String, Object> packageInfoData = packageInfoService.selectPackageInfoData(param);
			List<Map<String, Object>> addInfoList = packageInfoService.selectAddInfoList(param);
			
			model.addAttribute("codeMap", map);	
			model.addAttribute("packageInfoData", packageInfoData);		
			model.addAttribute("addInfoList", addInfoList);
			return "/package/update";
		} else {
			model.addAttribute("returnPage", "/package/list");
			return "/error/noAuth";
		}
		
		
	}
	
	@RequestMapping("/updatePackageInfoTmpAjax")
	@ResponseBody
	public Map<String, Object> updatePackageInfoTmpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			packageInfoService.updatePackageInfoTmp(param, file);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/updatePackageInfoAjax")
	@ResponseBody
	public Map<String, Object> updatePackageInfoAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			packageInfoService.updatePackageInfo(param, file);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping(value = "/versionUp")
	public String versionUp( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		
		if( packageInfoService.selectMyDataCheck(param) > 0 ) {
			HashMap<String,String> paramMap = new HashMap<String,String>();
			paramMap.put("code", "KEEP_CONDITION");
			List<HashMap<String, String>> keepConditonList = commonService.getCodeList(paramMap);
			
			paramMap.put("code", "FOOD_TYPE");
			List<HashMap<String, String>> foodTypeList = commonService.getCodeList(paramMap);
			
			paramMap.put("code", "DISCHARGE_DISPLAY");
			List<HashMap<String, String>> dischargeDisplayList = commonService.getCodeList(paramMap);
			
			Map<String,Object> map = new HashMap<String,Object>();
			map.put("keepConditonList", keepConditonList);
			map.put("foodTypeList", foodTypeList);
			map.put("dischargeDisplayList", dischargeDisplayList);
			
			Map<String, Object> packageInfoData = packageInfoService.selectPackageInfoData(param);
			List<Map<String, Object>> addInfoList = packageInfoService.selectAddInfoList(param);
			
			model.addAttribute("codeMap", map);	
			model.addAttribute("packageInfoData", packageInfoData);		
			model.addAttribute("addInfoList", addInfoList);
			return "/package/versionUp";
		} else {
			model.addAttribute("returnPage", "/package/list");
			return "/error/noAuth";
		}
	}
	
	@RequestMapping("/insertVersionUpTmpAjax")
	@ResponseBody
	public Map<String, Object> insertVersionUpTmpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			int infoIdx = packageInfoService.insertVersionUpTmp(param, file);
			returnMap.put("IDX", infoIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/insertVersionUpAjax")
	@ResponseBody
	public Map<String, Object> insertVersionUpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			int infoIdx = packageInfoService.insertVersionUp(param, file);
			returnMap.put("IDX", infoIdx);
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
	public List<Map<String, Object>> selectHistoryAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return packageInfoService.selectHistory(param);
	}
}
