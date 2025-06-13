<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<title>상품설계변경보고서</title>
<script type="text/javascript">
$(document).ready(function(){
	fn_loadList(1);
});

function fn_loadList(pageNo) {
	var URL = "../businessTrip/selectBusinessTripListAjax";
	var viewCount = $("#viewCount").selectedValues()[0];
	if( viewCount == '' ) {
		viewCount = "10";
	}
	$("#list").html("<tr><td align='center' colspan='5'>조회중입니다.</td></tr>");
	$('.page_navi').html("");
	
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"searchType" : $("#searchType").selectedValues()[0]
			, "searchValue" : $("#searchValue").val()
			, "searchFileTxt" : $("#searchFileTxt").val()
			, "viewCount":viewCount
			, "pageNo":pageNo
		},
		dataType:"json",
		success:function(data) {
			var html = "";
			if( data.totalCount > 0 ) {
				$("#list").html(html);
				data.list.forEach(function (item) {
					html += "<tr>";
					html += "	<td>"+nvl(item.TRIP_TYPE_TXT,'&nbsp;')+"</td>";
					html += "	<td><div class=\"ellipsis_txt tgnl\">&nbsp;&nbsp;<a href=\"#\" onClick=\"fn_view('"+item.TRIP_IDX+"')\">"+nvl(item.TITLE,'&nbsp;')+"</a></div></td>";					
					html += "	<td>"+nvl(item.TRIP_DESTINATION,'&nbsp;')+"</td>";
					html += "	<td>"+nvl(item.STATUS_TXT,'&nbsp;')+"</td>";
					html += "	<td>"+nvl(item.DOC_OWNER_NAME,'&nbsp;')+"</td>";
					html += "	<td>";
					if( item.IS_LAST == 'Y' ) {
						html += "		<li style=\"float:none; display:inline\">";
						html += "			<button class=\"btn_doc\" onclick=\"javascript:fn_viewHistory('"+item.TRIP_IDX+"')\"><img src=\"/resources/images/icon_doc05.png\">이력</button>";
						if( item.STATUS == 'COND_APPR' || item.STATUS == 'TMP' ) {
							html += "			<button class=\"btn_doc\" onclick=\"javascript:fn_update('"+item.TRIP_IDX+"')\"><img src=\"/resources/images/icon_doc03.png\">수정</button>";
						}
						html += "		</li>";
					}
					html += "	</td>";
					html += "</tr>"		
				});				
			} else {
				$("#list").html(html);
				html += "<tr><td align='center' colspan='6'>데이터가 없습니다.</td></tr>";
			}			
			$("#list").html(html);
			$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
			$('#pageNo').val(data.navi.pageNo);			
		},
		error:function(request, status, errorThrown){
			var html = "";
			$("#list").html(html);
			html += "<tr><td align='center' colspan='6'>오류가 발생하였습니다.</td></tr>";
			$("#list").html(html);
			$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
			$('#pageNo').val(data.navi.pageNo);
		}			
	});
}

function fn_insertForm() {
	window.location.href = "../businessTrip/insert";
}

function fn_view(idx) {
	window.location.href = "../businessTrip/view?idx="+idx;
}

function fn_update(idx) {
	location.href = '/businessTrip/update?idx='+idx;
}

function fn_viewHistory(idx) {
	var URL = "../businessTrip/selectHistoryAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"idx" : idx
			, "docType" : "TRIP"
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
</script>

<input type="hidden" name="pageNo" id="pageNo" value="${paramVO.pageNo}">
<div class="wrap_in" id="fixNextTag">
	<span class="path">출장결과보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Business Trip Report</span>
			<span class="title">출장결과보고서</span>
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
									<option value="searchName">제품명</option>
									<option value="searchTitle">제목</option>
								</select>
							</div>
							<input type="text" name="searchValue" id="searchValue" value="" style="width:180px; margin-left:5px;">
						</dd>
					</li>
					<li>
						<dt>검색조건</dt>
						<dd >

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
				<table class="tbl01">
					<colgroup id="list_colgroup">						
						<col width="8%">
						<col />						
						<col width="25%">
						<col width="10%">
						<col width="10%">						
						<col width="15%">						
					</colgroup>
					<thead id="list_header">
						<tr>
							<th>출장구분</th>
							<th>제목</th>							
							<th>출장지</th>
							<th>문서상태</th>
							<th>작성자</th>
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
				<button class="btn_admin_red" onclick="javascript:fn_insertForm();">출장결과보고서 생성</button>
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