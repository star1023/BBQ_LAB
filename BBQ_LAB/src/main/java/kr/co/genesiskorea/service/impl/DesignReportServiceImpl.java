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
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.controller.DesignReportController;
import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.dao.DesignReportDao;
import kr.co.genesiskorea.service.DesignReportService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class DesignReportServiceImpl implements DesignReportService {
	private Logger logger = LogManager.getLogger(DesignReportServiceImpl.class);
	
	@Autowired
	DesignReportDao reportDao;
	
	@Autowired
	private Properties config;
	
	@Autowired
	CommonDao commonDao;
	
	@Resource
	DataSourceTransactionManager txManager;

	@Override
	public Map<String, Object> selectDesignList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = reportDao.selectDesignCount(param);
		
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
		
		List<Map<String, Object>> designList = reportDao.selectDesignList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", designList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	@Transactional
	public int insertDesign(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		int designIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			ArrayList<String> fileType = (ArrayList<String>)listMap.get("fileType");
			ArrayList<String> fileTypeText = (ArrayList<String>)listMap.get("fileTypeText");
			JSONParser parser = new JSONParser();
			JSONArray changeReasonArr = (JSONArray) parser.parse((String)param.get("changeReasonArr"));
			JSONArray changeTimeArr = (JSONArray) parser.parse((String)param.get("changeTimeArr"));
			JSONArray rowIdArr = (JSONArray) parser.parse((String)param.get("rowIdArr"));
			JSONArray itemDivArr = (JSONArray) parser.parse((String)param.get("itemDivArr"));
			JSONArray itemCurrentArr = (JSONArray) parser.parse((String)param.get("itemCurrentArr"));
			JSONArray itemChangeArr = (JSONArray) parser.parse((String)param.get("itemChangeArr"));
			JSONArray itemNoteArr = (JSONArray) parser.parse((String)param.get("itemNoteArr"));

			designIdx = reportDao.selectDesignSeq();	//key value 조회
			param.put("idx", designIdx);
			
			//제품 등록
			reportDao.insertDesign(param);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( changeReasonArr.size() > 0 ) {
				for( int i = 0 ; i < changeReasonArr.size() ; i++ ) {
					HashMap<String,Object> changeReasonData = new HashMap<String,Object>();
					changeReasonData.put("idx", designIdx);
					changeReasonData.put("displayOrder", i+1);
					changeReasonData.put("infoType", "REA");
					changeReasonData.put("infoText", changeReasonArr.get(i));
					addInfoList.add(changeReasonData);
				}				
			}
			
			if( changeTimeArr.size() > 0 ) {
				for( int i = 0 ; i < changeTimeArr.size() ; i++ ) {
					HashMap<String,Object> changeTimeData = new HashMap<String,Object>();
					changeTimeData.put("idx", designIdx);
					changeTimeData.put("displayOrder", i+1);
					changeTimeData.put("infoType", "TIME");
					changeTimeData.put("infoText", changeTimeArr.get(i));
					addInfoList.add(changeTimeData);
				}				
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				reportDao.insertAddInfo(addInfoList);
			}
			
			ArrayList<HashMap<String,String>> changeList = new ArrayList<HashMap<String,String>>();
			for( int i = 0 ; i < itemDivArr.size() ; i++ ) {
				HashMap<String,String> matMap = new HashMap<String,String>();
				try{
					matMap.put("itemDiv", (String)itemDivArr.get(i));
				} catch(Exception e) {
					matMap.put("itemDiv", "");
				}				
				try{
					matMap.put("itemCurrent", (String)itemCurrentArr.get(i));
				} catch(Exception e) {
					matMap.put("itemCurrent", "");
				}				
				try{
					matMap.put("itemChange", (String)itemChangeArr.get(i));
				} catch(Exception e) {
					matMap.put("itemChange", "");
				}
				try{
					matMap.put("itemNote", (String)itemNoteArr.get(i));
				} catch(Exception e) {
					matMap.put("itemNote", "");
				}
				
				changeList.add(matMap);
			}
			param.put("changeList", changeList);
			reportDao.insertChangeList(param);
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", designIdx);
			historyParam.put("docType", "DESIGN");
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
				String path = config.getProperty("upload.file.path.design");
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
							fileMap.put("docIdx", designIdx);
							fileMap.put("docType", "DESIGN");
							fileMap.put("fileType", fileType.get(idx));
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
		return designIdx;
	}

	@Override
	public Map<String, Object> selectDesignData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		Map<String, Object> data = reportDao.selectDesignData(param);
		param.put("docType", "DESIGN");
		List<Map<String, String>> fileList = commonDao.selectFileList(param);
		map.put("data", data);
		map.put("fileList", fileList);
		return map;
	}

	@Override
	public List<Map<String, Object>> selectDesignChangeList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectDesignChangeList(param);
	}

	@Override
	@Transactional
	public void updateDesign(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			ArrayList<String> fileType = (ArrayList<String>)listMap.get("fileType");
			ArrayList<String> fileTypeText = (ArrayList<String>)listMap.get("fileTypeText");
			JSONParser parser = new JSONParser();
			JSONArray changeReasonArr = (JSONArray) parser.parse((String)param.get("changeReasonArr"));
			JSONArray changeTimeArr = (JSONArray) parser.parse((String)param.get("changeTimeArr"));
			JSONArray rowIdArr = (JSONArray) parser.parse((String)param.get("rowIdArr"));
			JSONArray itemDivArr = (JSONArray) parser.parse((String)param.get("itemDivArr"));
			JSONArray itemCurrentArr = (JSONArray) parser.parse((String)param.get("itemCurrentArr"));
			JSONArray itemChangeArr = (JSONArray) parser.parse((String)param.get("itemChangeArr"));
			JSONArray itemNoteArr = (JSONArray) parser.parse((String)param.get("itemNoteArr"));
			
			/*ArrayList<String> rowIdArr = (ArrayList<String>)listMap.get("rowIdArr");
			ArrayList<String> itemDivArr = (ArrayList<String>)listMap.get("itemDivArr");
			ArrayList<String> itemCurrentArr = (ArrayList<String>)listMap.get("itemCurrentArr");
			ArrayList<String> itemChangeArr = (ArrayList<String>)listMap.get("itemChangeArr");
			ArrayList<String> itemNoteArr = (ArrayList<String>)listMap.get("itemNoteArr");*/
			
			int designIdx = Integer.parseInt((String)param.get("idx")); 	//key value 조회
			if( param.get("currentStatus") != null && "COND_APPR".equals(param.get("currentStatus")) ) {
				param.put("status", "APPR");
			}
			
			reportDao.updateDesign(param);			
			
			reportDao.deleteChangeList(param);
			
			ArrayList<HashMap<String,String>> changeList = new ArrayList<HashMap<String,String>>();
			for( int i = 0 ; i < itemDivArr.size() ; i++ ) {
				HashMap<String,String> matMap = new HashMap<String,String>();
				try{
					matMap.put("itemDiv", (String)itemDivArr.get(i));
				} catch(Exception e) {
					matMap.put("itemDiv", "");
				}				
				try{
					matMap.put("itemCurrent", (String)itemCurrentArr.get(i));
				} catch(Exception e) {
					matMap.put("itemCurrent", "");
				}				
				try{
					matMap.put("itemChange", (String)itemChangeArr.get(i));
				} catch(Exception e) {
					matMap.put("itemChange", "");
				}
				try{
					matMap.put("itemNote", (String)itemNoteArr.get(i));
				} catch(Exception e) {
					matMap.put("itemNote", "");
				}
				
				changeList.add(matMap);
			}
			param.put("changeList", changeList);
			reportDao.insertChangeList(param);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( changeReasonArr.size() > 0 ) {
				for( int i = 0 ; i < changeReasonArr.size() ; i++ ) {
					HashMap<String,Object> changeReasonData = new HashMap<String,Object>();
					changeReasonData.put("idx", (String)param.get("idx"));
					changeReasonData.put("displayOrder", i+1);
					changeReasonData.put("infoType", "REA");
					changeReasonData.put("infoText", changeReasonArr.get(i));
					addInfoList.add(changeReasonData);
				}				
			}
			
			if( changeTimeArr.size() > 0 ) {
				for( int i = 0 ; i < changeTimeArr.size() ; i++ ) {
					HashMap<String,Object> changeTimeData = new HashMap<String,Object>();
					changeTimeData.put("idx", (String)param.get("idx"));
					changeTimeData.put("displayOrder", i+1);
					changeTimeData.put("infoType", "TIME");
					changeTimeData.put("infoText", changeTimeArr.get(i));
					addInfoList.add(changeTimeData);
				}				
			}
			
			reportDao.deleteAddInfo(param);
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				reportDao.insertAddInfo(addInfoList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", designIdx);
			historyParam.put("docType", "DESIGN");
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
		        String path = config.getProperty("upload.file.path.design");
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
							fileMap.put("docIdx", designIdx);
							fileMap.put("docType", "DESIGN");
							fileMap.put("fileType", fileType.get(idx));
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

	@Override
	public List<Map<String, Object>> selectAddInfoList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectAddInfoList(param);
	}

	@Override
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectMyDataCheck(param);
	}

}
