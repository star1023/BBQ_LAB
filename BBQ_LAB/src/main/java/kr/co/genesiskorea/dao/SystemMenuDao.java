package kr.co.genesiskorea.dao;

import java.util.List;
import java.util.Map;

public interface SystemMenuDao {

	int selectTotalMenuCount(Map<String, Object> param);

	List<Map<String, Object>> selectMenuList(Map<String, Object> param);

	List<Map<String, Object>> selectAllMenuList(Map<String, Object> param);

	Map<String, Object> selectMenuData(Map<String, Object> param);

	void updateMenuName(Map<String, Object> param) throws Exception;

	void insertMenu(Map<String, Object> param) throws Exception;
	
	void insertMenu2(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> pMenuList(Map<String, Object> param);

	void updateMenu(Map<String, Object> param) throws Exception;

	void deleteMenu(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectAllMenu(Map<String, Object> param);

	

}
