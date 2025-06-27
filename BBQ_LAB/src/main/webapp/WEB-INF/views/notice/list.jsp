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
		url: "/notice/selectNoticeListAjax", // API 엔드포인트는 /list/json 등으로 분리 가능
		data: {
			searchType: $("#searchType").val(),
			searchValue: $("#searchValue").val(),
			searchStartDate: $("#searchStartDate").val(),
			searchEndDate: $("#searchEndDate").val(),
			searchNoticeType: $("#searchNoticeType").val(),
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
        $tbody.append("<tr><td colspan='6' style='text-align:center;'>데이터가 없습니다.</td></tr>");
        return;
    }

    list.forEach(function (item, index) {
        let row = "";
        const isNotice = item.TYPE === "I";
        const isValidPeriod = isNotice && isNoticePeriodValid(item.POST_START_DATE, item.POST_END_DATE);

        // ✅ 유효한 공지면 배경색 추가
        const trStyle = isNotice && isValidPeriod ? " style='background-color: rgba(255, 0, 0, 0.06);'" : "";

        row += "<tr" + trStyle + ">";

        // ✅ 타입 컬럼 처리
        if (isNotice) {
            const iconStyle = isValidPeriod
                ? "filter: brightness(0) saturate(100%) invert(19%) sepia(94%) saturate(7468%) hue-rotate(353deg) brightness(89%) contrast(102%);"
                : ""; // 검정 아이콘이면 필터 없음

            const textColor = isValidPeriod ? "#d15b47" : "#000";

            row += "<td style='white-space: nowrap; color: " + textColor + "'>" +
            "<span style='margin-left : 20px; display: inline-flex; align-items: center; gap: 8px;'>" +
            "<img src='/resources/images/icon_megaphone.png' style='width: 18px; height: 18px; " + iconStyle + "' />" +
            "</span></td>";
        } else {
            row += "<td></td>";
        }

    	// 제목 (유효한 공지는 BOLD 처리)
        if (isNotice && isValidPeriod) {
            row += "<td><a href=\"javascript:fn_viewDetail(" + item.BNOTICE_IDX + ");\"><b>" + item.TITLE + "</b></a></td>";
        } else {
            row += "<td><a href=\"javascript:fn_viewDetail(" + item.BNOTICE_IDX + ");\">" + item.TITLE + "</a></td>";
        }

        // 게시 기간
        if (item.POST_START_DATE && item.POST_END_DATE) {
            row += "<td>" + item.POST_START_DATE + " ~ " + item.POST_END_DATE + "</td>";
        } else {
            row += "<td></td>";
        }

        // 작성자 / 조회수
        row += "<td>" + item.REG_USER + "</td>";
        row += "<td>" + item.REG_DATE + "</td>";
        row += "<td>" + item.HITS + "</td>";

        // 버튼
        row += "<td>";
        row += "  <button class=\"btn_doc\" onclick=\"fn_viewHistory('" + item.BNOTICE_IDX + "', '" + item.BNOTICE_IDX + "')\"><img src=\"/resources/images/icon_doc05.png\">이력</button>";
        row += "  <button class=\"btn_doc\" onclick=\"fn_updatForm('" + item.BNOTICE_IDX + "')\"><img src=\"/resources/images/icon_doc03.png\">수정</button>";
        row += "  <button class=\"btn_doc\" onclick=\"fn_delete('" + item.BNOTICE_IDX + "')\"><img src=\"/resources/images/icon_doc04.png\">삭제</button>";
        row += "</td>";

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
    $("#searchNoticeType").val("");
    $("#searchNoticeType_label").text("전체");
	$("#viewCount").val("10");
}

function fn_insertForm() {
	location.href = "/notice/insert";
}

function fn_updatForm(idx) {
	location.href = "/notice/update?idx=" + idx;
}

function fn_viewDetail(idx) {
	location.href = "/notice/view?idx=" + idx;
}

function paging( pageNo ) {
	fn_loadList(pageNo);
}


function fn_delete(idx) {
    if (!confirm("정말 삭제하시겠습니까?")) {
        return; // 취소 시 아무 작업도 하지 않음
    }

    $.ajax({
        type: "POST",
        url: "/notice/deleteNoticeAjax",
        data: { idx: idx },
        dataType: "json",
        success: function(res) {
            if (res.success) {
                alert("삭제되었습니다.");
                fn_loadList(); // 목록 재조회
            } else {
                alert("삭제 실패: " + (res.message || "알 수 없는 오류"));
            }
        },
        error: function(xhr, status, error) {
            console.error("삭제 중 오류:", error);
            alert("서버 오류가 발생했습니다.");
        }
    });
}

function fn_viewHistory(idx, docNo) {
	var URL = "../notice/selectHistoryAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"idx" : idx
			, "docNo" : docNo
			, "docType" : "NOTICE"
		},
		dataType:"json",
		async:false,
		success:function(data) {
			var html = "";
			data.forEach(function (item) {
				html += "<li>";
				if( item.TITLE != '' ) {
					html += "공지사항 ("+item.TITLE+")이(가)";
				}
				
				if( item.HISTORY_TYPE == 'I' ) {
					html += " 생성되었습니다.";
				} else if( item.HISTORY_TYPE == 'V' ) {
					html += " 개정되었습니다.";
				} else if( item.HISTORY_TYPE == 'D' ) {
					html += " 삭제되었습니다.";
				} else if( item.HISTORY_TYPE == 'U' ) {
					html += " 수정되었습니다.";
				} else if( item.HISTORY_TYPE == 'T' ) {
					html += " 임시저장 되었습니다.";
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

function fn_search() {
	fn_loadList(1);
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
</script>
<input type="hidden" name="pageNo" id="pageNo" value="${paramVO.pageNo}">
<input type="hidden" name="imNo" id="imNo" value="">
<div class="wrap_in" id="fixNextTag">
	<span class="path">공지사항&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Notice</span>
			<span class="title">공지사항</span>
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
									<option value="searchTitle">제목</option>
									<option value="searchName">담당자</option>
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
								<label for="searchNoticeType" id="searchNoticeType_label">전체</label> 
								<select name="searchNoticeType" id="searchNoticeType">		
									<option value="">전체</option>												
									<option value="I" style="color:red;">[공지]</option>
									<option value="N">[일반]</option>
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
						<col width="32%">
						<col width="14%">			
						<col width="7%">			
						<col width="8%">			
						<col width="5%">			
						<col width="12%">						
					</colgroup>
					<thead id="list_header">
						<tr>
							<th></th>							
							<th>제목</th>
							<th>게시기간</th>
							<th>담당자</th>
							<th>등록일</th>
							<th>조회수</th>
							<th></th>
						<tr>
					</thead>
					<tbody id="list">						
					</tbody>
				</table>
				<div class="page_navi  mt10">
				</div>
			</div>
			<div class="btn_box_con"> 
				<button class="btn_admin_red" onclick="javascript:fn_insertForm();">공지사항 작성</button>
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
