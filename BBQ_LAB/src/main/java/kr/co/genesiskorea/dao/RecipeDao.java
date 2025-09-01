package kr.co.genesiskorea.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface RecipeDao {

	int selectRecipeSeq();

	void insertRecipe(Map<String, Object> param) throws Exception;

	void insertRecipeMaterial(ArrayList<HashMap<String, Object>> matList) throws Exception;

	void insertRecipePurchase(ArrayList<HashMap<String, Object>> newList) throws Exception;

	int selectRecipeCount(Map<String, Object> param);

	List<Map<String, Object>> selectRecipeList(Map<String, Object> param);

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int selectMyDataCheck(Map<String, Object> param);

	Map<String, Object> selectRecipeData(Map<String, Object> param);

	List<Map<String, Object>> selectMaterialList(Map<String, Object> param);

	List<Map<String, Object>> selectPurchaseList(Map<String, Object> param);

	void updateRecipe(Map<String, Object> param) throws Exception;

	void deleteRecipeMaterial(Map<String, Object> param) throws Exception;

	void deleteRecipePurchase(Map<String, Object> param) throws Exception;

	void insertErp(Map<String, Object> paramMap) throws Exception;

	void insertVersionUpRecipe(Map<String, Object> param) throws Exception;

	void updateRecipeIsLast(Map<String, Object> param) throws Exception;

	Map<String, Object> applyErp(List<Map<String, Object>> erpItemList) throws Exception;

	void updateStatus(HashMap<String, Object> paramMap);
	
	int selectRecipeErpMaterialCount(Map<String, Object> param);

	List<Map<String, Object>> selectRecipeErpMaterialList(Map<String, Object> param);

}
