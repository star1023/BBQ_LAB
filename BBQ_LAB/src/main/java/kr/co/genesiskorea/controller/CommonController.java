package kr.co.genesiskorea.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.co.genesiskorea.service.CommonService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/common")
public class CommonController {
	private Logger logger = LogManager.getLogger(CommonController.class);
	
	@Autowired
	CommonService commonService;
	
	@RequestMapping(value = "/companyListAjax", method = RequestMethod.POST)
	@ResponseBody
	public Map<String,Object> getCompanyList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param) throws Exception {
		try {
			Map<String,Object> map = new HashMap<String,Object>();
			List<HashMap<String,Object>> companyList = commonService.getCompany();
			logger.debug("companyList  :  {}",companyList);
			map.put("RESULT", companyList);
			return map;
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping(value = "/plantListAjax", method = RequestMethod.POST)
	@ResponseBody
	public Map<String,Object> getPlantListList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param) throws Exception {
		try {
			logger.debug("param  :  {}",param);
			Map<String,Object> map = new HashMap<String,Object>();
			System.out.println("param.get(companyCode) : "+param.get("companyCode"));
			List<HashMap<String,Object>> plantList = commonService.getPlant(param);
			map.put("RESULT", plantList);
			return map;
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping(value = "/unitListAjax", method = RequestMethod.POST)
	@ResponseBody
	public List<HashMap<String,Object>> unitListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception {
		try {
			return commonService.getUnit();
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping(value = "/codeListAjax", method = RequestMethod.POST)
	@ResponseBody
	public Map<String,Object> codeList(@RequestParam Map<String, Object> param ,HttpServletRequest request, HttpServletResponse response, Model model) throws Exception {
		try {
			//CodeItemVO codeItemVO = new CodeItemVO();
			//codeItemVO.setGroupCode((String)param.get("groupCode"));		
			List<Map<String,Object>> codeList = commonService.getCodeList(param);
			logger.debug("codeList  :  {}",codeList);
			
			Map<String,Object> map = new HashMap<String,Object>();
			map.put("RESULT", codeList);
			return map;
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/categoryListAjax")
	@ResponseBody
	public List<Map<String, Object>> categoryListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return commonService.categoryList(param);
	}
	
	@RequestMapping("/selectCategoryByPIdAjax")
	@ResponseBody
	public List<Map<String, Object>> selectCategoryByPIdAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return commonService.selectCategoryByPId(param);
	}
	
	@RequestMapping("/selectHistoryAjax")
	@ResponseBody
	public List<Map<String, Object>> selectHistoryAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return commonService.selectHistory(param);
	}
	
	@RequestMapping("/fileDownload")
	public void fileDownload(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		try{
			Map<String, String> fileInfo =commonService.selectFileData(param);
			if( fileInfo != null && ( fileInfo.get("FILE_IDX") != null || !"".equals(fileInfo.get("FILE_IDX"))) ) {
				FileUtil.fileDownload3(fileInfo, response);	
			}
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
		}
	}
	
	@RequestMapping("/readNotificationAjax")
	@ResponseBody
	public List<HashMap<String, Object>> readNotificationAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return commonService.selectNotification(param);
	}

}
