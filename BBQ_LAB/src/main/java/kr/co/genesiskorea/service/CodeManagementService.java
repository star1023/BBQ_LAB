package kr.co.genesiskorea.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

public interface CodeManagementService {
	List<HashMap<String, Object>> getGroupList();

	int groupCount(Map<String, String> param, HttpServletRequest request);

	void groupInsert(Map<String, String> param, HttpServletRequest request);

	void groupUpdate(Map<String, String> param, HttpServletRequest request);

	int groupItemCount(Map<String, String> param, HttpServletRequest request);

	void groupDelete(Map<String, String> param, HttpServletRequest request);

	List<HashMap<String, Object>> getItemList(Map<String, String> param);

	int itemCount(Map<String, String> param, HttpServletRequest request);

	void itemInsert(Map<String, String> param, HttpServletRequest request);

	void itemUpdate(Map<String, String> param, HttpServletRequest request);

	void itemOrderUpdate(Map<String, String> param, HttpServletRequest request);

	void itemDelete(Map<String, String> param, HttpServletRequest request);

	void itemOrderUpDown(Map<String, String> param, HttpServletRequest request);

	void itemOrderUpdateAjax(Map<String, String> param, HttpServletRequest request);

}
