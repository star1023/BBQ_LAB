package kr.co.genesiskorea.controller;

import java.util.HashMap;
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
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.databind.ObjectMapper;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.service.MainService;
import kr.co.genesiskorea.service.MenuService;
import kr.co.genesiskorea.service.ProductService;
import kr.co.genesiskorea.service.UserService;

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
	
	@Autowired
	UserService userService;
	
	@RequestMapping(value = { "/", "/main" }, method = RequestMethod.GET)
    public String main(HttpServletRequest request, Model model, @RequestParam Map<String, Object> param) throws Exception {

        if (!AuthUtil.hasAuth(request)) return "redirect:/user/login";

        Auth auth = AuthUtil.getAuth(request);
        String userId = auth.getUserId();
        param.put("userId", userId);

        ObjectMapper mapper = new ObjectMapper();

        // 1) 유저 정보
        Map<String, Object> userData = userService.getUserData(userId);
        model.addAttribute("userData", userData);

        // ORGAID 세팅
        if (userData != null) {
            // userData key가 ORGAID / orgaid 섞여 있을 수 있어 방어
            Object orgaid = userData.get("ORGAID");
            if (orgaid == null) orgaid = userData.get("orgaid");
            param.put("ORGAID", orgaid);
        }

        // 2) 결재 현황(공통)
        Map<String, Object> apprStatusCount = mainService.getApprStatusCount(param);
        model.addAttribute("apprStatusCountJson", mapper.writeValueAsString(apprStatusCount));

        // 3) ✅ userType 추출 (여기가 핵심)
        // DB 로그 보면 userData에는 userType / userTypeName 으로 내려옴
        String userType = null;
        String userTypeName = null;

        if (userData != null) {
            Object ut = userData.get("userType");
            if (ut == null) ut = userData.get("USER_TYPE"); // 혹시 다른 매퍼 대비
            if (ut != null) userType = String.valueOf(ut);

            Object utn = userData.get("userTypeName");
            if (utn == null) utn = userData.get("USER_TYPE_NAME");
            if (utn != null) userTypeName = String.valueOf(utn);
        }

        // JSP에서도 쓰게 내려줌
        model.addAttribute("userType", userType);
        model.addAttribute("userTypeName", userTypeName);

        logger.info("[MAIN] userId={}, userType={}, userTypeName={}, ORGAID={}, OBJTTX={}",
                userId,
                userType,
                userTypeName,
                userData == null ? null : userData.get("ORGAID"),
                userData == null ? null : userData.get("OBJTTX")
        );

	     // 4) 역할별 데이터
	     // ✅ 임원 값이 EXEC / EXECUTIVE 섞일 수 있으니 둘 다 처리
	     boolean isExec = "EXEC".equalsIgnoreCase(userType) || "EXECUTIVE".equalsIgnoreCase(userType);
	     boolean isLeader = "LEADER".equalsIgnoreCase(userType);
	
	     // ✅ 팀장/임원 아니면 전부 "본인만" (EMP, RESEARCHER, 기타 등등)
	     boolean isSelfOnly = !isExec && !isLeader;
	
	     if (isSelfOnly) {
	         // 본인 데이터만
	         Map<String, Object> docCount = mainService.getDocCount(param);
	         Map<String, Object> docStatusCount = mainService.getDocStatusCount(param);
	
	         model.addAttribute("docCount", docCount);
	         model.addAttribute("docCountJson", mapper.writeValueAsString(docCount));
	         model.addAttribute("docStatusCountJson", mapper.writeValueAsString(docStatusCount));
	
	         // 팀/임원 데이터는 비움
	         model.addAttribute("teamDocCountJson", "{}");
	         model.addAttribute("teamDocStatusCountJson", "[]");
	         model.addAttribute("execTeamsJson", "[]");
	     }
	
	     if (isLeader) {
	         Map<String, Object> docCount = mainService.getDocCount(param);
	         Map<String, Object> docStatusCount = mainService.getDocStatusCount(param);
	
	         Map<String, Object> teamDocCount = mainService.selectTeamDocCount(param);
	         List<Map<String, Object>> teamDocStatusCount = mainService.getTeamDocStatusCount(param);
	
	         model.addAttribute("docCount", docCount);
	         model.addAttribute("docCountJson", mapper.writeValueAsString(docCount));
	         model.addAttribute("docStatusCountJson", mapper.writeValueAsString(docStatusCount));
	
	         model.addAttribute("teamDocCountJson", mapper.writeValueAsString(teamDocCount));
	         model.addAttribute("teamDocStatusCountJson", mapper.writeValueAsString(teamDocStatusCount));
	
	         model.addAttribute("execTeamsJson", "[]");
	     }
	
	     if (isExec) {
	         // 1) 팀 버튼 목록
	         List<Map<String, Object>> execTeams = mainService.selectExecTeams(param);
	         model.addAttribute("execTeamsJson", mapper.writeValueAsString(execTeams));
	
	         // 2) 임원 기본: 전체 파이 + 전체 팀원 막대(팀별 블록)
	         Map<String, Object> allPie = mainService.selectExecAllDocCount(param);
	         List<Map<String, Object>> allMembers = mainService.getExecAllTeamDocStatusCount(param);
	
	         model.addAttribute("teamDocCountJson", mapper.writeValueAsString(allPie));
	         model.addAttribute("teamDocStatusCountJson", mapper.writeValueAsString(allMembers));
	
	         // null 방지
	         model.addAttribute("docCountJson", "{}");
	         model.addAttribute("docStatusCountJson", "{}");
	         model.addAttribute("docCount", new HashMap<String, Object>());
	     }

        return "/main/main";
    }
	
	@RequestMapping(value="/teamChartsAjax", method=RequestMethod.POST)
	public @ResponseBody Map<String,Object> teamChartsAjax(@RequestParam Map<String,Object> param) throws Exception {
	    Map<String, Object> res = new HashMap<>();

	    Object orgaid = param.get("ORGAID");
	    boolean isAll = (orgaid == null || String.valueOf(orgaid).trim().isEmpty());

	    if (isAll) {
	        Map<String, Object> allPie = mainService.selectExecAllDocCount(param);
	        List<Map<String, Object>> allMembers = mainService.getExecAllTeamDocStatusCount(param);
	        res.put("teamDocCount", allPie);
	        res.put("teamMembers", allMembers);
	    } else {
	        Map<String, Object> teamDocCount = mainService.selectTeamDocCount(param);
	        List<Map<String, Object>> teamMembers = mainService.getTeamDocStatusCount(param);
	        res.put("teamDocCount", teamDocCount);
	        res.put("teamMembers", teamMembers);
	    }
	    return res;
	}

}	
