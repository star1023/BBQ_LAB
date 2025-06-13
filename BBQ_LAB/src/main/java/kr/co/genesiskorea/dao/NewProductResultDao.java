package kr.co.genesiskorea.dao;

import java.util.List;
import java.util.Map;

public interface NewProductResultDao {

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int selectNewProductResultCount(Map<String, Object> param);

	List<Map<String, Object>> selectNewProductResultList(Map<String, Object> param);

	List<Map<String, Object>> searchNewProductResultListAjax(Map<String, Object> param);

	int selectNewProductResultSeq();

	void insertNewProductResult(Map<String, Object> param) throws Exception;

	void insertNewProductResultItems(List<Map<String, Object>> itemList) throws Exception;

	void insertNewProductResultItemImage(List<Map<String, Object>> imageMetaList) throws Exception;

	Map<String, Object> selectNewProductResultData(Map<String, Object> param);

	List<Map<String, Object>> selectNewProductResultItemList(Map<String, Object> param);

	List<Map<String, Object>> selectNewProductResultItemImageList(Map<String, Object> param);

	void updateNewProductResult(Map<String, Object> param) throws Exception;

	void deleteNewProductResultItems(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectNewProductResultItemImages(Map<String, Object> param);

	void deleteNewProductResultItemImageByRow(Map<String, Object> deleteParam) throws Exception;

}
