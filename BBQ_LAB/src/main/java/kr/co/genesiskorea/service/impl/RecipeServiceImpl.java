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
import kr.co.genesiskorea.dao.RecipeDao;
import kr.co.genesiskorea.service.RecipeService;
import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class RecipeServiceImpl implements RecipeService {
	private Logger logger = LogManager.getLogger(RecipeServiceImpl.class);

	@Autowired
	RecipeDao recipeDao;
	
	@Autowired
	CommonDao commonDao;
	
	@Resource
	DataSourceTransactionManager txManager;
	
	@Autowired
	private Properties config;
	
	@Override
	public Map<String, Object> selectRecipeList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		int totalCount = recipeDao.selectRecipeCount(param);
		
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
		List<Map<String, Object>> recipeList = recipeDao.selectRecipeList(param);		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", recipeList);	
		map.put("navi", navi);
		return map;
	}
	
	@Override
	public int insertTmpRecipe(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int recipeIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			JSONParser parser = new JSONParser();
			JSONArray matItemSapCode = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemSapCodeArr")));
			JSONArray matItemName = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemNameArr")));
			JSONArray matItemCompCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemCompCountArr")));
			JSONArray matItemCompUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemCompUnitArr")));
			JSONArray matItemUseCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemUseCountArr")));
			JSONArray matItemUseUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemUseUnitArr")));
			
			JSONArray newItemName = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemNameArr")));
			JSONArray newItemCompCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemCompCountArr")));
			JSONArray newItemCompUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemCompUnitArr")));
			JSONArray newItemUseCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemUseCountArr")));
			JSONArray newItemUseUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemUseUnitArr")));
			JSONArray newItemPrice = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemPriceArr")));
			JSONArray newItemDesc = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemDescArr")));
			
			ArrayList<String> fileType = (ArrayList<String>)param.get("fileType");
			
			recipeIdx = recipeDao.selectRecipeSeq(); 	//key value 조
			param.put("idx", recipeIdx);
			
			recipeDao.insertRecipe(param);
			
			ArrayList<HashMap<String,Object>> matList = new ArrayList<HashMap<String,Object>>();
			if( matItemSapCode != null && matItemSapCode.size() > 0 ) {
				for( int i = 0 ; i < matItemSapCode.size() ; i++ ) {
					HashMap<String,Object> matData = new HashMap<String,Object>();
					matData.put("idx", recipeIdx);
					matData.put("no", (i*10)+10);
					try{
						matData.put("sapCode", matItemSapCode.get(i));
					} catch(Exception e) {
						matData.put("sapCode", "");
					}
					try{
						matData.put("productName", matItemName.get(i));
					} catch(Exception e) {
						matData.put("productName", "");
					}
					try{
						matData.put("compCount", matItemCompCount.get(i));
					} catch(Exception e) {
						matData.put("compCount", "");
					}
					try{
						matData.put("compUnit", matItemCompUnit.get(i));
					} catch(Exception e) {
						matData.put("compUnit", "");
					}
					try{
						matData.put("useCount", matItemUseCount.get(i));
					} catch(Exception e) {
						matData.put("useCount", "");
					}
					try{
						matData.put("useUnit", matItemUseUnit.get(i));
					} catch(Exception e) {
						matData.put("useUnit", "");
					}
					matList.add(matData);
				}
			}
			if( matList != null && matList.size() > 0 ) {
				recipeDao.insertRecipeMaterial(matList);
			}
			
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			if( newItemName != null && newItemName.size() > 0 ) {
			    for( int i = 0 ; i < newItemName.size() ; i++ ) {
			        HashMap<String,Object> newData = new HashMap<String,Object>();
			        newData.put("idx", recipeIdx);
			        newData.put("no", (i*10)+10);
			        try{
			            newData.put("name", newItemName.get(i));
			        } catch(Exception e) {
			            newData.put("name", "");
			        }
			        try{
			            newData.put("compCount", newItemCompCount.get(i));
			        } catch(Exception e) {
			            newData.put("compCount", "");
			        }
			        try{
			            newData.put("compUnit", newItemCompUnit.get(i));
			        } catch(Exception e) {
			            newData.put("compUnit", "");
			        }
			        try{
			            newData.put("useCount", newItemUseCount.get(i));
			        } catch(Exception e) {
			            newData.put("useCount", "");
			        }
			        try{
			            newData.put("useUnit", newItemUseUnit.get(i));
			        } catch(Exception e) {
			            newData.put("useUnit", "");
			        }
			        try{
			            newData.put("price", newItemPrice.get(i));
			        } catch(Exception e) {
			            newData.put("price", "");
			        }
			        try{
			            newData.put("desc", newItemDesc.get(i));
			        } catch(Exception e) {
			            newData.put("desc", "");
			        }

			        // ✅ 추가된 부분: 모든 값이 ""(빈값)이면 스킵
			        if ("".equals(newData.get("name"))
			            && "".equals(newData.get("compCount"))
			            && "".equals(newData.get("compUnit"))
			            && "".equals(newData.get("useCount"))
			            && "".equals(newData.get("useUnit"))
			            && "".equals(newData.get("price"))
			            && "".equals(newData.get("desc"))) {
			            continue;
			        }

			        newList.add(newData);
			    }
			}
			
			if( newList != null && newList.size() > 0 ) {
				recipeDao.insertRecipePurchase(newList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", recipeIdx);
			historyParam.put("docType", "RECIPE");
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
				String path = config.getProperty("upload.file.path.recipe");
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
							fileMap.put("docIdx", recipeIdx);
							fileMap.put("docType", "RECIPE");
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
			return recipeIdx;
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public int insertRecipe(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int recipeIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			JSONParser parser = new JSONParser();
			JSONArray matItemSapCode = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemSapCodeArr")));
			JSONArray matItemName = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemNameArr")));
			JSONArray matItemCompCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemCompCountArr")));
			JSONArray matItemCompUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemCompUnitArr")));
			JSONArray matItemUseCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemUseCountArr")));
			JSONArray matItemUseUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemUseUnitArr")));
			
			JSONArray newItemName = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemNameArr")));
			JSONArray newItemCompCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemCompCountArr")));
			JSONArray newItemCompUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemCompUnitArr")));
			JSONArray newItemUseCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemUseCountArr")));
			JSONArray newItemUseUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemUseUnitArr")));
			JSONArray newItemPrice = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemPriceArr")));
			JSONArray newItemDesc = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemDescArr")));
			
			ArrayList<String> fileType = (ArrayList<String>)param.get("fileType");
			
			recipeIdx = recipeDao.selectRecipeSeq(); 	//key value 조
			param.put("idx", recipeIdx);
			
			recipeDao.insertRecipe(param);
			
			ArrayList<HashMap<String,Object>> matList = new ArrayList<HashMap<String,Object>>();
			if( matItemSapCode != null && matItemSapCode.size() > 0 ) {
				for( int i = 0 ; i < matItemSapCode.size() ; i++ ) {
					HashMap<String,Object> matData = new HashMap<String,Object>();
					matData.put("idx", recipeIdx);
					matData.put("no", (i*10)+10);
					try{
						matData.put("sapCode", matItemSapCode.get(i));
					} catch(Exception e) {
						matData.put("sapCode", "");
					}
					try{
						matData.put("productName", matItemName.get(i));
					} catch(Exception e) {
						matData.put("productName", "");
					}
					try{
						matData.put("compCount", matItemCompCount.get(i));
					} catch(Exception e) {
						matData.put("compCount", "");
					}
					try{
						matData.put("compUnit", matItemCompUnit.get(i));
					} catch(Exception e) {
						matData.put("compUnit", "");
					}
					try{
						matData.put("useCount", matItemUseCount.get(i));
					} catch(Exception e) {
						matData.put("useCount", "");
					}
					try{
						matData.put("useUnit", matItemUseUnit.get(i));
					} catch(Exception e) {
						matData.put("useUnit", "");
					}
					matList.add(matData);
				}
			}
			if( matList != null && matList.size() > 0 ) {
				recipeDao.insertRecipeMaterial(matList);
			}
			
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			if( newItemName != null && newItemName.size() > 0 ) {
				for( int i = 0 ; i < newItemName.size() ; i++ ) {
					HashMap<String,Object> newData = new HashMap<String,Object>();
					newData.put("idx", recipeIdx);
					newData.put("no", (i*10)+10);
					try{
						newData.put("name", newItemName.get(i));
					} catch(Exception e) {
						newData.put("name", "");
					}
					try{
						newData.put("compCount", newItemCompCount.get(i));
					} catch(Exception e) {
						newData.put("compCount", "");
					}
					try{
						newData.put("compUnit", newItemCompUnit.get(i));
					} catch(Exception e) {
						newData.put("compUnit", "");
					}
					try{
						newData.put("useCount", newItemUseCount.get(i));
					} catch(Exception e) {
						newData.put("useCount", "");
					}
					try{
						newData.put("useUnit", newItemUseUnit.get(i));
					} catch(Exception e) {
						newData.put("useUnit", "");
					}
					try{
						newData.put("price", newItemPrice.get(i));
					} catch(Exception e) {
						newData.put("price", "");
					}
					try{
						newData.put("desc", newItemDesc.get(i));
					} catch(Exception e) {
						newData.put("desc", "");
					}
					
					// ✅ 추가된 부분: 모든 값이 ""(빈값)이면 스킵
			        if ("".equals(newData.get("name"))
			            && "".equals(newData.get("compCount"))
			            && "".equals(newData.get("compUnit"))
			            && "".equals(newData.get("useCount"))
			            && "".equals(newData.get("useUnit"))
			            && "".equals(newData.get("price"))
			            && "".equals(newData.get("desc"))) {
			            continue;
			        }
			        
					newList.add(newData);
				}
			}
			
			if( newList != null && newList.size() > 0 ) {
				recipeDao.insertRecipePurchase(newList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", recipeIdx);
			historyParam.put("docType", "RECIPE");
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
				String path = config.getProperty("upload.file.path.recipe");
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
							fileMap.put("docIdx", recipeIdx);
							fileMap.put("docType", "RECIPE");
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
			return recipeIdx;
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return recipeDao.selectHistory(param);
	}

	@Override
	public int selectMyDataCheck(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return recipeDao.selectMyDataCheck(param);
	}

	@Override
	public Map<String, Object> selectRecipeData(Map<String, Object> param) {
		// TODO Auto-generated method stub	
		Map<String, Object> data = recipeDao.selectRecipeData(param);
		param.put("docType", "RECIPE");
		List<Map<String, String>> fileList = commonDao.selectFileList(param);
		data.put("fileList", fileList);
		return data;

	}

	@Override
	public List<Map<String, Object>> selectMaterialList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return recipeDao.selectMaterialList(param);
	}

	@Override
	public List<Map<String, Object>> selectPurchaseList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return recipeDao.selectPurchaseList(param);
	}

	@Override
	public void updateTmpRecipe(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			JSONParser parser = new JSONParser();
			JSONArray matItemSapCode = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemSapCodeArr")));
			JSONArray matItemName = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemNameArr")));
			JSONArray matItemCompCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemCompCountArr")));
			JSONArray matItemCompUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemCompUnitArr")));
			JSONArray matItemUseCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemUseCountArr")));
			JSONArray matItemUseUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemUseUnitArr")));
			
			JSONArray newItemName = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemNameArr")));
			JSONArray newItemCompCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemCompCountArr")));
			JSONArray newItemCompUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemCompUnitArr")));
			JSONArray newItemUseCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemUseCountArr")));
			JSONArray newItemUseUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemUseUnitArr")));
			JSONArray newItemPrice = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemPriceArr")));
			JSONArray newItemDesc = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemDescArr")));
			
			JSONArray deletedFileIdArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("deletedFileIdArr")));
			JSONArray deletedFileArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("deletedFileArr")));
			JSONArray deletedFilePathArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("deletedFilePathArr")));
			
			ArrayList<String> fileType = (ArrayList<String>)param.get("fileType");
			
			recipeDao.updateRecipe(param);
			
			recipeDao.deleteRecipeMaterial(param);
			ArrayList<HashMap<String,Object>> matList = new ArrayList<HashMap<String,Object>>();
			if( matItemSapCode != null && matItemSapCode.size() > 0 ) {
				for( int i = 0 ; i < matItemSapCode.size() ; i++ ) {
					HashMap<String,Object> matData = new HashMap<String,Object>();
					matData.put("idx", param.get("idx"));
					matData.put("no", (i*10)+10);
					try{
						matData.put("sapCode", matItemSapCode.get(i));
					} catch(Exception e) {
						matData.put("sapCode", "");
					}
					try{
						matData.put("productName", matItemName.get(i));
					} catch(Exception e) {
						matData.put("productName", "");
					}
					try{
						matData.put("compCount", matItemCompCount.get(i));
					} catch(Exception e) {
						matData.put("compCount", "");
					}
					try{
						matData.put("compUnit", matItemCompUnit.get(i));
					} catch(Exception e) {
						matData.put("compUnit", "");
					}
					try{
						matData.put("useCount", matItemUseCount.get(i));
					} catch(Exception e) {
						matData.put("useCount", "");
					}
					try{
						matData.put("useUnit", matItemUseUnit.get(i));
					} catch(Exception e) {
						matData.put("useUnit", "");
					}
					matList.add(matData);
				}
			}
			if( matList != null && matList.size() > 0 ) {
				recipeDao.insertRecipeMaterial(matList);
			}
			
			recipeDao.deleteRecipePurchase(param);
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			if( newItemName != null && newItemName.size() > 0 ) {
				for( int i = 0 ; i < newItemName.size() ; i++ ) {
					HashMap<String,Object> newData = new HashMap<String,Object>();
					newData.put("idx", param.get("idx"));
					newData.put("no", (i*10)+10);
					try{
						newData.put("name", newItemName.get(i));
					} catch(Exception e) {
						newData.put("name", "");
					}
					try{
						newData.put("compCount", newItemCompCount.get(i));
					} catch(Exception e) {
						newData.put("compCount", "");
					}
					try{
						newData.put("compUnit", newItemCompUnit.get(i));
					} catch(Exception e) {
						newData.put("compUnit", "");
					}
					try{
						newData.put("useCount", newItemUseCount.get(i));
					} catch(Exception e) {
						newData.put("useCount", "");
					}
					try{
						newData.put("useUnit", newItemUseUnit.get(i));
					} catch(Exception e) {
						newData.put("useUnit", "");
					}
					try{
						newData.put("price", newItemPrice.get(i));
					} catch(Exception e) {
						newData.put("price", "");
					}
					try{
						newData.put("desc", newItemDesc.get(i));
					} catch(Exception e) {
						newData.put("desc", "");
					}
					
					// ✅ 추가된 부분: 모든 값이 ""(빈값)이면 스킵
			        if ("".equals(newData.get("name"))
			            && "".equals(newData.get("compCount"))
			            && "".equals(newData.get("compUnit"))
			            && "".equals(newData.get("useCount"))
			            && "".equals(newData.get("useUnit"))
			            && "".equals(newData.get("price"))
			            && "".equals(newData.get("desc"))) {
			            continue;
			        }
			        
					newList.add(newData);
				}
			}
			
			if( newList != null && newList.size() > 0 ) {
				recipeDao.insertRecipePurchase(newList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", param.get("idx"));
			historyParam.put("docType", "RECIPE");
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
		        String path = config.getProperty("upload.file.path.recipe");
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
							fileMap.put("docIdx", param.get("idx"));
							fileMap.put("docType", "RECIPE");
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
	}

	@Override
	public void updateRecipe(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			JSONParser parser = new JSONParser();
			JSONArray matItemSapCode = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemSapCodeArr")));
			JSONArray matItemName = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemNameArr")));
			JSONArray matItemCompCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemCompCountArr")));
			JSONArray matItemCompUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemCompUnitArr")));
			JSONArray matItemUseCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemUseCountArr")));
			JSONArray matItemUseUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemUseUnitArr")));
			
			JSONArray newItemName = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemNameArr")));
			JSONArray newItemCompCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemCompCountArr")));
			JSONArray newItemCompUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemCompUnitArr")));
			JSONArray newItemUseCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemUseCountArr")));
			JSONArray newItemUseUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemUseUnitArr")));
			JSONArray newItemPrice = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemPriceArr")));
			JSONArray newItemDesc = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemDescArr")));
			
			JSONArray deletedFileIdArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("deletedFileIdArr")));
			JSONArray deletedFileArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("deletedFileArr")));
			JSONArray deletedFilePathArr = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("deletedFilePathArr")));
			
			ArrayList<String> fileType = (ArrayList<String>)param.get("fileType");
			
			recipeDao.updateRecipe(param);
			
			recipeDao.deleteRecipeMaterial(param);
			ArrayList<HashMap<String,Object>> matList = new ArrayList<HashMap<String,Object>>();
			if( matItemSapCode != null && matItemSapCode.size() > 0 ) {
				for( int i = 0 ; i < matItemSapCode.size() ; i++ ) {
					HashMap<String,Object> matData = new HashMap<String,Object>();
					matData.put("idx", param.get("idx"));
					matData.put("no", (i*10)+10);
					try{
						matData.put("sapCode", matItemSapCode.get(i));
					} catch(Exception e) {
						matData.put("sapCode", "");
					}
					try{
						matData.put("productName", matItemName.get(i));
					} catch(Exception e) {
						matData.put("productName", "");
					}
					try{
						matData.put("compCount", matItemCompCount.get(i));
					} catch(Exception e) {
						matData.put("compCount", "");
					}
					try{
						matData.put("compUnit", matItemCompUnit.get(i));
					} catch(Exception e) {
						matData.put("compUnit", "");
					}
					try{
						matData.put("useCount", matItemUseCount.get(i));
					} catch(Exception e) {
						matData.put("useCount", "");
					}
					try{
						matData.put("useUnit", matItemUseUnit.get(i));
					} catch(Exception e) {
						matData.put("useUnit", "");
					}
					matList.add(matData);
				}
			}
			if( matList != null && matList.size() > 0 ) {
				recipeDao.insertRecipeMaterial(matList);
			}
			
			recipeDao.deleteRecipePurchase(param);
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			if( newItemName != null && newItemName.size() > 0 ) {
				for( int i = 0 ; i < newItemName.size() ; i++ ) {
					HashMap<String,Object> newData = new HashMap<String,Object>();
					newData.put("idx", param.get("idx"));
					newData.put("no", (i*10)+10);
					try{
						newData.put("name", newItemName.get(i));
					} catch(Exception e) {
						newData.put("name", "");
					}
					try{
						newData.put("compCount", newItemCompCount.get(i));
					} catch(Exception e) {
						newData.put("compCount", "");
					}
					try{
						newData.put("compUnit", newItemCompUnit.get(i));
					} catch(Exception e) {
						newData.put("compUnit", "");
					}
					try{
						newData.put("useCount", newItemUseCount.get(i));
					} catch(Exception e) {
						newData.put("useCount", "");
					}
					try{
						newData.put("useUnit", newItemUseUnit.get(i));
					} catch(Exception e) {
						newData.put("useUnit", "");
					}
					try{
						newData.put("price", newItemPrice.get(i));
					} catch(Exception e) {
						newData.put("price", "");
					}
					try{
						newData.put("desc", newItemDesc.get(i));
					} catch(Exception e) {
						newData.put("desc", "");
					}
					
					// ✅ 추가된 부분: 모든 값이 ""(빈값)이면 스킵
			        if ("".equals(newData.get("name"))
			            && "".equals(newData.get("compCount"))
			            && "".equals(newData.get("compUnit"))
			            && "".equals(newData.get("useCount"))
			            && "".equals(newData.get("useUnit"))
			            && "".equals(newData.get("price"))
			            && "".equals(newData.get("desc"))) {
			            continue;
			        }
					
					newList.add(newData);
				}
			}
			
			if( newList != null && newList.size() > 0 ) {
				recipeDao.insertRecipePurchase(newList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", param.get("idx"));
			historyParam.put("docType", "RECIPE");
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
		        String path = config.getProperty("upload.file.path.recipe");
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
							fileMap.put("docIdx", param.get("idx"));
							fileMap.put("docType", "RECIPE");
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
	}

	@Override
	public Map<String, Object> insertErp(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> returnMap = new HashMap<String, Object>();
		try {
			Map<String, Object> recipeData = recipeDao.selectRecipeData(param);
			//2.lab_recipe_material 조회
			List<Map<String, Object>> materialList = recipeDao.selectMaterialList(param);
			//3.lab_recipe_purchase
			List<Map<String, Object>> purchaseList = recipeDao.selectPurchaseList(param);
			
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("recipeData", recipeData);
			paramMap.put("materialList", materialList);
			paramMap.put("purchaseList", purchaseList);
			
			recipeDao.insertErp(paramMap);
		} catch( Exception e ) {
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE","ERP 반영오류가 발생했습니다.");
		}
		
		return returnMap;
	}

	@Override
	public int versionUpTmpRecipe(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int recipeIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			JSONParser parser = new JSONParser();
			JSONArray matItemSapCode = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemSapCodeArr")));
			JSONArray matItemName = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemNameArr")));
			JSONArray matItemCompCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemCompCountArr")));
			JSONArray matItemCompUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemCompUnitArr")));
			JSONArray matItemUseCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemUseCountArr")));
			JSONArray matItemUseUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemUseUnitArr")));
			
			JSONArray newItemName = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemNameArr")));
			JSONArray newItemCompCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemCompCountArr")));
			JSONArray newItemCompUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemCompUnitArr")));
			JSONArray newItemUseCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemUseCountArr")));
			JSONArray newItemUseUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemUseUnitArr")));
			JSONArray newItemPrice = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemPriceArr")));
			JSONArray newItemDesc = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemDescArr")));
			
			ArrayList<String> fileType = (ArrayList<String>)param.get("fileType");
			ArrayList<String> tempFile = (ArrayList<String>)param.get("tempFile");
			
			recipeDao.updateRecipeIsLast(param);
			
			recipeIdx = recipeDao.selectRecipeSeq(); 	//key value 조
			param.put("idx", recipeIdx);
			
			recipeDao.insertVersionUpRecipe(param);
			
			ArrayList<HashMap<String,Object>> matList = new ArrayList<HashMap<String,Object>>();
			if( matItemSapCode != null && matItemSapCode.size() > 0 ) {
				for( int i = 0 ; i < matItemSapCode.size() ; i++ ) {
					HashMap<String,Object> matData = new HashMap<String,Object>();
					matData.put("idx", recipeIdx);
					matData.put("no", (i*10)+10);
					try{
						matData.put("sapCode", matItemSapCode.get(i));
					} catch(Exception e) {
						matData.put("sapCode", "");
					}
					try{
						matData.put("productName", matItemName.get(i));
					} catch(Exception e) {
						matData.put("productName", "");
					}
					try{
						matData.put("compCount", matItemCompCount.get(i));
					} catch(Exception e) {
						matData.put("compCount", "");
					}
					try{
						matData.put("compUnit", matItemCompUnit.get(i));
					} catch(Exception e) {
						matData.put("compUnit", "");
					}
					try{
						matData.put("useCount", matItemUseCount.get(i));
					} catch(Exception e) {
						matData.put("useCount", "");
					}
					try{
						matData.put("useUnit", matItemUseUnit.get(i));
					} catch(Exception e) {
						matData.put("useUnit", "");
					}
					matList.add(matData);
				}
			}
			if( matList != null && matList.size() > 0 ) {
				recipeDao.insertRecipeMaterial(matList);
			}
			
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			if( newItemName != null && newItemName.size() > 0 ) {
				for( int i = 0 ; i < newItemName.size() ; i++ ) {
					HashMap<String,Object> newData = new HashMap<String,Object>();
					newData.put("idx", recipeIdx);
					newData.put("no", (i*10)+10);
					try{
						newData.put("name", newItemName.get(i));
					} catch(Exception e) {
						newData.put("name", "");
					}
					try{
						newData.put("compCount", newItemCompCount.get(i));
					} catch(Exception e) {
						newData.put("compCount", "");
					}
					try{
						newData.put("compUnit", newItemCompUnit.get(i));
					} catch(Exception e) {
						newData.put("compUnit", "");
					}
					try{
						newData.put("useCount", newItemUseCount.get(i));
					} catch(Exception e) {
						newData.put("useCount", "");
					}
					try{
						newData.put("useUnit", newItemUseUnit.get(i));
					} catch(Exception e) {
						newData.put("useUnit", "");
					}
					try{
						newData.put("price", newItemPrice.get(i));
					} catch(Exception e) {
						newData.put("price", "");
					}
					try{
						newData.put("desc", newItemDesc.get(i));
					} catch(Exception e) {
						newData.put("desc", "");
					}
					
					// ✅ 추가된 부분: 모든 값이 ""(빈값)이면 스킵
			        if ("".equals(newData.get("name"))
			            && "".equals(newData.get("compCount"))
			            && "".equals(newData.get("compUnit"))
			            && "".equals(newData.get("useCount"))
			            && "".equals(newData.get("useUnit"))
			            && "".equals(newData.get("price"))
			            && "".equals(newData.get("desc"))) {
			            continue;
			        }
					
					newList.add(newData);
				}
			}
			
			if( newList != null && newList.size() > 0 ) {
				recipeDao.insertRecipePurchase(newList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", recipeIdx);
			historyParam.put("docType", "RECIPE");
			historyParam.put("historyType", "V");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			String path = config.getProperty("upload.file.path.recipe");
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
	        path += File.separator+toDay; 
	        
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
								fileMap.put("docIdx", recipeIdx);
								fileMap.put("docType", "RECIPE");
								fileMap.put("fileType", "00");
								fileMap.put("orgFileName", orgFileName);
								fileMap.put("filePath", path);
								fileMap.put("changeFileName", newFileName);
								fileMap.put("content", fileContents);
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
					try {
						if( !multipartFile.isEmpty() ) {
							String fileIdx = FileUtil.getUUID();
							String result = FileUtil.upload3(multipartFile,path,fileIdx);
							String content = FileUtil.getPdfContents(path, result);
							Map<String,Object> fileMap = new HashMap<String,Object>();
							fileMap.put("fileIdx", fileIdx);
							fileMap.put("docIdx", recipeIdx);
							fileMap.put("docType", "RECIPE");
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
			return recipeIdx;
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public int versionUpRecipe(Map<String, Object> param, MultipartFile[] file) throws Exception {
		// TODO Auto-generated method stub
		int recipeIdx = 0;
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			JSONParser parser = new JSONParser();
			JSONArray matItemSapCode = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemSapCodeArr")));
			JSONArray matItemName = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemNameArr")));
			JSONArray matItemCompCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemCompCountArr")));
			JSONArray matItemCompUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemCompUnitArr")));
			JSONArray matItemUseCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemUseCountArr")));
			JSONArray matItemUseUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("matItemUseUnitArr")));
			
			JSONArray newItemName = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemNameArr")));
			JSONArray newItemCompCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemCompCountArr")));
			JSONArray newItemCompUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemCompUnitArr")));
			JSONArray newItemUseCount = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemUseCountArr")));
			JSONArray newItemUseUnit = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemUseUnitArr")));
			JSONArray newItemPrice = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemPriceArr")));
			JSONArray newItemDesc = (JSONArray) parser.parse(StringEscapeUtils.unescapeHtml4((String)param.get("newItemDescArr")));
			
			ArrayList<String> fileType = (ArrayList<String>)param.get("fileType");
			ArrayList<String> tempFile = (ArrayList<String>)param.get("tempFile");
			
			recipeDao.updateRecipeIsLast(param);
			
			recipeIdx = recipeDao.selectRecipeSeq(); 	//key value 조
			param.put("idx", recipeIdx);
			
			recipeDao.insertVersionUpRecipe(param);
			
			ArrayList<HashMap<String,Object>> matList = new ArrayList<HashMap<String,Object>>();
			if( matItemSapCode != null && matItemSapCode.size() > 0 ) {
				for( int i = 0 ; i < matItemSapCode.size() ; i++ ) {
					HashMap<String,Object> matData = new HashMap<String,Object>();
					matData.put("idx", recipeIdx);
					matData.put("no", (i*10)+10);
					try{
						matData.put("sapCode", matItemSapCode.get(i));
					} catch(Exception e) {
						matData.put("sapCode", "");
					}
					try{
						matData.put("productName", matItemName.get(i));
					} catch(Exception e) {
						matData.put("productName", "");
					}
					try{
						matData.put("compCount", matItemCompCount.get(i));
					} catch(Exception e) {
						matData.put("compCount", "");
					}
					try{
						matData.put("compUnit", matItemCompUnit.get(i));
					} catch(Exception e) {
						matData.put("compUnit", "");
					}
					try{
						matData.put("useCount", matItemUseCount.get(i));
					} catch(Exception e) {
						matData.put("useCount", "");
					}
					try{
						matData.put("useUnit", matItemUseUnit.get(i));
					} catch(Exception e) {
						matData.put("useUnit", "");
					}
					matList.add(matData);
				}
			}
			if( matList != null && matList.size() > 0 ) {
				recipeDao.insertRecipeMaterial(matList);
			}
			
			ArrayList<HashMap<String,Object>> newList = new ArrayList<HashMap<String,Object>>();
			if( newItemName != null && newItemName.size() > 0 ) {
				for( int i = 0 ; i < newItemName.size() ; i++ ) {
					HashMap<String,Object> newData = new HashMap<String,Object>();
					newData.put("idx", recipeIdx);
					newData.put("no", (i*10)+10);
					try{
						newData.put("name", newItemName.get(i));
					} catch(Exception e) {
						newData.put("name", "");
					}
					try{
						newData.put("compCount", newItemCompCount.get(i));
					} catch(Exception e) {
						newData.put("compCount", "");
					}
					try{
						newData.put("compUnit", newItemCompUnit.get(i));
					} catch(Exception e) {
						newData.put("compUnit", "");
					}
					try{
						newData.put("useCount", newItemUseCount.get(i));
					} catch(Exception e) {
						newData.put("useCount", "");
					}
					try{
						newData.put("useUnit", newItemUseUnit.get(i));
					} catch(Exception e) {
						newData.put("useUnit", "");
					}
					try{
						newData.put("price", newItemPrice.get(i));
					} catch(Exception e) {
						newData.put("price", "");
					}
					try{
						newData.put("desc", newItemDesc.get(i));
					} catch(Exception e) {
						newData.put("desc", "");
					}
					
					// ✅ 추가된 부분: 모든 값이 ""(빈값)이면 스킵
			        if ("".equals(newData.get("name"))
			            && "".equals(newData.get("compCount"))
			            && "".equals(newData.get("compUnit"))
			            && "".equals(newData.get("useCount"))
			            && "".equals(newData.get("useUnit"))
			            && "".equals(newData.get("price"))
			            && "".equals(newData.get("desc"))) {
			            continue;
			        }
					
					newList.add(newData);
				}
			}
			
			if( newList != null && newList.size() > 0 ) {
				recipeDao.insertRecipePurchase(newList);
			}
			
			//history 저장
			Map<String, Object> historyParam = new HashMap<String, Object>();
			historyParam.put("docIdx", recipeIdx);
			historyParam.put("docType", "RECIPE");
			historyParam.put("historyType", "V");
			historyParam.put("historyData", param.toString());
			historyParam.put("userId", param.get("userId"));
			commonDao.insertHistory(historyParam);
			
			String path = config.getProperty("upload.file.path.recipe");
			Calendar cal = Calendar.getInstance();
	        Date day = cal.getTime();    //시간을 꺼낸다.
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String toDay = sdf.format(day);
	        path += File.separator+toDay; 
	        
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
								fileMap.put("docIdx", recipeIdx);
								fileMap.put("docType", "RECIPE");
								fileMap.put("fileType", "00");
								fileMap.put("orgFileName", orgFileName);
								fileMap.put("filePath", path);
								fileMap.put("changeFileName", newFileName);
								fileMap.put("content", fileContents);
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
					try {
						if( !multipartFile.isEmpty() ) {
							String fileIdx = FileUtil.getUUID();
							String result = FileUtil.upload3(multipartFile,path,fileIdx);
							String content = FileUtil.getPdfContents(path, result);
							Map<String,Object> fileMap = new HashMap<String,Object>();
							fileMap.put("fileIdx", fileIdx);
							fileMap.put("docIdx", recipeIdx);
							fileMap.put("docType", "RECIPE");
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
			return recipeIdx;
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public Map<String, Object> applyErp(Map<String, Object> param) {
		// TODO Auto-generated method stub
		Map<String, Object> returnMap = new HashMap<String, Object>();
		//1.lab_recipe 
		Map<String, Object> recipeData = recipeDao.selectRecipeData(param);
		//2.lab_recipe_material 조회
		List<Map<String, Object>> materialList = recipeDao.selectMaterialList(param);
		//3.lab_recipe_purchase
		List<Map<String, Object>> purchaseList = recipeDao.selectPurchaseList(param);
		
		List<Map<String, Object>> erpItemList = new ArrayList<Map<String, Object>>();
		
		//for (Map<String, Object> materialItem : materialList) {
		for ( int i = 0 ; i < materialList.size() ; i++ ) {
			Map<String, Object> materialItem = materialList.get(i);
			
			HashMap<String, Object> erpDataMap = new HashMap<String, Object>();
			erpDataMap.put("MATNR", recipeData.get("PRODUCT_CODE"));	//매장 메뉴 코드
			erpDataMap.put("MAKTX", recipeData.get("PRODUCT_NAME"));	//매장 메뉴 코드명
			erpDataMap.put("WERKS", recipeData.get("PLANT"));			//플랜트
			erpDataMap.put("MENGE", recipeData.get("PRODUCT_COUNT"));	//품목수량
			erpDataMap.put("MEINS", recipeData.get("PRODUCT_UNIT"));			//기본단위
			erpDataMap.put("RCNUM", (i*10)+10);	//구성품번호(10부터 + 10씩 증가)
			erpDataMap.put("LMATNR", materialItem.get("SAP_CODE"));	//구성품목코드
			erpDataMap.put("LMAKTX", materialItem.get("ITEM_NAME"));	//구성품목명
			erpDataMap.put("UMREN", materialItem.get("ITEM_COUNT"));	//레시피수량
			erpDataMap.put("RCMEI", materialItem.get("ITEM_UNIT").toString().toUpperCase());	//레시피단위
			erpDataMap.put("LMENGE", materialItem.get("USED_COUNT"));	//사용량
			erpDataMap.put("LMEINS", materialItem.get("USED_UNIT").toString().toUpperCase());	//사용량단위
			erpDataMap.put("POGB", "본사");		//구성품 구매형태 구분 (본사 / 직사입)
			erpDataMap.put("NETPR", "");		//레시피수량 별 단가
			
			erpItemList.add(erpDataMap);
		}
		
		for( int i = 0 ; i < purchaseList.size() ; i++ ) {
			Map<String, Object> purchaseItem = purchaseList.get(i);
			
			HashMap<String, Object> erpDataMap = new HashMap<String, Object>();
			
			erpDataMap.put("MATNR", recipeData.get("PRODUCT_CODE"));	//매장 메뉴 코드
			erpDataMap.put("MAKTX", recipeData.get("PRODUCT_NAME"));	//매장 메뉴 코드명
			erpDataMap.put("WERKS", recipeData.get("PLANT"));			//플랜트
			erpDataMap.put("MENGE", recipeData.get("PRODUCT_COUNT"));	//품목수량
			erpDataMap.put("MEINS", recipeData.get("PRODUCT_UNIT"));			//기본단위
			erpDataMap.put("RCNUM", (i*10)+10+(materialList.size()*10));//구성품번호(10부터 + 10씩 증가)
			erpDataMap.put("LMATNR", "");	//구성품목코드
			erpDataMap.put("LMAKTX", purchaseItem.get("ITEM_NAME"));	//구성품목명
			erpDataMap.put("UMREN", purchaseItem.get("ITEM_COUNT"));	//레시피수량
			erpDataMap.put("RCMEI", purchaseItem.get("ITEM_UNIT").toString().toUpperCase());	//레시피단위
			erpDataMap.put("LMENGE", purchaseItem.get("USED_COUNT"));	//사용량
			erpDataMap.put("LMEINS", purchaseItem.get("USED_UNIT").toString().toUpperCase());	//사용량단위
			erpDataMap.put("POGB", "직사입");		//구성품 구매형태 구분 (본사 / 직사입)
			erpDataMap.put("NETPR", purchaseItem.get("ITEM_PRICE"));		//레시피수량 별 단가
			
			erpItemList.add(erpDataMap);
		}
		
		HashMap<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("idx", recipeData.get("RECIPE_IDX"));
		if( erpItemList.size() > 0 ) {
			try {
				returnMap = recipeDao.applyErp(erpItemList);	//ERP 반영
				if( returnMap != null && "S".equals((String)returnMap.get("RESULT"))) {
					//반영 결과 업데이트.
					paramMap.put("status", "BOM");
					paramMap.put("message", "정상처리 되었습니다.");
				} else {
					//반영 결과 업데이트.
					paramMap.put("status", "BOM_ERROR");
					paramMap.put("message", returnMap.get("MESSAGE"));
				}				
			} catch( Exception e ) {
				returnMap.put("RESULT", "E");
				returnMap.put("MESSAGE", "ERP 반영 오류가 발생했습니다.");
				paramMap.put("status", "BOM_ERROR");
				paramMap.put("message", "ERP 반영 오류가 발생했습니다."+e.getMessage());
			}			
		} else {
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE", "ERP 반영 데이터가 없습니다.");
			paramMap.put("status", "BOM_ERROR");
			paramMap.put("message", "ERP 반영 데이터가 없습니다.");
		}
		
		recipeDao.updateStatus(paramMap);
		
		return returnMap;
	}
	
	@Override
	public Map<String, Object> selectRecipeErpMaterialList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = recipeDao.selectRecipeErpMaterialCount(param);
		
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
			pageNo = 1;
		}
		
		//int startRow = (pageNo-1)*viewCount+1;
		//int endRow = pageNo*viewCount;
		
		//param.put("startRow", startRow);
		//param.put("endRow", endRow);
		
		// 페이징: 페이징 정보 SET
		PageNavigator navi = new PageNavigator(param, viewCount, totalCount);
		
		List<Map<String, Object>> materialList = recipeDao.selectRecipeErpMaterialList(param);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", materialList);		
		map.put("navi", navi);
		
		return map;
	}

}
