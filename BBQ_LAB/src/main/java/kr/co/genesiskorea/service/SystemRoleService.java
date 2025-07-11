package kr.co.genesiskorea.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface SystemRoleService {

	Map<String, Object> selectRoleList(Map<String, Object> param) throws Exception;

	Map<String, Object> selectRoleData(Map<String, Object> param);

	void insertRole(Map<String, Object> param) throws Exception;

	void updateRole(Map<String, Object> param) throws Exception;

	void deleteRole(Map<String, Object> param) throws Exception;

	List<HashMap<String, Object>> selectRoleList();

}
