package kr.co.genesiskorea.dao.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.BusinessTripDao;

@Repository
public class BusinessTripDaoImpl implements BusinessTripDao {
	@Autowired
	SqlSessionTemplate sqlSessionTemplate;

	@Override
	public int selectBusinessTripCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("businessTrip.selectBusinessTripCount",param);
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("businessTrip.selectBusinessTripList", param);
	}

	@Override
	public int selectTripSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("businessTrip.selectTripSeq");
	}

	@Override
	public void insertBusinessTrip(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("businessTrip.insertBusinessTrip", param);
	}

	@Override
	public void insertBusinessTripUser(ArrayList<HashMap<String, Object>> userList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("businessTrip.insertBusinessTripUser", userList);
	}

	@Override
	public void insertBusinessTripAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("businessTrip.insertBusinessTripAddInfo", addInfoList);
	}

	@Override
	public void insertBusinessTripContents(ArrayList<HashMap<String, Object>> contentList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("businessTrip.insertBusinessTripContents", contentList);
	}

	@Override
	public Map<String, Object> selectBusinessTripData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("businessTrip.selectBusinessTripData", param);
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripUserList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("businessTrip.selectBusinessTripUserList", param);
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripAddInfoList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("businessTrip.selectBusinessTripAddInfoList", param);
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripContentsList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("businessTrip.selectBusinessTripContentsList", param);
	}

	@Override
	public void updateBusinessTrip(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("businessTrip.updateBusinessTrip", param);
	}

	@Override
	public void deleteBusinessTripUser(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("businessTrip.deleteBusinessTripUser", param);
	}

	@Override
	public void deleteBusinessTripAddInfo(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("businessTrip.deleteBusinessTripAddInfo", param);
	}

	@Override
	public void deleteBusinessTripContents(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("businessTrip.deleteBusinessTripContents", param);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("businessTrip.selectHistory", param);
	}
}
