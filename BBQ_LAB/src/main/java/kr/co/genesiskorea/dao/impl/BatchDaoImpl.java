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
import kr.co.genesiskorea.dao.BatchDao;
import kr.co.genesiskorea.util.RfcCommonMapper;
import kr.co.genesiskorea.util.RfcDataHandler;

@Repository
public class BatchDaoImpl extends RfcCommonMapper implements BatchDao {
	@Autowired(required=true)
	@Qualifier("sqlSessionTemplate")
	private SqlSessionTemplate sqlSessionTemplate;
	
	@Autowired(required=true)
	@Qualifier("sqlSessionTemplateMSSQL")
	private SqlSessionTemplate sqlSessionTemplateMSSQL;
	
	@Override
	public List<Map<String, Object>> selectMaterial(Map<String, Object> importParams) {
		// TODO Auto-generated method stub
		List<Map<String, Object>> returnList = null;
		try {
			JCoDestination dest = RfcManager.getDestination();
			JCoFunction function = getFunction(dest, "ZASMM_WMS_MATERIAL_SEND");
			execute(function,importParams);
			
			returnList = RfcDataHandler.getTableData(function,"T_MATERIAL",new HashMap<String, String>() {
	            {
	                put("MATNR", "MATNR");
	                put("MAKTX", "MAKTX");
	                put("MEINS", "MEINS");
	                put("STOR_COND", "STOR_COND");
	                put("LRMEI", "LRMEI");
	                put("UMREZ", "UMREZ");
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
	                put("MOQ", "MOQ");
	                put("PALLET_HOR_STOCK", "PALLET_HOR_STOCK");
	                put("PALLET_VER_STOCK", "PALLET_VER_STOCK");
	                put("PALLET_STOCK", "PALLET_STOCK");
	                put("MWSKZ", "MWSKZ");
	                put("EXP_DATE", "EXP_DATE");
	            }
	        });
		} catch( Exception e ) {
			e.printStackTrace();
		}
		return returnList;
	}

	@Override
	public void initProductSeq() {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("batch.initProductSeq");
	}

	@Override
	public void initMenuSeq() {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("batch.initMenuSeq");
	}

	@Override
	public void insertMaterial(List<Map<String, Object>> returnList) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("batch.insertMaterial",returnList);
	}

	@Override
	public void initSeq() {
		// TODO Auto-generated method stub
		sqlSessionTemplate.update("batch.initSeq");
	}

	@Override
	public List<Map<String, Object>> selectHrOrgMaster() {
		// TODO Auto-generated method stub
		return sqlSessionTemplateMSSQL.selectList("batch.selectHrOrgMaster");
	}

	@Override
	public void insertHrOrgMaster(List<Map<String, Object>> dataList) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("batch.insertHrOrgMaster", dataList);
	}

	@Override
	public List<Map<String, Object>> selectHrUserMaster() {
		// TODO Auto-generated method stub
		return sqlSessionTemplateMSSQL.selectList("batch.selectHrUserMaster");
	}

	@Override
	public void insertHrUserMaster(List<Map<String, Object>> dataList) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("batch.insertHrUserMaster", dataList);
	}

	@Override
	public List<Map<String, Object>> selectHrCodeMaster() {
		// TODO Auto-generated method stub
		return sqlSessionTemplateMSSQL.selectList("batch.selectHrCodeMaster");
	}

	@Override
	public void insertHrCodeMaster(List<Map<String, Object>> dataList) {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("batch.insertHrCodeMaster", dataList);
	}

	@Override
	public void insertHrUser() {
		// TODO Auto-generated method stub
		sqlSessionTemplate.insert("batch.insertHrUser");
	}

}
