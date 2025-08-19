package kr.co.genesiskorea.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface EtcReportService {

	Map<String, Object> selectEtcList(Map<String, Object> param) throws Exception;

	int insertEtc(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	Map<String, Object> selectEtcData(Map<String, Object> param);

	void updateEtc(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);
	
	int selectMyDataCheck(Map<String, Object> param);

	int insertTmpEtc(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception;

	void deleteEtcReport(Map<String, Object> param) throws Exception;
	
}
