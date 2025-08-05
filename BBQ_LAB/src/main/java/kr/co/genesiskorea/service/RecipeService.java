package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

public interface RecipeService {
	
	Map<String, Object> selectRecipeList(Map<String, Object> param) throws Exception;

	int insertTmpRecipe(Map<String, Object> param) throws Exception;

	int insertRecipe(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int selectMyDataCheck(Map<String, Object> param);

	Map<String, Object> selectRecipeData(Map<String, Object> param);

	List<Map<String, Object>> selectMaterialList(Map<String, Object> param);

	List<Map<String, Object>> selectPurchaseList(Map<String, Object> param);

	void updateTmpRecipe(Map<String, Object> param) throws Exception;

	void updateRecipe(Map<String, Object> param) throws Exception;

	Map<String, Object> insertErp(Map<String, Object> param);

	int versionUpTmpRecipe(Map<String, Object> param) throws Exception;

	int versionUpRecipe(Map<String, Object> param) throws Exception;

	Map<String, Object> applyErp(Map<String, Object> param);	

}
