package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface MaterialService {

	Map<String, Object> selectMaterialList(Map<String, Object> param) throws Exception;

	Map<String, Object> selectMaterialDataCount(Map<String, Object> param);

	String selectmaterialCode();

	void insertMaterial(Map<String, Object> param, List<String> materialType, List<String> fileType,
			List<String> fileTypeText, List<String> docType, List<String> docTypeText, MultipartFile[] file) throws Exception;

	Map<String, Object> selectMaterialData(Map<String, Object> param);

	Map<String, Object> selectErpMaterialList(Map<String, Object> param) throws Exception;

	Map<String, Object> selectErpMaterialData(Map<String, Object> param);

	void insertNewVersion(Map<String, Object> param, List<String> materialType, List<String> fileType,
			List<String> fileTypeText, List<String> docType, List<String> docTypeText, MultipartFile[] file) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	void deleteMaterial(Map<String, Object> param) throws Exception;

	int selectMyDataCheck(Map<String, Object> param);


}
