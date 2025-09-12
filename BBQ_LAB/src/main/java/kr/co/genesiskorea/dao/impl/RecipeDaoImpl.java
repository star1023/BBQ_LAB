package kr.co.genesiskorea.dao.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.sap.conn.jco.JCoDestination;
import com.sap.conn.jco.JCoFunction;
import com.sap.conn.jco.JCoTable;

import kr.co.genesiskorea.common.jco.RfcManager;
import kr.co.genesiskorea.dao.RecipeDao;
import kr.co.genesiskorea.util.RfcCommonMapper;
import kr.co.genesiskorea.util.RfcDataHandler;

@Repository
public class RecipeDaoImpl extends RfcCommonMapper implements RecipeDao {
	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;

	@Override
	public int selectRecipeCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("recipe.selectRecipeCount", param);
	}
	
	@Override
	public List<Map<String, Object>> selectRecipeList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("recipe.selectRecipeList", param);
	}
	
	@Override
	public int selectRecipeSeq() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("recipe.selectRecipeSeq");
	}

	@Override
	public void insertRecipe(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("recipe.insertRecipe", param);
	}

	@Override
	public void insertRecipeMaterial(ArrayList<HashMap<String, Object>> matList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("recipe.insertRecipeMaterial", matList);
	}

	@Override
	public void insertRecipePurchase(ArrayList<HashMap<String, Object>> newList) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("recipe.insertRecipePurchase", newList);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("recipe.selectHistory", param);
	}

	@Override
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("recipe.selectMyDataCount", param);
	}

	@Override
	public Map<String, Object> selectRecipeData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("recipe.selectRecipeData", param);
	}

	@Override
	public List<Map<String, Object>> selectMaterialList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("recipe.selectMaterialList", param);
	}

	@Override
	public List<Map<String, Object>> selectPurchaseList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("recipe.selectPurchaseList", param);
	}

	@Override
	public void updateRecipe(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("recipe.updateRecipe", param);
	}

	@Override
	public void deleteRecipeMaterial(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("recipe.deleteRecipeMaterial", param);
	}

	@Override
	public void deleteRecipePurchase(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.delete("recipe.deleteRecipePurchase", param);
	}

	@Override
	public void insertErp(Map<String, Object> paramMap) throws Exception {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void insertVersionUpRecipe(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("recipe.insertVersionUpRecipe", param);
	}

	@Override
	public void updateRecipeIsLast(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("recipe.updateRecipeIsLast", param);
	}

	@Override
	public Map<String, Object> applyErp(List<Map<String, Object>> erpItemList) throws Exception {
		// TODO Auto-generated method stub
		
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			JCoDestination dest = RfcManager.getDestination();
			JCoFunction function = getFunction(dest, "ZASMM_PDM_RECIPE_REC");
			//JCoFunction function = getFunction(dest, "ZASMM_WMS_MATERIAL_SEND");
			JCoTable table = function.getTableParameterList().getTable("T_RECIPE");
			
			
			for (Map<String, Object> bomItem : erpItemList) {
				table.appendRow();
				
				table.setValue("MATNR", bomItem.get("MATNR"));	//매장 메뉴 코드
				table.setValue("MAKTX", bomItem.get("MAKTX"));	//매장 메뉴 코드명
				table.setValue("WERKS", bomItem.get("WERKS"));	//플랜트
				table.setValue("MENGE", bomItem.get("MENGE"));	//품목수량
				table.setValue("MEINS", bomItem.get("MEINS"));	//기본단위
				table.setValue("RCNUM", bomItem.get("RCNUM"));	//구성품번호(10부터 + 10씩 증가)
				table.setValue("LMATNR", bomItem.get("LMATNR"));//구성품목코드
				table.setValue("LMAKTX", bomItem.get("LMAKTX"));//구성품목명
				table.setValue("UMREN", bomItem.get("UMREN"));	//레시피수량
				table.setValue("RCMEI", bomItem.get("RCMEI"));	//레시피단위
				table.setValue("LMENGE", bomItem.get("LMENGE"));//사용량
				table.setValue("LMEINS", bomItem.get("LMEINS"));//사용량단위
				table.setValue("POGB", bomItem.get("POGB"));	//구성품 구매형태 구분 (본사 / 직사입)
				table.setValue("NETPR", bomItem.get("NETPR"));	//레시피수량 별 단가
			}
			
			execute(function);
			
			ArrayList<String> exportParamNames = new ArrayList<String>();
			exportParamNames.add("E_STAT");
			exportParamNames.add("E_MESSAGE");
			Map<String, Object> exportParamMap = RfcDataHandler.getExportData(function, exportParamNames);

			String statut = (String)exportParamMap.get("E_STAT");
			String message = (String)exportParamMap.get("E_MESSAGE");
			
			if( statut != null && "S".equals(statut) ) {
				returnMap.put("RESULT", "S");
			} else {
				returnMap.put("RESULT", "E");
				returnMap.put("MESSAGE", message);
			}
		} catch( Exception e) {
			e.printStackTrace();
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE", e.getMessage());
		}
		
		return returnMap;
	}

	@Override
	public void updateStatus(HashMap<String, Object> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("recipe.updateStatus", param);
	}

	@Override
	public int selectRecipeErpMaterialCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectOne("recipe.selectRecipeErpMaterialCount", param);
	}

	@Override
	public List<Map<String, Object>> selectRecipeErpMaterialList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("recipe.selectRecipeErpMaterialList", param);
	}
}
