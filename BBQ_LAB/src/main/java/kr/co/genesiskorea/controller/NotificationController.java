package kr.co.genesiskorea.controller;

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

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.NoticeService;
import kr.co.genesiskorea.service.NotificationService;
import kr.co.genesiskorea.util.StringUtil;

@Controller
@RequestMapping("/notification")
public class NotificationController {
	private Logger logger = LogManager.getLogger(NotificationController.class);
	
	@Autowired
	NotificationService notificationService;
	
	@RequestMapping("/list")
	public String noticeList(HttpSession session,HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> param ) throws Exception {
		try {
			logger.debug("param : {} ",param.toString());
			return "notification/list";
		}catch(Exception e) {
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@RequestMapping("/selectListAjax")
	@ResponseBody
	public Map<String, Object> selectNoticeListAjax(HttpSession session, HttpServletRequest request,
	                                                HttpServletResponse response,
	                                                @RequestParam Map<String, Object> param) throws Exception {
	    try {
	        logger.error("[selectNoticeListAjax] 요청 수신: {}", param.toString()); // ← DEBUG → ERROR
	        Auth auth = AuthUtil.getAuth(request);
			param.put("userId", auth.getUserId());
	        return notificationService.selectList(param);
	    } catch (Exception e) {
	        logger.error("[selectNoticeListAjax] 오류 발생", e); // ← 전체 스택 찍기
	        throw e;
	    }
	}
	
}
