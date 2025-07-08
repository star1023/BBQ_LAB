<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ page session="false"%>
<title>BBQ세계식문화과학기술원</title>
<link href="../resources/css/main.css" rel="stylesheet" type="text/css" />
<style>

</style>
<script type="text/javascript"
	src="https://www.gstatic.com/charts/loader.js"></script>
<script
	src="${pageContext.request.contextPath}/resources/js/mainChart.js"></script>
<script type="text/javascript">
$(document).ready(function() {
	// 공지사항
	fn_loadList(1);
	fn_loadFaq(1);
	
	loadCode('FAQ_CATEGORY', 'searchFaqType')
	
	$('.tab-item').on('click', function () {
	  $('.tab-item').removeClass('active');
	  $(this).addClass('active');

	  const docType = $(this).data('doc');
	  drawBarChartByDocType(docType);
	});
	
    // 올린 결재 문서
    $("#my_reg").text(apprStatusData !== null ? apprStatusData.APPR_NCNT : 0);   // 대기 (상신)
    $("#my_ac").text(apprStatusData !== null ? apprStatusData.APPR_A_CNT + apprStatusData.APPR_C_CNT : 0);  // 반려
    $("#my_ret").text(apprStatusData !== null ? apprStatusData.APPR_R_CNT : 0);  // 반려
    $("#my_comp").text(apprStatusData !== null ? apprStatusData.APPR_Y_CNT : 0); // 완료

    // 받은 결재 문서
    $("#appr_reg").text(apprStatusData !== null ? apprStatusData.MY_APPR_CNT : 0); // 결재중 + 부분승인
   
    // 참조 문서
    $("#ref_today").text(apprStatusData !== null ? apprStatusData.REF_NO_READ_CNT : 0); // 미열람
    $("#ref_total").text(apprStatusData !== null ? apprStatusData.REF_TOTAL_CNT : 0);   // 전체
	
	$("#productDocCount").text(productDocCount || 0);
	$("#menuDocCount").text(menuDocCount || 0);
	
	$("#faq-prev-btn").on("click", function () {
	  if (faqCurrentIndex > 0) {
	    faqCurrentIndex--;
	    updateFaqSliderPosition();
	    $(".slider_item").removeClass("active").eq(faqCurrentIndex).addClass("active");

	    const itemCode = _faqCategoryFullList[faqCurrentIndex].itemCode;
	    fn_loadFaq(1, itemCode);
	  }
	});

	$("#faq-next-btn").on("click", function () {
	  if (faqCurrentIndex < _faqCategoryFullList.length - 1) {
	    faqCurrentIndex++;
	    updateFaqSliderPosition();
	    $(".slider_item").removeClass("active").eq(faqCurrentIndex).addClass("active");

	    const itemCode = _faqCategoryFullList[faqCurrentIndex].itemCode;
	    fn_loadFaq(1, itemCode);
	  }
	});
	
	$(document).on("click", ".barChartBtnBox2 .barChartBtn", function () {
	  const btnText = $(this).text().trim();
	  updatePieChartContext(btnText);
	});

	$(document).on("click", ".barChartBtnBox .barChartBtn", function () {
	  const btnText = $(this).text().trim();
	  updateBarChartContext(btnText);
	});
		
	$(document).on("click", ".faq-title", function () {
	  const $clickedItem = $(this).closest(".faq-item");

	  // 모든 항목 닫기
	  $(".faq-item").not($clickedItem).removeClass("active");

	  // 토글
	  $clickedItem.toggleClass("active");

	  // 스크롤 최상단으로 이동 (선택된 항목)
	  if ($clickedItem.hasClass("active")) {
	    $("html, body").animate({
	      scrollTop: $clickedItem.offset().top - 120 // 상단 여백 고려
	    }, 400);
	  }
	});
	
});
let _faqCategoryFullList = []; // 전체 FAQ 카테고리 저장용 전역변수
let faqCurrentIndex = 0;
const chartData1 = ${docCountJson != null ? docCountJson : '{}'};
const chartData2 = ${docStatusCountJson != null ? docStatusCountJson : '{}'};
const apprStatusData = ${apprStatusCountJson};
const productDocCount = ${productDocCount != null ? productDocCount : 0};
const menuDocCount = ${menuDocCount != null ? menuDocCount : 0};
const chartStatusData = transformFlatToNestedStatusData(chartData2);

