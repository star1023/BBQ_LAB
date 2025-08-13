package kr.co.genesiskorea.dao;

import java.util.List;
import java.util.Map;

public interface SystemDocTransferDao {

	List<Map<String, Object>> selectUserDocs(Map<String, Object> param) throws Exception;

	int updateOwnerByDocNoBulk(Map<String, Object> param);
	
    int updateOwnerByIdxBulk(Map<String, Object> param);
    
    int insertTransferHistory(Map<String, Object> param);
    
    int insertTransferDocBulk(Map<String, Object> param);
}
