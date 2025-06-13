package kr.co.genesiskorea.dao;

import java.util.List;
import java.util.Map;

public interface NoticeDao {
	int selectNoticeCount(Map<String, Object> param);

    List<Map<String, Object>> selectNoticeList(Map<String, Object> param);

    Map<String, Object> selectNoticeData(Map<String, Object> param);
    
    List<Map<String, Object>> selectHistory(Map<String, Object> param);
    
    int selectNoticeSeq();
    
    void insertNotice(Map<String, Object> param) throws Exception;
    
    void updateNotice(Map<String, Object> param);
    
    int updateHits(Map<String, Object> param);
    
    void updateIsDeleteY(Map<String, Object> param);
}
