/**
 * 
 */
package kr.co.genesiskorea.service.impl;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.dao.ManualDao;
import kr.co.genesiskorea.service.ManualService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class ManualServiceImpl implements ManualService {
	
	private Logger logger = LogManager.getLogger(ManualServiceImpl.class);
	
	@Autowired
	ManualDao manualDao;
	
	@Autowired
	private Properties config;
	
	@Autowired
	CommonDao commonDao;
	
	@Resource
	DataSourceTransactionManager txManager;
	
	@Override
	public Map<String, Object> selectManualList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		int totalCount = manualDao.selectManualCount(param);
		
		int viewCount = 10;
		int pageNo = 1;
		try {
			pageNo = Integer.parseInt((String)param.get("pageNo"));
		} catch( Exception e ) {
			System.err.println(e.getMessage());
			pageNo = 1;
		}
		
		// 페이징: 페이징 정보 SET
		PageNavigator navi = new PageNavigator(param, viewCount, totalCount);
		
		List<Map<String, Object>> manualList = manualDao.selectManualList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", manualList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	public void uploadManual(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try{
			manualDao.uploadManual(param);
			
			String manualIdx = (String)param.get("idx");
			
			MultipartFile[] file = (MultipartFile[]) param.get("files");
			if( file != null && file.length > 0 ) {
				Calendar cal = Calendar.getInstance();
		        Date day = cal.getTime();    //시간을 꺼낸다.
		        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
		        String toDay = sdf.format(day);
				String path = config.getProperty("upload.file.path.manual");
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
							fileMap.put("docIdx", manualIdx);
							fileMap.put("docType", "MANUAL");
							fileMap.put("fileType", "00");
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
	}

	@Override
	public List<Map<String, Object>> selectManualFileList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return manualDao.selectManualFileList(param);
	}
}
