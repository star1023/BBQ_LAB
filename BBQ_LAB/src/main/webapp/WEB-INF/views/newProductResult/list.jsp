<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<title>메뉴 품질 점검 결과 보고서</title>
<script src="/resources/js/jquery.ui.monthpicker.js"></script>
<script type="text/javascript">
$(document).ready(function () {
	fn_loadList(1);
	const startYear = new Date().getFullYear();

	const options = {
		dateFormat: 'yy-mm', // "02/2025" → "2025-02"로 바꾸기 위해 yy-mm 사용
		showOn: 'button',
		buttonImage: '/resources/images/btn_calendar.png',
		buttonImageOnly: true,

		monthNames: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		yearRange: '1900:2999',
		changeMonth: true,
		changeYear: true
	};

	// searchType이 "searchDate"일 때만 monthpicker 적용
	$('#searchType').change(function () {
		const selected = $(this).val();
		const $input = $('#searchValue');

		$input.val(''); // 기존 값 초기화

		if (selected === 'searchDate') {
			$input.attr('readonly', true);
			$input.monthpicker(options);
		} else {
			// 다른 옵션일 때 monthpicker 제거
			if ($input.data('monthpicker')) {
				$input.monthpicker('destroy');
			}
			$input.removeAttr('readonly');
		}
	});

	// 트리거 이미지 버튼 위치 조정
	$('.ui-monthpicker-trigger').css({
		'margin-left': '8px',
		'margin-top': '-5px',
		'cursor': 'pointer'
	});
	
	//1.임원인(roleCode가 4, 5) 경우에만 탭 설정 상관없이 팀, 담당자 필드를 표시한다.
	if( '${userUtil:getUserType(pageContext.request)}' == 'EXECUTIVE' ) {
		$("#searchTeam_li").show();
		$("#searchUser_li").show();
	}

});

function changeListType(listType){
	$('input[name=listType]').val(listType);
	
	$(".tab >a").each(function(){
		if( $(this).attr('id') == listType) {
			$(this).children().prop("class","select")
		} else {
			$(this).children().prop("class","change")			
		}
	});
	
	//1.팀장인 경우
	if( '${userUtil:getUserType(pageContext.request)}' == 'LEADER' ) {
		//2.my일 경우 팀, 담당자 항목을 숨김처리하고, 셀렉트값을 초기화 한다.
		//3.team일 경우 담당자 항목을 표시처리하고 팀을 로그인한 팀 코드로 설정 후 사용자를 조회한다.
		//4.share일 경우 팀, 담당자 항목을 숨김처리하고, 셀렉트값을 초기화 한다.
		if( listType == 'my' ) {
			$("#searchTeam_li").hide();
			$("#searchUser_li").hide();
			$("#searchTeam").selectOptions("");
			$("#searchUser").selectOptions("");
		} else if( listType == 'team' ) {
			$("#searchTeam_li").hide();
			$("#searchTeam").selectOptions('${SESS_AUTH.ORGAID}');
			fn_loadUser();
			$("#searchUser_li").show();
		} else if( listType == 'share' ) {
			$("#searchTeam_li").hide();
			$("#searchUser_li").hide();
			$("#searchTeam").selectOptions("");
			$("#searchUser").selectOptions("");
		} else if( listType == 'search' ) {
			$("#searchTeam_li").hide();
			$("#searchUser_li").hide();
			$("#searchTeam").selectOptions("");
			$("#searchUser").selectOptions("");
		}
	}
	fn_search();
}

function fn_loadUser() {
	if( $("#searchTeam").selectedValues()[0] != "" ) {
		var URL = "../common/userListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"teamId" : $("#searchTeam").selectedValues()[0]
			},
			dataType:"json",
			async:false,
			success:function(data) {
				var list = data;
				$("#searchUser").removeOption(/./);
				$("#searchUser").addOption("", "전체", false);
				$("#searchUser_label").html("전체");
				$.each(list, function( index, value ){ //배열-> index, value
					$("#searchUser").addOption(value.USER_ID, value.USER_NAME+"("+value.RESP_TXT+")", false);
				});
			},
			error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	} else {
		$("#searchUser").removeOption(/./);
		$("#searchUser").addOption("", "전체", false);
		$("#searchUser_label").html("전체");
	}
}

