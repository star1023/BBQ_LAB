package kr.co.genesiskorea.dao.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.SystemCategoryDao;

@Repository
public class SystemCategoryDaoImpl implements SystemCategoryDao {
	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;

	@Override
	public List<Map<String, Object>> selectCategory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("systemCategory.selectCategory", param);
	}

	@Override
	public Map<String, Object> selectCategoryData(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("systemCategory.selectCategoryData", param);
	}

	@Override
	public void updateCategoryName(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("systemCategory.updateCategoryName", param);
	}

	@Override
	public void insertCategory(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("systemCategory.insertCategory", param);
	}

	@Override
	public void deleteCategory(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("systemCategory.deleteCategory", param);
	}

	@Override
	public void updateCategoryOrder(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("systemCategory.updateCategoryOrder", param);
	}

	@Override
	public Map<String, Object> selectNPCategory(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("systemCategory.selectNPCategory", param);
	}

	@Override
	public void updateNPCategoryOrder(Map<String, Object> paramMap) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("systemCategory.updateNPCategoryOrder", paramMap);
	}

	@Override
	public void updateMyCategoryOrder(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("systemCategory.updateMyCategoryOrder", param);
	}
}
