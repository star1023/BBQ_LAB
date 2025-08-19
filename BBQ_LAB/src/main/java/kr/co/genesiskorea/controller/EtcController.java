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
import kr.co.genesiskorea.service.EtcReportService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/etcReport")
public class EtcController {
private Logger logger = LogManager.getLogger(DesignReportController.class);
	
	@Autowired
	private Properties config;
	
	@Autowired
	EtcReportService etcService;
	
	@Autowired
	ApprovalService approvalService;
	
	@RequestMapping(value = "/list")
	public String productList( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/etcReport/list";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectEtcListAjax")
	@ResponseBody
	public Map<String, Object> selectEtcListAjax(HttpServletRequest request, HttpServletResponse response, @RequestParam(required=false) Map<String, Object> param) throws Exception {
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		Map<String, Object> returnMap = etcService.selectEtcList(param);
		return returnMap;
	}
	
	@RequestMapping(value = "/insert")
	public String compInsert( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception{
		try {
			logger.debug("param : {} ",param.toString());
			return "/etcReport/insert";
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/insertTmpEtcAjax")
	@ResponseBody
	public Map<String, Object> insertTmpEtcAjax(HttpServletRequest request, HttpServletResponse response
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
			int designIdx = etcService.insertTmpEtc(param, listMap, file);
			returnMap.put("IDX", designIdx);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/insertEtcAjax")
	@ResponseBody
	public Map<String, Object> insertEtcAjax(HttpServletRequest request, HttpServletResponse response
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
			int etcIdx = etcService.insertEtc(param, listMap, file);
			returnMap.put("IDX", etcIdx);
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
		Map<String, Object> etcData = etcService.selectEtcData(param);
		model.addAttribute("etcData", etcData);
		
		param.put("docIdx", param.get("idx"));
		param.put("docType", "ETC");
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
		
		return "/etcReport/view";
	}
	
	@RequestMapping(value = "/update")
	public String designUpdateForm( HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param, ModelMap model ) throws Exception{
		try {
			Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
			
			if( etcService.selectMyDataCheck(param) > 0 ) {
				Map<String, Object> etcData = etcService.selectEtcData(param);
				//lab_design 테이블 조회, lab_file 테이블 조회
				model.addAttribute("etcData", etcData);
				
				param.put("docIdx", param.get("idx"));
				param.put("docType", "ETC");
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
				
				return "/etcReport/update";
			} else {
				model.addAttribute("returnPage", "/etcReport/list");
				return "/error/noAuth";
			}
					
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/updateTmpEtcAjax")
	@ResponseBody
	public Map<String, Object> updateTmpEtcAjax(HttpServletRequest request, HttpServletResponse response
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
			etcService.updateEtc(param, listMap, file);
			returnMap.put("RESULT", "S");			
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE",e.getMessage());
		}
		return returnMap;
	}
	
	@RequestMapping("/updateEtcAjax")
	@ResponseBody
	public Map<String, Object> updateEtcAjax(HttpServletRequest request, HttpServletResponse response
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
			etcService.updateEtc(param, listMap, file);
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
		return etcService.selectHistory(param);
	}
	
	@RequestMapping(value = "/deleteEtcReportAjax", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> deleteEtcReportAjax(HttpServletResponse respose, HttpServletRequest request, @RequestParam Map<String, Object> param) throws Exception{
		Map<String, Object> map = new HashMap<String, Object>();
		try {
			etcService.deleteEtcReport(param);
			map.put("RESULT", "S");
		} catch( Exception e ) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			map.put("RESULT", "E");
			map.put("MESSAGE", e.getMessage());
		}
		return map;
	}
}
