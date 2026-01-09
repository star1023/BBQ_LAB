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
/* 기존 스타일 유지 */
.tab-item2 {
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

.tab-item2.active {
	background: white;
	font-weight: bold;
	z-index: 2;
	border-bottom: 1px solid white;
}

.myDocTable {
	margin: 0 0 30px;
	padding: 10px 0;
	min-height: 318px;
}

.main_bottom_box {
	box-shadow: 2px 2px 3px 2px #93939380;
	margin: 1px 0;
	padding: 10px 10px;
	border: 2px #ccc solid;
	border-radius: 10px;
}

.m_version td {
	background-color: #f6f6f6;
}

.m_version td:first-child {
	background-image: url(../resources/images/bg_ver.png);
	background-repeat: no-repeat;
	background-position: 20px 0
}

.team-select{
  height: 26px;
  border: 1px solid #cfcfcf;
  border-radius: 6px;
  padding: 0 8px;
  font-size: 12px;
  margin-left: 10px;
}

#barScopeBtns .barChartBtn.active{
  color: #fff;
  border-radius: 6px;
  padding: 4px 10px;
}

#barScopeBtns .barChartBtn.active{
  color: rgb(255 241 87);   /* 원하는 색으로 변경 가능 */
  font-weight: 700;
  border-radius: 0;
  padding: 0;
  background: none;
}

#pieScopeBtns .barChartBtn.active{
  color: rgb(255 241 87);
  font-weight: 700;
  border-radius: 0;
  padding: 0;
  background: none;
}

</style>

<script type="text/javascript"
	src="https://www.gstatic.com/charts/loader.js"></script>
<script type="text/javascript"
	src="../resources/js/common.js"></script>

<script type="text/javascript">
//==========================================================================
//[0] 전역 공통
//==========================================================================
var selectedTeamNameBar = "";  // 막대용 선택 팀
var selectedTeamNamePie = "";  // 파이용 선택 팀
let USER_TYPE = "";                 // LEADER / EXECUTIVE / ...
let _faqCategoryFullList = [];
let faqCurrentIndex = 0;

let selectedTeamName = "__ALL__";   // 임원 팀 선택
let currentTabDocType = "PROD";

//[내 데이터]
let myPieRaw = ${docCountJson != null && docCountJson != '' ? docCountJson : 'null'} || {};
let myBarRaw = ${docStatusCountJson != null && docStatusCountJson != '' ? docStatusCountJson : 'null'} || {};
let apprStatusData = ${apprStatusCountJson != null && apprStatusCountJson != '' ? apprStatusCountJson : 'null'} || {};

//[팀 데이터]
let teamPieRaw = ${teamDocCountJson != null && teamDocCountJson != '' ? teamDocCountJson : '{}'};
let teamBarRaw = ${teamDocStatusCountJson != null && teamDocStatusCountJson != '' ? teamDocStatusCountJson : '[]'};
//✅ EXECUTIVE 전체 원본 백업(처음 로딩 데이터)
let teamPieAllRaw = teamPieRaw;   // 전체 파이(팀 전체 합계)
let teamBarAllRaw = teamBarRaw;   // 전체 막대(모든 팀원 목록)
//[현재 차트 상태]
let currentPieData = myPieRaw;
let currentBarData = transformFlatToNestedStatusData(myBarRaw);
let isTeamMode = false;

let productDocCount = ${docCount.PROD_CNT != null ? docCount.PROD_CNT : 0};
let menuDocCount = ${docCount.MENU_CNT != null ? docCount.MENU_CNT : 0};

let execTeamsRaw = ${execTeamsJson != null && execTeamsJson != '' ? execTeamsJson : '[]'};

