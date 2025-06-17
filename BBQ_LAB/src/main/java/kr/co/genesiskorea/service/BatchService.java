package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

public interface BatchService {

	List<Map<String, Object>> material(Map<String, Object> importParams);

	void initSeq();

	void erpMaterial();

	void erpMaterial(Map<String, Object> param);

}
