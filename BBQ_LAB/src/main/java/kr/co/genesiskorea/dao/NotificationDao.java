package kr.co.genesiskorea.dao;

import java.util.List;
import java.util.Map;

public interface NotificationDao {

	int selectListCount(Map<String, Object> param);

	List<Map<String, Object>> selectList(Map<String, Object> param);

}
