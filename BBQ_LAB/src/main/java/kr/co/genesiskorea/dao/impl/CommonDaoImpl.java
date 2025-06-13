package kr.co.genesiskorea.dao.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class CommonDaoImpl implements kr.co.genesiskorea.dao.CommonDao {

	@Autowired
	SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public List<HashMap<String, String>> getCodeList(HashMap<String, String> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("common.codeList",param);
	}

	@Override
	public List<HashMap<String, Object>> getCompany() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("common.company");
	}

	@Override
	public List<HashMap<String, Object>> getUnit() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("common.unit");
	}

	@Override
	public List<HashMap<String, Object>> getPlant(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("common.plant",param);
	}
	
	@Override
	public void insertFileType(List<HashMap<String, Object>> docTypeList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("common.insertFileType", docTypeList);
	}
	
	@Override
	public void insertHistory(Map<String, Object> historyParam) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("common.insertHistory",historyParam);
	}
	
	@Override
	public void insertFileInfo(Map<String, Object> fileMap) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("common.insertFileInfo",fileMap);
	}
	
	@Override
	public List<Map<String, String>> selectFileList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("common.selectFileList", param);
	}
	
	@Override
	public List<Map<String, String>> selectFileType(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("common.selectFileType", param);
	}
	
	@Override
	public List<Map<String, Object>> categoryList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("common.categoryList", param);
	}

	@Override
	public List<Map<String, Object>> selectCategoryByPId(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("common.selectCategoryByPId", param);
	}

	@Override
	public Map<String, String> selectFileData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("common.selectFileData", param);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("common.selectHistory", param);
	}

	@Override
	public void deleteFileType(HashMap<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("common.deleteFileType", param);
	}

	@Override
	public void insertNotification(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("common.insertNotification", param);
	}

	@Override
	public void insertNotificationHistory(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("common.insertNotificationHistory", param);
	}

	@Override
	public int selectSeq( Map<String, Object> param ) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("common.selectSeq", param);
	}

	@Override
	public List<HashMap<String, Object>> selectNotification(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("common.selectNotification", param);
	}

	@Override
	public void deleteNotification(List<HashMap<String, Object>> notiList) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("common.deleteNotification", notiList);
	}
	
	@Override
	public void deleteFileData(String fileIdx) {
	    sqlSessionTemplate.delete("common.deleteFileData", fileIdx);
	}

	@Override
	public List<Map<String, Object>> getCodeList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("common.codeList",param);
	}

}
