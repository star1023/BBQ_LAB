package kr.co.genesiskorea.service.impl;

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

import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.dao.SystemDocTransferDao;
import kr.co.genesiskorea.service.SystemDocTransferService;
import kr.co.genesiskorea.util.StringUtil;

@Service
public class SystemDocTransferServiceImpl implements SystemDocTransferService {

	private Logger logger = LogManager.getLogger(MenuServiceImpl.class);
	
    @Autowired
    private SystemDocTransferDao systemDocTransferDao;
    
    @Autowired
    CommonDao commonDao;
    
    @Resource
	DataSourceTransactionManager txManager;

    @Override
    public List<Map<String, Object>> selectUserDocs(String userId) throws Exception {
        Map<String, Object> param = new HashMap<>();
        param.put("userId", userId);
        return systemDocTransferDao.selectUserDocs(param);
    }
    
    @Override
    @Transactional
    public Map<String, Object> transferDocs(Map<String, Object> param) throws Exception {

        DefaultTransactionDefinition def = new DefaultTransactionDefinition();
        def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
        TransactionStatus status = txManager.getTransaction(def);

        try {
            @SuppressWarnings("unchecked")
            List<Map<String,Object>> docs = (List<Map<String,Object>>) param.get("docs");
            if (docs == null || docs.isEmpty()) {
                throw new IllegalArgumentException("docs is empty");
            }

            // ===== 1) 리스트 분리 =====
            // DOC_NO 기반 테이블: PROD, MENU, DESIGN, PACKAGE, RECIPE
            List<String> prodDocNos   = new java.util.ArrayList<>();
            List<String> menuDocNos   = new java.util.ArrayList<>();
            List<String> designDocNos = new java.util.ArrayList<>();
            List<String> packageDocNos= new java.util.ArrayList<>();
            List<String> recipeDocNos = new java.util.ArrayList<>();

            // IDX 기반 테이블: REPORT, PLAN, TRIP, RESEARCH, RESULT, CHEMICAL, NOTICE
            List<String> reportIds    = new java.util.ArrayList<>();
            List<String> planIds      = new java.util.ArrayList<>();
            List<String> tripIds      = new java.util.ArrayList<>();
            List<String> researchIds  = new java.util.ArrayList<>();
            List<String> resultIds    = new java.util.ArrayList<>();
            List<String> chemicalIds  = new java.util.ArrayList<>();
            List<String> noticeIds    = new java.util.ArrayList<>();

            for (Map<String,Object> d : docs) {
                String type  = String.valueOf(d.getOrDefault("typeCode","")).trim();
                String docNo = String.valueOf(d.getOrDefault("docNo","")).trim();
                String docId = String.valueOf(d.getOrDefault("docId","")).trim();

                if (!docNo.isEmpty()) {
                    switch (type) {
                        case "PROD":    prodDocNos.add(docNo);   break;
                        case "MENU":    menuDocNos.add(docNo);   break;
                        case "DESIGN":  designDocNos.add(docNo); break;
                        case "PACKAGE": packageDocNos.add(docNo);break;
                        case "RECIPE":  recipeDocNos.add(docNo); break;
                        default: break; // DOC_NO를 쓰지 않는 타입은 무시
                    }
                } else {
                    if (docId.isEmpty()) continue;
                    switch (type) {
                        case "REPORT":   reportIds.add(docId);   break;
                        case "PLAN":     planIds.add(docId);     break;
                        case "TRIP":     tripIds.add(docId);     break;
                        case "RESEARCH": researchIds.add(docId); break;
                        case "RESULT":   resultIds.add(docId);   break;
                        case "CHEMICAL": chemicalIds.add(docId); break;
                        case "NOTICE":   noticeIds.add(docId);   break;
                        default: break;
                    }
                }
            }

            int updatedByDocNo = 0;
            int updatedByIdx   = 0;

            // ===== 2) DOC_NO 기반 전체 버전 이관 =====
            if (!prodDocNos.isEmpty() || !menuDocNos.isEmpty() || !designDocNos.isEmpty()
                || !packageDocNos.isEmpty() || !recipeDocNos.isEmpty()) {

                Map<String,Object> p1 = new java.util.HashMap<>(param);
                p1.put("prodDocNos",    prodDocNos);
                p1.put("menuDocNos",    menuDocNos);
                p1.put("designDocNos",  designDocNos);
                p1.put("packageDocNos", packageDocNos);
                p1.put("recipeDocNos",  recipeDocNos);

                updatedByDocNo = systemDocTransferDao.updateOwnerByDocNoBulk(p1);
            }

            // ===== 3) IDX 기반 단건 이관 =====
            if (!reportIds.isEmpty() || !planIds.isEmpty() || !tripIds.isEmpty()
                || !researchIds.isEmpty() || !resultIds.isEmpty()
                || !chemicalIds.isEmpty() || !noticeIds.isEmpty()) {

                Map<String,Object> p2 = new java.util.HashMap<>(param);
                p2.put("reportIds",   reportIds);
                p2.put("planIds",     planIds);
                p2.put("tripIds",     tripIds);
                p2.put("researchIds", researchIds);
                p2.put("resultIds",   resultIds);
                p2.put("chemicalIds", chemicalIds);
                p2.put("noticeIds",   noticeIds);

                updatedByIdx = systemDocTransferDao.updateOwnerByIdxBulk(p2);
            }

            // ===== 4) 결과 집계 =====
            int updated = updatedByDocNo + updatedByIdx;
            String resultFlag = (updated <= 0) ? "E" : (updated >= docs.size() ? "S" : "P");

            // ===== 5) 이력 저장 (공통 히스토리 N건 + 마스터 1건 + 문서 N건) =====
            String fromUser = String.valueOf(param.getOrDefault("sourceUserId", ""));
            String toUser   = String.valueOf(param.getOrDefault("targetUserId", ""));
            String byUser   = String.valueOf(param.getOrDefault("excuteUserId", param.getOrDefault("userId","")));
            String comment  = String.valueOf(param.getOrDefault("transferComment", ""));

            for (Map<String, Object> d : docs) {
                String docIdx  = String.valueOf(d.getOrDefault("docId", ""));
                String docType = String.valueOf(d.getOrDefault("typeCode", ""));
                String dn      = String.valueOf(d.getOrDefault("docNo", ""));

                Map<String, Object> historyParam = new HashMap<>();
                historyParam.put("docIdx", docIdx);
                historyParam.put("docType", docType);
                historyParam.put("historyType", "F");
                String message = (dn == null || dn.isEmpty())
                    ? String.format("문서 이관: type=%s, idx=%s, from=%s, to=%s, by=%s, comment=%s",
                                    docType, docIdx, fromUser, toUser, byUser, comment)
                    : String.format("문서 이관: type=%s, idx=%s, docNo=%s, from=%s, to=%s, by=%s, comment=%s",
                                    docType, docIdx, dn, fromUser, toUser, byUser, comment);
                historyParam.put("historyData", message);
                historyParam.put("userId", byUser);
                commonDao.insertHistory(historyParam);
            }

            Map<String, Object> hist = new HashMap<>();
            hist.put("transFrom",    fromUser);
            hist.put("transTo",      toUser);
            hist.put("transUser",    byUser);
            hist.put("transComment", comment);
            systemDocTransferDao.insertTransferHistory(hist);

            Number n = (Number) hist.get("transIdx");
            long transIdx = (n != null) ? n.longValue() : 0L;
            if (transIdx <= 0L) throw new IllegalStateException("transIdx generation failed");

            Map<String,Object> bulkParam = new HashMap<>();
            bulkParam.put("transIdx", transIdx);
            bulkParam.put("list", docs);
            systemDocTransferDao.insertTransferDocBulk(bulkParam);

            Map<String,Object> res = new HashMap<>();
            res.put("RESULT",  resultFlag);
            res.put("COUNT",   updated);
            res.put("FAILS",   java.util.Collections.emptyList());
            res.put("MESSAGE", resultFlag.equals("S") ? "OK" : (resultFlag.equals("P") ? "PARTIAL" : "ERROR"));

            txManager.commit(status);
            return res;

        } catch (Exception e) {
            txManager.rollback(status);
            logger.error(StringUtil.getStackTrace(e, this.getClass()));
            throw e;
        }
    }
}