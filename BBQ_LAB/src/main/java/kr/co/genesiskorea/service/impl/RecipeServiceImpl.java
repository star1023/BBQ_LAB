package kr.co.genesiskorea.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;

import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.dao.RecipeDao;
import kr.co.genesiskorea.service.RecipeService;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class RecipeServiceImpl implements RecipeService {
	private Logger logger = LogManager.getLogger(RecipeServiceImpl.class);

	@Autowired
	RecipeDao recipeDao;
	
	@Autowired
	CommonDao commonDao;
	
	@Resource
	DataSourceTransactionManager txManager;
	
	@Override
	public Map<String, Object> selectRecipeList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		int totalCount = recipeDao.selectRecipeCount(param);
		
		int viewCount = 10;
		int pageNo = 1;
		try {
			pageNo = Integer.parseInt((String)param.get("pageNo"));
		} catch( Exception e ) {
			System.err.println(e.getMessage());
			pageNo = 1;
		}
		
		// 페이징: 페이징 정보 SET
		PageNavigator navi = new PageNavigator(param, viewCount, totalCount);
		List<Map<String, Object>> recipeList = recipeDao.selectRecipeList(param);		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", recipeList);	
		map.put("navi", navi);
		return map;
	}
	
	@Override
	public int insertTmpRecipe(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		int recipeIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			JSONParser parser = new JSONParser();
			JSONArray matItemSapCode = (JSONArray) parser.parse((String)param.get("matItemSapCodeArr"));
			JSONArray matItemName = (JSONArray) parser.parse((String)param.get("matItemNameArr"));
			JSONArray matItemCompCount = (JSONArray) parser.parse((String)param.get("matItemCompCountArr"));
			JSONArray matItemCompUnit = (JSONArray) parser.parse((String)param.get("matItemCompUnitArr"));
			JSONArray matItemUseCount = (JSONArray) parser.parse((String)param.get("matItemUseCountArr"));
			JSONArray matItemUseUnit = (JSONArray) parser.parse((String)param.get("matItemUseUnitArr"));
			
			JSONArray newItemName = (JSONArray) parser.parse((String)param.get("newItemNameArr"));
			JSONArray newItemCompCount = (JSONArray) parser.parse((String)param.get("newItemCompCountArr"));
			JSONArray newItemCompUnit = (JSONArray) parser.parse((String)param.get("newItemCompUnitArr"));
			JSONArray newItemUseCount = (JSONArray) parser.parse((String)param.get("newItemUseCountArr"));
			JSONArray newItemUseUnit = (JSONArray) parser.parse((String)param.get("newItemUseUnitArr"));
			JSONArray newItemPrice = (JSONArray) parser.parse((String)param.get("newItemPriceArr"));
			JSONArray newItemDesc = (JSONArray) parser.parse((String)param.get("newItemDescArr"));
			
			recipeIdx = recipeDao.selectRecipeSeq(); 	//key value 조
			param.put("idx", recipeIdx);
			
			recipeDao.insertRecipe(param);
			
			ArrayList<HashMap<String,Object>> matList = new ArrayList<HashMap<String,Object>>();
			if( matItemSapCode != null && matItemSapCode.size() > 0 ) {
				for( int i = 0 ; i < matItemSapCode.size() ; i++ ) {
					HashMap<String,Object> matData = new HashMap<String,Object>();
					matData.put("idx", recipeIdx);
					matData.put("no", (i*10)+10);
					try{
						matData.put("sapCode", matItemSapCode.get(i));
					} catch(Exception e) {
						matData.put("sapCode", "");
					}
					try{
						matData.put("productName", matItemName.get(i));
					} catch(Exception e) {
						matData.put("productName", "");
					}
					try{
						matData.put("compCount", matItemCompCount.get(i));
					} catch(Exception e) {
						matData.put("compCount", "");
					}
					try{
						matData.put("compUnit", matItemCompUnit.get(i));
					} catch(Exception e) {
						matData.put("compUnit", "");
					}
					try{
						matData.put("useCount", matItemUseCount.get(i));
					} catch(Exception e) {
						matData.put("useCount", "");
					}
					try{
						matData.put("useUnit", matItemUseUnit.get(i));
					} catch(Exception e) {
						matData.put("useUnit", "");
					}
					matList.add(matData);
				}
			}
			if( matList != null && matList.size() > 0 ) {
				recipeDao.insertRecipeMaterial(matList);
			}
			
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			if( newItemName != null && newItemName.size() > 0 ) {
				for( int i = 0 ; i < newItemName.size() ; i++ ) {
					HashMap<String,Object> newData = new HashMap<String,Object>();
					newData.put("idx", recipeIdx);
					newData.put("no", (i*10)+10);
					try{
						newData.put("name", newItemName.get(i));
					} catch(Exception e) {
						newData.put("name", "");
					}
					try{
						newData.put("compCount", newItemCompCount.get(i));
					} catch(Exception e) {
						newData.put("compCount", "");
					}
					try{
						newData.put("compUnit", newItemCompUnit.get(i));
					} catch(Exception e) {
						newData.put("compUnit", "");
					}
					try{
						newData.put("useCount", newItemUseCount.get(i));
					} catch(Exception e) {
						newData.put("useCount", "");
					}
					try{
						newData.put("useUnit", newItemUseUnit.get(i));
					} catch(Exception e) {
						newData.put("useUnit", "");
					}
					try{
						newData.put("price", newItemPrice.get(i));
					} catch(Exception e) {
						newData.put("price", "");
					}
					try{
						newData.put("desc", newItemDesc.get(i));
					} catch(Exception e) {
						newData.put("desc", "");
					}
					newList.add(newData);
				}
			}
			
			if( newList != null && newList.size() > 0 ) {
				recipeDao.insertRecipePurchase(newList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", recipeIdx);
			historyParam.put("docType", "RECIPE");
			historyParam.put("historyType", "T");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			txManager.commit(status);
			return recipeIdx;
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public int insertRecipe(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		int recipeIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			JSONParser parser = new JSONParser();
			JSONArray matItemSapCode = (JSONArray) parser.parse((String)param.get("matItemSapCodeArr"));
			JSONArray matItemName = (JSONArray) parser.parse((String)param.get("matItemNameArr"));
			JSONArray matItemCompCount = (JSONArray) parser.parse((String)param.get("matItemCompCountArr"));
			JSONArray matItemCompUnit = (JSONArray) parser.parse((String)param.get("matItemCompUnitArr"));
			JSONArray matItemUseCount = (JSONArray) parser.parse((String)param.get("matItemUseCountArr"));
			JSONArray matItemUseUnit = (JSONArray) parser.parse((String)param.get("matItemUseUnitArr"));
			
			JSONArray newItemName = (JSONArray) parser.parse((String)param.get("newItemNameArr"));
			JSONArray newItemCompCount = (JSONArray) parser.parse((String)param.get("newItemCompCountArr"));
			JSONArray newItemCompUnit = (JSONArray) parser.parse((String)param.get("newItemCompUnitArr"));
			JSONArray newItemUseCount = (JSONArray) parser.parse((String)param.get("newItemUseCountArr"));
			JSONArray newItemUseUnit = (JSONArray) parser.parse((String)param.get("newItemUseUnitArr"));
			JSONArray newItemPrice = (JSONArray) parser.parse((String)param.get("newItemPriceArr"));
			JSONArray newItemDesc = (JSONArray) parser.parse((String)param.get("newItemDescArr"));
			
			recipeIdx = recipeDao.selectRecipeSeq(); 	//key value 조
			param.put("idx", recipeIdx);
			
			recipeDao.insertRecipe(param);
			
			ArrayList<HashMap<String,Object>> matList = new ArrayList<HashMap<String,Object>>();
			if( matItemSapCode != null && matItemSapCode.size() > 0 ) {
				for( int i = 0 ; i < matItemSapCode.size() ; i++ ) {
					HashMap<String,Object> matData = new HashMap<String,Object>();
					matData.put("idx", recipeIdx);
					matData.put("no", (i*10)+10);
					try{
						matData.put("sapCode", matItemSapCode.get(i));
					} catch(Exception e) {
						matData.put("sapCode", "");
					}
					try{
						matData.put("productName", matItemName.get(i));
					} catch(Exception e) {
						matData.put("productName", "");
					}
					try{
						matData.put("compCount", matItemCompCount.get(i));
					} catch(Exception e) {
						matData.put("compCount", "");
					}
					try{
						matData.put("compUnit", matItemCompUnit.get(i));
					} catch(Exception e) {
						matData.put("compUnit", "");
					}
					try{
						matData.put("useCount", matItemUseCount.get(i));
					} catch(Exception e) {
						matData.put("useCount", "");
					}
					try{
						matData.put("useUnit", matItemUseUnit.get(i));
					} catch(Exception e) {
						matData.put("useUnit", "");
					}
					matList.add(matData);
				}
			}
			if( matList != null && matList.size() > 0 ) {
				recipeDao.insertRecipeMaterial(matList);
			}
			
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			if( newItemName != null && newItemName.size() > 0 ) {
				for( int i = 0 ; i < newItemName.size() ; i++ ) {
					HashMap<String,Object> newData = new HashMap<String,Object>();
					newData.put("idx", recipeIdx);
					newData.put("no", (i*10)+10);
					try{
						newData.put("name", newItemName.get(i));
					} catch(Exception e) {
						newData.put("name", "");
					}
					try{
						newData.put("compCount", newItemCompCount.get(i));
					} catch(Exception e) {
						newData.put("compCount", "");
					}
					try{
						newData.put("compUnit", newItemCompUnit.get(i));
					} catch(Exception e) {
						newData.put("compUnit", "");
					}
					try{
						newData.put("useCount", newItemUseCount.get(i));
					} catch(Exception e) {
						newData.put("useCount", "");
					}
					try{
						newData.put("useUnit", newItemUseUnit.get(i));
					} catch(Exception e) {
						newData.put("useUnit", "");
					}
					try{
						newData.put("price", newItemPrice.get(i));
					} catch(Exception e) {
						newData.put("price", "");
					}
					try{
						newData.put("desc", newItemDesc.get(i));
					} catch(Exception e) {
						newData.put("desc", "");
					}
					newList.add(newData);
				}
			}
			
			if( newList != null && newList.size() > 0 ) {
				recipeDao.insertRecipePurchase(newList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", recipeIdx);
			historyParam.put("docType", "RECIPE");
			historyParam.put("historyType", "I");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			txManager.commit(status);
			return recipeIdx;
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return recipeDao.selectHistory(param);
	}

	@Override
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return recipeDao.selectMyDataCheck(param);
	}

	@Override
	public Map<String, Object> selectRecipeData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return recipeDao.selectRecipeData(param);
	}

	@Override
	public List<Map<String, Object>> selectMaterialList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return recipeDao.selectMaterialList(param);
	}

	@Override
	public List<Map<String, Object>> selectPurchaseList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return recipeDao.selectPurchaseList(param);
	}

	@Override
	public void updateTmpRecipe(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			JSONParser parser = new JSONParser();
			JSONArray matItemSapCode = (JSONArray) parser.parse((String)param.get("matItemSapCodeArr"));
			JSONArray matItemName = (JSONArray) parser.parse((String)param.get("matItemNameArr"));
			JSONArray matItemCompCount = (JSONArray) parser.parse((String)param.get("matItemCompCountArr"));
			JSONArray matItemCompUnit = (JSONArray) parser.parse((String)param.get("matItemCompUnitArr"));
			JSONArray matItemUseCount = (JSONArray) parser.parse((String)param.get("matItemUseCountArr"));
			JSONArray matItemUseUnit = (JSONArray) parser.parse((String)param.get("matItemUseUnitArr"));
			
			JSONArray newItemName = (JSONArray) parser.parse((String)param.get("newItemNameArr"));
			JSONArray newItemCompCount = (JSONArray) parser.parse((String)param.get("newItemCompCountArr"));
			JSONArray newItemCompUnit = (JSONArray) parser.parse((String)param.get("newItemCompUnitArr"));
			JSONArray newItemUseCount = (JSONArray) parser.parse((String)param.get("newItemUseCountArr"));
			JSONArray newItemUseUnit = (JSONArray) parser.parse((String)param.get("newItemUseUnitArr"));
			JSONArray newItemPrice = (JSONArray) parser.parse((String)param.get("newItemPriceArr"));
			JSONArray newItemDesc = (JSONArray) parser.parse((String)param.get("newItemDescArr"));
			
			recipeDao.updateRecipe(param);
			
			recipeDao.deleteRecipeMaterial(param);
			ArrayList<HashMap<String,Object>> matList = new ArrayList<HashMap<String,Object>>();
			if( matItemSapCode != null && matItemSapCode.size() > 0 ) {
				for( int i = 0 ; i < matItemSapCode.size() ; i++ ) {
					HashMap<String,Object> matData = new HashMap<String,Object>();
					matData.put("idx", param.get("idx"));
					matData.put("no", (i*10)+10);
					try{
						matData.put("sapCode", matItemSapCode.get(i));
					} catch(Exception e) {
						matData.put("sapCode", "");
					}
					try{
						matData.put("productName", matItemName.get(i));
					} catch(Exception e) {
						matData.put("productName", "");
					}
					try{
						matData.put("compCount", matItemCompCount.get(i));
					} catch(Exception e) {
						matData.put("compCount", "");
					}
					try{
						matData.put("compUnit", matItemCompUnit.get(i));
					} catch(Exception e) {
						matData.put("compUnit", "");
					}
					try{
						matData.put("useCount", matItemUseCount.get(i));
					} catch(Exception e) {
						matData.put("useCount", "");
					}
					try{
						matData.put("useUnit", matItemUseUnit.get(i));
					} catch(Exception e) {
						matData.put("useUnit", "");
					}
					matList.add(matData);
				}
			}
			if( matList != null && matList.size() > 0 ) {
				recipeDao.insertRecipeMaterial(matList);
			}
			
			recipeDao.deleteRecipePurchase(param);
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			if( newItemName != null && newItemName.size() > 0 ) {
				for( int i = 0 ; i < newItemName.size() ; i++ ) {
					HashMap<String,Object> newData = new HashMap<String,Object>();
					newData.put("idx", param.get("idx"));
					newData.put("no", (i*10)+10);
					try{
						newData.put("name", newItemName.get(i));
					} catch(Exception e) {
						newData.put("name", "");
					}
					try{
						newData.put("compCount", newItemCompCount.get(i));
					} catch(Exception e) {
						newData.put("compCount", "");
					}
					try{
						newData.put("compUnit", newItemCompUnit.get(i));
					} catch(Exception e) {
						newData.put("compUnit", "");
					}
					try{
						newData.put("useCount", newItemUseCount.get(i));
					} catch(Exception e) {
						newData.put("useCount", "");
					}
					try{
						newData.put("useUnit", newItemUseUnit.get(i));
					} catch(Exception e) {
						newData.put("useUnit", "");
					}
					try{
						newData.put("price", newItemPrice.get(i));
					} catch(Exception e) {
						newData.put("price", "");
					}
					try{
						newData.put("desc", newItemDesc.get(i));
					} catch(Exception e) {
						newData.put("desc", "");
					}
					newList.add(newData);
				}
			}
			
			if( newList != null && newList.size() > 0 ) {
				recipeDao.insertRecipePurchase(newList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", param.get("idx"));
			historyParam.put("docType", "RECIPE");
			historyParam.put("historyType", "T");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			txManager.commit(status);
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public void updateRecipe(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			JSONParser parser = new JSONParser();
			JSONArray matItemSapCode = (JSONArray) parser.parse((String)param.get("matItemSapCodeArr"));
			JSONArray matItemName = (JSONArray) parser.parse((String)param.get("matItemNameArr"));
			JSONArray matItemCompCount = (JSONArray) parser.parse((String)param.get("matItemCompCountArr"));
			JSONArray matItemCompUnit = (JSONArray) parser.parse((String)param.get("matItemCompUnitArr"));
			JSONArray matItemUseCount = (JSONArray) parser.parse((String)param.get("matItemUseCountArr"));
			JSONArray matItemUseUnit = (JSONArray) parser.parse((String)param.get("matItemUseUnitArr"));
			
			JSONArray newItemName = (JSONArray) parser.parse((String)param.get("newItemNameArr"));
			JSONArray newItemCompCount = (JSONArray) parser.parse((String)param.get("newItemCompCountArr"));
			JSONArray newItemCompUnit = (JSONArray) parser.parse((String)param.get("newItemCompUnitArr"));
			JSONArray newItemUseCount = (JSONArray) parser.parse((String)param.get("newItemUseCountArr"));
			JSONArray newItemUseUnit = (JSONArray) parser.parse((String)param.get("newItemUseUnitArr"));
			JSONArray newItemPrice = (JSONArray) parser.parse((String)param.get("newItemPriceArr"));
			JSONArray newItemDesc = (JSONArray) parser.parse((String)param.get("newItemDescArr"));
			
			recipeDao.updateRecipe(param);
			
			recipeDao.deleteRecipeMaterial(param);
			ArrayList<HashMap<String,Object>> matList = new ArrayList<HashMap<String,Object>>();
			if( matItemSapCode != null && matItemSapCode.size() > 0 ) {
				for( int i = 0 ; i < matItemSapCode.size() ; i++ ) {
					HashMap<String,Object> matData = new HashMap<String,Object>();
					matData.put("idx", param.get("idx"));
					matData.put("no", (i*10)+10);
					try{
						matData.put("sapCode", matItemSapCode.get(i));
					} catch(Exception e) {
						matData.put("sapCode", "");
					}
					try{
						matData.put("productName", matItemName.get(i));
					} catch(Exception e) {
						matData.put("productName", "");
					}
					try{
						matData.put("compCount", matItemCompCount.get(i));
					} catch(Exception e) {
						matData.put("compCount", "");
					}
					try{
						matData.put("compUnit", matItemCompUnit.get(i));
					} catch(Exception e) {
						matData.put("compUnit", "");
					}
					try{
						matData.put("useCount", matItemUseCount.get(i));
					} catch(Exception e) {
						matData.put("useCount", "");
					}
					try{
						matData.put("useUnit", matItemUseUnit.get(i));
					} catch(Exception e) {
						matData.put("useUnit", "");
					}
					matList.add(matData);
				}
			}
			if( matList != null && matList.size() > 0 ) {
				recipeDao.insertRecipeMaterial(matList);
			}
			
			recipeDao.deleteRecipePurchase(param);
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			if( newItemName != null && newItemName.size() > 0 ) {
				for( int i = 0 ; i < newItemName.size() ; i++ ) {
					HashMap<String,Object> newData = new HashMap<String,Object>();
					newData.put("idx", param.get("idx"));
					newData.put("no", (i*10)+10);
					try{
						newData.put("name", newItemName.get(i));
					} catch(Exception e) {
						newData.put("name", "");
					}
					try{
						newData.put("compCount", newItemCompCount.get(i));
					} catch(Exception e) {
						newData.put("compCount", "");
					}
					try{
						newData.put("compUnit", newItemCompUnit.get(i));
					} catch(Exception e) {
						newData.put("compUnit", "");
					}
					try{
						newData.put("useCount", newItemUseCount.get(i));
					} catch(Exception e) {
						newData.put("useCount", "");
					}
					try{
						newData.put("useUnit", newItemUseUnit.get(i));
					} catch(Exception e) {
						newData.put("useUnit", "");
					}
					try{
						newData.put("price", newItemPrice.get(i));
					} catch(Exception e) {
						newData.put("price", "");
					}
					try{
						newData.put("desc", newItemDesc.get(i));
					} catch(Exception e) {
						newData.put("desc", "");
					}
					newList.add(newData);
				}
			}
			
			if( newList != null && newList.size() > 0 ) {
				recipeDao.insertRecipePurchase(newList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", param.get("idx"));
			historyParam.put("docType", "RECIPE");
			historyParam.put("historyType", "U");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			txManager.commit(status);
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public Map<String, Object> insertErp(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Map<String, Object> recipeData = recipeDao.selectRecipeData(param);
			//2.lab_recipe_material 조회
			List<Map<String, Object>> materialList = recipeDao.selectMaterialList(param);
			//3.lab_recipe_purchase
			List<Map<String, Object>> purchaseList = recipeDao.selectPurchaseList(param);
			
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("recipeData", recipeData);
			paramMap.put("materialList", materialList);
			paramMap.put("purchaseList", purchaseList);
			
			recipeDao.insertErp(paramMap);
		} catch( Exception e ) {
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE","ERP 반영오류가 발생했습니다.");
		}
		
		return returnMap;
	}

	@Override
	public int versionUpTmpRecipe(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		int recipeIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			JSONParser parser = new JSONParser();
			JSONArray matItemSapCode = (JSONArray) parser.parse((String)param.get("matItemSapCodeArr"));
			JSONArray matItemName = (JSONArray) parser.parse((String)param.get("matItemNameArr"));
			JSONArray matItemCompCount = (JSONArray) parser.parse((String)param.get("matItemCompCountArr"));
			JSONArray matItemCompUnit = (JSONArray) parser.parse((String)param.get("matItemCompUnitArr"));
			JSONArray matItemUseCount = (JSONArray) parser.parse((String)param.get("matItemUseCountArr"));
			JSONArray matItemUseUnit = (JSONArray) parser.parse((String)param.get("matItemUseUnitArr"));
			
			JSONArray newItemName = (JSONArray) parser.parse((String)param.get("newItemNameArr"));
			JSONArray newItemCompCount = (JSONArray) parser.parse((String)param.get("newItemCompCountArr"));
			JSONArray newItemCompUnit = (JSONArray) parser.parse((String)param.get("newItemCompUnitArr"));
			JSONArray newItemUseCount = (JSONArray) parser.parse((String)param.get("newItemUseCountArr"));
			JSONArray newItemUseUnit = (JSONArray) parser.parse((String)param.get("newItemUseUnitArr"));
			JSONArray newItemPrice = (JSONArray) parser.parse((String)param.get("newItemPriceArr"));
			JSONArray newItemDesc = (JSONArray) parser.parse((String)param.get("newItemDescArr"));
			
			recipeDao.updateRecipeIsLast(param);
			
			recipeIdx = recipeDao.selectRecipeSeq(); 	//key value 조
			param.put("idx", recipeIdx);
			
			recipeDao.insertVersionUpRecipe(param);
			
			ArrayList<HashMap<String,Object>> matList = new ArrayList<HashMap<String,Object>>();
			if( matItemSapCode != null && matItemSapCode.size() > 0 ) {
				for( int i = 0 ; i < matItemSapCode.size() ; i++ ) {
					HashMap<String,Object> matData = new HashMap<String,Object>();
					matData.put("idx", recipeIdx);
					matData.put("no", (i*10)+10);
					try{
						matData.put("sapCode", matItemSapCode.get(i));
					} catch(Exception e) {
						matData.put("sapCode", "");
					}
					try{
						matData.put("productName", matItemName.get(i));
					} catch(Exception e) {
						matData.put("productName", "");
					}
					try{
						matData.put("compCount", matItemCompCount.get(i));
					} catch(Exception e) {
						matData.put("compCount", "");
					}
					try{
						matData.put("compUnit", matItemCompUnit.get(i));
					} catch(Exception e) {
						matData.put("compUnit", "");
					}
					try{
						matData.put("useCount", matItemUseCount.get(i));
					} catch(Exception e) {
						matData.put("useCount", "");
					}
					try{
						matData.put("useUnit", matItemUseUnit.get(i));
					} catch(Exception e) {
						matData.put("useUnit", "");
					}
					matList.add(matData);
				}
			}
			if( matList != null && matList.size() > 0 ) {
				recipeDao.insertRecipeMaterial(matList);
			}
			
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			if( newItemName != null && newItemName.size() > 0 ) {
				for( int i = 0 ; i < newItemName.size() ; i++ ) {
					HashMap<String,Object> newData = new HashMap<String,Object>();
					newData.put("idx", recipeIdx);
					newData.put("no", (i*10)+10);
					try{
						newData.put("name", newItemName.get(i));
					} catch(Exception e) {
						newData.put("name", "");
					}
					try{
						newData.put("compCount", newItemCompCount.get(i));
					} catch(Exception e) {
						newData.put("compCount", "");
					}
					try{
						newData.put("compUnit", newItemCompUnit.get(i));
					} catch(Exception e) {
						newData.put("compUnit", "");
					}
					try{
						newData.put("useCount", newItemUseCount.get(i));
					} catch(Exception e) {
						newData.put("useCount", "");
					}
					try{
						newData.put("useUnit", newItemUseUnit.get(i));
					} catch(Exception e) {
						newData.put("useUnit", "");
					}
					try{
						newData.put("price", newItemPrice.get(i));
					} catch(Exception e) {
						newData.put("price", "");
					}
					try{
						newData.put("desc", newItemDesc.get(i));
					} catch(Exception e) {
						newData.put("desc", "");
					}
					newList.add(newData);
				}
			}
			
			if( newList != null && newList.size() > 0 ) {
				recipeDao.insertRecipePurchase(newList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", recipeIdx);
			historyParam.put("docType", "RECIPE");
			historyParam.put("historyType", "V");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			txManager.commit(status);
			return recipeIdx;
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public int versionUpRecipe(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		int recipeIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			JSONParser parser = new JSONParser();
			JSONArray matItemSapCode = (JSONArray) parser.parse((String)param.get("matItemSapCodeArr"));
			JSONArray matItemName = (JSONArray) parser.parse((String)param.get("matItemNameArr"));
			JSONArray matItemCompCount = (JSONArray) parser.parse((String)param.get("matItemCompCountArr"));
			JSONArray matItemCompUnit = (JSONArray) parser.parse((String)param.get("matItemCompUnitArr"));
			JSONArray matItemUseCount = (JSONArray) parser.parse((String)param.get("matItemUseCountArr"));
			JSONArray matItemUseUnit = (JSONArray) parser.parse((String)param.get("matItemUseUnitArr"));
			
			JSONArray newItemName = (JSONArray) parser.parse((String)param.get("newItemNameArr"));
			JSONArray newItemCompCount = (JSONArray) parser.parse((String)param.get("newItemCompCountArr"));
			JSONArray newItemCompUnit = (JSONArray) parser.parse((String)param.get("newItemCompUnitArr"));
			JSONArray newItemUseCount = (JSONArray) parser.parse((String)param.get("newItemUseCountArr"));
			JSONArray newItemUseUnit = (JSONArray) parser.parse((String)param.get("newItemUseUnitArr"));
			JSONArray newItemPrice = (JSONArray) parser.parse((String)param.get("newItemPriceArr"));
			JSONArray newItemDesc = (JSONArray) parser.parse((String)param.get("newItemDescArr"));
			
			recipeDao.updateRecipeIsLast(param);
			
			recipeIdx = recipeDao.selectRecipeSeq(); 	//key value 조
			param.put("idx", recipeIdx);
			
			recipeDao.insertVersionUpRecipe(param);
			
			ArrayList<HashMap<String,Object>> matList = new ArrayList<HashMap<String,Object>>();
			if( matItemSapCode != null && matItemSapCode.size() > 0 ) {
				for( int i = 0 ; i < matItemSapCode.size() ; i++ ) {
					HashMap<String,Object> matData = new HashMap<String,Object>();
					matData.put("idx", recipeIdx);
					matData.put("no", (i*10)+10);
					try{
						matData.put("sapCode", matItemSapCode.get(i));
					} catch(Exception e) {
						matData.put("sapCode", "");
					}
					try{
						matData.put("productName", matItemName.get(i));
					} catch(Exception e) {
						matData.put("productName", "");
					}
					try{
						matData.put("compCount", matItemCompCount.get(i));
					} catch(Exception e) {
						matData.put("compCount", "");
					}
					try{
						matData.put("compUnit", matItemCompUnit.get(i));
					} catch(Exception e) {
						matData.put("compUnit", "");
					}
					try{
						matData.put("useCount", matItemUseCount.get(i));
					} catch(Exception e) {
						matData.put("useCount", "");
					}
					try{
						matData.put("useUnit", matItemUseUnit.get(i));
					} catch(Exception e) {
						matData.put("useUnit", "");
					}
					matList.add(matData);
				}
			}
			if( matList != null && matList.size() > 0 ) {
				recipeDao.insertRecipeMaterial(matList);
			}
			
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			if( newItemName != null && newItemName.size() > 0 ) {
				for( int i = 0 ; i < newItemName.size() ; i++ ) {
					HashMap<String,Object> newData = new HashMap<String,Object>();
					newData.put("idx", recipeIdx);
					newData.put("no", (i*10)+10);
					try{
						newData.put("name", newItemName.get(i));
					} catch(Exception e) {
						newData.put("name", "");
					}
					try{
						newData.put("compCount", newItemCompCount.get(i));
					} catch(Exception e) {
						newData.put("compCount", "");
					}
					try{
						newData.put("compUnit", newItemCompUnit.get(i));
					} catch(Exception e) {
						newData.put("compUnit", "");
					}
					try{
						newData.put("useCount", newItemUseCount.get(i));
					} catch(Exception e) {
						newData.put("useCount", "");
					}
					try{
						newData.put("useUnit", newItemUseUnit.get(i));
					} catch(Exception e) {
						newData.put("useUnit", "");
					}
					try{
						newData.put("price", newItemPrice.get(i));
					} catch(Exception e) {
						newData.put("price", "");
					}
					try{
						newData.put("desc", newItemDesc.get(i));
					} catch(Exception e) {
						newData.put("desc", "");
					}
					newList.add(newData);
				}
			}
			
			if( newList != null && newList.size() > 0 ) {
				recipeDao.insertRecipePurchase(newList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", recipeIdx);
			historyParam.put("docType", "RECIPE");
			historyParam.put("historyType", "V");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			txManager.commit(status);
			return recipeIdx;
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public Map<String, Object> applyErp(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> returnMap = new HashMap<String, Object>();
		//1.lab_recipe 
		Map<String, Object> recipeData = recipeDao.selectRecipeData(param);
		//2.lab_recipe_material 조회
		List<Map<String, Object>> materialList = recipeDao.selectMaterialList(param);
		//3.lab_recipe_purchase
		List<Map<String, Object>> purchaseList = recipeDao.selectPurchaseList(param);
		
		List<Map<String, Object>> erpItemList = new ArrayList<Map<String, Object>>();
		
		//for (Map<String, Object> materialItem : materialList) {
		for ( int i = 0 ; i < materialList.size() ; i++ ) {
			Map<String, Object> materialItem = materialList.get(i);
			
			HashMap<String, Object> erpDataMap = new HashMap<String, Object>();
			erpDataMap.put("MATNR", recipeData.get("PRODUCT_CODE"));	//매장 메뉴 코드
			erpDataMap.put("MAKTX", recipeData.get("PRODUCT_NAME"));	//매장 메뉴 코드명
			erpDataMap.put("WERKS", recipeData.get("PLANT"));			//플랜트
			erpDataMap.put("MENGE", recipeData.get("PRODUCT_COUNT"));	//품목수량
			erpDataMap.put("MEINS", recipeData.get("PRODUCT_UNIT"));			//기본단위
			erpDataMap.put("RCNUM", (i*10)+10);	//구성품번호(10부터 + 10씩 증가)
			erpDataMap.put("LMATNR", materialItem.get("SAP_CODE"));	//구성품목코드
			erpDataMap.put("LMAKTX", materialItem.get("ITEM_NAME"));	//구성품목명
			erpDataMap.put("UMREN", materialItem.get("ITEM_COUNT"));	//레시피수량
			erpDataMap.put("RCMEI", materialItem.get("ITEM_UNIT").toString().toUpperCase());	//레시피단위
			erpDataMap.put("LMENGE", materialItem.get("USED_COUNT"));	//사용량
			erpDataMap.put("LMEINS", materialItem.get("USED_UNIT").toString().toUpperCase());	//사용량단위
			erpDataMap.put("POGB", "본사");		//구성품 구매형태 구분 (본사 / 직사입)
			erpDataMap.put("NETPR", "");		//레시피수량 별 단가
			
			erpItemList.add(erpDataMap);
		}
		
		for( int i = 0 ; i < purchaseList.size() ; i++ ) {
			Map<String, Object> purchaseItem = purchaseList.get(i);
			
			HashMap<String, Object> erpDataMap = new HashMap<String, Object>();
			
			erpDataMap.put("MATNR", recipeData.get("PRODUCT_CODE"));	//매장 메뉴 코드
			erpDataMap.put("MAKTX", recipeData.get("PRODUCT_NAME"));	//매장 메뉴 코드명
			erpDataMap.put("WERKS", recipeData.get("PLANT"));			//플랜트
			erpDataMap.put("MENGE", recipeData.get("PRODUCT_COUNT"));	//품목수량
			erpDataMap.put("MEINS", recipeData.get("PRODUCT_UNIT"));			//기본단위
			erpDataMap.put("RCNUM", (i*10)+10+(materialList.size()*10));//구성품번호(10부터 + 10씩 증가)
			erpDataMap.put("LMATNR", "");	//구성품목코드
			erpDataMap.put("LMAKTX", purchaseItem.get("ITEM_NAME"));	//구성품목명
			erpDataMap.put("UMREN", purchaseItem.get("ITEM_COUNT"));	//레시피수량
			erpDataMap.put("RCMEI", purchaseItem.get("ITEM_UNIT").toString().toUpperCase());	//레시피단위
			erpDataMap.put("LMENGE", purchaseItem.get("USED_COUNT"));	//사용량
			erpDataMap.put("LMEINS", purchaseItem.get("USED_UNIT").toString().toUpperCase());	//사용량단위
			erpDataMap.put("POGB", "직사입");		//구성품 구매형태 구분 (본사 / 직사입)
			erpDataMap.put("NETPR", purchaseItem.get("ITEM_PRICE"));		//레시피수량 별 단가
			
			erpItemList.add(erpDataMap);
		}
		
		System.err.println(erpItemList);
		
		HashMap<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("idx", recipeData.get("RECIPE_IDX"));
		if( erpItemList.size() > 0 ) {
			try {
				returnMap = recipeDao.applyErp(erpItemList);	//ERP 반영
				if( returnMap != null && "S".equals((String)returnMap.get("RESULT"))) {
					//반영 결과 업데이트.
					paramMap.put("status", "BOM");
					paramMap.put("message", "정상처리 되었습니다.");
				} else {
					//반영 결과 업데이트.
					paramMap.put("status", "BOM_ERROR");
					paramMap.put("message", returnMap.get("MESSAGE"));
				}				
			} catch( Exception e ) {
				System.err.println(e.getMessage());
				returnMap.put("RESULT", "E");
				returnMap.put("MESSAGE", "ERP 반영 오류가 발생했습니다.");
				paramMap.put("status", "BOM_ERROR");
				paramMap.put("message", "ERP 반영 오류가 발생했습니다."+e.getMessage());
			}			
		} else {
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE", "ERP 반영 데이터가 없습니다.");
			paramMap.put("status", "BOM_ERROR");
			paramMap.put("message", "ERP 반영 데이터가 없습니다.");
		}
		
		recipeDao.updateStatus(paramMap);
		
		return returnMap;
	}

}
