package kr.co.genesiskorea.dao;

import java.util.List;
import java.util.Map;

public interface FaqDao {
	int selectFaqCount(Map<String, Object> param);

    List<Map<String, Object>> selectFaqList(Map<String, Object> param);

    Map<String, Object> selectFaqData(Map<String, Object> param);
    
    List<Map<String, Object>> selectHistory(Map<String, Object> param);
    
    int selectFaqSeq();
    
    void insertFaq(Map<String, Object> param) throws Exception;
    
    void updateFaq(Map<String, Object> param);
 
    void updateIsDeleteY(Map<String, Object> param);
}
