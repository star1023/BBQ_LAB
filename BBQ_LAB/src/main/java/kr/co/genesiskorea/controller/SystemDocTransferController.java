package kr.co.genesiskorea.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.SystemDocTransferService;

@Controller
@RequestMapping("/systemDocTransfer")
public class SystemDocTransferController {
	
	@Autowired
    SystemDocTransferService systemDocTransferService; 
	
	@RequestMapping("/list")
	public String list(HttpServletRequest request, HttpServletResponse response, Model model , @RequestParam(required=false) Map<String, Object> param) throws Exception {
		return "/systemDocTransfer/list";
	}
	
	/** 담당자별 문서 조회 (왼쪽 트리) */
	@PostMapping(value = "/selectUserDocsAjax", produces = "application/json; charset=UTF-8")
	@ResponseBody
    public Map<String, Object> selectUserDocsAjax(@RequestParam Map<String, Object> param) {
    	 Map<String, Object> res = new HashMap<>();
         try {
             String userId = param.get("userId") == null ? "" : String.valueOf(param.get("userId")).trim();
             if (userId.isEmpty()) {
                 res.put("RESULT", "E");
                 res.put("MESSAGE", "userId is required");
                 res.put("docs", java.util.Collections.emptyList());
                 return res;
             }
             List<Map<String, Object>> docs = systemDocTransferService.selectUserDocs(userId);
             res.put("RESULT", "S");
             res.put("docs", docs);
         } catch (Exception e) {
             res.put("RESULT", "E");
             res.put("MESSAGE", "Failed to load documents");
             res.put("docs", java.util.Collections.emptyList());
         }
         return res;
     }
	
	@PostMapping(
	    value = "/transferDocsAjax",
	    consumes = "application/json; charset=UTF-8",
	    produces = "application/json; charset=UTF-8"
	)
	@ResponseBody
	public Map<String, Object> transferDocsAjax(
		HttpServletRequest request,
	    @org.springframework.web.bind.annotation.RequestBody Map<String, Object> body
	) {
	    Map<String, Object> res = new HashMap<>();
	    try {
	    	// 로그인 사용자 정보 조회
	        Auth auth = AuthUtil.getAuth(request);
	        String executeUserId = auth != null ? auth.getUserId() : "";
	        
	        String sourceUserId = (body.getOrDefault("sourceUserId","")+"").trim();
	        String targetTeamId = (body.getOrDefault("targetTeamId","")+"").trim();
	        String targetUserId = (body.getOrDefault("targetUserId","")+"").trim();
	        String transferComment = (body.getOrDefault("transferComment","")+"").trim();

	        @SuppressWarnings("unchecked")
	        List<Map<String, Object>> docs = (List<Map<String, Object>>) body.get("docs");

	        if (targetTeamId.isEmpty()) {
	            res.put("RESULT","E"); res.put("MESSAGE","targetTeamId is required"); return res;
	        }
	        if (targetUserId.isEmpty()) {
	            res.put("RESULT","E"); res.put("MESSAGE","targetUserId is required"); return res;
	        }
	        if (transferComment.isEmpty()) {
	        	res.put("RESULT","E"); res.put("MESSAGE","transferComment is required"); return res;
	        }
	        if (docs == null || docs.isEmpty()) {
	            res.put("RESULT","E"); res.put("MESSAGE","docs is empty"); return res;
	        }

	        Map<String,Object> param = new HashMap<>();
	        param.put("sourceUserId", sourceUserId);
	        param.put("targetTeamId", targetTeamId);
	        param.put("targetUserId", targetUserId);
	        param.put("transferComment", transferComment);
	        param.put("excuteUserId", executeUserId); // 요청자 ID 추가
	        param.put("docs", docs); // 그대로 전달

	        Map<String, Object> serviceResult = systemDocTransferService.transferDocs(param);

	        res.put("RESULT",  serviceResult.getOrDefault("RESULT","S"));
	        res.put("COUNT",   serviceResult.getOrDefault("COUNT", 0));
	        res.put("FAILS",   serviceResult.getOrDefault("FAILS", java.util.Collections.emptyList()));
	        res.put("MESSAGE", serviceResult.getOrDefault("MESSAGE","OK"));
	        return res;
	    } catch (Exception e) {
	        res.put("RESULT","E");
	        res.put("MESSAGE","Transfer failed");
	        res.put("DETAIL", e.getMessage());
	        return res;
	    }
	}
}
