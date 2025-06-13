package kr.co.genesiskorea.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.co.genesiskorea.dao.SystemMenuDao;
import kr.co.genesiskorea.service.SystemMenuService;
import kr.co.genesiskorea.util.PageNavigator;

@Service
public class SystemMenuServiceImpl implements SystemMenuService {
	@Autowired
	SystemMenuDao menuDao;

	@Override
	public Map<String, Object> menuList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = menuDao.selectTotalMenuCount(param);
		
		int viewCount = 0;
		try {
			viewCount = Integer.parseInt(param.get("viewCount").toString());
		} catch( Exception e ) {
			viewCount = 10;
		}
		
		// 페이징: 페이징 정보 SET
		PageNavigator navi = new PageNavigator(param, viewCount, totalCount);
		
		List<Map<String, Object>> menuList = menuDao.selectMenuList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("totalCount", totalCount);
		map.put("list", menuList);
		map.put("navi", navi);
		
		return map;
	}

	@Override
	public List<Map<String, Object>> selectAllMenuList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectAllMenuList(param);
	}

	@Override
	public void insertMenu2(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		boolean isNum = false;
		try{
			Integer.parseInt(param.get("id").toString());
			isNum = true;
		} catch(Exception e) {
			isNum = false;
		}
		
		if( isNum ) {
			Map<String, Object> map =  menuDao.selectMenuData(param);
			if( map != null && map.get("menuId") != null && "".equals(map.get("menuId")) ) {
				menuDao.updateMenuName(param);
			} else {
				menuDao.insertMenu2(param);
			}
		} else {
			menuDao.insertMenu2(param);
		}
	}
	
	@Override
	public void insertMenu(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		menuDao.insertMenu(param);
	}

	@Override
	public List<Map<String, Object>> pMenuList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.pMenuList(param);
	}

	@Override
	public Map<String, Object> selectMenuData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectMenuData(param);
	}

	@Override
	public void updateMenu(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		menuDao.updateMenu(param);
	}

	@Override
	public void deleteMenu(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		menuDao.deleteMenu(param);
	}

	@Override
	public List<Map<String, Object>> selectAllMenu(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectAllMenu(param);
	}

	

}
