package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

public interface ApprovalService {
	List<Map<String, Object>> searchUser(Map<String, Object> param);

	void insertApprLine(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectApprovalLine(Map<String, Object> param);

	List<Map<String, Object>> selectApprovalLineItem(Map<String, Object> param);

	void deleteApprLine(Map<String, Object> param) throws Exception;

	void insertAppr(Map<String, Object> param) throws Exception;

	Map<String, Object> selectList(Map<String, Object> param) throws Exception;

	Map<String, Object> selectMyApprList(Map<String, Object> param) throws Exception;

	Map<String, Object> selectMyRefList(Map<String, Object> param) throws Exception;

	Map<String, Object> selectMyCompList(Map<String, Object> param) throws Exception;

	Map<String, String> cancelAppr(Map<String, Object> param) throws Exception;

	Map<String, String> reAppr(Map<String, Object> param) throws Exception;

	Map<String, Object> selectApprHeaderData(Map<String, Object> param);

	List<Map<String, Object>> selectApprItemList(Map<String, Object> param);

	List<Map<String, Object>> selectReferenceList(Map<String, Object> param);

	Map<String, String> approvalSubmit(Map<String, Object> param) throws Exception;

	Map<String, String> approvalCondSubmit(Map<String, Object> param) throws Exception;
	
	Map<String, String> approvalReject(Map<String, Object> param) throws Exception;

	Map<String, Object> selectApprItem(Map<String, Object> param);	
}
