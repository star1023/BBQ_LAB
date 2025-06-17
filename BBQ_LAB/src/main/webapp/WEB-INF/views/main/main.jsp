<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ page session="false" %>
<title>연구개발시스템</title>
<link href="../resources/css/main.css" rel="stylesheet" type="text/css" />
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.popup-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    z-index: 9999;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: auto; /* ✅ 만약 팝업 전체가 넘칠 경우 대비 */
}

.popup-header img {
    height: 40px;
    margin: 5px 0 5px 0;
}
   
.popup-wrapper {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    z-index: 1000;
    width: 700px;
    background: none;
    display: flex;
    flex-direction: column;
    max-height: 80vh;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    border-radius: 16px;
    overflow: hidden;
}

.popup-header {
    background-color: #b32025;
    height: 60px;
    display: flex;
    align-items: center;
    padding: 0 20px;
    border-top-left-radius: 16px;
    border-top-right-radius: 16px;
    color: white;
    font-weight: bold;
    font-size: 16px;
}

.popup-container {
    background: #fff;
    overflow-y: auto;
    padding: 30px 40px;
    flex: 1; /* 본문이 남는 공간 차지 */
}

.popup-title {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 24px;
    font-weight: bold;
    color: #222;
    border-bottom: 2px solid #b92c35;
    padding-bottom: 10px;
    margin-bottom: 20px;
    margin-top: 10px;
}

.notice-title {
    cursor: pointer;
    transition: color 0.2s;
}
.notice-title:hover {
    color: #b92c35;
}

.more-icon {
    display: flex;
    flex-direction: column;
    align-items: center;
    font-size: 12px;
    color: #888;
    cursor: pointer;
}
.more-icon img {
    width: 20px;
    height: 20px;
    margin-bottom: 2px;
}
.more-icon:hover {
    color: #b92c35;
}

   .popup-title .more-btn {
       cursor: pointer;
       display: flex;
       align-items: center;
       gap: 4px;
   }

   .popup-meta {
       font-size: 14px;
       color: #666;
       margin-bottom: 20px;
   	text-align: right;
   }

   .popup-content {
       font-size: 16px;
       line-height: 1.8;
       white-space: pre-wrap;
   }

   .popup-footer {
       display: flex;
       justify-content: space-between;
       align-items: center;
       margin-top: 30px;
   }

   .popup-footer label {
       font-size: 14px;
       color: #555;
   }

   .btn-close {
       background: #3c8dbc;
       color: white;
       border: none;
       padding: 8px 16px;
       font-size: 14px;
       border-radius: 4px;
       cursor: pointer;
   }

   .btn-close:hover {
       background: #337ab7;
   }
   
   .popup-footer-fixed {
    background: #fff;
    border-top: 1px solid #ddd;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 15px 30px;
    height: 60px;
    box-sizing: border-box;
    border-bottom-left-radius: 16px;
    border-bottom-right-radius: 16px;
}
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
/* 공지사항 */
.tbl_dashboard {
    width: 100%;
    border-collapse: collapse;
    margin-top: 10px;
    border: 1px solid #c8c8c8;
}

.tbl_dashboard th, .tbl_dashboard td {
    padding: 8px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}

.tbl_dashboard th {
    background-color: #f4f4f4;
    font-weight: bold;
}

.tbl_dashboard td a {
    color: #333;
    text-decoration: none;
}

.tbl_dashboard td a:hover {
    color: #d15b47; /* 강조 색상 */
}
/* 공지사항 */
/* 차트 */
.group01 .title2 .txt.pieChart {
	background-image : url('/resources/images/main_pie_chart_icon.png') !important;
	background-size: 34px;  
    min-height: 20px;
    line-height: 34px;  
}

.chart-title {
  color: #fff;
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.chart-title .barChart {
  background-image: url('/resources/images/main_bar_chart_icon.png');
  background-size: 34px;
  background-repeat: no-repeat;
  background-position: left center;
  padding-left: 46px;
  color: #fff;
  line-height: 34px;
  margin: 10px 15px;
  height: 34px;

  /* ✅ 아이콘을 흰색처럼 보이게 하는 필터 */
  filter: brightness(0) invert(1);
}
.chart-title .pieChart {
  background-image: url('/resources/images/main_pie_chart_icon.png');
  background-size: 34px;
  background-repeat: no-repeat;
  background-position: left center;
  padding-left: 46px;
  color: #fff;
  line-height: 34px;
  margin: 10px 15px;
  height: 34px;

  /* ✅ 아이콘을 흰색처럼 보이게 하는 필터 */
  filter: brightness(0) invert(1);
}
.chart-card-wrapper {
  background: #b92c35;           /* ✅ 붉은 배경 */
  border-radius: 10px;
  padding: 10px;
  margin: 0 auto 20px;
}

.tab-menu {
  display: flex;
  padding: 0 8px;
  list-style: none;
  margin: 0;
  gap: 4px;
  background: transparent;
}

.tab-item {
  background-color: #e9ecef;
  padding: 6px 12px;
  border: 1px solid #ccc;
  border-bottom: none;
  border-top-left-radius: 6px;
  border-top-right-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  height: 22px;
  line-height: 22px;
  position: relative;
  z-index: 1;
  transition: background 0.2s ease;
}

.tab-item.active {
  background: white;
  font-weight: bold;
  z-index: 2;
  border-bottom: 1px solid white; /* 차트 배경과 맞추기 */
}

.chart-area {
  background: white;
  border-radius: 6px;
  position: relative;
  padding: 20px;
  z-index: 1;
}

#reportBarChart {
  width: 100%;
  height: 275px;
}
/* 차트 */
</style>
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/mainChart.js"></script>
<script type="text/javascript">
$(document).ready(function() {
	// 공지사항
	fn_loadList(1);
	
	$('.tab-item').on('click', function () {
	  $('.tab-item').removeClass('active');
	  $(this).addClass('active');

	  const docType = $(this).data('doc');
	  drawBarChartByDocType(docType);
	});
});

