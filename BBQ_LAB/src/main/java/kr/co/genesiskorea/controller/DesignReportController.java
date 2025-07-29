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
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.ApprovalService;
import kr.co.genesiskorea.service.DesignReportService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/designReport")
public class DesignReportController {
	private Logger logger = LogManager.getLogger(DesignReportController.class);
	
	@Autowired
	private Properties config;
	
	@Autowired
	DesignReportService reportService;
	
	@Autowired
	ApprovalService approvalService;
	
	@RequestMapping(value = "/list")
	public String productList( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/designReport/list";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectDesignListAjax")
	@ResponseBody
	public Map<String, Object> selectDesignListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = reportService.selectDesignList(param);
		return returnMap;
	}
	
	@RequestMapping(value = "/insert")
	public String compInsert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/designReport/insert";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/insertTmpDesignAjax")
	@ResponseBody
	public Map<String, Object> insertTmpDesignAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			HashMap<String, Object> listMap = new HashMap<String, Object>();
			listMap.put("fileType", fileType);
			listMap.put("fileTypeText", fileTypeText);
			int designIdx = reportService.insertTmpDesign(param, listMap, file);
			returnMap.put("IDX", designIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/insertDesignAjax")
	@ResponseBody
	public Map<String, Object> insertDesignAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
			/*, @RequestParam(value = "rowIdArr", required = false) List<String> rowIdArr
			, @RequestParam(value = "itemDivArr", required = false) List<String> itemDivArr
			, @RequestParam(value = "itemCurrentArr", required = false) List<String> itemCurrentArr
			, @RequestParam(value = "itemChangeArr", required = false) List<String> itemChangeArr
			, @RequestParam(value = "itemNoteArr", required = false) List<String> itemNoteArr*/
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			HashMap<String, Object> listMap = new HashMap<String, Object>();
			listMap.put("fileType", fileType);
			listMap.put("fileTypeText", fileTypeText);
			//listMap.put("rowIdArr", rowIdArr);
			//listMap.put("itemDivArr", itemDivArr);
			//listMap.put("itemCurrentArr", itemCurrentArr);
			//listMap.put("itemChangeArr", itemChangeArr);
			//listMap.put("itemNoteArr", itemNoteArr);
			int designIdx = reportService.insertDesign(param, listMap, file);
			returnMap.put("IDX", designIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/view")
	public String designView(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model) throws Exception{
		Auth auth = AuthUtil.getAuth(request);
		model.addAttribute("userId", auth.getUserId());
		
		//lab_design 테이블 조회, lab_file 테이블 조회
		Map<String, Object> designData = reportService.selectDesignData(param);
		model.addAttribute("designData", designData);
		//lab_design_change_info 테이블 조회
		model.addAttribute("designChangeList", reportService.selectDesignChangeList(param));
		//lab_design_add_info 테이블 조회
		model.addAttribute("addInfoList", reportService.selectAddInfoList(param));
		
		param.put("docIdx", param.get("idx"));
		param.put("docType", "DESIGN");
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
		
		return "/designReport/view";
	}
	
	@RequestMapping(value = "/update")
	public String designUpdateForm( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model ) throws Exception{
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			if( reportService.selectMyDataCheck(param) > 0 ) {
				Map<String, Object> designData = reportService.selectDesignData(param);
				//lab_design 테이블 조회, lab_file 테이블 조회
				model.addAttribute("designData", designData);
				//lab_design_change_info 테이블 조회
				model.addAttribute("designChangeList", reportService.selectDesignChangeList(param));
				//lab_design_add_info 테이블 조회
				model.addAttribute("addInfoList", reportService.selectAddInfoList(param));
				
				param.put("docIdx", param.get("idx"));
				param.put("docType", "DESIGN");
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
				
				return "/designReport/update";
			} else {
				model.addAttribute("returnPage", "/designReport/list");
				return "/error/noAuth";
			}
					
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
		
		
	}
	
	@RequestMapping("/updateTmpDesignAjax")
	@ResponseBody
	public Map<String, Object> updateTmpDesignAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
			/*, @RequestParam(value = "rowIdArr", required = false) List<String> rowIdArr
			, @RequestParam(value = "itemDivArr", required = false) List<String> itemDivArr
			, @RequestParam(value = "itemCurrentArr", required = false) List<String> itemCurrentArr
			, @RequestParam(value = "itemChangeArr", required = false) List<String> itemChangeArr
			, @RequestParam(value = "itemNoteArr", required = false) List<String> itemNoteArr*/
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			HashMap<String, Object> listMap = new HashMap<String, Object>();
			listMap.put("fileType", fileType);
			listMap.put("fileTypeText", fileTypeText);
			//listMap.put("rowIdArr", rowIdArr);
			//listMap.put("itemDivArr", itemDivArr);
			//listMap.put("itemCurrentArr", itemCurrentArr);
			//listMap.put("itemChangeArr", itemChangeArr);
			//listMap.put("itemNoteArr", itemNoteArr);
			reportService.updateDesign(param, listMap, file);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/updateDesignAjax")
	@ResponseBody
	public Map<String, Object> updateDesignAjax(HttpServletRequest request, HttpServletResponse response
			, @RequestParam(required=false) Map<String, Object> param
			, @RequestParam(value = "fileType", required = false) List<String> fileType
			, @RequestParam(value = "fileTypeText", required = false) List<String> fileTypeText
			/*, @RequestParam(value = "rowIdArr", required = false) List<String> rowIdArr
			, @RequestParam(value = "itemDivArr", required = false) List<String> itemDivArr
			, @RequestParam(value = "itemCurrentArr", required = false) List<String> itemCurrentArr
			, @RequestParam(value = "itemChangeArr", required = false) List<String> itemChangeArr
			, @RequestParam(value = "itemNoteArr", required = false) List<String> itemNoteArr*/
			, @RequestParam(required=false) MultipartFile... file) throws Exception {
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());

			HashMap<String, Object> listMap = new HashMap<String, Object>();
			listMap.put("fileType", fileType);
			listMap.put("fileTypeText", fileTypeText);
			//listMap.put("rowIdArr", rowIdArr);
			//listMap.put("itemDivArr", itemDivArr);
			//listMap.put("itemCurrentArr", itemCurrentArr);
			//listMap.put("itemChangeArr", itemChangeArr);
			//listMap.put("itemNoteArr", itemNoteArr);
			reportService.updateDesign(param, listMap, file);
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
	
	@RequestMapping(value = "/deleteDesignReportAjax", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> deleteDesignReportAjax(HttpServletResponse respose, HttpServletRequest request, @RequestParam Map<String, Object> param) throws Exception{
		Map<String, Object> map = new HashMap<String, Object>();
		try {
			reportService.deleteDesignReport(param);
			map.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			map.put("RESULT", "E");
			map.put("MESSAGE", e.getMessage());
		}
		return map;
	}
}
