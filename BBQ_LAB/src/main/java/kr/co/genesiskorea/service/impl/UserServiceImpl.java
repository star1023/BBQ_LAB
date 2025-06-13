package kr.co.genesiskorea.service.impl;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.commons.beanutils.BeanUtils;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.co.genesiskorea.common.auth.Auth;
import kr.co.genesiskorea.common.auth.AuthUtil;
import kr.co.genesiskorea.dao.UserDao;
import kr.co.genesiskorea.service.UserService;
import kr.co.genesiskorea.util.CommonException;
import kr.co.genesiskorea.util.PageNavigator;

@Service
public class UserServiceImpl implements UserService {
	
	@Autowired
	UserDao userDao;
	
	@Override
	public HashMap<String, Object> login(Map<String, Object> param, HttpServletRequest request) throws Exception {
		// TODO Auto-generated method stub
		HashMap<String, Object> userMap = userDao.selectUser(param);
		
		if( userMap == null ) {
			throw new CommonException("NO_USER");
		}
		if( userMap != null && "Y".equals(userMap.get("isLock")) ) {
			throw new CommonException("USER_LOCK");
		}
		if( userMap != null && "Y".equals(userMap.get("isDelete")) ) {
			throw new CommonException("USER_DELETE");
		}
		
		param.put("roleCode", userMap.get("roleCode"));
		List<Map<String,Object>> userMenu = userDao.selectUserMenu(param);
		
		JSONArray jArr = new JSONArray();
		for (Map<String, Object> menu : userMenu) {
			Iterator<String> itr = menu.keySet().iterator();

			JSONObject jObj = new JSONObject();
			while (itr.hasNext()) {
				String key = itr.next();
				String value = String.valueOf(menu.get(key));
				jObj.put(key, value);
			}
			jArr.add(jObj);
		}
		HttpSession session = request.getSession(false);
		session.setAttribute("USER_MENU", jArr);
		
		Auth auth = new Auth();
		BeanUtils.copyProperties(auth, userMap);
		AuthUtil.setAuth(request, auth);
		userDao.insertLginLog(userMap);
		return userMap;
	}

	@Override
	public Map<String, Object> getUserList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		
		// 페이징: 페이징 정보 SET
		int totalCount = userDao.getUserCount(param);
		
		PageNavigator navi = new PageNavigator(param, totalCount);
		
		List<HashMap<String, Object>> list = userDao.getUserList(param);
		
		map.put("navi", navi);
		map.put("list", list);
		map.put("totalCount", totalCount);
		
		return map;
	}

	@Override
	public int checkId(String userId) {
		// TODO Auto-generated method stub
		return userDao.checkId(userId);
	}

	@Override
	public void inserUser(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		userDao.inserUser(param);
	}

	@Override
	public void insertLog(Map<String, Object> logParam) {
		// TODO Auto-generated method stub
		userDao.insertLog(logParam);
	}

	@Override
	public Map<String, Object> selectUserData(String userId) {
		// TODO Auto-generated method stub
		return userDao.selectUserData(userId);
	}

	@Override
	public void updateUser(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		userDao.updateUser(param);
	}

	@Override
	public void deleteUser(String userId) throws Exception {
		// TODO Auto-generated method stub
		userDao.deleteUser(userId);
	}

	@Override
	public void restoreUser(String userId) throws Exception {
		// TODO Auto-generated method stub
		userDao.restoreUser(userId);
	}

	@Override
	public void unlockUser(String userId) throws Exception {
		// TODO Auto-generated method stub
		userDao.unlockUser(userId);
	}

	@Override
	public int insertAccessLog(HashMap<String, Object> param) {
		// TODO Auto-generated method stub
		int seq = userDao.selectAccessLogSeq();
		param.put("idx", seq);
		int insertCnt = userDao.insertAccessLog(param);
		String requestParams = (String)param.get("requestParams");
		if(requestParams != null && requestParams.length() > 0 ) {
			userDao.insertAccessLogParams(param);
		}
		
		return insertCnt;
	}

	@Override
	public void logout(HttpServletRequest request) throws Exception {
		// TODO Auto-generated method stub
		Auth auth = AuthUtil.getAuth(request);
		AuthUtil.removeAuth(request);
	}

	@Override
	public void setPersonalization(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		userDao.setPersonalization(param);
	}
	
}
