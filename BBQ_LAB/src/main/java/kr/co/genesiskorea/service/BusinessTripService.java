package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface BusinessTripService {

	Map<String, Object> selectBusinessTripList(Map<String, Object> param) throws Exception;

	int insertBusinessTripTmp(Map<String, Object> param, MultipartFile[] file) throws Exception;

	int insertBusinessTrip(Map<String, Object> param, MultipartFile[] file) throws Exception;

	Map<String, Object> selectBusinessTripData(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripUserList(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripAddInfoList(Map<String, Object> param);

	List<Map<String, Object>> selectBusinessTripContentsList(Map<String, Object> param);

	void updateBusinessTripTmp(Map<String, Object> param, MultipartFile[] file) throws Exception;

	void updateBusinessTrip(Map<String, Object> param, MultipartFile[] file) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

}
