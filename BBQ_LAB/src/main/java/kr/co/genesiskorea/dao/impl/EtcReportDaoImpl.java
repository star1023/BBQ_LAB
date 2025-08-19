package kr.co.genesiskorea.dao.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.EtcReportDao;

@Repository
public class EtcReportDaoImpl implements EtcReportDao {

	@Autowired
	SqlSessionTemplate sqlSessionTemplate;

	@Override
	public int selectEtcCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("etcReport.selectEtcCount",param);
	}

	@Override
	public List<Map<String, Object>> selectEtcList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("etcReport.selectEtcList", param);
	}

	@Override
	public int selectEtcSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("etcReport.selectEtcSeq");
	}

	@Override
	public void insertEtc(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("etcReport.insertEtc", param);
	}

	@Override
	public Map<String, Object> selectEtcData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("etcReport.selectEtcData", param);
	}

	@Override
	public void updateEtc(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("etcReport.updateEtc", param);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("etcReport.selectHistory", param);
	}

	@Override
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("etcReport.selectMyDataCheck", param);
	}

	@Override
	public void deleteEtcReport(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("etcReport.deleteEtcReport", param);
	}
}
