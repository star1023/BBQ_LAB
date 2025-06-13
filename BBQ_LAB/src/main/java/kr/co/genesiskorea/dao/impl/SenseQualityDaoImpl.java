package kr.co.genesiskorea.dao.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.SenseQualityDao;

@Repository
public class SenseQualityDaoImpl implements SenseQualityDao {	
	@Autowired
	SqlSessionTemplate sqlSessionTemplate;

	@Override
	public int selectSenseQualityCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("senseQuality.selectSenseQualityCount",param);
	}

	@Override
	public List<Map<String, Object>> selectSenseQualityList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("senseQuality.selectSenseQualityList", param);
	}

	@Override
	public int selectSenseQualitySeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("senseQuality.selectSenseQualitySeq");
	}

	@Override
	public void insertSenseQualityReport(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("senseQuality.insertSenseQualityReport", param);
	}

	@Override
	public void insertSenseQualityContents(ArrayList<HashMap<String, Object>> contentsList) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("senseQuality.insertSenseQualityContents", contentsList);
	}

	@Override
	public void insertSenseQualityAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("senseQuality.insertSenseQualityAddInfo", addInfoList);
	}

	@Override
	public Map<String, Object> selectSenseQualityReport(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("senseQuality.selectSenseQualityReport",param);
	}

	@Override
	public List<Map<String, Object>> selectSenseQualityContensts(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("senseQuality.selectSenseQualityContensts",param);
	}

	@Override
	public List<Map<String, Object>> selectSenseQualityInfo(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("senseQuality.selectSenseQualityInfo",param);
	}

	@Override
	public void updateSenseQualityReport(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("senseQuality.updateSenseQualityReport", param);
	}

	@Override
	public void updateSenseQualityContent(HashMap<String, Object> dataMap) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("senseQuality.updateSenseQualityContent", dataMap);
	}

	@Override
	public void insertSenseQualityContent(HashMap<String, Object> dataMap) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("senseQuality.insertSenseQualityContent", dataMap);
	}

	@Override
	public void deleteSenseQualityAddInfo(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("senseQuality.deleteSenseQualityAddInfo",param);
	}

	@Override
	public Map<String, Object> selectSenseQualityContenstsData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("senseQuality.selectSenseQualityContenstsData",param);
	}

	@Override
	public void deleteSenseQualityContenstsData(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("senseQuality.deleteSenseQualityContenstsData",param);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("senseQuality.selectHistory", param);
	}

}
