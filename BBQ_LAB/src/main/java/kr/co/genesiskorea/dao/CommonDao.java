package kr.co.genesiskorea.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface CommonDao {

	List<HashMap<String, String>> getCodeList(HashMap<String, String> param);

	List<HashMap<String, Object>> getCompany();

	List<HashMap<String, Object>> getUnit();

	List<HashMap<String, Object>> getPlant(Map<String, Object> param);
	
	void insertFileType(List<HashMap<String, Object>> docTypeList) throws Exception;
	
	void insertHistory(Map<String, Object> historyParam) throws Exception;
	
	void insertFileInfo(Map<String, Object> fileMap) throws Exception;
	
	List<Map<String, String>> selectFileList(Map<String, Object> param);
	
	List<Map<String, String>> selectFileType(Map<String, Object> param);

	List<Map<String, Object>> selectCategoryByPId(Map<String, Object> param);

	List<Map<String, Object>> categoryList(Map<String, Object> param);

	Map<String, String> selectFileData(Map<String, Object> param);

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	void deleteFileType(HashMap<String, Object> map) throws Exception;

	void insertNotification(Map<String, Object> param) throws Exception;

	void insertNotificationHistory(Map<String, Object> param) throws Exception;

	int selectSeq( Map<String, Object> param );

	List<HashMap<String, Object>> selectNotification(Map<String, Object> param);

	void deleteNotification(List<HashMap<String, Object>> notiList);

	void deleteFileData(String fileIdx) throws Exception;

	List<Map<String, Object>> getCodeList(Map<String, Object> param);

	List<HashMap<String, Object>> selectTeamList(Map<String, Object> param);

	List<HashMap<String, Object>> selectUserList(Map<String, Object> param);

}
