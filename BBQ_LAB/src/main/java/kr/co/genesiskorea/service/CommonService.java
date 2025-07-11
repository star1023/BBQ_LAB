package kr.co.genesiskorea.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface CommonService {

	List<HashMap<String, String>> getCodeList(HashMap<String, String> param);

	List<HashMap<String, Object>> getCompany();

	List<HashMap<String, Object>> getUnit();

	List<HashMap<String, Object>> getPlant(Map<String, Object> param);
	
	List<Map<String, Object>> selectCategoryByPId(Map<String, Object> param);

	List<Map<String, Object>> categoryList(Map<String, Object> param);

	Map<String, String> selectFileData(Map<String, Object> param);

	Object selectFileType(Map<String, Object> param);

	List<Map<String, Object>> selectHistory(Map<String, Object> param);
	
	int selectSeq( Map<String, Object> param );
	
	void insertNotification(Map<String, Object> param) throws Exception;
	
	void insertNotificationHistory(Map<String, Object> param) throws Exception;
	
	void notification(Map<String, Object> param) throws Exception;
	
	List<HashMap<String, Object>> selectNotification(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> getCodeList(Map<String, Object> param);

	void notificationAll();
	
	void insertHistory(Map<String, Object> param) throws Exception;

	List<HashMap<String, Object>> selectTeamList(Map<String, Object> param);

	List<HashMap<String, Object>> selectUserList(Map<String, Object> param);
}
