package kr.co.genesiskorea.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.service.CommonService;
import kr.co.genesiskorea.service.SseEmitterService;

@Service
public class CommonServiceImpl implements CommonService {
	@Autowired 
	CommonDao commonDao;
	
	@Override
	public List<HashMap<String, String>> getCodeList(HashMap<String, String> param) {
		// TODO Auto-generated method stub
		return commonDao.getCodeList(param);
	}

	@Override
	public List<HashMap<String, Object>> getCompany() {
		// TODO Auto-generated method stub
		return commonDao.getCompany();
	}

	@Override
	public List<HashMap<String, Object>> getUnit() {
		// TODO Auto-generated method stub
		return commonDao.getUnit();
	}

	@Override
	public List<HashMap<String, Object>> getPlant(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return commonDao.getPlant(param);
	}
	
	@Override
	public List<Map<String, Object>> categoryList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return commonDao.categoryList(param);
	}

	@Override
	public List<Map<String, Object>> selectCategoryByPId(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return commonDao.selectCategoryByPId(param);
	}

	@Override
	public Map<String, String> selectFileData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return commonDao.selectFileData(param);
	}

	@Override
	public Object selectFileType(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return commonDao.selectFileType(param);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return commonDao.selectHistory(param);
	}

	@Override
	public void insertNotification(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		commonDao.insertNotification(param);
	}

	@Override
	public void insertNotificationHistory(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		commonDao.insertNotificationHistory(param);
	}

	@Override
	public int selectSeq( Map<String, Object> param ) {
		// TODO Auto-generated method stub
		return commonDao.selectSeq(param);
	}

	@Override
	public void notification(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		//1.noti seq를 조회한다.
		param.put("seqName", "lab_notification_seq");
		int idx = commonDao.selectSeq(param);
		//2.lab_notificaton에 데이터를 저장한다.
		param.put("idx", idx);
		commonDao.insertNotification(param);
		//3.lab_notificaton_history에 데이터를 저장한다.
		commonDao.insertNotificationHistory(param);
		//4.사용자에게 알림을 전송한다. 
		String url = "http://localhost:8080/send-data";
		//MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
		Map<String, Object> params = new HashMap<>();
		params.put("","");
		RestTemplate rt = new RestTemplate();		
		HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.set("accept","application/json");
        httpHeaders.set("Content-Type","application/json");
		//HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(params, headers);
		//HttpEntity<Map<String, Object>> entity = new HttpEntity<>(params, headers);
		HttpEntity<Map<String, Object>> entity = new HttpEntity<>(params, httpHeaders);

		ResponseEntity<String> response = rt.exchange(
		                url+"/"+param.get("targetUser"), //{요청할 서버 주소}
						HttpMethod.POST, //{요청할 방식}
		                entity, // {요청할 때 보낼 데이터}
		                String.class //{요청시 반환되는 데이터 타입}
		);
	}
	
	@Override
	public void notificationAll() {
		// TODO Auto-generated method stub
		String url = "http://localhost:8080/send-data/broadcast";
		//MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
		Map<String, Object> params = new HashMap<>();
		params.put("","");
		RestTemplate rt = new RestTemplate();		
		HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.set("accept","application/json");
        httpHeaders.set("Content-Type","application/json");
		HttpEntity<Map<String, Object>> entity = new HttpEntity<>(params, httpHeaders);

		ResponseEntity<String> response = rt.exchange(
		                url, //{요청할 서버 주소}
						HttpMethod.POST, //{요청할 방식}
		                entity, // {요청할 때 보낼 데이터}
		                String.class //{요청시 반환되는 데이터 타입}
		);
	}

	@Override
	public List<HashMap<String, Object>> selectNotification(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		//1. lab_notificaton에 데이터를 조회한다.
		List<HashMap<String, Object>> notiList = commonDao.selectNotification(param);
		//2. 조회한 lab_notificaton 데이터를 삭제한다.
		if( notiList != null && !notiList.isEmpty() ) {
			commonDao.deleteNotification(notiList);
		}
		return notiList;
	}

	@Override
	public List<Map<String, Object>> getCodeList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return commonDao.getCodeList(param);
	}

	
}
