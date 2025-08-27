package kr.co.genesiskorea.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.co.genesiskorea.dao.NotificationDao;
import kr.co.genesiskorea.service.NotificationService;
import kr.co.genesiskorea.util.PageNavigator;

@Service
public class NotificationServiceImpl implements NotificationService {

	@Autowired
	NotificationDao notificationDao;
	
	@Override
	public Map<String, Object> selectList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		int totalCount = notificationDao.selectListCount(param);
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

        List<Map<String, Object>> noticeList = notificationDao.selectList(param);

        Map<String, Object> result = new HashMap<>();
        result.put("pageNo", pageNo);
        result.put("totalCount", totalCount);
        result.put("list", noticeList);
        result.put("navi", navi); // PageNavigator 포함

        return result;
	}

}
