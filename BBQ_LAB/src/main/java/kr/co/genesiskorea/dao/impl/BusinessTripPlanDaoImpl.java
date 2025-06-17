package kr.co.genesiskorea.dao.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.BusinessTripPlanDao;

@Repository
public class BusinessTripPlanDaoImpl implements BusinessTripPlanDao {
	@Autowired
	SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public int selectBusinessTripPlanCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("businessTripPlan.selectBusinessTripPlanCount",param);
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripPlanList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("businessTripPlan.selectBusinessTripPlanList", param);
	}

	@Override
	public int selectTripPlanSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("businessTripPlan.selectTripPlanSeq");
	}

	@Override
	public void insertBusinessTripPlan(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("businessTripPlan.insertBusinessTripPlan", param);
	}

	@Override
	public void insertBusinessTripPlanUser(ArrayList<HashMap<String, Object>> userList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("businessTripPlan.insertBusinessTripPlanUser", userList);
	}

	@Override
	public void insertBusinessTripPlanAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("businessTripPlan.insertBusinessTripPlanAddInfo", addInfoList);
	}

	@Override
	public void insertBusinessTripPlanContents(ArrayList<HashMap<String, Object>> contentList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("businessTripPlan.insertBusinessTripPlanContents", contentList);
	}

	@Override
	public Map<String, Object> selectBusinessTripPlanData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("businessTripPlan.selectBusinessTripPlanData", param);
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripPlanUserList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("businessTripPlan.selectBusinessTripPlanUserList", param);
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripPlanAddInfoList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("businessTripPlan.selectBusinessTripPlanAddInfoList", param);
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripPlanContentsList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("businessTripPlan.selectBusinessTripPlanContentsList", param);
	}

	@Override
	public void updateBusinessTripPlan(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("businessTripPlan.updateBusinessTripPlan", param);
	}

	@Override
	public void deleteBusinessTripPlanUser(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("businessTripPlan.deleteBusinessTripPlanUser", param);
	}

	@Override
	public void deleteBusinessTripPlanAddInfo(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("businessTripPlan.deleteBusinessTripPlanAddInfo", param);
	}

	@Override
	public void deleteBusinessTripPlanContents(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("businessTripPlan.deleteBusinessTripPlanContents", param);
	}

	@Override
	public List<Map<String, Object>> searchBusinessTripPlanList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("businessTripPlan.searchBusinessTripPlanList", param);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("businessTripPlan.selectHistory", param);
	}

	@Override
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("businessTripPlan.selectMyDataCheck", param);
	}

}
