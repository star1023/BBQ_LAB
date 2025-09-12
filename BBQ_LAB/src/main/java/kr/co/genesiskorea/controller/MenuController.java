package kr.co.genesiskorea.controller;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.ApprovalService;
import kr.co.genesiskorea.service.MenuService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/menu")
public class MenuController {
	private Logger logger = LogManager.getLogger(MenuController.class);
	
	@Autowired
	MenuService menuService;
	
	@Autowired
	ApprovalService approvalService;
	
	@RequestMapping(value = "/list")
	public String menuList( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/menu/list";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectMenuListAjax")
	@ResponseBody
	public Map<String, Object> selectMenuListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = menuService.selectMenuList(param);
		return returnMap;
	}
	
	@RequestMapping(value = "/insert")
	public String compInsert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/menu/insert";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/view")
	public String menuView(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//유저정보 DOC_OWNER 확인용
		Auth auth = AuthUtil.getAuth(request);
		String userId = auth.getUserId();
		model.addAttribute("userId", userId);
		
		//lab_menu 테이블 조회, lab_file 테이블 조회
		Map<String, Object> menuData = menuService.selectMenuData(param);
		model.addAttribute("menuData", menuData);
		Map<String, Object> addInfoCount = menuService.selectAddInfoCount(param);
		model.addAttribute("addInfoCount", addInfoCount);
		List<Map<String, String>> addInfoList = menuService.selectAddInfo(param);
		model.addAttribute("addInfoList", addInfoList);
		List<Map<String, String>> imporvePurposeList = menuService.selectImporvePurposeList(param);
		model.addAttribute("imporvePurposeList", imporvePurposeList);
		List<Map<String, String>> newDataList = menuService.selectNewDataList(param);
		model.addAttribute("newDataList", newDataList);
		model.addAttribute("menuMaterialData", menuService.selectMenuMaterial(param));
		List<Map<String, String>> sharedUserList = menuService.selectSharedUser(param);
		model.addAttribute("sharedUserList", sharedUserList);
		
		//lab_approval_header 테이블 조회
		param.put("docIdx", param.get("idx"));
		param.put("docType", "MENU");
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
		
		return "/menu/view";
	}
	
	@RequestMapping("/selectNewCodeAjax")
	@ResponseBody
	public String selectNewCodeAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = new SimpleDateFormat("yyMMdd");
		String selectCode = menuService.selectMenuCode();
		return sdf.format(cal.getTime())+""+selectCode;
	}
	
	@RequestMapping("/checkMaterialAjax")
	@ResponseBody
	public List<Map<String, String>> checkMaterialAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return menuService.checkMaterial(param);
	}
	
	@RequestMapping("/checkErpMaterialAjax")
	@ResponseBody
	public List<Map<String, String>> checkErpMaterialAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return menuService.checkErpMaterial(param);
	}
	
	@RequestMapping("/selectMaterialAjax")
	@ResponseBody
	public Map<String, Object> selectMaterialListAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return menuService.selectMaterialList(param);
	}
	
	@RequestMapping("/selectMenuCountAjax")
	@ResponseBody
	public Map<String, Object> selectMenuCountAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, Object> returnMap = menuService.selectMenuDataCount(param);
		return returnMap;
	}
	
	@RequestMapping("/insertTmpMenuAjax")
	@ResponseBody
	public Map<String, Object> insertTmpMenuAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "usageArr", required = false) List<String> usageArr
			, @RequestParam(value = "customUsage", required = false) String customUsage
			, @RequestParam(value = "menuType", required = false) List<String> menuType
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
			, @RequestParam(value = "tempFile", required = false) List<String> tempFile
			, @RequestParam(value = "manualFile", required = false) MultipartFile[] manualFile
	        , @RequestParam(value = "manualFileType", required = false) List<String> manualFileType
	        , @RequestParam(value = "manualFileTypeText", required = false) List<String> manualFileTypeText
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			Collections.reverse(menuType);
			
			HashMap<String, Object> listMap = new HashMap<String, Object>();
			listMap.put("usageArr", usageArr);
			listMap.put("customUsage", customUsage);
			listMap.put("menuType", menuType);
			listMap.put("fileType", fileType);
			listMap.put("fileTypeText", fileTypeText);
			listMap.put("tempFile", tempFile);
			
			 // ★ 매뉴얼 묶어서 listMap으로 전달
			listMap.put("manualFiles", manualFile);                 // MultipartFile[]  ← 이름 주의!
			listMap.put("manualFileType", manualFileType);          // List<String>
			listMap.put("manualFileTypeText", manualFileTypeText);  // List<String> (사용 안해도 put)
			
			int menuIdx = menuService.insertTmpMenu(param, listMap, file);
			returnMap.put("IDX", menuIdx);
			returnMap.put("RESULT", "S");
			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/insertMenuAjax")
	@ResponseBody
	public Map<String, Object> insertMenuAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "usageArr", required = false) List<String> usageArr
			, @RequestParam(value = "customUsage", required = false) String customUsage
			, @RequestParam(value = "menuType", required = false) List<String> menuType
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
			, @RequestParam(value = "tempFile", required = false) List<String> tempFile
			, @RequestParam(value = "manualFile", required = false) MultipartFile[] manualFile
	        , @RequestParam(value = "manualFileType", required = false) List<String> manualFileType
	        , @RequestParam(value = "manualFileTypeText", required = false) List<String> manualFileTypeText
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			Collections.reverse(menuType);
			
			HashMap<String, Object> listMap = new HashMap<String, Object>();
			listMap.put("usageArr", usageArr);
			listMap.put("customUsage", customUsage);
			listMap.put("menuType", menuType);
			listMap.put("fileType", fileType);
			listMap.put("fileTypeText", fileTypeText);
			listMap.put("tempFile", tempFile);
			 // ★ 매뉴얼 묶어서 listMap으로 전달
			listMap.put("manualFiles", manualFile);                 // MultipartFile[]  ← 이름 주의!
			listMap.put("manualFileType", manualFileType);          // List<String>
			listMap.put("manualFileTypeText", manualFileTypeText);  // List<String> (사용 안해도 put)
			
			int menuIdx = menuService.insertMenu(param, listMap, file);
			returnMap.put("IDX", menuIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping(value = "/versionUp")
	public String versionUp( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			//해당 문서가 내 문서인지 확인한다.
			if( menuService.selectMyDataCheck(param) > 0 ) {
				Map<String, Object> menuData = menuService.selectMenuData(param);
				model.addAttribute("menuData", menuData);
				Map<String, Object> addInfoCount = menuService.selectAddInfoCount(param);
				model.addAttribute("addInfoCount", addInfoCount);
				List<Map<String, String>> addInfoList = menuService.selectAddInfo(param);
				model.addAttribute("addInfoList", addInfoList);
				List<Map<String, String>> imporvePurposeList = menuService.selectImporvePurposeList(param);
				model.addAttribute("imporvePurposeList", imporvePurposeList);
				List<Map<String, String>> newDataList = menuService.selectNewDataList(param);
				model.addAttribute("newDataList", newDataList);
				model.addAttribute("menuMaterialData", menuService.selectMenuMaterial(param));
				List<Map<String, String>> sharedUserList = menuService.selectSharedUser(param);
				model.addAttribute("sharedUserList", sharedUserList);
				return "/menu/versionUp";
			} else {
				model.addAttribute("returnPage", "/menu/list");
				return "/error/noAuth";
			}
			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectHistoryAjax")
	@ResponseBody
	public List<Map<String, Object>> selectHistoryAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return menuService.selectHistory(param);
	}
	
	@RequestMapping("/insertNewVersionCheckAjax")
	@ResponseBody
	public Map<String, Object> insertNewVersionCheckAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		returnMap.put("RESULT", menuService.insertNewVersionCheck(param));
		return returnMap;
	}
	
	@RequestMapping("/insertNewVersionMenuTmpAjax")
	@ResponseBody
	public Map<String, Object> insertNewVersionMenuTmpAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "usageArr", required = false) List<String> usageArr
			, @RequestParam(value = "customUsage", required = false) String customUsage
			, @RequestParam(value = "menuType", required = false) List<String> menuType
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
			, @RequestParam(value = "tempFile", required = false) List<String> tempFile
			, @RequestParam(value = "manualTempFile", required = false) List<String> manualTempFile
			, @RequestParam(value = "manualFile",   required = false) MultipartFile[] manualFile
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			Collections.reverse(menuType);

			HashMap<String, Object> listMap = new HashMap<String, Object>();
			listMap.put("usageArr", usageArr);
			listMap.put("customUsage", customUsage);
			listMap.put("menuType", menuType);
			listMap.put("fileType", fileType);
			listMap.put("fileTypeText", fileTypeText);
			listMap.put("tempFile", tempFile);
			listMap.put("manualTempFile", manualTempFile);
			
			int menuIdx = menuService.insertNewVersionMenuTmp(param, listMap, file, manualFile);
			returnMap.put("IDX", menuIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/insertNewVersionMenuAjax")
	@ResponseBody
	public Map<String, Object> insertNewVersionMenuAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "usageArr", required = false) List<String> usageArr
			, @RequestParam(value = "customUsage", required = false) String customUsage
			, @RequestParam(value = "menuType", required = false) List<String> menuType
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
			, @RequestParam(value = "tempFile", required = false) List<String> tempFile
			, @RequestParam(value="manualTempFile", required=false) List<String> manualTempFile
			, @RequestParam(value="manualFile", required=false) MultipartFile[] manualFile   
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			Collections.reverse(menuType);

			HashMap<String, Object> listMap = new HashMap<String, Object>();
			listMap.put("usageArr", usageArr);
			listMap.put("customUsage", customUsage);
			listMap.put("menuType", menuType);
			listMap.put("fileType", fileType);
			listMap.put("fileTypeText", fileTypeText);
			listMap.put("tempFile", tempFile);
			listMap.put("manualTempFile", manualTempFile);
			
			int menuIdx = menuService.insertNewVersionMenu(param, listMap, file, manualFile);
			returnMap.put("IDX", menuIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/selectErpMaterialDataAjax")
	@ResponseBody
	public Map<String, Object> selectErpMaterialDataAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return menuService.selectErpMaterialData(param);
	}
	
	@RequestMapping("/selectSearchMenuAjax")
	@ResponseBody
	public Map<String, Object> selectSearchMenuAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = menuService.selectSearchMenu(param);
		return returnMap;
	}
	
	@RequestMapping("/selectMenuDataAjax")
	@ResponseBody
	public Map<String, Object> selectMenuDataAjax(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		//lab_menu 테이블 조회, lab_file 테이블 조회
		Map<String, Object> returnMap = new HashMap<String, Object>();
		returnMap.put("menuData", menuService.selectMenuData(param));
		Map<String, Object> addInfoCount = menuService.selectAddInfoCount(param);
		returnMap.put("addInfoCount", addInfoCount);
		List<Map<String, String>> addInfoList = menuService.selectAddInfo(param);
		returnMap.put("addInfoList", addInfoList);
		List<Map<String, String>> newDataList = menuService.selectNewDataList(param);
		returnMap.put("newDataList", newDataList);
		returnMap.put("menuMaterialData", menuService.selectMenuMaterial(param));
		List<Map<String, String>> sharedUserList = menuService.selectSharedUser(param);
		model.addAttribute("sharedUserList", sharedUserList);
		return returnMap;
	}
	
	@RequestMapping(value = "/update")
	public String menuUpdateForm( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			//해당 문서가 내 문서인지 확인한다.
			if( menuService.selectMyDataCheck(param) > 0 ) {
				Map<String, Object> menuData = menuService.selectMenuData(param);
				model.addAttribute("menuData", menuData);
				Map<String, Object> addInfoCount = menuService.selectAddInfoCount(param);
				model.addAttribute("addInfoCount", addInfoCount);
				List<Map<String, String>> addInfoList = menuService.selectAddInfo(param);
				model.addAttribute("addInfoList", addInfoList);
				List<Map<String, String>> imporvePurposeList = menuService.selectImporvePurposeList(param);
				model.addAttribute("imporvePurposeList", imporvePurposeList);
				List<Map<String, String>> newDataList = menuService.selectNewDataList(param);
				model.addAttribute("newDataList", newDataList);
				model.addAttribute("menuMaterialData", menuService.selectMenuMaterial(param));
				List<Map<String, String>> sharedUserList = menuService.selectSharedUser(param);
				model.addAttribute("sharedUserList", sharedUserList);
				
				//lab_approval_header 테이블 조회
				param.put("docIdx", param.get("idx"));
				param.put("docType", "MENU");
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
				return "/menu//update";
			} else {
				model.addAttribute("returnPage", "/menu/list");
				return "/error/noAuth";
			}
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping(value = "/deleteFileAjax", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> deleteFileAjax(HttpServletResponse respose, HttpServletRequest request, @RequestParam Map<String, Object> param) throws Exception{
		Map<String, Object> map = new HashMap<String, Object>();
		try {
			Map<String, Object> fileData = menuService.selectFileData(param);
			String path = (String)fileData.get("FILE_PATH");
			String fileName = (String)fileData.get("FILE_NAME");

			String fullPath = path+"/"+fileName;
			File file = new File(fullPath);
			if(file.exists() == true){		
				file.delete();				// 해당 경로의 파일이 존재하면 파일 삭제
			}
			menuService.deleteFileData(param);
			map.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			map.put("RESULT", "E");
			map.put("MESSAGE", e.getMessage());
		}
		return map;
	}
	
	@RequestMapping("/updateTmpMenuAjax")
	@ResponseBody
	public Map<String, String> updateTmpMenuAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "usageArr", required = false) List<String> usageArr
			, @RequestParam(value = "customUsage", required = false) String customUsage
			, @RequestParam(value = "menuType", required = false) List<String> menuType
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
	        // ★ 매뉴얼 신규 파일
	        , @RequestParam(value = "manualFile", required = false) MultipartFile[] manualFiles
	        // ★ 매뉴얼 삭제 배열(JSON 문자열)
	        , @RequestParam(value = "manualDeletedFileIdArr", required = false) String manualDeletedFileIdArrJson
	        , @RequestParam(value = "manualDeletedFileArr", required = false) String manualDeletedFileArrJson
	        , @RequestParam(value = "manualDeletedFilePathArr", required = false) String manualDeletedFilePathArrJson
			/*, @RequestParam(value = "docType", required = false) List<String> docType
			, @RequestParam(value = "docTypeText", required = false) List<String> docTypeText
			, @RequestParam(value = "deleteFileArr", required = false) List<String> deleteFileArr
			, @RequestParam(value = "deleteFilePathArr", required = false) List<String> deleteFilePathArr*/
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			Collections.reverse(menuType);
			HashMap<String, Object> listMap = new HashMap<String, Object>();
			listMap.put("usageArr", usageArr);
			listMap.put("customUsage", customUsage);
			listMap.put("menuType", menuType);
			listMap.put("fileType", fileType);
			listMap.put("fileTypeText", fileTypeText);
			
			// ★ 매뉴얼 삭제 배열 전달(서비스에서 JSON 파싱)
	        listMap.put("manualDeletedFileIdArrJson", manualDeletedFileIdArrJson);
	        listMap.put("manualDeletedFileArrJson", manualDeletedFileArrJson);
	        listMap.put("manualDeletedFilePathArrJson", manualDeletedFilePathArrJson);
	        
			/*listMap.put("docType", docType);
			listMap.put("docTypeText", docTypeText);
			listMap.put("deleteFileArr", deleteFileArr);
			listMap.put("deleteFilePathArr", deleteFilePathArr);*/
			menuService.updateMenuTmp(param, listMap, file, manualFiles);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/updateMenuAjax")
	@ResponseBody
	public Map<String, String> updateMenuAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "usageArr", required = false) List<String> usageArr
			, @RequestParam(value = "customUsage", required = false) String customUsage
			, @RequestParam(value = "menuType", required = false) List<String> menuType
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
			, @RequestParam(value = "manualFile", required = false) MultipartFile[] manualFiles
			/*, @RequestParam(value = "docType", required = false) List<String> docType
			, @RequestParam(value = "docTypeText", required = false) List<String> docTypeText
			, @RequestParam(value = "deleteFileArr", required = false) List<String> deleteFileArr
			, @RequestParam(value = "deleteFilePathArr", required = false) List<String> deleteFilePathArr*/
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, String> returnMap = new HashMap<String, String>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			Collections.reverse(menuType);
			HashMap<String, Object> listMap = new HashMap<String, Object>();
			listMap.put("usageArr", usageArr);
			listMap.put("customUsage", customUsage);
			listMap.put("menuType", menuType);
			listMap.put("fileType", fileType);
			listMap.put("fileTypeText", fileTypeText);
			/*listMap.put("docType", docType);
			listMap.put("docTypeText", docTypeText);
			listMap.put("deleteFileArr", deleteFileArr);
			listMap.put("deleteFilePathArr", deleteFilePathArr);*/
			menuService.updateMenu(param, listMap, file, manualFiles);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping(value = "/deleteMenuAjax", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> deleteMenuAjax(HttpServletResponse respose, HttpServletRequest request, @RequestParam Map<String, Object> param) throws Exception{
		Map<String, Object> map = new HashMap<String, Object>();
		try {
			menuService.deleteMenu(param);
			map.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			map.put("RESULT", "E");
			map.put("MESSAGE", e.getMessage());
		}
		return map;
	}
}