//==========================================================================
//[1] Document Ready
//==========================================================================
$(document).ready(function () {
USER_TYPE = $("#barScopeBtns").data("user-type") || "";
USER_TYPE = (USER_TYPE || "").toUpperCase();
if (USER_TYPE === "EXEC") USER_TYPE = "EXECUTIVE";

// 1) 차트 로드
google.charts.load("current", { packages: ["corechart", "bar"] });
google.charts.setOnLoadCallback(drawCharts);

// 2) 기본 데이터 로드
fn_loadList(1);
fn_loadFaq(1);
loadCode("FAQ_CATEGORY", "searchFaqType");

// 3) 내문서 테이블 초기화
renderMyDocTable("PROD_DOC");

// 4) 상단 카운트 텍스트
initDashboardCounts();

// 5) 권한별 초기 세팅
initScopeByRole();

// 6) 임원 팀 버튼 생성(임원일 때만)
buildExecutiveTeamButtons();   // 임원 막대 팀 버튼
buildExecutivePieSelect();     // 임원 파이 팀 셀렉트
// -----------------------------------------------------------------------
// 이벤트
// -----------------------------------------------------------------------

// (1) 막대 차트 탭 클릭(제품개발/메뉴개발/...)
$(".tab-item").on("click", function () {
 $(".tab-item").removeClass("active");
 $(this).addClass("active");
 currentTabDocType = $(this).data("doc");
 drawBarChartByDocType(currentTabDocType);
});

// (2) 내문서 현황 탭 클릭
$(".tab-item2").on("click", function () {
 $(".tab-item2").removeClass("active");
 $(this).addClass("active");
 renderMyDocTable($(this).data("doc"));
});

// (3) FAQ 이전/다음
$("#faq-prev-btn").on("click", function () {
 if (faqCurrentIndex > 0) {
   faqCurrentIndex--;
   updateAndLoadFaq();
 }
});
$("#faq-next-btn").on("click", function () {
 if (faqCurrentIndex < _faqCategoryFullList.length - 1) {
   faqCurrentIndex++;
   updateAndLoadFaq();
 }
});

// (4) FAQ 아코디언
$(document).on("click", ".faq-title", function () {
	 const $clickedItem = $(this).closest(".faq-item");
	 $(".faq-item").not($clickedItem).removeClass("active");
	 $clickedItem.toggleClass("active");
	 if ($clickedItem.hasClass("active")) {
	   $("html, body").animate({ scrollTop: $clickedItem.offset().top - 120 }, 400);
	 }
	});
	
	// (5) 파이 차트 버튼 (리더만: MY/TEAM)
	$(document).on("click", "#pieScopeBtns .barChartBtn", function () {
	  if (USER_TYPE !== "LEADER") return;   // ✅ 팀장만
	
	  $("#pieScopeBtns .barChartBtn").removeClass("active");
	  $(this).addClass("active");
	
	  var scope = $(this).data("scope"); // MY | TEAM
	  if (scope === "MY") {
	    currentPieData = myPieRaw;
	  } else {
	    currentPieData = teamPieRaw;
	  }
	  drawPieChart();
	});
	
	$(document).on("change", "#pieTeamSelect", function () {
	  if (USER_TYPE !== "EXECUTIVE") return;

	  var orgaid = $(this).val();

	  // ✅ 전체 처리
	  if (orgaid === "__ALL__") {
	    currentPieData = teamPieAllRaw; // 전체 파이로 복구
	    drawPieChart();
	    return;
	  }

	  $.ajax({
	    type: "POST",
	    url: "/main/teamChartsAjax",
	    data: { ORGAID: orgaid },
	    dataType: "json",
	    success: function (res) {
	      currentPieData = res.teamDocCount || {};
	      drawPieChart();
	    }
	  });
	});

	// (6) 막대 차트 상단 버튼 (LEADER + EXECUTIVE 모두 처리)
	$(document).on("click", "#barScopeBtns .barChartBtn", function () {

	  // 공통: active UI
	  $("#barScopeBtns .barChartBtn").removeClass("active");
	  $(this).addClass("active");

	  // =========================
	  // ✅ LEADER (팀장): MY / TEAM 토글
	  // =========================
	  if (USER_TYPE === "LEADER") {
	    var scope = $(this).data("scope"); // MY | TEAM

	    if (scope === "TEAM") {
	      isTeamMode = true;
	      currentBarData = teamBarRaw;     // 팀원 리스트
	    } else {
	      isTeamMode = false;
	      currentBarData = transformFlatToNestedStatusData(myBarRaw); // 내 상태별
	    }

	    drawBarChartByDocType(currentTabDocType);
	    return;
	  }

	  // =========================
	  // ✅ EXECUTIVE (임원): 팀 버튼 ajax
	  // =========================
	  if (USER_TYPE === "EXECUTIVE") {
	    var orgaid = $(this).data("orgaid");
	    var teamName = $(this).data("team");

	    // 전체
	    if (orgaid === "__ALL__") {
	      selectedTeamNameBar = "__ALL__";
	      selectedTeamName = "__ALL__";
	      teamBarRaw = teamBarAllRaw;
	      drawBarChartByDocType(currentTabDocType);
	      return;
	    }

	    // 팀 선택
	    selectedTeamNameBar = teamName;
	    selectedTeamName = teamName;

	    $.ajax({
	      type: "POST",
	      url: "/main/teamChartsAjax",
	      data: { ORGAID: orgaid },
	      dataType: "json",
	      success: function (res) {
	        teamBarRaw = res.teamMembers || [];
	        drawBarChartByDocType(currentTabDocType);
	      }
	    });

	    return;
	  }

	  // 사원 등 기타는 무시(원하면 MY만 처리 가능)
	});

});


//==========================================================================
//[2] 권한별 초기 세팅
//==========================================================================
function initScopeByRole() {
  if (USER_TYPE === "EXECUTIVE") {
    // 임원: 파이=팀(ajax로 선택), 막대=팀(버튼)
    currentPieData = teamPieRaw;
    isTeamMode = true;
    currentBarData = teamBarRaw;
  } else if (USER_TYPE === "LEADER") {
    // 팀장: 파이=내가 기본, 버튼으로 내/팀 토글
    currentPieData = myPieRaw;
    // 막대는 기존 로직대로(내/팀 버튼)
  } else {
    // 사원: 내 데이터만
    currentPieData = myPieRaw;
  }
}

//==========================================================================
//[3] 차트 시작점
//==========================================================================
function drawCharts() {
drawPieChart();
drawBarChartByDocType("PROD");
}

//==========================================================================
//[4] 파이 차트
//==========================================================================
function drawPieChart() {
  var chartContainer = document.getElementById("reportPieChart");
  chartContainer.innerHTML = "";

  var pData = convertKeysToUpperCase(currentPieData) || {};

  var total =
    parseInt(pData.PROD_CNT || 0, 10) +
    parseInt(pData.MENU_CNT || 0, 10) +
    parseInt(pData.DESIGN_CNT || 0, 10) +
    parseInt(pData.SENSE_QUALITY_CNT || 0, 10) +
    parseInt(pData.PLAN_CNT || 0, 10) +
    parseInt(pData.TRIP_CNT || 0, 10) +
    parseInt(pData.RESEARCH_CNT || 0, 10) +
    parseInt(pData.RESULT_CNT || 0, 10) +
    parseInt(pData.CHEMICAL_CNT || 0, 10) +
    parseInt(pData.PACKAGE_CNT || 0, 10);

  if (total === 0) {
    chartContainer.innerHTML =
      "<div style='text-align:center; padding-top:100px; color:#999;'>데이터가 존재하지 않습니다.</div>";
    return;
  }

  var data = new google.visualization.DataTable();
  data.addColumn("string", "보고서 구분");
  data.addColumn("number", "건수");

  data.addRows([
    ["제품개발", parseInt(pData.PROD_CNT || 0, 10)],
    ["메뉴개발", parseInt(pData.MENU_CNT || 0, 10)],
    ["상품설계", parseInt(pData.DESIGN_CNT || 0, 10)],
    ["관능&품질", parseInt(pData.SENSE_QUALITY_CNT || 0, 10)],
    ["출장계획", parseInt(pData.PLAN_CNT || 0, 10)],
    ["출장결과", parseInt(pData.TRIP_CNT || 0, 10)],
    ["시장조사", parseInt(pData.RESEARCH_CNT || 0, 10)],
    ["신제품품질", parseInt(pData.RESULT_CNT || 0, 10)],
    ["이화학검사", parseInt(pData.CHEMICAL_CNT || 0, 10)],
    ["표시사항기재", parseInt(pData.PACKAGE_CNT || 0, 10)]
  ]);

  var options = {
    pieHole: 0.4,
    chartArea: { width: "90%", height: "80%" },
    legend: { position: "right", alignment: "center" },
    height: 290
  };

  new google.visualization.PieChart(chartContainer).draw(data, options);
}


