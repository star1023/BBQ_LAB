package kr.co.genesiskorea.controller;

import java.text.SimpleDateFormat;
import java.util.Calendar;
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
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.service.CommonService;
import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.MaterialService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/material")
public class MaterialController {
	private Logger logger = LogManager.getLogger(MaterialController.class);
	
	@Autowired
	MaterialService materialService;
	
	@Autowired
	CommonService commonService;
	
	@RequestMapping("/list")
	public String materialList(HttpServletRequest request, HttpServletResponse response, Model model , @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return "/material/list";
	}
	
	@RequestMapping("/selectMaterialListAjax")
	@ResponseBody
	public Map<String, Object> selectMaterialListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, Object> returnMap = materialService.selectMaterialList(param);
		return returnMap;
	}
	
	@RequestMapping("/insert")
	public String insert(HttpServletRequest request, HttpServletResponse response, Model model , @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return "/material/insert";
	}
	
	@RequestMapping("/selectMaterialDataCountAjax")
	@ResponseBody
	public Map<String, Object> selectMaterialDataCountAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, Object> returnMap = materialService.selectMaterialDataCount(param);
		return returnMap;
	}
	
	@RequestMapping("/insertMaterialAjax")
	@ResponseBody
	public Map<String, String> insertMaterialAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "materialType", required = false) List<String> materialType
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
			, @RequestParam(value = "docType", required = false) List<String> docType
			, @RequestParam(value = "docTypeText", required = false) List<String> docTypeText
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			
			Calendar cal = Calendar.getInstance();
			SimpleDateFormat sdf = new SimpleDateFormat("yyMMdd");
			String selectCode = materialService.selectmaterialCode();
			String matCode = "E"+sdf.format(cal.getTime())+""+selectCode;
			
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			param.put("matCode", matCode);
			System.err.println(param);
			System.err.println(fileType);
			System.err.println(fileTypeText);
			System.err.println(docType);
			System.err.println(docTypeText);
			materialService.insertMaterial(param, materialType, fileType, fileTypeText, docType, docTypeText, file);
			returnMap.put("MATERIAL_CODE", matCode);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/selectMaterialDataAjax")
	@ResponseBody
	public Map<String, Object> selectMaterialDataAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return materialService.selectMaterialData(param);
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
	
	@RequestMapping("/selectErpMaterialListAjax")
	@ResponseBody
	public Map<String, Object> selectErpMaterialListAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return materialService.selectErpMaterialList(param);
	}
	
	@RequestMapping("/selectErpMaterialDataAjax")
	@ResponseBody
	public Map<String, Object> selectErpMaterialDataAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return materialService.selectErpMaterialData(param);
	}
	
	@RequestMapping("/selectNewCodeAjax")
	@ResponseBody
	public String selectNewCodeAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = new SimpleDateFormat("yyMMdd");
		String selectCode = materialService.selectmaterialCode();
		return sdf.format(cal.getTime())+""+selectCode;
	}
	
	@RequestMapping("/versionUp")
	public String versionUpForm(HttpServletRequest request, HttpServletResponse response, Model model , @RequestParam(required=false) Map<String, Object> param) throws Exception {
		model.addAttribute("param",param);
		model.addAttribute("materialData", materialService.selectMaterialData(param));
		param.put("docType", "MAT");
		model.addAttribute("fileType", commonService.selectFileType(param));
		return "/material/versionUp";
	}
	
	@RequestMapping("/insertNewVersionAjax")
	@ResponseBody
	public Map<String, String> insertNewVersionAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "materialType", required = false) List<String> materialType
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
			, @RequestParam(value = "docType", required = false) List<String> docType
			, @RequestParam(value = "docTypeText", required = false) List<String> docTypeText
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			materialService.insertNewVersion(param, materialType, fileType, fileTypeText, docType, docTypeText, file);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/deleteMaterialAjax")
	@ResponseBody
	public Map<String, String> deleteMaterialAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());			
			materialService.deleteMaterial(param);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/erpList")
	public String erpList(HttpServletRequest request, HttpServletResponse response, Model model , @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return "/material/erpList";
	}
	
	@RequestMapping("/selectHistoryAjax")
	@ResponseBody
	public List<Map<String, Object>> selectHistoryAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		param.put("docType", "MAT");
		return materialService.selectHistory(param);
	}
}
