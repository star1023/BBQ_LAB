package kr.co.genesiskorea.dao;

import java.util.Map;

public interface MainDao {
    Map<String, Object> selectDocCount(Map<String,Object> param);
    
    Map<String, Object> getDocStatusCount(Map<String,Object> param);
    
    Map<String, Object> getApprStatusCount(Map<String,Object> param);
}