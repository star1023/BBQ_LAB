package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface NoticeService {

	int selectNoticeCount(Map<String, Object> param);

    Map<String, Object> selectNoticeList(Map<String, Object> param) throws Exception;

    Map<String, Object> selectNoticeData(Map<String, Object> param);
    
    List<Map<String, Object>> selectHistory(Map<String, Object> param);
    
    int insertNotice(Map<String, Object> param, MultipartFile[] file) throws Exception;
    
    void updateNotice(Map<String, Object> param, MultipartFile[] files, String[] deletedFileList) throws Exception;
    
    int updateHits(Map<String, Object> param) throws Exception;
    
    void deleteNotice(Map<String, Object> param) throws Exception;

}
