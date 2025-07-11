package kr.co.genesiskorea.dao.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.PackageInfoDao;

@Repository
public class PackageInfoDaoImpl implements PackageInfoDao {
	@Autowired
	SqlSessionTemplate sqlSessionTemplate;

	@Override
	public int selectPackageInfoSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("package.selectPackageInfoSeq");
	}

	@Override
	public void insertPackageInfo(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("package.insertPackageInfo", param);
	}

	@Override
	public void insertPackageInfoAddInfo(ArrayList<HashMap<String, Object>> addInfoList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("package.insertPackageInfoAddInfo", addInfoList);
	}

	@Override
	public int selectPackageInfoCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("package.selectPackageInfoCount", param);
	}

	@Override
	public List<Map<String, Object>> selectPackageInfoList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("package.selectPackageInfoList", param);
	}

	@Override
	public Map<String, Object> selectPackageInfoData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("package.selectPackageInfoData", param);
	}

	@Override
	public List<Map<String, Object>> selectAddInfoList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("package.selectAddInfoList", param);
	}

	@Override
	public void updatePackageInfo(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("package.updatePackageInfo", param);
	}

	@Override
	public void deletePackageInfoAddInfo(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("package.deletePackageInfoAddInfo", param);
	}

	@Override
	public void updatePackageInfoIsLast(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("package.updatePackageInfoIsLast", param);
	}

	@Override
	public void insertVersionUp(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("package.insertVersionUp", param);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("package.selectHistory", param);
	}

	@Override
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("package.selectMyDataCheck", param);
	}

	@Override
	public Map<String, Object> selectPackageInfoDataByProductCode(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("package.selectPackageInfoDataByProductCode", param);
	}
}