//공지사항 //
function fn_loadList(pageNo = 1) {
 const viewCount = 7;  // 공지사항 7개만 표시

 $.ajax({
     type: "POST",
     url: "/notice/selectNoticeListAjax", // API 엔드포인트
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
         fn_renderDashboardList(data.list);
         fn_noticePopupFromList(data.list);  // 여기에 팝업 조건 체크
     },
     error: function (xhr, status, err) {
         alert("조회 중 오류 발생: " + err);
     }
 });
}

function transformFlatToNestedStatusData(flatData) {
  if (!flatData || typeof flatData !== 'object') return {}; // 🔒 안정화

  const result = {};
  Object.entries(flatData).forEach(([key, value]) => {
    const match = key.match(/^([A-Z_]+)_(TMP|REG|APPR|COND_APPR|COMP|RET)_CNT$/);
    if (!match) return;
    const docType = match[1];
    const status = match[2];
    if (!result[docType]) result[docType] = {};
    result[docType][status] = value;
  });
  return result;
}


function fn_renderDashboardList(list) {
  const $tbody = $("#noticeTableBody");
  $tbody.empty();

  const totalRows = 7; // 항상 7행 보이도록 설정
  let renderedCount = 0;

  if (!list || list.length === 0) {
    // 공지사항이 없으면 빈 행 7개 출력
    for (let i = 0; i < totalRows; i++) {
      $tbody.append("<tr><td colspan='3' style='height: 32px;'>&nbsp;</td></tr>");
    }
    return;
  }

  list.forEach(function (item) {
    const isNotice = item.TYPE === "I";
    const isValidPeriod = isNotice && isNoticePeriodValid(item.POST_START_DATE, item.POST_END_DATE);
    const trStyle = isNotice && isValidPeriod ? "style='background-color: rgba(255, 0, 0, 0.06);'" : "";

    let iconHtml = "";
    if (isNotice) {
      const iconStyle = isValidPeriod
        ? "filter: brightness(0) saturate(100%) invert(19%) sepia(94%) saturate(7468%) hue-rotate(353deg) brightness(89%) contrast(102%);"
        : "";

      iconHtml = "<span style='margin-left: 12px; display: inline-flex; align-items: center; gap: 15px;'>" +
        "<img src='/resources/images/icon_megaphone.png' style='width: 14px; height: 14px; " + iconStyle + "' />" +
        "</span>";
    }

    const trHtml = "<tr " + trStyle + ">" +
      "<td style='width: 80px; text-align: center;'>" + iconHtml + "</td>" +
      "<td style='text-align: center; width: 350px;'>" +
        "<a href=\"javascript:fn_viewDetail(" + item.BNOTICE_IDX + ");\">" + item.TITLE + "</a>" +
      "</td>" +
      "<td style='text-align: center;'>" + item.REG_DATE + "</td>" +
    "</tr>";

    $tbody.append(trHtml);
    renderedCount++;
  });

  // 부족한 행 수 만큼 빈 행 추가
  const remainingRows = totalRows - renderedCount;
  for (let i = 0; i < remainingRows; i++) {
    $tbody.append("<tr><td colspan='3' style='height: 32px;'>&nbsp;</td></tr>");
  }
}


function isNoticePeriodValid(startDateStr, endDateStr) {
 if (!startDateStr || !endDateStr) return false;

 const startDate = new Date(startDateStr);
 const endDate = new Date(endDateStr);
 const today = new Date();

 // 시간을 00:00:00으로 설정하여 날짜 비교
 startDate.setHours(0, 0, 0, 0);
 endDate.setHours(23, 59, 59, 999);
 today.setHours(0, 0, 0, 0);

 return startDate <= today && today <= endDate;
}

