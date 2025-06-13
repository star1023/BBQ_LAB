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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.dao.MaterialDao;
import kr.co.genesiskorea.service.MaterialService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class MaterialServiceImpl implements MaterialService {
	private Logger logger = LogManager.getLogger(MaterialServiceImpl.class);
	
	@Autowired 
	MaterialDao materialDao;
	
	@Autowired 
	CommonDao commonDao;
	
	@Autowired
	private Properties config;
	
	@Resource
	DataSourceTransactionManager txManager;

	@Override
	public Map<String, Object> selectMaterialList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = materialDao.selectMaterialCount(param);
		
		int viewCount = 0;
		try {
			viewCount = Integer.parseInt(param.get("viewCount").toString());
		} catch( Exception e ) {
			viewCount = 10;
		}
		
		// 페이징: 페이징 정보 SET
		PageNavigator navi = new PageNavigator(param, viewCount, totalCount);
		
		List<Map<String, Object>> materialList = materialDao.selectMaterialList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("totalCount", totalCount);
		map.put("list", materialList);
		map.put("navi", navi);
		
		return map;
	}

	@Override
	public Map<String, Object> selectMaterialDataCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		int count = materialDao.selectMaterialDataCount(param);
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("COUNT", count);		
		return map;
	}

	@Override
	public String selectmaterialCode() {
		// TODO Auto-generated method stub
		return materialDao.selectmaterialCode();
	}

	@Override
	public void insertMaterial(Map<String, Object> param, List<String> materialType, List<String> fileType,
			List<String> fileTypeText, List<String> docType, List<String> docTypeText, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			//입력항목 들록 및 key data 조회
			int materialIdx = materialDao.selectMaterialSeq();
			//데이터 저장
			param.put("idx", materialIdx);
			if( materialType != null && materialType.size() > 0 ) {
				for( int i = 0 ; i < materialType.size() ; i++ ) {
					param.put("materialType"+(i+1), materialType.get(i));
				}
			}
			System.err.println(param);
			materialDao.insertMaterial(param);
			
			//첨부파일 유형 저장
			List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
			for( int i = 0 ; i < docType.size() ; i++ ) {
				HashMap<String, Object> paramMap = new HashMap<String, Object>();
				paramMap.put("docIdx", materialIdx);
				paramMap.put("docType", "MAT");
				paramMap.put("fileType", docType.get(i));
				paramMap.put("fileTypeText", docTypeText.get(i));
				docTypeList.add(paramMap);
			}
			commonDao.insertFileType(docTypeList);
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", materialIdx);
			historyParam.put("docType", "MAT");
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
				String path = config.getProperty("upload.file.path.material");
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
							fileMap.put("docIdx", materialIdx);
							fileMap.put("docType", "MAT");
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
		
	}

	@Override
	public Map<String, Object> selectMaterialData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		Map<String, String> data = materialDao.selectMaterialData(param);
		param.put("docType", "MAT");
		List<Map<String, String>> fileList = commonDao.selectFileList(param);
		List<Map<String, String>> fileType = commonDao.selectFileType(param);
		map.put("data", data);
		map.put("fileList", fileList);
		map.put("fileType", fileType);
		return map;
	}

	@Override
	public Map<String, Object> selectErpMaterialList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = materialDao.selectErpMaterialCount(param);
		
		int viewCount = 0;
		try {
			viewCount = Integer.parseInt(param.get("viewCount").toString());
		} catch( Exception e ) {
			viewCount = 10;
		}
		
		int pageNo = 1;
		try {
			pageNo = Integer.parseInt((String)param.get("pageNo"));
		} catch( Exception e ) {
			System.err.println(e.getMessage());
			pageNo = 1;
		}
		
		//int startRow = (pageNo-1)*viewCount+1;
		//int endRow = pageNo*viewCount;
		
		//param.put("startRow", startRow);
		//param.put("endRow", endRow);
		
		// 페이징: 페이징 정보 SET
		PageNavigator navi = new PageNavigator(param, viewCount, totalCount);
		
		List<Map<String, Object>> materialList = materialDao.selectErpMaterialList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", materialList);		
		map.put("navi", navi);
		
		return map;
	}

	@Override
	public Map<String, Object> selectErpMaterialData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return materialDao.selectErpMaterialData(param);
	}

	@Override
	public void insertNewVersion(Map<String, Object> param, List<String> materialType, List<String> fileType,
			List<String> fileTypeText, List<String> docType, List<String> docTypeText, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			//헌재 데이터 버젼 수정
			materialDao.updateMaterial(param);
			
			//입력항목 들록 및 key data 조회
			int materialIdx = materialDao.selectMaterialSeq();
			//데이터 저장
			param.put("idx", materialIdx);
			if( materialType != null && materialType.size() > 0 ) {
				for( int i = 0 ; i < materialType.size() ; i++ ) {
					param.put("materialType"+(i+1), materialType.get(i));
				}
			}
			
			param.put("versionNo", Integer.parseInt((String)param.get("currentVersionNo"))+1);
			System.err.println(param);
			materialDao.insertNewVersion(param);
			
			//첨부파일 유형 저장
			List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
			for( int i = 0 ; i < docType.size() ; i++ ) {
				HashMap<String, Object> paramMap = new HashMap<String, Object>();
				paramMap.put("docIdx", materialIdx);
				paramMap.put("docType", "MAT");
				paramMap.put("fileType", docType.get(i));
				paramMap.put("fileTypeText", docTypeText.get(i));
				docTypeList.add(paramMap);
			}
			commonDao.insertFileType(docTypeList);
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", materialIdx);
			historyParam.put("docType", "MAT");
			historyParam.put("historyType", "V");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				Calendar cal = Calendar.getInstance();
		        Date day = cal.getTime();    //시간을 꺼낸다.
		        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
		        String toDay = sdf.format(day);
				String path = config.getProperty("upload.file.path.material");
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
							fileMap.put("docIdx", materialIdx);
							fileMap.put("docType", "MAT");
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
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub		
		return materialDao.selectHistory(param);
	}

	@Override
	public void deleteMaterial(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			materialDao.deleteMaterial(param);
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", param.get("idx"));
			historyParam.put("docType", "MAT");
			historyParam.put("historyType", "D");
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

}
