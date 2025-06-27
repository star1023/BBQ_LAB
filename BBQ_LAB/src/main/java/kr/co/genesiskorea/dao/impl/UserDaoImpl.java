package kr.co.genesiskorea.dao.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.UserDao;

@Repository
public class UserDaoImpl implements UserDao {
	
	private Logger logger = LogManager.getLogger(UserDaoImpl.class);
	
	@Autowired
	SqlSessionTemplate sqlSessionTemplate;

	public HashMap<String, Object> selectUser(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("user.selectUser", param);
	}

	@Override
	public void insertLginLog(Map<String, Object> logParam) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("user.insertLoginLog",logParam);
	}

	@Override
	public int getUserCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("user.userCount", param);
	}

	@Override
	public List<HashMap<String, Object>> getUserList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return  sqlSessionTemplate.selectList("user.userList", param);
	}

	@Override
	public int checkId(String userId) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("user.checkId", userId);
	}

	@Override
	public void inserUser(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("user.insertUser",param);
	}

	@Override
	public void insertLog(Map<String, Object> logParam) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("user.insertLog",logParam);
	}

	@Override
	public Map<String, Object> selectUserData(String userId) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("user.selectUserData", userId);
	}

	@Override
	public void updateUser(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("user.updateUser", param);
	}

	@Override
	public void deleteUser(String userId) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("user.deleteUser", userId);
	}

	@Override
	public void restoreUser(String userId) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("user.restoreUser", userId);
	}

	@Override
	public void unlockUser(String userId) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("user.unlockUser", userId);
	}

	@Override
	public int selectAccessLogSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("user.selectAccessLogSeq");
	}

	@Override
	public int insertAccessLog(HashMap<String, Object> param) {
		return sqlSessionTemplate.insert("user.insertAccessLog", param);
	}
	
	@Override
	public int insertAccessLogParams(HashMap<String, Object> param) {
		return sqlSessionTemplate.insert("user.insertAccessLogParams", param);
	}

	@Override
	public List<Map<String, Object>> selectUserMenu(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("user.selectUserMenu", param);
	}
	
	@Override
	public List<Map<String, Object>> selectUserAuth(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("user.selectUserAuth", param);
	}

	@Override
	public void setPersonalization(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("user.setPersonalization", param);
	}
	
	@Override
	public Map<String, Object> getUserData(String userId) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("user.getUserData", userId);
	}
}
