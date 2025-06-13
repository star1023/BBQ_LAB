package kr.co.genesiskorea.dao.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.MaterialDao;

@Repository
public class MaterialDaoImpl implements MaterialDao {
	
	@Autowired
	SqlSessionTemplate sqlSessionTemplate;

	@Override
	public int selectMaterialCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("material.selectMaterialCount", param);
	}

	@Override
	public List<Map<String, Object>> selectMaterialList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("material.selectMaterialList", param);
	}

	@Override
	public int selectMaterialDataCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("material.selectMaterialDataCount", param);
	}

	@Override
	public String selectmaterialCode() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("material.selectmaterialCode");
	}

	@Override
	public int selectMaterialSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("material.selectMaterialSeq");
	}

	@Override
	public void insertMaterial(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("material.insertMaterial",param);
	}

	@Override
	public Map<String, String> selectMaterialData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("material.selectMaterialData", param);
	}

	@Override
	public int selectErpMaterialCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("material.selectErpMaterialCount", param);
	}

	@Override
	public List<Map<String, Object>> selectErpMaterialList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("material.selectErpMaterialList", param);
	}

	@Override
	public Map<String, Object> selectErpMaterialData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("material.selectErpMaterialData", param);
	}

	@Override
	public void updateMaterial(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("material.updateMaterial",param);
	}

	@Override
	public void insertNewVersion(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("material.insertNewVersion",param);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("material.selectHistory", param);
	}

	@Override
	public void deleteMaterial(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("material.deleteMaterial",param);
	}
	
}
