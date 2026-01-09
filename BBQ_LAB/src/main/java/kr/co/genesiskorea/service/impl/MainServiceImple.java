package kr.co.genesiskorea.service.impl;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.co.genesiskorea.dao.MainDao;
import kr.co.genesiskorea.service.MainService;

@Service
public class MainServiceImple implements MainService {

	@Autowired
	MainDao mainDao;
	
    @Override
    public Map<String, Object> getDocCount(Map<String,Object> param) {
        return mainDao.selectDocCount(param);
    }
    
    @Override
    public Map<String, Object> getDocStatusCount(Map<String,Object> param) {
    	return mainDao.getDocStatusCount(param);
    }
    
    @Override
    public Map<String, Object> getApprStatusCount(Map<String,Object> param) {
    	return mainDao.getApprStatusCount(param);
    }
    
    @Override
    public Map<String, Object> selectTeamDocCount(Map<String,Object> param) {
    	return mainDao.selectTeamDocCount(param);
    }
    
    @Override
    public List<Map<String, Object>> getTeamDocStatusCount(Map<String,Object> param) {
    	return mainDao.getTeamDocStatusCount(param);
    }
    
    @Override
    public List<Map<String, Object>> selectDocCountByTeam(Map<String,Object> param) {
        return mainDao.selectDocCountByTeam(param);
    }
    
    @Override
    public List<Map<String, Object>> selectExecTeams(Map<String, Object> param) {
      return mainDao.selectExecTeams(param);
    }

    @Override
    public Map<String, Object> selectExecAllDocCount(Map<String, Object> param) {
      return mainDao.selectExecAllDocCount(param);
    }

    @Override
    public List<Map<String, Object>> getExecAllTeamDocStatusCount(Map<String, Object> param) {
      return mainDao.getExecAllTeamDocStatusCount(param);
    }


}
