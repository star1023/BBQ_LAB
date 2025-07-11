<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>상품설계변경보고서</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="../resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
$(document).ready(function(){
	fn.autoComplete($("#keyword"));
});

function downloadFile(idx){
	location.href = '/common/fileDownload?idx='+idx;
}

function fn_list() {
	location.href = '/designReport/list';
}

function fn_apprSubmit(){
	if( $("#apprLine option").length == 0 ) {
		alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 결재상신 해 주세요.");
		return;
	} else {
		$('#lab_loading').show();
		var formData = new FormData();
		formData.append("docIdx",'${designData.data.DESIGN_IDX}');
		formData.append("apprComment", $("#apprComment").val());
		formData.append("apprLine", $("#apprLine").selectedValues());
		formData.append("refLine", $("#refLine").selectedValues());
		formData.append("title", '${designData.data.TITLE}');
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
					alert("등록되었습니다.");
					$('#lab_loading').hide();
					fn_list();
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
/* 	var url = "/preview/designReportViewPopup?idx="+idx;
	console.log(idx);
	// 팝업 창 열기
	var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes"); */
	$('#lab_loading').show();
    fetch("/preview/designReportViewPopup?idx=" + idx)
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
			formData.append("docType", "DESIGN");
			formData.append("userId", "${userId}");
			formData.append("title", "${designData.data.TITLE}_상품설계변경보고서");
			
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
                a.download = "${designData.data.TITLE}_메뉴완료보고서.pdf";
                a.click();
                window.URL.revokeObjectURL(url);
                $('#lab_loading').hide();
            });
        });
}
</script>

<div class="wrap_in" id="fixNextTag">
	<span class="path">
		상품설계변경 보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Design Change Report</span><span class="title">상품설계변경보고서</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<c:if test="${designData.data.STATUS == 'REG' }">
							<button class="btn_small_search ml5" onclick="apprClass.openApprovalDialog()" style="float: left">결재</button>
						</c:if>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title2"  style="display: flex; justify-content:space-between; width: 100%;">
				<span class="txt">기본정보</span>
				<div class="pr15">
					<c:if test="${designData.data.STATUS eq 'COMP' && designData.data.DOC_OWNER eq userId}">
						<button class="btn_small_search" onclick="fn_pdfDownload('${designData.data.DESIGN_IDX}')">PDF 다운로드</button>
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
							<td colspan="3">${designData.data.TITLE}</td>
						</tr>
						<tr>
							<th style="border-left: none;">ERP코드</th>
							<td>
								${designData.data.SAP_CODE}
							</td>
							<th style="border-left: none;">제품명</th>
							<td>
								${designData.data.PRODUCT_NAME}
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<div class="title2" style="float: left; margin-top: 30px;">
				<span class="txt">변경 사유</span>
			</div>
			<table class="tbl05" style="border-top: 2px solid #4b5165;">
				<colgroup>
					<col />
				</colgroup>
				<tbody>
				<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
				<c:if test="${addInfoList.INFO_TYPE == 'REA' }">	
					<tr>
						<td>
							<div class="ellipsis_txt tgnl">${addInfoList.INFO_TEXT}</div>
						</td>						
					</tr>
				</c:if>	
				</c:forEach>	
				</tbody>
			</table>
			
			<div class="title2" style="float: left; margin-top: 30px;">
				<span class="txt">변경사항</span>
			</div>
			<table class="tbl05" style="border-top: 2px solid #4b5165;">
				<colgroup>
					<col width="15%">
					<col width="34%">
					<col />
					<col width="15%">
				</colgroup>
				<thead>
					<tr>
						<th>구분</th>
						<th>기존</th>
						<th>변경</th>
						<th>비고</th>
					</tr>
				</thead>
				<tbody>
				<c:forEach items="${designChangeList}" var="designChangeList" varStatus="status">
					<tr>
						<td>
							${designChangeList.ITEM_DIV}				
						</td>
						<td>
							${strUtil:getHtml(designChangeList.ITEM_CURRENT)}							
						</td>
						<td>
							${strUtil:getHtml(designChangeList.ITEM_CHANGE)}							
						</td>
						<td>
							${designChangeList.ITEM_NOTE}
						</td>
					</tr>
				</c:forEach>	
				</tbody>
			</table>
			
			<div class="title2" style="float: left; margin-top: 30px;">
				<span class="txt">변경 적용 시점</span>
			</div>
			<table class="tbl05" style="border-top: 2px solid #4b5165;">
				<colgroup>
					<col />
				</colgroup>
				<tbody>
				<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
				<c:if test="${addInfoList.INFO_TYPE == 'TIME' }">	
					<tr>
						<td>
							<div class="ellipsis_txt tgnl">${addInfoList.INFO_TEXT}</div>				
						</td>						
					</tr>
				</c:if>	
				</c:forEach>	
				</tbody>
			</table>
			
			<div class="title2 mt20"  style="width:90%;"><span class="txt">첨부파일</span></div>
			<div class="con_file" style="">
				<ul>
					<li class="point_img">
						<dt>첨부파일</dt><dd>
							<ul>
								<c:forEach items="${designData.fileList}" var="fileList" varStatus="status">
									<li>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
								</c:forEach>
							</ul>
						</dd>
					</li>
				</ul>
			</div>
			
			<div class="title2 mt20"  style="width:90%;"><span class="txt">기안문</span></div>
			<div>
				<table class="insert_proc01">
					<tr>
						<td>${designData.data.CONTENTS}</td>
					</tr>
				</table>
			</div>
			
			<div class="main_tbl">
				<div class="btn_box_con5">					
				</div>
				<div class="btn_box_con4">
					<button class="btn_admin_gray" onClick="fn_list();" style="width: 120px;">목록</button>
				</div>
				<hr class="con_mode" />
			</div>
		</div>
	</section>
</div>

<!-- 결재 상신 레이어  start-->
<div class="white_content" id="approval_dialog">
	<input type="hidden" id="docType" value="DESIGN"/>
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
			<span class="title">상품설계변경보고서 결재 상신</span>
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