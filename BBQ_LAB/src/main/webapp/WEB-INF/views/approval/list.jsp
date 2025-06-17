<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ page session="false" %>
<title>결재함</title>
<script type="text/javascript">
	var PARAM = {
		type : '${paramVO.type}',
		state : '${paramVO.state}'
	};
	$(document).ready(function(){
		loadCount();
		loadMyList('1');
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
			}
		} else if( $("#listType").val() == 'myCompList' ) {
			mode = "width=1100, height=600, left=100, top=10, scrollbars=yes";
			if( docType == 'PROD' ) {
				url = "";
			} else if( docType == 'MENU' ) {
				url = "";
			} else if( docType == 'DESIGN' ) {
				url = "";	
			} else if( docType == 'PLAN' ) {
				url = "";
			} else if( docType == 'TRIP' ) {
				url = "";
			} else if( docType == 'RESEARCH' ) {
				url = "";	
			} else if( docType == 'SENSE_QUALITY' ) {
				url = "";	
			} else if( docType == 'RESULT' ) {
				url = "";	
			} else if( docType == 'CHEMICAL' ) {
				url = "";	
			}
		}
		
		window.open(url, "ApprovalPopup", mode );
	}
	
	function fn_refInfo( apprIdx, refIdx,  docType, docIdx ) {
		var url = "";
		var mode = "width=1100, height=600, left=100, top=10, scrollbars=yes";
		if( docType == 'PROD' ) {
			url = "/approval/productPopup?apprIdx="+apprIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();
		} else if( docType == 'MENU' ) {
			url = "";
		} else if( docType == 'DESIGN' ) {
			url = "/approval/designPopup?apprIdx="+apprId+"&refIdx="+refIdx+"&idx="+docIdx+"&viewType="+$("#listType").val();	
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
		colgroup += "<col width=\"8%\">";
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
				"type":$(":input:radio[name=type]:checked").val(),
				"searchType":$("#searchType").selectedValues()[0],
				"searchValue":$("#searchValue").val(),
				"viewCount":viewCount
			},
			dataType:"json",
			success:function(data) {
				console.log(data);
				var html = "";
				if( data.totalCount > 0 ) {
					$("#list").html(html);
					data.list.forEach(function (item) {
						html += "<tr>";
						html += "	<td>"+item.APPR_IDX+"</td>";
						html += "	<td>"+item.DOC_TYPE_NAME+"</td>";
						if( item.LAST_STATUS == 'N' ) {
							html += "		<td><span class=\"app01\">"+item.LAST_STATUS_TXT+"</span></td>";
						} else if( item.LAST_STATUS == 'A' ) {
							html += "		<td><span class=\"app01\">"+item.LAST_STATUS_TXT+" ("+item.CURRENT_STEP+"/"+item.TOTAL_STEP+")</span></td>";
						} else if( item.LAST_STATUS == 'R' ) {
							html += "		<td><span class=\"app03\">"+item.LAST_STATUS_TXT+"</span></td>";
						} else if( item.LAST_STATUS == 'C' ) {
							html += "		<td><span class=\"app03\">"+item.LAST_STATUS_TXT+"</span></td>";
						}  else if( item.LAST_STATUS == 'Y' ) {
							html += "		<td><span class=\"app02\">"+item.LAST_STATUS_TXT+"</span></td>";
						}
						html += "	<td><a href=\"#\" onclick=\"fn_approvalInfo('"+item.APPR_IDX+"', '"+item.DOC_TYPE+"', '"+item.DOC_IDX+"'); return false;\">"+item.TITLE+"</a></td>";
						html += "	<td>";
						if( item.LAST_STATUS == 'N' ) {
							html += item.CURRENT_USER_NAME;
						}
						html += "	</td>"
						html += "	<td>"+item.REG_DATE_TXT+"</td>";
						html += "	<td>";
						html += "		<ul class=\"list_ul\">";
						if( item.LAST_STATUS == 'N' ) {
							html += "			<li><button class=\"btn_doc\" onClick=\"cancelAppr('"+item.APPR_IDX+"','"+item.DOC_TYPE+"','"+item.DOC_IDX+"')\"><img src=\"/resources/images/icon_doc06.png\"> 상신취소</button></li>";
						} else if( item.LAST_STATUS == 'CA' ) {
							html += "			<li><button type=\"button\" class=\"btn_doc\" onClick=\"reAppr('"+item.APPR_IDX+"','"+item.DOC_TYPE+"','"+item.DOC_IDX+"');\"><img src=\"/resources/images/icon_doc03.png\"> 재상신</button></li>";
						}
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
				"type":$(":input:radio[name=type]:checked").val(),
				"searchType":$("#searchType").selectedValues()[0],
				"searchValue":$("#searchValue").val(),
				"viewCount":viewCount
			},
			dataType:"json",
			success:function(data) {
				console.log(data);
				var html = "";
				if( data.totalCount > 0 ) {
					$("#list").html(html);
					data.list.forEach(function (item) {
						html += "<tr>";
						html += "	<td>"+item.APPR_IDX+"</td>";
						html += "	<td>"+item.DOC_TYPE_NAME+"</td>";
						if( item.LAST_STATUS == 'N' ) {
							html += "		<td><span class=\"app01\">"+item.LAST_STATUS_TXT+" ("+item.CURRENT_STEP+"/"+item.TOTAL_STEP+")</span></td>";
						} else if( item.LAST_STATUS == 'A' ) {
							html += "		<td><span class=\"app01\">"+item.LAST_STATUS_TXT+" ("+item.CURRENT_STEP+"/"+item.TOTAL_STEP+")</span></td>";
						} else if( item.LAST_STATUS == 'R' ) {
							html += "		<td><span class=\"app03\">"+item.LAST_STATUS_TXT+"</span></td>";
						} else if( item.LAST_STATUS == 'C' ) {
							html += "		<td><span class=\"app03\">"+item.LAST_STATUS_TXT+"</span></td>";
						}  else if( item.LAST_STATUS == 'Y' ) {
							html += "		<td><span class=\"app02\">"+item.LAST_STATUS_TXT+"</span></td>";
						}
						html += "	<td><a href=\"#\" onclick=\"fn_approvalInfo('"+item.APPR_IDX+"', '"+item.DOC_TYPE+"', '"+item.DOC_IDX+"'); return false;\">"+item.TITLE+"</a></td>";
						html += "	<td>"+item.REG_USER_NAME+"</td>";
						html += "	<td>"+item.REG_DATE_TXT+"</td>";
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
		colgroup += "<col width=\"15%\">";
		var thead = "";
		thead += "<tr>";
		thead += "<th>결재번호</th>";
		thead += "<th>문서구분</th>";
		thead += "<th>문서명</th>";
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
				"type":$(":input:radio[name=type]:checked").val(),
				"searchType":$("#searchType").selectedValues()[0],
				"searchValue":$("#searchValue").val(),
				"viewCount":viewCount
			},
			dataType:"json",
			success:function(data) {
				console.log(data);
				var html = "";
				if( data.totalCount > 0 ) {
					$("#list").html(html);
					data.list.forEach(function (item) {
						html += "<tr>";
						html += "	<td>"+item.APPR_IDX+"</td>";
						html += "	<td>"+item.DOC_TYPE_NAME+"</td>";
						html += "	<td><a href=\"#\" onclick=\"fn_refInfo('"+item.APPR_IDX+"', '"+item.REF_IDX+"', '"+item.DOC_TYPE+"', '"+item.DOC_IDX+"'); return false;\">"+item.TITLE+"</a></td>";
						html += "	<td>"+item.REG_USER_NAME+"</td>";
						html += "	<td>"+item.REG_DATE_TXT+"</td>";
						html += "</tr>";
					});					
				} else {
					$("#list").html(html);
					html += "<tr><td align='center' colspan='5'>데이터가 없습니다.</td></tr>";
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
	
	function loadMyCompList( pageNo ) {
		var colgroup = "";
		colgroup += "<col width=\"10%\">";
		colgroup += "<col width=\"10%\">";
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
				"type":$(":input:radio[name=type]:checked").val(),
				"searchType":$("#searchType").selectedValues()[0],
				"searchValue":$("#searchValue").val(),
				"viewCount":viewCount
			},
			dataType:"json",
			success:function(data) {
				console.log(data);
				var html = "";
				if( data.totalCount > 0 ) {
					$("#list").html(html);
					data.list.forEach(function (item) {
						html += "<tr>";
						html += "	<td>"+item.APPR_IDX+"</td>";
						html += "	<td>"+item.DOC_TYPE_NAME+"</td>";
						if( item.LAST_STATUS == 'N' ) {
							html += "		<td><span class=\"app01\">"+item.LAST_STATUS_TXT+"</span></td>";
						} else if( item.LAST_STATUS == 'A' ) {
							html += "		<td><span class=\"app01\">"+item.LAST_STATUS_TXT+" ("+item.CURRENT_STEP+"/"+item.TOTAL_STEP+")</span></td>";
						} else if( item.LAST_STATUS == 'R' ) {
							html += "		<td><span class=\"app03\">"+item.LAST_STATUS_TXT+"</span></td>";
						} else if( item.LAST_STATUS == 'C' ) {
							html += "		<td><span class=\"app03\">"+item.LAST_STATUS_TXT+"</span></td>";
						}  else if( item.LAST_STATUS == 'Y' ) {
							html += "		<td><span class=\"app02\">"+item.LAST_STATUS_TXT+"</span></td>";
						}
						html += "	<td><a href=\"#\" onclick=\"fn_approvalInfo('"+item.APPR_IDX+"', '"+item.DOC_TYPE+"', '"+item.DOC_IDX+"'); return false;\">"+item.TITLE+"</a></td>";
						html += "	<td>"+item.REG_USER_NAME+"</td>";
						html += "	<td>"+item.REG_DATE_TXT+"</td>";
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
				, "docStatus" : 'REG'
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
		} else if( type == 'apprCount' ) {
			loadMyApprList('1');
		} else if( type == 'refCount' ) {
			loadMyRefList('1');
		} else if( type == 'compCount' ) {
			loadMyCompList('1');
		}
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
					<li>
						<dt>문서상태</dt>
						<dd style="width:400px">
						<!-- 초기값은 보통으로 -->
							<input type="radio" id="r1" name="type" value="" checked/ ><label for="r1"><span></span>전체</label>
							<input type="radio" id="r2" name="type" value="0"/><label for="r2"><span></span>결재중</label>
							<input type="radio" id="r3" name="type" value="1"><label for="r3"><span></span>결재완료</label>
							<input type="radio" id="r4" name="type" value="2"><label for="r4"><span></span>결재반려</label>
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
									<option value="K">제목</option>
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
	