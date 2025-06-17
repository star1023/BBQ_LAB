package kr.co.genesiskorea.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface BusinessTripPlanDao {

	int selectBusinessTripPlanCount(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripPlanList(Map<String, Object> param);

	int selectTripPlanSeq();

	void insertBusinessTripPlan(Map<String, Object> param) throws Exception;

	void insertBusinessTripPlanUser(ArrayList<HashMap<String, Object>> userList) throws Exception;

	void insertBusinessTripPlanAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception;

	void insertBusinessTripPlanContents(ArrayList<HashMap<String, Object>> contentList) throws Exception;

	Map<String, Object> selectBusinessTripPlanData(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripPlanUserList(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripPlanAddInfoList(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripPlanContentsList(Map<String, Object> param);

	void updateBusinessTripPlan(Map<String, Object> param) throws Exception;

	void deleteBusinessTripPlanUser(Map<String, Object> param) throws Exception;

	void deleteBusinessTripPlanAddInfo(Map<String, Object> param) throws Exception;

	void deleteBusinessTripPlanContents(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> searchBusinessTripPlanList(Map<String, Object> param);

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int selectMyDataCheck(Map<String, Object> param);

}
