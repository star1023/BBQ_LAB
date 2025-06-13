package kr.co.genesiskorea.service.impl;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.web.multipart.MultipartFile;

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

import kr.co.genesiskorea.dao.BusinessTripPlanDao;
import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.service.BusinessTripPlanService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class BusinessTripPlanServiceImpl implements BusinessTripPlanService {
	private Logger logger = LogManager.getLogger(BusinessTripPlanServiceImpl.class);
	
	@Autowired
	BusinessTripPlanDao reportDao;
	
	@Autowired
	private Properties config;
	
	@Autowired
	CommonDao commonDao;
	
	@Resource
	DataSourceTransactionManager txManager;

	@Override
	public Map<String, Object> selectBusinessTripPlanList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = reportDao.selectBusinessTripPlanCount(param);
		
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
		
		List<Map<String, Object>> designList = reportDao.selectBusinessTripPlanList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", designList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	public int insertBusinessTripPlanTmp(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int planIdx = 0;
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
			
			
			planIdx = reportDao.selectTripPlanSeq();	//key value 조회
			param.put("idx", planIdx);
			
			//1. 출장계획 등록
			reportDao.insertBusinessTripPlan(param);			
			
			//2. 출장자 등록
			ArrayList<HashMap<String,Object>> userList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < deptArr.size() ; i++ ) {
				HashMap<String,Object> userMap = new HashMap<String,Object>();
				userMap.put("idx", planIdx);
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
				reportDao.insertBusinessTripPlanUser(userList);
			}
			
			//3. 추가 정보 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {					
					if( purposeArr.get(i) != null && !"".equals(purposeArr.get(i)) ) {
						HashMap<String,Object> purposeData = new HashMap<String,Object>();
						purposeData.put("idx", planIdx);
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
						featureData.put("idx", planIdx);
						featureData.put("displayOrder", i+1);
						featureData.put("infoType", "DEST");
						featureData.put("infoText", tripDestinationArr.get(i));
						addInfoList.add(featureData);
					}
				}
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				reportDao.insertBusinessTripPlanAddInfo(addInfoList);
			}
			
			//4. 업무수행내용 등록
			ArrayList<HashMap<String,Object>> contentList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < scheduleArr.size() ; i++ ) {
				HashMap<String,Object> contentMap = new HashMap<String,Object>();
				contentMap.put("idx", planIdx);
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
				reportDao.insertBusinessTripPlanContents(contentList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", planIdx);
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
				int idx = 0;
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
							fileMap.put("docIdx", planIdx);
							fileMap.put("docType", param.get("docType"));
							fileMap.put("fileType", "00");
							fileMap.put("orgFileName", multipartFile.getOriginalFilename());
							fileMap.put("filePath", path);
							fileMap.put("changeFileName", result);
							fileMap.put("content", content);
							System.err.println(fileMap);
							//파일정보 저장
							commonDao.insertFileInfo(fileMap);
							idx++;
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
		return planIdx;
	}

	@Override
	public int insertBusinessTripPlan(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int planIdx = 0;
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
			
			planIdx = reportDao.selectTripPlanSeq();	//key value 조회
			param.put("idx", planIdx);
			//param.put("status", "REG");
			
			//1. 출장계획 등록
			reportDao.insertBusinessTripPlan(param);
			
			//2. 출장자 등록
			ArrayList<HashMap<String,Object>> userList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < deptArr.size() ; i++ ) {
				HashMap<String,Object> userMap = new HashMap<String,Object>();
				userMap.put("idx", planIdx);
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
				reportDao.insertBusinessTripPlanUser(userList);
			}
			
			//3. 추가 정보 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {					
					if( purposeArr.get(i) != null && !"".equals(purposeArr.get(i)) ) {
						HashMap<String,Object> purposeData = new HashMap<String,Object>();
						purposeData.put("idx", planIdx);
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
						featureData.put("idx", planIdx);
						featureData.put("displayOrder", i+1);
						featureData.put("infoType", "DEST");
						featureData.put("infoText", tripDestinationArr.get(i));
						addInfoList.add(featureData);
					}
				}
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				reportDao.insertBusinessTripPlanAddInfo(addInfoList);
			}
			
			//4. 업무수행내용 등록
			ArrayList<HashMap<String,Object>> contentList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < scheduleArr.size() ; i++ ) {
				HashMap<String,Object> contentMap = new HashMap<String,Object>();
				contentMap.put("idx", planIdx);
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
				reportDao.insertBusinessTripPlanContents(contentList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", planIdx);
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
				int idx = 0;
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
							fileMap.put("docIdx", planIdx);
							fileMap.put("docType", param.get("docType"));
							fileMap.put("fileType", "00");
							fileMap.put("orgFileName", multipartFile.getOriginalFilename());
							fileMap.put("filePath", path);
							fileMap.put("changeFileName", result);
							fileMap.put("content", content);
							System.err.println(fileMap);
							//파일정보 저장
							commonDao.insertFileInfo(fileMap);
							idx++;
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
		return planIdx;
	}

	@Override
	public Map<String, Object> selectBusinessTripPlanData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		Map<String, Object> data = reportDao.selectBusinessTripPlanData(param);
		param.put("docType", "PLAN");
		List<Map<String, String>> fileList = commonDao.selectFileList(param);
		map.put("data", data);
		map.put("fileList", fileList);
		return map;
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripPlanUserList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectBusinessTripPlanUserList(param);
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripPlanAddInfoList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectBusinessTripPlanAddInfoList(param);
	}

	@Override
	public List<Map<String, Object>> selectBusinessTripPlanContentsList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectBusinessTripPlanContentsList(param);
	}

	@Override
	public void updateBusinessTripPlanTmp(Map<String, Object> param, MultipartFile[] file) throws Exception {
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
			
			//1. 출장계획 등록
			reportDao.updateBusinessTripPlan(param);			
			
			//2. 출장자 등록
			ArrayList<HashMap<String,Object>> userList = new ArrayList<HashMap<String,Object>>();
			reportDao.deleteBusinessTripPlanUser(param);
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
			if( userList != null && userList.size() > 0 ) {
				reportDao.insertBusinessTripPlanUser(userList);
			}
			
			//3. 추가 정보 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			reportDao.deleteBusinessTripPlanAddInfo(param);
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
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				reportDao.insertBusinessTripPlanAddInfo(addInfoList);
			}
			
			//4. 업무수행내용 등록
			ArrayList<HashMap<String,Object>> contentList = new ArrayList<HashMap<String,Object>>();
			reportDao.deleteBusinessTripPlanContents(param);
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
			if( contentList != null && contentList.size() > 0 ) {
				reportDao.insertBusinessTripPlanContents(contentList);
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
				int idx = 0;
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
							idx++;
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
	public void updateBusinessTripPlan(Map<String, Object> param, MultipartFile[] file) throws Exception {
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
			
			if( param.get("currentStatus") != null && "COND_APPR".equals(param.get("currentStatus")) ) {
				param.put("status", "APPR");
			}
			
			//1. 출장계획 등록
			reportDao.updateBusinessTripPlan(param);			
			
			//2. 출장자 등록
			ArrayList<HashMap<String,Object>> userList = new ArrayList<HashMap<String,Object>>();
			reportDao.deleteBusinessTripPlanUser(param);
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
			if( userList != null && userList.size() > 0 ) {
				reportDao.insertBusinessTripPlanUser(userList);
			}
			
			//3. 추가 정보 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			reportDao.deleteBusinessTripPlanAddInfo(param);
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
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				reportDao.insertBusinessTripPlanAddInfo(addInfoList);
			}
			
			//4. 업무수행내용 등록
			ArrayList<HashMap<String,Object>> contentList = new ArrayList<HashMap<String,Object>>();
			reportDao.deleteBusinessTripPlanContents(param);
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
			if( contentList != null && contentList.size() > 0 ) {
				reportDao.insertBusinessTripPlanContents(contentList);
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
				int idx = 0;
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
							idx++;
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
	public List<Map<String, Object>> searchBusinessTripPlanList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.searchBusinessTripPlanList(param);
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectHistory(param);
	}
}
