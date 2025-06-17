package kr.co.genesiskorea.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface ChemicalTestService {

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	Map<String, Object> selectChemicalTestList(Map<String, Object> param) throws Exception;

	int insertChemicalTest(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file,
			MultipartFile imageFile) throws Exception;

	Map<String, Object> selectChemicalTestData(Map<String, Object> param);

	List<Map<String, Object>> selectChemicalTestItemList(Map<String, Object> param);

	List<Map<String, Object>> selectChemicalTestStandardList(Map<String, Object> param);

	List<Map<String, Object>> searchChemicalTestList(Map<String, Object> param);

	void updateChemicalTest(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file,
			MultipartFile imageFile) throws Exception;

	int selectMyDataCheck(Map<String, Object> param);

}
