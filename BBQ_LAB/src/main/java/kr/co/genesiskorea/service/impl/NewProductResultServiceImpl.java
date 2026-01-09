package kr.co.genesiskorea.service.impl;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.annotation.Resource;

import org.apache.commons.lang3.StringEscapeUtils;
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
import kr.co.genesiskorea.dao.NewProductResultDao;
import kr.co.genesiskorea.service.NewProductResultService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class NewProductResultServiceImpl implements NewProductResultService {
	private Logger logger = LogManager.getLogger(NewProductResultServiceImpl.class);
	
	@Autowired
	NewProductResultDao newProductResultDao;
	
	@Autowired
	private Properties config;
	
	@Autowired
	CommonDao commonDao;
	
	@Resource
	DataSourceTransactionManager txManager;

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return newProductResultDao.selectHistory(param);
	}

	@Override
	public Map<String, Object> selectNewProductResultList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = newProductResultDao.selectNewProductResultCount(param);
		
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
		
		List<Map<String, Object>> newProductResultList = newProductResultDao.selectNewProductResultList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", newProductResultList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	public List<Map<String, Object>> searchNewProductResultListAjax(Map<String, Object> param){
		// TODO Auto-generated method stub
		return newProductResultDao.searchNewProductResultListAjax(param);
	}

	@Override
	public int insertNewProductResult(Map<String, Object> param, List<List<Map<String, Object>>> resultItemArr,
			List<Map<String, Object>> itemImageArr, List<MultipartFile> imageFiles, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		int resultIdx = 0;

		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
	    try {
	        resultIdx = newProductResultDao.selectNewProductResultSeq();
	        param.put("resultIdx", resultIdx);

	        // 날짜 경로 (yyyyMM)
	        String datePath = new SimpleDateFormat("yyyyMM").format(new Date());

	        param.put("isDelete", "N");
	        
	        // ✅ 경로 설정
	        String imageBasePath = config.getProperty("upload.file.path.images") + "/" + datePath;
	        String fileBasePath = config.getProperty("upload.file.path.newProductResult") + "/" + datePath;

	        // ✅ 1. 헤더 등록
	        newProductResultDao.insertNewProductResult(param);

	        // ✅ 2. 항목 전체를 모은 flat한 리스트 생성
	        List<Map<String, Object>> itemList = new ArrayList<Map<String, Object>>();

	        for (int i = 0; i < resultItemArr.size(); i++) {
	            List<Map<String, Object>> rowList = resultItemArr.get(i);
	            for (int j = 0; j < rowList.size(); j++) {
	                Map<String, Object> item = rowList.get(j);
	                item.put("resultIdx", resultIdx);
	                itemList.add(item);
	            }
	        }
	        
	        // ✅ 한 번에 insert ( 직접입력이 아닌경우에는 인서트 회피 )
	        if (!itemList.isEmpty()) {
	            newProductResultDao.insertNewProductResultItems(itemList);
	        }
	        
	        // ✅ 3. 이미지 저장
	        List<Map<String, Object>> imageMetaList = new ArrayList<Map<String, Object>>();

	        if (itemImageArr != null && imageFiles != null) {
	            for (int i = 0; i < itemImageArr.size(); i++) {
	                Map<String, Object> imgInfo = itemImageArr.get(i);
	                int rowNo = ((Integer) imgInfo.get("rowNo")).intValue();
	                MultipartFile imageFile = imageFiles.get(i);

	                if (imageFile != null && !imageFile.isEmpty()) {
	                    String orgFileName = imageFile.getOriginalFilename();
	                    String imageIdx = FileUtil.getUUID();
	                    String fileName = imageIdx + "_" + orgFileName;

	                    File dest = new File(imageBasePath, fileName);
	                    dest.getParentFile().mkdirs();
	                    imageFile.transferTo(dest);
	                    
	                    Map<String, Object> imageMap = new HashMap<String, Object>();
	                    imageMap.put("imageIdx", imageIdx);
	                    imageMap.put("resultIdx", resultIdx);
	                    imageMap.put("rowNo", rowNo);
	                    imageMap.put("fileName", fileName);
	                    imageMap.put("orgFileName", orgFileName);
	                    imageMap.put("filePath", "/" + datePath);
	                    
	                    imageMetaList.add(imageMap);
	                }
	            }

	            // ✅ 일괄 insert
	            if (!imageMetaList.isEmpty()) {
	                newProductResultDao.insertNewProductResultItemImage(imageMetaList);
	            }
	        }


	        // ✅ 4. 첨부파일 저장
	        if (file != null && file.length > 0) {
	            for (int i = 0; i < file.length; i++) {
	                MultipartFile multipartFile = file[i];
	                if (multipartFile != null && !multipartFile.isEmpty()) {
	                    String fileIdx = FileUtil.getUUID();
	                    String orgFileName = multipartFile.getOriginalFilename();
	                    String fileName = fileIdx + "_" + orgFileName;
	                    
	                    File dest = new File(fileBasePath, fileName);
	                    dest.getParentFile().mkdirs();
	                    multipartFile.transferTo(dest);
	                    // ✅ PDF 텍스트 추출
	                    String content = "";
	                    try {
	                        content = FileUtil.getPdfContents(fileBasePath, fileName);
	                    } catch (Exception e) {
	                    }
	                    Map<String, Object> fileMap = new HashMap<String, Object>();
	                    fileMap.put("fileIdx", fileIdx);
	                    fileMap.put("docIdx", resultIdx);
	                    fileMap.put("docType", "RESULT");
	                    fileMap.put("fileType", "00");
	                    fileMap.put("orgFileName", orgFileName);
	                    fileMap.put("filePath", fileBasePath);
	                    fileMap.put("changeFileName", fileName);
	                    fileMap.put("content", content); // ✅ 추가

	                    commonDao.insertFileInfo(fileMap);
	                }
	            }
	        }

	        // ✅ 5. 히스토리 저장
	        Map<String, Object> historyParam = new HashMap<String, Object>();
	        historyParam.put("docIdx", resultIdx);
	        historyParam.put("docType", "RESULT");
	        if ( "TMP".equals(param.get("status")) ){
	        	historyParam.put("historyType", "T");	        	
	        } else {
	        	historyParam.put("historyType", "I");	        		        			        	
	        }
	        historyParam.put("historyData", param.toString());
	        historyParam.put("userId", param.get("userId"));
	        commonDao.insertHistory(historyParam);

	        txManager.commit(status);
	    } catch (Exception e) {
	    	txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
	    }

	    return resultIdx;
	}
	
	@Override
	public Map<String, Object> selectNewProductResultData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		Map<String, Object> data = newProductResultDao.selectNewProductResultData(param);
		param.put("docType", "RESULT");
		List<Map<String, String>> fileList = commonDao.selectFileList(param);
		map.put("data", data);
		map.put("fileList", fileList);
		return map;
	}

	@Override
	public List<Map<String, Object>> selectNewProductResultItemList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return newProductResultDao.selectNewProductResultItemList(param);
	}

	@Override
	public List<Map<String, Object>> selectNewProductResultItemImageList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return newProductResultDao.selectNewProductResultItemImageList(param);
	}

	@Override
	public int updateNewProductResult(Map<String, Object> param, List<List<Map<String, Object>>> resultItemArr,
			List<Map<String, Object>> itemImageArr, MultipartFile[] file, List<MultipartFile> imageFiles,
			List<String> deletedFileList) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
	        String idx = String.valueOf(param.get("idx"));
	        String userId = String.valueOf(param.get("userId"));
	        String datePath = new SimpleDateFormat("yyyyMM").format(new Date());

	        param.put("isDelete", "N");
	        
	        String imageBasePath = config.getProperty("upload.file.path.images") + "/" + datePath;
	        String fileBasePath = config.getProperty("upload.file.path.newProductResult") + "/" + datePath;

	        // ✅ 1. 허더 업데이트
	        newProductResultDao.updateNewProductResult(param);

	        // ✅ 2. 기존 항목 삭제 후 재생입
	        newProductResultDao.deleteNewProductResultItems(param);

	        List<Map<String, Object>> itemList = new ArrayList<Map<String, Object>>();
	        for (List<Map<String, Object>> row : resultItemArr) {
	            for (Map<String, Object> cell : row) {
	                cell.put("resultIdx", idx);
	                itemList.add(cell);
	            }
	        }
	        
	        
	        // ✅ 한 번에 insert ( 직접입력이 아닌경우에는 인서트 회피 )
	        if (!itemList.isEmpty()) {
	            newProductResultDao.insertNewProductResultItems(itemList);
	        }
	        
		     // ✅ 3. 기존 이미지 삭제 후 새로 저장
	
		     // 1. 기존 이미지 목록을 로딩 (ROW_NO 기준 Map 생성)
		     List<Map<String, Object>> existingImages = newProductResultDao.selectNewProductResultItemImages(param);
		     Map<Integer, Map<String, Object>> existingImageMap = new HashMap<Integer, Map<String, Object>>();
		     for (Map<String, Object> img : existingImages) {
		         int rowNo = Integer.parseInt(String.valueOf(img.get("ROW_NO")));
		         existingImageMap.put(rowNo, img);
		     }
	
		     // 2. insert할 이미지 메타 정보 / 삭제할 파일 목록
		     List<Map<String, Object>> insertList = new ArrayList<Map<String, Object>>();
		     List<String> deletePhysicalFiles = new ArrayList<String>();
	
		     String imageRootPath = config.getProperty("upload.file.path.images");
	
		     int imgIndex = 0;
		     for (Map<String, Object> imgInfo : itemImageArr) {
		         int rowNo = Integer.parseInt(String.valueOf(imgInfo.get("rowNo")));
		         boolean keep = Boolean.parseBoolean(String.valueOf(imgInfo.get("keepExisting")));
	
		         Map<String, Object> existing = existingImageMap.get(rowNo);
	
		         // ✅ 유지 요청 → 아무것도 안 함
		         if (keep && existing != null) continue;
	
		         // 🔥 기존 이미지 삭제 예약
		         if (existing != null) {
		             String relativePath = String.valueOf(existing.get("FILE_PATH"));
		             String fileName = String.valueOf(existing.get("FILE_NAME"));
		             String fullPath = imageRootPath + relativePath + File.separator + fileName;
	
		             deletePhysicalFiles.add(fullPath);
	
		             // DB 삭제
		             Map<String, Object> deleteParam = new HashMap<String, Object>();
		             deleteParam.put("rowNo", rowNo);
		             deleteParam.put("resultIdx", param.get("idx"));
		             newProductResultDao.deleteNewProductResultItemImageByRow(deleteParam);
		         }
	
		         // ✅ 새 이미지 등록
		         if (!keep && imgIndex < imageFiles.size()) {
		             MultipartFile imageFile = imageFiles.get(imgIndex++);
		             if (imageFile != null && !imageFile.isEmpty()) {
		                 String orgFileName = imageFile.getOriginalFilename();
		                 String imageIdx = FileUtil.getUUID();
		                 String fileName = imageIdx + "_" + orgFileName;
	
		                 File dest = new File(imageBasePath, fileName);
		                 dest.getParentFile().mkdirs();
		                 imageFile.transferTo(dest);
	
		                 Map<String, Object> imageMap = new HashMap<String, Object>();
		                 imageMap.put("imageIdx", imageIdx);
		                 imageMap.put("resultIdx", param.get("idx"));
		                 imageMap.put("rowNo", rowNo);
		                 imageMap.put("orgFileName", orgFileName);
		                 imageMap.put("fileName", fileName);
		                 imageMap.put("filePath", "/" + datePath);
		                 insertList.add(imageMap);
		             }
		         }
		     }
	
		     // 3. 삭제 예약된 실제 이미지 파일 삭제
		     for (String path : deletePhysicalFiles) {
		         File imagefile = new File(path);
		         if (imagefile.exists()) {
		             boolean deleted = imagefile.delete();
		             if (!deleted) {
		             }
		         } else {
		         }
		     }
	
		     // 4. 새 이미지 DB 저장
		     if (!insertList.isEmpty()) {
		         newProductResultDao.insertNewProductResultItemImage(insertList);
		     }
		     
		     JSONParser parser = new JSONParser();
		     JSONArray deletedFileIdArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("deletedFileIdArr")));
			 JSONArray deletedFileArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("deletedFileArr")));
			 JSONArray deletedFilePathArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("deletedFilePathArr")));
			 
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

	        // ✅ 4. 삭제된 찮드파일 삭제 처리
	        /*if (deletedFileList != null) {
	            for (String fileIdx : deletedFileList) {
	                Map<String, Object> fparam = new HashMap<String, Object>();
	                fparam.put("idx", fileIdx);
	                Map<String, String> fileData = commonDao.selectFileData(fparam);
	                String basePath = config.getProperty("upload.file.path.newProductResult");  // 예: C:/upload/newProductResult
                	String filePath = fileData.get("FILE_PATH");  // 예: /202505
                	String fileName = fileData.get("FILE_NAME");

                	if (filePath != null && fileName != null) {
                	    File deleteFile = new File(basePath + filePath, fileName);  // ✅ 경로 조합
                	    if (deleteFile.exists()) {
                	        boolean deleted = deleteFile.delete();
                	        if (!deleted) {
                	        }
                	    } else {
                	    }
                	}
	                	
	                commonDao.deleteFileData(fileIdx);
	            }
	        }*/

	        // ✅ 5. 일반 찮드파일 저장
	        if (file != null && file.length > 0) {
	            for (MultipartFile multipartFile : file) {
	                if (multipartFile != null && !multipartFile.isEmpty()) {
	                    String fileIdx = FileUtil.getUUID();
	                    String orgFileName = multipartFile.getOriginalFilename();
	                    String fileName = fileIdx + "_" + orgFileName;

	                    File dest = new File(fileBasePath, fileName);
	                    dest.getParentFile().mkdirs();
	                    multipartFile.transferTo(dest);
	                    // ✅ PDF 텍스트 추출
	                    String content = "";
	                    try {
	                        content = FileUtil.getPdfContents(fileBasePath, fileName);
	                    } catch (Exception e) {
	                    }
	                    Map<String, Object> fileMap = new HashMap<String, Object>();
	                    fileMap.put("fileIdx", fileIdx);
	                    fileMap.put("docIdx", idx);
	                    fileMap.put("docType", "RESULT");
	                    fileMap.put("fileType", "00");
	                    fileMap.put("orgFileName", orgFileName);
	                    fileMap.put("filePath", fileBasePath);
	                    fileMap.put("changeFileName", fileName);
	                    fileMap.put("content", content);  // ✅ 추가됨
	                    
	                    commonDao.insertFileInfo(fileMap);
	                }
	            }
	        }

	        // ✅ 6. 이력 저장
	        Map<String, Object> historyParam = new HashMap<String, Object>();
	        historyParam.put("docIdx", idx);
	        historyParam.put("docType", "RESULT");
	        if ("TMP".equals(param.get("status"))) {
	        	historyParam.put("historyType", "T");
	        } else {
	        	historyParam.put("historyType", "U");	        	
	        }
	        
	        historyParam.put("historyData", param.toString());
	        historyParam.put("userId", userId);
	        commonDao.insertHistory(historyParam);
	        
	        txManager.commit(status);
	        
	        return Integer.parseInt(idx);
	    } catch (Exception e) {
	    	txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
	    }
	}

	@Override
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return newProductResultDao.selectMyDataCheck(param);
	}

	@Override
	public void deleteNewProduct(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		newProductResultDao.deleteNewProduct(param);
	}
}
