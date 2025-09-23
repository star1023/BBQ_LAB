<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ page session="false" %>
<title>결재함</title>
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	var PARAM = {
		type : '${paramVO.type}',
		state : '${paramVO.state}'
	};
	$(document).ready(function(){
		loadCount();
		//loadMyList('1');
		
		// 🔥 tab 파라미터가 있으면 해당 탭 실행
		const urlParams = new URLSearchParams(window.location.search);
		const tabParam = urlParams.get('tab');

		if (tabParam === 'appr') {
			fn_changeTab('apprCount');
		} else if (tabParam === 'ref') {
			fn_changeTab('refCount');
		} else if (tabParam === 'comp') {
			fn_changeTab('compCount');
		} else {
			//fn_changeTab('myCount'); // 기본값
			loadMyList('1');
		}
		
		$("#refStartDate").datepicker({
			showOn: "both",
			buttonImage: "../resources/images/btn_calendar.png",
			buttonImageOnly: true,
			buttonText: "Select date",
			dateFormat: "yy-mm-dd",
			showButtonPanel: true,
			showAnim: "",
			onClose: function(selectedDate){
				$("#refEndDate").datepicker("option", "minDate", selectedDate);
			}
		});	//당일 선택 가능 0, 당일 선택 불가능 1
		
		$("#refEndDate").datepicker({
			showOn: "both",
			buttonImage: "../resources/images/btn_calendar.png",
			buttonImageOnly: true,
			buttonText: "Select date",
			dateFormat: "yy-mm-dd",
			minDate: 0,
			showButtonPanel: true,
			showAnim: "",
			onClose: function(selectedDate){
				$("#refStartDate").datepicker("option", "maxdate", selectedDate)
			}
		});
		
		fn.autoComplete($("#refUserKeyword"));
	});	
	
	// 페이징
	function paging(pageNo){
		if( $("#listType").val() == 'myList' ){
			loadMyList(pageNo);
		} else if( $("#listType").val() == 'myApprList' ){
			loadMyApprList(pageNo);
		} else if( $("#listType").val() == 'myRefList' ){
			loadMyRefList(pageNo);
		} else if( $("#listType").val() == 'myCompList' ){
			loadMyCompList(pageNo);
		}
	}	
	
	//파라미터 조회
	function getParam(pageNo){
		PARAM.pageNo = pageNo || '${paramVO.pageNo}';
		return $.param(PARAM);
	}
	
	function fn_approvalInfo( apprIdx, docType, docIdx ) {
		var url = "";
		var mode = "";
		if( $("#listType").val() == 'myList' ) {
			mode = "width=1100, height=600, left=100, top=10, scrollbars=yes";
			if( docType == 'PROD' ) {
				url = "/approval/productPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();				
			} else if( docType == 'MENU' ) {
				url = "/approval/menuPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();;
			} else if( docType == 'DESIGN' ) {
				url = "/approval/designPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'PLAN' ) {
				url = "/approval/businessTripPlanPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'TRIP' ) {
				url = "/approval/businessTripPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'RESEARCH' ) {
				url = "/approval/marketResearchPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'SENSE_QUALITY' ) {
				url = "/approval/senseQualityReportPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'RESULT' ) {
				url = "/approval/newProductResultPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			} else if( docType == 'CHEMICAL' ) {
				url = "/approval/chemicalTestPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			} else if( docType == 'RECIPE' ) {
				url = "/approval/recipePopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			} else if( docType == 'ETC' ) {
				url = "/approval/etcPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			}
		} else if( $("#listType").val() == 'myApprList' ) {
			mode = "width=1100, height=600, left=100, top=10, scrollbars=yes";
			if( docType == 'PROD' ) {
				url = "/approval/productPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			} else if( docType == 'MENU' ) {
				url = "/approval/menuPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();;
			} else if( docType == 'DESIGN' ) {
				url = "/approval/designPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'PLAN' ) {
				url = "/approval/businessTripPlanPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'TRIP' ) {
				url = "/approval/businessTripPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'RESEARCH' ) {
				url = "/approval/marketResearchPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'SENSE_QUALITY' ) {
				url = "/approval/senseQualityReportPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'RESULT' ) {
				url = "/approval/newProductResultPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			} else if( docType == 'CHEMICAL' ) {
				url = "/approval/chemicalTestPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			} else if( docType == 'RECIPE' ) {
				url = "/approval/recipePopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			} else if( docType == 'ETC' ) {
				url = "/approval/etcPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			}
		} else if( $("#listType").val() == 'myCompList' ) {
			mode = "width=1100, height=600, left=100, top=10, scrollbars=yes";
			if( docType == 'PROD' ) {
				url = "/approval/productPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			} else if( docType == 'MENU' ) {
				url = "/approval/menuPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();;
			} else if( docType == 'DESIGN' ) {
				url = "/approval/designPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'PLAN' ) {
				url = "/approval/businessTripPlanPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'TRIP' ) {
				url = "/approval/businessTripPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'RESEARCH' ) {
				url = "/approval/marketResearchPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'SENSE_QUALITY' ) {
				url = "/approval/senseQualityReportPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
			} else if( docType == 'RESULT' ) {
				url = "/approval/newProductResultPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			} else if( docType == 'CHEMICAL' ) {
				url = "/approval/chemicalTestPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			} else if( docType == 'RECIPE' ) {
				url = "/approval/recipePopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			} else if( docType == 'ETC' ) {
				url = "/approval/etcPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
			}
		}
		
		window.open(url, "ApprovalPopup", mode );
	}
	
	function fn_refInfo( apprIdx, refIdx,  docType, docIdx ) {
		var url = "";
		mode = "width=1100, height=600, left=100, top=10, scrollbars=yes";
		if( docType == 'PROD' ) {
			url = "/approval/productPopup?apprIdx="+apprIdx+"&refIdx="+refIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
		} else if( docType == 'MENU' ) {
			url = "/approval/menuPopup?apprIdx="+apprIdx+"&refIdx="+refIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();;
		} else if( docType == 'DESIGN' ) {
			url = "/approval/designPopup?apprIdx="+apprIdx+"&refIdx="+refIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
		} else if( docType == 'PLAN' ) {
			url = "/approval/businessTripPlanPopup?apprIdx="+apprIdx+"&refIdx="+refIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
		} else if( docType == 'TRIP' ) {
			url = "/approval/businessTripPopup?apprIdx="+apprIdx+"&refIdx="+refIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
		} else if( docType == 'RESEARCH' ) {
			url = "/approval/marketResearchPopup?apprIdx="+apprIdx+"&refIdx="+refIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
		} else if( docType == 'SENSE_QUALITY' ) {
			url = "/approval/senseQualityReportPopup?apprIdx="+apprIdx+"&refIdx="+refIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
		} else if( docType == 'RESULT' ) {
			url = "/approval/newProductResultPopup?apprIdx="+apprIdx+"&refIdx="+refIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
		} else if( docType == 'CHEMICAL' ) {
			url = "/approval/chemicalTestPopup?apprIdx="+apprIdx+"&refIdx="+refIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
		} else if( docType == 'RECIPE' ) {
			url = "/approval/recipePopup?apprIdx="+apprIdx+"&refIdx="+refIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
		} else if( docType == 'ETC' ) {
			url = "/approval/etcPopup?apprIdx="+apprIdx+"&refIdx="+refIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
		}
		window.open(url, "RefPopup", mode );
	}
	
	function loadCount() {
		$("#myCount").html("내가 올린 결재문서");
		$("#apprCount").html("결재진행중 문서");
		$("#refCount").html("참조 문서");
		$("#compCount").html("결재완료 문서");
	}

	function loadMyList( pageNo ) {
		var colgroup = "";
		colgroup += "<col width=\"10%\">";
		colgroup += "<col width=\"13%\">";
		colgroup += "<col width=\"13%\">";
		colgroup += "<col />";
		colgroup += "<col width=\"10%\">";
		colgroup += "<col width=\"15%\">";
		colgroup += "<col width=\"15%\">";
		var thead = "";
		thead += "<tr>";
		thead += "<th>결재번호</th>";
		thead += "<th>문서구분</th>";
		thead += "<th>결재진행단계</th>";
		thead += "<th>결재문서명</th>";
		thead += "<th>현재결재</th>";
		thead += "<th>상신일</th>";
		thead += "<th>결재설정</th>";
		thead += "</tr>";
		$("#colgroup").html(colgroup);
		$("#thead").html(thead);
		$("#list").html("");
		$("#listType").val("myList");
		var viewCount = $("#viewCount").selectedValues()[0];
		if( viewCount == '' ) {
			viewCount = "10";
		}
		var URL = "../approval/selectListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"pageNo":pageNo,
				"searchStatus":$(":input:radio[name=searchStatus]:checked").val(),
				"searchType":$("#searchType").selectedValues()[0],
				"searchValue":$("#searchValue").val(),
				"viewCount":viewCount
			},
			dataType:"json",
			success:function(data) {
				var html = "";
				if( data.totalCount > 0 ) {
					$("#list").html(html);
					data.list.forEach(function (item) {
						html += "<tr>";
						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.APPR_IDX + "</td>";
						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.DOC_TYPE_NAME + "</td>";

						if (item.LAST_STATUS == 'N') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class='app01'>" + item.LAST_STATUS_TXT + "</span></td>";
						} else if (item.LAST_STATUS == 'A') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class='app01'>" + item.LAST_STATUS_TXT + " (" + item.CURRENT_STEP + "/" + item.TOTAL_STEP + ")</span></td>";
						} else if (item.LAST_STATUS == 'R' || item.LAST_STATUS == 'C') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class='app03'>" + item.LAST_STATUS_TXT + "</span></td>";
						} else if (item.LAST_STATUS == 'CA') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class='app04'>" + item.LAST_STATUS_TXT + "</span></td>";
						} else if (item.LAST_STATUS == 'Y') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class='app02'>" + item.LAST_STATUS_TXT + "</span></td>";
						}

						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.TITLE + "</td>";

						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">";
						if (item.LAST_STATUS == 'N') {
							html += item.CURRENT_USER_NAME;
						}
						html += "	</td>";

						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.REG_DATE_TXT + "</td>";

						html += "	<td>";
						html += "		<ul class=\"list_ul\">";
						html += "			<li>";
						if( item.LAST_STATUS == 'N' ) {
							html += "			<button class=\"btn_doc\" onClick=\"cancelAppr('"+item.APPR_IDX+"','"+item.DOC_TYPE+"','"+item.DOC_IDX+"')\"><img src=\"/resources/images/icon_doc06.png\"> 상신취소</button>";
						} else if( item.LAST_STATUS == 'CA' ) {
							//html += "			<li><button type=\"button\" class=\"btn_doc\" onClick=\"reAppr('"+item.APPR_IDX+"','"+item.DOC_TYPE+"','"+item.DOC_IDX+"');\"><img src=\"/resources/images/icon_doc03.png\"> 재상신</button></li>";
						}
						if( item.LAST_STATUS == 'Y' ) {
							html += "		<button class=\"btn_doc\" onclick=\"javascript:fn_openRefPopup('"+item.APPR_IDX+"')\"><img src=\"/resources/images/icon_doc02.png\">참조</button>";
							html += "		<button class=\"btn_doc\" onclick=\"javascript:fn_openRefListPopup('"+item.APPR_IDX+"')\"><img src=\"/resources/images/icon_doc03.png\">참조자리스트</button>";
						}
						html += "			</li>";
						html += "		</ul>";
						html += "	</td>";
						html += "</tr>";
					});					
				} else {
					$("#list").html(html);
					html += "<tr><td align='center' colspan='7'>데이터가 없습니다.</td></tr>";
				}
				$("#list").html(html);
				$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
				$('#pageNo').val(data.navi.pageNo);
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
	
	function loadMyApprList( pageNo ) {
		var colgroup = "";
		colgroup += "<col width=\"10%\">";
		colgroup += "<col width=\"13%\">";
		colgroup += "<col width=\"13%\">";
		colgroup += "<col />";
		colgroup += "<col width=\"10%\">";
		colgroup += "<col width=\"15%\">";
		var thead = "";
		thead += "<tr>";
		thead += "<th>결재번호</th>";
		thead += "<th>문서구분</th>";
		thead += "<th>결재진행단계</th>";
		thead += "<th>결재문서명</th>";
		thead += "<th>상신자</th>";
		thead += "<th>상신일</th>";
		thead += "</tr>";
		$("#colgroup").html(colgroup);
		$("#thead").html(thead);
		$("#list").html("");
		$("#listType").val("myApprList");
		var viewCount = $("#viewCount").selectedValues()[0];
		if( viewCount == '' ) {
			viewCount = "10";
		}
		var URL = "../approval/selectMyApprListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"pageNo":pageNo,
				"searchStatus":$(":input:radio[name=searchStatus]:checked").val(),
				"searchType":$("#searchType").selectedValues()[0],
				"searchValue":$("#searchValue").val(),
				"viewCount":viewCount
			},
			dataType:"json",
			success:function(data) {
				var html = "";
				if( data.totalCount > 0 ) {
					$("#list").html(html);
					data.list.forEach(function (item) {
						html += "<tr>";
						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.APPR_IDX + "</td>";

						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.DOC_TYPE_NAME + "</td>";

						if (item.LAST_STATUS == 'N' || item.LAST_STATUS == 'A') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class=\"app01\">" + item.LAST_STATUS_TXT + " (" + item.CURRENT_STEP + "/" + item.TOTAL_STEP + ")</span></td>";
						} else if (item.LAST_STATUS == 'R' || item.LAST_STATUS == 'C') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class=\"app03\">" + item.LAST_STATUS_TXT + "</span></td>";
						} else if (item.LAST_STATUS == 'CA') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class=\"app04\">" + item.LAST_STATUS_TXT + "</span></td>";
						} else if (item.LAST_STATUS == 'Y') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class=\"app02\">" + item.LAST_STATUS_TXT + "</span></td>";
						}

						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.TITLE + "</td>";

						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.REG_USER_NAME + "</td>";

						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.REG_DATE_TXT + "</td>";

						html += "</tr>";
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
	
	function loadMyRefList( pageNo ) {
		var colgroup = "";
		colgroup += "<col width=\"10%\">";
		colgroup += "<col width=\"10%\">";
		colgroup += "<col />";
		colgroup += "<col width=\"10%\">";
		colgroup += "<col width=\"10%\">";
		colgroup += "<col width=\"15%\">";
		var thead = "";
		thead += "<tr>";
		thead += "<th>결재번호</th>";
		thead += "<th>문서구분</th>";
		thead += "<th>문서명</th>";
		thead += "<th>열람여부</th>";
		thead += "<th>상신자</th>";
		thead += "<th>상신일</th>";
		thead += "</tr>";
		$("#colgroup").html(colgroup);
		$("#thead").html(thead);
		$("#list").html("");
		$("#listType").val("myRefList");
		var viewCount = $("#viewCount").selectedValues()[0];
		if( viewCount == '' ) {
			viewCount = "10";
		}
		var URL = "../approval/selectMyRefListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"pageNo":pageNo,
				"searchStatus":$(":input:radio[name=searchStatus]:checked").val(),
				"searchType":$("#searchType").selectedValues()[0],
				"searchValue":$("#searchValue").val(),
				"viewCount":viewCount
			},
			dataType:"json",
			success:function(data) {
				var html = "";
				if( data.totalCount > 0 ) {
					$("#list").html(html);
					data.list.forEach(function (item) {
						html += "<tr>";
						html += "	<td onclick=\"fn_refInfo('" + item.APPR_IDX + "', '" + item.REF_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.APPR_IDX + "</td>";

						html += "	<td onclick=\"fn_refInfo('" + item.APPR_IDX + "', '" + item.REF_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.DOC_TYPE_NAME + "</td>";

						html += "	<td onclick=\"fn_refInfo('" + item.APPR_IDX + "', '" + item.REF_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><a href=\"#\" onclick=\"return false;\">" + item.TITLE + "</a></td>";

						html += "	<td onclick=\"fn_refInfo('" + item.APPR_IDX + "', '" + item.REF_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">";
						if( item.REG_USER_NAME == 'Y' ){
							html += "확인완료";
						} else {
							html += "미열람"; 
						}
						html += "</td>";
						
						html += "	<td onclick=\"fn_refInfo('" + item.APPR_IDX + "', '" + item.REF_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.REG_USER_NAME + "</td>";

						html += "	<td onclick=\"fn_refInfo('" + item.APPR_IDX + "', '" + item.REF_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.REG_DATE_TXT + "</td>";

						html += "</tr>";
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
	
	function loadMyCompList( pageNo ) {
		var colgroup = "";
		colgroup += "<col width=\"10%\">";
		colgroup += "<col width=\"13%\">";
		colgroup += "<col width=\"13%\">";
		colgroup += "<col />";
		colgroup += "<col width=\"10%\">";
		colgroup += "<col width=\"15%\">";
		var thead = "";
		thead += "<tr>";
		thead += "<th>결재번호</th>";
		thead += "<th>문서구분</th>";
		thead += "<th>결재진행단계</th>";
		thead += "<th>결재문서명</th>";
		thead += "<th>현재결재</th>";
		thead += "<th>상신일</th>";
		thead += "</tr>";
		$("#colgroup").html(colgroup);
		$("#thead").html(thead);
		$("#list").html("");
		$("#listType").val("myCompList");
		var viewCount = $("#viewCount").selectedValues()[0];
		if( viewCount == '' ) {
			viewCount = "10";
		}
		var URL = "../approval/selectMyCompListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"pageNo":pageNo,
				"searchStatus":$(":input:radio[name=searchStatus]:checked").val(),
				"searchType":$("#searchType").selectedValues()[0],
				"searchValue":$("#searchValue").val(),
				"viewCount":viewCount
			},
			dataType:"json",
			success:function(data) {
				var html = "";
				if( data.totalCount > 0 ) {
					$("#list").html(html);
					data.list.forEach(function (item) {
						html += "<tr>";
						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.APPR_IDX + "</td>";

						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.DOC_TYPE_NAME + "</td>";

						if (item.LAST_STATUS == 'N') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class=\"app01\">" + item.LAST_STATUS_TXT + "</span></td>";
						} else if (item.LAST_STATUS == 'A') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class=\"app01\">" + item.LAST_STATUS_TXT + " (" + item.CURRENT_STEP + "/" + item.TOTAL_STEP + ")</span></td>";
						} else if (item.LAST_STATUS == 'R' || item.LAST_STATUS == 'C') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class=\"app03\">" + item.LAST_STATUS_TXT + "</span></td>";
						} else if (item.LAST_STATUS == 'Y') {
							html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><span class=\"app02\">" + item.LAST_STATUS_TXT + "</span></td>";
						}

						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\"><a href=\"#\" onclick=\"return false;\">" + item.TITLE + "</a></td>";

						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.REG_USER_NAME + "</td>";

						html += "	<td onclick=\"fn_approvalInfo('" + item.APPR_IDX + "', '" + item.DOC_TYPE + "', '" + item.DOC_IDX + "')\" style=\"cursor:pointer;\">" + item.REG_DATE_TXT + "</td>";
						
						html += "</tr>";
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
	
	function goSearch(){
		if( $("#listType").val() == 'myList' ){
			loadMyList('1');
		} else if( $("#listType").val() == 'myApprList' ){
			loadMyApprList('1');
		} else if( $("#listType").val() == 'myRefList' ){
			loadMyRefList('1');
		} else if( $("#listType").val() == 'myCompList' ){
			loadMyCompList('1');
		}
	}
	
	function cancelAppr( apprIdx, docType, docIdx ) {		
		var URL = "../approval/cancelApprAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"apprIdx" : apprIdx
				, "docType" : docType
				, "docIdx" : docIdx
				, "status" : 'CA'
				, "docStatus" : 'TMP'
			},
			dataType:"json",
			async:false,
			success:function(data) {
				if( data.RESULT == 'S' ) {
					alert("상신취소되었습니다.");
					loadMyList('1');
				} else if( data.RESULT == 'F' ){
					alert(data.MESSAGE);
				} else {
					alert("오류가 발생하였습니다.\n"+data.MESSAGE);
				}
			},
			error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}
		});
	}
	
	function reAppr( apprIdx, docType, docIdx ) {		
		var URL = "../approval/reApprAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"apprIdx" : apprIdx
				, "docType" : docType
				, "docIdx" : docIdx
				, "status" : 'N'
				, "docStatus" : 'APPR'
			},
			dataType:"json",
			async:false,
			success:function(data) {
				if( data.RESULT == 'S' ) {
					alert("재상신되었습니다.");
					loadMyList('1');
				} else if( data.RESULT == 'F' ){
					alert(data.MESSAGE);
				} else {
					alert("오류가 발생하였습니다.\n"+data.MESSAGE);
				}
			},
			error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}
		});
	}
	
	function viewApprInfo( apprIdx ) {
		
	}
	
	function goClear() {
		$("input:radio[name='type']:radio[value='']").prop('checked', true); // 선택하기
		$("#searchType").selectOptions("");
		$("#searchType_label").html("선택");
		$("#searchValue").val("");
		$("#viewCount").selectOptions("");
		$("#viewCount").html("선택");
		goSearch();
	}
	
	function fn_changeTab( type ) {
		$(".tab02").children("ul").children().toArray().forEach(function(obj){
			if( $(obj).children('li').prop('id') == type ) {
				$(obj).children('li').prop('class','select');
				$("#docTitle").html($(obj).children('li').html());
			} else {
				$(obj).children('li').prop('class','')
			}
		});
		if( type == 'myCount' ) {
			loadMyList('1');
			$("#li_searchStatus").show();
		} else if( type == 'apprCount' ) {
			loadMyApprList('1');
			$("#li_searchStatus").hide();
		} else if( type == 'refCount' ) {
			loadMyRefList('1');
			$("#li_searchStatus").hide();
		} else if( type == 'compCount' ) {
			loadMyCompList('1');
			$("#li_searchStatus").hide();
		}
	}
	
	function fn_openRefPopup(idx) {
		$("#apprIdx").val(idx);
		openDialog('refUserDialog')
	}
	
	function fn_closeRefPopup() {
		$("#apprIdx").val("");
		$("#refUserKeyword").val("");
		$("#userId").val("");
		$("#userName").val("");
		$("#deptName").val("");
		$("#teamName").val("");
		$("#refStartDate").val("");
		$("#refEndDate").val("");
		$("#refLine").removeOption(/./);
		$("#refLineList").empty();		
		closeDialog('refUserDialog')
	}

	function fn_addRefUser() {
		if( $("#userId").val() == '' ) {
			alert("참조자를 선택해주세요.");
			return;
		}
		if( $("#refLine").containsOption($("#userId").val()) ) {
			alert("이미 등록된 참조자입니다.");
			$("#refUserKeyword").val("");
			$("#userId").val("");
			$("#userName").val("");
			$("#deptName").val("");
			$("#teamName").val("");
			$("#refStartDate").val("");
			$("#refEndDate").val("");
			return;
		}
		

		if( $("#refStartDate").val() == '' && $("#refEndDate").val() == '' ) {
			if( confirm('열람기간을 선택하지 않으시겠습니까?') ) {
				$("#refLine").addOption($("#userId").val(), $("#userName").val(), true);
				html = "<li>";
				html += "<img src='../resources/images/icon_del_file.png' name='delImg' alt='' data-apprtype='R' onclick='apprClass.approvalRemoveLine(this);' >";
				html += "<span>참조</span> " + $("#userName").val();
				//html += "<strong>/" + $("#userId").val() + "/" + $("#deptName").val() + "/" + $("#teamName").val() + "</strong>";
				html += "<strong> ( 참조기간 제한 없음 ) </strong>";
				html += "<input type='hidden' name='userIds' data-apprtype='R' value='" + $("#userId").val() + "'/>";
				html += "<input type='hidden' name='refStartDates' data-apprtype='R' value='" + $("#refStartDate").val() + "'/>";
				html += "<input type='hidden' name='refEndDates' data-apprtype='R' value='" + $("#refEndDate").val() + "'/>";
				html += "</li>";
				$("#refLineList").append(html);
				$("#refUserKeyword").val("");
				$("#userId").val("");
				$("#userName").val("");
				$("#deptName").val("");
				$("#teamName").val("");
				$("#refStartDate").val("");
				$("#refEndDate").val("");
			} else {
				return;
			}
		} else {
			$("#refLine").addOption($("#userId").val(), $("#userName").val(), true);
			html = "<li>";
			html += "<img src='../resources/images/icon_del_file.png' name='delImg' alt='' data-apprtype='R' onclick='apprClass.approvalRemoveLine(this);' >";
			html += "<span>참조</span> " + $("#userName").val();
			html += "<strong> ( " + $("#refStartDate").val();
			if( $("#refEndDate").val() != '' ) {
				html += " ~ ";
			}
			html += "" + $("#refEndDate").val() + " )</strong>";
			html += "<input type='hidden' name='userIds' data-apprtype='R' value='" + $("#userId").val() + "'/>";
			html += "<input type='hidden' name='refStartDates' data-apprtype='R' value='" + $("#refStartDate").val() + "'/>";
			html += "<input type='hidden' name='refEndDates' data-apprtype='R' value='" + $("#refEndDate").val() + "'/>";
			html += "</li>";
			$("#refLineList").append(html);
			$("#refUserKeyword").val("");
			$("#userId").val("");
			$("#userName").val("");
			$("#deptName").val("");
			$("#teamName").val("");
			$("#refStartDate").val("");
			$("#refEndDate").val("");
		}
		
	}
	
	function fn_addRefLine() {
		if( $("#refLineList").children().length == 0 ) {
			alert("참조자를 등록해주세요.");
			return;
		} else {
			$('#lab_loading').show();
			var formData = new FormData();
			
			formData.append("apprIdx", $("#apprIdx").val());
			var userIdArr = new Array();
			var startDateArr = new Array();
			var endDateArr = new Array();
			$("#refLineList").children().each(function(){
				userIdArr.push($(this).children('input[name=userIds]').val());
				startDateArr.push($(this).children('input[name=refStartDates]').val());
				endDateArr.push($(this).children('input[name=refEndDates]').val());
			});
			formData.append("userIdArr", JSON.stringify(userIdArr));
			formData.append("startDateArr", JSON.stringify(startDateArr));
			formData.append("endDateArr", JSON.stringify(endDateArr));
			
			var URL = "../approval/addReferenceAjax";
			$.ajax({
				type:"POST",
				url:URL,
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				dataType:"json",
				success:function(data) {
					if( data.RESULT == 'S' ) {
						alert("참조자가 추가되었습니다.");
						fn_closeRefPopup();
						$('#lab_loading').hide();
						loadMyList(1);	
					} else {
						alert("참조자 등록 오류가 발생하였습니다.\n"+data.MESSAGE);
						fn_closeRefPopup();
						$('#lab_loading').hide();
					}
					
				},
				error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
					$('#lab_loading').hide();
				}			
			});
		}
	}
	
	function fn_openRefListPopup(idx) {
		var URL = "../approval/selectRefInfoListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"apprIdx":idx
			},
			dataType:"json",
			success:function(data) {
				var html = "";
				$("#refUserListBody").empty();
				if( data.length > 0 ) {
					data.forEach(function (item) {
						html += "<tr>";
						html += "	<td>"+item.USER_NAME+"</td>";
						html += "	<td>"+nvl(item.OBJTTX,'')+"</td>";
						html += "	<td>";
						if( item.IS_READ == 'Y') {
							html += "확인";
						} else {
							html += "미확인";
						}
						html += "	</td>";
						html += "	<td>";
						if( item.REF_END_DATE == '9999-12-31') {
							html += "참조기간 제한 없음";
						} else {
							html += item.REF_START_DATE + " ~ "+item.REF_END_DATE;
						}
						html += "	</td>";
						html += "</tr>";
					});
				} else {
					html += "<tr>";
					html += "<td colspan='4'>참조자 정보가 없습니다.</td>";
					html += "</tr>";
				}
				$("#refUserListBody").html(html);
				openDialog('refUserListDialog');
				
			},
			error:function(request, status, errorThrown){
				var html = "";
				$("#refUserListBody").empty();
				html += "<tr>";
				html += "	<td colspan='4'>오류가 발생했습니다.</td>";
				html += "</tr>";
				$("#refUserListBody").html(html);
				openDialog('refUserListDialog');
			}			
		});
	}
	