//==========================================================================
//[5] 막대 차트
//==========================================================================
function drawBarChartByDocType(docTypeKey) {
const chartContainer = document.getElementById("reportBarChart");
chartContainer.innerHTML = ""; 

// ✅ 임원: 팀별 블록(팀마다 팀원차트) 렌더링
if (USER_TYPE === "EXECUTIVE") {
  // ✅ 전체 버튼이면: "전체 상태별" 차트 1개
  if (!selectedTeamName || selectedTeamName === "__ALL__") {
    drawExecutiveAllStatusChart(docTypeKey, chartContainer, teamBarAllRaw);
  } else {
    // ✅ 팀 버튼이면: 기존 팀원별 차트(팀 1개만)
    drawExecutiveTeamCharts(docTypeKey, chartContainer, teamBarRaw, selectedTeamName);
  }
  return;
}

// ✅ 리더: 팀모드/내모드
const chartData = new google.visualization.DataTable();

// -------------------------
// Case A: 팀 모드 (팀원별)
// -------------------------
if (isTeamMode) {
 chartData.addColumn("string", "팀원");
 chartData.addColumn("number", "등록");
 chartData.addColumn("number", "결재중");
 chartData.addColumn("number", "부분승인");
 chartData.addColumn("number", "완료");

 if (!Array.isArray(currentBarData) || currentBarData.length === 0) {
   chartContainer.innerHTML =
     "<div style='text-align:center; padding-top:100px; color:#999;'>팀 데이터가 없습니다.</div>";
   return;
 }

 let totalCount = 0;

 currentBarData.forEach(function (member) {
   const safe = convertKeysToUpperCase(member);

   const regVal  = parseInt(safe[docTypeKey + "_REG_CNT"] || 0);
   const apprVal = parseInt(safe[docTypeKey + "_APPR_CNT"] || 0);
   const condVal = parseInt(safe[docTypeKey + "_COND_APPR_CNT"] || 0);
   const compVal = parseInt(safe[docTypeKey + "_COMP_CNT"] || 0);

   totalCount += regVal + apprVal + condVal + compVal;

   const userName = safe.USER_NAME || safe.DOC_OWNER || "Unknown";
   chartData.addRow([userName, regVal, apprVal, condVal, compVal]);
 });

 if (totalCount === 0) {
   chartContainer.innerHTML =
     "<div style='text-align:center; padding-top:100px; color:#999;'>데이터가 존재하지 않습니다.</div>";
   return;
 }

 const options = {
   chartArea: { width: "85%", height: "70%" },
   legend: { position: "top", maxLines: 2 },
   bar: { groupWidth: "65%" },
   colors: ["#339af0", "#c24b4b", "#ffb400", "#28a745"],
   vAxis: { minValue: 0, format: "0" },
   height: 275,
   animation: { duration: 500, startup: true },
 };

 new google.visualization.ColumnChart(chartContainer).draw(chartData, options);
 return;
}

// -------------------------
// Case B: 내 모드 (상태별)
// -------------------------
const statusMap = { REG:"등록", APPR:"결재중", COND_APPR:"부분승인", COMP:"완료", TMP:"임시저장", RET:"반려" };
const statusColors = { REG:"#339af0", APPR:"#c24b4b", COND_APPR:"#ffb400", COMP:"#28a745", TMP:"#adb5bd", RET:"#964b00" };

const raw = currentBarData?.[docTypeKey];
if (!raw) {
 chartContainer.innerHTML =
   "<div style='text-align:center; padding-top:100px; color:#999;'>데이터가 없습니다.</div>";
 return;
}

let totalCount = 0;

chartData.addColumn("string", "상태");
chartData.addColumn("number", "건수");
chartData.addColumn({ type: "string", role: "style" });

for (const key in statusMap) {
 const val = parseInt(raw[key] || 0);
 totalCount += val;
 chartData.addRow([statusMap[key], val, 'color: ' + statusColors[key]]);
}

if (totalCount === 0) {
 chartContainer.innerHTML =
   "<div style='text-align:center; padding-top:100px; color:#999;'>데이터가 존재하지 않습니다.</div>";
 return;
}

const options = {
 chartArea: { width: "80%", height: "70%" },
 legend: { position: "none" },
 vAxis: { minValue: 0, format: "0" },
 height: 275,
 animation: { duration: 500, startup: true },
};

new google.visualization.ColumnChart(chartContainer).draw(chartData, options);
}

//==========================================================================
//[6] 임원: 팀 버튼 생성
//==========================================================================
function buildExecutiveTeamButtons() {
  if (USER_TYPE !== "EXECUTIVE") return;

  var $box = $("#barScopeBtns");
  $box.empty();

  if (!Array.isArray(execTeamsRaw) || execTeamsRaw.length === 0) return;
  //✅ [전체] 버튼 먼저
  $box.append(
    '<span class="barChartBtn active" data-orgaid="__ALL__" data-team="__ALL__">전체</span>'
  );
  $box.append('<span>|</span>');
  var colors = ["#2f9e44", "#1971c2", "#f08c00", "#c92a2a", "#7048e8", "#0b7285", "#e8590c"];

  execTeamsRaw.forEach(function (t, idx) {
    var safe = convertKeysToUpperCase(t);
    var teamName = safe.TEAM_NAME || safe.OBJTTX || ("TEAM_" + safe.ORGAID);
    var color = colors[idx % colors.length];

    $box.append(
	  '<span class="barChartBtn" ' +
	  'data-orgaid="' + safe.ORGAID + '" data-team="' + teamName + '" data-color="' + color + '">' +
	  teamName +
	  '</span>'
	);


    if (idx !== execTeamsRaw.length - 1) $box.append('<span>|</span>');
  });

  //✅ 최초 상태는 전체
  selectedTeamNameBar = "__ALL__";
  selectedTeamName = "__ALL__";
  teamBarRaw = teamBarAllRaw;
}

