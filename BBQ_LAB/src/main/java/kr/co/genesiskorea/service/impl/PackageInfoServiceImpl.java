package kr.co.genesiskorea.service.impl;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.annotation.Resource;

import org.apache.commons.io.FileUtils;
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
import kr.co.genesiskorea.dao.PackageInfoDao;
import kr.co.genesiskorea.service.PackageInfoService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class PackageInfoServiceImpl implements PackageInfoService {
	private Logger logger = LogManager.getLogger(PackageInfoServiceImpl.class);
	
	@Autowired
	PackageInfoDao  packageInfoDao;
	
	@Autowired
	private Properties config;
	
	@Autowired
	CommonDao commonDao;
	
	@Resource
	DataSourceTransactionManager txManager;
	
	@Override
	public Map<String, Object> selectPackageInfoList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = packageInfoDao.selectPackageInfoCount(param);
		
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
		
		List<Map<String, Object>> productList = packageInfoDao.selectPackageInfoList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", productList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	public int insertPackageInfoTmp(Map<String, Object> param, MultipartFile imageFile, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int infoIdx = 0;
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray etcArr = (JSONArray) parser.parse((String)param.get("etcArr"));
			
			//1. idx 조회
			infoIdx = packageInfoDao.selectPackageInfoSeq();	//key value 조회
			param.put("idx", infoIdx);
			
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
			String path = config.getProperty("upload.file.path.images");
			path += "/"+toDay;
			
			// 5. 이미지 파일 저장
			if( imageFile != null && !imageFile.isEmpty() ) {
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
			
			//2. 표시사항 기재양식 등록
			packageInfoDao.insertPackageInfo(param);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( etcArr.size() > 0 ) {
				for( int i = 0 ; i < etcArr.size() ; i++ ) {					
					if( etcArr.get(i) != null && !"".equals(etcArr.get(i)) ) {
						HashMap<String,Object> etcData = new HashMap<String,Object>();
						etcData.put("idx", infoIdx);
						etcData.put("displayOrder", i+1);
						etcData.put("infoType", "ETC");
						etcData.put("infoText", etcArr.get(i));
						addInfoList.add(etcData);
					}
				}
			}			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				packageInfoDao.insertPackageInfoAddInfo(addInfoList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", infoIdx);
			historyParam.put("docType", param.get("docType"));
			historyParam.put("historyType", "T");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				path = config.getProperty("upload.file.path.package");
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
							fileMap.put("docIdx", infoIdx);
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
		return infoIdx;
	}
	
	@Override
	public int insertPackageInfo(Map<String, Object> param, MultipartFile imageFile, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int infoIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray etcArr = (JSONArray) parser.parse((String)param.get("etcArr"));
			
			//1. idx 조회
			infoIdx = packageInfoDao.selectPackageInfoSeq();	//key value 조회
			param.put("idx", infoIdx);
			
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
			String path = config.getProperty("upload.file.path.images");
			path += "/"+toDay;
			
			// 5. 이미지 파일 저장
			if( imageFile != null && !imageFile.isEmpty() ) {
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
			
			//2. 표시사항 기재양식 등록
			packageInfoDao.insertPackageInfo(param);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( etcArr.size() > 0 ) {
				for( int i = 0 ; i < etcArr.size() ; i++ ) {					
					if( etcArr.get(i) != null && !"".equals(etcArr.get(i)) ) {
						HashMap<String,Object> etcData = new HashMap<String,Object>();
						etcData.put("idx", infoIdx);
						etcData.put("displayOrder", i+1);
						etcData.put("infoType", "ETC");
						etcData.put("infoText", etcArr.get(i));
						addInfoList.add(etcData);
					}
				}
			}			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				packageInfoDao.insertPackageInfoAddInfo(addInfoList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", infoIdx);
			historyParam.put("docType", param.get("docType"));
			historyParam.put("historyType", "I");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				path = config.getProperty("upload.file.path.package");
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
							fileMap.put("docIdx", infoIdx);
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
		return infoIdx;
	}

	@Override
	public Map<String, Object> selectPackageInfoData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		Map<String, Object> data = packageInfoDao.selectPackageInfoData(param);
		param.put("docType", "PACKAGE");
		List<Map<String, String>> fileList = commonDao.selectFileList(param);
		map.put("data", data);
		map.put("fileList", fileList);
		return map;
	}

	@Override
	public List<Map<String, Object>> selectAddInfoList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return packageInfoDao.selectAddInfoList(param);
	}

	@Override
	public void updatePackageInfoTmp(Map<String, Object> param, MultipartFile imageFile, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray etcArr = (JSONArray) parser.parse((String)param.get("etcArr"));
			
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
			String path = config.getProperty("upload.file.path.images");
			
			
			String deleteFlag = String.valueOf(param.getOrDefault("imageDeleteFlag", "N"));

			// "undefined" 문자열 정리
			if ("undefined".equals(param.get("orgFileName"))) param.put("orgFileName", null);
			if ("undefined".equals(param.get("fileName"))) param.put("fileName", null);
			if ("undefined".equals(param.get("filePath"))) param.put("filePath", null);
			

			// 삭제 조건 확인
			if ("Y".equals(deleteFlag) || (imageFile != null && !imageFile.isEmpty())) {
			    Object filePathObj = param.get("filePath");
			    Object fileNameObj = param.get("fileName");

			    if (filePathObj != null && fileNameObj != null) {
			        // 파일 경로 조합 (File.separator 대신 Paths.get을 써도 무방)
			        String prevImgPath = path + File.separator
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
			
			// 5. 이미지 파일 저장
			if( imageFile != null && !imageFile.isEmpty() ) {
				path += "/"+toDay;
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
			
			//1. 표시사항 기재양식 등록
			packageInfoDao.updatePackageInfo(param);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( etcArr.size() > 0 ) {
				for( int i = 0 ; i < etcArr.size() ; i++ ) {					
					if( etcArr.get(i) != null && !"".equals(etcArr.get(i)) ) {
						HashMap<String,Object> etcData = new HashMap<String,Object>();
						etcData.put("idx", param.get("idx"));
						etcData.put("displayOrder", i+1);
						etcData.put("infoType", "ETC");
						etcData.put("infoText", etcArr.get(i));
						addInfoList.add(etcData);
					}
				}
			}
			packageInfoDao.deletePackageInfoAddInfo(param);
			if( addInfoList != null && addInfoList.size() > 0 ) {
				packageInfoDao.insertPackageInfoAddInfo(addInfoList);
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
				path = config.getProperty("upload.file.path.package");
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
	public void updatePackageInfo(Map<String, Object> param, MultipartFile imageFile, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray etcArr = (JSONArray) parser.parse((String)param.get("etcArr"));
			
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
			String path = config.getProperty("upload.file.path.images");
			
			String deleteFlag = String.valueOf(param.getOrDefault("imageDeleteFlag", "N"));

			// "undefined" 문자열 정리
			if ("undefined".equals(param.get("orgFileName"))) param.put("orgFileName", null);
			if ("undefined".equals(param.get("fileName"))) param.put("fileName", null);
			if ("undefined".equals(param.get("filePath"))) param.put("filePath", null);

			// 삭제 조건 확인
			if ("Y".equals(deleteFlag) || (imageFile != null && !imageFile.isEmpty())) {
			    Object filePathObj = param.get("filePath");
			    Object fileNameObj = param.get("fileName");

			    if (filePathObj != null && fileNameObj != null) {
			        // 파일 경로 조합 (File.separator 대신 Paths.get을 써도 무방)
			        String prevImgPath = path + File.separator
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
			
			// 5. 이미지 파일 저장
			if( imageFile != null && !imageFile.isEmpty() ) {
				path += "/"+toDay;
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
			
			//1. 표시사항 기재양식 등록
			packageInfoDao.updatePackageInfo(param);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( etcArr.size() > 0 ) {
				for( int i = 0 ; i < etcArr.size() ; i++ ) {					
					if( etcArr.get(i) != null && !"".equals(etcArr.get(i)) ) {
						HashMap<String,Object> etcData = new HashMap<String,Object>();
						etcData.put("idx", param.get("idx"));
						etcData.put("displayOrder", i+1);
						etcData.put("infoType", "ETC");
						etcData.put("infoText", etcArr.get(i));
						addInfoList.add(etcData);
					}
				}
			}
			packageInfoDao.deletePackageInfoAddInfo(param);
			if( addInfoList != null && addInfoList.size() > 0 ) {
				packageInfoDao.insertPackageInfoAddInfo(addInfoList);
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
				path = config.getProperty("upload.file.path.package");
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
	public int insertVersionUpTmp(Map<String, Object> param, MultipartFile imageFile, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int infoIdx = 0;
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray etcArr = (JSONArray) parser.parse((String)param.get("etcArr"));
			
			//개정하는 문서 버젼이 현재 보다 높은 경우에 현재 버젼 문서 상태를 변경한다.
			packageInfoDao.updatePackageInfoIsLast(param);
			
			//1. idx 조회
			infoIdx = packageInfoDao.selectPackageInfoSeq();	//key value 조회
			param.put("idx", infoIdx);
			
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
			String path = config.getProperty("upload.file.path.images");
			// 5. 이미지 파일 저장
			if( imageFile != null && !imageFile.isEmpty() ) {
				path += "/"+toDay;
				String fileIdx = FileUtil.getUUID();
				String result = FileUtil.upload3(imageFile,path,fileIdx);
				param.put("orgFileName", imageFile.getOriginalFilename());
				param.put("filePath", "/"+toDay);
				param.put("fileName", result);
			} else {
				String deleteFlag = String.valueOf(param.getOrDefault("imageDeleteFlag", "N"));
				if( deleteFlag != null && "N".equals(deleteFlag) ) {	//이미지 업로드하지 않고 삭제도 하지 않은경우
					String orgFileName = (String)param.get("orgFileName");
					String fileName = (String)param.get("fileName");
					String filePath = (String)param.get("filePath");
					//이전 파일 정보가 남은 경우
					if( orgFileName != null && !"".equals(orgFileName) && !"undefined".equals(orgFileName) ) {
						String currentFilePath = path+File.separator+filePath.toString().replaceFirst("^/", "")+File.separator+fileName;
						String fileIdx = FileUtil.getUUID();
						String newFilePath = path+File.separator+toDay;
						String newFileName = fileIdx+"_"+orgFileName;
						File currentFile = new File(currentFilePath);						
						File newFile = new File(newFilePath+File.separator+newFileName);
						//Files.copy(currentFile.toPath(), newFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
						FileUtils.copyFile(currentFile, newFile);
						param.put("orgFileName", orgFileName);
						param.put("filePath", File.separator+toDay);
						param.put("fileName", newFileName);
					}
				} else {
					//파일을 등록하지 않은 경우.
					param.put("orgFileName", "");
					param.put("filePath", "");
					param.put("fileName", "");
				}
			}
			
			//2. 표시사항 기재양식 등록
			packageInfoDao.insertVersionUp(param);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( etcArr.size() > 0 ) {
				for( int i = 0 ; i < etcArr.size() ; i++ ) {					
					if( etcArr.get(i) != null && !"".equals(etcArr.get(i)) ) {
						HashMap<String,Object> etcData = new HashMap<String,Object>();
						etcData.put("idx", infoIdx);
						etcData.put("displayOrder", i+1);
						etcData.put("infoType", "ETC");
						etcData.put("infoText", etcArr.get(i));
						addInfoList.add(etcData);
					}
				}
			}			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				packageInfoDao.insertPackageInfoAddInfo(addInfoList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", infoIdx);
			historyParam.put("docType", param.get("docType"));
			historyParam.put("historyType", "V");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				path = config.getProperty("upload.file.path.package");
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
							fileMap.put("docIdx", infoIdx);
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
		return infoIdx;
	}

	@Override
	public int insertVersionUp(Map<String, Object> param, MultipartFile imageFile, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int infoIdx = 0;
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			JSONParser parser = new JSONParser();
			JSONArray etcArr = (JSONArray) parser.parse((String)param.get("etcArr"));
			
			//개정하는 문서 버젼이 현재 보다 높은 경우에 현재 버젼 문서 상태를 변경한다.
			packageInfoDao.updatePackageInfoIsLast(param);
			
			//1. idx 조회
			infoIdx = packageInfoDao.selectPackageInfoSeq();	//key value 조회
			param.put("idx", infoIdx);
			
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
			String path = config.getProperty("upload.file.path.images");
			// 5. 이미지 파일 저장
			if( imageFile != null && !imageFile.isEmpty() ) {
				path += "/"+toDay;
				String fileIdx = FileUtil.getUUID();
				String result = FileUtil.upload3(imageFile,path,fileIdx);
				param.put("orgFileName", imageFile.getOriginalFilename());
				param.put("filePath", "/"+toDay);
				param.put("fileName", result);
			} else {
				String deleteFlag = String.valueOf(param.getOrDefault("imageDeleteFlag", "N"));
				if( deleteFlag != null && "N".equals(deleteFlag) ) {	//이미지 업로드하지 않고 삭제도 하지 않은경우
					String orgFileName = (String)param.get("orgFileName");
					String fileName = (String)param.get("fileName");
					String filePath = (String)param.get("filePath");
					//이전 파일 정보가 남은 경우
					if( orgFileName != null && !"".equals(orgFileName) && !"undefined".equals(orgFileName) ) {
						String currentFilePath = path+File.separator+filePath.toString().replaceFirst("^/", "")+File.separator+fileName;
						String fileIdx = FileUtil.getUUID();
						String newFilePath = path+File.separator+toDay;
						String newFileName = fileIdx+"_"+orgFileName;
						File currentFile = new File(currentFilePath);						
						File newFile = new File(newFilePath+File.separator+newFileName);
						//Files.copy(currentFile.toPath(), newFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
						FileUtils.copyFile(currentFile, newFile);
						param.put("orgFileName", orgFileName);
						param.put("filePath", File.separator+toDay);
						param.put("fileName", newFileName);
					}
				} else {
					//파일을 등록하지 않은 경우.
					param.put("orgFileName", "");
					param.put("filePath", "");
					param.put("fileName", "");
				}
			}
			
			//2. 표시사항 기재양식 등록
			packageInfoDao.insertVersionUp(param);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( etcArr.size() > 0 ) {
				for( int i = 0 ; i < etcArr.size() ; i++ ) {					
					if( etcArr.get(i) != null && !"".equals(etcArr.get(i)) ) {
						HashMap<String,Object> etcData = new HashMap<String,Object>();
						etcData.put("idx", infoIdx);
						etcData.put("displayOrder", i+1);
						etcData.put("infoType", "ETC");
						etcData.put("infoText", etcArr.get(i));
						addInfoList.add(etcData);
					}
				}
			}			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				packageInfoDao.insertPackageInfoAddInfo(addInfoList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", infoIdx);
			historyParam.put("docType", param.get("docType"));
			historyParam.put("historyType", "V");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				path = config.getProperty("upload.file.path.package");
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
							fileMap.put("docIdx", infoIdx);
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
		return infoIdx;
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return packageInfoDao.selectHistory(param);
	}

	@Override
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return packageInfoDao.selectMyDataCheck(param);
	}

	@Override
	public Map<String, Object> selectPackageInfoDataByProductCode(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return packageInfoDao.selectPackageInfoDataByProductCode(param);
	}
}
