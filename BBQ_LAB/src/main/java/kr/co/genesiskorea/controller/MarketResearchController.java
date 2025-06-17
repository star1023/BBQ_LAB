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
import kr.co.genesiskorea.service.MarketResearchService;
import kr.co.genesiskorea.util.StringUtil;


@Controller
@RequestMapping("/marketResearch")
public class MarketResearchController {
private Logger logger = LogManager.getLogger(MarketResearchController.class);
	
	@Autowired
	private Properties config;
	
	@Autowired
	MarketResearchService reportService;
	
	@RequestMapping(value = "/list")
	public String list( HttpSession session, HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) {
		return "/marketResearch/list";
	}
	
	@RequestMapping("/selectMarketResearchListAjax")
	@ResponseBody
	public Map<String, Object> selectMarketResearchListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = reportService.selectMarketResearchList(param);
		return returnMap;
	}
	
	@RequestMapping(value = "/insert")
	public String insert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) {
		return "/marketResearch/insert";
	}
	
	@RequestMapping("/insertMarketResearchTmpAjax")
	@ResponseBody
	public Map<String, Object> insertMarketResearchTmpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			int researchIdx = reportService.insertMarketResearchTmp(param, file);
			returnMap.put("IDX", researchIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/insertMarketResearchAjax")
	@ResponseBody
	public Map<String, Object> insertMarketResearchAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			int researchIdx = reportService.insertMarketResearch(param, file);
			returnMap.put("IDX", researchIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping(value = "/view")
	public String view( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model ) {
		//1.lab_market_research 조회
		Map<String, Object> researchData = reportService.selectMarketResearchData(param);
		//2.lab_market_research_user 조회
		List<Map<String, Object>> userList = reportService.selectMarketResearchUserList(param);
		//3.lab_market_research_add_info 조회
		List<Map<String, Object>> infoList = reportService.selectMarketResearchAddInfoList(param);
		
		model.addAttribute("researchData", researchData);
		model.addAttribute("userList", userList);
		model.addAttribute("infoList", infoList);
		return "/marketResearch/view";
	}
	
	@RequestMapping(value = "/update")
	public String update( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model ) throws Exception{
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			if( reportService.selectMyDataCheck(param) > 0 ) {
				//1.lab_market_research 조회
				Map<String, Object> researchData = reportService.selectMarketResearchData(param);
				//2.lab_market_research_user 조회
				List<Map<String, Object>> userList = reportService.selectMarketResearchUserList(param);
				//3.lab_market_research_add_info 조회
				List<Map<String, Object>> infoList = reportService.selectMarketResearchAddInfoList(param);
				
				model.addAttribute("researchData", researchData);
				model.addAttribute("userList", userList);
				model.addAttribute("infoList", infoList);
				return "/marketResearch/update";
			} else {
				model.addAttribute("returnPage", "/marketResearch/list");
				return "/error/noAuth";
			}
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
		
		
	}
	
	@RequestMapping("/updateMarketResearchTmpAjax")
	@ResponseBody
	public Map<String, Object> updateMarketResearchTmpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			reportService.updateMarketResearchTmp(param, file);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/updateMarketResearchAjax")
	@ResponseBody
	public Map<String, Object> updateMarketResearchAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			System.err.println(param);
			System.err.println(file);

			reportService.updateMarketResearch(param, file);
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
