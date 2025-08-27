package kr.co.genesiskorea.dao.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;

import com.sap.conn.jco.JCoDestination;
import com.sap.conn.jco.JCoFunction;

import kr.co.genesiskorea.common.jco.RfcManager;
import kr.co.genesiskorea.dao.TestDao;
import kr.co.genesiskorea.util.RfcCommonMapper;
import kr.co.genesiskorea.util.RfcDataHandler;

@Repository
public class TestDaoImpl extends RfcCommonMapper implements TestDao {

	@Autowired(required=true)
	@Qualifier("sqlSessionTemplate")
	private SqlSessionTemplate sqlSessionTemplate;
	
	@Autowired(required=true)
	@Qualifier("sqlSessionTemplateMSSQL")
	private SqlSessionTemplate sqlSessionTemplateMSSQL;
	
	@Override
	public List<HashMap<String,Object>> selectUser(HashMap<String, Object> map) throws Exception {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("test.selectUser",map);
	}

	public void insertTest1(HashMap<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("test.insertTest1", param);
	}

	public void insertTest2(HashMap<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("test.insertTest2", param);
	}

	public List<Map<String, Object>> selectOrg() {
		// TODO Auto-generated method stub
		return sqlSessionTemplateMSSQL.selectList("test.selectOrg");
	}

	public List<Map<String, Object>> selectHrInfo() {
		// TODO Auto-generated method stub
		return sqlSessionTemplateMSSQL.selectList("test.selectHrInfo");
	}

	public List<Map<String, Object>> selectMasterCode() {
		// TODO Auto-generated method stub
		return sqlSessionTemplateMSSQL.selectList("test.selectMasterCode");
	}

	public void insertOrg(List<Map<String, Object>> dataList) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("test.insertOrg", dataList);
	}

	public void insertHrInfo(List<Map<String, Object>> dataList) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("test.insertHrInfo", dataList);
	}

	public void insertMasterCode(List<Map<String, Object>> dataList) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("test.insertMasterCode", dataList);
	}

	public List<Map<String, Object>> selecUserList() {
		// TODO Auto-generated method stub
		return sqlSessionTemplate.selectList("test.selecUserList");
	}

	public void updateUserPwd(Map<String, Object> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("test.updateUserPwd", param);
	}

	public void insertHrUser(Map<String, Object> param) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("test.insertHrUser", param);
	}

	public List<Map<String, Object>> selectMaterial(Map<String, Object> importParams) {
		// TODO Auto-generated method stub
		List<Map<String, Object>> returnList = null;
		try {
			JCoDestination dest = RfcManager.getDestination();
			JCoFunction function = getFunction(dest, "ZASMM_PDM_MATERIAL_SEND");
			System.err.println("function  :  "+function);
			execute(function,importParams);
			
			returnList = RfcDataHandler.getTableData(function,"T_MATERIAL",new HashMap<String, String>() {
	            {
	            	put("BUKRS", "BUKRS");
	            	put("MATNR", "MATNR");
	                put("MAKTX", "MAKTX");
	                put("MTART", "MTART");
	                put("STOR_COND", "STOR_COND");
	                put("MATKL", "MATKL");
	                put("WGBEZ", "WGBEZ");
	                put("MEINS", "MEINS");
	                put("LRMEI", "LRMEI");
	                put("UMREZ", "UMREZ");
	                put("RCMEI", "RCMEI");
	                put("UMREN", "UMREN");
	                put("HORIZONTAL", "HORIZONTAL");
	                put("HORIZONTAL_MEINS", "HORIZONTAL_MEINS");
	                put("VERTICAL", "VERTICAL");
	                put("VERTICAL_MEINS", "VERTICAL_MEINS");
	                put("HEIGHT", "HEIGHT");
	                put("HEIGHT_MEINS", "HEIGHT_MEINS");
	                put("WEIGHT", "WEIGHT");
	                put("WEIGHT_MEINS", "WEIGHT_MEINS");
	                put("SIZE_DIM", "SIZE_DIM");
	                put("ORIG_MAT", "ORIG_MAT");
	                put("LEADTIMES", "LEADTIMES");
	                put("SAFETY_STOCK_DAY", "SAFETY_STOCK_DAY");
	                put("BOX_STOCK", "BOX_STOCK");
	                put("PALLET_STOCK", "PALLET_STOCK");
	                put("MWSKZ", "MWSKZ");
	                put("EXP_DATE", "EXP_DATE");
	                put("USE_YN", "USE_YN");
	                put("MOQ", "MOQ");
	            }
	        });
		} catch( Exception e ) {
			e.printStackTrace();
		}
		return returnList;
	}
	
}
