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

import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.dao.EtcReportDao;
import kr.co.genesiskorea.service.DesignReportService;
import kr.co.genesiskorea.service.EtcReportService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class EtcReportServiceImpl implements EtcReportService  {
private Logger logger = LogManager.getLogger(EtcReportServiceImpl.class);
	
	@Autowired
	EtcReportDao reportDao;
	
	@Autowired
	private Properties config;
	
	@Autowired
	CommonDao commonDao;
	
	@Resource
	DataSourceTransactionManager txManager;

	@Override
	public Map<String, Object> selectEtcList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = reportDao.selectEtcCount(param);
		
		int viewCount = 10;
		int pageNo = 1;
		try {
			pageNo = Integer.parseInt((String)param.get("pageNo"));
		} catch( Exception e ) {
			pageNo = 1;
		}
		
		try {
			viewCount = Integer.parseInt((String)param.get("viewCount"));
		} catch( Exception e ) {
			viewCount = 10;
		}
		
		// 페이징: 페이징 정보 SET
		PageNavigator navi = new PageNavigator(param, viewCount, totalCount);
		
		List<Map<String, Object>> etcList = reportDao.selectEtcList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", etcList);	
		map.put("navi", navi);
		return map;
	}
	
	@Override
	@Transactional
	public int insertTmpEtc(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		int etcIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			ArrayList<String> fileType = (ArrayList<String>)listMap.get("fileType");
			ArrayList<String> fileTypeText = (ArrayList<String>)listMap.get("fileTypeText");
			JSONParser parser = new JSONParser();

			etcIdx = reportDao.selectEtcSeq();	//key value 조회
			param.put("idx", etcIdx);
			
			//제품 등록
			reportDao.insertEtc(param);
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", etcIdx);
			historyParam.put("docType", "ETC");
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
				String path = config.getProperty("upload.file.path.etc");
				path += "/"+toDay; 
				int idx = 0;
				for( MultipartFile multipartFile : file ) {
					try {
						if( !multipartFile.isEmpty() ) {
							String fileIdx = FileUtil.getUUID();
							String result = FileUtil.upload3(multipartFile,path,fileIdx);
							String content = FileUtil.getPdfContents(path, result);
							Map<String,Object> fileMap = new HashMap<String,Object>();
							fileMap.put("fileIdx", fileIdx);
							fileMap.put("docIdx", etcIdx);
							fileMap.put("docType", "ETC");
							fileMap.put("fileType", fileType.get(idx));
							fileMap.put("orgFileName", multipartFile.getOriginalFilename());
							fileMap.put("filePath", path);
							fileMap.put("changeFileName", result);
							fileMap.put("content", content);
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
		return etcIdx;
	}

	@Override
	@Transactional
	public int insertEtc(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		int etcIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			ArrayList<String> fileType = (ArrayList<String>)listMap.get("fileType");
			ArrayList<String> fileTypeText = (ArrayList<String>)listMap.get("fileTypeText");
			JSONParser parser = new JSONParser();
			
			etcIdx = reportDao.selectEtcSeq();	//key value 조회
			param.put("idx", etcIdx);
			
			//제품 등록
			reportDao.insertEtc(param);
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", etcIdx);
			historyParam.put("docType", "ETC");
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
				String path = config.getProperty("upload.file.path.etc");
				path += "/"+toDay; 
				int idx = 0;
				for( MultipartFile multipartFile : file ) {
					try {
						if( !multipartFile.isEmpty() ) {
							String fileIdx = FileUtil.getUUID();
							String result = FileUtil.upload3(multipartFile,path,fileIdx);
							String content = FileUtil.getPdfContents(path, result);
							Map<String,Object> fileMap = new HashMap<String,Object>();
							fileMap.put("fileIdx", fileIdx);
							fileMap.put("docIdx", etcIdx);
							fileMap.put("docType", "ETC");
							fileMap.put("fileType", fileType.get(idx));
							fileMap.put("orgFileName", multipartFile.getOriginalFilename());
							fileMap.put("filePath", path);
							fileMap.put("changeFileName", result);
							fileMap.put("content", content);
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
		return etcIdx;
	}

	@Override
	public Map<String, Object> selectEtcData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		Map<String, Object> data = reportDao.selectEtcData(param);
		param.put("docType", "ETC");
		List<Map<String, String>> fileList = commonDao.selectFileList(param);
		map.put("data", data);
		map.put("fileList", fileList);
		return map;
	}
	
	@Override
	@Transactional
	public void updateEtc(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
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
			
			JSONArray deletedFileIdArr = (JSONArray) parser.parse((String)param.get("deletedFileIdArr"));
			JSONArray deletedFileArr = (JSONArray) parser.parse((String)param.get("deletedFileArr"));
			JSONArray deletedFilePathArr = (JSONArray) parser.parse((String)param.get("deletedFilePathArr"));
			
			
			int etcIdx = Integer.parseInt((String)param.get("idx")); 	//key value 조회
			if( param.get("currentStatus") != null && "COND_APPR".equals(param.get("currentStatus")) ) {
				param.put("status", "APPR");
			}
			
			reportDao.updateEtc(param);			
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", etcIdx);
			historyParam.put("docType", "ETC");
			historyParam.put("historyType", "U");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//삭제된 파일 삭제
			if (deletedFileIdArr != null && deletedFileIdArr.size() > 0) {
			    for (int i = 0; i < deletedFileIdArr.size(); i++) {
			    	String fileIdx = (String)deletedFileIdArr.get(i);
			        String fullFileName = (String)deletedFileArr.get(i);
			        String filePath = (String)deletedFilePathArr.get(i);

			        FileUtil.fileDelete(fullFileName, filePath);
			        Map<String, Object> fileParam = new HashMap<>();
			        fileParam.put("fileIdx", fileIdx);
			        commonDao.deleteFileData(fileParam);  // ✅ map으로 넘김
			    }
			}
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				Calendar cal = Calendar.getInstance();
		        Date day = cal.getTime();    //시간을 꺼낸다.
		        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
		        String toDay = sdf.format(day);
		        String path = config.getProperty("upload.file.path.etc");
				path += "/"+toDay; 
				int idx = 0;
				for( MultipartFile multipartFile : file ) {
					try {
						if( !multipartFile.isEmpty() ) {
							String fileIdx = FileUtil.getUUID();
							String result = FileUtil.upload3(multipartFile,path,fileIdx);
							String content = FileUtil.getPdfContents(path, result);
							Map<String,Object> fileMap = new HashMap<String,Object>();
							fileMap.put("fileIdx", fileIdx);
							fileMap.put("docIdx", etcIdx);
							fileMap.put("docType", "ETC");
							fileMap.put("fileType", fileType.get(idx));
							fileMap.put("orgFileName", multipartFile.getOriginalFilename());
							fileMap.put("filePath", path);
							fileMap.put("changeFileName", result);
							fileMap.put("content", content);
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
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectMyDataCheck(param);
	}

	@Override
	public void deleteEtcReport(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		reportDao.deleteEtcReport(param);
	}
}
