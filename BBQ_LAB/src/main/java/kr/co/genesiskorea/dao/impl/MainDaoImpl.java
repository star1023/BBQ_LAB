package kr.co.genesiskorea.dao.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.MainDao;

@Repository
public class MainDaoImpl implements MainDao {

	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public Map<String, Object> selectDocCount(Map<String,Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("main.selectDocCount", param);
	}
	
	@Override
	public Map<String, Object> getDocStatusCount(Map<String,Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("main.getDocStatusCount", param);
	}
	
	@Override
	public Map<String, Object> getApprStatusCount(Map<String,Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("main.getApprStatusCount", param);
	}

}
