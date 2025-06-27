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
import kr.co.genesiskorea.dao.MenuDao;
import kr.co.genesiskorea.service.MenuService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class MenuServiceImpl implements MenuService {
	private Logger logger = LogManager.getLogger(MenuServiceImpl.class);
	
	@Autowired
	MenuDao menuDao;
	
	@Autowired
	CommonDao commonDao;
	
	@Autowired
	private Properties config;
	
	@Resource
	DataSourceTransactionManager txManager;

	@Override
	public Map<String, Object> selectMenuList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = menuDao.selectMenuCount(param);
		
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
		
		List<Map<String, Object>> menuList = menuDao.selectMenuList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", menuList);	
		map.put("navi", navi);
		return map;
	}


	@Override
	public Map<String, Object> selectMenuData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		Map<String, Object> data = menuDao.selectMenuData(param);
		param.put("docType", "MENU");
		List<Map<String, String>> fileList = commonDao.selectFileList(param);
		List<Map<String, String>> fileType = commonDao.selectFileType(param);
		map.put("data", data);
		map.put("fileList", fileList);
		map.put("fileType", fileType);
		return map;
	}

	@Override
	public Map<String, Object> selectAddInfoCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectAddInfoCount(param);
	}

	@Override
	public List<Map<String, String>> selectAddInfo(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectAddInfo(param);
	}

	@Override
	public List<Map<String, String>> selectImporvePurposeList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectImporvePurposeList(param);
	}

	@Override
	public List<Map<String, String>> selectNewDataList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectNewDataList(param);
	}

	@Override
	public Object selectMenuMaterial(Map<String, Object> param) {
		// TODO Auto-generated method stub
		List<Map<String, String>> materialList = menuDao.selectMenuMaterial(param);
		return materialList;
	}


	@Override
	public String selectMenuCode() {
		// TODO Auto-generated method stub
		return menuDao.selectMenuCode();
	}


	@Override
	public List<Map<String, String>> checkMaterial(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.checkMaterial(param);
	}


	@Override
	public List<Map<String, String>> checkErpMaterial(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.checkErpMaterial(param);
	}


	@Override
	public Map<String, Object> selectMaterialList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		int totalCount = menuDao.selectMaterialCount(param);
		
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
		
		List<Map<String, String>> materialList = menuDao.selectMaterialList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", materialList);		
		
		return map;
	}


	@Override
	public Map<String, Object> selectMenuDataCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		int count = menuDao.selectMenuDataCount(param);
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("COUNT", count);		
		return map;
	}


	@Override
	@Transactional
	public int insertTmpMenu(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		int menuIdx;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			
			ArrayList<String> usageArr = (ArrayList<String>)listMap.get("usageArr");
			String customUsage = (String)listMap.get("customUsage");			
			
			ArrayList<String> menuType = (ArrayList<String>)listMap.get("menuType");
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
			JSONArray newItemTypeCodeArr = (JSONArray) parser.parse((String)param.get("newItemTypeCodeArr"));
			
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
			
			menuIdx = 0;
			menuIdx = menuDao.selectMenuSeq(); 	//key value 조회
			param.put("idx", menuIdx);
			
			if( menuType != null && menuType.size() > 0 ) {
				for( int i = 0 ; i < menuType.size() ; i++ ) {
					param.put("menuType"+(i+1), menuType.get(i));
				}
			}

			//제품 등록
			menuDao.insertMenu(param);
			
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", menuIdx);
					purposeData.put("infoType", "PUR");
					purposeData.put("infoText", purposeArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( featureArr.size() > 0 ) {
				for( int i = 0 ; i < featureArr.size() ; i++ ) {
					HashMap<String,Object> featureData = new HashMap<String,Object>();
					featureData.put("idx", menuIdx);
					featureData.put("infoType", "FEA");
					featureData.put("infoText", featureArr.get(i));
					addInfoList.add(featureData);
				}
			}
			
			if( usageArr != null && usageArr.size() > 0 ) {
				for( int i = 0 ; i < usageArr.size() ; i++ ) {
					HashMap<String,Object> usageData = new HashMap<String,Object>();
					usageData.put("idx", menuIdx);
					usageData.put("infoType", "USB");
					usageData.put("infoText", usageArr.get(i));
					addInfoList.add(usageData);
				}
			}
			
			if( customUsage != null && customUsage.length() > 0 ) {
				HashMap<String,Object> usageData = new HashMap<String,Object>();
				usageData.put("idx", menuIdx);
				usageData.put("infoType", "USC");
				usageData.put("infoText", customUsage);
				addInfoList.add(usageData);
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				menuDao.insertAddInfo(addInfoList);
			}
			
			//신규도입품/제품규격 등록
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < newItemNameArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", menuIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("menuName", newItemNameArr.get(i));
				} catch(Exception e) {
					newMap.put("menuName", "");
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
				
				try{
					newMap.put("typeCode", newItemTypeCodeArr.get(i));
				} catch(Exception e) {
					newMap.put("typeCode", "");
				}
				
				newList.add(newMap);
			}
			
			if( newList != null && newList.size() > 0 ) {
				menuDao.insertMenuNew(newList);
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
				menuDao.insertMenuMaterial(param);
			}
			
			//첨부파일 유형 저장
			List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
			if( docType != null ) {
				for( int i = 0 ; i < docType.size() ; i++ ) {
					HashMap<String, Object> paramMap = new HashMap<String, Object>();
					paramMap.put("docIdx", menuIdx);
					paramMap.put("docType", "MENU");
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
			historyParam.put("docIdx", menuIdx);
			historyParam.put("docType", "MENU");
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
				String path = config.getProperty("upload.file.path.menu");
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
							fileMap.put("docIdx", menuIdx);
							fileMap.put("docType", "MENU");
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
			return menuIdx;
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}


	@Override
	@Transactional
	public int insertMenu(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		int menuIdx;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try{
			ArrayList<String> usageArr = (ArrayList<String>)listMap.get("usageArr");
			String customUsage = (String)listMap.get("customUsage");			
			
			ArrayList<String> menuType = (ArrayList<String>)listMap.get("menuType");
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
			JSONArray newItemTypeCodeArr = (JSONArray) parser.parse((String)param.get("newItemTypeCodeArr"));
			
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

			menuIdx = menuDao.selectMenuSeq(); 	//key value 조회
			param.put("idx", menuIdx);
			//param.put("status", "REG");
			
			if( menuType != null && menuType.size() > 0 ) {
				for( int i = 0 ; i < menuType.size() ; i++ ) {
					param.put("menuType"+(i+1), menuType.get(i));
				}
			}
			
			//제품 등록
			menuDao.insertMenu(param);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", menuIdx);
					purposeData.put("infoType", "PUR");
					purposeData.put("infoText", purposeArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( featureArr.size() > 0 ) {
				for( int i = 0 ; i < featureArr.size() ; i++ ) {
					HashMap<String,Object> featureData = new HashMap<String,Object>();
					featureData.put("idx", menuIdx);
					featureData.put("infoType", "FEA");
					featureData.put("infoText", featureArr.get(i));
					addInfoList.add(featureData);
				}
			}
			
			if( usageArr != null && usageArr.size() > 0 ) {
				for( int i = 0 ; i < usageArr.size() ; i++ ) {
					HashMap<String,Object> usageData = new HashMap<String,Object>();
					usageData.put("idx", menuIdx);
					usageData.put("infoType", "USB");
					usageData.put("infoText", usageArr.get(i));
					addInfoList.add(usageData);
				}
			}
			
			if( customUsage != null && customUsage.length() > 0 ) {
				HashMap<String,Object> usageData = new HashMap<String,Object>();
				usageData.put("idx", menuIdx);
				usageData.put("infoType", "USC");
				usageData.put("infoText", customUsage);
				addInfoList.add(usageData);
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				menuDao.insertAddInfo(addInfoList);
			}
			
			//신규도입품/제품규격 등록
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < newItemNameArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", menuIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("menuName", newItemNameArr.get(i));
				} catch(Exception e) {
					newMap.put("menuName", "");
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
				
				try{
					newMap.put("typeCode", newItemTypeCodeArr.get(i));
				} catch(Exception e) {
					newMap.put("typeCode", "");
				}
				
				newList.add(newMap);
			}
			
			if( newList != null && newList.size() > 0 ) {
				menuDao.insertMenuNew(newList);
			}
			
			//원료 리스트 등록
			ArrayList<HashMap<String,String>> matList = new ArrayList<HashMap<String,String>>();
			for( int i = 0 ; i < itemMatIdxArr.size() ; i++ ) {
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
				menuDao.insertMenuMaterial(param);				
			}
			
			//첨부파일 유형 저장
			List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
			for( int i = 0 ; i < docType.size() ; i++ ) {
				HashMap<String, Object> paramMap = new HashMap<String, Object>();
				paramMap.put("docIdx", menuIdx);
				paramMap.put("docType", "MENU");
				paramMap.put("fileType", docType.get(i));
				paramMap.put("fileTypeText", docTypeText.get(i));
				docTypeList.add(paramMap);
			}		
			commonDao.insertFileType(docTypeList);
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", menuIdx);
			historyParam.put("docType", "MENU");
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
						paramMap.put("docIdx", menuIdx);
						paramMap.put("docType", "MENU");
						menuDao.insertFileCopy(paramMap);
					}
				}
			}
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				Calendar cal = Calendar.getInstance();
		        Date day = cal.getTime();    //시간을 꺼낸다.
		        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
		        String toDay = sdf.format(day);
				String path = config.getProperty("upload.file.path.menu");
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
							fileMap.put("docIdx", menuIdx);
							fileMap.put("docType", "MENU");
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
			 return menuIdx;
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}


	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectHistory(param);
	}


	@Override
	public int insertNewVersionCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.insertNewVersionCheck(param);
	}


	@Override
	@Transactional
	public int insertNewVersionMenuTmp(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		int menuIdx;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			ArrayList<String> usageArr = (ArrayList<String>)listMap.get("usageArr");
			String customUsage = (String)listMap.get("customUsage");
			
			ArrayList<String> menuType = (ArrayList<String>)listMap.get("menuType");
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
			JSONArray newItemTypeCodeArr = (JSONArray) parser.parse((String)param.get("newItemTypeCodeArr"));
			
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
				menuDao.updateMenuIsLast(param);
				param.put("isLast", "Y");	//개정하는 문서 버젼이 현재보다 높은 경우에 문서상태를 최신 상태(Y)로 저장한다.
			} else {
				param.put("isLast", "N");	//개정하는 문서 버젼이 현재보다 낮은 경우에 문서상태를 이전 상태(N)로 저장한다.
			}
			
			menuIdx = menuDao.selectMenuSeq(); 	//key value 조회
			param.put("idx", menuIdx);
			
			if( menuType != null && menuType.size() > 0 ) {
				for( int i = 0 ; i < menuType.size() ; i++ ) {
					param.put("menuType"+(i+1), menuType.get(i));
				}
			}

			menuDao.insertNewVersionMenu(param);
			
			//개선목적
			ArrayList<HashMap<String,Object>> imporvePurList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < itemImproveArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", menuIdx);
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
				menuDao.insertMenuImporvePurpose(imporvePurList);
			}
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( improveArr.size() > 0 ) {
				for( int i = 0 ; i < improveArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", menuIdx);
					purposeData.put("infoType", "IMP");
					purposeData.put("infoText", improveArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( usageArr != null && usageArr.size() > 0 ) {
				for( int i = 0 ; i < usageArr.size() ; i++ ) {
					HashMap<String,Object> usageData = new HashMap<String,Object>();
					usageData.put("idx", menuIdx);
					usageData.put("infoType", "USB");
					usageData.put("infoText", usageArr.get(i));
					addInfoList.add(usageData);
				}
			}
			
			if( customUsage != null && customUsage.length() > 0 ) {
				HashMap<String,Object> usageData = new HashMap<String,Object>();
				usageData.put("idx", menuIdx);
				usageData.put("infoType", "USC");
				usageData.put("infoText", customUsage);
				addInfoList.add(usageData);
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				menuDao.insertAddInfo(addInfoList);
			}
			
			//신규도입품/제품규격 등록
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < newItemNameArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", menuIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("menuName", newItemNameArr.get(i));
				} catch(Exception e) {
					newMap.put("menuName", "");
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
				
				try{
					newMap.put("typeCode", newItemTypeCodeArr.get(i));
				} catch(Exception e) {
					newMap.put("typeCode", "");
				}
				
				newList.add(newMap);
			}
			
			if( newList != null && newList.size() > 0 ) {
				menuDao.insertMenuNew(newList);
			}
			
			//원료 리스트 등록
			ArrayList<HashMap<String,String>> matList = new ArrayList<HashMap<String,String>>();
			for( int i = 0 ; i < itemMatIdxArr.size() ; i++ ) {
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
				menuDao.insertMenuMaterial(param);
			}			
			
			if( docType != null ) {
				List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
				for( int i = 0 ; i < docType.size() ; i++ ) {
					HashMap<String, Object> paramMap = new HashMap<String, Object>();
					paramMap.put("docIdx", menuIdx);
					paramMap.put("docType", "MENU");
					paramMap.put("fileType", docType.get(i));
					paramMap.put("fileTypeText", docTypeText.get(i));
					docTypeList.add(paramMap);
				}		
				commonDao.insertFileType(docTypeList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", menuIdx);
			historyParam.put("docType", "MENU");
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
				String path = config.getProperty("upload.file.path.menu");
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
							fileMap.put("docIdx", menuIdx);
							fileMap.put("docType", "MENU");
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
		return menuIdx;
	}


	@Override
	@Transactional
	public int insertNewVersionMenu(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		int menuIdx;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			ArrayList<String> usageArr = (ArrayList<String>)listMap.get("usageArr");
			String customUsage = (String)listMap.get("customUsage");
			
			ArrayList<String> menuType = (ArrayList<String>)listMap.get("menuType");
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
			JSONArray newItemTypeCodeArr = (JSONArray) parser.parse((String)param.get("newItemTypeCodeArr"));
			
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
				menuDao.updateMenuIsLast(param);
				param.put("isLast", "Y");	//개정하는 문서 버젼이 현재보다 높은 경우에 문서상태를 최신 상태(Y)로 저장한다.
			} else {
				param.put("isLast", "N");	//개정하는 문서 버젼이 현재보다 낮은 경우에 문서상태를 이전 상태(N)로 저장한다.
			}
			
			menuIdx = menuDao.selectMenuSeq(); 	//key value 조회
			param.put("idx", menuIdx);
			//param.put("status", "REG");
			
			if( menuType != null && menuType.size() > 0 ) {
				for( int i = 0 ; i < menuType.size() ; i++ ) {
					param.put("menuType"+(i+1), menuType.get(i));
				}
			}

			menuDao.insertNewVersionMenu(param);
			
			//개선목적
			ArrayList<HashMap<String,Object>> imporvePurList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < itemImproveArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", menuIdx);
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
				menuDao.insertMenuImporvePurpose(imporvePurList);
			}
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( improveArr.size() > 0 ) {
				for( int i = 0 ; i < improveArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", menuIdx);
					purposeData.put("infoType", "IMP");
					purposeData.put("infoText", improveArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( usageArr != null && usageArr.size() > 0 ) {
				for( int i = 0 ; i < usageArr.size() ; i++ ) {
					HashMap<String,Object> usageData = new HashMap<String,Object>();
					usageData.put("idx", menuIdx);
					usageData.put("infoType", "USB");
					usageData.put("infoText", usageArr.get(i));
					addInfoList.add(usageData);
				}
			}
			
			if( customUsage != null && customUsage.length() > 0 ) {
				HashMap<String,Object> usageData = new HashMap<String,Object>();
				usageData.put("idx", menuIdx);
				usageData.put("infoType", "USC");
				usageData.put("infoText", customUsage);
				addInfoList.add(usageData);
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//등록한다.
				menuDao.insertAddInfo(addInfoList);
			}
			
			//신규도입품/제품규격 등록
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < newItemNameArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", menuIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("menuName", newItemNameArr.get(i));
				} catch(Exception e) {
					newMap.put("menuName", "");
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
				
				try{
					newMap.put("typCode", newItemTypeCodeArr.get(i));
				} catch(Exception e) {
					newMap.put("typeCode", "");
				}
				
				newList.add(newMap);
			}
			
			if( newList != null && newList.size() > 0 ) {
				menuDao.insertMenuNew(newList);
			}
			
			//원료 리스트 등록
			ArrayList<HashMap<String,String>> matList = new ArrayList<HashMap<String,String>>();
			for( int i = 0 ; i < itemMatIdxArr.size() ; i++ ) {
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
				menuDao.insertMenuMaterial(param);
			}
			
			if( docType != null ) {
				List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
				for( int i = 0 ; i < docType.size() ; i++ ) {
					HashMap<String, Object> paramMap = new HashMap<String, Object>();
					paramMap.put("docIdx", menuIdx);
					paramMap.put("docType", "MENU");
					paramMap.put("fileType", docType.get(i));
					paramMap.put("fileTypeText", docTypeText.get(i));
					docTypeList.add(paramMap);
				}		
				commonDao.insertFileType(docTypeList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", menuIdx);
			historyParam.put("docType", "MENU");
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
				String path = config.getProperty("upload.file.path.menu");
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
							fileMap.put("docIdx", menuIdx);
							fileMap.put("docType", "MENU");
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
		return menuIdx;
	}


	@Override
	public Map<String, Object> selectErpMaterialData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectErpMaterialData(param);
	}


	@Override
	public Map<String, Object> selectSearchMenu(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> map = new HashMap<String, Object>();
		List<Map<String, Object>> list = menuDao.selectSearchMenu(param);
		map.put("list", list);
		return map;
	}


	@Override
	public Map<String, Object> selectFileData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectFileData(param);
	}


	@Override
	public void deleteFileData(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		menuDao.deleteFileData(param);
	}


	@Override
	@Transactional
	public void updateMenuTmp(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try{
			ArrayList<String> usageArr = (ArrayList<String>)listMap.get("usageArr");
			String customUsage = (String)listMap.get("customUsage");
			
			ArrayList<String> menuType = (ArrayList<String>)listMap.get("menuType");
			ArrayList<String> fileType = (ArrayList<String>)listMap.get("fileType");
			ArrayList<String> fileTypeText = (ArrayList<String>)listMap.get("fileTypeText");
			ArrayList<String> docType = (ArrayList<String>)listMap.get("docType");
			ArrayList<String> docTypeText = (ArrayList<String>)listMap.get("docTypeText");
			ArrayList<String> deleteFileArr = (ArrayList<String>)listMap.get("deleteFileArr");
			ArrayList<String> deleteFilePathArr = (ArrayList<String>)listMap.get("deleteFilePathArr");

			JSONParser parser = new JSONParser();
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
			JSONArray newItemTypeCodeArr = (JSONArray) parser.parse((String)param.get("newItemTypeCodeArr"));
			
			JSONArray itemTypeArr = (JSONArray) parser.parse((String)param.get("itemTypeArr"));
			JSONArray itemMatIdxArr = (JSONArray) parser.parse((String)param.get("itemMatIdxArr"));
			JSONArray itemMatCodeArr = (JSONArray) parser.parse((String)param.get("itemMatCodeArr"));
			JSONArray itemSapCodeArr = (JSONArray) parser.parse((String)param.get("itemSapCodeArr"));
			JSONArray itemNameArr = (JSONArray) parser.parse((String)param.get("itemNameArr"));
			JSONArray itemStandardArr = (JSONArray) parser.parse((String)param.get("itemStandardArr"));
			JSONArray itemKeepExpArr = (JSONArray) parser.parse((String)param.get("itemKeepExpArr"));
			JSONArray itemUnitPriceArr = (JSONArray) parser.parse((String)param.get("itemUnitPriceArr"));
			JSONArray itemDescArr = (JSONArray) parser.parse((String)param.get("itemDescArr"));
	
			int menuIdx = Integer.parseInt((String)param.get("idx")); 	//key value 조회
			param.put("menuIdx", menuIdx);
			
			if( menuType != null && menuType.size() > 0 ) {
				for( int i = 0 ; i < menuType.size() ; i++ ) {
					param.put("menuType"+(i+1), menuType.get(i));
				}
			}
			
			//제품 수정
			menuDao.updateMenuData(param);
			
			
			HashMap<String,Object> map = new HashMap<String,Object>(); 
			map.put("menuIdx", menuIdx);
			//개선목적 삭제
			menuDao.deleteMenuImporvePurpose(map);
			
			//개선목적 등록
			ArrayList<HashMap<String,Object>> imporvePurList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < itemImproveArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", menuIdx);
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
				menuDao.insertMenuImporvePurpose(imporvePurList);
			}
			
			//추가 정보를 삭제한다.			
			menuDao.deleteAddInfo(map);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", menuIdx);
					purposeData.put("infoType", "PUR");
					purposeData.put("infoText", purposeArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( featureArr.size() > 0 ) {
				for( int i = 0 ; i < featureArr.size() ; i++ ) {
					HashMap<String,Object> featureData = new HashMap<String,Object>();
					featureData.put("idx", menuIdx);
					featureData.put("infoType", "FEA");
					featureData.put("infoText", featureArr.get(i));
					addInfoList.add(featureData);
				}
			}
			
			if( improveArr.size() > 0 ) {
				for( int i = 0 ; i < improveArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", menuIdx);
					purposeData.put("infoType", "IMP");
					purposeData.put("infoText", improveArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( usageArr != null && usageArr.size() > 0 ) {
				for( int i = 0 ; i < usageArr.size() ; i++ ) {
					HashMap<String,Object> usageData = new HashMap<String,Object>();
					usageData.put("idx", menuIdx);
					usageData.put("infoType", "USB");
					usageData.put("infoText", usageArr.get(i));
					addInfoList.add(usageData);
				}
			}
			
			if( customUsage != null && customUsage.length() > 0 ) {
				HashMap<String,Object> usageData = new HashMap<String,Object>();
				usageData.put("idx", menuIdx);
				usageData.put("infoType", "USC");
				usageData.put("infoText", customUsage);
				addInfoList.add(usageData);
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//추가 정보를 등록한다.
				menuDao.insertAddInfo(addInfoList);
			}
			
			//신규도입품/제품규격 삭제
			menuDao.deleteMenuNew(map);
			//신규도입품/제품규격 등록
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < newItemNameArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", menuIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("menuName", newItemNameArr.get(i));
				} catch(Exception e) {
					newMap.put("menuName", "");
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
				
				try{
					newMap.put("typeCode", newItemTypeCodeArr.get(i));
				} catch(Exception e) {
					newMap.put("typeCode", "");
				}
				
				newList.add(newMap);
			}
			
			if( newList != null && newList.size() > 0 ) {
				menuDao.insertMenuNew(newList);
			}
			
			//원료 리스트 삭제
			menuDao.deleteMenuMaterial(map);
			
			//원료 리스트 등록
			ArrayList<HashMap<String,String>> matList = new ArrayList<HashMap<String,String>>();
			// itemSapCodeArr => itemMatIdxArr 로 for문 돌림 (신규원료의 경우 SAP_CODE 가 없기떄문) 
			System.out.println("원료 IDX : " + itemMatIdxArr.toString());
			for( int i = 0 ; i < itemMatIdxArr.size() ; i++ ) {
				HashMap<String,String> matMap = new HashMap<String,String>();
				matMap.put("itemType", (String)itemTypeArr.get(i));
				matMap.put("matIdx", (String)itemMatIdxArr.get(i));
				matMap.put("name", (String)itemNameArr.get(i));
				try {
					matMap.put("sapCode", (String)itemSapCodeArr.get(i));										
				} catch(Exception e){
					matMap.put("sapCode", "");					
				}
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
			// 빈 리스트가 아닐 때만 등록 처리 20250429 이정혁 
			if (!matList.isEmpty()) {
				param.put("matList", matList);
				menuDao.insertMenuMaterial(param);
			}
			
			//첨부파일 유형 삭제
			map = new HashMap<String,Object>(); 
			map.put("menuIdx", menuIdx);
			map.put("docType", "MENU");
			commonDao.deleteFileType(map);
			
			//첨부파일 유형 저장
			if( docType != null ) {
				List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
				for( int i = 0 ; i < docType.size() ; i++ ) {
					HashMap<String, Object> paramMap = new HashMap<String, Object>();
					paramMap.put("docIdx", menuIdx);
					paramMap.put("docType", "MENU");
					paramMap.put("fileType", docType.get(i));
					paramMap.put("fileTypeText", docTypeText.get(i));
					docTypeList.add(paramMap);
				}		
				commonDao.insertFileType(docTypeList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", menuIdx);
			historyParam.put("docType", "MENU");
			historyParam.put("historyType", "T");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//삭제된 파일 삭제
			if (deleteFileArr != null && deleteFileArr.size() > 0) {
			    for (int i = 0; i < deleteFileArr.size(); i++) {
			        String fullFileName = deleteFileArr.get(i);
			        String filePath = deleteFilePathArr.get(i);

			        // 첫 번째 '_' 이전의 인덱스 값 추출
			        String fileIdx = fullFileName.split("_")[0];

			        logger.error("삭제할 파일 이름: {}", fullFileName);
			        logger.error("삭제할 파일 경로: {}", filePath);
			        logger.error("삭제할 파일 IDX: {}", fileIdx);

			        FileUtil.fileDelete(fullFileName, filePath);
			        Map<String, Object> fileParam = new HashMap<>();
			        fileParam.put("fileIdx", fileIdx);
			        menuDao.deleteFileData(fileParam);  // ✅ map으로 넘김
			    }
			}
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				Calendar cal = Calendar.getInstance();
		        Date day = cal.getTime();    //시간을 꺼낸다.
		        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
		        String toDay = sdf.format(day);
				String path = config.getProperty("upload.file.path.menu");
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
							fileMap.put("docIdx", menuIdx);
							fileMap.put("docType", "MENU");
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
	@Transactional
	public void updateMenu(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file)
			throws Exception {
		// TODO Auto-generated method stub
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try{
			ArrayList<String> usageArr = (ArrayList<String>)listMap.get("usageArr");
			String customUsage = (String)listMap.get("customUsage");
			
			ArrayList<String> menuType = (ArrayList<String>)listMap.get("menuType");
			ArrayList<String> fileType = (ArrayList<String>)listMap.get("fileType");
			ArrayList<String> fileTypeText = (ArrayList<String>)listMap.get("fileTypeText");
			ArrayList<String> docType = (ArrayList<String>)listMap.get("docType");
			ArrayList<String> docTypeText = (ArrayList<String>)listMap.get("docTypeText");
			ArrayList<String> deleteFileArr = (ArrayList<String>)listMap.get("deleteFileArr");
			ArrayList<String> deleteFilePathArr = (ArrayList<String>)listMap.get("deleteFilePathArr");
			
			JSONParser parser = new JSONParser();
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
			JSONArray newItemTypeCodeArr = (JSONArray) parser.parse((String)param.get("newItemTypeCodeArr"));
			
			JSONArray itemTypeArr = (JSONArray) parser.parse((String)param.get("itemTypeArr"));
			JSONArray itemMatIdxArr = (JSONArray) parser.parse((String)param.get("itemMatIdxArr"));
			JSONArray itemMatCodeArr = (JSONArray) parser.parse((String)param.get("itemMatCodeArr"));
			JSONArray itemSapCodeArr = (JSONArray) parser.parse((String)param.get("itemSapCodeArr"));
			JSONArray itemNameArr = (JSONArray) parser.parse((String)param.get("itemNameArr"));
			JSONArray itemStandardArr = (JSONArray) parser.parse((String)param.get("itemStandardArr"));
			JSONArray itemKeepExpArr = (JSONArray) parser.parse((String)param.get("itemKeepExpArr"));
			JSONArray itemUnitPriceArr = (JSONArray) parser.parse((String)param.get("itemUnitPriceArr"));
			JSONArray itemDescArr = (JSONArray) parser.parse((String)param.get("itemDescArr"));
			
			int menuIdx = Integer.parseInt((String)param.get("idx")); 	//key value 조회
			param.put("menuIdx", menuIdx);
			if( param.get("currentStatus") != null && "COND_APPR".equals(param.get("currentStatus")) ) {
				param.put("status", "APPR");
			} else if( param.get("currentStatus") != null && "TMP".equals(param.get("currentStatus")) ) {
				param.put("status", "REG");
			}
			
			
			if( menuType != null && menuType.size() > 0 ) {
				for( int i = 0 ; i < menuType.size() ; i++ ) {
					param.put("menuType"+(i+1), menuType.get(i));
				}
			}
			
			//제품 수정
			menuDao.updateMenuData(param);
			
			HashMap<String,Object> map = new HashMap<String,Object>(); 
			map.put("menuIdx", menuIdx);
			//개선목적 삭제
			menuDao.deleteMenuImporvePurpose(map);
			
			//개선목적
			ArrayList<HashMap<String,Object>> imporvePurList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < itemImproveArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", menuIdx);
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
				menuDao.insertMenuImporvePurpose(imporvePurList);
			}
			
			//추가 정보를 삭제한다.			
			menuDao.deleteAddInfo(map);
			
			ArrayList<HashMap<String,Object>> addInfoList = new ArrayList<HashMap<String,Object>>();
			if( purposeArr.size() > 0 ) {
				for( int i = 0 ; i < purposeArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", menuIdx);
					purposeData.put("infoType", "PUR");
					purposeData.put("infoText", purposeArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( featureArr.size() > 0 ) {
				for( int i = 0 ; i < featureArr.size() ; i++ ) {
					HashMap<String,Object> featureData = new HashMap<String,Object>();
					featureData.put("idx", menuIdx);
					featureData.put("infoType", "FEA");
					featureData.put("infoText", featureArr.get(i));
					addInfoList.add(featureData);
				}
			}
			
			if( improveArr.size() > 0 ) {
				for( int i = 0 ; i < improveArr.size() ; i++ ) {
					HashMap<String,Object> purposeData = new HashMap<String,Object>();
					purposeData.put("idx", menuIdx);
					purposeData.put("infoType", "IMP");
					purposeData.put("infoText", improveArr.get(i));
					addInfoList.add(purposeData);
				}				
			}
			
			if( usageArr != null && usageArr.size() > 0 ) {
				for( int i = 0 ; i < usageArr.size() ; i++ ) {
					HashMap<String,Object> usageData = new HashMap<String,Object>();
					usageData.put("idx", menuIdx);
					usageData.put("infoType", "USB");
					usageData.put("infoText", usageArr.get(i));
					addInfoList.add(usageData);
				}
			}
			
			if( customUsage != null && customUsage.length() > 0 ) {
				HashMap<String,Object> usageData = new HashMap<String,Object>();
				usageData.put("idx", menuIdx);
				usageData.put("infoType", "USC");
				usageData.put("infoText", customUsage);
				addInfoList.add(usageData);
			}
			
			if( addInfoList != null && addInfoList.size() > 0 ) {
				//추가 정보를 등록한다.
				menuDao.insertAddInfo(addInfoList);
			}
			
			//신규도입품/제품규격 삭제
			menuDao.deleteMenuNew(map);
			//신규도입품/제품규격 등록
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < newItemNameArr.size() ; i++ ) {
				HashMap<String,Object> newMap = new HashMap<String,Object>();
				newMap.put("idx", menuIdx);
				newMap.put("displayOrder", i+1);
				try{
					newMap.put("menuName", newItemNameArr.get(i));
				} catch(Exception e) {
					newMap.put("menuName", "");
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
				
				try{
					newMap.put("typeCode", newItemTypeCodeArr.get(i));
				} catch(Exception e) {
					newMap.put("typeCode", "");
				}
				
				newList.add(newMap);
			}
			
			if( newList != null && newList.size() > 0 ) {
				menuDao.insertMenuNew(newList);
			}
			
			//원료 리스트 삭제
			menuDao.deleteMenuMaterial(map);
			
			//원료 리스트 등록
			ArrayList<HashMap<String,String>> matList = new ArrayList<HashMap<String,String>>();
			for( int i = 0 ; i < itemMatIdxArr.size() ; i++ ) {
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
				menuDao.insertMenuMaterial(param);				
			}
			
			//첨부파일 유형 삭제
			map = new HashMap<String,Object>(); 
			map.put("menuIdx", menuIdx);
			map.put("docType", "MENU");
			commonDao.deleteFileType(map);
			
			//첨부파일 유형 저장
			if( docType != null ) {
				List<HashMap<String, Object>> docTypeList = new ArrayList<HashMap<String, Object>>();
				for( int i = 0 ; i < docType.size() ; i++ ) {
					HashMap<String, Object> paramMap = new HashMap<String, Object>();
					paramMap.put("docIdx", menuIdx);
					paramMap.put("docType", "MENU");
					paramMap.put("fileType", docType.get(i));
					paramMap.put("fileTypeText", docTypeText.get(i));
					docTypeList.add(paramMap);
				}		
				commonDao.insertFileType(docTypeList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", menuIdx);
			historyParam.put("docType", "MENU");
			historyParam.put("historyType", "U");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			//삭제된 파일 삭제
			if (deleteFileArr != null && deleteFileArr.size() > 0) {
			    for (int i = 0; i < deleteFileArr.size(); i++) {
			        String fullFileName = deleteFileArr.get(i);
			        String filePath = deleteFilePathArr.get(i);

			        // 첫 번째 '_' 이전의 인덱스 값 추출
			        String fileIdx = fullFileName.split("_")[0];

			        logger.error("삭제할 파일 이름: {}", fullFileName);
			        logger.error("삭제할 파일 경로: {}", filePath);
			        logger.error("삭제할 파일 IDX: {}", fileIdx);

			        FileUtil.fileDelete(fullFileName, filePath);
			        Map<String, Object> fileParam = new HashMap<>();
			        fileParam.put("fileIdx", fileIdx);
			        menuDao.deleteFileData(fileParam);  // ✅ map으로 넘김
			    }
			}
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
				Calendar cal = Calendar.getInstance();
		        Date day = cal.getTime();    //시간을 꺼낸다.
		        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
		        String toDay = sdf.format(day);
				String path = config.getProperty("upload.file.path.menu");
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
							fileMap.put("docIdx", menuIdx);
							fileMap.put("docType", "MENU");
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
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectMyDataCheck(param);
	}
	
	@Override
	public int selectMyDataCount(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectMyDataCount(param);
	}

}
