<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<title>이화학 검사 의뢰서</title>

<script type="text/javascript">
$(document).ready(function () {
	
	fn_loadList(1, isUserSafeTeam(), isRequestList());
	// 요청일자
	$("#requestDate").datepicker({
		showOn: "both",
		buttonImage: "/resources/images/btn_calendar.png",
		buttonImageOnly: true,
		buttonText: "Select date",
		dateFormat: "yy-mm-dd",
		showButtonPanel: true,
		changeMonth: true,
		changeYear: true,
		yearRange: "2000:2099"
	});

	// 희망 완료일
	$("#completeDate").datepicker({
		showOn: "both",
		buttonImage: "/resources/images/btn_calendar.png",
		buttonImageOnly: true,
		buttonText: "Select date",
		dateFormat: "yy-mm-dd",
		showButtonPanel: true,
		changeMonth: true,
		changeYear: true,
		yearRange: "2000:2099"
	});

	// 트리거 이미지 위치 보정
	$('.ui-datepicker-trigger').css({
		'margin-left': '8px',
		'margin-top': '-5px',
		'cursor': 'pointer'
	});
});

let currentTabType = "R"; // 기본값

function fn_loadList(pageNo, isSafeTeam, isRequestList) {
    var URL = "../chemicalTest/selectChemicalTestListAjax";
    var viewCount = $("#viewCount").selectedValues()[0];
    if (viewCount == '') {
        viewCount = "10";
    }

 // 현재 탭에 따라 대상 tbody 선택
	var $listBody = isRequestList ? $("#requestListBody") : $("#resultListBody");
    
    $("#list").html("<tr><td align='center' colspan='5'>조회중입니다.</td></tr>");
    $('.page_navi').html("");

    $.ajax({
        type: "POST",
        url: URL,
        data: {
            "searchType": $("#searchType").selectedValues()[0],
            "searchValue": $("#searchValue").val(),
            "searchFileTxt": $("#searchFileTxt").val(),
            "requestDate": $("#requestDate").val(),
            "completeDate": $("#completeDate").val(),
            "isSafeTeam": isSafeTeam ? 'Y' : 'N',
            "isRequestList": isRequestList ? 'N' : 'C',
            "listType": currentTabType,
            "viewCount": viewCount,
            "pageNo": pageNo,
            "testStatus": currentTabType
        },
		dataType:"json",
		success:function(data) {
			var html = "";
			if (data.totalCount > 0) {
				data.list.forEach(function (item) {
					if( item.STATUS == 'APPR_RET' ) {
						html += "<tr class=\"m_visible\">";
					} else {
						html += "<tr>";
					}
					html += "	<td><a href=\"#\" onClick=\"fn_view('" + item.CHEMICAL_IDX + "')\">" + nvl(item.PRODUCT_NAME, '&nbsp;') + "</a></td>";
					html += "	<td>" + nvl(item.REQUEST_DATE, '&nbsp;') + "</td>";
					html += "	<td>" + nvl(item.COMPLETION_DATE, '&nbsp;') + "</td>";

					if (!isRequestList) {
						html += "	<td>" + nvl(item.TEST_COMPLETION_DATE, '&nbsp;') + "</td>";
					}

					html += "	<td>" + nvl(item.REQUEST_USER, '&nbsp;') + "</td>";

					if (!isRequestList) {
						html += "	<td>" + nvl(item.TEST_MANAGER_NAME, '&nbsp;') + "</td>";
					}
					
					if (!isRequestList) {
						html += "	<td>" + nvl(item.TEST_STATUS_TXT, '&nbsp;') + "</td>";
					} else {
						html += "	<td>" + nvl(item.STATUS_TXT, '&nbsp;') + "</td>";
					}
					
					html += "	<td>" + nvl(item.DOC_OWNER_NAME, '&nbsp;') + "</td>";
					html += "	<td>";
					html += "		<li style=\"float:none; display:inline\">";
					html += "			<button class=\"btn_doc\" onclick=\"fn_viewHistory('" + item.CHEMICAL_IDX + "')\"><img src=\"/resources/images/icon_doc05.png\">이력</button>";
					console.log(item.DOC_OWNER);
					if( '${userUtil:getUserId(pageContext.request)}' == item.DOC_OWNER ) {
						if (item.STATUS == 'TMP') {
							html += "			<button class=\"btn_doc\" onclick=\"fn_update('" + item.CHEMICAL_IDX + "')\"><img src=\"/resources/images/icon_doc03.png\">수정</button>";
						}
						if (item.STATUS == 'TMP') {
							html += "			<button class=\"btn_doc\" onclick=\"fn_delete('" + item.CHEMICAL_IDX + "')\"><img src=\"/resources/images/icon_doc04.png\">삭제</button>";
						}
					}
					
					if (isUserSafeTeam() && item.TEST_STATUS != 'C') {
						html += "			&nbsp;<button class=\"btn_doc\" onclick=\"fn_update('" + item.CHEMICAL_IDX + "')\"><img src=\"/resources/images/icon_doc03.png\">결과입력</button>";
					}
					html += "		</li>";
					html += "	</td>";
					html += "</tr>";
				});
			} else {
				html = "<tr><td align='center' colspan='10'>데이터가 없습니다.</td></tr>";
			}

			$listBody.html(html);
			$(".page_navi").html(data.navi.prevBlock + data.navi.pageList + data.navi.nextBlock);
			$("#pageNo").val(data.navi.pageNo);		
		},
		error:function(request, status, errorThrown){
			var html = "";
			$("#list").html(html);
			html += "<tr><td align='center' colspan='7'>오류가 발생하였습니다.</td></tr>";
			$("#list").html(html);
			$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
			$('#pageNo').val(data.navi.pageNo);
		}			
	});
}

