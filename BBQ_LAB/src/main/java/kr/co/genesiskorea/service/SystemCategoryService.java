package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

public interface SystemCategoryService {

	List<Map<String, Object>> selectCategory(Map<String, Object> param);

	void insertCategory(Map<String, Object> param) throws Exception;

	void deleteCategory(Map<String, Object> param) throws Exception;

	void updateCategory(Map<String, Object> param) throws Exception;

	Map<String, String> updateMoveCategory(Map<String, Object> param) throws Exception;

}
