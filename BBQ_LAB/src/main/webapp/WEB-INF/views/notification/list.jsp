<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<title>공지사항</title>
<style></style>
<script type="text/javascript">

const today = new Date();

$(document).ready(function () {
	fn_loadList(1);

	// 요청일자
	$("#searchStartDate").datepicker({
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
	$("#searchEndDate").datepicker({
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

function fn_loadList(pageNo = 1) {
	const viewCount = $("#viewCount").val() || 10;

	$.ajax({
		type: "POST",
		url: "/notification/selectListAjax", // API 엔드포인트는 /list/json 등으로 분리 가능
		data: {
			searchType: $("#searchType").val(),
			searchValue: $("#searchValue").val(),
			searchStartDate: $("#searchStartDate").val(),
			searchEndDate: $("#searchEndDate").val(),
			viewCount: viewCount,
			pageNo: pageNo
		},
		dataType: "json",
		success: function (data) {
			fn_renderList(data.list);
			$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
			$('#pageNo').val(data.navi.pageNo);
		},
		error: function (xhr, status, err) {
			alert("조회 중 오류 발생: " + err);
			var html = "";
			$("#list").html(html);
			html += "<tr><td align='center' colspan='5'>오류가 발생하였습니다.</td></tr>";
			$("#list").html(html);
			$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
			$('#pageNo').val(data.navi.pageNo);
		}
	});
}

function fn_renderList(list) {
    const $tbody = $("#list");
    $tbody.empty();

    if (!list || list.length === 0) {
        $tbody.append("<tr><td colspan='4' style='text-align:center;'>데이터가 없습니다.</td></tr>");
        return;
    }

    list.forEach(function (item, index) {
        let row = "";
        row += "<tr>";
        row += "<td>" + item.TYPE_TXT + "</td>";
        row += "<td>" + item.MESSAGE + "</td>";
        row += "<td>" + item.DOC_NAME + "</td>";
        row += "<td>" + nvl2(item.TITLE,'') + "</td>";
        row += "<td>" + item.REG_DATE + "</td>";
        row += "<td>" + nvl2(item.REG_USER_NAME,'') + "</td>";
        row += "</tr>";
        $tbody.append(row);
    });
}

function fn_searchClear() {
	$("#searchType").val("");
	$("#searchValue").val("");
	$("#searchStartDate").val("");
	$("#searchEndDate").val("");
    // 셀렉트 초기화 + 라벨 갱신
    $("#searchNotiType").val("");
    $("#searchNotiType_label").text("전체");
	$("#viewCount").val("10");
}

function isNoticePeriodValid(startDateStr, endDateStr) {
    if (!startDateStr || !endDateStr) return false;
    const startDate = new Date(startDateStr);
    const endDate = new Date(endDateStr);
    const today = new Date();

    // 시간 제거 (00:00:00 으로 맞추기)
    startDate.setHours(0, 0, 0, 0);
    endDate.setHours(23, 59, 59, 999);
    today.setHours(0, 0, 0, 0);

    return startDate <= today && today <= endDate;
}

function paging( pageNo ) {
	fn_loadList(pageNo);
}

function fn_search() {
	fn_loadList(1);
}
</script>
<input type="hidden" name="pageNo" id="pageNo" value="${paramVO.pageNo}">
<input type="hidden" name="imNo" id="imNo" value="">
<div class="wrap_in" id="fixNextTag">
	<span class="path">시스템 알림&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Notification</span>
			<span class="title">시스템 알림</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button type="button" class="btn_circle_red" onClick="javascript:fn_insertForm();">&nbsp;</button>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="tab02">
				<!--  ul>
					<a href="/material/list"><li class="select">자재관리</li></a>
					<a href="/material/changeList"><li class="">변경관리</li></a>
				</ul-->
			</div>
			<div class="search_box" >
				<ul style="border-top:none">
					<li>
						<dt>키워드</dt>
						<dd >
							<!-- 초기값은 보통으로 -->
							<div class="selectbox" style="width:100px;">  
								<label for="searchType" id="searchType_label">선택</label> 
								<select name="searchType" id="searchType">
									<option value="">선택</option>
									<option value="searchName">요청자</option>
									<option value="searchContent">내용</option>
								</select>
							</div>
							<input type="text" name="searchValue" id="searchValue" value="" style="width:180px; margin-left:5px;">
						</dd>
					</li>
					<li>
						<dt>등록일</dt>
						<dd style="display: contents;">
							<input type="text" id="searchStartDate" class="req" placeholder="" readonly style="width: 150px; border: 1px solid #c5c5c5 !important;"> ~ <input type="text" id="searchEndDate" class="req" placeholder="" readonly style="width: 150px; border: 1px solid #c5c5c5 !important;">
						</dd>
					</li>
					<li>
						<dt>유형</dt>
						<dd >
							<div class="selectbox" style="width:100px;">  
								<label for="searchNotiType" id="searchNotiType_label">전체</label> 
								<select name="searchNoticeType" id="searchNoticeType">		
									<option value="">전체</option>												
								</select>
							</div>
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
				<table class="tbl01">
					<colgroup id="list_colgroup">
						<col width="10%">
						<col />
						<col width="15%">
						<col width="20%">
						<col width="12%">			
						<col width="10%">		
					</colgroup>
					<thead id="list_header">
						<tr>
							<th>알림유형</th>
							<th>내용</th>
							<th>문서유형</th>
							<th>제목</th>							
							<th>알림일자</th>
							<th>요청자</th>							
						<tr>
					</thead>
					<tbody id="list">						
					</tbody>
				</table>
				<div class="page_navi  mt10">
				</div>
			</div>
			<div class="btn_box_con"> 
			</div>
	 		<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
	</section>
</div>
