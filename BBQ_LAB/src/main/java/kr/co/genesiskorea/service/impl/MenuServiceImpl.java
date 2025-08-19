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
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.web.multipart.MultipartFile;

import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.dao.MenuDao;
import kr.co.genesiskorea.service.ManualService;
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
	ManualService manualService;
	
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
			viewCount = Integer.parseInt((String)param.get("viewCount"));
			pageNo = Integer.parseInt((String)param.get("pageNo"));
		} catch( Exception e ) {
			System.err.println(e.getMessage());
			viewCount = 10;
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
		param.put("docType", "MANUAL");
		List<Map<String, String>> manualFileList = commonDao.selectFileList(param);
		map.put("data", data);
		map.put("fileList", fileList);
		map.put("fileType", fileType);
		map.put("manualFileList", manualFileList);
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
			/*ArrayList<String> docType = (ArrayList<String>)listMap.get("docType");
			ArrayList<String> docTypeText = (ArrayList<String>)listMap.get("docTypeText");*/
			ArrayList<String> tempFile = (ArrayList<String>)listMap.get("tempFile");
			
			// === MANUAL: 컨트롤러에서 listMap으로 전달된 매뉴얼 파라미터 받기 ===
			List<String> manualFileType     = (List<String>) listMap.get("manualFileType");
			List<String> manualFileTypeText = (List<String>) listMap.get("manualFileTypeText"); // 필요시
			MultipartFile[] manualFiles     = (MultipartFile[]) listMap.get("manualFiles");
			
			JSONParser parser = new JSONParser();
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray featureArr = (JSONArray) parser.parse((String)param.get("featureArr"));
			
			JSONArray sharedUserArr = (JSONArray) parser.parse((String)param.get("sharedUserArr"));
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
			
			JSONArray docType = (JSONArray) parser.parse((String)param.get("docTypeArr"));
			JSONArray docTypeText = (JSONArray) parser.parse((String)param.get("docTypeTextArr"));
			
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
			
			// 공동 참여자 등록
			ArrayList<HashMap<String,Object>> sharedUserList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < sharedUserArr.size() ; i++ ) {
				HashMap<String,Object> sharedUserMap = new HashMap<String,Object>();
				sharedUserMap.put("userId", sharedUserArr.get(i));
				sharedUserMap.put("docType", "MENU");
				sharedUserMap.put("docIdx", menuIdx);
				
				sharedUserList.add(sharedUserMap);
			} 
			
			if( sharedUserList != null && sharedUserList.size() > 0 ) {
				menuDao.insertSharedUser(sharedUserList);
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
			
	        // === MANUAL: 매뉴얼 파일 저장(매뉴얼 테이블) ===
			if (manualFiles != null && manualFiles.length > 0) {
			    Calendar cal = Calendar.getInstance();
			    Date day = cal.getTime();
			    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
			    String toDay = sdf.format(day);

			    // 구성 키: upload.file.path.manual  (오타 없이 manual)
			    String manualBasePath = config.getProperty("upload.file.path.manual");
			    String manualPath = manualBasePath + "/" + toDay;

			    int midx = 0;
			    for (MultipartFile mfile : manualFiles) {
			        System.err.println("===== MANUAL =====================");
			        System.err.println("isEmpty : " + mfile.isEmpty());
			        System.err.println("name : " + mfile.getName());
			        System.err.println("originalFilename : " + mfile.getOriginalFilename());
			        System.err.println("size : " + mfile.getSize());
			        System.err.println("==================================");
			        try {
			            if (!mfile.isEmpty()) {
			                String fileIdx = FileUtil.getUUID();
			                String result  = FileUtil.upload3(mfile, manualPath, fileIdx);
			                String content = FileUtil.getPdfContents(manualPath, result);

			                // 수신된 fileType 우선, 없으면 "00" 기본
			                String manType = (manualFileType != null && midx < manualFileType.size())
			                        ? manualFileType.get(midx)
			                        : "00";

			                Map<String,Object> fileMap = new HashMap<>();
			                fileMap.put("fileIdx",        fileIdx);
			                fileMap.put("docIdx",         menuIdx);            // ★ 메뉴 IDX
			                fileMap.put("docType",        "MANUAL");           // ★ MANUAL로 저장
			                fileMap.put("fileType",       manType);            // 예: MAN
			                fileMap.put("orgFileName",    mfile.getOriginalFilename());
			                fileMap.put("filePath",       manualPath);
			                fileMap.put("changeFileName", result);
			                fileMap.put("content",        content);

			                commonDao.insertFileInfo(fileMap);
			                midx++;
			            }
			        } catch (Exception e) {
			            // 필요시 로그만 남기고 다음 파일 계속
			            logger.warn("manual file save error", e);
			        }
			    }
			}
			// === MANUAL 블록 끝 ===
			
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
			/*ArrayList<String> docType = (ArrayList<String>)listMap.get("docType");
			ArrayList<String> docTypeText = (ArrayList<String>)listMap.get("docTypeText");*/
			ArrayList<String> tempFile = (ArrayList<String>)listMap.get("tempFile");
			
			// === MANUAL: 컨트롤러에서 listMap으로 전달된 매뉴얼 파라미터 받기 ===
			List<String> manualFileType     = (List<String>) listMap.get("manualFileType");
			List<String> manualFileTypeText = (List<String>) listMap.get("manualFileTypeText"); // 필요시
			MultipartFile[] manualFiles     = (MultipartFile[]) listMap.get("manualFiles");
			
			JSONParser parser = new JSONParser();
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray featureArr = (JSONArray) parser.parse((String)param.get("featureArr"));
			
			JSONArray sharedUserArr = (JSONArray) parser.parse((String)param.get("sharedUserArr"));
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
			
			JSONArray docType = (JSONArray) parser.parse((String)param.get("docTypeArr"));
			JSONArray docTypeText = (JSONArray) parser.parse((String)param.get("docTypeTextArr"));

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
			
			// 공동 참여자 등록
			ArrayList<HashMap<String,Object>> sharedUserList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < sharedUserArr.size() ; i++ ) {
				HashMap<String,Object> sharedUserMap = new HashMap<String,Object>();
				sharedUserMap.put("userId", sharedUserArr.get(i));
				sharedUserMap.put("docType", "MENU");
				sharedUserMap.put("docIdx", menuIdx);
				
				sharedUserList.add(sharedUserMap);
			} 
			
			if( sharedUserList != null && sharedUserList.size() > 0 ) {
				menuDao.insertSharedUser(sharedUserList);
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
			
			// === MANUAL: 매뉴얼 파일 저장(매뉴얼 테이블) ===
			if (manualFiles != null && manualFiles.length > 0) {
			    Calendar cal = Calendar.getInstance();
			    Date day = cal.getTime();
			    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
			    String toDay = sdf.format(day);

			    // 구성 키: upload.file.path.manual  (오타 없이 manual)
			    String manualBasePath = config.getProperty("upload.file.path.manual");
			    String manualPath = manualBasePath + "/" + toDay;

			    int midx = 0;
			    for (MultipartFile mfile : manualFiles) {
			        System.err.println("===== MANUAL =====================");
			        System.err.println("isEmpty : " + mfile.isEmpty());
			        System.err.println("name : " + mfile.getName());
			        System.err.println("originalFilename : " + mfile.getOriginalFilename());
			        System.err.println("size : " + mfile.getSize());
			        System.err.println("==================================");
			        try {
			            if (!mfile.isEmpty()) {
			                String fileIdx = FileUtil.getUUID();
			                String result  = FileUtil.upload3(mfile, manualPath, fileIdx);
			                String content = FileUtil.getPdfContents(manualPath, result);

			                // 수신된 fileType 우선, 없으면 "00" 기본
			                String manType = (manualFileType != null && midx < manualFileType.size())
			                        ? manualFileType.get(midx)
			                        : "00";

			                Map<String,Object> fileMap = new HashMap<>();
			                fileMap.put("fileIdx",        fileIdx);
			                fileMap.put("docIdx",         menuIdx);            // ★ 메뉴 IDX
			                fileMap.put("docType",        "MANUAL");           // ★ MANUAL로 저장
			                fileMap.put("fileType",       manType);            // 예: 00
			                fileMap.put("orgFileName",    mfile.getOriginalFilename());
			                fileMap.put("filePath",       manualPath);
			                fileMap.put("changeFileName", result);
			                fileMap.put("content",        content);

			                commonDao.insertFileInfo(fileMap);
			                midx++;
			            }
			        } catch (Exception e) {
			            // 필요시 로그만 남기고 다음 파일 계속
			            logger.warn("manual file save error", e);
			        }
			    }
			}
			// === MANUAL 블록 끝 ===
			
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
	public int insertNewVersionMenuTmp(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file, MultipartFile[] manualFile)
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
			ArrayList<String> tempFile = (ArrayList<String>)listMap.get("tempFile");
			ArrayList<String> manualTempFile = (ArrayList<String>) listMap.get("manualTempFile");
			
			JSONParser parser = new JSONParser();
			JSONArray itemImproveArr = (JSONArray) parser.parse((String)param.get("itemImproveArr"));
			JSONArray itemExistArr = (JSONArray) parser.parse((String)param.get("itemExistArr"));
			JSONArray itemNoteArr = (JSONArray) parser.parse((String)param.get("itemNoteArr"));
			JSONArray improveArr = (JSONArray) parser.parse((String)param.get("improveArr"));
			
			JSONArray sharedUserArr = (JSONArray) parser.parse((String)param.get("sharedUserArr"));
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
			
			JSONArray docType = (JSONArray) parser.parse((String)param.get("docTypeArr"));
			JSONArray docTypeText = (JSONArray) parser.parse((String)param.get("docTypeTextArr"));
			
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
			
			// 공동 참여자 등록
			ArrayList<HashMap<String,Object>> sharedUserList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < sharedUserArr.size() ; i++ ) {
				HashMap<String,Object> sharedUserMap = new HashMap<String,Object>();
				sharedUserMap.put("userId", sharedUserArr.get(i));
				sharedUserMap.put("docType", "MENU");
				sharedUserMap.put("docIdx", menuIdx);
				
				sharedUserList.add(sharedUserMap);
			} 
			
			if( sharedUserList != null && sharedUserList.size() > 0 ) {
				menuDao.insertSharedUser(sharedUserList);
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
			
			String path = config.getProperty("upload.file.path.menu");
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
	        path += "/"+toDay; 
	        
	        //문서 복사 시 기존 첨부파일을 유지하는 경우 기존 파일 데이터를 복사합니다.
			if( tempFile != null ) {
				if( tempFile.size() > 0 ) {
					//기존 파일 정보를 조회한다.
					List<Map<String, Object>> tempFileList = commonDao.selectTempFileList(tempFile);
					if( tempFileList != null && tempFileList.size() > 0 ) {
						for( int i = 0 ; i < tempFileList.size() ; i++ ) {
							Map<String, Object> tempFileData = tempFileList.get(i);
							String orgFileName = (String)tempFileData.get("ORG_FILE_NAME");
							String fileName = (String)tempFileData.get("FILE_NAME");
							String filePath = (String)tempFileData.get("FILE_PATH");
							String fileContents = (String)tempFileData.get("FILE_CONTENT");
							if( orgFileName != null && !"".equals(orgFileName) && !"undefined".equals(orgFileName) ) {
								String currentFilePath = filePath+File.separator+fileName;
								String fileIdx = FileUtil.getUUID();
								String newFilePath = path;
								String newFileName = fileIdx+"_"+orgFileName;
								File currentFile = new File(currentFilePath);						
								File newFile = new File(newFilePath+File.separator+newFileName);
								FileUtils.copyFile(currentFile, newFile);
								
								Map<String,Object> fileMap = new HashMap<String,Object>();
								fileMap.put("fileIdx", fileIdx);
								fileMap.put("docIdx", menuIdx);
								fileMap.put("docType", "MENU");
								fileMap.put("fileType", "00");
								fileMap.put("orgFileName", orgFileName);
								fileMap.put("filePath", path);
								fileMap.put("changeFileName", newFileName);
								fileMap.put("content", fileContents);
								System.err.println(fileMap);
								//파일정보 저장
								commonDao.insertFileInfo(fileMap);
							}
						}
					}
				}
			}
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
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
			
			String yyyyMM = new SimpleDateFormat("yyyyMM").format(Calendar.getInstance().getTime());
			
			// MANUAL 첨부 저장 경로  ✅ 추가
			String manualPath = config.getProperty("upload.file.path.manual") 
			                    + "/" + yyyyMM;
			
			// ====================== MANUAL : 기존 매뉴얼 승계 복사 ======================
			if (manualTempFile != null && !manualTempFile.isEmpty()) {
			    List<Map<String, Object>> manualTempFileList = commonDao.selectTempFileList(manualTempFile);
			    if (manualTempFileList != null && !manualTempFileList.isEmpty()) {
			        for (Map<String, Object> tempFileData : manualTempFileList) {
			            String orgFileName  = (String) tempFileData.get("ORG_FILE_NAME");
			            String fileName     = (String) tempFileData.get("FILE_NAME");
			            String filePath     = (String) tempFileData.get("FILE_PATH");
			            String fileContents = (String) tempFileData.get("FILE_CONTENT");

			            if (orgFileName != null && !"".equals(orgFileName) && !"undefined".equals(orgFileName)) {
			                String srcFullPath = filePath + "/" + fileName;

			                String newFileIdx  = FileUtil.getUUID();
			                String newFileName = newFileIdx + "_" + orgFileName; // 기존 MENU 승계 로직과 동일 포맷

			                File src  = new File(srcFullPath);
			                File dest = new File(manualPath + "/" + newFileName);
			                FileUtils.copyFile(src, dest);

			                Map<String, Object> fileMap = new HashMap<>();
			                fileMap.put("fileIdx",       newFileIdx);
			                fileMap.put("docIdx",        menuIdx);
			                fileMap.put("docType",       "MANUAL");   // ✅ 매뉴얼
			                fileMap.put("fileType",      "00");      // 정책상 고정(필요시 원본 FILE_TYPE 사용 가능)
			                fileMap.put("orgFileName",   orgFileName);
			                fileMap.put("filePath",      manualPath);
			                fileMap.put("changeFileName", newFileName);
			                fileMap.put("content",       fileContents);

			                commonDao.insertFileInfo(fileMap);
			            }
			        }
			    }
			}
			
			// ====================== MANUAL : 신규 업로드 저장 ======================
			if (manualFile != null && manualFile.length > 0) {
			    for (MultipartFile mf : manualFile) {
			        if (mf == null || mf.isEmpty()) continue;

			        try {
			            String fileIdx = FileUtil.getUUID();
			            String saved   = FileUtil.upload3(mf, manualPath, fileIdx);
			            String content = FileUtil.getPdfContents(manualPath, saved);

			            Map<String, Object> fileMap = new HashMap<>();
			            fileMap.put("fileIdx",        fileIdx);
			            fileMap.put("docIdx",         menuIdx);
			            fileMap.put("docType",        "MANUAL");                 // ✅ 매뉴얼
			            fileMap.put("fileType",       "00");                    // 정책상 고정
			            fileMap.put("orgFileName",    mf.getOriginalFilename());
			            fileMap.put("filePath",       manualPath);
			            fileMap.put("changeFileName", saved);
			            fileMap.put("content",        content);

			            commonDao.insertFileInfo(fileMap);
			        } catch (Exception ignore) {
			            // 필요시 로깅
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
	public int insertNewVersionMenu(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file, MultipartFile[] manualFile)
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
			ArrayList<String> tempFile = (ArrayList<String>)listMap.get("tempFile");
			ArrayList<String> manualTempFile  = (ArrayList<String>) listMap.get("manualTempFile");
			
			JSONParser parser = new JSONParser();
			JSONArray itemImproveArr = (JSONArray) parser.parse((String)param.get("itemImproveArr"));
			JSONArray itemExistArr = (JSONArray) parser.parse((String)param.get("itemExistArr"));
			JSONArray itemNoteArr = (JSONArray) parser.parse((String)param.get("itemNoteArr"));
			JSONArray improveArr = (JSONArray) parser.parse((String)param.get("improveArr"));
			
			JSONArray sharedUserArr = (JSONArray) parser.parse((String)param.get("sharedUserArr"));
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
			
			JSONArray docType = (JSONArray) parser.parse((String)param.get("docTypeArr"));
			JSONArray docTypeText = (JSONArray) parser.parse((String)param.get("docTypeTextArr"));
			
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
			
			// 공동 참여자 등록
			ArrayList<HashMap<String,Object>> sharedUserList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < sharedUserArr.size() ; i++ ) {
				HashMap<String,Object> sharedUserMap = new HashMap<String,Object>();
				sharedUserMap.put("userId", sharedUserArr.get(i));
				sharedUserMap.put("docType", "MENU");
				sharedUserMap.put("docIdx", menuIdx);
				
				sharedUserList.add(sharedUserMap);
			} 
			
			if( sharedUserList != null && sharedUserList.size() > 0 ) {
				menuDao.insertSharedUser(sharedUserList);
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
			
			String path = config.getProperty("upload.file.path.menu");
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
	        path += "/" + toDay; 
	        
	        //문서 복사 시 기존 첨부파일을 유지하는 경우 기존 파일 데이터를 복사합니다.
			if( tempFile != null ) {
				if( tempFile.size() > 0 ) {
					//기존 파일 정보를 조회한다.
					List<Map<String, Object>> tempFileList = commonDao.selectTempFileList(tempFile);
					if( tempFileList != null && tempFileList.size() > 0 ) {
						for( int i = 0 ; i < tempFileList.size() ; i++ ) {
							Map<String, Object> tempFileData = tempFileList.get(i);
							String orgFileName = (String)tempFileData.get("ORG_FILE_NAME");
							String fileName = (String)tempFileData.get("FILE_NAME");
							String filePath = (String)tempFileData.get("FILE_PATH");
							String fileContents = (String)tempFileData.get("FILE_CONTENT");
							if( orgFileName != null && !"".equals(orgFileName) && !"undefined".equals(orgFileName) ) {
								String currentFilePath = filePath+"/"+fileName;
								String fileIdx = FileUtil.getUUID();
								String newFilePath = path;
								String newFileName = fileIdx+"_"+orgFileName;
								File currentFile = new File(currentFilePath);						
								File newFile = new File(newFilePath+"/"+newFileName);
								FileUtils.copyFile(currentFile, newFile);
								
								Map<String,Object> fileMap = new HashMap<String,Object>();
								fileMap.put("fileIdx", fileIdx);
								fileMap.put("docIdx", menuIdx);
								fileMap.put("docType", "MENU");
								fileMap.put("fileType", "00");
								fileMap.put("orgFileName", orgFileName);
								fileMap.put("filePath", path);
								fileMap.put("changeFileName", newFileName);
								fileMap.put("content", fileContents);
								System.err.println(fileMap);
								//파일정보 저장
								commonDao.insertFileInfo(fileMap);
							}
						}
					}
				}
			}
			
			//파일 DB 저장
			if( file != null && file.length > 0 ) {
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
			
			String yyyyMM = new SimpleDateFormat("yyyyMM").format(new Date());
			String manualPath = config.getProperty("upload.file.path.manual") + "/" + yyyyMM;
			
			// ✅ 문서 복사 시 기존 매뉴얼 파일 승계
			if (manualTempFile != null && manualTempFile.size() > 0) {
			    List<Map<String, Object>> tempManualList = commonDao.selectTempFileList(manualTempFile);
			    if (tempManualList != null && tempManualList.size() > 0) {
			        for (Map<String, Object> tempFileData : tempManualList) {
			            String orgFileName  = (String) tempFileData.get("ORG_FILE_NAME");
			            String fileName     = (String) tempFileData.get("FILE_NAME");
			            String filePath     = (String) tempFileData.get("FILE_PATH");
			            String fileContents = (String) tempFileData.get("FILE_CONTENT");
			            if (orgFileName != null && !"".equals(orgFileName) && !"undefined".equals(orgFileName)) {
			                String currentFilePath = filePath + "/" + fileName;
			                String fileIdx         = FileUtil.getUUID();
			                String newFileName     = fileIdx + "_" + orgFileName;

			                FileUtils.copyFile(new File(currentFilePath), new File(manualPath, newFileName));

			                Map<String, Object> fileMap = new HashMap<>();
			                fileMap.put("fileIdx",        fileIdx);
			                fileMap.put("docIdx",         menuIdx);
			                fileMap.put("docType",        "MANUAL"); // ✅ 중요
			                fileMap.put("fileType",       "00");    // ✅ 고정 
			                fileMap.put("orgFileName",    orgFileName);
			                fileMap.put("filePath",       manualPath);
			                fileMap.put("changeFileName", newFileName);
			                fileMap.put("content",        fileContents);
			                commonDao.insertFileInfo(fileMap);
			            }
			        }
			    }
			}
			
			// ✅ 새로 추가한 매뉴얼 파일 업로드
			if (manualFile != null && manualFile.length > 0) {
			    for (MultipartFile mf : manualFile) {
			        if (!mf.isEmpty()) {
			            String fileIdx  = FileUtil.getUUID();
			            String result   = FileUtil.upload3(mf, manualPath, fileIdx);
			            String content  = FileUtil.getPdfContents(manualPath, result);

			            Map<String, Object> fileMap = new HashMap<>();
			            fileMap.put("fileIdx",        fileIdx);
			            fileMap.put("docIdx",         menuIdx);
			            fileMap.put("docType",        "MANUAL"); // ✅ 중요
			            fileMap.put("fileType",       "00");    // ✅ 고정
			            fileMap.put("orgFileName",    mf.getOriginalFilename());
			            fileMap.put("filePath",       manualPath);
			            fileMap.put("changeFileName", result);
			            fileMap.put("content",        content);
			            commonDao.insertFileInfo(fileMap);
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
	public void updateMenuTmp(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file, MultipartFile[] manualFiles)
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
			/*ArrayList<String> docType = (ArrayList<String>)listMap.get("docType");
			ArrayList<String> docTypeText = (ArrayList<String>)listMap.get("docTypeText");
			ArrayList<String> deleteFileArr = (ArrayList<String>)listMap.get("deleteFileArr");
			ArrayList<String> deleteFilePathArr = (ArrayList<String>)listMap.get("deleteFilePathArr");*/

			JSONParser parser = new JSONParser();
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray featureArr = (JSONArray) parser.parse((String)param.get("featureArr"));
			
			JSONArray sharedUserArr = (JSONArray) parser.parse((String)param.get("sharedUserArr"));
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
			
			JSONArray docType = (JSONArray) parser.parse((String)param.get("docTypeArr"));
			JSONArray docTypeText = (JSONArray) parser.parse((String)param.get("docTypeTextArr"));
			JSONArray deletedFileIdArr = (JSONArray) parser.parse((String)param.get("deletedFileIdArr"));
			JSONArray deletedFileArr = (JSONArray) parser.parse((String)param.get("deletedFileArr"));
			JSONArray deletedFilePathArr = (JSONArray) parser.parse((String)param.get("deletedFilePathArr"));
	
			JSONArray manualDeletedFileIdArr = new JSONArray();
			JSONArray manualDeletedFileArr = new JSONArray();
			JSONArray manualDeletedFilePathArr = new JSONArray();

			Object manualDelIdRaw   = param.get("manualDeletedFileIdArr");
			Object manualDelNameRaw = param.get("manualDeletedFileArr");
			Object manualDelPathRaw = param.get("manualDeletedFilePathArr");

			if (manualDelIdRaw != null && !"".equals(String.valueOf(manualDelIdRaw).trim())) {
			    manualDeletedFileIdArr = (JSONArray) parser.parse(String.valueOf(manualDelIdRaw));
			}
			if (manualDelNameRaw != null && !"".equals(String.valueOf(manualDelNameRaw).trim())) {
			    manualDeletedFileArr = (JSONArray) parser.parse(String.valueOf(manualDelNameRaw));
			}
			if (manualDelPathRaw != null && !"".equals(String.valueOf(manualDelPathRaw).trim())) {
			    manualDeletedFilePathArr = (JSONArray) parser.parse(String.valueOf(manualDelPathRaw));
			}
			
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
			
			menuDao.deleteSharedUser(map);
			
			// 공동 참여자 등록
			ArrayList<HashMap<String,Object>> sharedUserList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < sharedUserArr.size() ; i++ ) {
				HashMap<String,Object> sharedUserMap = new HashMap<String,Object>();
				sharedUserMap.put("userId", sharedUserArr.get(i));
				sharedUserMap.put("docType", "MENU");
				sharedUserMap.put("docIdx", menuIdx);
				
				sharedUserList.add(sharedUserMap);
			} 
			
			if( sharedUserList != null && sharedUserList.size() > 0 ) {
				menuDao.insertSharedUser(sharedUserList);
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
			if( docType != null && docType.size() > 0 ) {
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
			if (deletedFileIdArr != null && deletedFileIdArr.size() > 0) {
			    for (int i = 0; i < deletedFileIdArr.size(); i++) {
			    	String fileIdx = (String)deletedFileIdArr.get(i);
			        String fullFileName = (String)deletedFileArr.get(i);
			        String filePath = (String)deletedFilePathArr.get(i);

			        // 첫 번째 '_' 이전의 인덱스 값 추출
			        //String fileIdx = fullFileName.split("_")[0];

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
			
			// === MANUAL: 매뉴얼 파일 삭제(선택 삭제)
			// 1) 기존에 파일이 있고 삭제버튼을 누른 경우 → 파일시스템 삭제 + DB 삭제
			if (manualDeletedFileIdArr != null && manualDeletedFileIdArr.size() > 0) {
			    for (int i = 0; i < manualDeletedFileIdArr.size(); i++) {
			        String fileIdx   = (String) manualDeletedFileIdArr.get(i);   // lab_file.FILE_IDX
			        String fileName  = (String) manualDeletedFileArr.get(i);      // FILE_NAME
			        String filePath  = (String) manualDeletedFilePathArr.get(i);  // FILE_PATH

			        logger.error("삭제할 MANUAL 파일 이름: {}", fileName);
			        logger.error("삭제할 MANUAL 파일 경로: {}", filePath);
			        logger.error("삭제할 MANUAL 파일 IDX: {}", fileIdx);

			        // 물리파일 삭제
			        FileUtil.fileDelete(fileName, filePath);

			        // DB 삭제 (기존에 사용하던 삭제 DAO 사용)
			        Map<String, Object> fileParam = new HashMap<>();
			        fileParam.put("fileIdx", fileIdx);
			        menuDao.deleteFileData(fileParam);
			    }
			}

			// === MANUAL: 매뉴얼 신규 파일 업로드 & DB 저장
			// 2) 신규 파일 등록(기존 파일 삭제 여부와 무관) → 업로드 + lab_file insert(DOC_TYPE='MANUAL', FILE_TYPE='00')
			if (manualFiles != null && manualFiles.length > 0) {
			    Calendar cal = Calendar.getInstance();
			    Date day = cal.getTime();
			    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
			    String toDay = sdf.format(day);

			    // 저장 경로: upload.file.path.manual/yyyyMM
			    String manualPath = config.getProperty("upload.file.path.manual");
			    manualPath += "/" + toDay;

			    for (MultipartFile mfile : manualFiles) {
			        System.err.println("===== MANUAL =====================");
			        System.err.println("isEmpty : " + mfile.isEmpty());
			        System.err.println("name : " + mfile.getName());
			        System.err.println("originalFilename : " + mfile.getOriginalFilename());
			        System.err.println("size : " + mfile.getSize());
			        System.err.println("==================================");

			        try {
			            if (!mfile.isEmpty()) {
			                String fileIdx = FileUtil.getUUID();
			                String result  = FileUtil.upload3(mfile, manualPath, fileIdx);          // 저장파일명
			                String content = FileUtil.getPdfContents(manualPath, result);           // 텍스트 추출

			                Map<String, Object> fileMap = new HashMap<>();
			                fileMap.put("fileIdx",       fileIdx);
			                fileMap.put("docIdx",        menuIdx);                                  // 메뉴IDX
			                fileMap.put("docType",       "MANUAL");                                 // ★ MANUAL
			                fileMap.put("fileType",      "00");                                    // 구분값(원하면 '00'로 통일 가능)
			                fileMap.put("orgFileName",   mfile.getOriginalFilename());
			                fileMap.put("filePath",      manualPath);
			                fileMap.put("changeFileName", result);
			                fileMap.put("content",       content);

			                // DB insert
			                commonDao.insertFileInfo(fileMap);
			            }
			        } catch (Exception e) {
			            // 필요 시 로깅
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
	public void updateMenu(Map<String, Object> param, HashMap<String, Object> listMap, MultipartFile[] file, MultipartFile[] manualFiles)
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
			/*ArrayList<String> docType = (ArrayList<String>)listMap.get("docType");
			ArrayList<String> docTypeText = (ArrayList<String>)listMap.get("docTypeText");
			ArrayList<String> deleteFileArr = (ArrayList<String>)listMap.get("deleteFileArr");
			ArrayList<String> deleteFilePathArr = (ArrayList<String>)listMap.get("deleteFilePathArr");*/
			
			JSONParser parser = new JSONParser();
			JSONArray purposeArr = (JSONArray) parser.parse((String)param.get("purposeArr"));
			JSONArray featureArr = (JSONArray) parser.parse((String)param.get("featureArr"));
			
			JSONArray sharedUserArr = (JSONArray) parser.parse((String)param.get("sharedUserArr"));
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
			
			JSONArray docType = (JSONArray) parser.parse((String)param.get("docTypeArr"));
			JSONArray docTypeText = (JSONArray) parser.parse((String)param.get("docTypeTextArr"));
			JSONArray deletedFileIdArr = (JSONArray) parser.parse((String)param.get("deletedFileIdArr"));
			JSONArray deletedFileArr = (JSONArray) parser.parse((String)param.get("deletedFileArr"));
			JSONArray deletedFilePathArr = (JSONArray) parser.parse((String)param.get("deletedFilePathArr"));
			
			JSONArray manualDeletedFileIdArr   = new JSONArray();
			JSONArray manualDeletedFileArr     = new JSONArray();
			JSONArray manualDeletedFilePathArr = new JSONArray();

			Object manualDelIdRaw   = param.get("manualDeletedFileIdArr");
			Object manualDelNameRaw = param.get("manualDeletedFileArr");
			Object manualDelPathRaw = param.get("manualDeletedFilePathArr");

			if (manualDelIdRaw != null && !"".equals(String.valueOf(manualDelIdRaw).trim())) {
			    manualDeletedFileIdArr = (JSONArray) parser.parse(String.valueOf(manualDelIdRaw));
			}
			if (manualDelNameRaw != null && !"".equals(String.valueOf(manualDelNameRaw).trim())) {
			    manualDeletedFileArr = (JSONArray) parser.parse(String.valueOf(manualDelNameRaw));
			}
			if (manualDelPathRaw != null && !"".equals(String.valueOf(manualDelPathRaw).trim())) {
			    manualDeletedFilePathArr = (JSONArray) parser.parse(String.valueOf(manualDelPathRaw));
			}
			
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
			
			menuDao.deleteSharedUser(map);
			
			// 공동 참여자 등록
			ArrayList<HashMap<String,Object>> sharedUserList = new ArrayList<HashMap<String,Object>>();
			for( int i = 0 ; i < sharedUserArr.size() ; i++ ) {
				HashMap<String,Object> sharedUserMap = new HashMap<String,Object>();
				sharedUserMap.put("userId", sharedUserArr.get(i));
				sharedUserMap.put("docType", "MENU");
				sharedUserMap.put("docIdx", menuIdx);
				
				sharedUserList.add(sharedUserMap);
			} 
			
			if( sharedUserList != null && sharedUserList.size() > 0 ) {
				menuDao.insertSharedUser(sharedUserList);
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
			if (deletedFileIdArr != null && deletedFileIdArr.size() > 0) {
			    for (int i = 0; i < deletedFileIdArr.size(); i++) {
			        String fileIdx = (String)deletedFileIdArr.get(i);
			    	String fullFileName = (String)deletedFileArr.get(i);
			        String filePath = (String)deletedFilePathArr.get(i);

			        // 첫 번째 '_' 이전의 인덱스 값 추출
			        //String fileIdx = fullFileName.split("_")[0];

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
			
			// === MANUAL: 삭제 처리 (기존 파일이 있고 삭제버튼을 누른 경우)
			if (manualDeletedFileIdArr != null && manualDeletedFileIdArr.size() > 0) {
			    for (int i = 0; i < manualDeletedFileIdArr.size(); i++) {
			        String fileIdx  = (String) manualDeletedFileIdArr.get(i);  // lab_file.FILE_IDX
			        String fileName = (String) manualDeletedFileArr.get(i);     // FILE_NAME
			        String filePath = (String) manualDeletedFilePathArr.get(i); // FILE_PATH

			        FileUtil.fileDelete(fileName, filePath);

			        Map<String, Object> fileParam = new HashMap<>();
			        fileParam.put("fileIdx", fileIdx);
			        menuDao.deleteFileData(fileParam); // 기존 파일 삭제 DAO 그대로 재사용
			    }
			}

			// === MANUAL: 신규 파일 등록 (삭제했든 아니든, 새로 올린게 있으면 저장)
			if (manualFiles != null && manualFiles.length > 0) {
			    Calendar cal = Calendar.getInstance();
			    Date day = cal.getTime();
			    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
			    String toDay = sdf.format(day);

			    String manualPath = config.getProperty("upload.file.path.manual");
			    manualPath += "/" + toDay;

			    for (MultipartFile mfile : manualFiles) {
			        if (mfile != null && !mfile.isEmpty()) {
			            String fileIdx = FileUtil.getUUID();
			            String saved   = FileUtil.upload3(mfile, manualPath, fileIdx);
			            String content = FileUtil.getPdfContents(manualPath, saved);

			            Map<String, Object> fileMap = new HashMap<>();
			            fileMap.put("fileIdx",       fileIdx);
			            fileMap.put("docIdx",        menuIdx);
			            fileMap.put("docType",       "MANUAL"); // ★ MANUAL
			            fileMap.put("fileType",      "00");    // 필요시 '00'로 통일 가능
			            fileMap.put("orgFileName",   mfile.getOriginalFilename());
			            fileMap.put("filePath",      manualPath);
			            fileMap.put("changeFileName", saved);
			            fileMap.put("content",       content);

			            commonDao.insertFileInfo(fileMap);
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
	
	@Override
	public List<Map<String, String>> selectSharedUser(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return menuDao.selectSharedUser(param);
	}


	@Override
	public void deleteMenu(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		menuDao.deleteMenu(param);
	}

}
