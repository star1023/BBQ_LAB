package kr.co.genesiskorea.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface CodeManagementDao {

	List<HashMap<String, Object>> getGroupList();

	int groupCount(Map<String, String> param);

	void groupInsert(Map<String, String> param);

	void groupUpdate(Map<String, String> param);

	int groupItemCount(Map<String, String> param);

	void groupDelete(Map<String, String> param);

	List<HashMap<String, Object>> getItemList(Map<String, String> param);

	int itemCount(Map<String, String> param);

	void itemInsert(Map<String, String> param);

	void itemUpdate(Map<String, String> param);

	void itemOrderUpdate(Map<String, String> param);

	void itemDelete(Map<String, String> param);

	void itemOrderUpDown(Map<String, String> param);

	void itemOrderUpdateAjax(Map<String, String> param);

}
