package kr.co.genesiskorea.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.co.genesiskorea.dao.SystemRoleDao;
import kr.co.genesiskorea.service.SystemRoleService;
import kr.co.genesiskorea.util.PageNavigator;

@Service
public class SystemRoleServiceImpl implements SystemRoleService {
	@Autowired
	SystemRoleDao roleDao;
	
	@Override
	public Map<String, Object> selectRoleList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = roleDao.selectTotalRoleCount(param);
		
		int viewCount = 0;
		try {
			viewCount = Integer.parseInt(param.get("viewCount").toString());
		} catch( Exception e ) {
			viewCount = 10;
		}
		
		// 페이징: 페이징 정보 SET
		PageNavigator navi = new PageNavigator(param, viewCount, totalCount);
		
		List<Map<String, Object>> menuList = roleDao.selectRoleList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("totalCount", totalCount);
		map.put("list", menuList);
		map.put("navi", navi);
		
		return map;
	}

	@Override
	public Map<String, Object> selectRoleData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return roleDao.selectRoleData(param);
	}

	@Override
	public void insertRole(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		roleDao.insertRole(param);
	}

	@Override
	public void updateRole(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		roleDao.updateRole(param);
	}

	@Override
	public void deleteRole(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		roleDao.deleteRole(param);
	}

}
