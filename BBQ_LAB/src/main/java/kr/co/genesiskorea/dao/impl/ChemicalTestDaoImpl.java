package kr.co.genesiskorea.dao.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.ChemicalTestDao;

@Repository
public class ChemicalTestDaoImpl implements ChemicalTestDao {
	@Autowired
	SqlSessionTemplate sqlSessionTemplate;

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("chemicalTest.selectHistory", param);
	}

	@Override
	public int selectChemicalTestCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("chemicalTest.selectChemicalTestCount",param);
	}

	@Override
	public List<Map<String, Object>> selectChemicalTestList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("chemicalTest.selectChemicalTestList", param);
	}

	@Override
	public int selectChemicalTestSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("chemicalTest.selectChemicalTestSeq");
	}

	@Override
	public void insertChemicalTest(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("chemicalTest.insertChemicalTest", param);
	}

	@Override
	public void insertChemicalTestItem(ArrayList<HashMap<String, Object>> itemList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("chemicalTest.insertChemicalTestItem", itemList);
	}

	@Override
	public void insertChemicalTestStandard(ArrayList<HashMap<String, Object>> standardList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("chemicalTest.insertChemicalTestStandard", standardList);
	}

	@Override
	public Map<String, Object> selectChemicalTestData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("chemicalTest.selectChemicalTestData", param);
	}

	@Override
	public List<Map<String, Object>> selectChemicalTestItemData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("chemicalTest.selectChemicalTestItemData", param);
	}

	@Override
	public List<Map<String, Object>> selectChemicalTestStandardList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("chemicalTest.selectChemicalTestStandardList", param);
	}

	@Override
	public List<Map<String, Object>> searchChemicalTestList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("chemicalTest.searchChemicalTestList", param);
	}

	@Override
	public void updateChemicalTest(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.selectList("chemicalTest.updateChemicalTest", param);
	}

	@Override
	public void deleteChemicalTestItems(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.selectList("chemicalTest.deleteChemicalTestItems", param);
	}

	@Override
	public void deleteChemicalTestStandards(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.selectList("chemicalTest.deleteChemicalTestStandards", param);
	}

	@Override
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("chemicalTest.selectMyDataCheck", param);
	}

}
