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

import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.dao.MarketResearchDao;
import kr.co.genesiskorea.service.MarketResearchService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class MarketResearchServiceImpl implements MarketResearchService {
private Logger logger = LogManager.getLogger(MarketResearchServiceImpl.class);
	
	@Autowired
	MarketResearchDao reportDao;
	
	@Autowired
	private Properties config;
	
	@Autowired
	CommonDao commonDao;
	
	@Resource
	DataSourceTransactionManager txManager;

	@Override
	public Map<String, Object> selectMarketResearchList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = reportDao.selectMarketResearchCount(param);
		
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
		
		List<Map<String, Object>> marketSearchList = reportDao.selectMarketResearchList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", marketSearchList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	public int insertMarketResearchTmp(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int researchIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray marketNameArr = (JSONArray) parser.parse((String)param.get("marketNameArr"));
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray marketAddressArr = (JSONArray) parser.parse((String)param.get("marketAddressArr"));
			JSONArray deptArr = (JSONArray) parser.parse((String)param.get("deptArr"));
			JSONArray positionArr = (JSONArray) parser.parse((String)param.get("positionArr"));
			JSONArray nameArr = (JSONArray) parser.parse((String)param.get("nameArr"));
			
			researchIdx = reportDao.selectMarketResearchSeq();	//key value 조회
			param.put("idx", researchIdx);
			
			//1. 출장계획 등록
			reportDao.insertMarketResearch(param);
			
			//2. 추가 정보 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( marketNameArr.size() > 0 ) {
				for( int i = 0 ; i < marketNameArr.size() ; i++ ) {					
					if( marketNameArr.get(i) != null && !"".equals(marketNameArr.get(i)) ) {
						HashMap<String,Object> marketNameData = new HashMap<String,Object>();
						marketNameData.put("idx", researchIdx);
						marketNameData.put("displayOrder", i+1);
						marketNameData.put("infoType", "NAME");
						marketNameData.put("infoText", marketNameArr.get(i));
						addInfoList.add(marketNameData);
					}
				}				
			}
			
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {
					if( purposeArr.get(i) != null && !"".equals(purposeArr.get(i)) ) {
						HashMap<String,Object> purposeData = new HashMap<String,Object>();
						purposeData.put("idx", researchIdx);
						purposeData.put("displayOrder", i+1);
						purposeData.put("infoType", "PUR");
						purposeData.put("infoText", purposeArr.get(i));
						addInfoList.add(purposeData);
					}
				}
			}
			
			if( marketAddressArr.size() > 0 ) {
				for( int i = 0 ; i < marketAddressArr.size() ; i++ ) {
					if( marketAddressArr.get(i) != null && !"".equals(marketAddressArr.get(i)) ) {
						HashMap<String,Object> marketAddressData = new HashMap<String,Object>();
						marketAddressData.put("idx", researchIdx);
						marketAddressData.put("displayOrder", i+1);
						marketAddressData.put("infoType", "ADDRESS");
						marketAddressData.put("infoText", marketAddressArr.get(i));
						addInfoList.add(marketAddressData);
					}
				}
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				reportDao.insertMarketResearchAddInfo(addInfoList);
			}
			
			//3. 출장자 등록
			ArrayList<HashMap<String,Object>> userList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < deptArr.size() ; i++ ) {
				HashMap<String,Object> userMap = new HashMap<String,Object>();
				userMap.put("idx", researchIdx);
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
				reportDao.insertMarketResearchUser(userList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", researchIdx);
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
				String path = config.getProperty("upload.file.path.research");
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
							fileMap.put("docIdx", researchIdx);
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
		return researchIdx;
	}

	@Override
	public int insertMarketResearch(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int researchIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray marketNameArr = (JSONArray) parser.parse((String)param.get("marketNameArr"));
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray marketAddressArr = (JSONArray) parser.parse((String)param.get("marketAddressArr"));
			JSONArray deptArr = (JSONArray) parser.parse((String)param.get("deptArr"));
			JSONArray positionArr = (JSONArray) parser.parse((String)param.get("positionArr"));
			JSONArray nameArr = (JSONArray) parser.parse((String)param.get("nameArr"));
			
			researchIdx = reportDao.selectMarketResearchSeq();	//key value 조회
			param.put("idx", researchIdx);
			
			//1. 출장계획 등록
			reportDao.insertMarketResearch(param);
			
			//2. 추가 정보 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( marketNameArr.size() > 0 ) {
				for( int i = 0 ; i < marketNameArr.size() ; i++ ) {					
					if( marketNameArr.get(i) != null && !"".equals(marketNameArr.get(i)) ) {
						HashMap<String,Object> marketNameData = new HashMap<String,Object>();
						marketNameData.put("idx", researchIdx);
						marketNameData.put("displayOrder", i+1);
						marketNameData.put("infoType", "NAME");
						marketNameData.put("infoText", marketNameArr.get(i));
						addInfoList.add(marketNameData);
					}
				}				
			}
			
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {
					if( purposeArr.get(i) != null && !"".equals(purposeArr.get(i)) ) {
						HashMap<String,Object> purposeData = new HashMap<String,Object>();
						purposeData.put("idx", researchIdx);
						purposeData.put("displayOrder", i+1);
						purposeData.put("infoType", "PUR");
						purposeData.put("infoText", purposeArr.get(i));
						addInfoList.add(purposeData);
					}
				}
			}
			
			if( marketAddressArr.size() > 0 ) {
				for( int i = 0 ; i < marketAddressArr.size() ; i++ ) {
					if( marketAddressArr.get(i) != null && !"".equals(marketAddressArr.get(i)) ) {
						HashMap<String,Object> marketAddressData = new HashMap<String,Object>();
						marketAddressData.put("idx", researchIdx);
						marketAddressData.put("displayOrder", i+1);
						marketAddressData.put("infoType", "ADDRESS");
						marketAddressData.put("infoText", marketAddressArr.get(i));
						addInfoList.add(marketAddressData);
					}
				}
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				reportDao.insertMarketResearchAddInfo(addInfoList);
			}
			
			//3. 출장자 등록
			ArrayList<HashMap<String,Object>> userList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < deptArr.size() ; i++ ) {
				HashMap<String,Object> userMap = new HashMap<String,Object>();
				userMap.put("idx", researchIdx);
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
				reportDao.insertMarketResearchUser(userList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", researchIdx);
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
				String path = config.getProperty("upload.file.path.research");
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
							fileMap.put("docIdx", researchIdx);
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
		return researchIdx;
	}

	@Override
	public Map<String, Object> selectMarketResearchData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		Map<String, Object> data = reportDao.selectMarketResearchData(param);
		param.put("docType", "RESEARCH");
		List<Map<String, String>> fileList = commonDao.selectFileList(param);
		map.put("data", data);
		map.put("fileList", fileList);
		return map;
	}

	@Override
	public List<Map<String, Object>> selectMarketResearchUserList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectMarketResearchUserList(param);
	}

	@Override
	public List<Map<String, Object>> selectMarketResearchAddInfoList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectMarketResearchAddInfoList(param);
	}

	@Override
	public void updateMarketResearchTmp(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray marketNameArr = (JSONArray) parser.parse((String)param.get("marketNameArr"));
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray marketAddressArr = (JSONArray) parser.parse((String)param.get("marketAddressArr"));
			JSONArray deptArr = (JSONArray) parser.parse((String)param.get("deptArr"));
			JSONArray positionArr = (JSONArray) parser.parse((String)param.get("positionArr"));
			JSONArray nameArr = (JSONArray) parser.parse((String)param.get("nameArr"));

			//1. 출장계획 등록
			reportDao.updateMarketResearch(param);
			
			//2. 추가 정보 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( marketNameArr.size() > 0 ) {
				for( int i = 0 ; i < marketNameArr.size() ; i++ ) {					
					if( marketNameArr.get(i) != null && !"".equals(marketNameArr.get(i)) ) {
						HashMap<String,Object> marketNameData = new HashMap<String,Object>();
						marketNameData.put("idx", param.get("idx"));
						marketNameData.put("displayOrder", i+1);
						marketNameData.put("infoType", "NAME");
						marketNameData.put("infoText", marketNameArr.get(i));
						addInfoList.add(marketNameData);
					}
				}				
			}
			
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
			
			if( marketAddressArr.size() > 0 ) {
				for( int i = 0 ; i < marketAddressArr.size() ; i++ ) {
					if( marketAddressArr.get(i) != null && !"".equals(marketAddressArr.get(i)) ) {
						HashMap<String,Object> marketAddressData = new HashMap<String,Object>();
						marketAddressData.put("idx", param.get("idx"));
						marketAddressData.put("displayOrder", i+1);
						marketAddressData.put("infoType", "ADDRESS");
						marketAddressData.put("infoText", marketAddressArr.get(i));
						addInfoList.add(marketAddressData);
					}
				}
			}
			
			reportDao.deleteMarketResearchAddInfo(param);
			if( addInfoList != null && addInfoList.size() > 0 ) {
				reportDao.insertMarketResearchAddInfo(addInfoList);
			}
			
			//3. 출장자 등록
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
			reportDao.deleteMarketResearchUser(param);
			if( userList != null && userList.size() > 0 ) {
				reportDao.insertMarketResearchUser(userList);
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
				String path = config.getProperty("upload.file.path.research");
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
	public void updateMarketResearch(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray marketNameArr = (JSONArray) parser.parse((String)param.get("marketNameArr"));
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray marketAddressArr = (JSONArray) parser.parse((String)param.get("marketAddressArr"));
			JSONArray deptArr = (JSONArray) parser.parse((String)param.get("deptArr"));
			JSONArray positionArr = (JSONArray) parser.parse((String)param.get("positionArr"));
			JSONArray nameArr = (JSONArray) parser.parse((String)param.get("nameArr"));
			
			//1. 출장계획 수정
			reportDao.updateMarketResearch(param);
			
			//2. 추가 정보 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( marketNameArr.size() > 0 ) {
				for( int i = 0 ; i < marketNameArr.size() ; i++ ) {					
					if( marketNameArr.get(i) != null && !"".equals(marketNameArr.get(i)) ) {
						HashMap<String,Object> marketNameData = new HashMap<String,Object>();
						marketNameData.put("idx", param.get("idx"));
						marketNameData.put("displayOrder", i+1);
						marketNameData.put("infoType", "NAME");
						marketNameData.put("infoText", marketNameArr.get(i));
						addInfoList.add(marketNameData);
					}
				}				
			}
			
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
			
			if( marketAddressArr.size() > 0 ) {
				for( int i = 0 ; i < marketAddressArr.size() ; i++ ) {
					if( marketAddressArr.get(i) != null && !"".equals(marketAddressArr.get(i)) ) {
						HashMap<String,Object> marketAddressData = new HashMap<String,Object>();
						marketAddressData.put("idx", param.get("idx"));
						marketAddressData.put("displayOrder", i+1);
						marketAddressData.put("infoType", "ADDRESS");
						marketAddressData.put("infoText", marketAddressArr.get(i));
						addInfoList.add(marketAddressData);
					}
				}
			}
			
			reportDao.deleteMarketResearchAddInfo(param);
			if( addInfoList != null && addInfoList.size() > 0 ) {
				reportDao.insertMarketResearchAddInfo(addInfoList);
			}
			
			//3. 출장자 등록
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
			reportDao.deleteMarketResearchUser(param);
			if( userList != null && userList.size() > 0 ) {
				reportDao.insertMarketResearchUser(userList);
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
				String path = config.getProperty("upload.file.path.research");
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
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectHistory(param);
	}

	@Override
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectMyDataCheck(param);
	}
}
