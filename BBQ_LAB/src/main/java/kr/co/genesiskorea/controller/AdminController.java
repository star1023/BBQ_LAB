package kr.co.genesiskorea.controller;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import kr.co.genesiskorea.service.AdminService;

@Controller
@RequestMapping("/admin")
public class AdminController {
	private Logger logger = LogManager.getLogger(AdminController.class);
	
	@Autowired
	AdminService adminService;
}
