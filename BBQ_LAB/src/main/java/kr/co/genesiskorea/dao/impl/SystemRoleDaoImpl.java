package kr.co.genesiskorea.dao.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.SystemRoleDao;

@Repository
public class SystemRoleDaoImpl implements SystemRoleDao {
	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public int selectTotalRoleCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("systemRole.selectTotalRoleCount", param);
	}

	@Override
	public List<Map<String, Object>> selectRoleList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("systemRole.selectRoleList", param);
	}

	@Override
	public Map<String, Object> selectRoleData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("systemRole.selectRoleData", param);
	}

	@Override
	public void insertRole(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("systemRole.insertRole", param);
	}

	@Override
	public void updateRole(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("systemRole.updateRole", param);
	}

	@Override
	public void deleteRole(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("systemRole.deleteRole", param);
	}

}
