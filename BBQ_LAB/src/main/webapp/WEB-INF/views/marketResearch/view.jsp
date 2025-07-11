<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>시장조사결과 보고서 생성</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 400px; min-height:150px;}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	$(document).ready(function(){
		fn.autoComplete($("#keyword"));
	});
	
	function fn_goList() {
		location.href = '/marketResearch/list';
	}
	
	function fn_apprSubmit(){
		if( $("#apprLine option").length == 0 ) {
			alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 결재상신 해 주세요.");
			return;
		} else {
			$('#lab_loading').show();
			var formData = new FormData();
			formData.append("docIdx",'${researchData.data.RESEARCH_IDX}');
			formData.append("apprComment", $("#apprComment").val());
			formData.append("apprLine", $("#apprLine").selectedValues());
			formData.append("refLine", $("#refLine").selectedValues());
			formData.append("title", '${researchData.data.TITLE}');
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
						alert("결재상신 되었습니다.");
						$('#lab_loading').hide();
						fn_goList();
					} else {
						alert("결재상신 오류가 발생하였습니다."+data.MESSAGE);
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
	
	function downloadFile(idx){
		location.href = '/common/fileDownload?idx='+idx;
	}
	
	function fn_update(idx) {
		location.href = '/marketResearch/update?idx='+idx;
	}
	function fn_pdfDownload(idx) {
 		/* var url = "/preview/marketResearchViewPopup?idx="+idx;
		console.log(idx);
		// 팝업 창 열기
		var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes"); */
		$('#lab_loading').show();
	    fetch("/preview/marketResearchViewPopup?idx=" + idx)
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
				formData.append("docType", "RESEARCH");
				formData.append("userId", "${userId}");
				var title = "${researchData.data.TITLE}_시장조사결과보고서";
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
	                a.download = title + ".pdf";
	                a.click();
	                window.URL.revokeObjectURL(url);
	                $('#lab_loading').hide();
	            });
	        });
	}
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">
		시장조사결과 보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Market Research Report</span><span class="title">시장조사결과보고서</span>
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
					<c:if test="${researchData.data.STATUS eq 'COMP' && researchData.data.DOC_OWNER eq userId}">
						<button class="btn_small_search" onclick="fn_pdfDownload('${researchData.data.RESEARCH_IDX}')">PDF 다운로드</button>
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
								${researchData.data.TITLE}
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">출장구분</th>
							<td colspan="3">
								${researchData.data.TRIP_TYPE_TXT}
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">대상업소</th>
							<td colspan="3">
								<c:forEach items="${infoList}" var="infoList" varStatus="status">
								<c:if test="${infoList.INFO_TYPE == 'NAME' }">
									${infoList.INFO_TEXT}<br>
								</c:if>
								</c:forEach>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">목적</th>
							<td colspan="3">	
								<c:forEach items="${infoList}" var="infoList" varStatus="status">
								<c:if test="${infoList.INFO_TYPE == 'PUR' }">
									${infoList.INFO_TEXT}<br>
								</c:if>
								</c:forEach>						
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">일시</th>
							<td colspan="3">
								${researchData.data.RESEARCH_DATE}
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">주소</th>
							<td colspan="3">
								<c:forEach items="${infoList}" var="infoList" varStatus="status">
								<c:if test="${infoList.INFO_TYPE == 'ADDRESS' }">
									${infoList.INFO_TEXT}<br>
								</c:if>
								</c:forEach>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">비용</th>
							<td colspan="3">
								<p style="white-space: pre-line; text-align:left;">${researchData.data.COST}</p>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">조사자</th>
							<td colspan="3">
								<table width="100%">
									<tr>
										<td>소속</td>
										<td>직위(직급)</td>
										<td>성명</td>
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
					</tbody>
				</table>
			</div>
			
			<div class="title2 mt20"  style="width:90%;"><span class="txt">첨부파일</span></div>
			<div class="con_file" style="">
				<ul>
					<li class="point_img">
						<dt>첨부파일</dt><dd>
							<ul>
								<c:forEach items="${researchData.fileList}" var="fileList" varStatus="status">
									<li>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
								</c:forEach>
							</ul>
						</dd>
					</li>
				</ul>
			</div>
							
			<div class="main_tbl">
				<div class="btn_box_con5">
					
				</div>
				<div class="btn_box_con4">
					<!-- 
					<button class="btn_admin_red">임시/템플릿저장</button>
					 -->
					<c:if test="${researchData.data.STATUS == 'TMP'}">
						<button class="btn_admin_sky" onclick="fn_update('${researchData.data.RESEARCH_IDX}')">수정</button>
					</c:if>
					<button class="btn_admin_gray" onClick="fn_goList();" style="width: 120px;">목록</button>
				</div>
				<hr class="con_mode" />
			</div>
		</div>
	</section>
</div>

<!-- 첨부파일 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_attatch">
	<div class="modal" style="margin-left: -355px; width: 710px; height: 480px; margin-top: -250px">
		<h5 style="position: relative">
			<span class="title">첨부파일 추가</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialogWithClean('dialog_attatch')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li class="pt10 mb5">
					<dt style="width: 20%">파일 선택</dt>
					<dd style="width: 80%" class="ppp">
						<div style="float: left; display: inline-block;">
							<span class="file_load" id="fileSpan">
								<input id="attatch_common_text" class="form-control form_point_color01" type="text" placeholder="파일을 선택해주세요." style="width:308px; float:left; cursor: pointer; color: black;" onclick="callAddFileEvent()" readonly="readonly">
								<input id="attatch_common" type="file" style="display:none;" onchange="setFileName(this)">
							</span>
							<button class="btn_small02 ml5" onclick="addFile(this, '00')">파일등록</button>
						</div>
						<div style="float: left; display: inline-block; margin-top: 5px">
							
						</div>
					</dd>
				</li>
				<li class=" mb5">
					<dt style="width: 20%">파일리스트</dt>
					<dd style="width: 80%;">
						<div class="file_box_pop" style="width:95%">
							<ul name="popFileList"></ul>
						</div>
					</dd>
				</li>
			</ul>
		</div>
		<div class="btn_box_con">
			<button class="btn_admin_red" onclick="uploadFiles();">파일 등록</button>
			<button class="btn_admin_gray" onClick="closeDialogWithClean('dialog_attatch')">등록 취소</button>
		</div>
	</div>
