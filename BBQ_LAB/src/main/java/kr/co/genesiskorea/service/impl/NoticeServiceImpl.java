package kr.co.genesiskorea.service.impl;

import java.io.File;
import java.text.SimpleDateFormat;
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

import kr.co.genesiskorea.util.FileUtil;
import kr.co.genesiskorea.util.PageNavigator;
import kr.co.genesiskorea.util.StringUtil;
import kr.co.genesiskorea.dao.CommonDao;
import kr.co.genesiskorea.dao.NoticeDao;
import kr.co.genesiskorea.service.NoticeService;

@Service
public class NoticeServiceImpl implements NoticeService {
	
	private Logger logger = LogManager.getLogger(NoticeServiceImpl.class);
	
	@Autowired
	NoticeDao noticeDao;
	
	@Autowired
	CommonDao commonDao;
	
	@Autowired
	private Properties config;
	
	@Resource
	DataSourceTransactionManager txManager;

	@Override
    public int selectNoticeCount(Map<String, Object> param) {
        return noticeDao.selectNoticeCount(param);
    }

    @Override
    public Map<String, Object> selectNoticeList(Map<String, Object> param) throws Exception {
        int totalCount = noticeDao.selectNoticeCount(param);

        int viewCount = 10;
        int pageNo = 1;

        try {
            viewCount = Integer.parseInt(String.valueOf(param.get("viewCount")));
            pageNo = Integer.parseInt(String.valueOf(param.get("pageNo")));
        } catch (Exception e) {
            viewCount = 10;
            pageNo = 1;
        }

        // PageNavigator를 통해 startRow, endRow 계산
        PageNavigator navi = new PageNavigator(param, viewCount, totalCount);

        List<Map<String, Object>> noticeList = noticeDao.selectNoticeList(param);

        Map<String, Object> result = new HashMap<>();
        result.put("pageNo", pageNo);
        result.put("totalCount", totalCount);
        result.put("list", noticeList);
        result.put("navi", navi); // PageNavigator 포함

        return result;
    }

    @Override
	public List<Map<String, Object>> selectHistory(Map<String, Object> param) {
		// TODO Auto-generated method stub
		return noticeDao.selectHistory(param);
	}
	
	@Override
	public int insertNotice(Map<String, Object> param, MultipartFile[] file) throws Exception {
	    int noticeIdx = 0;
	    
	    DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
	    try {
	        // 공지사항 IDX 생성
	        noticeIdx = noticeDao.selectNoticeSeq();
	        param.put("idx", noticeIdx);

	        // 현재 날짜 기준 폴더 생성용 yyyyMM
	        Calendar cal = Calendar.getInstance();
	        Date now = cal.getTime();
	        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
	        String today = sdf.format(now);

	        String path = config.getProperty("upload.file.path.notice") + "/" + today;

	        // 1. 공지사항 등록
	        noticeDao.insertNotice(param);

	        // 2. 첨부파일 저장
	        if (file != null && file.length > 0) {
	            for (MultipartFile multipartFile : file) {
	                try {
	                    if (!multipartFile.isEmpty()) {
	                        String fileIdx = FileUtil.getUUID();
	                        String result = FileUtil.upload3(multipartFile, path, fileIdx);
	                        String content = FileUtil.getPdfContents(path, result);

	                        Map<String, Object> fileMap = new HashMap<>();
	                        fileMap.put("fileIdx", fileIdx);
	                        fileMap.put("docIdx", noticeIdx);
	                        fileMap.put("docType", "NOTICE");
	                        fileMap.put("fileType", "00"); // 필요 시 외부에서 값 받아서 수정 가능
	                        fileMap.put("orgFileName", multipartFile.getOriginalFilename());
	                        fileMap.put("filePath", path);
	                        fileMap.put("changeFileName", result);
	                        fileMap.put("content", content);

	                        commonDao.insertFileInfo(fileMap);
	                    }
	                } catch (Exception e) {
	                    // 개별 파일 저장 실패는 전체 실패로 이어지지 않도록 로그만 출력
	                    e.printStackTrace();
	                }
	            }
	        }

	        // 3. 히스토리 저장
	        Map<String, Object> historyParam = new HashMap<>();
	        historyParam.put("docIdx", noticeIdx);
	        historyParam.put("docType", "NOTICE");
	        historyParam.put("historyType", "I");
	        historyParam.put("historyData", param.toString());
	        historyParam.put("userId", param.get("userId"));
	        commonDao.insertHistory(historyParam);

	        txManager.commit(status);
	    } catch (Exception e) {
	    	txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
	    }
	    return noticeIdx;
	}
	
