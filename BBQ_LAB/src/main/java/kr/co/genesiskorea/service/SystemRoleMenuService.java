package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

public interface SystemRoleMenuService {

	List<Map<String, Object>> selectRoleMenuList(Map<String, Object> param);

	void updateRoleMenu(Map<String, Object> param) throws Exception;

}
