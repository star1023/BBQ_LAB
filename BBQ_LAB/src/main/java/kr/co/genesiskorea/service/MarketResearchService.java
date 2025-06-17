package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface MarketResearchService {

	Map<String, Object> selectMarketResearchList(Map<String, Object> param) throws Exception;

	int insertMarketResearchTmp(Map<String, Object> param, MultipartFile[] file) throws Exception;

	int insertMarketResearch(Map<String, Object> param, MultipartFile[] file) throws Exception;

	Map<String, Object> selectMarketResearchData(Map<String, Object> param);

	List<Map<String, Object>> selectMarketResearchUserList(Map<String, Object> param);

	List<Map<String, Object>> selectMarketResearchAddInfoList(Map<String, Object> param);

	void updateMarketResearchTmp(Map<String, Object> param, MultipartFile[] file) throws Exception;

	void updateMarketResearch(Map<String, Object> param, MultipartFile[] file) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int selectMyDataCheck(Map<String, Object> param);

}
