package kr.co.genesiskorea.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface FaqService {
	int selectFaqCount(Map<String, Object> param);

    Map<String, Object> selectFaqList(Map<String, Object> param) throws Exception;

    Map<String, Object> selectFaqData(Map<String, Object> param);
    
    List<Map<String, Object>> selectHistory(Map<String, Object> param);
    
    int insertFaq(Map<String, Object> param) throws Exception;
    
    void updateFaq(Map<String, Object> param, MultipartFile[] files, String[] deletedFileList) throws Exception;
    
    void deleteFaq(Map<String, Object> param) throws Exception;
}
