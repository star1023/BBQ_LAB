<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<title>FAQ</title>
<style>
.faq-item {
    border-bottom: 1px solid #ddd;
    padding: 10px 0;
}
.faq-question {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    padding: 10px;
    gap: 10px;
    flex-wrap: nowrap;
}

.faq-left {
    flex: 1;
    min-width: 0;
    word-break: break-word;
}
.faq-title-wrapper {
    display: flex;
    align-items: center;
    gap: 24px;
    flex-wrap: nowrap;
}

.faq-category-token {
    display: inline-flex;
    justify-content: center;
    align-items: center;
    min-width: 80px;
    height: 24px;
    padding: 0 12px;
    border-radius: 12px;
    font-size: 12px;
    white-space: nowrap;
    flex-shrink: 0;
    font-weight: 500;
    border: 1px solid;
}

.faq-q-title {
    flex: 1;
    font-size: 15px;
    font-weight: bold;
    word-break: break-word;
    white-space: normal;
}

.faq-q-meta {
    flex-shrink: 0;
    font-size: 12px;
    color: #999;
    white-space: nowrap;
    display: flex;
    align-items: center;
    gap: 6px;
}

.faq-ctrl {
    text-align: right;
    margin-top: 10px;
}
.faq-ctrl button {
    margin-left: 5px;
}
.toggle-btn {
    border: none;
    background: none;
    font-size: 16px;
    cursor: pointer;
    transition: transform 0.3s ease;
}

/* 슬라이드용 transition */
.faq-answer {
    display: none;
    padding: 10px 15px;
    background: #f9f9f9;
    border-top: 1px solid #eee;
    overflow: hidden;
}

pre {
	font-size: 14px;
	font-family: '맑은고딕', Malgun Gothic;
}
</style>
<script type="text/javascript">
let _faqCategoryFullList = []; // 전체 FAQ 카테고리 저장용 전역변수

$(document).ready(function () {
	fn_loadList(1);
	loadCode('FAQ_CATEGORY', 'searchFaqType')
});

function loadCode(codeId,selectBoxId) {
	var URL = "../common/codeListAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{ groupCode : codeId
		},
		dataType:"json",
		async:false,
		success:function(data) {
			var list = data.RESULT;
			$("#"+selectBoxId).removeOption(/./);
			$("#"+selectBoxId).addOption("", "전체", false);
			$.each(list, function( index, value ){ //배열-> index, value
				$("#"+selectBoxId).addOption(value.itemCode, value.itemName, false);
			});
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}			
	});
}

