package kr.co.genesiskorea.service.impl;

import java.io.File;
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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.dao.ChemicalTestDao;
import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.service.ChemicalTestService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class ChemicalTestServiceImpl implements ChemicalTestService {
	private Logger logger = LogManager.getLogger(ChemicalTestServiceImpl.class);
	
	@Autowired
	ChemicalTestDao reportDao;
	
	@Autowired
	private Properties config;
	
	@Autowired
	CommonDao commonDao;
	
	@Resource
	DataSourceTransactionManager txManager;

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectHistory(param);
	}

	@Override
	public Map<String, Object> selectChemicalTestList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = reportDao.selectChemicalTestCount(param);
		
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
		
		List<Map<String, Object>> chemicalTestList = reportDao.selectChemicalTestList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", chemicalTestList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	public int insertChemicalTest(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file,
			MultipartFile imageFile) throws Exception {
		// TODO Auto-generated method stub
		int reportIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONArray typeCodeArr = (JSONArray)listMap.get("typeCodeArr");
			JSONArray itemContentArr = (JSONArray)listMap.get("itemContentArr");
			JSONArray standard1Arr = (JSONArray)listMap.get("standard1Arr");
			JSONArray standard2Arr = (JSONArray)listMap.get("standard2Arr");

			//1. key value 조회
			reportIdx = reportDao.selectChemicalTestSeq();	//key value 조회
			param.put("idx", reportIdx);
			//param.put("status", "REG");
			
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
			String path = config.getProperty("upload.file.path.images");
			path += "/"+toDay;
			
			// 5. 이미지 파일 저장
			if( !imageFile.isEmpty() ) {
				String fileIdx = FileUtil.getUUID();
				String result = FileUtil.upload3(imageFile,path,fileIdx);
				param.put("orgFileName", imageFile.getOriginalFilename());
				param.put("filePath", "/"+toDay);
				param.put("fileName", result);
			} else {
				param.put("orgFileName", "");
				param.put("filePath", "");
				param.put("fileName", "");
			}
			
			//2. lab_chemical_test 등록
			reportDao.insertChemicalTest(param);
			
			//3. lab_chemical_test_item 등록
			ArrayList<HashMap<String,Object>> itemList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < typeCodeArr.size() ; i++ ) {
				HashMap<String,Object> itemMap = new HashMap<String,Object>();
				itemMap.put("chemicalIdx", reportIdx);
				
				try{
					itemMap.put("typeCode", typeCodeArr.get(i));
				} catch(Exception e) {
					itemMap.put("typeCode", "");
				}
				
				try{
					itemMap.put("itemContent", itemContentArr.get(i));
				} catch(Exception e) {
					itemMap.put("itemContent", "");
				}
				
				itemList.add(itemMap);
			}			
			reportDao.insertChemicalTestItem(itemList);
			
			//4. lab_chemical_test_standard 등록
			ArrayList<HashMap<String,Object>> standardList = new ArrayList<HashMap<String,Object>>();
			if( standard1Arr.size() > 0 ) {
				for( int i = 0 ; i < standard1Arr.size() ; i++ ) {
					HashMap<String,Object> standard1 = new HashMap<String,Object>();
					standard1.put("chemicalIdx", reportIdx);
					standard1.put("typeCode", "MET");
					standard1.put("standardContent", standard1Arr.get(i));
					standardList.add(standard1);
				}				
			}
			
			if( standard2Arr.size() > 0 ) {
				for( int i = 0 ; i < standard2Arr.size() ; i++ ) {
					HashMap<String,Object> standard2 = new HashMap<String,Object>();
					standard2.put("chemicalIdx", reportIdx);
					standard2.put("typeCode", "SCH");
					standard2.put("standardContent", standard2Arr.get(i));
					standardList.add(standard2);
				}				
			}
			
			if( standardList != null && standardList.size() > 0 ) {
				//등록한다.
				reportDao.insertChemicalTestStandard(standardList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", param.get("idx"));
			historyParam.put("docType", param.get("docType"));
			historyParam.put("historyType", "I");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				path = config.getProperty("upload.file.path.chemical");
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
		return reportIdx;
	}

	@Override
	public Map<String, Object> selectChemicalTestData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		Map<String, Object> data = reportDao.selectChemicalTestData(param);
		param.put("docType", "CHEMICAL");
		List<Map<String, String>> fileList = commonDao.selectFileList(param);
		map.put("data", data);
		map.put("fileList", fileList);
		return map;
	}

	@Override
	public List<Map<String, Object>> selectChemicalTestItemList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectChemicalTestItemData(param);
	}

	@Override
	public List<Map<String, Object>> selectChemicalTestStandardList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.selectChemicalTestStandardList(param);
	}

	@Override
	public List<Map<String, Object>> searchChemicalTestList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return reportDao.searchChemicalTestList(param);
	}

	@Override
	public void updateChemicalTest(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file,
			MultipartFile imageFile) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONArray typeCodeArr = (JSONArray)listMap.get("typeCodeArr");
			JSONArray itemContentArr = (JSONArray)listMap.get("itemContentArr");
			JSONArray standard1Arr = (JSONArray)listMap.get("standard1Arr");
			JSONArray standard2Arr = (JSONArray)listMap.get("standard2Arr");
		
			Calendar cal = Calendar.getInstance();
			Date day = cal.getTime();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
			String toDay = sdf.format(day);

			// 설정에서 이미지 저장 루트 경로 읽기
			String baseDir = config.getProperty("upload.file.path.images"); // 예: C:/develop/upload/images
			String path = baseDir + "/" + toDay;

			String deleteFlag = String.valueOf(param.getOrDefault("imageDeleteFlag", "N"));

			// "undefined" 문자열 정리
			if ("undefined".equals(param.get("FILE_PATH"))) param.put("FILE_PATH", null);
			if ("undefined".equals(param.get("FILE_NAME"))) param.put("FILE_NAME", null);

			// 삭제 조건 확인
			if ("Y".equals(deleteFlag) || (imageFile != null && !imageFile.isEmpty())) {
			    Object filePathObj = param.get("FILE_PATH");
			    Object fileNameObj = param.get("FILE_NAME");

			    if (filePathObj != null && fileNameObj != null) {
			        // 파일 경로 조합 (File.separator 대신 Paths.get을 써도 무방)
			        String prevImgPath = baseDir + File.separator
			                           + filePathObj.toString().replaceFirst("^/", "")  // "/202505" → "202505"
			                           + File.separator
			                           + fileNameObj.toString();

			        File prevImgFile = new File(prevImgPath);

			        if (prevImgFile.exists()) {
			            prevImgFile.delete(); // 삭제
			        }
			        // 존재하지 않으면 무시
			    }
			}

			// 새 이미지가 있다면 저장
			if (imageFile != null && !imageFile.isEmpty()) {
			    String fileIdx = FileUtil.getUUID();
			    String result = FileUtil.upload3(imageFile, path, fileIdx);
			    param.put("orgFileName", imageFile.getOriginalFilename());
			    param.put("filePath", "/" + toDay);
			    param.put("fileName", result);
			} else if ("Y".equals(deleteFlag)) {
			    // 삭제한 경우만 빈값 처리
			    param.put("orgFileName", "");
			    param.put("filePath", "");
			    param.put("fileName", "");
			} else {
			    // 아무것도 안 했으면 기존 값을 다시 넣어줘야 함
			    param.put("orgFileName", param.get("ORG_FILE_NAME"));
			    param.put("filePath", param.get("FILE_PATH"));
			    param.put("fileName", param.get("FILE_NAME"));
			}
			// else 유지: 아무 수정 없으면 기존 값 유지
			
			// 1. chemical_test 수정
			reportDao.updateChemicalTest(param);
	
			// 2. 기존 데이터 삭제
			reportDao.deleteChemicalTestItems(param);      // chemical_test_item 삭제
	
			//3. lab_chemical_test_item 등록
			ArrayList<HashMap<String,Object>> itemList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < typeCodeArr.size() ; i++ ) {
				HashMap<String,Object> itemMap = new HashMap<String,Object>();
				itemMap.put("chemicalIdx", param.get("idx"));
				
				try{
					itemMap.put("typeCode", typeCodeArr.get(i));
				} catch(Exception e) {
					itemMap.put("typeCode", "");
				}
				
				try{
					itemMap.put("itemContent", itemContentArr.get(i));
				} catch(Exception e) {
					itemMap.put("itemContent", "");
				}
				
				itemList.add(itemMap);
			}			
			reportDao.insertChemicalTestItem(itemList);
	
			reportDao.deleteChemicalTestStandards(param);  // chemical_test_standard 삭제
			
			//4. lab_chemical_test_standard 등록
			ArrayList<HashMap<String,Object>> standardList = new ArrayList<HashMap<String,Object>>();
			if( standard1Arr.size() > 0 ) {
				for( int i = 0 ; i < standard1Arr.size() ; i++ ) {
					HashMap<String,Object> standard1 = new HashMap<String,Object>();
					standard1.put("chemicalIdx", param.get("idx"));
					standard1.put("typeCode", "MET");
					standard1.put("standardContent", standard1Arr.get(i));
					standardList.add(standard1);
				}				
			}
			
			if( standard2Arr.size() > 0 ) {
				for( int i = 0 ; i < standard2Arr.size() ; i++ ) {
					HashMap<String,Object> standard2 = new HashMap<String,Object>();
					standard2.put("chemicalIdx", param.get("idx"));
					standard2.put("typeCode", "SCH");
					standard2.put("standardContent", standard2Arr.get(i));
					standardList.add(standard2);
				}				
			}
			
			if( standardList != null && standardList.size() > 0 ) {
				//등록한다.
				reportDao.insertChemicalTestStandard(standardList);
			}
	
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", param.get("idx"));
			historyParam.put("docType", param.get("docType"));
			historyParam.put("historyType", "U");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			// 기존 파일 삭제
			Object deletedFileListObj = param.get("deletedFileList");
			if (deletedFileListObj instanceof List<?>) {
			    List<?> deletedList = (List<?>) deletedFileListObj;

			    for (Object item : deletedList) {
			        if (item == null) continue;

			        try {
			        	String fileIdx = String.valueOf(item);

			        	Map<String, Object> paramMap = new HashMap<String, Object>();
			        	paramMap.put("idx", fileIdx);
			        	Map<String, String> fileData = commonDao.selectFileData(paramMap);

			        	if (fileData != null && fileData.get("FILE_PATH") != null && fileData.get("FILE_NAME") != null) {
			        		String filePath = fileData.get("FILE_PATH"); // ex. C:/develop/upload/chemical/202505
			        		String fileName = fileData.get("FILE_NAME"); // ex. xxx.pdf

			        		// OS에 맞게 경로 조합
			        		File deleteFile = new File(filePath + File.separator + fileName);
			        	    if (deleteFile.exists()) {
			        	        boolean deleted = deleteFile.delete();
			        	        if (!deleted) {
			        	            System.err.println("파일 삭제 실패: " + filePath + File.separator + fileName);
			        	        }
			        	    }
			        	}
			        	commonDao.deleteFileData(fileIdx);

			        } catch (NumberFormatException e) {
			            System.err.println("FILE_IDX 파싱 실패: " + item);
			        }
			    }
			}
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				path = config.getProperty("upload.file.path.chemical");
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

}
