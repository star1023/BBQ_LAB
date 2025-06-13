package kr.co.genesiskorea.service.impl;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.dao.BusinessTripDao;
import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.service.BusinessTripService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class BusinessTripServiceImpl implements BusinessTripService {
private Logger logger = LogManager.getLogger(BusinessTripServiceImpl.class);
	
	@Autowired
	BusinessTripDao reportDao;
	
	@Autowired
	private Properties config;
	
	@Autowired
	CommonDao commonDao;
	
	@Resource
	DataSourceTransactionManager txManager;

	@Override
	public Map<String, Object> selectBusinessTripList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = reportDao.selectBusinessTripCount(param);
		
		int viewCount = 10;
		int pageNo = 1;
		try {
			pageNo = Integer.parseInt((String)param.get("pageNo"));
		} catch( Exception e ) {
			System.err.println(e.getMessage());
			pageNo = 1;
		}
		
		try {
			viewCount = Integer.parseInt((String)param.get("viewCount"));
		} catch( Exception e ) {
			System.err.println(e.getMessage());
			viewCount = 10;
		}
		
		// 페이징: 페이징 정보 SET
		PageNavigator navi = new PageNavigator(param, viewCount, totalCount);
		
		List<Map<String, Object>> designList = reportDao.selectBusinessTripList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", designList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	public int insertBusinessTripTmp(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int tripIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray deptArr = (JSONArray) parser.parse((String)param.get("deptArr"));
			JSONArray positionArr = (JSONArray) parser.parse((String)param.get("positionArr"));
			JSONArray nameArr = (JSONArray) parser.parse((String)param.get("nameArr"));
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray tripDestinationArr = (JSONArray) parser.parse((String)param.get("tripDestinationArr"));
			JSONArray scheduleArr = (JSONArray) parser.parse((String)param.get("scheduleArr"));
			JSONArray contentArr = (JSONArray) parser.parse((String)param.get("contentArr"));
			JSONArray placeArr = (JSONArray) parser.parse((String)param.get("placeArr"));
			JSONArray noteArr = (JSONArray) parser.parse((String)param.get("noteArr"));
			
			tripIdx = reportDao.selectTripSeq();	//key value 조회
			param.put("idx", tripIdx);
			
			//출장결과 등록
			reportDao.insertBusinessTrip(param);
			
			//2. 출장자 등록
			ArrayList<HashMap<String,Object>> userList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < deptArr.size() ; i++ ) {
				HashMap<String,Object> userMap = new HashMap<String,Object>();
				userMap.put("idx", tripIdx);
				userMap.put("displayOrder", i+1);
				
				try{
					userMap.put("dept", deptArr.get(i));
				} catch(Exception e) {
					userMap.put("dept", "");
				}
				
				try{
					userMap.put("position", positionArr.get(i));
				} catch(Exception e) {
					userMap.put("position", "");
				}
				
				try{
					userMap.put("name", nameArr.get(i));
				} catch(Exception e) {
					userMap.put("name", "");
				}
				
				userList.add(userMap);
			}			
			if( userList != null && userList.size() > 0 ) {
				reportDao.insertBusinessTripUser(userList);
			}
			
			//3. 추가 정보 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {					
					if( purposeArr.get(i) != null && !"".equals(purposeArr.get(i)) ) {
						HashMap<String,Object> purposeData = new HashMap<String,Object>();
						purposeData.put("idx", tripIdx);
						purposeData.put("displayOrder", i+1);
						purposeData.put("infoType", "PUR");
						purposeData.put("infoText", purposeArr.get(i));
						addInfoList.add(purposeData);
					}
				}				
			}
			
			if( tripDestinationArr.size() > 0 ) {
				for( int i = 0 ; i < tripDestinationArr.size() ; i++ ) {
					if( tripDestinationArr.get(i) != null && !"".equals(tripDestinationArr.get(i)) ) {
						HashMap<String,Object> featureData = new HashMap<String,Object>();
						featureData.put("idx", tripIdx);
						featureData.put("displayOrder", i+1);
						featureData.put("infoType", "DEST");
						featureData.put("infoText", tripDestinationArr.get(i));
						addInfoList.add(featureData);
					}
				}
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				reportDao.insertBusinessTripAddInfo(addInfoList);
			}
			
			//4. 업무수행내용 등록
			ArrayList<HashMap<String,Object>> contentList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < scheduleArr.size() ; i++ ) {
				HashMap<String,Object> contentMap = new HashMap<String,Object>();
				contentMap.put("idx", tripIdx);
				contentMap.put("displayOrder", i+1);
				
				try{
					contentMap.put("schedule", scheduleArr.get(i));
				} catch(Exception e) {
					contentMap.put("schedule", "");
				}
				
				try{
					contentMap.put("content", contentArr.get(i));
				} catch(Exception e) {
					contentMap.put("content", "");
				}
				
				try{
					contentMap.put("place", placeArr.get(i));
				} catch(Exception e) {
					contentMap.put("place", "");
				}
				
				try{
					contentMap.put("note", noteArr.get(i));
				} catch(Exception e) {
					contentMap.put("note", "");
				}
				
				contentList.add(contentMap);
			}			
			if( contentList != null && contentList.size() > 0 ) {
				reportDao.insertBusinessTripContents(contentList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", tripIdx);
			historyParam.put("docType", param.get("docType"));
			historyParam.put("historyType", "T");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				Calendar cal = Calendar.getInstance();
		        Date day = cal.getTime();    //시간을 꺼낸다.
		        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
		        String toDay = sdf.format(day);
				String path = config.getProperty("upload.file.path.trip");
				path += "/"+toDay; 
				for( MultipartFile multipartFile : file ) {
					System.err.println("=================================");
					System.err.println("isEmpty : "+multipartFile.isEmpty());
					System.err.println("name : " + multipartFile.getName());
					System.err.println("originalFilename : " + multipartFile.getOriginalFilename());		
					System.err.println("size : " + multipartFile.getSize());				
					System.err.println("=================================");
					try {
						if( !multipartFile.isEmpty() ) {
							String fileIdx = FileUtil.getUUID();
							String result = FileUtil.upload3(multipartFile,path,fileIdx);
							String content = FileUtil.getPdfContents(path, result);
							Map<String,Object> fileMap = new HashMap<String,Object>();
							fileMap.put("fileIdx", fileIdx);
							fileMap.put("docIdx", tripIdx);
							fileMap.put("docType", param.get("docType"));
							fileMap.put("fileType", "00");
							fileMap.put("orgFileName", multipartFile.getOriginalFilename());
							fileMap.put("filePath", path);
							fileMap.put("changeFileName", result);
							fileMap.put("content", content);
							System.err.println(fileMap);
							//파일정보 저장
							commonDao.insertFileInfo(fileMap);
						}
					} catch( Exception e ) {
						//throw e;
					}					
				}
			}
			
			txManager.commit(status);
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
		return tripIdx;
	}

	@Override
	public int insertBusinessTrip(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int tripIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray deptArr = (JSONArray) parser.parse((String)param.get("deptArr"));
			JSONArray positionArr = (JSONArray) parser.parse((String)param.get("positionArr"));
			JSONArray nameArr = (JSONArray) parser.parse((String)param.get("nameArr"));
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray tripDestinationArr = (JSONArray) parser.parse((String)param.get("tripDestinationArr"));
			JSONArray scheduleArr = (JSONArray) parser.parse((String)param.get("scheduleArr"));
			JSONArray contentArr = (JSONArray) parser.parse((String)param.get("contentArr"));
			JSONArray placeArr = (JSONArray) parser.parse((String)param.get("placeArr"));
			JSONArray noteArr = (JSONArray) parser.parse((String)param.get("noteArr"));
			
			tripIdx = reportDao.selectTripSeq();	//key value 조회
			param.put("idx", tripIdx);
			
			//출장결과 등록
			reportDao.insertBusinessTrip(param);
			
			//2. 출장자 등록
			ArrayList<HashMap<String,Object>> userList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < deptArr.size() ; i++ ) {
				HashMap<String,Object> userMap = new HashMap<String,Object>();
				userMap.put("idx", tripIdx);
				userMap.put("displayOrder", i+1);
				
				try{
					userMap.put("dept", deptArr.get(i));
				} catch(Exception e) {
					userMap.put("dept", "");
				}
				
				try{
					userMap.put("position", positionArr.get(i));
				} catch(Exception e) {
					userMap.put("position", "");
				}
				
				try{
					userMap.put("name", nameArr.get(i));
				} catch(Exception e) {
					userMap.put("name", "");
				}
				
				userList.add(userMap);
			}			
			if( userList != null && userList.size() > 0 ) {
				reportDao.insertBusinessTripUser(userList);
			}
			
			//3. 추가 정보 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {					
					if( purposeArr.get(i) != null && !"".equals(purposeArr.get(i)) ) {
						HashMap<String,Object> purposeData = new HashMap<String,Object>();
						purposeData.put("idx", tripIdx);
						purposeData.put("displayOrder", i+1);
						purposeData.put("infoType", "PUR");
						purposeData.put("infoText", purposeArr.get(i));
						addInfoList.add(purposeData);
					}
				}				
			}
			
			if( tripDestinationArr.size() > 0 ) {
				for( int i = 0 ; i < tripDestinationArr.size() ; i++ ) {
					if( tripDestinationArr.get(i) != null && !"".equals(tripDestinationArr.get(i)) ) {
						HashMap<String,Object> featureData = new HashMap<String,Object>();
						featureData.put("idx", tripIdx);
						featureData.put("displayOrder", i+1);
						featureData.put("infoType", "DEST");
						featureData.put("infoText", tripDestinationArr.get(i));
						addInfoList.add(featureData);
					}
				}
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				reportDao.insertBusinessTripAddInfo(addInfoList);
			}
			
			//4. 업무수행내용 등록
			ArrayList<HashMap<String,Object>> contentList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < scheduleArr.size() ; i++ ) {
				HashMap<String,Object> contentMap = new HashMap<String,Object>();
				contentMap.put("idx", tripIdx);
				contentMap.put("displayOrder", i+1);
				
				try{
					contentMap.put("schedule", scheduleArr.get(i));
				} catch(Exception e) {
					contentMap.put("schedule", "");
				}
				
				try{
					contentMap.put("content", contentArr.get(i));
				} catch(Exception e) {
					contentMap.put("content", "");
				}
				
				try{
					contentMap.put("place", placeArr.get(i));
				} catch(Exception e) {
					contentMap.put("place", "");
				}
				
				try{
					contentMap.put("note", noteArr.get(i));
				} catch(Exception e) {
					contentMap.put("note", "");
				}
				
				contentList.add(contentMap);
			}			
			if( contentList != null && contentList.size() > 0 ) {
				reportDao.insertBusinessTripContents(contentList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", tripIdx);
			historyParam.put("docType", param.get("docType"));
			historyParam.put("historyType", "I");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				Calendar cal = Calendar.getInstance();
		        Date day = cal.getTime();    //시간을 꺼낸다.
		        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
		        String toDay = sdf.format(day);
				String path = config.getProperty("upload.file.path.trip");
				path += "/"+toDay; 
				for( MultipartFile multipartFile : file ) {
					System.err.println("=================================");
					System.err.println("isEmpty : "+multipartFile.isEmpty());
					System.err.println("name : " + multipartFile.getName());
					System.err.println("originalFilename : " + multipartFile.getOriginalFilename());		
					System.err.println("size : " + multipartFile.getSize());				
					System.err.println("=================================");
					try {
						if( !multipartFile.isEmpty() ) {
							String fileIdx = FileUtil.getUUID();
							String result = FileUtil.upload3(multipartFile,path,fileIdx);
							String content = FileUtil.getPdfContents(path, result);
							Map<String,Object> fileMap = new HashMap<String,Object>();
							fileMap.put("fileIdx", fileIdx);
							fileMap.put("docIdx", tripIdx);
							fileMap.put("docType", param.get("docType"));
							fileMap.put("fileType", "00");
							fileMap.put("orgFileName", multipartFile.getOriginalFilename());
							fileMap.put("filePath", path);
							fileMap.put("changeFileName", result);
							fileMap.put("content", content);
							System.err.println(fileMap);
							//파일정보 저장
							commonDao.insertFileInfo(fileMap);
						}
					} catch( Exception e ) {
						//throw e;
					}					
				}
			}
			
			txManager.commit(status);
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
		return tripIdx;
	}

	@Override
	public Map<String, Object> selectBusinessTripData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		Map<String, Object> data = reportDao.selectBusinessTripData(param);
		param.put("docType", "TRIP");
		List<Map<String, String>> fileList = commonDao.selectFileList(param);
		map.put("data", data);
		map.put("fileList", fileList);
		return map;
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripUserList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectBusinessTripUserList(param);
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripAddInfoList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectBusinessTripAddInfoList(param);
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripContentsList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectBusinessTripContentsList(param);
	}

	@Override
	public void updateBusinessTripTmp(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray deptArr = (JSONArray) parser.parse((String)param.get("deptArr"));
			JSONArray positionArr = (JSONArray) parser.parse((String)param.get("positionArr"));
			JSONArray nameArr = (JSONArray) parser.parse((String)param.get("nameArr"));
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray tripDestinationArr = (JSONArray) parser.parse((String)param.get("tripDestinationArr"));
			JSONArray scheduleArr = (JSONArray) parser.parse((String)param.get("scheduleArr"));
			JSONArray contentArr = (JSONArray) parser.parse((String)param.get("contentArr"));
			JSONArray placeArr = (JSONArray) parser.parse((String)param.get("placeArr"));
			JSONArray noteArr = (JSONArray) parser.parse((String)param.get("noteArr"));
			
			//출장결과 수정
			reportDao.updateBusinessTrip(param);
			
			//2. 출장자 등록
			ArrayList<HashMap<String,Object>> userList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < deptArr.size() ; i++ ) {
				HashMap<String,Object> userMap = new HashMap<String,Object>();
				userMap.put("idx", param.get("idx"));
				userMap.put("displayOrder", i+1);
				
				try{
					userMap.put("dept", deptArr.get(i));
				} catch(Exception e) {
					userMap.put("dept", "");
				}
				
				try{
					userMap.put("position", positionArr.get(i));
				} catch(Exception e) {
					userMap.put("position", "");
				}
				
				try{
					userMap.put("name", nameArr.get(i));
				} catch(Exception e) {
					userMap.put("name", "");
				}
				
				userList.add(userMap);
			}			
			reportDao.deleteBusinessTripUser(param);
			if( userList != null && userList.size() > 0 ) {
				reportDao.insertBusinessTripUser(userList);
			}
			
			//3. 추가 정보 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {					
					if( purposeArr.get(i) != null && !"".equals(purposeArr.get(i)) ) {
						HashMap<String,Object> purposeData = new HashMap<String,Object>();
						purposeData.put("idx", param.get("idx"));
						purposeData.put("displayOrder", i+1);
						purposeData.put("infoType", "PUR");
						purposeData.put("infoText", purposeArr.get(i));
						addInfoList.add(purposeData);
					}
				}				
			}
			
			if( tripDestinationArr.size() > 0 ) {
				for( int i = 0 ; i < tripDestinationArr.size() ; i++ ) {
					if( tripDestinationArr.get(i) != null && !"".equals(tripDestinationArr.get(i)) ) {
						HashMap<String,Object> featureData = new HashMap<String,Object>();
						featureData.put("idx", param.get("idx"));
						featureData.put("displayOrder", i+1);
						featureData.put("infoType", "DEST");
						featureData.put("infoText", tripDestinationArr.get(i));
						addInfoList.add(featureData);
					}
				}
			}
			
			reportDao.deleteBusinessTripAddInfo(param);
			if( addInfoList != null && addInfoList.size() > 0 ) {
				reportDao.insertBusinessTripAddInfo(addInfoList);
			}
			
			//4. 업무수행내용 등록
			ArrayList<HashMap<String,Object>> contentList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < scheduleArr.size() ; i++ ) {
				HashMap<String,Object> contentMap = new HashMap<String,Object>();
				contentMap.put("idx", param.get("idx"));
				contentMap.put("displayOrder", i+1);
				
				try{
					contentMap.put("schedule", scheduleArr.get(i));
				} catch(Exception e) {
					contentMap.put("schedule", "");
				}
				
				try{
					contentMap.put("content", contentArr.get(i));
				} catch(Exception e) {
					contentMap.put("content", "");
				}
				
				try{
					contentMap.put("place", placeArr.get(i));
				} catch(Exception e) {
					contentMap.put("place", "");
				}
				
				try{
					contentMap.put("note", noteArr.get(i));
				} catch(Exception e) {
					contentMap.put("note", "");
				}
				
				contentList.add(contentMap);
			}
			reportDao.deleteBusinessTripContents(param);
			if( contentList != null && contentList.size() > 0 ) {
				reportDao.insertBusinessTripContents(contentList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", param.get("idx"));
			historyParam.put("docType", param.get("docType"));
			historyParam.put("historyType", "U");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				Calendar cal = Calendar.getInstance();
		        Date day = cal.getTime();    //시간을 꺼낸다.
		        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
		        String toDay = sdf.format(day);
				String path = config.getProperty("upload.file.path.trip");
				path += "/"+toDay; 
				for( MultipartFile multipartFile : file ) {
					System.err.println("=================================");
					System.err.println("isEmpty : "+multipartFile.isEmpty());
					System.err.println("name : " + multipartFile.getName());
					System.err.println("originalFilename : " + multipartFile.getOriginalFilename());		
					System.err.println("size : " + multipartFile.getSize());				
					System.err.println("=================================");
					try {
						if( !multipartFile.isEmpty() ) {
							String fileIdx = FileUtil.getUUID();
							String result = FileUtil.upload3(multipartFile,path,fileIdx);
							String content = FileUtil.getPdfContents(path, result);
							Map<String,Object> fileMap = new HashMap<String,Object>();
							fileMap.put("fileIdx", fileIdx);
							fileMap.put("docIdx", param.get("idx"));
							fileMap.put("docType", param.get("docType"));
							fileMap.put("fileType", "00");
							fileMap.put("orgFileName", multipartFile.getOriginalFilename());
							fileMap.put("filePath", path);
							fileMap.put("changeFileName", result);
							fileMap.put("content", content);
							System.err.println(fileMap);
							//파일정보 저장
							commonDao.insertFileInfo(fileMap);
						}
					} catch( Exception e ) {
						//throw e;
					}					
				}
			}
			txManager.commit(status);
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public void updateBusinessTrip(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			int tripIdx = Integer.parseInt((String)param.get("idx")); 	//key value 조회
			if( param.get("currentStatus") != null && "COND_APPR".equals(param.get("currentStatus")) ) {
				param.put("status", "APPR");
			}
			
			JSONParser parser = new JSONParser();
			JSONArray deptArr = (JSONArray) parser.parse((String)param.get("deptArr"));
			JSONArray positionArr = (JSONArray) parser.parse((String)param.get("positionArr"));
			JSONArray nameArr = (JSONArray) parser.parse((String)param.get("nameArr"));
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray tripDestinationArr = (JSONArray) parser.parse((String)param.get("tripDestinationArr"));
			JSONArray scheduleArr = (JSONArray) parser.parse((String)param.get("scheduleArr"));
			JSONArray contentArr = (JSONArray) parser.parse((String)param.get("contentArr"));
			JSONArray placeArr = (JSONArray) parser.parse((String)param.get("placeArr"));
			JSONArray noteArr = (JSONArray) parser.parse((String)param.get("noteArr"));
			
			//출장결과 수정
			reportDao.updateBusinessTrip(param);
			
			//2. 출장자 등록
			ArrayList<HashMap<String,Object>> userList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < deptArr.size() ; i++ ) {
				HashMap<String,Object> userMap = new HashMap<String,Object>();
				userMap.put("idx", param.get("idx"));
				userMap.put("displayOrder", i+1);
				
				try{
					userMap.put("dept", deptArr.get(i));
				} catch(Exception e) {
					userMap.put("dept", "");
				}
				
				try{
					userMap.put("position", positionArr.get(i));
				} catch(Exception e) {
					userMap.put("position", "");
				}
				
				try{
					userMap.put("name", nameArr.get(i));
				} catch(Exception e) {
					userMap.put("name", "");
				}
				
				userList.add(userMap);
			}			
			reportDao.deleteBusinessTripUser(param);
			if( userList != null && userList.size() > 0 ) {
				reportDao.insertBusinessTripUser(userList);
			}
			
			//3. 추가 정보 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {					
					if( purposeArr.get(i) != null && !"".equals(purposeArr.get(i)) ) {
						HashMap<String,Object> purposeData = new HashMap<String,Object>();
						purposeData.put("idx", param.get("idx"));
						purposeData.put("displayOrder", i+1);
						purposeData.put("infoType", "PUR");
						purposeData.put("infoText", purposeArr.get(i));
						addInfoList.add(purposeData);
					}
				}				
			}
			
			if( tripDestinationArr.size() > 0 ) {
				for( int i = 0 ; i < tripDestinationArr.size() ; i++ ) {
					if( tripDestinationArr.get(i) != null && !"".equals(tripDestinationArr.get(i)) ) {
						HashMap<String,Object> featureData = new HashMap<String,Object>();
						featureData.put("idx", param.get("idx"));
						featureData.put("displayOrder", i+1);
						featureData.put("infoType", "DEST");
						featureData.put("infoText", tripDestinationArr.get(i));
						addInfoList.add(featureData);
					}
				}
			}
			
			reportDao.deleteBusinessTripAddInfo(param);
			if( addInfoList != null && addInfoList.size() > 0 ) {
				reportDao.insertBusinessTripAddInfo(addInfoList);
			}
			
			//4. 업무수행내용 등록
			ArrayList<HashMap<String,Object>> contentList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < scheduleArr.size() ; i++ ) {
				HashMap<String,Object> contentMap = new HashMap<String,Object>();
				contentMap.put("idx", param.get("idx"));
				contentMap.put("displayOrder", i+1);
				
				try{
					contentMap.put("schedule", scheduleArr.get(i));
				} catch(Exception e) {
					contentMap.put("schedule", "");
				}
				
				try{
					contentMap.put("content", contentArr.get(i));
				} catch(Exception e) {
					contentMap.put("content", "");
				}
				
				try{
					contentMap.put("place", placeArr.get(i));
				} catch(Exception e) {
					contentMap.put("place", "");
				}
				
				try{
					contentMap.put("note", noteArr.get(i));
				} catch(Exception e) {
					contentMap.put("note", "");
				}
				
				contentList.add(contentMap);
			}
			reportDao.deleteBusinessTripContents(param);
			if( contentList != null && contentList.size() > 0 ) {
				reportDao.insertBusinessTripContents(contentList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", param.get("idx"));
			historyParam.put("docType", param.get("docType"));
			historyParam.put("historyType", "U");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				Calendar cal = Calendar.getInstance();
		        Date day = cal.getTime();    //시간을 꺼낸다.
		        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
		        String toDay = sdf.format(day);
				String path = config.getProperty("upload.file.path.trip");
				path += "/"+toDay; 
				for( MultipartFile multipartFile : file ) {
					System.err.println("=================================");
					System.err.println("isEmpty : "+multipartFile.isEmpty());
					System.err.println("name : " + multipartFile.getName());
					System.err.println("originalFilename : " + multipartFile.getOriginalFilename());		
					System.err.println("size : " + multipartFile.getSize());				
					System.err.println("=================================");
					try {
						if( !multipartFile.isEmpty() ) {
							String fileIdx = FileUtil.getUUID();
							String result = FileUtil.upload3(multipartFile,path,fileIdx);
							String content = FileUtil.getPdfContents(path, result);
							Map<String,Object> fileMap = new HashMap<String,Object>();
							fileMap.put("fileIdx", fileIdx);
							fileMap.put("docIdx", param.get("idx"));
							fileMap.put("docType", param.get("docType"));
							fileMap.put("fileType", "00");
							fileMap.put("orgFileName", multipartFile.getOriginalFilename());
							fileMap.put("filePath", path);
							fileMap.put("changeFileName", result);
							fileMap.put("content", content);
							System.err.println(fileMap);
							//파일정보 저장
							commonDao.insertFileInfo(fileMap);
						}
					} catch( Exception e ) {
						//throw e;
					}					
				}
			}
			txManager.commit(status);
			if( param.get("currentStatus") != null && "COND_APPR".equals(param.get("currentStatus")) ) {
				//다음 결재자에게 메일을 보낸다.
			}
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectHistory(param);
	}
}
