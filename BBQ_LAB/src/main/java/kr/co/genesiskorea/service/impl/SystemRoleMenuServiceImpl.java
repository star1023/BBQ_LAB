package kr.co.genesiskorea.service.impl;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.co.genesiskorea.dao.SystemRoleMenuDao;
import kr.co.genesiskorea.service.SystemRoleMenuService;

@Service
public class SystemRoleMenuServiceImpl implements SystemRoleMenuService {
	@Autowired
	SystemRoleMenuDao rMenuDao;
	
	@Override
	public List<Map<String, Object>> selectRoleMenuList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return rMenuDao.selectRoleMenuList(param);
	}

	@Override
	public void updateRoleMenu(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		//1.기존 메뉴권한 리스트 삭제
		rMenuDao.deleteRoleMenu(param);
		//2.신규 메뉴 권한 리스트 등록
		rMenuDao.insertRoleMenu(param);
	}

}
