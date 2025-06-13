package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface BusinessTripPlanService {

	Map<String, Object> selectBusinessTripPlanList(Map<String, Object> param) throws Exception;

	int insertBusinessTripPlanTmp(Map<String, Object> param, MultipartFile[] file) throws Exception;

	int insertBusinessTripPlan(Map<String, Object> param, MultipartFile[] file) throws Exception;

	Map<String, Object> selectBusinessTripPlanData(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripPlanUserList(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripPlanAddInfoList(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripPlanContentsList(Map<String, Object> param);
	
	void updateBusinessTripPlanTmp(Map<String, Object> param, MultipartFile[] file) throws Exception;

	void updateBusinessTripPlan(Map<String, Object> param, MultipartFile[] file) throws Exception;

	List<Map<String, Object>> searchBusinessTripPlanList(Map<String, Object> param);

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

}
