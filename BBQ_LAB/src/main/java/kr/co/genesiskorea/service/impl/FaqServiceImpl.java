package kr.co.genesiskorea.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.dao.FaqDao;
import kr.co.genesiskorea.service.FaqService;
import kr.co.genesiskorea.util.PageNavigator;

@Service
public class FaqServiceImpl implements FaqService {
	@Autowired
    FaqDao faqDao;
	
	@Autowired
	CommonDao commonDao;
	
	@Autowired
	private Properties config;
	
	@Override
    public int selectFaqCount(Map<String, Object> param) {
        return faqDao.selectFaqCount(param);
    }

    @Override
    public Map<String, Object> selectFaqList(Map<String, Object> param) throws Exception {
        int totalCount = faqDao.selectFaqCount(param);

        int viewCount = 10;
        int pageNo = 1;

        try {
            viewCount = Integer.parseInt(String.valueOf(param.get("viewCount")));
            pageNo = Integer.parseInt(String.valueOf(param.get("pageNo")));
        } catch (Exception e) {
            System.err.println("페이징 파라미터 오류: " + e.getMessage());
            viewCount = 10;
            pageNo = 1;
        }

        // PageNavigator를 통해 startRow, endRow 계산
        PageNavigator navi = new PageNavigator(param, viewCount, totalCount);

        List<Map<String, Object>> noticeList = faqDao.selectFaqList(param);

        Map<String, Object> result = new HashMap<>();
        result.put("pageNo", pageNo);
        result.put("totalCount", totalCount);
        result.put("list", noticeList);
        result.put("navi", navi); // PageNavigator 포함

        return result;
    }

    @Override
    public Map<String, Object> selectFaqData(Map<String, Object> param) {
        Map<String, Object> data = faqDao.selectFaqData(param);
        Map<String, Object> result = new HashMap<>();
        result.put("data", data);
        return result;
    }
    
	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return faqDao.selectHistory(param);
	}
	
	@Override
	public int insertFaq(Map<String, Object> param) throws Exception {
	    int noticeIdx = 0;
	    try {
	        // 공지사항 IDX 생성
	        noticeIdx = faqDao.selectFaqSeq();
	        param.put("idx", noticeIdx);
	        
	        // 1. 공지사항 등록
	        faqDao.insertFaq(param);

	    } catch (Exception e) {
	        throw e;
	    }
	    return noticeIdx;
	}
	
	@Override
	public void updateFaq(Map<String, Object> param, MultipartFile[] files, String[] deletedFileList) throws Exception {
	    try {

	        // 1. FAQ 기본 정보 업데이트
	    	faqDao.updateFaq(param);

	    } catch (Exception e) {
	        System.err.println("[updateFaq] 오류 발생:");
	        e.printStackTrace();
	        throw e;
	    }
	}
	
	@Override
	public void deleteFaq(Map<String, Object> param) throws Exception {
		faqDao.updateIsDeleteY(param); // is_delete = 'Y'로 업데이트
	}
}
