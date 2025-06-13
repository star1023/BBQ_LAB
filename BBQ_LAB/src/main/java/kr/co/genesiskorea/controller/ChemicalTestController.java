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
import kr.co.genesiskorea.service.ChemicalTestService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/chemicalTest")
public class ChemicalTestController {
	private Logger logger = LogManager.getLogger(ChemicalTestController.class);
	
	@Autowired
	private Properties config;
	
	@Autowired
	ChemicalTestService reportService;
	
	@RequestMapping("/selectHistoryAjax")
	@ResponseBody
	public List<Map<String, Object>> selectHistoryAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return reportService.selectHistory(param);
	}
	
	@RequestMapping("/selectChemicalTestListAjax")
	@ResponseBody
	public Map<String, Object> selectChemicalTestListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = reportService.selectChemicalTestList(param);
		return returnMap;
	}
	
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
	
	@RequestMapping(value = "/insert")
	public String chemicalTestInsert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		return "/chemicalTest/insert";
	}
	
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
			System.err.println(param);
			System.err.println(typeCodeArr);
			System.err.println(itemContentArr);
			System.err.println(standard1Arr);
			System.err.println(standard2Arr);
			System.err.println(file);
			System.err.println(imageFile);
			
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
	
	@RequestMapping("/view")
	public String chemicalTestView(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
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
	
	@RequestMapping("/update")
	public String chemicalTestUpdate(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//1. lab_chemical_test 테이블 조회, lab_chemical_test 테이블 조회
		Map<String, Object> chemicalData = reportService.selectChemicalTestData(param);
		//2. lab_chemical_test_item 조회
		List<Map<String, Object>> itemList = reportService.selectChemicalTestItemList(param);
		//3. lab_chemical_test_standard 조회
		List<Map<String, Object>> standardList = reportService.selectChemicalTestStandardList(param);
		
		model.addAttribute("chemicalTestData", chemicalData);
		model.put("itemList", itemList);
		model.put("standardList", standardList);
		
		return "/chemicalTest/update";
	}
	
	@RequestMapping("/searchChemicalTestAjax")
	@ResponseBody
	public List<Map<String, Object>> searchChemicalTestAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		List<Map<String, Object>> returnList = reportService.searchChemicalTestList(param);
		return returnList;
	}

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
			System.err.println(param);
			System.err.println(typeCodeArr);
			System.err.println(itemContentArr);
			System.err.println(standard1Arr);
			System.err.println(standard2Arr);
			System.err.println(file);
			System.err.println(imageFile);
			
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

}

