package kr.co.genesiskorea.dao;

import java.util.List;
import java.util.Map;

public interface SystemCategoryDao {

	List<Map<String, Object>> selectCategory(Map<String, Object> param);

	Map<String, Object> selectCategoryData(Map<String, Object> param) throws Exception;

	void updateCategoryName(Map<String, Object> param) throws Exception;

	void insertCategory(Map<String, Object> param) throws Exception;

	void deleteCategory(Map<String, Object> param) throws Exception;

	void updateCategoryOrder(Map<String, Object> param) throws Exception;

	Map<String, Object> selectNPCategory(Map<String, Object> param) throws Exception;

	void updateNPCategoryOrder(Map<String, Object> paramMap) throws Exception;

	void updateMyCategoryOrder(Map<String, Object> param) throws Exception;

}
