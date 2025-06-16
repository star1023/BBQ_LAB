package kr.co.genesiskorea.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface SenseQualityDao {

	int selectSenseQualityCount(Map<String, Object> param);

	List<Map<String, Object>> selectSenseQualityList(Map<String, Object> param);

	int selectSenseQualitySeq();

	void insertSenseQualityReport(Map<String, Object> param) throws Exception;
	
	void insertSenseQualityContents(ArrayList<HashMap<String, Object>> contentsList);

	void insertSenseQualityAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception;

	Map<String, Object> selectSenseQualityReport(Map<String, Object> param);

	List<Map<String, Object>> selectSenseQualityContensts(Map<String, Object> param);

	List<Map<String, Object>> selectSenseQualityInfo(Map<String, Object> param);

	void updateSenseQualityReport(Map<String, Object> param) throws Exception;

	void updateSenseQualityContent(HashMap<String, Object> dataMap) throws Exception;

	void insertSenseQualityContent(HashMap<String, Object> dataMap) throws Exception;

	void deleteSenseQualityAddInfo(Map<String, Object> param) throws Exception;

	Map<String, Object> selectSenseQualityContenstsData(Map<String, Object> param);

	void deleteSenseQualityContenstsData(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int selectMyDataCheck(Map<String, Object> param);

}
