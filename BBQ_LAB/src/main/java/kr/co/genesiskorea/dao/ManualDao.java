package kr.co.genesiskorea.dao;

import java.util.List;
import java.util.Map;

public interface ManualDao {
	int selectManualCount(Map<String, Object> param);

	List<Map<String, Object>> selectManualList(Map<String, Object> param);

	void uploadManual(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectManualFileList(Map<String, Object> param);

	void insertManual(Map<String, Object> param);
}
