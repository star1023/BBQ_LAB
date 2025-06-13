package kr.co.genesiskorea.dao.impl;

import java.util.HashMap;
import java.util.List;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.TestDao;

@Repository
public class TestDaoImpl implements TestDao {

	@Autowired(required=true)
	private SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public List<HashMap<String,Object>> selectUser(HashMap<String, Object> map) throws Exception {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("test.selectUser",map);
	}

	public void insertTest1(HashMap<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("test.insertTest1", param);
	}

	public void insertTest2(HashMap<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("test.insertTest2", param);
	}
	
}