const chartData1 = ${docCountJson};
const chartData2 = ${docStatusCountJson};
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
 const $dashboard = $(".dashboard02");
 $dashboard.empty();

 if (!list || list.length === 0) {
     $dashboard.append("<p>공지사항이 없습니다.</p>");
     return;
 }

 let tableHtml = "<table class='tbl_dashboard' style='font-size: 14px; width: 100%;'><thead><tr>";
 tableHtml += "<th style='text-align: center;'></th><th style='text-align: center;'>제목</th><th style='text-align: center;'>작성자</th><th style='text-align: center;'>등록일</th><th style='text-align: center;'>조회수</th></tr></thead><tbody>";

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
                     "<img src='/resources/images/lab_notice_handwriting.png' style='height: 14px; width: 60px; " + iconStyle + "' alt='Notice!'/>" +
                     "</span>";
     }

     tableHtml += "<tr " + trStyle + ">";
     tableHtml += "<td style='width: 140px; text-align:center;'>" + iconHtml + "</td>";
     tableHtml += "<td style='text-align: center; width: 500px;'><a href=\"javascript:fn_viewDetail(" + item.BNOTICE_IDX + ");\">" + item.TITLE + "</a></td>";
     tableHtml += "<td style='text-align: center;'>" + item.REG_USER + "</td>";
     tableHtml += "<td style='text-align: center;'>" + item.REG_DATE + "</td>";
     tableHtml += "<td style='text-align: center;'>" + item.HITS + "</td>"; // 조회수 추가
     tableHtml += "</tr>";
 });

 tableHtml += "</tbody></table>";
 $dashboard.append(tableHtml);
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
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">
		<a href="#">제너시스 BBQ연구소</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">System main</span>
			<span class="title">제너시스 BBQ연구소</span>
		</h2>
		<div class="group01" >
		<!-- 내정보 start -->
			<div class="main_top_box">
			<div class="my_info">
					<div class="my_info_box">
						<div class="chart-card-wrapper">
							<div class="chart-title">
								<span class="txt pieChart">내 보고서 현황</span>
							</div>
							<div class="chart-area">
								<div id="reportPieChart" style="width: 400px; height: 290px; margin: auto; padding : 5px 0;"></div>
							</div>
						</div>
					</div>
			</div>
			
			<!-- 내정보 close-->
			<!-- 사이공백 -->
			<div class="main_top_box_blank"></div>

			</div>
			
			<div class="main_middle_box">
				<div class="my_info_box2">
					<div class="tab-wrapper">
						<div class="chart-card-wrapper">
						    <div class="chart-title">
							  <span class="txt-icon barChart">내 보고서 상태별 현황</span>
							</div>
							<ul class="tab-menu">
						        <li class="tab-item active" data-doc="PROD">제품개발</li>
						        <li class="tab-item" data-doc="MENU">메뉴개발</li>
						        <li class="tab-item" data-doc="DESIGN">상품설계</li>
						        <li class="tab-item" data-doc="SENSE_QUALITY">관능&품질</li>
								<li class="tab-item" data-doc="TRIP">출장계획</li>
								<li class="tab-item" data-doc="TRIP_RESULT">출장결과</li>
								<li class="tab-item" data-doc="RESEARCH">시장조사</li>
						        <li class="tab-item" data-doc="RESULT">신제품품질</li>
						        <li class="tab-item" data-doc="CHEMICAL">이화학검사</li>
						        <li class="tab-item" data-doc="PACKAGE">표시사항기재</li>
							  </ul>
							  <div class="chart-area">
								  <div id="reportBarChart" style="width: 1000px; height: 275px; margin: auto;"></div>
							  </div>
						</div>
					</div>
				</div>
			</div>
			
			<div class="title2 mt10"><span class="txt">공지사항</span></div>
			<div class="dashboard02">
				
			</div>
			<!-- 품목제조공정서 검색 close -->			
			<div class="title2 mt30"><span class="txt">내문서 현황</span></div>
			<div class="dashboard01">
			</div>
			<div class="btn_box_con"></div>
			<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
		<!-- 컨텐츠 close-->	
	</section>
</div>

<!-- 🔔 공지사항 팝업 레이어 -->
<div id="noticeLayerPopup" class="popup-overlay" style="display:none;">
  <div class="popup-wrapper">
    <!-- 헤더 -->
    <div class="popup-header">
        <img src="/resources/images/bbq_logo.png" alt="BBQ Logo">
    </div>

    <!-- 팝업 본체 -->
    <div class="popup-container">
      <div class="popup-title">
          <span class="notice-title" id="popupNoticeTitle" onclick="goToDetail()"></span>
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
        <label><input type="checkbox" id="popupTodaySkip"> 오늘 하루 보지 않기</label>
        <button class="btn-close" onclick="closeNoticeLayerPopup()">닫기</button>
    </div>
  </div>
</div>