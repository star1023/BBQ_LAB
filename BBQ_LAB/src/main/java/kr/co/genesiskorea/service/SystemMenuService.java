package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

public interface SystemMenuService {

	Map<String, Object> menuList(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectAllMenuList(Map<String, Object> param);

	void insertMenu(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> pMenuList(Map<String, Object> param);

	void insertMenu2(Map<String, Object> param) throws Exception;

	Map<String, Object> selectMenuData(Map<String, Object> param);

	void updateMenu(Map<String, Object> param) throws Exception;

	void deleteMenu(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectAllMenu(Map<String, Object> param);

}
