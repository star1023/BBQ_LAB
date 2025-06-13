package kr.co.genesiskorea.dao.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.ManualDao;

@Repository
public class ManualDaoImpl implements ManualDao {
	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public int selectManualCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("manual.selectManualCount", param);
	}

	@Override
	public List<Map<String, Object>> selectManualList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("manual.selectManualList", param);
	}

	@Override
	public void uploadManual(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("manual.uploadManual", param);
	}

	@Override
	public List<Map<String, Object>> selectManualFileList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("manual.selectManualFileList", param);
	}

	@Override
	public void insertManual(Map<String, Object> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("manual.insertManual", param);
	}
}
