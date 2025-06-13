package kr.co.genesiskorea.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface DesignReportService {

	Map<String, Object> selectDesignList(Map<String, Object> param) throws Exception;

	int insertDesign(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	Map<String, Object> selectDesignData(Map<String, Object> param);

	List<Map<String, Object>> selectDesignChangeList(Map<String, Object> param);

	void updateDesign(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	List<Map<String, Object>> selectAddInfoList(Map<String, Object> param);

}
