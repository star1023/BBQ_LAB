<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>  <!-- ✅ 이거 추가 -->
<title>공지사항 상세</title>
<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<style>
    .ck-editor__editable { min-height: 400px; }
</style>
<script>
	$(document).ready(function() {
	    // 페이지 로딩 후 조회수 증가 -> 완료 후 fn_update 호출 가능
	    increaseHitsAndThen(function() {
	        // 조회수 증가 후 원하는 작업 실행
	        // 예: 수정 버튼 비활성화 해제 등
	        console.log("조회수 증가 후 추가 작업 실행 가능");
	        // fn_update('${noticeData.data.BNOTICE_IDX}'); // 자동 호출 원할 경우
	    });
	});
	
    function fn_goList() {
        location.href = "/notice/list";
    }
    
    function fn_update(idx) {
    	location.href = "/notice/update?idx=" + idx;
    }
    
	function downloadFile(idx){
		location.href = '/common/fileDownload?idx='+idx;
	}
	
	function increaseHitsAndThen(callback) {
	    const idx = '${noticeData.data.BNOTICE_IDX}';
	    $.ajax({
	        url: '/notice/updateHits',
	        type: 'POST',
	        data: { idx: idx },
	        success: function(res) {
	            console.log('조회수 업데이트 완료');
	            if (typeof callback === 'function') callback(); // 모든 처리 후 실행할 콜백
	        },
	        error: function(xhr, status, error) {
	            console.error('조회수 업데이트 실패:', error);
	        }
	    });
	}
	
	function fn_list(){
		location.href = '/notice/list';
	}
</script>
<div class="wrap_in" id="fixNextTag">
    <span class="path">공지사항 &nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>

    <section class="type01">
        <h2 style="position:relative">
            <span class="title_s">Notice</span>
            <span class="title">공지사항 상세</span>
        </h2>

        <div class="group01 mt20">
            <div class="title"></div>
            <div id="tab1_div">
                <div class="title2" style="width: 80%;"><span class="txt">기본정보</span></div>
                <div class="main_tbl">
                    <table class="insert_proc01">
                        <colgroup>
                            <col width="20%" />
                            <col width="20%" />
                            <col width="20%" />
                            <col width="40%" />
                        </colgroup>
                        <tbody>
                            <tr>
                                <th>제목</th>
                                <td colspan="3">${noticeData.data.TITLE}</td>
                            </tr>
                            <tr>
                                <th>유형</th>
                                <td>
                                    <c:choose>
                                        <c:when test="${noticeData.data.TYPE == 'I'}"><span style="color: red;">[공지]</span></c:when>
                                        <c:otherwise>[일반]</c:otherwise>
                                    </c:choose>
                                </td>
							    <th>게시 기간</th>
							    <td>
							        <c:choose>
							            <c:when test="${empty noticeData.data.POST_START_DATE || empty noticeData.data.POST_END_DATE}">
							                &nbsp;
							            </c:when>
							            <c:otherwise>
							                ${noticeData.data.POST_START_DATE} ~ ${noticeData.data.POST_END_DATE}
							            </c:otherwise>
							        </c:choose>
							    </td>
                            </tr>
                            <tr>
                                <th>팝업 노출</th>
                                <td>
                                    <c:choose>
                                        <c:when test="${noticeData.data.IS_POPUP == 'Y'}">사용</c:when>
                                        <c:otherwise>미사용</c:otherwise>
                                    </c:choose>
                                </td>
							    <th>팝업 노출 기간</th>
							    <td>
							        <c:choose>
							            <c:when test="${empty noticeData.data.POP_START_DATE || empty noticeData.data.POP_END_DATE}">
							                &nbsp;
							            </c:when>
							            <c:otherwise>
							                ${noticeData.data.POP_START_DATE} ~ ${noticeData.data.POP_END_DATE}
							            </c:otherwise>
							        </c:choose>
							    </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="title2 mt20" style="width: 80%;"><span class="txt">내용</span></div>
     			<div>
					<table class="insert_proc01" style="border-bottom: 2px solid #4b5165;">
						<tr>
							<td>${noticeData.data.CONTENT}</td>
						</tr>
					</table>
				</div>
            
	      		<div class="title2 mt20"  style="width:90%;"><span class="txt">첨부파일</span></div>
				<div class="con_file" style="">
					<ul>
						<li class="point_img">
							<dt>첨부파일</dt><dd>
								<ul>
									<c:forEach items="${noticeData.fileList}" var="fileList" varStatus="status">
										<li>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
									</c:forEach>
								</ul>
							</dd>
						</li>
					</ul>
				</div>
            </div>
        	<div class="main_tbl">
				<div class="btn_box_con5">					
				</div>
				<div class="btn_box_con4">
					<button class="btn_admin_sky" onclick="javascript:fn_update('${noticeData.data.BNOTICE_IDX}')">수정</button>
					<button class="btn_admin_gray" onClick="fn_list();" style="width: 120px;">목록</button>
				</div>
				<hr class="con_mode" />
			</div>
        </div>
    </section>
</div>
