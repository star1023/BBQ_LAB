package kr.co.genesiskorea.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface BusinessTripDao {

	int selectBusinessTripCount(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripList(Map<String, Object> param);

	int selectTripSeq();

	void insertBusinessTrip(Map<String, Object> param) throws Exception;

	void insertBusinessTripUser(ArrayList<HashMap<String, Object>> userList) throws Exception;

	void insertBusinessTripAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception;

	void insertBusinessTripContents(ArrayList<HashMap<String, Object>> contentList) throws Exception;

	Map<String, Object> selectBusinessTripData(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripUserList(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripAddInfoList(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripContentsList(Map<String, Object> param);

	void updateBusinessTrip(Map<String, Object> param) throws Exception;

	void deleteBusinessTripUser(Map<String, Object> param) throws Exception;

	void deleteBusinessTripAddInfo(Map<String, Object> param) throws Exception;

	void deleteBusinessTripContents(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

}
