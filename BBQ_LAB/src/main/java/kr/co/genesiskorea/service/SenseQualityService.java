package kr.co.genesiskorea.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface SenseQualityService {

	Map<String, Object> selectSenseQualityList(Map<String, Object> param) throws Exception;

	int insertSenseQualityTmp(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	int insertSenseQuality(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	Map<String, Object> selectSenseQualityData(Map<String, Object> param);

	void updateSenseQualityTmp(Map<String, Object> param, HashMap<String, Object> dataListMap,
			HashMap<String, Object> fileMap, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	void updateSenseQuality(Map<String, Object> param, HashMap<String, Object> dataListMap,
			HashMap<String, Object> fileMap, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	void deleteSenseQualityContenstsData(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

}
