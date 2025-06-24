package kr.co.genesiskorea.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import com.fasterxml.jackson.databind.ObjectMapper;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.MainService;
import kr.co.genesiskorea.service.MenuService;
import kr.co.genesiskorea.service.ProductService;

@Controller
@RequestMapping("/main")
public class MainController {
	private Logger logger = LogManager.getLogger(MainController.class);
	
	@Autowired
	MainService mainService;
	
	@Autowired
	ProductService productService;
	
	@Autowired
	MenuService menuService;
	
	@RequestMapping(value = { "/","/main" }, method = RequestMethod.GET)
	public String main(HttpServletRequest request, Model model,@RequestParam Map<String,Object> param) throws Exception {
		// 메인에서 로그인
		if (!AuthUtil.hasAuth(request)) {
			return "redirect:/user/login";
		}
		Auth auth = AuthUtil.getAuth(request);
		param.put("userId", auth.getUserId());
		
		// 문서 개수 리스트 조회
		Map<String, Object> docCount = mainService.getDocCount(param);
		// 문서 상태 개수 리스트 조회
		Map<String, Object> docStatusCount = mainService.getDocStatusCount(param);
		// 결재 상태 리스트 조회
		Map<String, Object> apprStatusCount = mainService.getApprStatusCount(param);
		// 제품완료보고서 개수
		int productDocCount = productService.selectMyDataCount(param);
		int menuDocCount = menuService.selectMyDataCount(param);
		
		ObjectMapper mapper = new ObjectMapper();
	    String docCountJson = mapper.writeValueAsString(docCount);
	    String docStatusCountJson = mapper.writeValueAsString(docStatusCount);
	    String apprStatusCountJson = mapper.writeValueAsString(apprStatusCount);
	    model.addAttribute("docCountJson", docCountJson);
	    model.addAttribute("docStatusCountJson", docStatusCountJson);
	    model.addAttribute("apprStatusCountJson", apprStatusCountJson);
	    model.addAttribute("productDocCount", productDocCount);
	    model.addAttribute("menuDocCount", menuDocCount);
		
		return "/main/main";
	}
}	