function fn_loadTeam() {
	var URL = "../common/teamListAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"pTeamId" : "10000752"
		},
		dataType:"json",
		async:false,
		success:function(data) {
			var list = data;
			$("#searchTeam").removeOption(/./);
			$("#searchTeam").addOption("", "전체", false);
			$("#searchTeam_label").html("전체");
			$.each(list, function( index, value ){ //배열-> index, value
				$("#searchTeam").addOption(value.TEAM_ID, value.TEAM_NAME, false);
			});
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}			
	});
}

function fn_loadList(pageNo) {
	var URL = "../newProductResult/selectNewProductResultListAjax";
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
			, "listType":$('#listType').val()
			, "searchTeam" : $("#searchTeam").selectedValues()[0]
			, "searchUser" : $("#searchUser").selectedValues()[0]
			, "viewCount":viewCount
			, "pageNo":pageNo
		},
		dataType:"json",
		success:function(data) {
			var html = "";
			if( data.totalCount > 0 ) {
				$("#list").html(html);
				data.list.forEach(function (item) {
					if( item.STATUS == 'APPR_RET' || item.STATUS == 'RET' ) {
						html += "<tr class=\"m_visible\">";
					} else {
						html += "<tr>";
					}
					html += "	<td onclick=\"fn_view('"+item.RESULT_IDX+"')\" style=\"cursor:pointer;\">";
					html += "		<div class=\"ellipsis_txt tgnl\">" + nvl(item.TITLE,'&nbsp;') + "</div>";
					html += "	</td>";

					html += "	<td onclick=\"fn_view('"+item.RESULT_IDX+"')\" style=\"cursor:pointer; text-align:center;\">" + nvl(item.EXCUTE_DATE,'&nbsp;') + "</td>";

					html += "	<td onclick=\"fn_view('"+item.RESULT_IDX+"')\" style=\"cursor:pointer;\">";
					var columnItems = item.COLUMN_STATE_TEXT && item.COLUMN_STATE_TEXT.trim() !== ""
					      ? item.COLUMN_STATE_TEXT.split(',').filter(v => v && v.trim() !== "")
					      : [];

					if (columnItems.length === 0) {
					  columnItems = ['업로드'];
					}
					for (var i = 0; i < columnItems.length; i++) {
						html += columnItems[i] + "<br>";
					}
					html += "</td>";

					html += "	<td onclick=\"fn_view('"+item.RESULT_IDX+"')\" style=\"cursor:pointer;\">" + nvl(item.STATUS_TXT,'&nbsp;') + "</td>";

					html += "	<td onclick=\"fn_view('"+item.RESULT_IDX+"')\" style=\"cursor:pointer;\">" + nvl(item.DOC_OWNER_NAME,'&nbsp;') + "</td>";

					html += "	<td>";
					html += "		<li style=\"float:none; display:inline\">";
					html += "			<button class=\"btn_doc\" onclick=\"javascript:fn_viewHistory('"+item.RESULT_IDX+"')\"><img src=\"/resources/images/icon_doc05.png\">이력</button>";
					if( '${userUtil:getUserId(pageContext.request)}' == item.DOC_OWNER && $('#listType').val() != 'search' ) {
						if( item.STATUS == 'TMP' || item.STATUS == 'COND_APPR' || item.STATUS == 'RET' ) {
							html += "			<button class=\"btn_doc\" onclick=\"javascript:fn_update('"+item.RESULT_IDX+"')\"><img src=\"/resources/images/icon_doc03.png\">수정</button>";
						}
						if( item.STATUS == 'TMP' ) {
							html += "			<button class=\"btn_doc\" onclick=\"javascript:fn_delete('"+item.RESULT_IDX+"')\"><img src=\"/resources/images/icon_doc04.png\">삭제</button>";
						}
					}
					html += "		</li>";
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
			html += "<tr><td align='center' colspan='5'>오류가 발생하였습니다.</td></tr>";
			$("#list").html(html);
			$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
			$('#pageNo').val(data.navi.pageNo);
		}			
	});
}

function fn_search() {
	fn_loadList(1);
}

function fn_insertForm() {
	window.location.href = "../newProductResult/insert";
}

function fn_view(idx) {
	if( $('#listType').val() != 'search' ) {
		window.location.href = "../newProductResult/view?idx="+idx;
	}
}

function fn_update(idx) {
	location.href = '/newProductResult/update?idx='+idx;
}

