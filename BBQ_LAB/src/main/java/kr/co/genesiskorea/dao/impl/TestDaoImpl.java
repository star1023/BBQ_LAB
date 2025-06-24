package kr.co.genesiskorea.dao.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.TestDao;

@Repository
public class TestDaoImpl implements TestDao {

	@Autowired(required=true)
	@Qualifier("sqlSessionTemplate")
	private SqlSessionTemplate sqlSessionTemplate;
	
	@Autowired(required=true)
	@Qualifier("sqlSessionTemplateMSSQL")
	private SqlSessionTemplate sqlSessionTemplateMSSQL;
	
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

	public List<Map<String, Object>> selectOrg() {
		// TODO Auto-generated method stub
		return sqlSessionTemplateMSSQL.selectList("test.selectOrg");
	}

	public List<Map<String, Object>> selectHrInfo() {
		// TODO Auto-generated method stub
		return sqlSessionTemplateMSSQL.selectList("test.selectHrInfo");
	}

	public List<Map<String, Object>> selectMasterCode() {
		// TODO Auto-generated method stub
		return sqlSessionTemplateMSSQL.selectList("test.selectMasterCode");
	}

	public void insertOrg(List<Map<String, Object>> dataList) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("test.insertOrg", dataList);
	}

	public void insertHrInfo(List<Map<String, Object>> dataList) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("test.insertHrInfo", dataList);
	}

	public void insertMasterCode(List<Map<String, Object>> dataList) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("test.insertMasterCode", dataList);
	}
	
}
