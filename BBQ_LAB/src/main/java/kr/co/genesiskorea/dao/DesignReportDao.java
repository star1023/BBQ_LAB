package kr.co.genesiskorea.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface DesignReportDao {

	int selectDesignCount(Map<String, Object> param);

	List<Map<String, Object>> selectDesignList(Map<String, Object> param);

	int selectDesignSeq();

	void insertDesign(Map<String, Object> param) throws Exception;

	void insertChangeList(Map<String, Object> param) throws Exception;

	Map<String, Object> selectDesignData(Map<String, Object> param);

	List<Map<String, Object>> selectDesignChangeList(Map<String, Object> param);

	void updateDesign(Map<String, Object> param) throws Exception;

	void deleteChangeList(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	void insertAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception;

	List<Map<String, Object>> selectAddInfoList(Map<String, Object> param);

	void deleteAddInfo(Map<String, Object> param) throws Exception;

}
