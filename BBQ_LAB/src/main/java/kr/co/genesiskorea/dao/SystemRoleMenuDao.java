package kr.co.genesiskorea.dao;

import java.util.List;
import java.util.Map;

public interface SystemRoleMenuDao {

	List<Map<String, Object>> selectRoleMenuList(Map<String, Object> param);

	void deleteRoleMenu(Map<String, Object> param) throws Exception;

	void insertRoleMenu(Map<String, Object> param) throws Exception;

}
