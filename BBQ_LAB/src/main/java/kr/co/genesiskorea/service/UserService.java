package kr.co.genesiskorea.service;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

public interface UserService {
	public HashMap<String,Object> login( Map<String, Object> param, HttpServletRequest request) throws Exception;

	public Map<String, Object> getUserList(Map<String, Object> param) throws Exception;

	public int checkId(String userId);

	public void inserUser(Map<String, Object> param) throws Exception;

	public void insertLog(Map<String, Object> logParam);

	public Map<String, Object> selectUserData(String userId);

	public void updateUser(Map<String, Object> param) throws Exception;

	public void deleteUser(String userId) throws Exception;

	public void restoreUser(String userId) throws Exception;

	public void unlockUser(String userId) throws Exception;

	public int insertAccessLog(HashMap<String, Object> param);

	public void logout(HttpServletRequest request) throws Exception;

	public void setPersonalization(Map<String, Object> param) throws Exception;
}
