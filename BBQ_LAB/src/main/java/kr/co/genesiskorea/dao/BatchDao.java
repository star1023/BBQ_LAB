package kr.co.genesiskorea.dao;

import java.util.List;
import java.util.Map;

public interface BatchDao {

	List<Map<String, Object>> selectMaterial(Map<String, Object> importParams);

	void initProductSeq();

	void initMenuSeq();

	void insertMaterial(List<Map<String, Object>> returnList);

	void initSeq();

	List<Map<String, Object>> selectHrOrgMaster();

	void insertHrOrgMaster(List<Map<String, Object>> dataList);

	List<Map<String, Object>> selectHrUserMaster();

	void insertHrUserMaster(List<Map<String, Object>> dataList);

	List<Map<String, Object>> selectHrCodeMaster();

	void insertHrCodeMaster(List<Map<String, Object>> dataList);

	void insertHrUser();

}