function buildExecutivePieSelect() {
  if (USER_TYPE !== "EXECUTIVE") return;

  var $sel = $("#pieTeamSelect");
  if ($sel.length === 0) return;

  $sel.empty();
  if (!Array.isArray(execTeamsRaw) || execTeamsRaw.length === 0) return;

  // ✅ 전체 옵션
  $sel.append('<option value="__ALL__">전체</option>');

  execTeamsRaw.forEach(function (t) {
    var safe = convertKeysToUpperCase(t);
    var teamName = safe.TEAM_NAME || safe.OBJTTX || ("TEAM_" + safe.ORGAID);
    $sel.append('<option value="' + safe.ORGAID + '">' + teamName + '</option>');
  });

  $sel.val("__ALL__");   // ✅ 기본값: 전체
  $sel.trigger("change");
}



//==========================================================================
//[7] 임원: 팀별 블록 렌더링
//==========================================================================
function drawExecutiveTeamCharts(docTypeKey, chartContainer, rawList, selectedTeam) {
chartContainer.innerHTML = "";

if (!Array.isArray(rawList) || rawList.length === 0) {
 chartContainer.innerHTML =
   "<div style='text-align:center; padding-top:100px; color:#999;'>팀 데이터가 없습니다.</div>";
 return;
}

const groups = {};
rawList.forEach((m) => {
 const safe = convertKeysToUpperCase(m);
 const teamName = safe.TEAM_NAME || safe.OBJTTX || safe.DEPT_NAME || "Unknown Team";
 (groups[teamName] ||= []).push(safe);
});

const entries = Object.entries(groups).filter(([teamName]) => {
 if (!selectedTeam || selectedTeam === "__ALL__") return true;
 return teamName === selectedTeam;
});

if (entries.length === 0) {
 chartContainer.innerHTML =
   "<div style='text-align:center; padding-top:100px; color:#999;'>선택한 팀 데이터가 없습니다.</div>";
 return;
}

let idx = 0;
entries.forEach(([teamName, members]) => {
 const block = document.createElement("div");
 const chartDiv = document.createElement("div");
 chartDiv.id = "teamBarChart_" + idx++;
 chartDiv.style.width = "100%";
 chartDiv.style.height = "275px";

 chartDiv.innerHTML = "";
 block.appendChild(chartDiv);
 chartContainer.appendChild(block);

 drawTeamMemberBar(docTypeKey, members, chartDiv);
});
}

function drawTeamMemberBar(docTypeKey, members, chartEl) {
chartEl.innerHTML = ""; 
const chartData = new google.visualization.DataTable();
chartData.addColumn("string", "팀원");
chartData.addColumn("number", "등록");
chartData.addColumn("number", "결재중");
chartData.addColumn("number", "부분승인");
chartData.addColumn("number", "완료");
chartData.addColumn("number", "반려");

let totalCount = 0;

members.forEach((m) => {
 const regVal  = parseInt(m[docTypeKey + "_REG_CNT"] || 0);
 const apprVal = parseInt(m[docTypeKey + "_APPR_CNT"] || 0);
 const condVal = parseInt(m[docTypeKey + "_COND_APPR_CNT"] || 0);
 const compVal = parseInt(m[docTypeKey + "_COMP_CNT"] || 0);
 const retVal = parseInt(m[docTypeKey + "_RET_CNT"] || 0);
 totalCount += regVal + apprVal + condVal + compVal + retVal;

 const userName = m.USER_NAME || m.DOC_OWNER || "Unknown";
 chartData.addRow([userName, regVal, apprVal, condVal, compVal, retVal]);
});

if (totalCount === 0) {
 chartEl.innerHTML =
   "<div style='text-align:center; padding-top:100px; color:#999;'>데이터가 존재하지 않습니다.</div>";
 return;
}

const options = {
 chartArea: { width: "85%", height: "70%" },
 legend: { position: "top", maxLines: 2 },
 bar: { groupWidth: "65%" },
 colors: ["#339af0", "#c24b4b", "#ffb400", "#28a745", "#964b00"],
 vAxis: { minValue: 0, format: "0" },
 height: 275,
 animation: { duration: 500, startup: true },
};

new google.visualization.ColumnChart(chartEl).draw(chartData, options);
}

//==========================================================================
//[8] 유틸 + 기존 함수(공지/FAQ/내문서)는 그대로 유지
//==========================================================================
function convertKeysToUpperCase(obj) {
if (!obj || typeof obj !== "object") return {};
const newObj = {};
for (let key in obj) newObj[key.toUpperCase()] = obj[key];
return newObj;
}

function transformFlatToNestedStatusData(flatData) {
if (!flatData || typeof flatData !== "object") return {};
let targetData = Array.isArray(flatData) ? (flatData[0] || {}) : flatData;
const result = {};
Object.entries(targetData).forEach(([key, value]) => {
 const upperKey = key.toUpperCase();
 const match = upperKey.match(/^([A-Z_]+)_(TMP|REG|APPR|COND_APPR|COMP|RET)_CNT$/);
 if (!match) return;
 const docType = match[1];
 const status = match[2];
 if (!result[docType]) result[docType] = {};
 result[docType][status] = value;
});
return result;
}

