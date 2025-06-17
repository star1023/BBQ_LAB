package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface NewProductResultService {

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	Map<String, Object> selectNewProductResultList(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> searchNewProductResultListAjax(Map<String, Object> param);

	int insertNewProductResult(Map<String, Object> param, List<List<Map<String, Object>>> resultItemArr,
			List<Map<String, Object>> itemImageArr, List<MultipartFile> imageFiles, MultipartFile[] file) throws Exception;

	List<Map<String, Object>> selectNewProductResultItemList(Map<String, Object> param);

	List<Map<String, Object>> selectNewProductResultItemImageList(Map<String, Object> param);

	int updateNewProductResult(Map<String, Object> param, List<List<Map<String, Object>>> resultItemArr,
			List<Map<String, Object>> itemImageArr, MultipartFile[] file, List<MultipartFile> imageFiles,
			List<String> deletedFiles) throws Exception;

	Map<String, Object> selectNewProductResultData(Map<String, Object> param);

	int selectMyDataCheck(Map<String, Object> param);

}
