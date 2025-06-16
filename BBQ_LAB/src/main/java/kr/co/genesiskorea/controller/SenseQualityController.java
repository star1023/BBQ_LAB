package kr.co.genesiskorea.controller;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

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
import kr.co.genesiskorea.service.SenseQualityService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/senseQuality")
public class SenseQualityController {
	private Logger logger = LogManager.getLogger(SenseQualityController.class);
	
	@Autowired
	SenseQualityService reportService;
	
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
			JSONArray contentsDivArr = (JSONArray) parser.parse((String)param.get("contentsDivArr"));
			JSONArray contentsResultArr = (JSONArray) parser.parse((String)param.get("contentsResultArr"));
			JSONArray contentsNoteArr = (JSONArray) parser.parse((String)param.get("contentsNoteArr"));
			JSONArray resultArr = (JSONArray) parser.parse((String)param.get("resultArr"));
			
			
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			System.err.println(param);
			System.err.println(contentsDivArr);
			System.err.println(contentsResultArr);
			System.err.println(contentsNoteArr);
			System.err.println(resultArr);
			System.err.println(file);
			
			HashMap<String, Object> listMap = new HashMap<String, Object>();			
			
			listMap.put("contentsDivArr", contentsDivArr);
			listMap.put("contentsResultArr", contentsResultArr);
			listMap.put("contentsNoteArr", contentsNoteArr);
			listMap.put("resultArr", resultArr);
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
			JSONArray contentsDivArr = (JSONArray) parser.parse((String)param.get("contentsDivArr"));
			JSONArray contentsResultArr = (JSONArray) parser.parse((String)param.get("contentsResultArr"));
			JSONArray contentsNoteArr = (JSONArray) parser.parse((String)param.get("contentsNoteArr"));
			JSONArray resultArr = (JSONArray) parser.parse((String)param.get("resultArr"));
			
			
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			System.err.println(param);
			System.err.println(contentsDivArr);
			System.err.println(contentsResultArr);
			System.err.println(contentsNoteArr);
			System.err.println(resultArr);
			System.err.println(file);
			
			HashMap<String, Object> listMap = new HashMap<String, Object>();			
			
