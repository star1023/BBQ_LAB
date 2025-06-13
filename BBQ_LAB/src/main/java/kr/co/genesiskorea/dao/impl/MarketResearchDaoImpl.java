package kr.co.genesiskorea.dao.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.MarketResearchDao;

@Repository
public class MarketResearchDaoImpl implements MarketResearchDao {
	@Autowired
	SqlSessionTemplate sqlSessionTemplate;

	@Override
	public int selectMarketResearchCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("marketResearch.selectMarketResearchCount", param);
	}

	@Override
	public List<Map<String, Object>> selectMarketResearchList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("marketResearch.selectMarketResearchList", param);
	}

	@Override
	public int selectMarketResearchSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("marketResearch.selectMarketResearchSeq");
	}

	@Override
	public void insertMarketResearch(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("marketResearch.insertMarketResearch", param);
	}

	@Override
	public void insertMarketResearchAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("marketResearch.insertMarketResearchAddInfo", addInfoList);
	}

	@Override
	public void insertMarketResearchUser(ArrayList<HashMap<String, Object>> userList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("marketResearch.insertMarketResearchUser", userList);
	}

	@Override
	public Map<String, Object> selectMarketResearchData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("marketResearch.selectMarketResearchData",param);
	}

	@Override
	public List<Map<String, Object>> selectMarketResearchUserList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("marketResearch.selectMarketResearchUserList",param);
	}

	@Override
	public List<Map<String, Object>> selectMarketResearchAddInfoList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("marketResearch.selectMarketResearchAddInfoList",param);
	}

	@Override
	public void updateMarketResearch(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("marketResearch.updateMarketResearch", param);
	}

	@Override
	public void deleteMarketResearchAddInfo(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("marketResearch.deleteMarketResearchAddInfo",param);
	}

	@Override
	public void deleteMarketResearchUser(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("marketResearch.deleteMarketResearchUser",param);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("marketResearch.selectHistory", param);
	}
}