function fn_search() {
	fn_loadList(1, isUserSafeTeam(), isRequestList());
}

function fn_insertForm() {
	window.location.href = "../chemicalTest/insert";
}

function fn_view(idx) {
	window.location.href = "../chemicalTest/view?idx="+idx;
}

function fn_update(idx) {
	location.href = '/chemicalTest/update?idx='+idx;
}

function fn_delete(idx) {
	$('#lab_loading').show();
	var URL = "../chemicalTest/deleteChemicalTestAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"idx" : idx
		},
		dataType:"json",
		async:false,
		success:function(data) {
			if( data.RESULT == 'S' ) {
				alert("보고서가 삭제 되었습니다.");
				$('#lab_loading').hide();
				fn_loadList(1, isUserSafeTeam(), isRequestList());
			} else {
				alert("오류가 발생하였습니다.\n"+result.MESSAGE);
				$('#lab_loading').hide();
			}
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}
	});
}

function fn_viewHistory(idx) {
	var URL = "../chemicalTest/selectHistoryAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"idx" : idx
			, "docType" : "CHEMICAL"
		},
		dataType:"json",
		async:false,
		success:function(data) {
			var html = "";
			data.forEach(function (item) {
				html += "<li>";
				html += item.TITLE+" 이(가)";
				if( item.HISTORY_TYPE == 'I' ) {
					html += " 생성되었습니다.";
				} else if( item.HISTORY_TYPE == 'V' ) {
					html += " 개정되었습니다.";
				} else if( item.HISTORY_TYPE == 'D' ) {
					html += " 삭제되었습니다.";
				} else if( item.HISTORY_TYPE == 'U' ) {
					html += " 수정되었습니다.";
				} else if( item.HISTORY_TYPE == 'R' ) {
					html += " 검사가 완료되었습니다.";
				} 
				html += "<br/><span>"+item.USER_NAME+"</span>&nbsp;&nbsp;<span class=\"date\">"+item.REG_DATE+"</span>";
				html += "</li>"; 
			});
			$("#historyDiv").html(html);
			openDialog('dialog_history');
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}
	});
}

function fn_searchClear() {
    // 날짜 초기화
    $("#requestDate").val("");
    $("#completeDate").val("");

    // 키워드 초기화
    $("#searchType").val("").change(); // 선택 박스 초기화 후 change()로 라벨 갱신
    $("#searchType_label").text("선택");

    $("#searchValue").val("");
    $("#searchFileTxt").val(""); // 파일 내용 검색 텍스트 필드가 있다면

    // 표시수 초기화
    $("#viewCount").val("").change();
    $("#viewCount_label").text("선택");

}

function fn_changeTab(type) {
	currentTabType = type;

	// 탭 클래스 처리
	if (type === "R") {
		$("#myCount").addClass("select");
		$("#apprCount").removeClass("select");

		// 테이블 표시 제어
		$(".requestList").show();
		$(".resultList").hide();
	} else {
		$("#apprCount").addClass("select");
		$("#myCount").removeClass("select");

		// 테이블 표시 제어
		$(".requestList").hide();
		$(".resultList").show();
	}

	// 리스트 로딩
	fn_loadList(1, isUserSafeTeam(), isRequestList());
}

function isUserSafeTeam() {
	return ('${userUtil:getRoleCode(pageContext.request)}' == '6' || '${userUtil:getRoleCode(pageContext.request)}' == '7');
}

