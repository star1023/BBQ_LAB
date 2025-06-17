package kr.co.genesiskorea.dao;

import java.util.List;
import java.util.Map;

public interface MaterialDao {

	int selectMaterialCount(Map<String, Object> param);

	List<Map<String, Object>> selectMaterialList(Map<String, Object> param);

	int selectMaterialDataCount(Map<String, Object> param);

	String selectmaterialCode();

	int selectMaterialSeq();

	void insertMaterial(Map<String, Object> param) throws Exception;

	Map<String, String> selectMaterialData(Map<String, Object> param);

	int selectErpMaterialCount(Map<String, Object> param);

	List<Map<String, Object>> selectErpMaterialList(Map<String, Object> param);

	Map<String, Object> selectErpMaterialData(Map<String, Object> param);

	void updateMaterial(Map<String, Object> param) throws Exception;

	void insertNewVersion(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	void deleteMaterial(Map<String, Object> param) throws Exception;

	int selectMyDataCheck(Map<String, Object> param);


}
