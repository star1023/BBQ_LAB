package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

public interface ManualService {
	Map<String, Object> selectManualList(Map<String, Object> param) throws Exception;

	void uploadManual(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectManualFileList(Map<String, Object> param);
}
