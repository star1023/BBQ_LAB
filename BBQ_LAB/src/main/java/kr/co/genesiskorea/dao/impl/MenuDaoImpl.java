package kr.co.genesiskorea.dao.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.MenuDao;

@Repository
public class MenuDaoImpl implements MenuDao {
	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public int selectMenuCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("menu.selectMenuCount", param);
	}

	@Override
	public List<Map<String, Object>> selectMenuList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("menu.selectMenuList", param);
	}
	
	@Override
	public Map<String, Object> selectMenuData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("menu.selectMenuData", param);
	}

	@Override
	public int selectMenuDataCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("menu.selectMenuDataCount", param);
	}

	@Override
	public Map<String, Object> selectAddInfoCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("menu.selectAddInfoCount", param);
	}

	@Override
	public List<Map<String, String>> selectAddInfo(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("menu.selectAddInfo", param);
	}

	@Override
	public List<Map<String, String>> selectImporvePurposeList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("menu.selectImporvePurposeList", param);
	}

	@Override
	public List<Map<String, String>> selectNewDataList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("menu.selectNewDataList", param);
	}

	@Override
	public List<Map<String, String>> selectMenuMaterial(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("menu.selectMenuMaterial", param);
	}

	@Override
	public String selectMenuCode() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("menu.selectMenuCode");
	}

	@Override
	public List<Map<String, String>> checkMaterial(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("menu.checkMaterial", param);
	}

	@Override
	public List<Map<String, String>> checkErpMaterial(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("menu.checkErpMaterial", param);
	}

	@Override
	public int selectMaterialCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("menu.selectMaterialCount", param);
	}

	@Override
	public List<Map<String, String>> selectMaterialList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("menu.selectMaterialList", param);
	}

	@Override
	public int selectMenuSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("menu.selectMenuSeq");
	}

	@Override
	public void insertMenu(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("menu.insertMenu", param);
	}

	@Override
	public void insertAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("menu.insertAddInfo", addInfoList);
	}

	@Override
	public void insertMenuNew(ArrayList<HashMap<String, Object>> newList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("menu.insertMenuNew", newList);
	}

	@Override
	public void insertMenuMaterial(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("menu.insertMenuMaterial", param);
	}

	@Override
	public void insertFileCopy(HashMap<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("menu.insertFileCopy", param);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("menu.selectHistory", param);
	}

	@Override
	public int insertNewVersionCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("menu.insertNewVersionCheck", param);
	}

	@Override
	public void updateMenuIsLast(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("menu.updateMenuIsLast", param);
	}

	@Override
	public void insertNewVersionMenu(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("menu.insertNewVersionMenu", param);
	}

	@Override
	public void insertMenuImporvePurpose(ArrayList<HashMap<String, Object>> imporvePurList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("menu.insertMenuImporvePurpose", imporvePurList);
	}

	@Override
	public Map<String, Object> selectErpMaterialData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("menu.selectErpMaterialData", param);
	}

	@Override
	public List<Map<String, Object>> selectSearchMenu(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("menu.selectSearchMenu", param);
	}

	@Override
	public Map<String, Object> selectFileData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("menu.selectFileData", param);
	}

	@Override
	public void deleteFileData(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("menu.deleteFileData", param);
	}

	@Override
	public void updateMenuData(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("menu.updateMenuData", param);
	}

	@Override
	public void deleteMenuImporvePurpose(HashMap<String, Object> map) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("menu.deleteMenuImporvePurpose", map);
	}

	@Override
	public void deleteAddInfo(HashMap<String, Object> map) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("menu.deleteAddInfo", map);
	}

	@Override
	public void deleteMenuNew(HashMap<String, Object> map) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("menu.deleteMenuNew", map);
	}

	@Override
	public void deleteMenuMaterial(HashMap<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("menu.deleteMenuMaterial", param);
	}

}