function initDashboardCounts() {
$("#my_reg").text(apprStatusData.APPR_NCNT || 0);
$("#my_ac").text((apprStatusData.APPR_A_CNT || 0) + (apprStatusData.APPR_C_CNT || 0));
$("#my_ret").text(apprStatusData.APPR_R_CNT || 0);
$("#my_comp").text(apprStatusData.APPR_Y_CNT || 0);
$("#appr_reg").text(apprStatusData.MY_APPR_CNT || 0);
$("#ref_today").text(apprStatusData.REF_NO_READ_CNT || 0);
$("#ref_total").text(apprStatusData.REF_TOTAL_CNT || 0);
$("#productDocCount").text(productDocCount);
$("#menuDocCount").text(menuDocCount);
}

// ★ 사라졌던 FAQ 관련 함수들 복구
function updateAndLoadFaq() {
    updateFaqSliderPosition();
    $(".slider_item").removeClass("active").eq(faqCurrentIndex).addClass("active");
    fn_loadFaq(1, _faqCategoryFullList[faqCurrentIndex].itemCode);
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
    $("#faq-prev-btn").toggleClass("active", faqCurrentIndex > 0);
    $("#faq-next-btn").toggleClass("active", faqCurrentIndex < _faqCategoryFullList.length - 1);
}

// 공지사항 로드
function fn_loadList(pageNo = 1) {
    const viewCount = 7;
    $.ajax({
        type: "POST", url: "/notice/selectNoticeListAjax",
        data: { searchType: $("#searchType").val(), searchValue: $("#searchValue").val(), searchStartDate: $("#searchStartDate").val(), searchEndDate: $("#searchEndDate").val(), searchNoticeType: $("#searchNoticeType").val(), viewCount: viewCount, pageNo: pageNo },
        dataType: "json",
        success: function (data) { fn_renderDashboardList(data.list); fn_noticePopupFromList(data.list); },
        error: function (xhr, status, err) { alert("조회 중 오류 발생: " + err); }
    });
}

function fn_renderDashboardList(list) {
    const $tbody = $("#noticeTableBody"); $tbody.empty();
    const totalRows = 7; let renderedCount = 0;
    if (!list || list.length === 0) {
        for (let i = 0; i < totalRows; i++) $tbody.append("<tr><td colspan='3' style='height: 32px;'>&nbsp;</td></tr>");
        return;
    }
    list.forEach(function (item) {
        const isNotice = item.TYPE === "I";
        const isValidPeriod = isNotice && isNoticePeriodValid(item.POST_START_DATE, item.POST_END_DATE);
        const trStyle = isNotice && isValidPeriod ? "style='background-color: rgba(255, 0, 0, 0.06);'" : "";
        let iconHtml = "";
        if (isNotice) {
            const iconStyle = isValidPeriod ? "filter: brightness(0) saturate(100%) invert(19%) sepia(94%) saturate(7468%) hue-rotate(353deg) brightness(89%) contrast(102%);" : "";
            iconHtml = "<span style='margin-left: 12px; display: inline-flex; align-items: center; gap: 15px;'><img src='/resources/images/icon_megaphone.png' style='width: 14px; height: 14px; " + iconStyle + "' /></span>";
        }
        const trHtml = "<tr " + trStyle + "><td style='width: 80px; text-align: center;'>" + iconHtml + "</td><td style='text-align: center; width: 350px;'><a href=\"javascript:fn_viewDetail(" + item.BNOTICE_IDX + ");\">" + item.TITLE + "</a></td><td style='text-align: center;'>" + item.REG_DATE + "</td></tr>";
        $tbody.append(trHtml); renderedCount++;
    });
    const remainingRows = totalRows - renderedCount;
    for (let i = 0; i < remainingRows; i++) $tbody.append("<tr><td colspan='3' style='height: 32px;'>&nbsp;</td></tr>");
}

function isNoticePeriodValid(startDateStr, endDateStr) {
    if (!startDateStr || !endDateStr) return false;
    const startDate = new Date(startDateStr); const endDate = new Date(endDateStr); const today = new Date();
    startDate.setHours(0, 0, 0, 0); endDate.setHours(23, 59, 59, 999); today.setHours(0, 0, 0, 0);
    return startDate <= today && today <= endDate;
}
function fn_viewDetail(idx) { location.href = "/notice/view?idx=" + idx; }

// 팝업 관련
function getCookie(name) { const match = document.cookie.match(new RegExp("(^| )" + name + "=([^;]+)")); return match ? match[2] : null; }
let popupNoticeQueue = [];
function fn_noticePopupFromList(list) {
    if (!list || list.length === 0) return;
    const today = new Date(); today.setHours(0, 0, 0, 0);
    popupNoticeQueue = list.filter(function(item) {
        if (item.IS_POPUP !== 'Y') return false;
        const skip = getCookie("notice_skip_" + item.BNOTICE_IDX);
        if (skip === "Y") return false;
        const start = new Date(item.POP_START_DATE); const end = new Date(item.POP_END_DATE);
        start.setHours(0, 0, 0, 0); end.setHours(23, 59, 59, 999);
        return start <= today && today <= end;
    });
    if (popupNoticeQueue.length > 0) showNextNoticePopup();
}
function showNextNoticePopup() {
    if (popupNoticeQueue.length === 0) { $("#noticeLayerPopup").hide(); return; }
    const notice = popupNoticeQueue.shift();
    $("#popupNoticeTitle").text(notice.TITLE);
    $("#popupNoticeMeta").text("작성자: " + notice.REG_USER + " | 등록일: " + notice.REG_DATE);
    $("#popupNoticeContent").empty().html(restoreStr(notice.CONTENT));
    $("#popupNoticeTitle, .more-icon").data("noticeId", notice.BNOTICE_IDX);
    $("#popupTodaySkip").prop("checked", false);
    $("#noticeLayerPopup").fadeIn(function () { $(".popup-container").scrollTop(0); });
}
function closeNoticeLayerPopup() {
    const currentId = $("#popupNoticeTitle").data("noticeId");
    const skip = $("#popupTodaySkip").is(":checked");
    if (skip && currentId) {
        const expires = new Date(); expires.setHours(23, 59, 59, 999);
        document.cookie = "notice_skip_" + currentId + "=Y; expires=" + expires.toUTCString() + "; path=/";
    }
    $("#noticeLayerPopup").fadeOut(() => { showNextNoticePopup(); });
}
function goToDetail() { const id = $("#popupNoticeTitle").data("noticeId"); if (id) location.href = "/notice/view?idx=" + id; }

