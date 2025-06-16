package kr.co.genesiskorea.dao.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.DesignReportDao;

@Repository
public class DesignReportDaoImpl implements DesignReportDao {
	@Autowired
	SqlSessionTemplate sqlSessionTemplate;

	@Override
	public int selectDesignCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("designReport.selectDesignCount",param);
	}

	@Override
	public List<Map<String, Object>> selectDesignList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("designReport.selectDesignList", param);
	}

	@Override
	public int selectDesignSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("designReport.selectDesignSeq");
	}

	@Override
	public void insertDesign(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("designReport.insertDesign", param);
	}

	@Override
	public void insertChangeList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("designReport.insertChangeList", param);
	}

	@Override
	public Map<String, Object> selectDesignData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("designReport.selectDesignData", param);
	}

	@Override
	public List<Map<String, Object>> selectDesignChangeList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("designReport.selectDesignChangeList", param);
	}

	@Override
	public void updateDesign(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("designReport.updateDesign", param);
	}

	@Override
	public void deleteChangeList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("designReport.deleteChangeList", param);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("designReport.selectHistory", param);
	}

	@Override
	public void insertAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("designReport.insertAddInfo", addInfoList);
	}

	@Override
	public List<Map<String, Object>> selectAddInfoList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("designReport.selectAddInfoList", param);
	}

	@Override
	public void deleteAddInfo(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("designReport.deleteAddInfo", param);
	}

	@Override
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("designReport.selectMyDataCheck", param);
	}

}
