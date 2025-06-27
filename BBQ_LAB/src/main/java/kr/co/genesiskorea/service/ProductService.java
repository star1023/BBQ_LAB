package kr.co.genesiskorea.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface ProductService {

	String selectProductCode();

	Map<String, Object> selectMaterialList(Map<String, Object> param);

	List<Map<String, Object>> checkMaterial(Map<String, Object> param);

	Map<String, Object> selectProductDataCount(Map<String, Object> param);

	int insertProduct(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	Map<String, Object> selectProductList(Map<String, Object> param)  throws Exception;

	Map<String, Object> selectProductData(Map<String, Object> param);

	List<Map<String, Object>> selectProductMaterial(Map<String, Object> param);

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int insertNewVersionProduct(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	List<Map<String, Object>> checkErpMaterial(Map<String, Object> param);

	Map<String, Object> selectErpMaterialData(Map<String, Object> param);

	int insertNewVersionCheck(Map<String, Object> param);

	Map<String, Object> selectSearchProduct(Map<String, Object> param);

	Map<String, Object> selectFileData(Map<String, Object> param);

	void deleteFileData(Map<String, Object> param) throws Exception;

	void updateProduct(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	int insertTmpProduct(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	List<Map<String, Object>> selectAddInfo(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectNewDataList(Map<String, Object> param);

	void updateProductTmp(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	int insertNewVersionProductTmp(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	List<Map<String, Object>> selectImporvePurposeList(Map<String, Object> param);

	Map<String, Object> selectAddInfoCount(Map<String, Object> param);

	int selectMyDataCheck(Map<String, Object> param);
	
	int selectMyDataCount(Map<String, Object> param);
}