// FAQ 관련
function fn_loadFaq (pageNo=1, faqType = '1') {
    const viewCount = 7;
    $.ajax({
        type: "POST", url: "/faq/selectFaqListAjax",
        data: { searchType: $("#searchType").val(), searchValue: $("#searchValue").val(), searchFaqType: faqType, viewCount: viewCount, pageNo: pageNo },
        dataType: "json",
        success: function (data) { fn_renderFaqList(data.list); },
        error: function (xhr, status, err) { alert("조회 중 오류 발생: " + err); }
    });
}
function fn_renderFaqList(list) {
    var $dashboard = $(".dashboard03"); $dashboard.empty();
    var html = '<div class="faq-list">';
    var maxRow = 7; var count = list.length;
    for (var i = 0; i < maxRow; i++) {
        if (i < count) {
            var item = list[i];
            html += '<div class="faq-item"><div class="faq-title"><span>Q. ' + item.QUESTION + '</span><span class="toggle-arrow">&gt;</span></div><div class="faq-content">' + restoreStr(item.ANSWER) + '</div></div>';
        } else {
            html += '<div class="faq-item empty"><div class="faq-title"><span>&nbsp;</span></div></div>';
        }
    }
    html += '</div>'; $dashboard.append(html);
}
function loadCode(codeId,selectBoxId) {
    var URL = "../common/codeListAjax";
    $.ajax({
        type:"POST", url:URL, data:{ groupCode : codeId }, dataType:"json", async:false,
        success:function(data) {
            _faqCategoryFullList = data.RESULT;
            renderFaqSlider();
        },
        error:function(request, status, errorThrown){ alert("오류가 발생하였습니다."); }
    });
}
function renderFaqSlider() {
    const $track = $("#faq-slider-track"); $track.empty();
    _faqCategoryFullList.forEach((item, index) => {
        const btn = $("<div>").addClass("slider_item").text(item.itemName).attr("data-code", item.itemCode);
        if (index === faqCurrentIndex) btn.addClass("active");
        btn.on("click", function () { $(".slider_item").removeClass("active"); $(this).addClass("active"); fn_loadFaq(1, $(this).data("code")); });
        $track.append(btn);
    });
    updateFaqSliderPosition();
}

