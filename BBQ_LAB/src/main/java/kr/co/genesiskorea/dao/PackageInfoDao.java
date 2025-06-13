package kr.co.genesiskorea.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface PackageInfoDao {
	int selectPackageInfoSeq();

	void insertPackageInfo(Map<String, Object> param) throws Exception;

	void insertPackageInfoAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception;

	int selectPackageInfoCount(Map<String, Object> param);

	List<Map<String, Object>> selectPackageInfoList(Map<String, Object> param);

	Map<String, Object> selectPackageInfoData(Map<String, Object> param);

	List<Map<String, Object>> selectAddInfoList(Map<String, Object> param);

	void updatePackageInfo(Map<String, Object> param) throws Exception;

	void deletePackageInfoAddInfo(Map<String, Object> param) throws Exception;

	void updatePackageInfoIsLast(Map<String, Object> param) throws Exception;

	void insertVersionUp(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);
}
