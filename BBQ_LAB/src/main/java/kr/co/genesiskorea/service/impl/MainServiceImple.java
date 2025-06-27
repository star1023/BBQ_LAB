package kr.co.genesiskorea.service.impl;

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

}
