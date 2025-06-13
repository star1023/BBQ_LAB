package kr.co.genesiskorea.service.impl;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.simple.JSONArray;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.dao.ApprovalDao;
import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.dao.SenseQualityDao;
import kr.co.genesiskorea.service.CommonService;
import kr.co.genesiskorea.service.SenseQualityService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class SenseQualityServiceImpl implements SenseQualityService {
	private Logger logger = LogManager.getLogger(SenseQualityServiceImpl.class);
	
	@Autowired
	SenseQualityDao reportDao;
	
	@Autowired
	private Properties config;
	
	@Autowired
	CommonDao commonDao;
	
	@Autowired
	CommonService commonService;
	
	@Autowired
	ApprovalDao approvalDao;
	
	@Resource
	DataSourceTransactionManager txManager;
	
	@Override
	public Map<String, Object> selectSenseQualityList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = reportDao.selectSenseQualityCount(param);
		
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
		
		List<Map<String, Object>> designList = reportDao.selectSenseQualityList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", designList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	@Transactional
	public int insertSenseQualityTmp(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		int reportIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONArray contentsDivArr = (JSONArray)listMap.get("contentsDivArr");
			JSONArray contentsResultArr = (JSONArray)listMap.get("contentsResultArr");
			JSONArray contentsNoteArr = (JSONArray)listMap.get("contentsNoteArr");
			JSONArray resultArr = (JSONArray)listMap.get("resultArr");
			//1. key value 조회
			reportIdx = reportDao.selectSenseQualitySeq();	//key value 조회
			param.put("idx", reportIdx);
			
			//2. lab_sense_quality_report 등록
			reportDao.insertSenseQualityReport(param);
			
			//3. lab_sense_quality_contents 등록
			ArrayList<HashMap<String,Object>> contentsList = new ArrayList<HashMap<String,Object>>();
			
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
			String path = config.getProperty("upload.file.path.images");
			path += "/"+toDay; 			
			for( int i = 0 ; i < contentsDivArr.size() ; i++ ) {
				HashMap<String,Object> contentsMap = new HashMap<String,Object>();
				contentsMap.put("idx", reportIdx);
				contentsMap.put("displayOrder", i+1);
				
				try{
					contentsMap.put("contentsDiv", contentsDivArr.get(i));
				} catch(Exception e) {
					contentsMap.put("contentsDiv", "");
				}
				
				try{
					contentsMap.put("contentsResult", contentsResultArr.get(i));
				} catch(Exception e) {
					contentsMap.put("contentsResult", "");
				}
				
				try {
					MultipartFile multipartFile = file[i];
					if( file != null && file.length > 0 ) {
						if( !multipartFile.isEmpty() ) {
							String fileIdx = FileUtil.getUUID();
							String result = FileUtil.upload3(multipartFile,path,fileIdx);
							contentsMap.put("orgFileName", multipartFile.getOriginalFilename());
							contentsMap.put("filePath", "/"+toDay);
							contentsMap.put("changeFileName", result);
						} else {
							contentsMap.put("orgFileName", "");
							contentsMap.put("filePath", "");
							contentsMap.put("changeFileName", "");
						}
					} else {
						contentsMap.put("orgFileName", "");
						contentsMap.put("filePath", "");
						contentsMap.put("changeFileName", "");
					}
				} catch( Exception e ) {
					contentsMap.put("orgFileName", "");
					contentsMap.put("filePath", "");
					contentsMap.put("changeFileName", "");
				}
				
				contentsList.add(contentsMap);
			}			
			reportDao.insertSenseQualityContents(contentsList);
			
			
			//4. lab_sense_quality_add_info 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( contentsNoteArr != null && contentsNoteArr.size() > 0 ) {
				for( int i = 0 ; i < contentsNoteArr.size() ; i++ ) {
					HashMap<String,Object> contentsNoteData = new HashMap<String,Object>();
					contentsNoteData.put("idx", reportIdx);
					contentsNoteData.put("infoType", "NOTE");
					contentsNoteData.put("infoText", contentsNoteArr.get(i));
					addInfoList.add(contentsNoteData);
				}				
			}
			
			if( resultArr != null && resultArr.size() > 0 ) {
				for( int i = 0 ; i < resultArr.size() ; i++ ) {
					HashMap<String,Object> resultData = new HashMap<String,Object>();
					resultData.put("idx", reportIdx);
					resultData.put("infoType", "RESULT");
					resultData.put("infoText", resultArr.get(i));
					addInfoList.add(resultData);
				}				
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				reportDao.insertSenseQualityAddInfo(addInfoList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", reportIdx);
			historyParam.put("docType", "SENSE_QUALITY");
			historyParam.put("historyType", "T");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			txManager.commit(status);
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
		return reportIdx;
	}

	@Override
	@Transactional
	public int insertSenseQuality(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		int reportIdx = 0;
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONArray contentsDivArr = (JSONArray)listMap.get("contentsDivArr");
			JSONArray contentsResultArr = (JSONArray)listMap.get("contentsResultArr");
			JSONArray contentsNoteArr = (JSONArray)listMap.get("contentsNoteArr");
			JSONArray resultArr = (JSONArray)listMap.get("resultArr");
			//1. key value 조회
			reportIdx = reportDao.selectSenseQualitySeq();	//key value 조회
			param.put("idx", reportIdx);
			//param.put("status", "REG");
			
			//2. lab_sense_quality_report 등록
			reportDao.insertSenseQualityReport(param);
			
			//3. lab_sense_quality_contents 등록
			ArrayList<HashMap<String,Object>> contentsList = new ArrayList<HashMap<String,Object>>();
			
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
			String path = config.getProperty("upload.file.path.images");
			path += "/"+toDay; 			
			for( int i = 0 ; i < contentsDivArr.size() ; i++ ) {
				HashMap<String,Object> contentsMap = new HashMap<String,Object>();
				contentsMap.put("idx", reportIdx);
				contentsMap.put("displayOrder", i+1);
				
				try{
					contentsMap.put("contentsDiv", contentsDivArr.get(i));
				} catch(Exception e) {
					contentsMap.put("contentsDiv", "");
				}
				
				try{
					contentsMap.put("contentsResult", contentsResultArr.get(i));
				} catch(Exception e) {
					contentsMap.put("contentsResult", "");
				}
				
				try {
					MultipartFile multipartFile = file[i];
					if( file != null && file.length > 0 ) {
						if( !multipartFile.isEmpty() ) {
							String fileIdx = FileUtil.getUUID();
							String result = FileUtil.upload3(multipartFile,path,fileIdx);
							contentsMap.put("orgFileName", multipartFile.getOriginalFilename());
							contentsMap.put("filePath", "/"+toDay);
							contentsMap.put("changeFileName", result);
						} else {
							contentsMap.put("orgFileName", "");
							contentsMap.put("filePath", "");
							contentsMap.put("changeFileName", "");
						}
					} else {
						contentsMap.put("orgFileName", "");
						contentsMap.put("filePath", "");
						contentsMap.put("changeFileName", "");
					}
				} catch( Exception e ) {
					contentsMap.put("orgFileName", "");
					contentsMap.put("filePath", "");
					contentsMap.put("changeFileName", "");
				}
				
				contentsList.add(contentsMap);
			}			
			reportDao.insertSenseQualityContents(contentsList);
			
			
			//4. lab_sense_quality_add_info 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( contentsNoteArr != null && contentsNoteArr.size() > 0 ) {
				for( int i = 0 ; i < contentsNoteArr.size() ; i++ ) {
					HashMap<String,Object> contentsNoteData = new HashMap<String,Object>();
					contentsNoteData.put("idx", reportIdx);
					contentsNoteData.put("infoType", "NOTE");
					contentsNoteData.put("infoText", contentsNoteArr.get(i));
					addInfoList.add(contentsNoteData);
				}				
			}
			
			if( resultArr != null && resultArr.size() > 0 ) {
				for( int i = 0 ; i < resultArr.size() ; i++ ) {
					HashMap<String,Object> resultData = new HashMap<String,Object>();
					resultData.put("idx", reportIdx);
					resultData.put("infoType", "RESULT");
					resultData.put("infoText", resultArr.get(i));
					addInfoList.add(resultData);
				}				
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				reportDao.insertSenseQualityAddInfo(addInfoList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", reportIdx);
			historyParam.put("docType", "SENSE_QUALITY");
			historyParam.put("historyType", "I");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			txManager.commit(status);
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
		return reportIdx;
	}

	@Override
	public Map<String, Object> selectSenseQualityData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		//1. lab_sense_quality_report 조회
		Map<String, Object> reportMap = reportDao.selectSenseQualityReport(param);
		//2. lab_sense_quality_contents 조회
		List<Map<String, Object>> contentsList = reportDao.selectSenseQualityContensts(param);
		
		int totalCount = contentsList.size();
		int modCount = totalCount/3;
		if( totalCount % 3 > 0  ) {
			modCount++;
		}
		
		//3. lab_sense_quality_add_info 조회
		param.put("infoType", "NOTE");
		List<Map<String, Object>> infoNoteList = reportDao.selectSenseQualityInfo(param);		
		param.put("infoType", "RESULT");
		List<Map<String, Object>> infoResultList = reportDao.selectSenseQualityInfo(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("reportMap", reportMap);
		map.put("contentsList", contentsList);
		map.put("totalCount", totalCount);
		map.put("modCount", modCount);
		map.put("infoNoteList", infoNoteList);
		map.put("infoResultList", infoResultList);
		
		return map;
	}

	@Override
	@Transactional
	public void updateSenseQualityTmp(Map<String, Object> param, HashMap<String, Object> dataListMap,
			HashMap<String, Object> fileMap, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONArray contentsNoteArr = (JSONArray)listMap.get("contentsNoteArr");
			JSONArray resultArr = (JSONArray)listMap.get("resultArr");
			
			//1. lab_sense_quality_report 등록
			reportDao.updateSenseQualityReport(param);
			
			Iterator<String> keys = dataListMap.keySet().iterator();		
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
			String path = config.getProperty("upload.file.path.images");
			path += "/"+toDay; 			
			while( keys.hasNext() ) {
				String key = keys.next();
				HashMap<String, Object> dataMap = (HashMap<String, Object>)dataListMap.get(key);
				if( dataMap != null && "U".equals(dataMap.get("dataStatus")) ) {
					reportDao.updateSenseQualityContent(dataMap);
				} else {
					dataMap.put("idx", param.get("idx"));
					//파일에 대한 정보를 조회한다.
					try {
						MultipartFile multipartFile = (MultipartFile)fileMap.get(key);
						if( file != null && file.length > 0 ) {
							if( !multipartFile.isEmpty() ) {
								String fileIdx = FileUtil.getUUID();
								String result = FileUtil.upload3(multipartFile,path,fileIdx);
								dataMap.put("orgFileName", multipartFile.getOriginalFilename());
								dataMap.put("filePath", "/"+toDay);
								dataMap.put("changeFileName", result);
							} else {
								dataMap.put("orgFileName", "");
								dataMap.put("filePath", "");
								dataMap.put("changeFileName", "");
							}
						} else {
							dataMap.put("orgFileName", "");
							dataMap.put("filePath", "");
							dataMap.put("changeFileName", "");
						}
					} catch( Exception e ) {
						dataMap.put("orgFileName", "");
						dataMap.put("filePath", "");
						dataMap.put("changeFileName", "");
					}
					reportDao.insertSenseQualityContent(dataMap);
				}
			}
			
			//3. lab_sense_quality_add_info 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( contentsNoteArr != null && contentsNoteArr.size() > 0 ) {
				for( int i = 0 ; i < contentsNoteArr.size() ; i++ ) {
					HashMap<String,Object> contentsNoteData = new HashMap<String,Object>();
					contentsNoteData.put("idx", param.get("idx"));
					contentsNoteData.put("infoType", "NOTE");
					contentsNoteData.put("infoText", contentsNoteArr.get(i));
					addInfoList.add(contentsNoteData);
				}				
			}
			
			if( resultArr != null && resultArr.size() > 0 ) {
				for( int i = 0 ; i < resultArr.size() ; i++ ) {
					HashMap<String,Object> resultData = new HashMap<String,Object>();
					resultData.put("idx", param.get("idx"));
					resultData.put("infoType", "RESULT");
					resultData.put("infoText", resultArr.get(i));
					addInfoList.add(resultData);
				}				
			}
			System.err.println("addInfoList : "+addInfoList);
			reportDao.deleteSenseQualityAddInfo(param);
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				reportDao.insertSenseQualityAddInfo(addInfoList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", param.get("idx"));
			historyParam.put("docType", "SENSE_QUALITY");
			historyParam.put("historyType", "T");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			txManager.commit(status);
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	@Transactional
	public void updateSenseQuality(Map<String, Object> param, HashMap<String, Object> dataListMap,
			HashMap<String, Object> fileMap, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONArray contentsNoteArr = (JSONArray)listMap.get("contentsNoteArr");
			JSONArray resultArr = (JSONArray)listMap.get("resultArr");
			
			if( param.get("currentStatus") != null && "COND_APPR".equals(param.get("currentStatus")) ) {
				param.put("status", "APPR");
			} else if( param.get("currentStatus") != null && "TMP".equals(param.get("currentStatus")) ) {
				param.put("status", "REG");
			}
			
			//1. lab_sense_quality_report 등록
			reportDao.updateSenseQualityReport(param);
			
			Iterator<String> keys = dataListMap.keySet().iterator();		
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
			String path = config.getProperty("upload.file.path.images");
			path += "/"+toDay; 			
			while( keys.hasNext() ) {
				String key = keys.next();
				HashMap<String, Object> dataMap = (HashMap<String, Object>)dataListMap.get(key);
				if( dataMap != null && "U".equals(dataMap.get("dataStatus")) ) {
					//update 하자
					System.err.println("UPDATE 하자 "+dataMap);
					reportDao.updateSenseQualityContent(dataMap);
				} else {
					dataMap.put("idx", param.get("idx"));
					//파일에 대한 정보를 조회한다.
					try {
						MultipartFile multipartFile = (MultipartFile)fileMap.get(key);
						if( file != null && file.length > 0 ) {
							if( !multipartFile.isEmpty() ) {
								String fileIdx = FileUtil.getUUID();
								String result = FileUtil.upload3(multipartFile,path,fileIdx);
								dataMap.put("orgFileName", multipartFile.getOriginalFilename());
								dataMap.put("filePath", "/"+toDay);
								dataMap.put("changeFileName", result);
							} else {
								dataMap.put("orgFileName", "");
								dataMap.put("filePath", "");
								dataMap.put("changeFileName", "");
							}
						} else {
							dataMap.put("orgFileName", "");
							dataMap.put("filePath", "");
							dataMap.put("changeFileName", "");
						}
					} catch( Exception e ) {
						dataMap.put("orgFileName", "");
						dataMap.put("filePath", "");
						dataMap.put("changeFileName", "");
					}
					System.err.println("INSERT 하자 "+dataMap);
					reportDao.insertSenseQualityContent(dataMap);
				}
			}
			
			//3. lab_sense_quality_add_info 등록
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( contentsNoteArr != null && contentsNoteArr.size() > 0 ) {
				for( int i = 0 ; i < contentsNoteArr.size() ; i++ ) {
					HashMap<String,Object> contentsNoteData = new HashMap<String,Object>();
					contentsNoteData.put("idx", param.get("idx"));
					contentsNoteData.put("infoType", "NOTE");
					contentsNoteData.put("infoText", contentsNoteArr.get(i));
					addInfoList.add(contentsNoteData);
				}				
			}
			
			if( resultArr != null && resultArr.size() > 0 ) {
				for( int i = 0 ; i < resultArr.size() ; i++ ) {
					HashMap<String,Object> resultData = new HashMap<String,Object>();
					resultData.put("idx", param.get("idx"));
					resultData.put("infoType", "RESULT");
					resultData.put("infoText", resultArr.get(i));
					addInfoList.add(resultData);
				}				
			}
			System.err.println("addInfoList : "+addInfoList);
			reportDao.deleteSenseQualityAddInfo(param);
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				reportDao.insertSenseQualityAddInfo(addInfoList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", param.get("idx"));
			historyParam.put("docType", "SENSE_QUALITY");
			historyParam.put("historyType", "U");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			if( param.get("currentStatus") != null && "COND_APPR".equals(param.get("currentStatus")) ) {
				//다음 결재자에게 메일을 보낸다.
				param.put("docIdx", param.get("idx"));
				Map<String, Object> approvalHeader = approvalDao.selectApprHeaderData(param);
				approvalHeader.get("CURRENT_USER_ID");
				HashMap<String, Object> notiMap = new HashMap<String, Object>();
				notiMap.put("targetUser", approvalHeader.get("CURRENT_USER_ID"));
				notiMap.put("type", "A");
				notiMap.put("typeTxt", "결재알림");
				notiMap.put("message", "결재 요청이 도착했습니다.");
				notiMap.put("userId", approvalHeader.get("REG_USER"));
				notiMap.put("docIdx", param.get("docIdx"));
				notiMap.put("docType", param.get("docType"));
				commonService.notification(notiMap);
			}
			
			txManager.commit(status);
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	@Transactional
	public void deleteSenseQualityContenstsData(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			//1. 데이터를 조회한다.
			Map<String, Object> contenstsMap = reportDao.selectSenseQualityContenstsData(param);
			if( contenstsMap != null  ) {
				//2. 업로드 파일을 삭제한다.
				String path = config.getProperty("upload.file.path.images");
				path += contenstsMap.get("FILE_PATH")+"/"+contenstsMap.get("ORG_FILE_NAME"); 
				File file = new File(path);
				if(file.exists() == true){		
					file.delete();				// 해당 경로의 파일이 존재하면 파일 삭제
				}
				//3. 데이터를 삭제한다.
				reportDao.deleteSenseQualityContenstsData(param);
				
				//history 저장
				Map<String, Object> historyParam = new HashMap<String, Object>();
				historyParam.put("docIdx", param.get("idx"));
				historyParam.put("docType", "SENSE_QUALITY");
				historyParam.put("historyType", "D");
				historyParam.put("historyData", param.toString());
				historyParam.put("userId", param.get("userId"));
				commonDao.insertHistory(historyParam);
				
				txManager.commit(status);
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
