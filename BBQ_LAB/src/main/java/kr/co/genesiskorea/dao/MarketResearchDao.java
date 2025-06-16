package kr.co.genesiskorea.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface MarketResearchDao {

	int selectMarketResearchCount(Map<String, Object> param);

	List<Map<String, Object>> selectMarketResearchList(Map<String, Object> param);

	int selectMarketResearchSeq();

	void insertMarketResearch(Map<String, Object> param) throws Exception;

	void insertMarketResearchAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception;

	void insertMarketResearchUser(ArrayList<HashMap<String, Object>> userList) throws Exception;

	Map<String, Object> selectMarketResearchData(Map<String, Object> param);

	List<Map<String, Object>> selectMarketResearchUserList(Map<String, Object> param);

	List<Map<String, Object>> selectMarketResearchAddInfoList(Map<String, Object> param);

	void updateMarketResearch(Map<String, Object> param) throws Exception;

	void deleteMarketResearchAddInfo(Map<String, Object> param) throws Exception;

	void deleteMarketResearchUser(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int selectMyDataCheck(Map<String, Object> param);

}