</script>
<input type="hidden" name="pageNo" id="pageNo" value="${paramVO.pageNo}">
<input type="hidden" name="listType" id="listType" value="">
<div class="wrap_in" id="fixNextTag">
	<span class="path">결재함&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Approval Doc</span>
			<span class="title" id="docTitle">내가 올린 결재문서</span>
			<div  class="top_btn_box">
				<ul><li></li></ul>
			</div>
		</h2>
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="tab02">
				<ul>
				<!-- 선택됬을경우는 탭 클래스에 select를 넣어주세요 -->
				<!-- 내 제품설계서 같은경우는 change select 이렇게 change 그대로 두고 한칸 띄고 select 삽입 -->
				<a href="#" onClick="fn_changeTab('myCount')"><li  class="select" id="myCount">내가 올린 결재문서</li></a>
				<a href="#" onClick="fn_changeTab('apprCount')"><li class="" id="apprCount">결재진행중 문서</li></a>
				<a href="#" onClick="fn_changeTab('refCount')"><li class="" id="refCount">참조 문서</li></a>
				<a href="#" onClick="fn_changeTab('compCount')"><li class="" id="compCount">결재완료 문서</li></a>
				</ul>
			</div>
			<div class="search_box" >
				<ul style="border-top:none;">
					<li id="li_searchStatus">
						<dt>문서상태</dt>
						<dd style="width:400px">
						<!-- 초기값은 보통으로 -->
							<input type="radio" id="r1" name="searchStatus" value="" checked/ ><label for="r1"><span></span>전체</label>
							<input type="radio" id="r2" name="searchStatus" value="A"/><label for="r2"><span></span>결재중</label>
							<!-- <input type="radio" id="r3" name="searchStatus" value="CA"/><label for="r3"><span></span>상신취소</label> -->
							<input type="radio" id="r4" name="searchStatus" value="C"><label for="r4"><span></span>결재완료</label>
							<input type="radio" id="r5" name="searchStatus" value="R"><label for="r5"><span></span>결재반려</label>
						</dd>
					</li>
					<li>
						<dt>키워드</dt>
						<dd style="widht:400px">
							<div class="selectbox" style="width:100px;">  
								<label for="searchType" id="searchType_label">선택</label> 
								<select id="searchType" name="searchType">
									<option value="">선택</option>
									<option value="U">결재자</option>
									<option value="K">문서명</option>
								</select>
							</div>
							<input type="text" name="searchValue" id="searchValue" style="width:200px; margin-left:5px;"/>
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
					<button type="button" class="btn_con_search" onClick="javascript:goSearch()"><img src="/resources/images/btn_icon_search.png" style="vertical-align:middle;"/> 검색</button>
					<button type="button" class="btn_con_search" onClick="goClear()"><img src="/resources/images/btn_icon_refresh.png" style="vertical-align:middle;"/> 검색 초기화</button>
				</div>
			</div>
			<div class="main_tbl">
				<table class="tbl01">
					<colgroup id="colgroup">
						<col width="10%">
						<col width="13%">
						<col width="13%">
						<col />
						<col width="10%">
						<col width="15%">
						<col width="8%">
					</colgroup>
					<thead id="thead">
						<tr>
							<th>결재번호</th>
							<th>문서구분</th>
							<th>결재진행단계</th>
							<th>결재문서명</th>
							<th>현재결재</th>
							<th>상신일</th>
							<th>결재설정</th>
						</tr>
					</thead>
					<tbody id="list">
					</tbody>
				</table>	
				<div class="page_navi  mt10">
				</div>
			</div>
			<div class="btn_box_con"></div>
			<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
	</section>
