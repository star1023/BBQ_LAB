<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>상품설계변경 보고서 생성</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 400px; min-height:150px;}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	$(document).ready(function(){
		fn.autoComplete($("#keyword"));
		fn_changeDate();
	});
	
	function fn_goList() {
		location.href = '/businessTrip/list';
	}
	
	function fn_update(idx) {
		location.href = '/businessTrip/update?idx='+idx;
	}
	
	function downloadFile(idx){
		location.href = '/common/fileDownload?idx='+idx;
	}
	
	function fn_apprSubmit(){
		if( $("#apprLine option").length == 0 ) {
			alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 결재상신 해 주세요.");
			return;
		} else {
			$('#lab_loading').show();
			var formData = new FormData();
			formData.append("docIdx",'${businessTripData.data.TRIP_IDX}');
			formData.append("apprComment", $("#apprComment").val());
			formData.append("apprLine", $("#apprLine").selectedValues());
			formData.append("refLine", $("#refLine").selectedValues());
			formData.append("title", '${businessTripData.data.TITLE}');
			formData.append("docType", $("#docType").val());
			formData.append("status", "N");
			var URL = "../approval/insertApprAjax";
			$.ajax({
				type:"POST",
				url:URL,
				dataType:"json",
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				success:function(data) {
					if(data.RESULT == 'S') {
						alert("상신되었습니다.");
						$('#lab_loading').hide();
						fn_goList();
					} else {
						alert("결재선 상신 오류가 발생하였습니다."+data.MESSAGE);
						$('#lab_loading').hide();
						return;
					}
				},
				error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
					$('#lab_loading').hide();
				}			
			});
		}
	}
	
	function fn_pdfDownload(idx) {
/* 		var url = "/preview/businessTripViewPopup?idx="+idx;
		// 팝업 창 열기
		var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes"); */
		$('#lab_loading').show();
	    fetch("/preview/businessTripViewPopup?idx=" + idx)
	        .then(function(res) {
	            return res.text();
	        })
	        .then(function(html) {
	            var parser = new DOMParser();
	            var doc = parser.parseFromString(html, "text/html");

	            var wrapperHTML = doc.querySelector("#wrapper")?.outerHTML;
	            if (!wrapperHTML) {
	                alert("PDF 생성 실패: 출력할 wrapper 요소가 없습니다.");
	                $('#lab_loading').hide();
	                return;
	            }

	            // 전체 HTML로 감싸기 (백틱 없이)
				var fullHtml = ""
				  + "<html>"
				  + "<head>"
				  + "<meta charset='UTF-8'>"
				  + "<style>"
				  + "@page{margin:0}body{margin:0;padding:0;}@media print{body{margin:0;background:white!important;padding:10px}html,body{width:210mm;height:auto;background:white!important}}#wrapper{background:white;padding:20px;box-sizing:border-box}table{table-layout:fixed;border-collapse:collapse;width:100%}.main_tbl{margin:2.5px 0;table-layout:fixed;border-collapse:collapse;width:100%;border:1px solid #333}th{background-color:#f2f2f2;-webkit-print-color-adjust:exact}td,th{border-collapse:collapse;border:1px solid #bbb;text-align:left;font-size:12px;padding:7px}td{background-color:#fff}pre{margin:0;padding:0;line-height:1.5;white-space:pre-wrap}.inner-table-cell{padding:0;border-collapse:collapse}td.inner-table-cell{padding:1px!important}td.inner-table-cell table{border:1px solid #333}.mainTable{border:1px solid #000;margin:2.5px 0}.btn_print{width:36px;height:36px;border:none;background-color:transparent;cursor:pointer;margin-top:7px}"
				  + "</style>"
				  + "</head>"
				  + "<body>"
				  + wrapperHTML
				  + "</body>"
				  + "</html>";

	            var formData = new FormData();
	            formData.append("htmlContent", fullHtml);
	            formData.append("docIdx", idx);
				formData.append("docType", "TRIP");
				formData.append("userId", "${userId}");
				var title = "${businessTripData.data.TITLE}_출장결과보고서";
				formData.append("title", title);
				
	            fetch("/preview/downloadPdf", {
	                method: "POST",
	                body: formData
	            })
	            .then(function(res) {
	                return res.blob();
	            })
	            .then(function(blob) {
	                var url = window.URL.createObjectURL(blob);
	                var a = document.createElement("a");
	                a.href = url;
	                a.download = title+".pdf";
	                a.click();
	                window.URL.revokeObjectURL(url);
	                $('#lab_loading').hide();
	            });
	        });
	}
	
	function fn_changeDate() {
		var startDate = $("#tripStartDate").val();
		var endDate = $("#tripEndDate").val();
		if( startDate != '' && endDate != '' ) {
			var startDateArr = startDate.split('-');
		    var endDateArr = endDate.split('-');
		    var startDateObj = new Date(startDateArr[0], startDateArr[1], startDateArr[2]);
		    var endDateObj = new Date(endDateArr[0], endDateArr[1], endDateArr[2]);
		    var dif = endDateObj - startDateObj;
		    var cDay = 24 * 60 * 60 * 1000;// 시 * 분 * 초 * 밀리세컨
		    var difDay = parseInt(dif/cDay);
		    if( difDay > 0 ) {
		    	var start = difDay;
		    	var end = difDay+1;
		    	$("#txtTripDuration").html("출장기간("+start+"박 "+end+"일)");
		    } else {
		    	$("#txtTripDuration").html("출장기간(1일)");
		    }
		}
	}
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">
		출장결과 보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Design Change Report</span><span class="title">출장결과보고서</span>
			<div class="top_btn_box">
				<ul>
					<li>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title2"  style="display: flex; justify-content:space-between; width: 100%;">
				<span class="txt">기본정보</span>
				<div class="pr15">
					<c:if test="${businessTripData.data.STATUS eq 'COMP' && businessTripData.data.DOC_OWNER eq userId}">
						<button class="btn_small_search" onclick="fn_pdfDownload('${businessTripData.data.TRIP_IDX}')">PDF 다운로드</button>
					</c:if>
				</div>
			</div>
			<div class="main_tbl">
				<table class="insert_proc01">
					<colgroup>
						<col width="15%" />
						<col width="35%" />
						<col width="15%" />
						<col width="35%" />
					</colgroup>
					<tbody>
						<tr>
							<th style="border-left: none;">제목</th>
							<td colspan="3">
								${businessTripData.data.TITLE}
							</td>
						</tr>
						<c:if test="${userUtil:getUserId(pageContext.request) == businessTripData.data.DOC_OWNER }">
						<tr>
							<th style="border-left: none;">결재라인</th>
							<td colspan="3">
								<c:forEach items="${apprItemList}" var="apprItemList" varStatus="status">
									<c:if test="${status.count > 1}">
										&nbsp; > &nbsp; 
									</c:if>
									${apprItemList.TARGET_USER_NAME}										
								</c:forEach>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">참조자</th>
							<td colspan="3">
								<c:forEach items="${refList}" var="refList" varStatus="status">
									<c:if test="${status.count > 1}">
										&nbsp; , &nbsp; 
									</c:if>
									${refList.TARGET_USER_NAME}										
								</c:forEach>
							</td>
						</tr>
						</c:if>
						<tr>
							<th style="border-left: none;">출장구분</th>
							<td colspan="3">
								${businessTripData.data.TRIP_TYPE_TXT}
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">출장자</th>
							<td colspan="3">
								<table width="100%">
									<tr>
										<td width="35%">소속</td>
										<td width="35%">직위(직급)</td>
										<td width="2305%">성명</td>
									</tr>
									<tbody id="user_tbody" name="user_tbody">
									<c:forEach items="${userList}" var="userList" varStatus="status">
										<tr>
											<td>
												${userList.DEPT}
											</td>
											<td>
												${userList.POSITION}
											</td>
											<td>
												${userList.NAME}
											</td>
										</tr>
									</c:forEach>	
									</tbody>
								</table>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">출장목적</th>
							<td colspan="3">
								<c:forEach items="${infoList}" var="infoList" varStatus="status">
								<c:if test="${infoList.INFO_TYPE == 'PUR' }">
									${infoList.INFO_TEXT}<br>
								</c:if>
								</c:forEach>									
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">출장기간</th>
							<td colspan="3">
								${businessTripData.data.TRIP_START_DATE}
								&nbsp;~&nbsp;
								${businessTripData.data.TRIP_END_DATE}
								<input type="hidden" name="tripStartDate" id="tripStartDate" value="${businessTripData.data.TRIP_START_DATE}"/>
								<input type="hidden" name="tripEndDate" id="tripEndDate" value="${businessTripData.data.TRIP_END_DATE}"/>	
								<span id="txtTripDuration" name="txtTripDuration" style='margin-left:20px;'></span>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">출장지</th>
							<td>
								<c:forEach items="${infoList}" var="infoList" varStatus="status">
								<c:if test="${infoList.INFO_TYPE == 'DEST' }">
									${infoList.INFO_TEXT}<br>
								</c:if>
								</c:forEach>
							</td>
							<th style="border-left: none;">경유지</th>
							<td>
								<c:forEach items="${infoList}" var="infoList" varStatus="status">
								<c:if test="${infoList.INFO_TYPE == 'TRAN' }">
									${infoList.INFO_TEXT}<br>
								</c:if>
								</c:forEach>								
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">출장내용</th>
							<td colspan="3">
								<table width="100%">
									<tr>
										<td width="25%">일정</td>
										<td width="25%">세부내용</td>
										<td width="25%">장소</td>
										<td width="25%">비고</td>
									</tr>
									<tbody id="contents_tbody" name="contents_tbody">
									<c:forEach items="${contentsList}" var="contentsList" varStatus="status">	
										<tr>
											<td>
												${contentsList.SCHEDULE}
											</td>
											<td>
												${contentsList.CONTENT}												
											</td>
											<td>
												${contentsList.PLACE}												
											</td>
											<td>
												${contentsList.NOTE}												
											</td>
										</tr>
									</c:forEach>	
									</tbody>
								</table>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">업무수행내용</th>
							<td colspan="3">
								${businessTripData.data.TRIP_CONTENTS}
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">경비</th>
							<td colspan="3">
								<p style="white-space: pre-line; text-align:left;">${businessTripData.data.TRIP_COST}</p>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">초과사유</th>
							<td colspan="3">
								<p style="white-space: pre-line; text-align:left;">${businessTripData.data.OVER_REASON}</p>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">출장효과</th>
							<td colspan="3">
								<p style="white-space: pre-line; text-align:left;">${businessTripData.data.TRIP_EFFECT}</p>
							</td>
						</tr>						
					</tbody>
				</table>
			</div>
			
			<div class="title2 mt20"  style="width:90%;"><span class="txt">첨부파일</span></div>
			<div class="list_detail">
				<ul style="">
					<li>
						<dt style="width: 20%">첨부파일</dt>
						<dd style="width: 80%;">
							<div class="add_file" id="add_file2" style="width:100%">
								
							</div>
							<div id="fileList" class="file_box_pop" style="height: 120px; width: 100%; border-top-left-radius: 0px; border-top-right-radius: 0px; border-top: 1px solid rgb(221, 221, 221); box-sizing: border-box;">
								<ul id="attatch_file">
									<c:forEach items="${businessTripData.fileList}" var="fileList" varStatus="status">
										<li>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
									</c:forEach>
								</ul>	
							</div>
						</dd>
					</li>
				</ul>
			</div>
			<%-- <div class="con_file" style="">
				<ul>
					<li class="point_img">
						<dt>첨부파일</dt><dd>
							<ul>
								<c:forEach items="${businessTripData.fileList}" var="fileList" varStatus="status">
									<li>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
								</c:forEach>
							</ul>
						</dd>
					</li>
				</ul>
			</div> --%>
							
			<div class="main_tbl">
				<div class="btn_box_con5">
					
				</div>
				<div class="btn_box_con4">
					<c:if test="${userUtil:getUserId(pageContext.request) == businessTripData.data.DOC_OWNER }">
						<c:if test="${businessTripData.data.STATUS == 'TMP' || businessTripData.data.STATUS == 'COND_APPR' }">
							<button class="btn_admin_sky" onclick="fn_update('${businessTripData.data.TRIP_IDX}')">수정</button>
						</c:if>
					</c:if>
					<button class="btn_admin_gray" onClick="fn_goList();" style="width: 120px;">목록</button>
				</div>
				<hr class="con_mode" />
			</div>
		</div>
	</section>
</div>

<table id="tmpTable" class="tbl05" style="display:none">
	<tbody id="tmpChangeTbody" name="tmpChangeTbody">
		<tr id="tmpChangeRow_1" class="temp_color">
			<td>
				<input type="checkbox" id="change_1"><label for="change_1"><span></span></label>
			</td>
			<td>
				<input type="text" name="itemDiv" style="width: 99%" class="req code_tbl"/>							
			</td>
			<td>
				<textarea style="width:95%; height:50px" placeholder="기존정보를 입력하세요." name="itemCurrent" id="itemCurrent" class="req code_tbl"></textarea>
			</td>
			<td>
				<textarea style="width:95%; height:50px" placeholder="변경정보를 입력하세요." name="itemChange" id="itemChange" class="req code_tbl"></textarea>
			</td>
			<td>
				<input type="text" name="itemNote" style="width: 99%" class="req code_tbl"/>
			</td>
		</tr>
	</tbody>
</table>