// 내문서 테이블
function renderMyDocTable(docTypeParam) {
    var docTypeKey = docTypeParam.replace("_DOC", "");
    var docTypePathMap = { "PROD": "/product", "MENU": "/menu", "DESIGN": "/designReport", "SENSE_QUALITY": "/senseQuality", "PLAN": "/businessTripPlan", "TRIP": "/businessTrip", "RESEARCH": "/marketResearch", "RESULT": "/newProductResult", "CHEMICAL": "/chemicalTest", "PACKAGE": "/package" };
    var endpointMap = { "PROD": "selectProductListAjax", "MENU": "selectMenuListAjax", "DESIGN": "selectDesignListAjax", "SENSE_QUALITY": "selectSenseQualityListAjax", "PLAN": "selectBusinessTripPlanListAjax", "TRIP": "selectBusinessTripListAjax", "RESEARCH": "selectMarketResearchListAjax", "RESULT": "selectNewProductResultListAjax", "CHEMICAL": "selectChemicalTestListAjax", "PACKAGE": "selectPackageInfoListAjax" };
    if (!docTypePathMap[docTypeKey] || !endpointMap[docTypeKey]) return;
    var docType = docTypePathMap[docTypeKey];
    var url = endpointMap[docTypeKey];
    var isSafeTeam = ('${userUtil:getRoleCode(pageContext.request)}' == '6' || '${userUtil:getRoleCode(pageContext.request)}' == '7');
    
    $.ajax({
        type: "POST", url: docType + "/" + url,
        data: { "docType": docTypeKey, "viewCount": 5, "pageNo": 1, "isSafeTeam": (docTypeKey == "CHEMICAL" && isSafeTeam) ? 'Y' : 'N', "isRequestList": 'N' },
        dataType: "json",
        success: function (response) { renderMyDocTableRow(response, docType, docTypeKey); },
        error: function (request, status, error) { alert("데이터 요청 중 오류 발생"); }
    });
}
function renderMyDocTableRow(data, docType, docTypeKey) {
    var list = data.list || [];
    var hasVersioningDoc = docTypeKey === 'PROD' || docTypeKey === 'MENU' || docTypeKey === 'PACKAGE';
    var theadHtml = "<tr>";
    if(hasVersioningDoc) theadHtml += " <th style=\"width:40px\"></th>";
    theadHtml += " <th>제목</th><th>작성자</th></tr>";
    $("#myDocTableHaed").html(theadHtml);

    var tbodyHtml = "";
    var idxText = docTypeKey == 'SENSE_QUALITY' ? "REPORT_IDX" : (docTypeKey == 'PROD' ? "PRODUCT_IDX" : docTypeKey+'_IDX');
    
    list.forEach(function(item, i) {
        var viewUrl = docType + "/view?idx=" + item[idxText];
        var id = docTypeKey + '_' + item.DOC_NO + '_' + i; 
        if (hasVersioningDoc) {
            if (item.IS_LAST === 'Y') {
                tbodyHtml += (item.STATUS === 'APPR_RET' || item.STATUS === 'RET') ? "<tr id=\"" + id + "\"class=\"m_visible\">" : "<tr id=\"" + id + "\">";
            } else {
                tbodyHtml += "<tr id=\"" + id + "\" class=\"m_version\" style=\"display: none\">";
            }
        } else {
            tbodyHtml += "<tr>";
        }
        if (hasVersioningDoc) {
            tbodyHtml += "<td>";
            tbodyHtml += (item.CHILD_CNT > 0 && item.IS_LAST === 'Y') ? "<img src=\"/resources/images/img_add_doc.png\" style=\"cursor: pointer;\" onclick=\"showChildVersion(this)\">" : "&nbsp;";
            tbodyHtml += "</td>";
        }
        tbodyHtml += "<td onclick=\"location.href='" + viewUrl + "'\" style=\"cursor:pointer\"><div class=\"ellipsis_txt tgnl\" style=\"text-align:center !important;\">" + nvl(item.TITLE || item.PRODUCT_NAME, '&nbsp;') + "</div></td>";
        tbodyHtml += "<td onclick=\"location.href='" + viewUrl + "'\" style=\"cursor:pointer\">" + nvl(item.USER_NAME, '&nbsp;') + "</td></tr>";
    });
    $("#myDocTableBody").html(tbodyHtml);
}
function nvl(value, defaultValue) { return (value !== undefined && value !== null && value !== '') ? value : defaultValue; }
function showChildVersion(imgElement) {
    var trId = $(imgElement).closest('tr').attr('id');
    var parts = trId.split('_');
    var rowPrefix = parts[0] + "_" + parts[1] + "_";
    var imgSrc = $(imgElement).attr('src');
    if (imgSrc.includes('_add_')) {
        $(imgElement).attr('src', imgSrc.replace('_add_', '_m_')); $('tr[id^="' + rowPrefix + '"]').show();
    } else {
        $(imgElement).attr('src', imgSrc.replace('_m_', '_add_')); $('tr[id^="' + rowPrefix + '"]').toArray().forEach(function(v, i) { if (i !== 0) $(v).hide(); });
    }
}
function drawExecutiveAllStatusChart(docTypeKey, chartContainer, rawList) {
  chartContainer.innerHTML = "";

  if (!Array.isArray(rawList) || rawList.length === 0) {
    chartContainer.innerHTML =
      "<div style='text-align:center; padding-top:100px; color:#999;'>팀 데이터가 없습니다.</div>";
    return;
  }

  // ✅ 전체 팀원 합산(상태별)
  let reg = 0, appr = 0, cond = 0, comp = 0, ret = 0;

  rawList.forEach(r => {
    const m = convertKeysToUpperCase(r);
    reg  += parseInt(m[docTypeKey + "_REG_CNT"] || 0, 10);
    appr += parseInt(m[docTypeKey + "_APPR_CNT"] || 0, 10);
    cond += parseInt(m[docTypeKey + "_COND_APPR_CNT"] || 0, 10);
    comp += parseInt(m[docTypeKey + "_COMP_CNT"] || 0, 10);
    ret  += parseInt(m[docTypeKey + "_RET_CNT"] || 0, 10);
  });

  const total = reg + appr + cond + comp + ret;
  if (total === 0) {
    chartContainer.innerHTML =
      "<div style='text-align:center; padding-top:100px; color:#999;'>데이터가 존재하지 않습니다.</div>";
    return;
  }

  const data = new google.visualization.DataTable();
  data.addColumn("string", "상태");
  data.addColumn("number", "건수");
  data.addColumn({ type: "string", role: "style" });

  data.addRows([
    ["등록", reg,  "color:#339af0"],
    ["결재중", appr, "color:#c24b4b"],
    ["부분승인", cond, "color:#ffb400"],
    ["완료", comp, "color:#28a745"],
    ["반려", ret,  "color:#964b00"]
  ]);

  const options = {
    chartArea: { width: "80%", height: "70%" },
    legend: { position: "none" },
    vAxis: { minValue: 0, format: "0" },
    height: 275,
    animation: { duration: 500, startup: true }
  };

  new google.visualization.ColumnChart(chartContainer).draw(data, options);
}

</script>