function isRequestList() {
	return currentTabType === 'R';
}
</script>
<c:set var="isSafeTeam" value="${userUtil:getRoleCode(pageContext.request) == '6' || userUtil:getRoleCode(pageContext.request) == '7'}" />
<input type="hidden" name="pageNo" id="pageNo" value="${paramVO.pageNo}">
<div class="wrap_in" id="fixNextTag">
	<span class="path">이화학 검사 의뢰서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Request For Chemical Test</span>
			<span class="title">이화학 검사 의뢰서</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<c:if test="${not isSafeTeam}">
							<button type="button" class="btn_circle_red" onClick="javascript:fn_insertForm();">&nbsp;</button>
						</c:if>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="tab02">
				<ul>
				<!-- 선택됬을경우는 탭 클래스에 select를 넣어주세요 -->
				<!-- 내 제품설계서 같은경우는 change select 이렇게 change 그대로 두고 한칸 띄고 select 삽입 -->
				<a href="#" onClick="fn_changeTab('R')"><li  class="select" id="myCount">의뢰 문서</li></a>
				<a href="#" onClick="fn_changeTab('C')"><li class="" id="apprCount">결과 문서</li></a>
				</ul>
			</div>
			<div class="search_box" >
				<ul style="border-top:none">
					<li>
						<dt>요청일자</dt>
						<dd>
							<input type="text" id="requestDate" class="req" placeholder="요청일 선택" readonly style="width: 150px;">
						</dd>
					</li>
					<li>
						<dt>희망 완료일</dt>
						<dd>
							<input type="text" id="completeDate" class="req" placeholder="완료일 선택" readonly style="width: 150px;">
						</dd>
					</li>
					<li>
						<dt>키워드</dt>
						<dd >
							<!-- 초기값은 보통으로 -->
							<div class="selectbox" style="width:100px;">  
								<label for="searchType" id="searchType_label">선택</label> 
								<select name="searchType" id="searchType">
									<option value="">선택</option>
									<option value="searchProduct">시료명</option>
									<option value="searchRequestUser">의뢰자</option>
									<option value="searchStandardContent">검사 기준</option>
									<option value="searchRequsetContent">요청 사항</option>
								</select>
							</div>
							<input type="text" name="searchValue" id="searchValue" value="" style="width:180px; margin-left:5px;">
						</dd>
					</li>
					<li>
						<dt>첨부 내용</dt>
						<dd >
							<input type="text" name="searchFileTxt" id="searchFileTxt" value="" style="width:180px;">
						</dd>
					</li>
					<li>
						<dt>표시수</dt>
						<dd >
							<div class="selectbox" style="width:100px;">  
								<label for="viewCount" id="viewCount_label">선택</label> 
								<select name="viewCount" id="viewCount">		
									<option value="">선택</option>													
									<option value="10">10</option>
									<option value="20">20</option>
									<option value="50">50</option>
									<option value="100">100</option>
								</select>
							</div>
						</dd>
					</li>
				</ul>
				<div class="fr pt5 pb10">
					<button type="button" class="btn_con_search" onClick="javascript:fn_search();"><img src="/resources/images/btn_icon_search.png" style="vertical-align:middle;"/> 검색</button>
					<button type="button" class="btn_con_search" onClick="javascript:fn_searchClear();"><img src="/resources/images/btn_icon_refresh.png" style="vertical-align:middle;"/> 검색 초기화</button>					
				</div>
			</div>
			<div class="main_tbl">
				<table class="tbl01 requestList">
					<colgroup id="list_colgroup">
						<col />
						<col width="13%">
						<col width="13%">
						<col width="13%">						
						<col width="13%">						
						<col width="13%">						
						<col width="15%">						
					</colgroup>
					<thead id="list_header">
						<tr>
							<th>시료명</th>
							<th>요청일</th>
							<th>희망완료일</th>
							<th>의뢰자</th>
							<th>문서상태</th> 
							<th>담당자</th> 
							<th></th> 
						</tr>
					</thead>
					<tbody id="requestListBody">						
					</tbody>
				</table>
				<table class="tbl01 resultList" style="display:none;">
					<colgroup id="list_colgroup">
						<col />
						<col width="10%">
						<col width="10%">
						<col width="10%">						
						<col width="10%">						
						<col width="10%">						
						<col width="10%">						
						<col width="10%">						
						<col width="12%">						
					</colgroup>
					<thead id="list_header">
						<tr>
							<th>시료명</th>
							<th>요청일</th>
							<th>희망완료일</th>
							<th>검사완료일</th>
							<th>의뢰자</th>
							<th>검사자</th>
							<th>검사상태</th> 
							<th>담당자</th> 
							<th></th> 
						</tr>
					</thead>
					<tbody id="resultListBody">						
					</tbody>
				</table>
				<div class="page_navi  mt10">
				</div>
			</div>
			<div class="btn_box_con">
				<c:if test="${not isSafeTeam}">
					<button class="btn_admin_red" onclick="javascript:fn_insertForm();">이화학 검사 의뢰서 생성</button>
				</c:if> 
			</div>
	 		<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
	</section>
</div>

<!-- 이력내역 레이어 start-->
<div class="white_content" id="dialog_history">
	<div class="modal"
		style="margin-left: -300px; width: 500px; height: 420px; margin-top: -210px">
		<h5 style="position: relative">
			<span class="title">문서이력</span>
			<div class="top_btn_box">
				<ul>
					<li><button class="btn_madal_close" onClick="closeDialog('dialog_history')"></button></li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul id="historyDiv" class="pop_notice_con history_option">
			</ul>
		</div>
		<div class="btn_box_con4" style="padding: 15px 0 20px 0">
			<button class="btn_admin_red" onclick="closeDialog('dialog_history')">확인</button>
		</div>
	</div>
</div>
<!-- 이력내역 레이어 생성레이어 close-->