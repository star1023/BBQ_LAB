package kr.co.genesiskorea.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;

import kr.co.genesiskorea.controller.ApprovalController;
import kr.co.genesiskorea.dao.ApprovalDao;
import kr.co.genesiskorea.dao.BusinessTripDao;
import kr.co.genesiskorea.dao.BusinessTripPlanDao;
import kr.co.genesiskorea.dao.ChemicalTestDao;
import kr.co.genesiskorea.dao.DesignReportDao;
import kr.co.genesiskorea.dao.ManualDao;
import kr.co.genesiskorea.dao.MarketResearchDao;
import kr.co.genesiskorea.dao.MenuDao;
import kr.co.genesiskorea.dao.NewProductResultDao;
import kr.co.genesiskorea.dao.PackageInfoDao;
import kr.co.genesiskorea.dao.ProductDao;
import kr.co.genesiskorea.dao.SenseQualityDao;
import kr.co.genesiskorea.service.ApprovalService;
import kr.co.genesiskorea.service.BusinessTripPlanService;
import kr.co.genesiskorea.service.BusinessTripService;
import kr.co.genesiskorea.service.CommonService;
import kr.co.genesiskorea.service.DesignReportService;
import kr.co.genesiskorea.service.MarketResearchService;
import kr.co.genesiskorea.service.PackageInfoService;
import kr.co.genesiskorea.service.SenseQualityService;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class ApprovalServiceImpl implements ApprovalService {
	private Logger logger = LogManager.getLogger(ApprovalServiceImpl.class);
	
	@Autowired
	ApprovalDao approvalDao;
	
	@Autowired
	ManualDao manualDao;
	
	@Autowired
	ProductDao productDao;
	
	@Autowired
	MenuDao menuDao;
	
	@Autowired
	DesignReportDao designReportDao;
	
	@Autowired
	BusinessTripPlanDao businessTripPlanDao;
	
	@Autowired
	BusinessTripDao businessTripDao;
	
	@Autowired
	MarketResearchDao marketResearchDao;
	
	@Autowired
	SenseQualityDao senseQualityDao;
	
	@Autowired
	PackageInfoDao packageInfoDao;
	
	@Autowired
	NewProductResultDao newProductResultDao;
	
	@Autowired
	ChemicalTestDao chemicalTestDao;
	
	@Autowired
	CommonService commonService;
	
	@Resource
	DataSourceTransactionManager txManager;
	
	
	
	@Override
	public List<Map<String, Object>> searchUser(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return approvalDao.searchUser(param);
	}

	@Override
	@Transactional
	public void insertApprLine(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			//5.line idx 조회
			int lineIdx = approvalDao.selectLineSeq(); 	//key value 조회
			//6.line header 저장
			param.put("lineIdx", lineIdx);
			approvalDao.insertApprLine(param);
			//7.line item 저장
			approvalDao.insertApprLineItem(param);
			
			txManager.commit(status);
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}

	@Override
	public List<Map<String, Object>> selectApprovalLine(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return approvalDao.selectApprovalLine(param);
	}

	@Override
	public List<Map<String, Object>> selectApprovalLineItem(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return approvalDao.selectApprovalLineItem(param);
	}

	@Override
	public void deleteApprLine(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		approvalDao.deleteApprLine(param);
	}

	@Override
	public void insertAppr(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			//1.기존에 결재중인 결재데이터가 있는 경우 삭제처리 한다.
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("docIdx", param.get("docIdx"));
			paramMap.put("docType", param.get("docType"));
			paramMap.put("lastStatus", "C");
			Map<String, Object> headerData = approvalDao.selectApprHeaderData(paramMap);
			if( headerData != null && !"".equals(headerData.get("APPR_IDX")) ) {
				//기존 결재 정보를 삭제한다.
				//2.결재 아이템을 삭제한다.
				approvalDao.deleteApprItem(headerData);
				//3.결재 헤더를 삭제한다.
				approvalDao.deleteApprHeader(headerData);
				//4.참조 데이터를 삭제한다.
				approvalDao.deleteApprReference(headerData);
			}
			//5. appr idx를 조회한다.
			int APPR_IDX = approvalDao.selectApprSeq();
			param.put("apprIdx", APPR_IDX);		
			ArrayList<String> apprLine = (ArrayList<String>)param.get("apprLine");
			ArrayList<String> refLine = (ArrayList<String>)param.get("refLine");
			param.put("totalStep", apprLine.size());
			param.put("currentStep", 1);
			param.put("currentUser", apprLine.get(0));
			
			System.err.println(param);
			//6. appr header를 저장한다.
			approvalDao.insertApprHeader(param);
			//7. appr item을 저장한다.
			approvalDao.insertApprItem(param);
			//8. arrp ref를 저장한다.
			if( refLine != null && refLine.size() > 0 ) {
				approvalDao.insertReference(param);
			}
			//9. 문서 상태를 REG에서 APPR로 변경한다.
			param.put("docStatus", "APPR");
			approvalDao.updateDocStatus(param);
			//10. 메일발송 및 알람등을 처리한다.
			//첫번째 담당자(apprLine.get(0)) 에게 알림을 발송한다.
			//param.get("docType"), param.get("docIdx"),param.get("title")
			HashMap<String, Object> notiMap = new HashMap<String, Object>();
			notiMap.put("targetUser", apprLine.get(0));
			notiMap.put("type", "A");
			notiMap.put("typeTxt", "결재알림");
			notiMap.put("message", "결재 요청이 도착했습니다.");
			notiMap.put("userId", param.get("userId"));
			notiMap.put("docIdx", param.get("docIdx"));
			notiMap.put("docType", param.get("docType"));
			commonService.notification(notiMap);
			
			txManager.commit(status);
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	}
	
	@Override
	public Map<String, Object> selectList(Map<String, Object> param) throws Exception{
		// TODO Auto-generated method stub
		int totalCount = approvalDao.selectTotalCount(param);
		
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
		
		List<Map<String, Object>> apprList = approvalDao.selectApprovalList(param);
				
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", apprList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	public Map<String, Object> selectMyApprList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		System.err.println(param);
		int totalCount = approvalDao.selectMyApprTotalCount(param);
		
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
		
		List<Map<String, Object>> apprList = approvalDao.selectMyApprList(param);
				
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", apprList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	public Map<String, Object> selectMyRefList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		System.err.println(param);
		int totalCount = approvalDao.selectMyRefTotalCount(param);
		
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
		
		List<Map<String, Object>> apprList = approvalDao.selectMyRefList(param);
				
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", apprList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	public Map<String, Object> selectMyCompList(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		System.err.println(param);
		int totalCount = approvalDao.selectMyCompTotalCount(param);
		
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
		
		List<Map<String, Object>> apprList = approvalDao.selectMyCompList(param);
				
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("pageNo", pageNo);
		map.put("totalCount", totalCount);
		map.put("list", apprList);	
		map.put("navi", navi);
		return map;
	}

	@Override
	@Transactional
	public Map<String, String> cancelAppr(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		Map<String, String> returnMap = new HashMap<String, String>();
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {			
			//1. 결재 문서 상태 확인. 결재 상태가 N이 아닌 경우 상신취소 불가능.
			Map<String, Object> header = approvalDao.selectApprHeaderData(param);
			if( header != null && !"N".equals(header.get("LAST_STATUS")) ) {
				returnMap.put("RESULT", "F");
				returnMap.put("MESSAGE", "결재진행중 문서는 상신취소 할 수 없습니다.");
			} else {
				//2. APPR 문서 상태 변경
				approvalDao.updateApprStatus(param);
				//3. 결재 상신 문서 상태 변경
				approvalDao.updateDocStatus(param);
				//4.결재자에게 알림을 발송한다.
				HashMap<String, Object> notiMap = new HashMap<String, Object>();
				notiMap.put("targetUser", header.get("TARGET_USER_ID"));
				notiMap.put("type", "APPR_CANCEL");
				notiMap.put("typeTxt", "상신취소");
				notiMap.put("message", "상신취소 되었습니다.");
				notiMap.put("userId", header.get("REG_USER"));
				notiMap.put("docIdx", header.get("DOC_IDX"));
				notiMap.put("docType", header.get("DOC_TYPE"));
				commonService.notification(notiMap);
				returnMap.put("RESULT", "S");
				
				txManager.commit(status);
			}			
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE", e.getMessage());
		}
		return returnMap;
	}

	@Override
	@Transactional
	public Map<String, String> reAppr(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		Map<String, String> returnMap = new HashMap<String, String>();
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try {
			//1. 문서 상태 확인. 문서상태가 등록(REG) 상태가 아닌 경우 재상신 할 수 없다.
			Map<String, String> docMap = approvalDao.selectDocData(param);
			Map<String, Object> header = approvalDao.selectApprHeaderData(param);
			if( docMap != null && "REG".equals(docMap.get("STATUS")) ) {
				if( header != null && !"C".equals(header.get("LAST_STATUS")) ) {
					returnMap.put("RESULT", "F");
					returnMap.put("MESSAGE", "상신취소 상태의 문서만 재상신이 가능합니다.");
				} else {
					//2. APPR 문서 상태 변경
					approvalDao.updateApprStatus(param);
					//3. 결재 상신 문서 상태 변경
					approvalDao.updateDocStatus(param);
					returnMap.put("RESULT", "S");
					//4.결재자에게 알림을 발송한다.
					HashMap<String, Object> notiMap = new HashMap<String, Object>();
					notiMap.put("targetUser", header.get("TARGET_USER_ID"));
					notiMap.put("type", "APPR");
					notiMap.put("typeTxt", "결재상신");
					notiMap.put("message", "결재 요청이 도착했습니다.");
					notiMap.put("userId", header.get("REG_USER"));
					notiMap.put("docIdx", header.get("DOC_IDX"));
					notiMap.put("docType", header.get("DOC_TYPE"));
					commonService.notification(notiMap);
					
					txManager.commit(status);
				}
			} else {
				returnMap.put("RESULT", "F");
				returnMap.put("MESSAGE", "등록상태의 문서만 재상신이 가능합니다.");
			}
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE", e.getMessage());
		}
		return returnMap;
	}

	@Override
	public Map<String, Object> selectApprHeaderData(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return approvalDao.selectApprHeaderData(param);
	}

	@Override
	public List<Map<String, Object>> selectApprItemList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return approvalDao.selectApprItemList(param);
	}

	@Override
	public List<Map<String, Object>> selectReferenceList(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return approvalDao.selectReferenceList(param);
	}

	@Override
	public Map<String, String> approvalSubmit(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		Map<String, String> returnMap = new HashMap<String, String>();
		
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		
		try{
			//1.현재 문서 상태 확인
			Map<String, Object> docData = null;
			if(  param.get("docType") != null && "PROD".equals(param.get("docType"))) {
				docData = productDao.selectProductData(param);
			} else if(  param.get("docType") != null && "MENU".equals(param.get("docType"))) {
				docData = menuDao.selectMenuData(param);
			} else if(  param.get("docType") != null && "DESIGN".equals(param.get("docType"))) {
				docData = designReportDao.selectDesignData(param);
			} else if(  param.get("docType") != null && "SENSE_QUALITY".equals(param.get("docType"))) {
				docData = senseQualityDao.selectSenseQualityReport(param);
			} else if(  param.get("docType") != null && "TRIP".equals(param.get("docType"))) {
				docData = businessTripDao.selectBusinessTripData(param);
			} else if(  param.get("docType") != null && "PLAN".equals(param.get("docType"))) {
				docData = businessTripPlanDao.selectBusinessTripPlanData(param);
			} else if(  param.get("docType") != null && "RESEARCH".equals(param.get("docType"))) {
				docData = marketResearchDao.selectMarketResearchData(param);
			} else if(  param.get("docType") != null && "RESULT".equals(param.get("docType"))) {
				docData = newProductResultDao.selectNewProductResultData(param);
			} else if(  param.get("docType") != null && "CHEMICAL".equals(param.get("docType"))) {
				docData = chemicalTestDao.selectChemicalTestData(param);
			} else if(  param.get("docType") != null && "PACKAGE".equals(param.get("docType"))) {
				docData = packageInfoDao.selectPackageInfoData(param);
			}
			//문서 상태가 승인중, 부분승인인 경우에만 결재가 가능하다.
			System.err.println("docData : "+docData);
			if( docData.get("STATUS") != null && ("APPR".equals(docData.get("STATUS")) || "COND_APPR".equals(docData.get("STATUS")) )  ) {
				Map<String, Object> apprHeader = approvalDao.selectApprHeaderData(param);
				System.err.println("apprHeader : "+apprHeader);
				//결재상태가 상신, 결재중인 경우에만 결재가 가능하다.
				if( apprHeader.get("LAST_STATUS") != null && ("N".equals(apprHeader.get("LAST_STATUS")) || "A".equals(apprHeader.get("LAST_STATUS"))) ) {
					//2.정상적인 문서의 경우 결재처리한다. approval item 데이터를 업데이트한다.
					approvalDao.approvalSubmitItem(param);
					//3.전체 결재가 완료 된 경우 문서의 결재 상태를 변경한다.				
					Map<String, Object> itemData = approvalDao.selectNextApprItem(param);	//다음 결재 데이터를 조회한다.
					System.err.println("itemData : "+itemData);
					Map<String, Object> map = new HashMap<String, Object>();
					if( itemData != null && !"".equals((String)itemData.get("TARGET_USER_ID")) ) {
					//if( Integer.parseInt((String)param.get("totalStep")) == Integer.parseInt((String)param.get("currentStep")) ) {					
						map = new HashMap<String, Object>();
						map.put("apprIdx", (String)param.get("apprIdx"));				//문서 ID
						map.put("currentUser", (String)itemData.get("TARGET_USER_ID"));	//결재자 ID
						map.put("currentStep", itemData.get("APPR_NO"));				//결재 순서
						map.put("lastStatus", "A");										//결재 상태(A:결재중)
						approvalDao.updateApprUser(map);
						//다음 결재자에게 메일/알림을 보낸다.
						HashMap<String, Object> notiMap = new HashMap<String, Object>();
						notiMap.put("targetUser", (String)itemData.get("TARGET_USER_ID"));
						notiMap.put("type", "APPR");
						notiMap.put("typeTxt", "결재상신");
						notiMap.put("message", "결재 요청이 도착했습니다.");
						notiMap.put("userId", apprHeader.get("REG_USER"));
						notiMap.put("docIdx", apprHeader.get("DOC_IDX"));
						notiMap.put("docType", apprHeader.get("DOC_TYPE"));
						commonService.notification(notiMap);
					} else {
						map.put("apprIdx", (String)param.get("apprIdx"));	//결재 ID
						map.put("status", "Y");								//결재문서 승인처리
						approvalDao.updateApprStatus(map);
						map = new HashMap<String, Object>();
						map.put("docIdx", (String)param.get("docIdx"));		//문서 ID
						map.put("docType", (String)param.get("docType"));	//문서 유형
						map.put("docStatus", "COMP");						//완료
						approvalDao.updateDocStatus(map);
						if( (String)param.get("docType") != null && "MENU".equals((String)param.get("docType")) ) {
							manualDao.insertManual(param);
						}
						//완료 메일/알림을 상신자에게 보낸다.
						HashMap<String, Object> notiMap = new HashMap<String, Object>();
						notiMap.put("targetUser", (String)apprHeader.get("REG_USER"));
						notiMap.put("type", "APPR_COMP");
						notiMap.put("typeTxt", "결재완료");
						notiMap.put("message", "결재가 완료되었습니다.");
						notiMap.put("userId", "");
						notiMap.put("docIdx", apprHeader.get("DOC_IDX"));
						notiMap.put("docType", apprHeader.get("DOC_TYPE"));
						commonService.notification(notiMap);
						
						//참조자리스트를 조회한다.
						List<Map<String, Object>> refList = approvalDao.selectReferenceList(param);	//다음 결재 데이터를 조회한다.
						//참조자들에게 메일/알림을 보낸다.
						for( int i = 0 ; i < refList.size() ; i++) {
							Map<String, Object> refData = refList.get(i);
							notiMap = new HashMap<String, Object>();
							notiMap.put("targetUser", refData.get("TARGET_USER_ID"));
							notiMap.put("type", "APPR_REF");
							notiMap.put("typeTxt", "결재참조");
							notiMap.put("message", "참조문서가 도착했습니다.");
							notiMap.put("userId", apprHeader.get("REG_USER"));
							notiMap.put("docIdx", apprHeader.get("DOC_IDX"));
							notiMap.put("docType", apprHeader.get("DOC_TYPE"));
							commonService.notification(notiMap);
						}					
					}
					
					txManager.commit(status);
					
					returnMap.put("RESULT", "S");
				} else {
					returnMap.put("RESULT", "F");
					returnMap.put("MESSAGE","결재승인 할 수 없는 문서입니다.");
				}
				returnMap.put("RESULT", "S");
			} else {
				returnMap.put("RESULT", "F");
				returnMap.put("MESSAGE","상신취소 되었거나 결재승인 할 수 없는 문서입니다.");
			}
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE", e.getMessage());
		}
		
		return returnMap;
	}

	@Override
	public Map<String, String> approvalCondSubmit(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		Map<String, String> returnMap = new HashMap<String, String>();
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			//1.현재 문서 상태 확인
			Map<String, Object> docData = null;
			if(  param.get("docType") != null && "PROD".equals(param.get("docType"))) {
				docData = productDao.selectProductData(param);
			} else if(  param.get("docType") != null && "MENU".equals(param.get("docType"))) {
				docData = menuDao.selectMenuData(param);
			} else if(  param.get("docType") != null && "DESIGN".equals(param.get("docType"))) {
				docData = designReportDao.selectDesignData(param);
			} else if(  param.get("docType") != null && "SENSE_QUALITY".equals(param.get("docType"))) {
				docData = senseQualityDao.selectSenseQualityReport(param);
			} else if(  param.get("docType") != null && "TRIP".equals(param.get("docType"))) {
				docData = businessTripDao.selectBusinessTripData(param);
			} else if(  param.get("docType") != null && "PLAN".equals(param.get("docType"))) {
				docData = businessTripPlanDao.selectBusinessTripPlanData(param);
			} else if(  param.get("docType") != null && "RESEARCH".equals(param.get("docType"))) {
				docData = marketResearchDao.selectMarketResearchData(param);
			} else if(  param.get("docType") != null && "RESULT".equals(param.get("docType"))) {
				docData = newProductResultDao.selectNewProductResultData(param);
			} else if(  param.get("docType") != null && "CHEMICAL".equals(param.get("docType"))) {
				docData = chemicalTestDao.selectChemicalTestData(param);
			} else if(  param.get("docType") != null && "PACKAGE".equals(param.get("docType"))) {
				docData = packageInfoDao.selectPackageInfoData(param);
			}
			//문서 상태가 승인중, 부분승인인 경우에만 결재가 가능하다.
			System.err.println("docData : "+docData);
			if( docData.get("STATUS") != null && ("APPR".equals(docData.get("STATUS")) || "COND_APPR".equals(docData.get("STATUS")) )  ) {
				Map<String, Object> apprHeader = approvalDao.selectApprHeaderData(param);
				System.err.println("apprHeader : "+apprHeader);
				//결재상태가 상신, 결재중인 경우에만 결재가 가능하다.
				if( apprHeader.get("LAST_STATUS") != null && ("N".equals(apprHeader.get("LAST_STATUS")) || "A".equals(apprHeader.get("LAST_STATUS"))) ) {
					//2.정상적인 문서의 경우 결재처리한다. approval item 데이터를 업데이트한다.
					approvalDao.approvalSubmitItem(param);
					//3.전체 결재가 완료 된 경우 문서의 결재 상태를 변경한다.				
					Map<String, Object> itemData = approvalDao.selectNextApprItem(param);	//다음 결재 데이터를 조회한다.
					System.err.println("itemData : "+itemData);
					Map<String, Object> map = new HashMap<String, Object>();
					if( itemData != null && !"".equals((String)itemData.get("TARGET_USER_ID")) ) {
					//if( Integer.parseInt((String)param.get("totalStep")) == Integer.parseInt((String)param.get("currentStep")) ) {					
						map = new HashMap<String, Object>();
						map.put("apprIdx", (String)param.get("apprIdx"));				//문서 ID
						map.put("currentUser", (String)itemData.get("TARGET_USER_ID"));	//결재자 ID
						map.put("currentStep", itemData.get("APPR_NO"));				//결재 순서
						map.put("lastStatus", "A");										//결재 상태(A:결재중)
						approvalDao.updateApprUser(map);
						map = new HashMap<String, Object>();
						map.put("docIdx", (String)param.get("docIdx"));		//문서 ID
						map.put("docType", (String)param.get("docType"));	//문서 유형
						map.put("docStatus", "COND_APPR");					//부분승인 처리
						approvalDao.updateDocStatus(map);
						//담당자에게 알림을 보낸다.
						HashMap<String, Object> notiMap = new HashMap<String, Object>();
						notiMap.put("targetUser", apprHeader.get("REG_USER"));
						notiMap.put("type", "COND_APPR");
						notiMap.put("typeTxt", "부분승인");
						notiMap.put("message", "요청하신 결재가 부분승인 되었습니다.");
						notiMap.put("userId", "");
						notiMap.put("docIdx", apprHeader.get("DOC_IDX"));
						notiMap.put("docType", apprHeader.get("DOC_TYPE"));
						commonService.notification(notiMap);
					} else {
						map.put("apprIdx", (String)param.get("apprIdx"));	//결재 ID
						map.put("status", "Y");								//결재문서 승인처리
						approvalDao.updateApprStatus(map);
						map = new HashMap<String, Object>();
						map.put("docIdx", (String)param.get("docIdx"));		//문서 ID
						map.put("docType", (String)param.get("docType"));	//문서 유형
						map.put("docStatus", "COMP");						//완료
						approvalDao.updateDocStatus(map);
						//담당자에게 알림을 보낸다.
						HashMap<String, Object> notiMap = new HashMap<String, Object>();
						notiMap.put("targetUser", apprHeader.get("REG_USER"));
						notiMap.put("type", "APPR_COMP");
						notiMap.put("typeTxt", "승인완료");
						notiMap.put("message", "요청하신 결재가 승인완료 되었습니다.");
						notiMap.put("userId", "");
						notiMap.put("docIdx", apprHeader.get("DOC_IDX"));
						notiMap.put("docType", apprHeader.get("DOC_TYPE"));
						commonService.notification(notiMap);
						//참조자들에게 메일/알림을 보낸다.
						//참조자리스트를 조회한다.
						List<Map<String, Object>> refList = approvalDao.selectReferenceList(param);	//다음 결재 데이터를 조회한다.
						//참조자들에게 메일/알림을 보낸다.
						for( int i = 0 ; i < refList.size() ; i++) {
							Map<String, Object> refData = refList.get(i);
							notiMap = new HashMap<String, Object>();
							notiMap.put("targetUser", refData.get("TARGET_USER_ID"));
							notiMap.put("type", "APPR_REF");
							notiMap.put("typeTxt", "결재참조");
							notiMap.put("message", "참조문서가 도착했습니다.");
							notiMap.put("userId", apprHeader.get("REG_USER"));
							notiMap.put("docIdx", apprHeader.get("DOC_IDX"));
							notiMap.put("docType", apprHeader.get("DOC_TYPE"));
							commonService.notification(notiMap);
						}
					}
					
					txManager.commit(status);
					returnMap.put("RESULT", "S");
				} else {
					returnMap.put("RESULT", "F");
					returnMap.put("MESSAGE","결재승인 할 수 없는 문서입니다.");
				}
				returnMap.put("RESULT", "S");
			} else {
				returnMap.put("RESULT", "F");
				returnMap.put("MESSAGE","상신취소 되었거나 결재승인 할 수 없는 문서입니다.");
			}
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE", e.getMessage());
		}
		return returnMap;
	}
	
	@Override
	public Map<String, String> approvalReject(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		Map<String, String> returnMap = new HashMap<String, String>();
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try{
			//1.현재 문서 상태 확인
			Map<String, Object> docData = null;
			if(  param.get("docType") != null && "PROD".equals(param.get("docType"))) {
				docData = productDao.selectProductData(param);
			} else if(  param.get("docType") != null && "MENU".equals(param.get("docType"))) {
				docData = menuDao.selectMenuData(param);
			} else if(  param.get("docType") != null && "DESIGN".equals(param.get("docType"))) {
				docData = designReportDao.selectDesignData(param);
			} else if(  param.get("docType") != null && "SENSE_QUALITY".equals(param.get("docType"))) {
				docData = senseQualityDao.selectSenseQualityReport(param);
			} else if(  param.get("docType") != null && "TRIP".equals(param.get("docType"))) {
				docData = businessTripDao.selectBusinessTripData(param);
			} else if(  param.get("docType") != null && "PLAN".equals(param.get("docType"))) {
				docData = businessTripPlanDao.selectBusinessTripPlanData(param);
			} else if(  param.get("docType") != null && "RESEARCH".equals(param.get("docType"))) {
				docData = marketResearchDao.selectMarketResearchData(param);
			} else if(  param.get("docType") != null && "RESULT".equals(param.get("docType"))) {
				docData = newProductResultDao.selectNewProductResultData(param);
			} else if(  param.get("docType") != null && "CHEMICAL".equals(param.get("docType"))) {
				docData = chemicalTestDao.selectChemicalTestData(param);
			} else if(  param.get("docType") != null && "PACKAGE".equals(param.get("docType"))) {
				docData = packageInfoDao.selectPackageInfoData(param);
			}
			
			//문서 상태가 승인중, 부분승인인 경우에만 반려가 가능하다.
			System.err.println("docData : "+docData);
			if( docData.get("STATUS") != null && ("APPR".equals(docData.get("STATUS")) || "COND_APPR".equals(docData.get("STATUS")) )  ) {
				Map<String, Object> apprHeader = approvalDao.selectApprHeaderData(param);
				System.err.println("apprHeader : "+apprHeader);
				//결재상태가 상신, 결재중인 경우에만 반려가 가능하다.
				if( apprHeader.get("LAST_STATUS") != null && ("N".equals(apprHeader.get("LAST_STATUS")) || "A".equals(apprHeader.get("LAST_STATUS"))) ) {
					//2.정상적인 문서의 경우 반려처리한다. approval item 데이터를 업데이트한다.
					approvalDao.approvalSubmitItem(param);
					Map<String, Object> map = new HashMap<String, Object>();
					map.put("apprIdx", param.get("apprIdx"));		//문서 ID
					map.put("status", param.get("apprStatus"));	//문서 유형
					approvalDao.updateApprStatus(map);
					//3.결재 header를 반려로 업데이트한다.
					map = new HashMap<String, Object>();
					map.put("docIdx", (String)param.get("docIdx"));		//문서 ID
					map.put("docType", (String)param.get("docType"));	//문서 유형
					map.put("docStatus", "RET");						//반려
					approvalDao.updateDocStatus(map);
					returnMap.put("RESULT", "S");
					//담당자에게 알림을 보낸다.
					HashMap<String, Object> notiMap = new HashMap<String, Object>();
					notiMap.put("targetUser", apprHeader.get("REG_USER"));
					notiMap.put("type", "APPR_RET");
					notiMap.put("typeTxt", "반려");
					notiMap.put("message", "요청하신 결재가 반려 되었습니다.");
					notiMap.put("userId", "");
					notiMap.put("docIdx", apprHeader.get("DOC_IDX"));
					notiMap.put("docType", apprHeader.get("DOC_TYPE"));
					commonService.notification(notiMap);
					
					txManager.commit(status);
				} else {
					returnMap.put("RESULT", "F");
					returnMap.put("MESSAGE","반려 할 수 없는 문서입니다.");
				}
			} else {
				returnMap.put("RESULT", "F");
				returnMap.put("MESSAGE","상신취소 되었거나 반려 할 수 없는 문서입니다.");
			}
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			returnMap.put("RESULT", "E");
			returnMap.put("MESSAGE", e.getMessage());
		}
		
		
		return returnMap;
	}

	@Override
	public Map<String, Object> selectApprItem(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return approvalDao.selectApprItem(param);
	}

	@Override
	public void updateRefIsRead(Map<String, Object> param) throws Exception {
		// TODO Auto-generated method stub
		approvalDao.updateRefIsRead(param);
	}	
}
