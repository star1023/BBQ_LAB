package kr.co.genesiskorea.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface ProductDao {

	String selectProductCode();

	List<Map<String, String>> selectMaterialList(Map<String, Object> param);

	int selectMaterialCount(Map<String, Object> param);

	List<Map<String, Object>> checkMaterial(Map<String, Object> param);

	int selectProductDataCount(Map<String, Object> param);

	int selectProductSeq();

	void insertProduct(Map<String, Object> param) throws Exception;

	void insertProductMaterial(Map<String, Object> param) throws Exception;

	int selectProductCount(Map<String, Object> param);

	List<Map<String, Object>> selectProductList(Map<String, Object> param);

	Map<String, Object> selectProductData(Map<String, Object> param);

	List<Map<String, Object>> selectProductMaterial(Map<String, Object> param);

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	void updateProductIsLast(Map<String, Object> param) throws Exception;

	void insertNewVersionProduct(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> checkErpMaterial(Map<String, Object> param);

	Map<String, Object> selectErpMaterialData(Map<String, Object> param);

	int insertNewVersionCheck(Map<String, Object> param);

	List<Map<String, Object>> selectSearchProduct(Map<String, Object> param);

	void insertFileCopy(HashMap<String, Object> paramMap) throws Exception;

	Map<String, Object> selectFileData(Map<String, Object> param);

	void deleteFileData(Map<String, Object> param) throws Exception;

	void deleteProductMaterial(Map<String, Object> param) throws Exception;

	void deleteFileType(HashMap<String, Object> map) throws Exception;

	void updateProductData(Map<String, Object> param) throws Exception;

	void insertAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception;

	List<Map<String, Object>> selectAddInfo(Map<String, Object> param);

	void insertProductNew(ArrayList<HashMap<String, Object>> newList) throws Exception;

	List<Map<String, Object>> selectNewDataList(Map<String, Object> param);

	void deleteAddInfo(HashMap<String, Object> map) throws Exception;

	void deleteProductNew(HashMap<String, Object> map) throws Exception;

	void insertProductImporvePurpose(ArrayList<HashMap<String, Object>> imporvePurList) throws Exception;

	List<Map<String, Object>> selectImporvePurposeList(Map<String, Object> param);

	Map<String, Object> selectAddInfoCount(Map<String, Object> param);

	void deleteProductImporvePurpose(HashMap<String, Object> map) throws Exception;

	int selectMyDataCheck(Map<String, Object> param);
}