function fn_loadList(pageNo = 1) {
	const viewCount = $("#viewCount").val() || 10;

	$.ajax({
		type: "POST",
		url: "/faq/selectFaqListAjax",
		data: {
			searchType: $("#searchType").val(),
			searchValue: $("#searchValue").val(),
			searchFaqType: $("#searchFaqType").val(),
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

function fn_searchClear() {
	$("#searchType").val("");
	$("#searchType_label").text("전체"); // ✅ 라벨도 초기화

	$("#searchValue").val("");

	$("#searchFaqType").val("");
	$("#searchFaqType_label").text("전체"); // ✅ 라벨도 초기화

	$("#viewCount").val("");
	$("#viewCount_label").text("선택"); // ✅ 라벨도 초기화
}

function fn_insertForm() {
	location.href = "/faq/insert";
}

function fn_updatForm(idx) {
	location.href = "/faq/update?idx=" + idx;
}

function fn_viewDetail(idx) {
	location.href = "/faq/view?idx=" + idx;
}

function paging( pageNo ) {
	fn_loadList(pageNo);
}

function fn_viewHistory(idx, docNo) {
	var URL = "../faq/selectHistoryAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"idx" : idx
			, "docNo" : docNo
			, "docType" : "FAQ"
		},
		dataType:"json",
		async:false,
		success:function(data) {
			
			var html = "";
			data.forEach(function (item) {
				html += "<li>";
				if( item.TITLE != '' ) {
					html += "FAQ ("+item.TITLE+")이(가)";
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

function fn_renderList(list) {
    var $container = $("#faqList");
    $container.empty();

    if (!list || list.length === 0) {
        $container.append("<div style='text-align:center; padding:20px;'>데이터가 없습니다.</div>");
        return;
    }

    list.forEach(function (item, index) {
        var html = "";
        html += "<div class='faq-item'>";
        const categoryName = item.CATEGORY_NAME || "-";
        const color = stringToColor(categoryName);

        html += "  <div class='faq-question' onclick='toggleAnswer(" + index + ")'>";
        html += "    <div class='faq-left'>";
        html += "      <div class='faq-title-wrapper'>";
        html += '<span class="faq-category-token" style="color:' + color.border +
		        '; border-color:' + color.border +
		        '; background-color:' + color.background + ';">' +
		        categoryName + '</span>';
        html += "        <span class='faq-q-title'>" + item.QUESTION + "</span>";
        html += "      </div>";
        html += "    </div>";
        html += "    <span class='faq-q-meta'>" + item.REG_USER + " | " + item.REG_DATE;
        html += "      <img src='/resources/images/img_dot.png' class='toggle-btn' id='btn-" + index + "' style='width: 18px; height: 18px; transition: transform 0.3s ease; margin-left: 8px;' />";
        html += "    </span>";
        html += "  </div>";
        html += "  <div class='faq-answer' id='answer-" + index + "' style='display:none;'>";
        html += "    <pre style='white-space:pre-wrap;'>" + item.ANSWER + "</pre>";
        html += "    <div class='faq-ctrl'>";
        html += "  <button class=\"btn_doc\" onclick=\"fn_updatForm('" + item.BFAQ_IDX + "')\"><img src=\"/resources/images/icon_doc03.png\">수정</button>&nbsp; |";
        html += "  <button class=\"btn_doc\" onclick=\"fn_delete('" + item.BFAQ_IDX + "')\"><img src=\"/resources/images/icon_doc04.png\">삭제</button>";
        html += "    </div>";
        html += "  </div>";
        html += "</div>";
        $container.append(html);
    });
}

function toggleAnswer(index) {
    const $answer = $("#answer-" + index);
    const $btn = $("#btn-" + index);
    const isOpen = $answer.is(":visible");

    if (isOpen) {
        $answer.slideUp(200);
        $btn.css("transform", "rotate(0deg)");
    } else {
        $answer.slideDown(200);
        $btn.css("transform", "rotate(90deg)");
    }
}

function stringToColor(str) {
    var hash = 0;
    for (var i = 0; i < str.length; i++) {
        hash = str.charCodeAt(i) + ((hash << 5) - hash);
    }
    var hue = Math.abs(hash % 360);
    return {
        border: 'hsl(' + hue + ', 60%, 70%)',
        background: 'hsla(' + hue + ', 40%, 75%, 0.1)'
    };
}

function fn_delete(idx) {
    if (!confirm("정말 삭제하시겠습니까?")) {
        return; // 취소 시 아무 작업도 하지 않음
    }

    $.ajax({
        type: "POST",
        url: "/faq/deleteFaqAjax",
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

</script>
<input type="hidden" name="pageNo" id="pageNo" value="${paramVO.pageNo}">
<input type="hidden" name="imNo" id="imNo" value="">
<div class="wrap_in" id="fixNextTag">
	<span class="path">FAQ&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Frequently Asked Questions</span>
			<span class="title">FAQ</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button type="button" class="btn_circle_red" onClick="javascript:fn_insertForm();">&nbsp;</button>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 FAQ</span--></div>
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
								<label for="searchType" id="searchType_label">전체</label> 
								<select name="searchType" id="searchType">
									<option value="">전체</option>
									<option value="searchQuestion">제목</option>
									<option value="searchAnswer">답변</option>
								</select>
							</div>
							<input type="text" name="searchValue" id="searchValue" value="" style="width:180px; margin-left:5px;">
						</dd>
					</li>
					<li>
						<dt>카테고리</dt>
						<dd >
							<div class="selectbox" style="width:100px;">  
								<label for="searchFaqType" id="searchFaqType_label">전체</label> 
								<select name="searchFaqType" id="searchFaqType">		
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
				<div class="faq-list" id="faqList"></div>
				<div class="page_navi mt10"></div>
			</div>
			<div class="btn_box_con"> 
				<button class="btn_admin_red" onclick="javascript:fn_insertForm();">FAQ 작성</button>
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