function fn_delete(idx) {
	$('#lab_loading').show();
	var URL = "../newProductResult/deleteNewProductAjax";
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
				fn_loadList(1);
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

function fn_searchClear() {
    // 키워드 검색 초기화
    const searchTypeSelect = document.getElementById("searchType");
    const searchTypeLabel = document.getElementById("searchType_label");
    if (searchTypeSelect && searchTypeLabel) {
        searchTypeSelect.value = "";
        searchTypeLabel.textContent = "선택";
    }

    const searchValueInput = document.getElementById("searchValue");
    if (searchValueInput) {
        searchValueInput.value = "";
    }

    // 첨부내용 초기화
    const searchFileTxtInput = document.getElementById("searchFileTxt");
    if (searchFileTxtInput) {
        searchFileTxtInput.value = "";
    }

    // 표시수 초기화
    const viewCountSelect = document.getElementById("viewCount");
    const viewCountLabel = document.getElementById("viewCount_label");
    if (viewCountSelect && viewCountLabel) {
        viewCountSelect.value = "";
        viewCountLabel.textContent = "선택";
    }
}

function fn_viewHistory(idx) {
	var URL = "../newProductResult/selectHistoryAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"idx" : idx
			, "docType" : "RESULT"
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
				} else if( item.HISTORY_TYPE == 'T' ) {
					html += " 임시 저장되었습니다.";
				} else if( item.HISTORY_TYPE == 'U' ) {
					html += " 수정되었습니다.";
				} else if( item.HISTORY_TYPE == 'P' ) {
					html += " PDF 다운로드 되었습니다.";
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

function paging( pageNo ) {
	fn_loadList(pageNo);
}
</script>

<input type="hidden" name="pageNo" id="pageNo" value="${paramVO.pageNo}">
<div class="wrap_in" id="fixNextTag">
	<span class="path">메뉴 품질 점검 결과 보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Menu Quality Test Report</span>
			<span class="title">메뉴 품질 점검 결과 보고서</span>
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
				<c:set var="listType" value="my"/>
				<c:choose>
					<c:when test='${userUtil:getUserType(pageContext.request) == "RESEARCHER"}'>
						<c:set var="listType" value="my" />
					</c:when>
					<c:when test='${userUtil:getUserType(pageContext.request) == "LEADER"}'>
						<c:set var="listType" value="my" />
					</c:when>
					<c:when test='${userUtil:getUserType(pageContext.request) == "EXECUTIVE"}'>
						<c:set var="listType" value="all" />
					</c:when>
				</c:choose>
				<input type="hidden" name="listType" id="listType" value="${listType}">
				<ul class="tab">
					<c:choose>
						<c:when test='${userUtil:getUserType(pageContext.request) == "LEADER"}'>
							<a href="javascript:changeListType('my')" id="my"><li class="select">'${userUtil:getUserName(pageContext.request)}님의 품질점검결과보고서</li></a>
							<a href="javascript:changeListType('team')" id="team"><li class="change">${userUtil:getDeptName(pageContext.request)} 품질점검결과보고서</li></a>
							<a href="javascript:changeListType('search')" id="search"><li class="change">전체 품질점검결과보고서</li></a>
						</c:when>
						<c:when test='${userUtil:getUserType(pageContext.request) == "RESEARCHER"}'>
							<a href="javascript:changeListType('my')" id="my"><li class="select">'${userUtil:getUserName(pageContext.request)}님의 품질점검결과보고서</li></a>
							<a href="javascript:changeListType('search')" id="search"><li class="change">전체 품질점검결과보고서</li></a>
						</c:when>
						<c:when test='${userUtil:getUserType(pageContext.request) == "EXECUTIVE"}'>
							<a href="javascript:changeListType('all')" id="all"><li class="change">전체 품질점검결과보고서</li></a>
						</c:when>
					</c:choose>	
				</ul>
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
									<option value="searchDate">시행월</option>
									<option value="searchColumnState">문서양식</option>
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
					<!--  
					<li>
						<dt>검색조건</dt>
						<dd >

						</dd>
					</li>
					--> 
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
						<col />
						<col width="15%">
						<col width="10%">
						<col width="15%">
						<col width="10%">						
						<col width="15%">						
					</colgroup>
					<thead id="list_header">
						<tr>
							<th>제목</th>
							<th>시행월</th>
							<th>문서양식</th>
							<th>문서상태</th>
							<th>담당자</th>
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
				<button class="btn_admin_red" onclick="javascript:fn_insertForm();">메뉴 품질 점검 결과 보고서 생성</button>
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