</div>
<!-- 파일 생성레이어 close-->

<!-- 결재 상신 레이어  start-->
<div class="white_content" id="approval_dialog">
	<input type="hidden" id="docType" value="RESEARCH"/>
 	<input type="hidden" id="deptName" />
	<input type="hidden" id="teamName" />
	<input type="hidden" id="userId" />
	<input type="hidden" id="userName"/>
 	<select style="display:none" id=apprLine name="apprLine" multiple>
 	</select>
 	<select style="display:none" id=refLine name="refLine" multiple>
 	</select>
	<div class="modal" style="	margin-left:-500px;width:1000px;height: 550px;margin-top:-300px">
		<h5 style="position:relative">
			<span class="title">시장조사결과보고서 결재 상신</span>
			<div  class="top_btn_box">
				<ul><li><button class="btn_madal_close" onClick="apprClass.apprCancel(); return false;"></button></li></ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li>
					<dt style="width:20%">결재요청의견</dt>
					<dd style="width:80%;">
						<div class="insert_comment">
							<table style=" width:756px">
								<tr>
									<td>
										<textarea style="width:100%; height:50px" placeholder="의견을 입력하세요" name="apprComment" id="apprComment"></textarea>
									</td>
									<td width="98px"></td>
								</tr>
							</table>
						</div>
					</dd>
				</li>
				<li class="pt5">
					<dt style="width:20%">결재자 입력</dt>
					<dd style="width:80%;" class="ppp">
						<input type="text" placeholder="결재자명 2자이상 입력후 선택" style="width:198px; float:left;" class="req" id="keyword" name="keyword">
						<button class="btn_small01 ml5" onclick="apprClass.approvalAddLine(this); return false;" name="appr_add_btn" id="appr_add_btn">결재자 추가</button>
						<button class="btn_small02  ml5" onclick="apprClass.approvalAddLine(this); return false;" name="ref_add_btn" id="ref_add_btn">참조</button>
						<div class="selectbox ml5" style="width:180px;">
							<label for="apprLineSelect" id="apprLineSelect_label">---- 결재라인 불러오기 ----</label>
							<select id="apprLineSelect" name="apprLineSelect" onchange="apprClass.changeApprLine(this);">
								<option value="">---- 결재라인 불러오기 ----</option>
							</select>
						</div>
						<button class="btn_small02  ml5" onclick="apprClass.deleteApprovalLine(this); return false;">선택 결재라인 삭제</button>
					</dd>
				</li>
				<li  class="mt5">
					<dt style="width:20%; background-image:none;" ></dt>
					<dd style="width:80%;">
						<div class="file_box_pop2" style="height:190px;">
							<ul id="apprLineList">
							</ul>
						</div>
						<div class="file_box_pop3" style="height:190px;">
							<ul id="refLineList">
							</ul>
						</div>
						<!-- 현재 추가된 결재선 저장 버튼을 누르면 안보이게 처리 start -->
						<div class="app_line_edit">
							저장 결재선라인 입력 :  <input type="text" name="apprLineName" id="apprLineName" class="req" style="width:280px;"/> 
							<button class="btn_doc" onclick="apprClass.approvalLineSave(this);  return false;"><img src="../resources/images/icon_doc11.png"> 저장</button> 
							<button class="btn_doc" onclick="apprClass.apprLineSaveCancel(this); return false;"><img src="../resources/images/icon_doc04.png">취소</button>
						</div>
						<!-- 현재 추가된 결재선 저장 버튼 눌렀을때 보이게 처리 close -->
					</dd>
				</li>
			</ul>
		</div>
		<div class="btn_box_con4" style="padding:15px 0 20px 0">
			<button class="btn_admin_red" onclick="fn_apprSubmit(); return false;">결재등록</button> 
			<button class="btn_admin_gray" onclick="apprClass.apprCancel(); return false;">결재삭제</button>
		</div>
	</div>
</div>
<!-- 결재 상신 레이어  close-->

<!-- 문서 검색 레이어 start-->
<div class="white_content" id="dialog_search">
	<div class="modal" style="	width: 700px;margin-left:-360px;height: 550px;margin-top:-300px;">
		<h5 style="position:relative">
			<span class="title">출장계획보고서 검색</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('dialog_search')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li>
					<dt>보고서검색</dt>
					<dd>
						<input type="text" value="" class="req" style="width:302px; float: left" name="searchValue" id="searchValue" placeholder="제목, 목적, 출장지, 업무내용 등을 입력하세요."/>
						<button class="btn_small_search ml5" onclick="fn_search()" style="float: left">조회</button>
					</dd>
				</li>
			</ul>
		</div>
		<div class="main_tbl" style="height: 300px; overflow-y: auto">
			<table class="tbl07">
				<colgroup>
					<col width="40px">
					<col/>
					<col width="23%">
					<col width="30%">
				</colgroup>
				<thead>
					<tr>
						<th></th>
						<th>제목</th>
						<th>출장지</th>
						<th>출장일</th>
					<tr>
				</thead>
				<tbody id="productLayerBody">
					<tr>
						<td colspan="4">검색해주세요</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</div>
<!-- 문서 검색 레이어 close-->