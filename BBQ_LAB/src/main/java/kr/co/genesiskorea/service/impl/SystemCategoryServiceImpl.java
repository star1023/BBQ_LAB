package kr.co.genesiskorea.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.co.genesiskorea.dao.SystemCategoryDao;
import kr.co.genesiskorea.service.SystemCategoryService;

@Service
public class SystemCategoryServiceImpl implements SystemCategoryService {
	@Autowired
	SystemCategoryDao categoryDao;

	@Override
	public List<Map<String, Object>> selectCategory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return categoryDao.selectCategory(param);
	}

	@Override
	public void insertCategory(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		boolean isNum = false;
		try{
			Integer.parseInt(param.get("id").toString());
			isNum = true;
		} catch(Exception e) {
			isNum = false;
		}
		
		if( isNum ) {
			Map<String, Object> map =  categoryDao.selectCategoryData(param);
			if( map != null && map.get("CATEGORY_IDX") != null && !"".equals(map.get("CATEGORY_IDX")) ) {
				categoryDao.updateCategoryName(param);
			} else {
				categoryDao.insertCategory(param);
			}
		} else {
			categoryDao.insertCategory(param);
		}
	}

	@Override
	public void deleteCategory(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		categoryDao.deleteCategory(param);
		//현재 ID보다 표시 순서가 큰 아이템들의 순서를 모두 -1 처리.
		categoryDao.updateCategoryOrder(param);
	}

	@Override
	public void updateCategory(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		
	}

	@Override
	public Map<String, String> updateMoveCategory(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		//이웃 카테고리를 조회 한다.
		Map<String, String> returnMap = new HashMap<String, String>();
		Map<String, Object> npCategory = categoryDao.selectNPCategory(param);
		//System.err.println("npCategory  :  "+npCategory);
		if( npCategory != null && npCategory.get("CATEGORY_IDX") != null && !"".equals(npCategory.get("CATEGORY_IDX")) ) {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("id", npCategory.get("CATEGORY_IDX"));
			int displayOrder = Integer.parseInt(""+npCategory.get("DISPLAY_ORDER"));
			if( param.get("div") != null && "UP".equals(param.get("div")) ) {
				paramMap.put("displayOrder", displayOrder+1);
			} else if( param.get("div") != null && "DOWN".equals(param.get("div")) ) {
				paramMap.put("displayOrder", displayOrder-1);
			}
			paramMap.put("div", param.get("div"));
			
			categoryDao.updateNPCategoryOrder(paramMap);			
			categoryDao.updateMyCategoryOrder(param);
			returnMap.put("RESULT", "S");
		} else {
			returnMap.put("RESULT", "F");
			if( param.get("div") != null && "UP".equals(param.get("div")) ) {
				returnMap.put("MESSAGE", "첫번째 항목입니다.");	
			} else {
				returnMap.put("MESSAGE", "마지막 항목입니다.");
			}
		}
		return returnMap;
	}
}
