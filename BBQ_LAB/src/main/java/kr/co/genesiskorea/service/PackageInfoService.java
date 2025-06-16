package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface PackageInfoService {
int insertPackageInfoTmp(Map<String, Object> param, MultipartFile[] file) throws Exception;
	
	int insertPackageInfo(Map<String, Object> param, MultipartFile[] file) throws Exception;

	Map<String, Object> selectPackageInfoList(Map<String, Object> param) throws Exception;

	Map<String, Object> selectPackageInfoData(Map<String, Object> param);

	List<Map<String, Object>> selectAddInfoList(Map<String, Object> param);

	void updatePackageInfoTmp(Map<String, Object> param, MultipartFile[] file) throws Exception;

	void updatePackageInfo(Map<String, Object> param, MultipartFile[] file) throws Exception;

	int insertVersionUpTmp(Map<String, Object> param, MultipartFile[] file) throws Exception;

	int insertVersionUp(Map<String, Object> param, MultipartFile[] file) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int selectMyDataCheck(Map<String, Object> param);
}
