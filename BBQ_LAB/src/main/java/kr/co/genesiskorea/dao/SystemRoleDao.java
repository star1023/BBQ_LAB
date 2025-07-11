package kr.co.genesiskorea.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface SystemRoleDao {

	int selectTotalRoleCount(Map<String, Object> param);

	List<Map<String, Object>> selectRoleList(Map<String, Object> param);

	Map<String, Object> selectRoleData(Map<String, Object> param);

	void insertRole(Map<String, Object> param) throws Exception;

	void updateRole(Map<String, Object> param) throws Exception;

	void deleteRole(Map<String, Object> param) throws Exception;

	List<HashMap<String, Object>> selectRoleList();

}
