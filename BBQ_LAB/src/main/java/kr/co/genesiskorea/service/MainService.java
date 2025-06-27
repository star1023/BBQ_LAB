package kr.co.genesiskorea.service;

import java.util.Map;

public interface MainService {

	Map<String, Object> getDocCount(Map<String,Object> param);
	
	Map<String, Object> getDocStatusCount(Map<String,Object> param);
	
	Map<String, Object> getApprStatusCount(Map<String,Object> param);
	
}
