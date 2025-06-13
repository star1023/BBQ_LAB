package kr.co.genesiskorea.dao.impl;

import java.util.List;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.co.genesiskorea.dao.ApprovalDao;
import kr.co.genesiskorea.service.impl.ApprovalServiceImpl;

@Repository
public class ApprovalDaoImpl implements ApprovalDao {
	private Logger logger = LogManager.getLogger(ApprovalDaoImpl.class);
	
	@Autowired
	SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public List<Map<String, Object>> searchUser(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("approval.searchUser", param);
	}

	@Override
	public int selectLineSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("approval.selectLineSeq");
	}

	@Override
	public void insertApprLine(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("approval.insertApprLine", param);
	}

	@Override
	public void insertApprLineItem(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("approval.insertApprLineItem", param);
	}

	@Override
	public List<Map<String, Object>> selectApprovalLine(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("approval.selectApprovalLine", param);
	}

	@Override
	public List<Map<String, Object>> selectApprovalLineItem(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("approval.selectApprovalLineItem", param);
	}

	@Override
	public void deleteApprLine(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("approval.deleteApprLine", param);
	}

	@Override
	public int selectApprSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("approval.selectApprSeq");
	}

	@Override
	public void insertApprHeader(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("approval.insertApprHeader",param);
	}

	@Override
	public void insertApprItem(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("approval.insertApprItem",param);
	}

	@Override
	public void insertReference(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("approval.insertReference",param);
	}

	@Override
	public void updateStatus(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("approval.updateStatus", param);
	}

	@Override
	public int selectTotalCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("approval.selectTotalCount", param);
	}

	@Override
	public List<Map<String, Object>> selectApprovalList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("approval.selectApprovalList", param);
	}

	@Override
	public int selectMyApprTotalCount(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("approval.selectMyApprTotalCount", param);
	}

	@Override
	public List<Map<String, Object>> selectMyApprList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("approval.selectMyApprList", param);
	}

	@Override
	public int selectMyRefTotalCount(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("approval.selectMyRefTotalCount", param);
	}

	@Override
	public List<Map<String, Object>> selectMyRefList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("approval.selectMyRefList", param);
	}

	@Override
	public int selectMyCompTotalCount(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("approval.selectMyCompTotalCount", param);
	}

	@Override
	public List<Map<String, Object>> selectMyCompList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("approval.selectMyCompList", param);
	}

	@Override
	public Map<String, Object> selectApprHeaderData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("approval.selectApprHeaderData", param);
	}

	@Override
	public void updateApprStatus(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("approval.updateApprStatus", param);
	}

	@Override
	public void updateDocStatus(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("approval.updateDocStatus", param);
	}

	@Override
	public Map<String, String> selectDocData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("approval.selectDocData", param);
	}

	@Override
	public List<Map<String, Object>> selectApprItemList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("approval.selectApprItemList", param);
	}

	@Override
	public List<Map<String, Object>> selectReferenceList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("approval.selectReferenceList", param);
	}

	@Override
	public void approvalSubmitItem(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("approval.approvalSubmitItem", param);
	}

	@Override
	public Map<String, Object> selectNextApprItem(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("approval.selectNextApprItem", param);
	}

	@Override
	public void updateApprUser(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("approval.updateApprUser", param);
	}

	@Override
	public Map<String, Object> selectApprItem(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("approval.selectApprItem", param);
	}

	@Override
	public void deleteApprItem(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("approval.deleteApprItem", param);
	}

	@Override
	public void deleteApprHeader(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("approval.deleteApprHeader", param);
	}

	@Override
	public void deleteApprReference(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("approval.deleteApprReference", param);
	}	
}
