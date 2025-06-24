package kr.co.genesiskorea.service.impl;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sap.conn.jco.JCoDestination;
import com.sap.conn.jco.JCoFunction;

import kr.co.genesiskorea.service.BatchService;
import kr.co.genesiskorea.common.jco.RfcManager;
import kr.co.genesiskorea.controller.BusinessTripController;
import kr.co.genesiskorea.util.RfcDataHandler;
import kr.co.genesiskorea.dao.BatchDao;

@Service
public class BatchServiceImpl implements BatchService {
	private Logger logger = LogManager.getLogger(BatchServiceImpl.class);
	@Autowired 
	BatchDao batchDao;
	
	/*@Override
	public List<Map<String, Object>> material(Map<String, Object> importParams) {
		// TODO Auto-generated method stub
		List<Map<String, Object>> returnList = batchDao.material(importParams);
		logger.debug(returnList);
		return returnList;
	}*/

	@Override
	public void initSeq() {
		// TODO Auto-generated method stub
		//batchDao.initProductSeq();
		//batchDao.initMenuSeq();
		batchDao.initSeq();
	}

	@Override
	public void erpMaterial() {
		// TODO Auto-generated method stub
		Map<String, Object> importParams = new HashMap<String, Object>();
		//유저동기화 로직
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DATE , -1);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        String toDay = sdf.format(cal.getTime());        
		importParams.put("I_DATUM", toDay);
		List<Map<String, Object>> returnList = batchDao.selectMaterial(importParams);
		logger.debug("전체 RFC 처리 데이터 건수 : "+returnList.size());
		batchDao.insertMaterial(returnList);
	}

	@Override
	public List<Map<String, Object>> material(Map<String, Object> importParams) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void erpMaterial(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> importParams = new HashMap<String, Object>();
		//유저동기화 로직
        importParams.put("I_DATUM", param.get("toDay"));
		List<Map<String, Object>> returnList = batchDao.selectMaterial(importParams);
		logger.debug("전체 RFC 처리 데이터 건수 : "+returnList.size());
		//batchDao.insertMaterial(returnList);
	}

	@Override
	public void hrOrgMaster() {
		// TODO Auto-generated method stub
		List<Map<String,Object>> dataList = batchDao.selectHrOrgMaster();
		batchDao.insertHrOrgMaster(dataList);
	}

	@Override
	public void hrUserMaster() {
		// TODO Auto-generated method stub
		List<Map<String,Object>> dataList = batchDao.selectHrUserMaster();
		batchDao.insertHrUserMaster(dataList);
	}

	@Override
	public void hrCodeMaster() {
		// TODO Auto-generated method stub
		List<Map<String,Object>> dataList = batchDao.selectHrCodeMaster();
		batchDao.insertHrCodeMaster(dataList);
	}

	@Override
	public void hrUserSync() {
		// TODO Auto-generated method stub
		batchDao.insertHrUser();
	}
}
