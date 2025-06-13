package kr.co.genesiskorea.service.impl;

import java.util.HashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.co.genesiskorea.dao.LoginDao;
import kr.co.genesiskorea.service.LoginService;

@Service
public class LoginServiceImpl implements LoginService {
	
	@Autowired
	LoginDao loginDao;
	
	@Override
	public HashMap<String, Object> loginProc(HashMap<String, Object> paramMap) {
		// TODO Auto-generated method stub
		loginDao.loginProc(paramMap);
		return null;
	}
}