</div>

<!-- 참조자 추가 팝업 start -->
<div class="white_content" id="refUserDialog">
	<input type="hidden" id="apprIdx" name="apprIdx"/>
	<input type="hidden" id="userId" />
	<input type="hidden" id="userName"/>
	<input type="hidden" id="deptName" />
	<input type="hidden" id="teamName" />
	<select style="display:none" id=refLine name="refLine" multiple>
 	</select>
	<div class="modal"
		style="margin-left: -300px; width: 650px; height: 450px; margin-top: -250px">
		<h5 style="position: relative">
			<span class="title">문서 참조자 선택</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close"
							onClick="fn_closeRefPopup();"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<!-- 사용자 검색 라인 -->
				<li>
					<dt style="width: 30%">사용자 조회</dt>
					<dd style="width: 70%; display: flex; justify-content: flex; align-items: center;">
						<input type="text" id="refUserKeyword"
							placeholder="이름 2자 이상 입력"
							style="width: 330px; margin-right: 5px;">
						<button class="btn_small01" onclick="fn_addRefUser()">추가</button>
					</dd>
				</li>
				<li>
					<dt style="width: 30%">열람기간</dt>
					<dd style="width: 70%; display: flex; justify-content: flex; align-items: center;">
						<input type="text" id="refStartDate" name="refStartDate" style="width: 120px; margin-right: 5px;">
						~
						<input type="text" id="refEndDate" name="refStartDate" style="width: 120px; margin-right: 5px;">
					</dd>
				</li>

				<!-- 선택된 사용자 라인 -->
				<li class="mt5">
					<dt style="width: 30%">선택된 사용자</dt>
					<dd style="width: 70%;">
						<div class="file_box_pop2" style="height: 180px;">
							<ul id="refLineList" style="margin-top: 10px;"></ul>
						</div>
					</dd>
				</li>
			</ul>
		</div>
		<div class="btn_box_con4" style="padding: 15px 0 20px 0">
			<button class="btn_admin_red"
				onclick="fn_addRefLine();">확인</button>
			<button class="btn_admin_gray"
				onclick="fn_closeRefPopup();">취소</button>
		</div>
	</div>
</div>
<!-- 참조자 추가 팝업 close -->

<!-- 참조자 조회 레이어 start-->
<div class="white_content" id="refUserListDialog">
	<div class="modal"
		style="width: 700px; margin-left: -360px; height: 450px; margin-top: -300px;">
		<h5 style="position: relative">
			<span class="title">참조자 리스트</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close"
							onClick="closeDialog('refUserListDialog')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="main_tbl" style="height: 300px; overflow-y: auto">
			<table class="tbl01">
				<colgroup>
					<col width="20%">
					<col width="25%">
					<col width="10%">
					<col />
				</colgroup>
				<thead>
					<tr>
						<th>이름</th>
						<th>부서</th>
						<th>확인여부</th>
						<th>참조기간</th>						
					<tr>
				</thead>
				<tbody id="refUserListBody">
				</tbody>
			</table>
		</div>
		<div class="btn_box_con4" style="padding: 15px 0 5px 0">
			<button class="btn_admin_gray"
				onclick="closeDialog('refUserListDialog');">확인</button>
		</div>
	</div>
</div>
<!-- 참조자 조회 레이어 close-->
	