<div class="wrap_in" id="fixNextTag">
	<span class="path"> <a href="#">BBQ세계식문화과학기술원</a>
	</span>
	<section class="type01">
		<h2 style="position: relative">
			<span class="title_s">System main</span> <span class="title">BBQ
				세계식문화과학기술원</span>
		</h2>
		<div class="group01">
			<div class="main_top_box">
				<div class="my_info_box">
					<div class="wd60">
						<div class="my_noti_box">
							<span class="noti_box_title">내 정보</span>
							<div class="noti_box_table">
								<div class="my_info_box_top">
									<div class="main_logo_img">
										<img alt="profilelogo" src="../resources/images/bbq_logo.png"
											style="width: 70px;">
									</div>
									<div class="main_profile_info">
										<span class="user_dept"> ${userData.OBJTTX} <c:if
												test="${not empty userData.RESP_TXT}">
												<em>&nbsp;|&nbsp;</em>
												<strong class="ml5">${userData.RESP_TXT}</strong>
											</c:if>
										</span> <span class="user_name"> ${userData.userName} <strong
											class="ml5">${userData.TITL_TXT}</strong>
										</span> <span class="user_sub_info"> 제품완료보고서 <strong
											id="productDocCount">0</strong> 건 <em>&nbsp;|&nbsp;</em>
											메뉴완료보고서 <strong id="menuDocCount">0</strong> 건
										</span>
									</div>
									<div class="main_etc"></div>
								</div>
								<div class="my_info_box_bottom">
									<div
										style="width: 100%; display: flex; justify-content: space-around; color: #808080; margin-bottom: 0; padding-top: 15px; border-top: 2px #f0f0f0 solid;">
										<span>올린 결재 문서</span> <span>받을 결재 문서</span> <span>받은 참조
											문서</span>
									</div>
									<div class="fl" style="width: 100%; box-sizing: border-box;">
										<div class="bottom_box_con01">
											<ul>
												<li><span> <strong><a
															href="../approval/list" id="my_reg">0</a></strong> <em>/</em> <a
														href="../approval/list" id="my_ac">0</a> <em>/</em> <a
														href="../approval/list" id="my_ret">0</a> <em>/</em> <a
														href="../approval/list?tab=comp" id="my_comp">0</a>
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
								</div>
							</div>
						</div>
					</div>
					<div class="wd40">
						<div class="chart-card-wrapper">
							<div class="chart-title">
								<span class="txt pieChart" id="pieChartTitle">보고서 현황</span>
								
								<!-- ✅ LEADER: 내 | 팀 버튼 유지 -->
								<c:if test='${userType == "LEADER"}'>
								  <div class="barChartBtnBox2" id="pieScopeBtns" data-user-type="${userType}">
								    <span class="barChartBtn active" data-scope="MY">${userData.userName}</span>
								    <span>|</span>
								    <span class="barChartBtn" data-scope="TEAM">${userData.OBJTTX}</span>
								  </div>
								</c:if>
								
								<!-- ✅ EXECUTIVE: 팀 선택 셀렉트 -->
								<c:if test='${userType == "EXECUTIVE"}'>
								  <select id="pieTeamSelect" class="team-select"></select>
								</c:if>
							</div>
							<div class="chart-area pie">
								<div id="reportPieChart"
									style="width: 400px; height: 290px; margin: auto; padding: 5px 0;"></div>
							</div>
						</div>
					</div>
				</div>
				<div class="main_middle_box">
					<div class="my_info_box2">
						<div class="tab-wrapper">
							<div class="chart-card-wrapper">
								<div class="chart-title">
									<span class="txt-icon barChart" id="barChartTitle">보고서 상태별 현황</span>
									<div class="barChartBtnBox" id="barScopeBtns"
										data-user-type="${userType}">
										<!-- 사원: 버튼 없음(내 보고서만) -->

										<!-- 리더: 내 + 팀원별 -->
										<c:if test='${userType == "LEADER"}'>
											<span class="barChartBtn active" data-scope="MY">${userData.userName}</span>
											<span>|</span>
											<span class="barChartBtn" data-scope="TEAM">${userData.OBJTTX}</span>
										</c:if>

										<!-- 임원: 팀 목록 버튼(동적 생성) -->
										<c:if test='${userType == "EXECUTIVE"}'>
											<!-- JS에서 teamBarRaw 기반으로 [전체 | BBQ상품개발팀 | ...] 버튼 생성 -->
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
			<div class="main_bottom_box">
				<div class="board_box">
					<div class="wd60">
						<span class="noti_box_title">공지사항</span>
						<div class="dashboard02 scroll-wrapper"
							style="box-shadow: 1px 1px 2px 1px #93939380; border-radius: 6px;">
							<table class="tbl_dashboard"
								style="font-size: 14px; width: 100%;">
								<thead>
									<tr>
										<th style='text-align: center;'></th>
										<th style='text-align: center;'>제목</th>
										<th style='text-align: center;'>등록일</th>
									</tr>
								</thead>
								<tbody id="noticeTableBody"></tbody>
							</table>
						</div>
					</div>
					<div class="wd40">
						<span class="noti_box_title">FAQ</span>
						<div
							style="box-shadow: 1px 1px 2px 1px #93939380; border: 1px solid #ddd; border-radius: 7px;">
							<div class="slider_wrap">
								<button id="faq-prev-btn">&lt;</button>
								<div class="slider_viewport">
									<div class="slider_track" id="faq-slider-track"></div>
								</div>
								<button id="faq-next-btn">&gt;</button>
							</div>
							<div class="dashboard03_wrap">
								<div class="dashboard03">
									<div class="faq-list">
										<div class="faq-item" data-index="0">
											<div class="faq-title"></div>
											<div class="faq-content"></div>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>

				<div class="myDocTable">
					<div
						style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
						<span class="noti_box_title">내문서 현황</span>
					</div>
					<div>
						<ul class="tab-menu">
							<li class="tab-item2 active" data-doc="PROD_DOC">제품개발</li>
							<li class="tab-item2" data-doc="MENU_DOC">메뉴개발</li>
							<li class="tab-item2" data-doc="DESIGN_DOC">상품설계</li>
							<li class="tab-item2" data-doc="SENSE_QUALITY_DOC">관능&품질</li>
							<li class="tab-item2" data-doc="PLAN_DOC">출장계획</li>
							<li class="tab-item2" data-doc="TRIP_DOC">출장결과</li>
							<li class="tab-item2" data-doc="RESEARCH_DOC">시장조사</li>
							<li class="tab-item2" data-doc="RESULT_DOC">신제품품질</li>
							<li class="tab-item2" data-doc="CHEMICAL_DOC">이화학검사</li>
							<li class="tab-item2" data-doc="PACKAGE_DOC">표시사항기재</li>
						</ul>
					</div>
					<div class="dashboard02 scroll-wrapper"
						style="box-shadow: 1px 1px 2px 1px #93939380;">
						<table class="tbl_dashboard" style="font-size: 14px; width: 100%;">
							<thead id="myDocTableHaed"></thead>
							<tbody id="myDocTableBody"></tbody>
						</table>
					</div>
				</div>
			</div>
			<div class="btn_box_con"></div>
			<hr class="con_mode" />
		</div>
	</section>
</div>

<div id="noticeLayerPopup" class="popup-overlay" style="display: none;">
	<div class="popup-wrapper">
		<div class="popup-header">
			<img src="/resources/images/bbq_logo.png" alt="BBQ Logo">
		</div>
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
		<div class="popup-footer-fixed">
			<label><input type="checkbox" id="popupTodaySkip"> 오늘
				하루 보지 않기</label>
			<button class="btn-close" onclick="closeNoticeLayerPopup()">닫기</button>
		</div>
	</div>
</div>