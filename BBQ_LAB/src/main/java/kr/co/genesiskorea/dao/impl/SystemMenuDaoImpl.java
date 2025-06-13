package kr.co.genesiskorea.dao.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.SystemMenuDao;

@Repository
public class SystemMenuDaoImpl implements SystemMenuDao {
	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public int selectTotalMenuCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("systemMenu.selectTotalMenuCount", param);
	}

	@Override
	public List<Map<String, Object>> selectMenuList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("systemMenu.selectMenuList", param);
	}

	@Override
	public List<Map<String, Object>> selectAllMenuList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("systemMenu.selectAllMenuList", param);
	}

	@Override
	public Map<String, Object> selectMenuData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("systemMenu.selectMenuData", param);
	}

	@Override
	public void updateMenuName(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("systemMenu.updateMenu", param);
	}

	@Override
	public void insertMenu(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("systemMenu.insertMenu", param);
	}
	
	@Override
	public void insertMenu2(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("systemMenu.insertMenu2", param);
	}

	@Override
	public List<Map<String, Object>> pMenuList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("systemMenu.selectPMenuList", param);
	}

	@Override
	public void updateMenu(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("systemMenu.updateMenu", param);
	}

	@Override
	public void deleteMenu(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("systemMenu.deleteMenu", param);
	}

	@Override
	public List<Map<String, Object>> selectAllMenu(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("systemMenu.selectAllMenu", param);
	}

	

}
