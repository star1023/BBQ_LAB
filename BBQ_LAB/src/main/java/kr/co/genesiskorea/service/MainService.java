package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

public interface MainService {

	Map<String, Object> getDocCount(Map<String,Object> param);
	
	Map<String, Object> getDocStatusCount(Map<String,Object> param);
	
	Map<String, Object> getApprStatusCount(Map<String,Object> param);
	
	Map<String, Object> selectTeamDocCount(Map<String,Object> param);
	
	List<Map<String, Object>> getTeamDocStatusCount(Map<String,Object> param);
	
	List<Map<String,Object>> selectDocCountByTeam(Map<String,Object> param);

    List<Map<String,Object>> selectExecTeams(Map<String,Object> param);
    
    Map<String,Object> selectExecAllDocCount(Map<String,Object> param);
    
    List<Map<String,Object>> getExecAllTeamDocStatusCount(Map<String,Object> param);
}