	@Override
	public Map<String, Object> selectNoticeData(Map<String, Object> param) {
	    Map<String, Object> result = new HashMap<String, Object>();

	    // 공지사항 본문 데이터 조회
	    Map<String, Object> noticeData = noticeDao.selectNoticeData(param);

	    // 첨부파일 리스트 조회
	    param.put("docType", "NOTICE"); // 문서 타입 명확하게 설정 (필요 시 변경)
	    List<Map<String, String>> fileList = commonDao.selectFileList(param);

	    result.put("data", noticeData);
	    result.put("fileList", fileList);

	    return result;
	}
    
	@Override
	public void updateNotice(Map<String, Object> param, MultipartFile[] files, String[] deletedFileList) throws Exception {
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
	        // 날짜 폴더 구성
	        Calendar cal = Calendar.getInstance();
	        String toDay = new SimpleDateFormat("yyyyMM").format(cal.getTime());

	        // 파일 저장 경로
	        String basePath = config.getProperty("upload.file.path.notice"); // 예: /aspn/pdm/upload/notice
	        String savePath = basePath + "/" + toDay;

	        // 1. 공지사항 본문 및 기본 정보 업데이트
	        noticeDao.updateNotice(param); // param에는 idx, title, type, dates, contents 등이 포함됨

	        // 2. 기존 파일 삭제 처리
	        if (deletedFileList != null) {
	            for (String fileIdx : deletedFileList) {
	                if (fileIdx == null || fileIdx.trim().isEmpty()) continue;

	                Map<String, Object> fileParam = new HashMap<>();
	                fileParam.put("idx", fileIdx);
	                Map<String, String> fileData = commonDao.selectFileData(fileParam);

	                if (fileData == null) {
	                    continue;
	                }

	                String filePath = fileData.get("FILE_PATH");
	                String fileName = fileData.get("FILE_NAME");

	                if (filePath != null && fileName != null) {
	                    File fileToDelete = new File(filePath + File.separator + fileName);

	                    if (fileToDelete.exists()) {
	                        boolean deleted = fileToDelete.delete();
	                        if (deleted) {
	                        } else {
	                        }
	                    } else {
	                    }
	                }

	                commonDao.deleteFileData(fileIdx); // DB 삭제는 계속 수행
	            }
	        }

	        // 3. 신규 파일 업로드 및 저장
	        if (files != null && files.length > 0) {
	            for (MultipartFile multipartFile : files) {
	                if (multipartFile != null && !multipartFile.isEmpty()) {
	                    String fileIdx = FileUtil.getUUID();
	                    String storedFileName = FileUtil.upload3(multipartFile, savePath, fileIdx);

	                    Map<String, Object> fileMap = new HashMap<>();
	                    fileMap.put("fileIdx", fileIdx);
	                    fileMap.put("docIdx", param.get("idx"));
	                    fileMap.put("docType", "NOTICE");
	                    fileMap.put("fileType", "00");
	                    fileMap.put("orgFileName", multipartFile.getOriginalFilename());
	                    fileMap.put("changeFileName", storedFileName);
	                    fileMap.put("filePath", savePath);

	                    commonDao.insertFileInfo(fileMap);
	                }
	            }
	        }

	        // 4. 히스토리 기록 (선택)
	        Map<String, Object> history = new HashMap<>();
	        history.put("docIdx", param.get("idx"));
	        history.put("docType", "NOTICE");
	        history.put("historyType", "U");
	        history.put("historyData", param.toString());
	        history.put("userId", param.get("userId"));
	        commonDao.insertHistory(history);

	        txManager.commit(status);
	    } catch (Exception e) {
	    	txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
	    }
	}
	
	@Override
	public int updateHits(Map<String, Object> param) throws Exception {
	    return noticeDao.updateHits(param);
	}
	
	@Override
	public void deleteNotice(Map<String, Object> param) throws Exception {
		DefaultTransactionDefinition def = new DefaultTransactionDefinition();
		TransactionStatus status = null;
		
		def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
		status = txManager.getTransaction(def);
		try {
			// 1. 첨부파일 조회
		    param.put("docType", "NOTICE");
		    List<Map<String, String>> fileList = commonDao.selectFileList(param);

		    // 2. 파일 삭제
		    for (Map<String, String> fileData : fileList) {
		        String filePath = fileData.get("FILE_PATH");
		        String fileName = fileData.get("FILE_NAME"); // DB 컬럼 확인 후 FILE_NAME이 맞는지 확인

		        if (filePath != null && fileName != null) {
		            File fileToDelete = new File(filePath + File.separator + fileName);

		            if (fileToDelete.exists()) {
		                boolean deleted = fileToDelete.delete();
		                if (deleted) {
		                } else {
		                }
		            } else {
		            }
		        }

		        // 3. DB 파일 정보 삭제
		        commonDao.deleteFileData(fileData.get("FILE_IDX"));
		    }

		    noticeDao.updateIsDeleteY(param); // is_delete = 'Y'로 업데이트
		    
		    txManager.commit(status);
		} catch( Exception e ) {
			txManager.rollback(status);
			logger.error(StringUtil.getStackTrace(e, this.getClass()));
			throw e;
		}
	    
	}

}
