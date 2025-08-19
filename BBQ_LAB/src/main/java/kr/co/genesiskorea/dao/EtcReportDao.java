package kr.co.genesiskorea.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface EtcReportDao {

	int selectEtcCount(Map<String, Object> param);

	List<Map<String, Object>> selectEtcList(Map<String, Object> param);

	int selectEtcSeq();

	void insertEtc(Map<String, Object> param) throws Exception;

	Map<String, Object> selectEtcData(Map<String, Object> param);

	void updateEtc(Map<String, Object> param) throws Exception;

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int selectMyDataCheck(Map<String, Object> param);

	void deleteEtcReport(Map<String, Object> param) throws Exception;
	
}