			listMap.put("contentsDivArr", contentsDivArr);
			listMap.put("contentsResultArr", contentsResultArr);
			listMap.put("contentsNoteArr", contentsNoteArr);
			listMap.put("resultArr", resultArr);
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
		Map<String, Object> senseQualityData = reportService.selectSenseQualityData(param);
		model.addAttribute("senseQualityData", senseQualityData);
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
			return "/senseQuality/update";
		} else {
			model.addAttribute("returnPage", "/senseQuality/list");
			return "/error/noAuth";
		}
	}
	
	@RequestMapping("/updateSenseQualityTmpAjax")
	@ResponseBody
	public Map<String, Object> updateSenseQualityTmpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "displayOrderArr", required = false) List<String> displayOrderArr
			, @RequestParam(value = "orderArr", required = false) List<String> orderArr
			, @RequestParam(value = "dataStatusArr", required = false) List<String> dataStatusArr
			, @RequestParam(value = "contentsIdxArr", required = false) List<String> contentsIdxArr
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			JSONParser parser = new JSONParser();
			JSONArray contentsDivArr = (JSONArray) parser.parse((String)param.get("contentsDivArr"));
			JSONArray contentsResultArr = (JSONArray) parser.parse((String)param.get("contentsResultArr"));
			JSONArray contentsNoteArr = (JSONArray) parser.parse((String)param.get("contentsNoteArr"));
			JSONArray resultArr = (JSONArray) parser.parse((String)param.get("resultArr"));
			
			
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			HashMap<String, Object> dataListMap = new HashMap<String, Object>();
			
			for( int i = 0 ; i < displayOrderArr.size() ; i++ ) {
				HashMap<String, Object> dataMap = (HashMap<String, Object>)dataListMap.get(displayOrderArr.get(i));
				if( dataMap == null ) {
					dataMap = new HashMap<String, Object>();
					dataMap.put("displayOrder", displayOrderArr.get(i));
					dataMap.put("contentsDiv", contentsDivArr.get(i));
					dataMap.put("contentsResult", contentsResultArr.get(i));
					dataMap.put("contentsIdx", contentsIdxArr.get(i));
					dataMap.put("dataStatus", dataStatusArr.get(i));
					
				} else {
					dataMap.put("displayOrder", displayOrderArr.get(i));
					dataMap.put("contentsDiv", contentsDivArr.get(i));
					dataMap.put("contentsResult", contentsResultArr.get(i));
					dataMap.put("contentsIdx", contentsIdxArr.get(i));
					dataMap.put("dataStatus", dataStatusArr.get(i));
				}
				dataListMap.put(displayOrderArr.get(i), dataMap);
			}
			
			HashMap<String, Object> fileMap = new HashMap<String, Object>();
			for( int i = 0 ; i < orderArr.size() ; i++ ) {
				HashMap<String, Object> dataMap = (HashMap<String, Object>)dataListMap.get(orderArr.get(i));
				if( dataMap == null ) {
					dataMap = new HashMap<String, Object>();
					dataMap.put("displayOrder", orderArr.get(i));
					dataMap.put("contentsDiv", contentsDivArr.get(Integer.parseInt(orderArr.get(i))-1));
					dataMap.put("contentsResult", contentsResultArr.get(Integer.parseInt(orderArr.get(i))-1));
					dataMap.put("contentsIdx", "");
					dataMap.put("dataStatus", "I");
				} else {
					dataMap.put("displayOrder", orderArr.get(i));
					dataMap.put("contentsDiv", contentsDivArr.get(Integer.parseInt(orderArr.get(i))-1));
					dataMap.put("contentsResult", contentsResultArr.get(Integer.parseInt(orderArr.get(i))-1));
					dataMap.put("contentsIdx", "");
					dataMap.put("dataStatus", "I");
				}				
				dataListMap.put(orderArr.get(i), dataMap);
				fileMap.put(orderArr.get(i), file[i]);
			}
			
			System.err.println(dataListMap);
			System.err.println(fileMap);
			
			Iterator<String> keys = dataListMap.keySet().iterator();
			
			while( keys.hasNext() ) {
				String key = keys.next();
				HashMap<String, Object> dataMap = (HashMap<String, Object>)dataListMap.get(key);
				System.err.println(dataMap);
			}
			
			HashMap<String, Object> listMap = new HashMap<String, Object>();			
			listMap.put("resultArr", resultArr);

			reportService.updateSenseQualityTmp(param, dataListMap, fileMap, listMap, file);			
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
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
			JSONArray contentsDivArr = (JSONArray) parser.parse((String)param.get("contentsDivArr"));
			JSONArray contentsResultArr = (JSONArray) parser.parse((String)param.get("contentsResultArr"));
			JSONArray contentsNoteArr = (JSONArray) parser.parse((String)param.get("contentsNoteArr"));
			JSONArray resultArr = (JSONArray) parser.parse((String)param.get("resultArr"));
			
			
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			HashMap<String, Object> dataListMap = new HashMap<String, Object>();
			
			for( int i = 0 ; i < displayOrderArr.size() ; i++ ) {
				HashMap<String, Object> dataMap = (HashMap<String, Object>)dataListMap.get(displayOrderArr.get(i));
				if( dataMap == null ) {
					dataMap = new HashMap<String, Object>();
					dataMap.put("displayOrder", displayOrderArr.get(i));
					dataMap.put("contentsDiv", contentsDivArr.get(i));
					dataMap.put("contentsResult", contentsResultArr.get(i));
					dataMap.put("contentsIdx", contentsIdxArr.get(i));
					dataMap.put("dataStatus", dataStatusArr.get(i));
					
				} else {
					dataMap.put("displayOrder", displayOrderArr.get(i));
					dataMap.put("contentsDiv", contentsDivArr.get(i));
					dataMap.put("contentsResult", contentsResultArr.get(i));
					dataMap.put("contentsIdx", contentsIdxArr.get(i));
					dataMap.put("dataStatus", dataStatusArr.get(i));
				}
				dataListMap.put(displayOrderArr.get(i), dataMap);
			}
			
			HashMap<String, Object> fileMap = new HashMap<String, Object>();
			for( int i = 0 ; i < orderArr.size() ; i++ ) {
				HashMap<String, Object> dataMap = (HashMap<String, Object>)dataListMap.get(orderArr.get(i));
				if( dataMap == null ) {
					dataMap = new HashMap<String, Object>();
					dataMap.put("displayOrder", orderArr.get(i));
					dataMap.put("contentsDiv", contentsDivArr.get(Integer.parseInt(orderArr.get(i))-1));
					dataMap.put("contentsResult", contentsResultArr.get(Integer.parseInt(orderArr.get(i))-1));
					dataMap.put("contentsIdx", "");
					dataMap.put("dataStatus", "I");
				} else {
					dataMap.put("displayOrder", orderArr.get(i));
					dataMap.put("contentsDiv", contentsDivArr.get(Integer.parseInt(orderArr.get(i))-1));
					dataMap.put("contentsResult", contentsResultArr.get(Integer.parseInt(orderArr.get(i))-1));
					dataMap.put("contentsIdx", "");
					dataMap.put("dataStatus", "I");
				}				
				dataListMap.put(orderArr.get(i), dataMap);
				fileMap.put(orderArr.get(i), file[i]);
			}
			
			System.err.println(dataListMap);
			System.err.println(fileMap);
			
			Iterator<String> keys = dataListMap.keySet().iterator();
			
			while( keys.hasNext() ) {
				String key = keys.next();
				HashMap<String, Object> dataMap = (HashMap<String, Object>)dataListMap.get(key);
				System.err.println(dataMap);
			}
			
			HashMap<String, Object> listMap = new HashMap<String, Object>();			
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
}