function fn_viewDetail(idx) {
	location.href = "/notice/view?idx=" + idx;
}

//공지사항 //

//popup //
function getCookie(name) {
 const match = document.cookie.match(new RegExp("(^| )" + name + "=([^;]+)"));
 return match ? match[2] : null;
}

let popupNoticeQueue = [];

function fn_noticePopupFromList(list) {
 if (!list || list.length === 0) return;

 const today = new Date();
 today.setHours(0, 0, 0, 0);

 popupNoticeQueue = list.filter(function(item) {
     if (item.IS_POPUP !== 'Y') return false;

     const skip = getCookie("notice_skip_" + item.BNOTICE_IDX);
     if (skip === "Y") return false;

     const start = new Date(item.POP_START_DATE);
     const end = new Date(item.POP_END_DATE);
     start.setHours(0, 0, 0, 0);
     end.setHours(23, 59, 59, 999);

     return start <= today && today <= end;
 });

 if (popupNoticeQueue.length > 0) {
     showNextNoticePopup();
 }
}

function showNextNoticePopup() {
 if (popupNoticeQueue.length === 0) {
     $("#noticeLayerPopup").hide();
     return;
 }

 const notice = popupNoticeQueue.shift();

 $("#popupNoticeTitle").text(notice.TITLE);
 $("#popupNoticeMeta").text("작성자: " + notice.REG_USER + " | 등록일: " + notice.REG_DATE);
 $("#popupNoticeContent").empty().html(notice.CONTENT);

 $("#popupNoticeTitle, .more-icon").data("noticeId", notice.BNOTICE_IDX);
 $("#popupTodaySkip").prop("checked", false);

 // 팝업 열기 + fadeIn 후 바로 스크롤 0
 $("#noticeLayerPopup").fadeIn(function () {
     $(".popup-container").scrollTop(0); // ✅ 정확한 스크롤 타겟
 });
}


function closeNoticeLayerPopup() {
 const currentId = $("#popupNoticeTitle").data("noticeId");
 const skip = $("#popupTodaySkip").is(":checked");

 if (skip && currentId) {
     const expires = new Date();
     expires.setHours(23, 59, 59, 999);
     document.cookie = "notice_skip_" + currentId + "=Y; expires=" + expires.toUTCString() + "; path=/";
 }

 $("#noticeLayerPopup").fadeOut(() => {
     showNextNoticePopup(); // 다음 팝업 표시
 });
}

function goToDetail() {
 const id = $("#popupNoticeTitle").data("noticeId");
 if (id) {
     location.href = "/notice/view?idx=" + id;
 }
}
//popup //
// FAQ //
function fn_loadFaq (pageNo=1, faqType = '1') {
	 const viewCount = 7;  // 공지사항 7개만 표시

	 $.ajax({
	     type: "POST",
	     url: "/faq/selectFaqListAjax", // API 엔드포인트
	     data: {
	         searchType: $("#searchType").val(),
	         searchValue: $("#searchValue").val(),
	         searchFaqType: faqType,
	         viewCount: viewCount,
	         pageNo: pageNo
	     },
	     dataType: "json",
	     success: function (data) {
	    	 fn_renderFaqList(data.list);
	     },
	     error: function (xhr, status, err) {
	         alert("조회 중 오류 발생: " + err);
	     }
	 });
}

function fn_renderFaqList(list) {
  var $dashboard = $(".dashboard03");
  $dashboard.empty();

  var html = '<div class="faq-list">';
  var maxRow = 7;
  var count = list.length;

  for (var i = 0; i < maxRow; i++) {
    if (i < count) {
      var item = list[i];
      html += '<div class="faq-item">';
      html += '  <div class="faq-title">';
      html += '    <span>Q. ' + item.QUESTION + '</span>';
      html += '    <span class="toggle-arrow">&gt;</span>';
      html += '  </div>';
      html += '  <div class="faq-content">' + item.ANSWER + '</div>';
      html += '</div>';
    } else {
      // 빈 줄에는 별도 클래스 추가 (보더 없음)
      html += '<div class="faq-item empty">';
      html += '  <div class="faq-title">';
      html += '    <span>&nbsp;</span>';
      html += '  </div>';
      html += '</div>';
    }
  }

  html += '</div>';
  $dashboard.append(html);
}
	
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

