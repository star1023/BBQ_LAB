package kr.co.genesiskorea.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface ChemicalTestDao {

	List<Map<String, Object>> selectHistory(Map<String, Object> param);

	int selectChemicalTestCount(Map<String, Object> param);

	List<Map<String, Object>> selectChemicalTestList(Map<String, Object> param);

	int selectChemicalTestSeq();

	void insertChemicalTest(Map<String, Object> param) throws Exception;

	void insertChemicalTestItem(ArrayList<HashMap<String, Object>> itemList) throws Exception;

	void insertChemicalTestStandard(ArrayList<HashMap<String, Object>> standardList) throws Exception;

	Map<String, Object> selectChemicalTestData(Map<String, Object> param);

	List<Map<String, Object>> selectChemicalTestItemData(Map<String, Object> param);

	List<Map<String, Object>> selectChemicalTestStandardList(Map<String, Object> param);

	List<Map<String, Object>> searchChemicalTestList(Map<String, Object> param);

	void updateChemicalTest(Map<String, Object> param) throws Exception;

	void deleteChemicalTestItems(Map<String, Object> param) throws Exception;

	void deleteChemicalTestStandards(Map<String, Object> param) throws Exception;

}
