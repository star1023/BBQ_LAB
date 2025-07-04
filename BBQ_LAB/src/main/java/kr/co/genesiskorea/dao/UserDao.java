package kr.co.genesiskorea.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface UserDao {
	public HashMap<String,Object> selectUser( Map<String, Object> param ) throws Exception;
	
	public void insertLginLog(Map<String, Object> logParam) throws Exception;

	public int getUserCount(Map<String, Object> param);

	public List<HashMap<String, Object>> getUserList(Map<String, Object> param);

	public int checkId(String userId);

	public void inserUser(Map<String, Object> param) throws Exception;

	public void insertLog(Map<String, Object> logParam);

	public Map<String, Object> selectUserData(String userId);

	public void updateUser(Map<String, Object> param) throws Exception;

	public void deleteUser(String userId) throws Exception;

	public void restoreUser(String userId) throws Exception;

	public void unlockUser(String userId) throws Exception;
	
	public int selectAccessLogSeq();
	
	public int insertAccessLog(HashMap<String, Object> param);
	
	public int insertAccessLogParams(HashMap<String, Object> param);

	public List<Map<String, Object>> selectUserMenu(Map<String, Object> param);

	public void setPersonalization(Map<String, Object> param) throws Exception;

	public List<Map<String, Object>> selectUserAuth(Map<String, Object> param) throws Exception;
	public HashMap<String, Object> loginCheck(Map<String, Object> param) throws Exception;
	public void updateUserPwd(Map<String, Object> param) throws Exception;
	public Map<String, Object> getUserData(String userId);

}