function renderFaqSlider() {
  const $track = $("#faq-slider-track");
  $track.empty();

  _faqCategoryFullList.forEach((item, index) => {
    const btn = $("<div>")
      .addClass("slider_item")
      .text(item.itemName)
      .attr("data-code", item.itemCode);

    if (index === faqCurrentIndex) btn.addClass("active");

    btn.on("click", function () {
      $(".slider_item").removeClass("active");
      $(this).addClass("active");
      fn_loadFaq(1, $(this).data("code"));
    });

    $track.append(btn);
  });

  updateFaqSliderPosition();
}


function updateFaqSliderPosition() {
  const track = document.getElementById("faq-slider-track");
  const viewport = document.querySelector(".slider_viewport");
  const items = document.querySelectorAll(".slider_item");

  if (!track || !viewport || items.length === 0) return;

  const itemWidth = items[0].offsetWidth;
  const itemMarginRight = 20;
  const totalItemWidth = itemWidth + itemMarginRight;

  const centerOffset = (viewport.offsetWidth - itemWidth) / 2;
  const translateX = -(faqCurrentIndex * totalItemWidth - centerOffset);

  track.style.transform = 'translateX('+translateX+'px)';

  // 버튼 상태 처리
  $("#faq-prev-btn").toggleClass("active", faqCurrentIndex > 0);
  $("#faq-next-btn").toggleClass("active", faqCurrentIndex < _faqCategoryFullList.length - 1);
}
	
// loadCode 이후 renderFaqSlider 호출 필요
function loadCode(codeId, selectBoxId) {
  $.ajax({
    type: "POST",
    url: "../common/codeListAjax",
    data: { groupCode: codeId },
    dataType: "json",
    success: function (data) {
      _faqCategoryFullList = data.RESULT;
      renderFaqSlider();
    },
    error: function () {
      alert("코드 조회 실패");
    }
  });
}

function getLabelFromText(text) {
  if (text === '${userData.userName}') {
  	return "내";	  
  }else if(text === '세계식문화과학기술원'){
  	return "전체";
  }else {
  	return "팀";
  }
}

function getLabelFromText2(text) {
  if (text === '${userData.userName}') {
  	return "내";	  
  }else {
  	return text;	  
  }
}

function updatePieChartContext(buttonText) {
  const label = getLabelFromText(buttonText);
  $("#pieChartTitle").text(label + " 보고서 현황");

  // 초기화 + 이후 차트 재렌더링
  $("#reportPieChart").empty();
  if (label === '내'){
	  drawPieChart();
  }else {	  
  // drawPieChartFor(label); ← 나중에 추가 예정
  }
}

