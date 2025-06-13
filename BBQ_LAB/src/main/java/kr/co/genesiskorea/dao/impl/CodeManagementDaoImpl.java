package kr.co.genesiskorea.dao.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.CodeManagementDao;

@Repository
public class CodeManagementDaoImpl implements CodeManagementDao {
	
	@Autowired
	SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public List<HashMap<String, Object>> getGroupList() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("code.groupList");
	}

	@Override
	public int groupCount(Map<String, String> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("code.groupCount", param);
	}

	@Override
	public void groupInsert(Map<String, String> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("code.groupInsert", param);
	}

	@Override
	public void groupUpdate(Map<String, String> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("code.groupUpdate", param);
	}

	@Override
	public void groupDelete(Map<String, String> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("code.groupDelete", param);
	}
	
	@Override
	public int groupItemCount(Map<String, String> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("code.groupItemCount", param);
	}

	@Override
	public List<HashMap<String, Object>> getItemList(Map<String, String> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("code.itemList",param);
	}

	@Override
	public int itemCount(Map<String, String> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("code.itemCount", param);
	}

	@Override
	public void itemInsert(Map<String, String> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("code.itemInsert", param);
	}

	@Override
	public void itemUpdate(Map<String, String> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("code.itemUpdate", param);
	}

	@Override
	public void itemOrderUpdate(Map<String, String> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("code.itemOrderUpdate", param);
	}

	@Override
	public void itemDelete(Map<String, String> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("code.itemDelete", param);
	}

	@Override
	public void itemOrderUpDown(Map<String, String> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("code.itemOrderUpDown", param);
	}

	@Override
	public void itemOrderUpdateAjax(Map<String, String> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("code.itemOrderUpdateAjax", param);
	}

}
