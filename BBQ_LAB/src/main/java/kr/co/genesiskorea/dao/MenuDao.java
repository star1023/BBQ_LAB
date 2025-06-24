package kr.co.genesiskorea.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface MenuDao {

	int selectMenuCount(Map<String, Object> param);

	List<Map<String, Object>> selectMenuList(Map<String, Object> param);
	
	Map<String, Object> selectMenuData(Map<String, Object> param);

	int selectMenuDataCount(Map<String, Object> param);

	Map<String, Object> selectAddInfoCount(Map<String, Object> param);

	List<Map<String, String>> selectAddInfo(Map<String, Object> param);

	List<Map<String, String>> selectImporvePurposeList(Map<String, Object> param);

	List<Map<String, String>> selectNewDataList(Map<String, Object> param);

	List<Map<String, String>> selectMenuMaterial(Map<String, Object> param);

	String selectMenuCode();

	List<Map<String, String>> checkMaterial(Map<String, Object> param);

	List<Map<String, String>> checkErpMaterial(Map<String, Object> param);

	int selectMaterialCount(Map<String, Object> param);

	List<Map<String, String>> selectMaterialList(Map<String, Object> param);

	int selectMenuSeq();

	void insertMenu(Map<String, Object> param) throws Exception;

	void insertAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception;

	void insertMenuNew(ArrayList<HashMap<String, Object>> newList) throws Exception;

	void insertMenuMaterial(Map<String, Object> param) throws Exception;

	void insertFileCopy(HashMap<String, Object> paramMap) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int insertNewVersionCheck(Map<String, Object> param);

	void updateMenuIsLast(Map<String, Object> param) throws Exception;

	void insertNewVersionMenu(Map<String, Object> param) throws Exception;

	void insertMenuImporvePurpose(ArrayList<HashMap<String, Object>> imporvePurList) throws Exception;

	Map<String, Object> selectErpMaterialData(Map<String, Object> param);

	List<Map<String, Object>> selectSearchMenu(Map<String, Object> param);

	Map<String, Object> selectFileData(Map<String, Object> param);

	void deleteFileData(Map<String, Object> param) throws Exception;

	void updateMenuData(Map<String, Object> param) throws Exception;

	void deleteMenuImporvePurpose(HashMap<String, Object> map) throws Exception;

	void deleteAddInfo(HashMap<String, Object> map) throws Exception;

	void deleteMenuNew(HashMap<String, Object> map) throws Exception;

	void deleteMenuMaterial(HashMap<String, Object> map) throws Exception;

	int selectMyDataCheck(Map<String, Object> param);
	
	int selectMyDataCount(Map<String, Object> param);

}
