package kr.co.genesiskorea.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface MenuService {

	Map<String, Object> selectMenuList(Map<String, Object> param) throws Exception;

	Map<String, Object> selectMenuData(Map<String, Object> param);

	Map<String, Object> selectAddInfoCount(Map<String, Object> param);

	List<Map<String, String>> selectAddInfo(Map<String, Object> param);

	List<Map<String, String>> selectImporvePurposeList(Map<String, Object> param);

	List<Map<String, String>> selectNewDataList(Map<String, Object> param);

	Object selectMenuMaterial(Map<String, Object> param);

	String selectMenuCode();

	List<Map<String, String>> checkMaterial(Map<String, Object> param);

	List<Map<String, String>> checkErpMaterial(Map<String, Object> param);

	Map<String, Object> selectMaterialList(Map<String, Object> param);

	Map<String, Object> selectMenuDataCount(Map<String, Object> param);
	
	int insertTmpMenu(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	int insertMenu(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int insertNewVersionCheck(Map<String, Object> param);

	int insertNewVersionMenuTmp(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	int insertNewVersionMenu(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	Map<String, Object> selectErpMaterialData(Map<String, Object> param);

	Map<String, Object> selectSearchMenu(Map<String, Object> param);

	Map<String, Object> selectFileData(Map<String, Object> param);

	void deleteFileData(Map<String, Object> param) throws Exception;

	void updateMenuTmp(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	void updateMenu(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception;

	int selectMyDataCheck(Map<String, Object> param);	

}