function updateBarChartContext(buttonText) {
  const label = getLabelFromText2(buttonText);
  $("#barChartTitle").text(label + " 보고서 상태별 현황");

  // 초기화 + 이후 차트 재렌더링
  $("#reportBarChart").empty();
  if (label === '내'){
	  drawBarChartByDocType("PROD");
  }else {	  
  // drawPieChartFor(label); ← 나중에 추가 예정
  }

}
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path"> <a href="#">BBQ세계식문화과학기술원</a>
	</span>
	<section class="type01">
		<h2 style="position: relative">
			<span class="title_s">System main</span> <span class="title">BBQ 세계식문화과학기술원</span>
		</h2>
		<div class="group01">

			<!-- 내정보 start -->
			<div class="main_top_box">
				<div class="my_info_box">
					<div class="wd60">
						<div class="my_noti_box">
							<span class="noti_box_title">내 정보</span>
							<div class="noti_box_table">
								<div class="my_info_box_top">
									<div class="main_logo_img">
										<img alt="profilelogo" src="../resources/images/bbq_logo.png" style="width:70px;">
									</div>
									<div class="main_profile_info">
										<span class="user_dept">
											${userData.OBJTTX}
											<c:if test="${not empty userData.RESP_TXT}">
												<em>&nbsp;|&nbsp;</em>
												<strong class="ml5">${userData.RESP_TXT}</strong>
											</c:if>
										</span>
										<span class="user_name">
											${userData.userName}
											<strong	class="ml5">${userData.TITL_TXT}</strong>
										</span> 
										<span class="user_sub_info">
											제품완료보고서 <strong id="productDocCount">0</strong> 건 
											<em>&nbsp;|&nbsp;</em>
											메뉴완료보고서 <strong id="menuDocCount">0</strong> 건
										</span>
									</div>
									<div class="main_etc">
										
									</div>
								</div>
								<div class="my_info_box_bottom">
									<div style="width:100%;display:flex;justify-content: space-around;color: #808080;margin-bottom:0;padding-top: 15px;border-top: 2px #f0f0f0 solid;">
										<span>올린 결재 문서</span>
										<span>받을 결재 문서</span>
										<span>받은 참조 문서</span>
									</div>
									<div class="fl"
										style="width: 100%; box-sizing: border-box;">
										
										<div class="bottom_box_con01">
											<ul>
												<li><span> <strong>
														<a href="../approval/list" id="my_reg">0</a></strong> 
														<em>/</em> <a href="../approval/list" id="my_ac">0</a> 
														<em>/</em> <a href="../approval/list" id="my_ret">0</a> 
														<em>/</em> <a href="../approval/list?tab=comp" id="my_comp">0</a>
												</span> <br /> <em>(상신/진행/반려/완료)</em></li>
												<li><span> <strong><a
															href="../approval/list?tab=appr" id="appr_reg">0</a></strong>
												</span> <br /> <em>(미처리)</em></li>
												<li><span> <strong><a
															href="../approval/list?tab=ref" id="ref_today">0</a></strong> <em>/</em>
														<a href="../approval/list?tab=ref" id="ref_total">0</a>
												</span> <br /> <em>(미열람/전체)</em></li>
											</ul>
										</div>
									</div>
									<!--  
									<div class="fl" style="width: 30%">
									</div>
									-->
								</div>
							</div>
						</div>
					</div>
					<div class="wd40">
						<div class="chart-card-wrapper">
							<div class="chart-title">
								<span class="txt pieChart" id="pieChartTitle">내 보고서 현황</span>
								<div class="barChartBtnBox2">
									<c:if test='${userData.ORGAID == "10000065" || userData.RESP_TXT == "팀장"}'>
										<span class="barChartBtn">${userData.userName}</span>
										<span>|</span> <span class="barChartBtn">${userData.OBJTTX}</span> 
										<!-- <span>|</span>
										<span class="barChartBtn">부서</span> -->
									</c:if>
								</div>
							</div>
							<div class="chart-area pie">
								<div id="reportPieChart"
									style="width: 400px; height: 290px; margin: auto; padding: 5px 0;"></div>
							</div>
						</div>
					</div>
				</div>
				<!-- 내정보 close-->

				<div class="main_middle_box">
					<div class="my_info_box2">
						<div class="tab-wrapper">
							<div class="chart-card-wrapper">
								<div class="chart-title">
									<span class="txt-icon barChart" id="barChartTitle">내 보고서 상태별 현황</span>
									<div class="barChartBtnBox">
										<c:if test='${userData.ORGAID == "10000065" || userData.RESP_TXT == "팀장"}'>
											<span class="barChartBtn">${userData.userName}</span>
											<c:if test='${userData.ORGAID != "10000065"}'>
												<span>|</span> <span class="barChartBtn">${userData.OBJTTX}</span> 
											</c:if>
											<c:if test='${userData.ORGAID == "10000065"}'>
												<span>|</span> <span class="barChartBtn">유통상품</span> 
												<span>|</span> <span class="barChartBtn">BBQ상품개발</span> 
												<span>|</span> <span class="barChartBtn">F&B상품개발</span> 
												<span>|</span> <span class="barChartBtn">글로벌/신소재</span> 
												<span>|</span> <span class="barChartBtn">식품안전</span> 
											</c:if>
											<!-- <span>|</span>
											<span class="barChartBtn">부서</span> -->
										</c:if>
									</div>
								</div>
								<ul class="tab-menu">
									<li class="tab-item active" data-doc="PROD">제품개발</li>
									<li class="tab-item" data-doc="MENU">메뉴개발</li>
									<li class="tab-item" data-doc="DESIGN">상품설계</li>
									<li class="tab-item" data-doc="SENSE_QUALITY">관능&품질</li>
									<li class="tab-item" data-doc="PLAN">출장계획</li>
									<li class="tab-item" data-doc="TRIP">출장결과</li>
									<li class="tab-item" data-doc="RESEARCH">시장조사</li>
									<li class="tab-item" data-doc="RESULT">신제품품질</li>
									<li class="tab-item" data-doc="CHEMICAL">이화학검사</li>
									<li class="tab-item" data-doc="PACKAGE">표시사항기재</li>
								</ul>
								<div class="chart-area">
									<div id="reportBarChart"
										style="width: 100%; height: 275px; margin: auto;"></div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="board_box">
				<div class="wd60">
					<span class="noti_box_title">공지사항</span>
					<div class="dashboard02 scroll-wrapper" style="box-shadow: 1px 1px 2px 1px #93939380;">
					  <table class="tbl_dashboard" style="font-size: 14px; width: 100%;">
					    <thead>
					      <tr>
					        <th style='text-align: center;'></th>
					        <th style='text-align: center;'>제목</th>
					        <th style='text-align: center;'>등록일</th>
					      </tr>
					    </thead>
					    <tbody id="noticeTableBody">
					      <!-- JS에서 동적으로 tr만 삽입 -->
					    </tbody>
					  </table>
					</div>
				</div>
				<div class="wd40">
					<span class="noti_box_title">FAQ</span>
					<div style="box-shadow: 1px 1px 2px 1px #93939380; border : 1px solid #ddd;">
						<div class="slider_wrap">
						  <button id="faq-prev-btn">&lt;</button>
						  <div class="slider_viewport">
						    <div class="slider_track" id="faq-slider-track"></div>
						  </div>
						  <button id="faq-next-btn">&gt;</button>
						</div>
						<div class="dashboard03_wrap" >
							<div class="dashboard03">
								<div class="faq-list">
								  <!-- FAQ 항목 반복 -->
								  <div class="faq-item" data-index="0">
								    <div class="faq-title">
								    </div>
								    <div class="faq-content">
								    </div>
								  </div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<!-- 품목제조공정서 검색 close -->
			<div class="title2 mt30">
				<span class="txt">내문서 현황</span>
			</div>
			<div class="dashboard01"></div>
			<div class="btn_box_con"></div>
			<hr class="con_mode" />
			<!-- 신규 추가 꼭 데려갈것 !-->
		</div>
		<!-- 컨텐츠 close-->

	</section>
</div>

<!-- 🔔 공지사항 팝업 레이어 -->
<div id="noticeLayerPopup" class="popup-overlay" style="display: none;">
	<div class="popup-wrapper">
		<!-- 헤더 -->
		<div class="popup-header">
			<img src="/resources/images/bbq_logo.png" alt="BBQ Logo">
		</div>

		<!-- 팝업 본체 -->
		<div class="popup-container">
			<div class="popup-title">
				<span class="notice-title" id="popupNoticeTitle"
					onclick="goToDetail()"></span>
				<div class="more-icon" onclick="goToDetail()">
					<img src="/resources/images/icon_more.png" alt="돋보기" />
					<div>More</div>
				</div>
			</div>
			<div class="popup-meta" id="popupNoticeMeta"></div>
			<div class="popup-content" id="popupNoticeContent"></div>
		</div>

		<!-- 푸터 고정 -->
		<div class="popup-footer-fixed">
			<label><input type="checkbox" id="popupTodaySkip"> 오늘
				하루 보지 않기</label>
			<button class="btn-close" onclick="closeNoticeLayerPopup()">닫기</button>
		</div>
	</div>
</div>