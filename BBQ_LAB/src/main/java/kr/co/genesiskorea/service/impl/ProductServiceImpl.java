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

import com.fasterxml.jackson.annotation.JsonIgnore;

import kr.co.genesiskorea.dao.ApprovalDao;
import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.dao.ProductDao;
import kr.co.genesiskorea.service.CommonService;
import kr.co.genesiskorea.service.ProductService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
//import kr.co.genesiskorea.vo.FileVO;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class ProductServiceImpl implements ProductService {
	private Logger logger = LogManager.getLogger(ProductServiceImpl.class);
	
	@Autowired
	ProductDao productDao;
	
	@Autowired
	CommonDao commonDao;
	
	@Autowired
	CommonService commonService;
	
	@Autowired
	ApprovalDao approvalDao;
	
	@Autowired
	private Properties config;
	
	@Resource
	DataSourceTransactionManager txManager;
	
	@Override
	public String selectProductCode() {
		// TODO Auto-generated method stub
		return productDao.selectProductCode();
	}
	
	@Override
	public List<Map<String, Object>> checkMaterial(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return productDao.checkMaterial(param);
	}

	@Override
	public Map<String, Object> selectMaterialList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		System.err.println(param);
		int totalCount = productDao.selectMaterialCount(param);
		
		int viewCount = 10;
		int pageNo = 1;
		try {
			pageNo = Integer.parseInt((String)param.get("pageNo"));
		} catch( Exception e ) {
			System.err.println(e.getMessage());
			pageNo = 1;
		}
		
		int startRow = (pageNo-1)*viewCount+1;
		int endRow = pageNo*viewCount;
		
		param.put("startRow", startRow);
		param.put("endRow", endRow);
		
		List<Map<String, String>> materialList = productDao.selectMaterialList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", materialList);		
		
		return map;
	}

	@Override
	public Map<String, Object> selectProductDataCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		int count = productDao.selectProductDataCount(param);
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("COUNT", count);		
		return map;
	}
	
	@Override
	@Transactional
	public int insertTmpProduct(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		int productIdx;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			ArrayList<String> usageArr = (ArrayList<String>)listMap.get("usageArr");
			String usageType = (String)listMap.get("usageType");
			ArrayList<String> productType = (ArrayList<String>)listMap.get("productType");
			ArrayList<String> fileType = (ArrayList<String>)listMap.get("fileType");
			ArrayList<String> fileTypeText = (ArrayList<String>)listMap.get("fileTypeText");
			ArrayList<String> docType = (ArrayList<String>)listMap.get("docType");
			ArrayList<String> docTypeText = (ArrayList<String>)listMap.get("docTypeText");
			ArrayList<String> tempFile = (ArrayList<String>)listMap.get("tempFile");
			
			JSONParser parser = new JSONParser();
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray featureArr = (JSONArray) parser.parse((String)param.get("featureArr"));
			JSONArray newItemNameArr = (JSONArray) parser.parse((String)param.get("newItemNameArr"));
			JSONArray newItemStandardArr = (JSONArray) parser.parse((String)param.get("newItemStandardArr"));
			JSONArray newItemSupplierArr = (JSONArray) parser.parse((String)param.get("newItemSupplierArr"));
			JSONArray newItemKeepExpArr = (JSONArray) parser.parse((String)param.get("newItemKeepExpArr"));
			JSONArray newItemNoteArr = (JSONArray) parser.parse((String)param.get("newItemNoteArr"));
			
			JSONArray rowIdArr = (JSONArray) parser.parse((String)param.get("rowIdArr"));
			JSONArray itemTypeArr = (JSONArray) parser.parse((String)param.get("itemTypeArr"));
			JSONArray itemMatIdxArr = (JSONArray) parser.parse((String)param.get("itemMatIdxArr"));
			JSONArray itemMatCodeArr = (JSONArray) parser.parse((String)param.get("itemMatCodeArr"));
			JSONArray itemSapCodeArr = (JSONArray) parser.parse((String)param.get("itemSapCodeArr"));
			JSONArray itemNameArr = (JSONArray) parser.parse((String)param.get("itemNameArr"));
			JSONArray itemStandardArr = (JSONArray) parser.parse((String)param.get("itemStandardArr"));
			JSONArray itemKeepExpArr = (JSONArray) parser.parse((String)param.get("itemKeepExpArr"));
			JSONArray itemUnitPriceArr = (JSONArray) parser.parse((String)param.get("itemUnitPriceArr"));
			JSONArray itemDescArr = (JSONArray) parser.parse((String)param.get("itemDescArr"));
			
			productIdx = 0;
			productIdx = productDao.selectProductSeq(); 	//key value 조회
			param.put("idx", productIdx);
			
			if( productType != null && productType.size() > 0 ) {
				for( int i = 0 ; i < productType.size() ; i++ ) {
					param.put("productType"+(i+1), productType.get(i));
				}
			}

			//제품 등록
			productDao.insertProduct(param);
			
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", productIdx);
					purposeData.put("infoType", "PUR");
					purposeData.put("infoText", purposeArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( featureArr.size() > 0 ) {
				for( int i = 0 ; i < featureArr.size() ; i++ ) {
					HashMap<String,Object> featureData = new HashMap<String,Object>();
					featureData.put("idx", productIdx);
					featureData.put("infoType", "FEA");
					featureData.put("infoText", featureArr.get(i));
					addInfoList.add(featureData);
				}
			}
			
			if( usageArr != null && usageArr.size() > 0 ) {
				for( int i = 0 ; i < usageArr.size() ; i++ ) {
					HashMap<String,Object> usageData = new HashMap<String,Object>();
					usageData.put("idx", productIdx);
					usageData.put("infoType", "BRAND".equals(usageType) ? "USB" : "USC");
					usageData.put("infoText", usageArr.get(i));
					addInfoList.add(usageData);
				}
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				productDao.insertAddInfo(addInfoList);
			}
			
			//신규도입품/제품규격 등록
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < newItemNameArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", productIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("productName", newItemNameArr.get(i));
				} catch(Exception e) {
					newMap.put("productName", "");
				}
				
				try{
					newMap.put("packageStandard", newItemStandardArr.get(i));
				} catch(Exception e) {
					newMap.put("packageStandard", "");
				}
				
				try{
					newMap.put("supplier", newItemSupplierArr.get(i));
				} catch(Exception e) {
					newMap.put("supplier", "");
				}
				
				try{
					newMap.put("keepExp", newItemKeepExpArr.get(i));
				} catch(Exception e) {
					newMap.put("keepExp", "");
				}
				
				try{
					newMap.put("note", newItemNoteArr.get(i));
				} catch(Exception e) {
					newMap.put("note", "");
				}
				
				newList.add(newMap);
			}
			
			if( newList != null && newList.size() > 0 ) {
				productDao.insertProductNew(newList);
			}
			
			//원료 리스트 등록
			ArrayList<HashMap<String,String>> matList = new ArrayList<HashMap<String,String>>();
			for( int i = 0 ; i < itemSapCodeArr.size() ; i++ ) {
				HashMap<String,String> matMap = new HashMap<String,String>();
				matMap.put("itemType", (String)itemTypeArr.get(i));
				matMap.put("matIdx", (String)itemMatIdxArr.get(i));
				matMap.put("name", (String)itemNameArr.get(i));
				
				try{
					matMap.put("matCode", (String)itemMatCodeArr.get(i));
				} catch(Exception e) {
					matMap.put("matCode", "");
				}				
				try{
					matMap.put("sapCode", (String)itemSapCodeArr.get(i));
				} catch(Exception e) {
					matMap.put("sapCode", "");
				}				
				try{
					matMap.put("standard", (String)itemStandardArr.get(i));
				} catch(Exception e) {
					matMap.put("standard", "");
				}
				try{
					matMap.put("keepExp", (String)itemKeepExpArr.get(i));
				} catch(Exception e) {
					matMap.put("keepExp", "");
				}
				try{
					matMap.put("unitPrice", (String)itemUnitPriceArr.get(i));
				} catch(Exception e) {
					matMap.put("unitPrice", "");
				}
				try{
					matMap.put("desc", (String)itemDescArr.get(i));
				} catch(Exception e) {
					matMap.put("desc", "");
				}
				matList.add(matMap);
			}
			
			if( matList != null && matList.size() > 0 ) {
				param.put("matList", matList);
				productDao.insertProductMaterial(param);
			}
			
			//첨부파일 유형 저장
			List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
			if( docType != null ) {
				for( int i = 0 ; i < docType.size() ; i++ ) {
					HashMap<String, Object> paramMap = new HashMap<String, Object>();
					paramMap.put("docIdx", productIdx);
					paramMap.put("docType", "PROD");
					paramMap.put("fileType", docType.get(i));
					paramMap.put("fileTypeText", docTypeText.get(i));
					docTypeList.add(paramMap);
				}
				if( docTypeList != null && docTypeList.size() > 0 ) {
					commonDao.insertFileType(docTypeList);
				}
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", productIdx);
			historyParam.put("docType", "PROD");
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
				String path = config.getProperty("upload.file.path.product");
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
							fileMap.put("docIdx", productIdx);
							fileMap.put("docType", "PROD");
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
			return productIdx;
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
		
	}	

	@Override
	@Transactional
	public int insertProduct(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int productIdx;
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try{
			ArrayList<String> usageArr = (ArrayList<String>)listMap.get("usageArr");
			String usageType = (String)listMap.get("usageType");
			ArrayList<String> productType = (ArrayList<String>)listMap.get("productType");
			ArrayList<String> fileType = (ArrayList<String>)listMap.get("fileType");
			ArrayList<String> fileTypeText = (ArrayList<String>)listMap.get("fileTypeText");
			ArrayList<String> docType = (ArrayList<String>)listMap.get("docType");
			ArrayList<String> docTypeText = (ArrayList<String>)listMap.get("docTypeText");
			ArrayList<String> tempFile = (ArrayList<String>)listMap.get("tempFile");
			
			JSONParser parser = new JSONParser();
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray featureArr = (JSONArray) parser.parse((String)param.get("featureArr"));
			JSONArray newItemNameArr = (JSONArray) parser.parse((String)param.get("newItemNameArr"));
			JSONArray newItemStandardArr = (JSONArray) parser.parse((String)param.get("newItemStandardArr"));
			JSONArray newItemSupplierArr = (JSONArray) parser.parse((String)param.get("newItemSupplierArr"));
			JSONArray newItemKeepExpArr = (JSONArray) parser.parse((String)param.get("newItemKeepExpArr"));
			JSONArray newItemNoteArr = (JSONArray) parser.parse((String)param.get("newItemNoteArr"));
			
			JSONArray rowIdArr = (JSONArray) parser.parse((String)param.get("rowIdArr"));
			JSONArray itemTypeArr = (JSONArray) parser.parse((String)param.get("itemTypeArr"));
			JSONArray itemMatIdxArr = (JSONArray) parser.parse((String)param.get("itemMatIdxArr"));
			JSONArray itemMatCodeArr = (JSONArray) parser.parse((String)param.get("itemMatCodeArr"));
			JSONArray itemSapCodeArr = (JSONArray) parser.parse((String)param.get("itemSapCodeArr"));
			JSONArray itemNameArr = (JSONArray) parser.parse((String)param.get("itemNameArr"));
			JSONArray itemStandardArr = (JSONArray) parser.parse((String)param.get("itemStandardArr"));
			JSONArray itemKeepExpArr = (JSONArray) parser.parse((String)param.get("itemKeepExpArr"));
			JSONArray itemUnitPriceArr = (JSONArray) parser.parse((String)param.get("itemUnitPriceArr"));
			JSONArray itemDescArr = (JSONArray) parser.parse((String)param.get("itemDescArr"));
			
			productIdx = productDao.selectProductSeq(); 	//key value 조회
			param.put("idx", productIdx);
			//param.put("status", "REG");
			
			if( productType != null && productType.size() > 0 ) {
				for( int i = 0 ; i < productType.size() ; i++ ) {
					param.put("productType"+(i+1), productType.get(i));
				}
			}
			
			//제품 등록
			productDao.insertProduct(param);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", productIdx);
					purposeData.put("infoType", "PUR");
					purposeData.put("infoText", purposeArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( featureArr.size() > 0 ) {
				for( int i = 0 ; i < featureArr.size() ; i++ ) {
					HashMap<String,Object> featureData = new HashMap<String,Object>();
					featureData.put("idx", productIdx);
					featureData.put("infoType", "FEA");
					featureData.put("infoText", featureArr.get(i));
					addInfoList.add(featureData);
				}
			}
			
			if( usageArr.size() > 0 ) {
				for( int i = 0 ; i < usageArr.size() ; i++ ) {
					HashMap<String,Object> usageData = new HashMap<String,Object>();
					usageData.put("idx", productIdx);
					usageData.put("infoType", "BRAND".equals(usageType) ? "USB" : "USC");
					usageData.put("infoText", usageArr.get(i));
					addInfoList.add(usageData);
				}
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				productDao.insertAddInfo(addInfoList);
			}
			
			//신규도입품/제품규격 등록
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < newItemNameArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", productIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("productName", newItemNameArr.get(i));
				} catch(Exception e) {
					newMap.put("productName", "");
				}
				
				try{
					newMap.put("packageStandard", newItemStandardArr.get(i));
				} catch(Exception e) {
					newMap.put("packageStandard", "");
				}
				
				try{
					newMap.put("supplier", newItemSupplierArr.get(i));
				} catch(Exception e) {
					newMap.put("supplier", "");
				}
				
				try{
					newMap.put("keepExp", newItemKeepExpArr.get(i));
				} catch(Exception e) {
					newMap.put("keepExp", "");
				}
				
				try{
					newMap.put("note", newItemNoteArr.get(i));
				} catch(Exception e) {
					newMap.put("note", "");
				}
				
				newList.add(newMap);
			}
			
			if( newList != null && newList.size() > 0 ) {
				productDao.insertProductNew(newList);
			}
			
			//원료 리스트 등록
			ArrayList<HashMap<String,String>> matList = new ArrayList<HashMap<String,String>>();
			for( int i = 0 ; i < itemSapCodeArr.size() ; i++ ) {
				HashMap<String,String> matMap = new HashMap<String,String>();
				matMap.put("itemType", (String)itemTypeArr.get(i));
				matMap.put("matIdx", (String)itemMatIdxArr.get(i));
				matMap.put("name", (String)itemNameArr.get(i));
				
				try{
					matMap.put("matCode", (String)itemMatCodeArr.get(i));
				} catch(Exception e) {
					matMap.put("matCode", "");
				}				
				try{
					matMap.put("sapCode", (String)itemSapCodeArr.get(i));
				} catch(Exception e) {
					matMap.put("sapCode", "");
				}				
				try{
					matMap.put("standard", (String)itemStandardArr.get(i));
				} catch(Exception e) {
					matMap.put("standard", "");
				}
				try{
					matMap.put("keepExp", (String)itemKeepExpArr.get(i));
				} catch(Exception e) {
					matMap.put("keepExp", "");
				}
				try{
					matMap.put("unitPrice", (String)itemUnitPriceArr.get(i));
				} catch(Exception e) {
					matMap.put("unitPrice", "");
				}
				try{
					matMap.put("desc", (String)itemDescArr.get(i));
				} catch(Exception e) {
					matMap.put("desc", "");
				}
				matList.add(matMap);
			}
			param.put("matList", matList);
			productDao.insertProductMaterial(param);
			
			//첨부파일 유형 저장
			List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
			for( int i = 0 ; i < docType.size() ; i++ ) {
				HashMap<String, Object> paramMap = new HashMap<String, Object>();
				paramMap.put("docIdx", productIdx);
				paramMap.put("docType", "PROD");
				paramMap.put("fileType", docType.get(i));
				paramMap.put("fileTypeText", docTypeText.get(i));
				docTypeList.add(paramMap);
			}		
			commonDao.insertFileType(docTypeList);
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", productIdx);
			historyParam.put("docType", "PROD");
			historyParam.put("historyType", "I");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//문서 복사 시 기존 첨부파일을 유지하는 경우 기존 파일 데이터를 복사합니다.
			if( tempFile != null ) {
				if( tempFile.size() > 0 ) {
					for( int i = 0 ; i < tempFile.size() ; i++ ) {
						HashMap<String, Object> paramMap = new HashMap<String, Object>();
						String tempFileIdx = tempFile.get(i);
						String fileIdx = FileUtil.getUUID();
						paramMap.put("fileIdx", fileIdx);
						paramMap.put("tempFileIdx", tempFileIdx);
						paramMap.put("docIdx", productIdx);
						paramMap.put("docType", "PROD");
						productDao.insertFileCopy(paramMap);
					}
				}
			}
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				Calendar cal = Calendar.getInstance();
		        Date day = cal.getTime();    //시간을 꺼낸다.
		        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
		        String toDay = sdf.format(day);
				String path = config.getProperty("upload.file.path.product");
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
							fileMap.put("docIdx", productIdx);
							fileMap.put("docType", "PROD");
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
			
			return productIdx;
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public Map<String, Object> selectProductList(Map<String, Object> param)  throws Exception {
		// TODO Auto-generated method stub
		int totalCount = productDao.selectProductCount(param);
		
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
		
		List<Map<String, Object>> productList = productDao.selectProductList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", productList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	public Map<String, Object> selectProductData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		Map<String, Object> data = productDao.selectProductData(param);
		param.put("docType", "PROD");
		List<Map<String, String>> fileList = commonDao.selectFileList(param);
		List<Map<String, String>> fileType = commonDao.selectFileType(param);
		map.put("data", data);
		map.put("fileList", fileList);
		map.put("fileType", fileType);
		return map;
	}
	
	@Override
	public List<Map<String, Object>> selectAddInfo(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return productDao.selectAddInfo(param);
	}
	
	@Override
	public List<Map<String, Object>> selectNewDataList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return productDao.selectNewDataList(param);
	}

	@Override
	public List<Map<String, Object>> selectProductMaterial(Map<String, Object> param) {
		// TODO Auto-generated method stub
		List<Map<String, Object>> materialList = productDao.selectProductMaterial(param);
		return materialList;
	}

	@Override
	@JsonIgnore
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return productDao.selectHistory(param);
	}
	
	@Override
	@Transactional
	public int insertNewVersionProductTmp(Map<String, Object> param, HashMap<String, Object> listMap,
			MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int productIdx;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			ArrayList<String> usageArr = (ArrayList<String>)listMap.get("usageArr");
			String usageType = (String)listMap.get("usageType");
			ArrayList<String> productType = (ArrayList<String>)listMap.get("productType");
			ArrayList<String> fileType = (ArrayList<String>)listMap.get("fileType");
			ArrayList<String> fileTypeText = (ArrayList<String>)listMap.get("fileTypeText");
			ArrayList<String> docType = (ArrayList<String>)listMap.get("docType");
			ArrayList<String> docTypeText = (ArrayList<String>)listMap.get("docTypeText");
			
			JSONParser parser = new JSONParser();
			JSONArray itemImproveArr = (JSONArray) parser.parse((String)param.get("itemImproveArr"));
			JSONArray itemExistArr = (JSONArray) parser.parse((String)param.get("itemExistArr"));
			JSONArray itemNoteArr = (JSONArray) parser.parse((String)param.get("itemNoteArr"));
			JSONArray improveArr = (JSONArray) parser.parse((String)param.get("improveArr"));
			JSONArray newItemNameArr = (JSONArray) parser.parse((String)param.get("newItemNameArr"));
			JSONArray newItemStandardArr = (JSONArray) parser.parse((String)param.get("newItemStandardArr"));
			JSONArray newItemSupplierArr = (JSONArray) parser.parse((String)param.get("newItemSupplierArr"));
			JSONArray newItemKeepExpArr = (JSONArray) parser.parse((String)param.get("newItemKeepExpArr"));
			JSONArray newItemNoteArr = (JSONArray) parser.parse((String)param.get("newItemNoteArr"));
			JSONArray itemTypeArr = (JSONArray) parser.parse((String)param.get("itemTypeArr"));
			JSONArray itemMatIdxArr = (JSONArray) parser.parse((String)param.get("itemMatIdxArr"));
			JSONArray itemMatCodeArr = (JSONArray) parser.parse((String)param.get("itemMatCodeArr"));
			JSONArray itemSapCodeArr = (JSONArray) parser.parse((String)param.get("itemSapCodeArr"));
			JSONArray itemNameArr = (JSONArray) parser.parse((String)param.get("itemNameArr"));
			JSONArray itemStandardArr = (JSONArray) parser.parse((String)param.get("itemStandardArr"));
			JSONArray itemKeepExpArr = (JSONArray) parser.parse((String)param.get("itemKeepExpArr"));
			JSONArray itemUnitPriceArr = (JSONArray) parser.parse((String)param.get("itemUnitPriceArr"));
			JSONArray itemDescArr = (JSONArray) parser.parse((String)param.get("itemDescArr"));
			
			int currentVersionNo = Integer.parseInt((String)param.get("currentVersionNo"));	//현재 문서 버젼
			int versionNo = Integer.parseInt((String)param.get("versionNo"));				//개정 문서 버젼
			
			//개정하는 문서 버젼이 현재 보다 높은 경우에 현재 버젼 문서 상태를 변경한다.
			if( versionNo > currentVersionNo ) {	
				productDao.updateProductIsLast(param);
				param.put("isLast", "Y");	//개정하는 문서 버젼이 현재보다 높은 경우에 문서상태를 최신 상태(Y)로 저장한다.
			} else {
				param.put("isLast", "N");	//개정하는 문서 버젼이 현재보다 낮은 경우에 문서상태를 이전 상태(N)로 저장한다.
			}
			
			productIdx = productDao.selectProductSeq(); 	//key value 조회
			param.put("idx", productIdx);
			
			if( productType != null && productType.size() > 0 ) {
				for( int i = 0 ; i < productType.size() ; i++ ) {
					param.put("productType"+(i+1), productType.get(i));
				}
			}

			productDao.insertNewVersionProduct(param);
			
			//개선목적
			ArrayList<HashMap<String,Object>> imporvePurList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < itemImproveArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", productIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("improve", itemImproveArr.get(i));
				} catch(Exception e) {
					newMap.put("improve", "");
				}
				
				try{
					newMap.put("exist", itemExistArr.get(i));
				} catch(Exception e) {
					newMap.put("exist", "");
				}
				
				try{
					newMap.put("note", itemNoteArr.get(i));
				} catch(Exception e) {
					newMap.put("note", "");
				}
				imporvePurList.add(newMap);
			}
			
			if( imporvePurList != null && imporvePurList.size() > 0 ) {
				productDao.insertProductImporvePurpose(imporvePurList);
			}
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( improveArr.size() > 0 ) {
				for( int i = 0 ; i < improveArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", productIdx);
					purposeData.put("infoType", "IMP");
					purposeData.put("infoText", improveArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( usageArr.size() > 0 ) {
				for( int i = 0 ; i < usageArr.size() ; i++ ) {
					HashMap<String,Object> usageData = new HashMap<String,Object>();
					usageData.put("idx", productIdx);
					usageData.put("infoType", "BRAND".equals(usageType) ? "USB" : "USC");
					usageData.put("infoText", usageArr.get(i));
					addInfoList.add(usageData);
				}
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				productDao.insertAddInfo(addInfoList);
			}
			
			//신규도입품/제품규격 등록
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < newItemNameArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", productIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("productName", newItemNameArr.get(i));
				} catch(Exception e) {
					newMap.put("productName", "");
				}
				
				try{
					newMap.put("packageStandard", newItemStandardArr.get(i));
				} catch(Exception e) {
					newMap.put("packageStandard", "");
				}
				
				try{
					newMap.put("supplier", newItemSupplierArr.get(i));
				} catch(Exception e) {
					newMap.put("supplier", "");
				}
				
				try{
					newMap.put("keepExp", newItemKeepExpArr.get(i));
				} catch(Exception e) {
					newMap.put("keepExp", "");
				}
				
				try{
					newMap.put("note", newItemNoteArr.get(i));
				} catch(Exception e) {
					newMap.put("note", "");
				}
				
				newList.add(newMap);
			}
			
			if( newList != null && newList.size() > 0 ) {
				productDao.insertProductNew(newList);
			}
			
			//원료 리스트 등록
			ArrayList<HashMap<String,String>> matList = new ArrayList<HashMap<String,String>>();
			for( int i = 0 ; i < itemSapCodeArr.size() ; i++ ) {
				HashMap<String,String> matMap = new HashMap<String,String>();
				matMap.put("itemType", (String)itemTypeArr.get(i));
				matMap.put("matIdx", (String)itemMatIdxArr.get(i));
				matMap.put("sapCode", (String)itemSapCodeArr.get(i));
				matMap.put("name", (String)itemNameArr.get(i));
				try{
					matMap.put("matCode", (String)itemMatCodeArr.get(i));
				} catch(Exception e) {
					matMap.put("matCode", "");
				}
				try{
					matMap.put("standard", (String)itemStandardArr.get(i));
				} catch(Exception e) {
					matMap.put("standard", "");
				}
				try{
					matMap.put("keepExp", (String)itemKeepExpArr.get(i));
				} catch(Exception e) {
					matMap.put("keepExp", "");
				}
				try{
					matMap.put("unitPrice", (String)itemUnitPriceArr.get(i));
				} catch(Exception e) {
					matMap.put("unitPrice", "");
				}
				try{
					matMap.put("desc", (String)itemDescArr.get(i));
				} catch(Exception e) {
					matMap.put("desc", "");
				}
				matList.add(matMap);
			}
			if( matList != null && matList.size() > 0 ) {
				param.put("matList", matList);
				productDao.insertProductMaterial(param);
			}			
			
			if( docType != null ) {
				List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
				for( int i = 0 ; i < docType.size() ; i++ ) {
					HashMap<String, Object> paramMap = new HashMap<String, Object>();
					paramMap.put("docIdx", productIdx);
					paramMap.put("docType", "PROD");
					paramMap.put("fileType", docType.get(i));
					paramMap.put("fileTypeText", docTypeText.get(i));
					docTypeList.add(paramMap);
				}		
				commonDao.insertFileType(docTypeList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", productIdx);
			historyParam.put("docType", "PROD");
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
				String path = config.getProperty("upload.file.path.product");
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
							fileMap.put("docIdx", productIdx);
							fileMap.put("docType", "PROD");
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
		return productIdx;
	}	

	@Override
	@Transactional
	public int insertNewVersionProduct(Map<String, Object> param, HashMap<String, Object> listMap,
			MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int productIdx;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			ArrayList<String> usageArr = (ArrayList<String>)listMap.get("usageArr");
			String usageType = (String)listMap.get("usageType");
			ArrayList<String> productType = (ArrayList<String>)listMap.get("productType");
			ArrayList<String> fileType = (ArrayList<String>)listMap.get("fileType");
			ArrayList<String> fileTypeText = (ArrayList<String>)listMap.get("fileTypeText");
			ArrayList<String> docType = (ArrayList<String>)listMap.get("docType");
			ArrayList<String> docTypeText = (ArrayList<String>)listMap.get("docTypeText");
			
			JSONParser parser = new JSONParser();
			//JSONArray itemImproveArr = (JSONArray) parser.parse((String)param.get("itemImproveArr"));
			JSONArray itemImproveArr = (JSONArray) parser.parse((String)param.get("itemImproveArr"));
			JSONArray itemExistArr = (JSONArray) parser.parse((String)param.get("itemExistArr"));
			JSONArray itemNoteArr = (JSONArray) parser.parse((String)param.get("itemNoteArr"));
			JSONArray improveArr = (JSONArray) parser.parse((String)param.get("improveArr"));
			JSONArray newItemNameArr = (JSONArray) parser.parse((String)param.get("newItemNameArr"));
			JSONArray newItemStandardArr = (JSONArray) parser.parse((String)param.get("newItemStandardArr"));
			JSONArray newItemSupplierArr = (JSONArray) parser.parse((String)param.get("newItemSupplierArr"));
			JSONArray newItemKeepExpArr = (JSONArray) parser.parse((String)param.get("newItemKeepExpArr"));
			JSONArray newItemNoteArr = (JSONArray) parser.parse((String)param.get("newItemNoteArr"));
			
			JSONArray rowIdArr = (JSONArray) parser.parse((String)param.get("rowIdArr"));
			JSONArray itemTypeArr = (JSONArray) parser.parse((String)param.get("itemTypeArr"));
			JSONArray itemMatIdxArr = (JSONArray) parser.parse((String)param.get("itemMatIdxArr"));
			JSONArray itemMatCodeArr = (JSONArray) parser.parse((String)param.get("itemMatCodeArr"));
			JSONArray itemSapCodeArr = (JSONArray) parser.parse((String)param.get("itemSapCodeArr"));
			JSONArray itemNameArr = (JSONArray) parser.parse((String)param.get("itemNameArr"));
			JSONArray itemStandardArr = (JSONArray) parser.parse((String)param.get("itemStandardArr"));
			JSONArray itemKeepExpArr = (JSONArray) parser.parse((String)param.get("itemKeepExpArr"));
			JSONArray itemUnitPriceArr = (JSONArray) parser.parse((String)param.get("itemUnitPriceArr"));
			JSONArray itemDescArr = (JSONArray) parser.parse((String)param.get("itemDescArr"));
			
			int currentVersionNo = Integer.parseInt((String)param.get("currentVersionNo"));	//현재 문서 버젼
			int versionNo = Integer.parseInt((String)param.get("versionNo"));				//개정 문서 버젼
			
			//개정하는 문서 버젼이 현재 보다 높은 경우에 현재 버젼 문서 상태를 변경한다.
			if( versionNo > currentVersionNo ) {	
				productDao.updateProductIsLast(param);
				param.put("isLast", "Y");	//개정하는 문서 버젼이 현재보다 높은 경우에 문서상태를 최신 상태(Y)로 저장한다.
			} else {
				param.put("isLast", "N");	//개정하는 문서 버젼이 현재보다 낮은 경우에 문서상태를 이전 상태(N)로 저장한다.
			}
			
			productIdx = productDao.selectProductSeq(); 	//key value 조회
			param.put("idx", productIdx);
			//param.put("status", "REG");
			
			if( productType != null && productType.size() > 0 ) {
				for( int i = 0 ; i < productType.size() ; i++ ) {
					param.put("productType"+(i+1), productType.get(i));
				}
			}
			System.err.println(param);
			productDao.insertNewVersionProduct(param);
			
			//개선목적
			ArrayList<HashMap<String,Object>> imporvePurList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < itemImproveArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", productIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("improve", itemImproveArr.get(i));
				} catch(Exception e) {
					newMap.put("improve", "");
				}
				
				try{
					newMap.put("exist", itemExistArr.get(i));
				} catch(Exception e) {
					newMap.put("exist", "");
				}
				
				try{
					newMap.put("note", itemNoteArr.get(i));
				} catch(Exception e) {
					newMap.put("note", "");
				}
				imporvePurList.add(newMap);
			}
			
			if( imporvePurList != null && imporvePurList.size() > 0 ) {
				productDao.insertProductImporvePurpose(imporvePurList);
			}
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( improveArr.size() > 0 ) {
				for( int i = 0 ; i < improveArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", productIdx);
					purposeData.put("infoType", "IMP");
					purposeData.put("infoText", improveArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( usageArr.size() > 0 ) {
				for( int i = 0 ; i < usageArr.size() ; i++ ) {
					HashMap<String,Object> usageData = new HashMap<String,Object>();
					usageData.put("idx", productIdx);
					usageData.put("infoType", "BRAND".equals(usageType) ? "USB" : "USC");
					usageData.put("infoText", usageArr.get(i));
					addInfoList.add(usageData);
				}
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				productDao.insertAddInfo(addInfoList);
			}
			
			//신규도입품/제품규격 등록
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < newItemNameArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", productIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("productName", newItemNameArr.get(i));
				} catch(Exception e) {
					newMap.put("productName", "");
				}
				
				try{
					newMap.put("packageStandard", newItemStandardArr.get(i));
				} catch(Exception e) {
					newMap.put("packageStandard", "");
				}
				
				try{
					newMap.put("supplier", newItemSupplierArr.get(i));
				} catch(Exception e) {
					newMap.put("supplier", "");
				}
				
				try{
					newMap.put("keepExp", newItemKeepExpArr.get(i));
				} catch(Exception e) {
					newMap.put("keepExp", "");
				}
				
				try{
					newMap.put("note", newItemNoteArr.get(i));
				} catch(Exception e) {
					newMap.put("note", "");
				}
				
				newList.add(newMap);
			}
			
			if( newList != null && newList.size() > 0 ) {
				productDao.insertProductNew(newList);
			}
			
			//원료 리스트 등록
			ArrayList<HashMap<String,String>> matList = new ArrayList<HashMap<String,String>>();
			for( int i = 0 ; i < itemSapCodeArr.size() ; i++ ) {
				HashMap<String,String> matMap = new HashMap<String,String>();
				matMap.put("itemType", (String)itemTypeArr.get(i));
				matMap.put("matIdx", (String)itemMatIdxArr.get(i));
				matMap.put("sapCode", (String)itemSapCodeArr.get(i));
				matMap.put("name", (String)itemNameArr.get(i));
				try{
					matMap.put("matCode", (String)itemMatCodeArr.get(i));
				} catch(Exception e) {
					matMap.put("matCode", "");
				}
				try{
					matMap.put("standard", (String)itemStandardArr.get(i));
				} catch(Exception e) {
					matMap.put("standard", "");
				}
				try{
					matMap.put("keepExp", (String)itemKeepExpArr.get(i));
				} catch(Exception e) {
					matMap.put("keepExp", "");
				}
				try{
					matMap.put("unitPrice", (String)itemUnitPriceArr.get(i));
				} catch(Exception e) {
					matMap.put("unitPrice", "");
				}
				try{
					matMap.put("desc", (String)itemDescArr.get(i));
				} catch(Exception e) {
					matMap.put("desc", "");
				}
				matList.add(matMap);
			}
			
			if( matList != null && matList.size() > 0 ) {
				param.put("matList", matList);
				productDao.insertProductMaterial(param);
			}
			
			if( docType != null ) {
				List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
				for( int i = 0 ; i < docType.size() ; i++ ) {
					HashMap<String, Object> paramMap = new HashMap<String, Object>();
					paramMap.put("docIdx", productIdx);
					paramMap.put("docType", "PROD");
					paramMap.put("fileType", docType.get(i));
					paramMap.put("fileTypeText", docTypeText.get(i));
					docTypeList.add(paramMap);
				}		
				commonDao.insertFileType(docTypeList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", productIdx);
			historyParam.put("docType", "PROD");
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
				String path = config.getProperty("upload.file.path.product");
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
							fileMap.put("docIdx", productIdx);
							fileMap.put("docType", "PROD");
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
		return productIdx;
	}

	@Override
	public List<Map<String, Object>> checkErpMaterial(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return productDao.checkErpMaterial(param);
	}

	@Override
	public Map<String, Object> selectErpMaterialData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return productDao.selectErpMaterialData(param);
	}

	@Override
	public int insertNewVersionCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return productDao.insertNewVersionCheck(param);
	}

	@Override
	public Map<String, Object> selectSearchProduct(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		List<Map<String, Object>> list = productDao.selectSearchProduct(param);
		map.put("list", list);
		return map;
	}

	@Override
	public Map<String, Object> selectFileData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return productDao.selectFileData(param);
	}

	@Override
	public void deleteFileData(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		productDao.deleteFileData(param);
	}

	@Override
	public void updateProduct(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try{
			ArrayList<String> usageArr = (ArrayList<String>)listMap.get("usageArr");
			String usageType = (String)listMap.get("usageType");
			ArrayList<String> productType = (ArrayList<String>)listMap.get("productType");
			ArrayList<String> fileType = (ArrayList<String>)listMap.get("fileType");
			ArrayList<String> fileTypeText = (ArrayList<String>)listMap.get("fileTypeText");
			ArrayList<String> docType = (ArrayList<String>)listMap.get("docType");
			ArrayList<String> docTypeText = (ArrayList<String>)listMap.get("docTypeText");
			
			JSONParser parser = new JSONParser();
			//JSONArray itemImproveArr = (JSONArray) parser.parse((String)param.get("itemImproveArr"));
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray featureArr = (JSONArray) parser.parse((String)param.get("featureArr"));
			
			JSONArray itemImproveArr = (JSONArray) parser.parse((String)param.get("itemImproveArr"));
			JSONArray itemExistArr = (JSONArray) parser.parse((String)param.get("itemExistArr"));
			JSONArray itemNoteArr = (JSONArray) parser.parse((String)param.get("itemNoteArr"));
			JSONArray improveArr = (JSONArray) parser.parse((String)param.get("improveArr"));
			
			JSONArray newItemNameArr = (JSONArray) parser.parse((String)param.get("newItemNameArr"));
			JSONArray newItemStandardArr = (JSONArray) parser.parse((String)param.get("newItemStandardArr"));
			JSONArray newItemSupplierArr = (JSONArray) parser.parse((String)param.get("newItemSupplierArr"));
			JSONArray newItemKeepExpArr = (JSONArray) parser.parse((String)param.get("newItemKeepExpArr"));
			JSONArray newItemNoteArr = (JSONArray) parser.parse((String)param.get("newItemNoteArr"));
			
			JSONArray rowIdArr = (JSONArray) parser.parse((String)param.get("rowIdArr"));
			JSONArray itemTypeArr = (JSONArray) parser.parse((String)param.get("itemTypeArr"));
			JSONArray itemMatIdxArr = (JSONArray) parser.parse((String)param.get("itemMatIdxArr"));
			JSONArray itemMatCodeArr = (JSONArray) parser.parse((String)param.get("itemMatCodeArr"));
			JSONArray itemSapCodeArr = (JSONArray) parser.parse((String)param.get("itemSapCodeArr"));
			JSONArray itemNameArr = (JSONArray) parser.parse((String)param.get("itemNameArr"));
			JSONArray itemStandardArr = (JSONArray) parser.parse((String)param.get("itemStandardArr"));
			JSONArray itemKeepExpArr = (JSONArray) parser.parse((String)param.get("itemKeepExpArr"));
			JSONArray itemUnitPriceArr = (JSONArray) parser.parse((String)param.get("itemUnitPriceArr"));
			JSONArray itemDescArr = (JSONArray) parser.parse((String)param.get("itemDescArr"));
			
			int productIdx = Integer.parseInt((String)param.get("idx")); 	//key value 조회
			param.put("productIdx", productIdx);
			if( param.get("currentStatus") != null && "COND_APPR".equals(param.get("currentStatus")) ) {
				param.put("status", "APPR");
			} else if( param.get("currentStatus") != null && "TMP".equals(param.get("currentStatus")) ) {
				param.put("status", "REG");
			}
			
			
			if( productType != null && productType.size() > 0 ) {
				for( int i = 0 ; i < productType.size() ; i++ ) {
					param.put("productType"+(i+1), productType.get(i));
				}
			}
			
			//제품 수정
			productDao.updateProductData(param);
			
			HashMap<String,Object> map = new HashMap<String,Object>(); 
			map.put("productIdx", productIdx);
			//개선목적 삭제
			productDao.deleteProductImporvePurpose(map);
			
			//개선목적
			ArrayList<HashMap<String,Object>> imporvePurList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < itemImproveArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", productIdx);
				try{
					newMap.put("improve", itemImproveArr.get(i));
				} catch(Exception e) {
					newMap.put("improve", "");
				}
				
				try{
					newMap.put("exist", itemExistArr.get(i));
				} catch(Exception e) {
					newMap.put("exist", "");
				}
				
				try{
					newMap.put("note", itemNoteArr.get(i));
				} catch(Exception e) {
					newMap.put("note", "");
				}
				if( (newMap.get("improve") != null && !"".equals(newMap.get("improve"))) 
						&& (newMap.get("exist") != null && !"".equals(newMap.get("exist"))) 
						&& (newMap.get("note") != null && !"".equals(newMap.get("note")))  ) {
					newMap.put("displayOrder", i+1);
					imporvePurList.add(newMap);
					
				}
				
			}
			
			if( imporvePurList != null && imporvePurList.size() > 0 ) {
				productDao.insertProductImporvePurpose(imporvePurList);
			}
			
			//추가 정보를 삭제한다.			
			productDao.deleteAddInfo(map);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", productIdx);
					purposeData.put("infoType", "PUR");
					purposeData.put("infoText", purposeArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( featureArr.size() > 0 ) {
				for( int i = 0 ; i < featureArr.size() ; i++ ) {
					HashMap<String,Object> featureData = new HashMap<String,Object>();
					featureData.put("idx", productIdx);
					featureData.put("infoType", "FEA");
					featureData.put("infoText", featureArr.get(i));
					addInfoList.add(featureData);
				}
			}
			
			if( improveArr.size() > 0 ) {
				for( int i = 0 ; i < improveArr.size() ; i++ ) {
					if( improveArr.get(i) != null && !"".equals(improveArr.get(i))) {
						HashMap<String,Object> purposeData = new HashMap<String,Object>();
						purposeData.put("idx", productIdx);
						purposeData.put("infoType", "IMP");
						purposeData.put("infoText", improveArr.get(i));
						addInfoList.add(purposeData);
					}
				}				
			}
			
			if( usageArr.size() > 0 ) {
				for( int i = 0 ; i < usageArr.size() ; i++ ) {
					HashMap<String,Object> usageData = new HashMap<String,Object>();
					usageData.put("idx", productIdx);
					usageData.put("infoType", "BRAND".equals(usageType) ? "USB" : "USC");
					usageData.put("infoText", usageArr.get(i));
					addInfoList.add(usageData);
				}
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//추가 정보를 등록한다.
				productDao.insertAddInfo(addInfoList);
			}
			
			//신규도입품/제품규격 삭제
			productDao.deleteProductNew(map);
			//신규도입품/제품규격 등록
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < newItemNameArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", productIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("productName", newItemNameArr.get(i));
				} catch(Exception e) {
					newMap.put("productName", "");
				}
				
				try{
					newMap.put("packageStandard", newItemStandardArr.get(i));
				} catch(Exception e) {
					newMap.put("packageStandard", "");
				}
				
				try{
					newMap.put("supplier", newItemSupplierArr.get(i));
				} catch(Exception e) {
					newMap.put("supplier", "");
				}
				
				try{
					newMap.put("keepExp", newItemKeepExpArr.get(i));
				} catch(Exception e) {
					newMap.put("keepExp", "");
				}
				
				try{
					newMap.put("note", newItemNoteArr.get(i));
				} catch(Exception e) {
					newMap.put("note", "");
				}
				
				newList.add(newMap);
			}
			
			if( newList != null && newList.size() > 0 ) {
				productDao.insertProductNew(newList);
			}
			
			//원료 리스트 삭제
			productDao.deleteProductMaterial(map);
			
			//원료 리스트 등록
			ArrayList<HashMap<String,String>> matList = new ArrayList<HashMap<String,String>>();
			for( int i = 0 ; i < itemSapCodeArr.size() ; i++ ) {
				HashMap<String,String> matMap = new HashMap<String,String>();
				matMap.put("itemType", (String)itemTypeArr.get(i));
				matMap.put("matIdx", (String)itemMatIdxArr.get(i));
				matMap.put("sapCode", (String)itemSapCodeArr.get(i));
				matMap.put("name", (String)itemNameArr.get(i));
				try{
					matMap.put("matCode", (String)itemMatCodeArr.get(i));
				} catch(Exception e) {
					matMap.put("matCode", "");
				}
				try{
					matMap.put("standard", (String)itemStandardArr.get(i));
				} catch(Exception e) {
					matMap.put("standard", "");
				}
				try{
					matMap.put("keepExp", (String)itemKeepExpArr.get(i));
				} catch(Exception e) {
					matMap.put("keepExp", "");
				}
				try{
					matMap.put("unitPrice", (String)itemUnitPriceArr.get(i));
				} catch(Exception e) {
					matMap.put("unitPrice", "");
				}
				try{
					matMap.put("desc", (String)itemDescArr.get(i));
				} catch(Exception e) {
					matMap.put("desc", "");
				}
				matList.add(matMap);
			}
			param.put("matList", matList);
			productDao.insertProductMaterial(param);
			
			//첨부파일 유형 삭제
			map = new HashMap<String,Object>(); 
			map.put("productIdx", productIdx);
			map.put("docType", "PROD");
			productDao.deleteFileType(map);
			
			//첨부파일 유형 저장
			if( docType != null ) {
				List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
				for( int i = 0 ; i < docType.size() ; i++ ) {
					HashMap<String, Object> paramMap = new HashMap<String, Object>();
					paramMap.put("docIdx", productIdx);
					paramMap.put("docType", "PROD");
					paramMap.put("fileType", docType.get(i));
					paramMap.put("fileTypeText", docTypeText.get(i));
					docTypeList.add(paramMap);
				}		
				commonDao.insertFileType(docTypeList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", productIdx);
			historyParam.put("docType", "PROD");
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
				String path = config.getProperty("upload.file.path.product");
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
							fileMap.put("docIdx", productIdx);
							fileMap.put("docType", "PROD");
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
			
			if( param.get("currentStatus") != null && "COND_APPR".equals(param.get("currentStatus")) ) {
				//다음 결재자에게 메일을 보낸다.
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
	public void updateProductTmp(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try{
			ArrayList<String> usageArr = (ArrayList<String>)listMap.get("usageArr");
			String usageType = (String)listMap.get("usageType");
			ArrayList<String> productType = (ArrayList<String>)listMap.get("productType");
			ArrayList<String> fileType = (ArrayList<String>)listMap.get("fileType");
			ArrayList<String> fileTypeText = (ArrayList<String>)listMap.get("fileTypeText");
			ArrayList<String> docType = (ArrayList<String>)listMap.get("docType");
			ArrayList<String> docTypeText = (ArrayList<String>)listMap.get("docTypeText");
			
			JSONParser parser = new JSONParser();
			//JSONArray itemImproveArr = (JSONArray) parser.parse((String)param.get("itemImproveArr"));
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray featureArr = (JSONArray) parser.parse((String)param.get("featureArr"));
			
			JSONArray itemImproveArr = (JSONArray) parser.parse((String)param.get("itemImproveArr"));
			JSONArray itemExistArr = (JSONArray) parser.parse((String)param.get("itemExistArr"));
			JSONArray itemNoteArr = (JSONArray) parser.parse((String)param.get("itemNoteArr"));
			JSONArray improveArr = (JSONArray) parser.parse((String)param.get("improveArr"));
			
			JSONArray newItemNameArr = (JSONArray) parser.parse((String)param.get("newItemNameArr"));
			JSONArray newItemStandardArr = (JSONArray) parser.parse((String)param.get("newItemStandardArr"));
			JSONArray newItemSupplierArr = (JSONArray) parser.parse((String)param.get("newItemSupplierArr"));
			JSONArray newItemKeepExpArr = (JSONArray) parser.parse((String)param.get("newItemKeepExpArr"));
			JSONArray newItemNoteArr = (JSONArray) parser.parse((String)param.get("newItemNoteArr"));
			JSONArray rowIdArr = (JSONArray) parser.parse((String)param.get("rowIdArr"));
			JSONArray itemTypeArr = (JSONArray) parser.parse((String)param.get("itemTypeArr"));
			JSONArray itemMatIdxArr = (JSONArray) parser.parse((String)param.get("itemMatIdxArr"));
			JSONArray itemMatCodeArr = (JSONArray) parser.parse((String)param.get("itemMatCodeArr"));
			JSONArray itemSapCodeArr = (JSONArray) parser.parse((String)param.get("itemSapCodeArr"));
			JSONArray itemNameArr = (JSONArray) parser.parse((String)param.get("itemNameArr"));
			JSONArray itemStandardArr = (JSONArray) parser.parse((String)param.get("itemStandardArr"));
			JSONArray itemKeepExpArr = (JSONArray) parser.parse((String)param.get("itemKeepExpArr"));
			JSONArray itemUnitPriceArr = (JSONArray) parser.parse((String)param.get("itemUnitPriceArr"));
			JSONArray itemDescArr = (JSONArray) parser.parse((String)param.get("itemDescArr"));
			
			int productIdx = Integer.parseInt((String)param.get("idx")); 	//key value 조회
			param.put("productIdx", productIdx);
			
			if( productType != null && productType.size() > 0 ) {
				for( int i = 0 ; i < productType.size() ; i++ ) {
					param.put("productType"+(i+1), productType.get(i));
				}
			}
			
			//제품 수정
			productDao.updateProductData(param);
			
			
			HashMap<String,Object> map = new HashMap<String,Object>(); 
			map.put("productIdx", productIdx);
			//개선목적 삭제
			productDao.deleteProductImporvePurpose(map);
			
			//개선목적 등록
			ArrayList<HashMap<String,Object>> imporvePurList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < itemImproveArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", productIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("improve", itemImproveArr.get(i));
				} catch(Exception e) {
					newMap.put("improve", "");
				}
				
				try{
					newMap.put("exist", itemExistArr.get(i));
				} catch(Exception e) {
					newMap.put("exist", "");
				}
				
				try{
					newMap.put("note", itemNoteArr.get(i));
				} catch(Exception e) {
					newMap.put("note", "");
				}
				if( (newMap.get("improve") != null && !"".equals(newMap.get("improve"))) 
						&& (newMap.get("exist") != null && !"".equals(newMap.get("exist"))) 
						&& (newMap.get("note") != null && !"".equals(newMap.get("note")))  ) {
					newMap.put("displayOrder", i+1);
					imporvePurList.add(newMap);					
				}
			}
			
			if( imporvePurList != null && imporvePurList.size() > 0 ) {
				productDao.insertProductImporvePurpose(imporvePurList);
			}
			
			//추가 정보를 삭제한다.			
			productDao.deleteAddInfo(map);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", productIdx);
					purposeData.put("infoType", "PUR");
					purposeData.put("infoText", purposeArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( featureArr.size() > 0 ) {
				for( int i = 0 ; i < featureArr.size() ; i++ ) {
					HashMap<String,Object> featureData = new HashMap<String,Object>();
					featureData.put("idx", productIdx);
					featureData.put("infoType", "FEA");
					featureData.put("infoText", featureArr.get(i));
					addInfoList.add(featureData);
				}
			}
			
			if( improveArr.size() > 0 ) {
				for( int i = 0 ; i < improveArr.size() ; i++ ) {
					if( improveArr.get(i) != null && !"".equals(improveArr.get(i))) {
						HashMap<String,Object> purposeData = new HashMap<String,Object>();
						purposeData.put("idx", productIdx);
						purposeData.put("infoType", "IMP");
						purposeData.put("infoText", improveArr.get(i));
						addInfoList.add(purposeData);
					}
				}				
			}
			
			if( usageArr.size() > 0 ) {
				for( int i = 0 ; i < usageArr.size() ; i++ ) {
					HashMap<String,Object> usageData = new HashMap<String,Object>();
					usageData.put("idx", productIdx);
					usageData.put("infoType", "BRAND".equals(usageType) ? "USB" : "USC");
					usageData.put("infoText", usageArr.get(i));
					addInfoList.add(usageData);
				}
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//추가 정보를 등록한다.
				productDao.insertAddInfo(addInfoList);
			}
			
			//신규도입품/제품규격 삭제
			productDao.deleteProductNew(map);
			//신규도입품/제품규격 등록
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < newItemNameArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", productIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("productName", newItemNameArr.get(i));
				} catch(Exception e) {
					newMap.put("productName", "");
				}
				
				try{
					newMap.put("packageStandard", newItemStandardArr.get(i));
				} catch(Exception e) {
					newMap.put("packageStandard", "");
				}
				
				try{
					newMap.put("supplier", newItemSupplierArr.get(i));
				} catch(Exception e) {
					newMap.put("supplier", "");
				}
				
				try{
					newMap.put("keepExp", newItemKeepExpArr.get(i));
				} catch(Exception e) {
					newMap.put("keepExp", "");
				}
				
				try{
					newMap.put("note", newItemNoteArr.get(i));
				} catch(Exception e) {
					newMap.put("note", "");
				}
				
				newList.add(newMap);
			}
			
			if( newList != null && newList.size() > 0 ) {
				productDao.insertProductNew(newList);
			}
			
			//원료 리스트 삭제
			productDao.deleteProductMaterial(map);
			
			//원료 리스트 등록
			ArrayList<HashMap<String,String>> matList = new ArrayList<HashMap<String,String>>();
			for( int i = 0 ; i < itemSapCodeArr.size() ; i++ ) {
				HashMap<String,String> matMap = new HashMap<String,String>();
				matMap.put("itemType", (String)itemTypeArr.get(i));
				matMap.put("matIdx", (String)itemMatIdxArr.get(i));
				matMap.put("sapCode", (String)itemSapCodeArr.get(i));
				matMap.put("name", (String)itemNameArr.get(i));
				try{
					matMap.put("matCode", (String)itemMatCodeArr.get(i));
				} catch(Exception e) {
					matMap.put("matCode", "");
				}
				try{
					matMap.put("standard", (String)itemStandardArr.get(i));
				} catch(Exception e) {
					matMap.put("standard", "");
				}
				try{
					matMap.put("keepExp", (String)itemKeepExpArr.get(i));
				} catch(Exception e) {
					matMap.put("keepExp", "");
				}
				try{
					matMap.put("unitPrice", (String)itemUnitPriceArr.get(i));
				} catch(Exception e) {
					matMap.put("unitPrice", "");
				}
				try{
					matMap.put("desc", (String)itemDescArr.get(i));
				} catch(Exception e) {
					matMap.put("desc", "");
				}
				matList.add(matMap);
			}
			param.put("matList", matList);
			productDao.insertProductMaterial(param);
			
			//첨부파일 유형 삭제
			map = new HashMap<String,Object>(); 
			map.put("productIdx", productIdx);
			map.put("docType", "PROD");
			productDao.deleteFileType(map);
			
			//첨부파일 유형 저장
			if( docType != null ) {
				List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
				for( int i = 0 ; i < docType.size() ; i++ ) {
					HashMap<String, Object> paramMap = new HashMap<String, Object>();
					paramMap.put("docIdx", productIdx);
					paramMap.put("docType", "PROD");
					paramMap.put("fileType", docType.get(i));
					paramMap.put("fileTypeText", docTypeText.get(i));
					docTypeList.add(paramMap);
				}		
				commonDao.insertFileType(docTypeList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", productIdx);
			historyParam.put("docType", "PROD");
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
				String path = config.getProperty("upload.file.path.product");
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
							fileMap.put("docIdx", productIdx);
							fileMap.put("docType", "PROD");
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
	public List<Map<String, Object>> selectImporvePurposeList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return productDao.selectImporvePurposeList(param);
	}

	@Override
	public Map<String, Object> selectAddInfoCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return productDao.selectAddInfoCount(param);
	}	
}
