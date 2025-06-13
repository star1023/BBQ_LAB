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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.ManualService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/manual")
public class ManualController {
	private Logger logger = LogManager.getLogger(ManualController.class);
	
	@Autowired
	ManualService manualService;
	
	@RequestMapping(value = "/list")
	public String productList( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/manual/list";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectManualListAjax")
	@ResponseBody
	public Map<String, Object> selectManualListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = manualService.selectManualList(param);
		return returnMap;
	}
	
	@RequestMapping("/uploadManualAjax")
	@ResponseBody
	public Map<String, String> uploadManualAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			param.put("files", file);
			manualService.uploadManual(param);
			
			returnMap.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/selectManualFileListAjax")
	@ResponseBody
	public List<Map<String, Object>> selectManualFileListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		List<Map<String, Object>> list = manualService.selectManualFileList(param);
		return list;
	}
}
