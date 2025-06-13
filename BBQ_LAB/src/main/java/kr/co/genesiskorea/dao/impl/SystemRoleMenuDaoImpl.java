package kr.co.genesiskorea.dao.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.SystemRoleMenuDao;

@Repository
public class SystemRoleMenuDaoImpl implements SystemRoleMenuDao {
	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public List<Map<String, Object>> selectRoleMenuList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("systemRoleMenu.selectRoleMenuList", param);
	}

	@Override
	public void deleteRoleMenu(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("systemRoleMenu.deleteRoleMenu", param);
	}

	@Override
	public void insertRoleMenu(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("systemRoleMenu.insertRoleMenu", param);
	}

}
