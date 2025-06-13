package kr.co.genesiskorea.controller;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import kr.co.genesiskorea.common.auth.AuthUtil;

@Controller
@RequestMapping("/main")
public class MainController {
	private Logger logger = LogManager.getLogger(MainController.class);
	
	@RequestMapping(value = { "/","/main" }, method = RequestMethod.GET)
	public String main(HttpServletRequest request, Model model,@RequestParam Map<String,Object> param) throws Exception {
		// 메인에서 로그인
		if (!AuthUtil.hasAuth(request)) {
			return "redirect:/user/login";
		}
		return "/main/main";
	}
}	
