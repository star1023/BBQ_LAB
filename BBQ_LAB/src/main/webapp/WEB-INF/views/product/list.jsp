<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<title>개발완료보고서</title>
<script type="text/javascript">
	$(document).ready(function(){
		fn_loadTeam();
		fn_loadList(1);
		fn_loadSearchCategory(2,1);
		//1.임원인(roleCode가 4, 5) 경우에만 탭 설정 상관없이 팀, 담당자 필드를 표시한다.
		if( '${userUtil:getRoleCode(pageContext.request)}' == '4' || '${userUtil:getRoleCode(pageContext.request)}' == '5' ) {
			$("#searchTeam_li").show();
			$("#searchUser_li").show();
		}
	});
	
	function fn_loadSearchCategory(pIdx, level) {
		
		if( level == 2 ) {
			$("#searchCategory"+(level+1)).removeOption(/./);
			$("#searchCategory"+(level+1)+"_div").hide();
		}
		
		if( pIdx == '' ) {
			$("#searchCategory"+level).removeOption(/./);
			$("#searchCategory"+level+"_div").hide();
			return;
		}
		
		var URL = "../common/selectCategoryByPIdAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				pIdx : pIdx
			},
			dataType:"json",
			async:false,
			success:function(data) {
				var list = data;
				$("#searchCategory"+level).removeOption(/./);
				$("#searchCategory"+level).addOption("", "전체", false);
				$("#searchCategory"+level+"_label").html("전체");
				if( list.length > 0 ) {
					$("#searchCategory"+level+"_div").show();
					$.each(list, function( index, value ){ //배열-> index, value
						$("#searchCategory"+level).addOption(value.CATEGORY_IDX, value.CATEGORY_NAME, false);
					});
				}
			},
			error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	}
	
	function fn_changeCategory(obj,level){
		fn_loadSearchCategory($(obj).selectedValues()[0], level);
	}
	
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
		if( '${userUtil:getRoleCode(pageContext.request)}' == '2' || '${userUtil:getRoleCode(pageContext.request)}' == '7' ) {
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
			}
		}
		fn_search();
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
	
	function fn_loadList(pageNo) {
		var URL = "../product/selectProductListAjax";
		var viewCount = $("#viewCount").selectedValues()[0];
		if( viewCount == '' ) {
			viewCount = "10";
		}
		$("#list").html("<tr><td align='center' colspan='9'>조회중입니다.</td></tr>");
		$('.page_navi').html("");
		
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"searchType" : $("#searchType").selectedValues()[0]
				, "searchValue" : $("#searchValue").val()
				, "searchCategory1" : $("#searchCategory1").selectedValues()[0]
				, "searchCategory2" : $("#searchCategory2").selectedValues()[0]
				, "searchCategory3" : $("#searchCategory3").selectedValues()[0]
				, "searchFileTxt" : $("#searchFileTxt").val()
				, "viewCount":viewCount
				, "pageNo":pageNo
				, "listType":$('#listType').val()
				, "docType" : "PROD"
				, "searchTeam" : $("#searchTeam").selectedValues()[0]
				, "searchUser" : $("#searchUser").selectedValues()[0]
			},
			dataType:"json",
			success:function(data) {
				var html = "";
				if( data.totalCount > 0 ) {
					$("#list").html(html);
					data.list.forEach(function (item) {
						if( item.IS_LAST == 'Y' ) {
							html += "<tr id=\"product_"+item.DOC_NO+"_"+item.VERSION_NO+"\">";	
						} else {
							html += "<tr id=\"product_"+item.DOC_NO+"_"+item.VERSION_NO+"\" class=\"m_version\" style=\"display: none\">";
						}
						
						html += "	<td>";
						if( item.CHILD_CNT > 0 && item.IS_LAST == 'Y' ) {
							html += "		<img src=\"/resources/images/img_add_doc.png\" style=\"cursor: pointer;\" onclick=\"showChildVersion(this)\"/>";
						} else {
							html += "&nbsp;";
						}
						html += "	</td>";
						
						html += "	<td>"+nvl(item.PRODUCT_CODE,'&nbsp;')+"</td>";
						html += "	<td><div class=\"ellipsis_txt tgnl\"><a href=\"#\" onClick=\"fn_view('"+item.PRODUCT_IDX+"')\">"+nvl(item.NAME,'&nbsp;')+"</a></div></td>";
						html += "	<td>"+nvl(item.VERSION_NO,'&nbsp;')+"</td>";
						html += "	<td><div class=\"ellipsis_txt tgnl\"><a href=\"#\" onClick=\"fn_view('"+item.PRODUCT_IDX+"')\">"+nvl(item.TITLE,'&nbsp;')+"</a></div></td>";
						html += "	<td><div class=\"ellipsis_txt tgnl\">";
						if( chkNull(item.CATEGORY_NAME1) ) {
							html += item.CATEGORY_NAME1;
						}
						if( chkNull(item.CATEGORY_NAME2) ) {
							html += " > "+item.CATEGORY_NAME2;
						}
						if( chkNull(item.CATEGORY_NAME3) ) {
							html += " > "+item.CATEGORY_NAME3;
						}
						html += "	</div></td>";
						html += "	<td>"+nvl(item.STATUS_TXT,'&nbsp;')+"</td>";
						html += "	<td>"+nvl(item.USER_NAME,'&nbsp;')+"</td>";						
						html += "	<td>";
						if( item.IS_LAST == 'Y' ) {
							html += "		<li style=\"float:none; display:inline\">";
							html += "			<button class=\"btn_doc\" onclick=\"javascript:fn_viewHistory('"+item.PRODUCT_IDX+"', '"+item.DOC_NO+"')\"><img src=\"/resources/images/icon_doc05.png\">이력</button>";
							if( '${userUtil:getUserId(pageContext.request)}' == item.DOC_OWNER ) {
								if( item.STATUS == 'COMP' ) {
									html += "			<button class=\"btn_doc\" onclick=\"javascript:fn_versionUp('"+item.PRODUCT_IDX+"')\"><img src=\"/resources/images/icon_doc02.png\">개정</button>";
								}
								if( item.STATUS == 'TMP' || item.STATUS == 'COND_APPR' || item.STATUS == 'APPR_CANCEL' ) {
									html += "			<button class=\"btn_doc\" onclick=\"javascript:fn_update('"+item.PRODUCT_IDX+"', '"+item.DOC_NO+"')\"><img src=\"/resources/images/icon_doc03.png\">수정</button>";
								}	
							}
							html += "		</li>";
						}
						html += "	</td>";
						html += "</tr>"		
					});				
				} else {
					$("#list").html(html);
					html += "<tr><td align='center' colspan='9'>데이터가 없습니다.</td></tr>";
				}			
				$("#list").html(html);
				$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
				$('#pageNo').val(data.navi.pageNo);			
			},
			error:function(request, status, errorThrown){
				var html = "";
				$("#list").html(html);
				html += "<tr><td align='center' colspan='9'>오류가 발생하였습니다.</td></tr>";
				$("#list").html(html);
				$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
				$('#pageNo').val(data.navi.pageNo);
			}			
		});
	}

	function fn_insertForm() {
		window.location.href = "../product/insert";
	}
	
	function fn_view(idx) {
		window.location.href = "../product/view?idx="+idx;
	}
	
	function fn_versionUp(idx) {
		location.href = '/product/versionUp?idx='+idx;
	}
	
	function fn_viewHistory(idx, docNo) {
		var URL = "../product/selectHistoryAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"idx" : idx
				, "docNo" : docNo
				, "docType" : "PROD"
			},
			dataType:"json",
			async:false,
			success:function(data) {
				var html = "";
				data.forEach(function (item) {
					html += "<li>";
					if( item.NAME != '' ) {
						html += item.NAME;
					}
					if( item.PRODUCT_CODE != '' ) {
						html += "("+item.PRODUCT_CODE+")이(가)";
					}
					
					if( item.HISTORY_TYPE == 'I' ) {
						html += " 생성되었습니다.(버젼 : "+item.VERSION_NO+")";
					} else if( item.HISTORY_TYPE == 'V' ) {
						html += " 개정되었습니다.(버젼 : "+item.VERSION_NO+")";
					} else if( item.HISTORY_TYPE == 'D' ) {
						html += " 삭제되었습니다.";
					} else if( item.HISTORY_TYPE == 'U' ) {
						html += " 수정되었습니다.";
					} else if( item.HISTORY_TYPE == 'T' ) {
						html += " 임시저장 되었습니다.";
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
	
	function fn_update(idx, docNo) {
		location.href = '/product/update?idx='+idx;
	}
	
	function showChildVersion(imgElement){
		var docNo = $(imgElement).parent().parent().attr('id').split('_')[1];
		var elementImg = $(imgElement).attr('src').split('/')[$(imgElement).attr('src').split('/').length-1];
		
		var addImg = 'img_add_doc.png';
		
		if(elementImg == addImg){
			$(imgElement).attr('src', $(imgElement).attr('src').replace('_add_', '_m_')); 
			$('tr[id*=product_'+docNo+']').show();
		} else {
			$(imgElement).attr('src', $(imgElement).attr('src').replace('_m_', '_add_'));
			$('tr[id*=product_'+docNo+']').toArray().forEach(function(v, i){
				if(i != 0){
					$(v).hide();
				}
			})
		}
	}
	
	function fn_search() {
		fn_loadList(1);
	}
	
	function fn_searchClear() {
		$("#searchType").val("").prop("selected", true);
		$("#searchType_label").html("전체");
		$("#searchValue").val("");
		$("#searchCategory1").val("").prop("selected", true);
		$("#searchCategory1_label").html("전체");
		$("#searchCategory2_div").hide();
		$("#searchCategory2").removeOption(/./);
		$("#searchCategory3_div").hide();
		$("#searchCategory3").removeOption(/./);
		$("#searchFileTxt").val("");
		$("#viewCount").val("").prop("selected", true);
		$("#viewCount_label").html("전체");
	}
	
	function paging( pageNo ) {
		fn_loadList(pageNo);
	}
</script>

<input type="hidden" name="pageNo" id="pageNo" value="${paramVO.pageNo}">
<input type="hidden" name="imNo" id="imNo" value="">
<div class="wrap_in" id="fixNextTag">
	<span class="path">제품완료보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Complete List</span>
			<span class="title">제품완료보고서</span>
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
					<c:when test='${userUtil:getRoleCode(pageContext.request) == "1"}'>
						<c:set var="listType" value="my" />
					</c:when>
					<c:when test='${userUtil:getRoleCode(pageContext.request) == "2"}'>
						<c:set var="listType" value="my" />
					</c:when>
					<c:when test='${userUtil:getRoleCode(pageContext.request) == "3"}'>
						<c:set var="listType" value="my" />
					</c:when>
					<c:when test='${userUtil:getRoleCode(pageContext.request) == "4"}'>
						<c:set var="listType" value="all" />
					</c:when>
					<c:when test='${userUtil:getRoleCode(pageContext.request) == "5"}'>
						<c:set var="listType" value="all" />
					</c:when>
					<c:when test='${userUtil:getRoleCode(pageContext.request) == "6"}'>
						<c:set var="listType" value="my" />
					</c:when>
					<c:when test='${userUtil:getRoleCode(pageContext.request) == "7"}'>
						<c:set var="listType" value="my" />
					</c:when>
				</c:choose>
				<input type="hidden" name="listType" id="listType" value="${listType}">
				<ul class="tab">
					<c:choose>
						<c:when test='${userUtil:getRoleCode(pageContext.request) == "1"}'>
							<a href="javascript:changeListType('my')" id="my"><li class="select">'${userUtil:getUserName(pageContext.request)}님의 제품완료보고서</li></a>
							<a href="javascript:changeListType('all')" id="all"><li class="change">전체 제품완료보고서</li></a>						
						</c:when>
						<c:when test='${userUtil:getRoleCode(pageContext.request) == "2"}'>
							<a href="javascript:changeListType('my')" id="my"><li class="select">'${userUtil:getUserName(pageContext.request)}님의 제품완료보고서</li></a>
							<a href="javascript:changeListType('team')" id="team"><li class="change">${userUtil:getDeptName(pageContext.request)} 제품완료보고서</li></a>
							<a href="javascript:changeListType('share')" id="share"><li class="change">공동참여 제품완료보고서</li></a>
						</c:when>
						<c:when test='${userUtil:getRoleCode(pageContext.request) == "3"}'>
							<a href="javascript:changeListType('my')" id="my"><li class="select">'${userUtil:getUserName(pageContext.request)}님의 제품완료보고서</li></a>
							<a href="javascript:changeListType('share')" id="share"><li class="change">공동참여 제품완료보고서</li></a>
						</c:when>
						<c:when test='${userUtil:getRoleCode(pageContext.request) == "4"}'>
							<a href="javascript:changeListType('all')" id="all"><li class="change">전체 제품완료보고서</li></a>
						</c:when>
						<c:when test='${userUtil:getRoleCode(pageContext.request) == "5"}'>
							<a href="javascript:changeListType('all')" id="all"><li class="change">전체 제품완료보고서</li></a>
						</c:when>
						<c:when test='${userUtil:getRoleCode(pageContext.request) == "6"}'>
							<a href="javascript:changeListType('my')" id="my"><li class="select">'${userUtil:getUserName(pageContext.request)}님의 제품완료보고서</li></a>
							<a href="javascript:changeListType('share')" id="share"><li class="select">공동참여 제품완료보고서</li></a>
						</c:when>
						<c:when test='${userUtil:getRoleCode(pageContext.request) == "7"}'>
							<a href="javascript:changeListType('my')" id="my"><li class="select">'${userUtil:getUserName(pageContext.request)}님의 제품완료보고서</li></a>
							<a href="javascript:changeListType('team')" id="team"><li class="change">${userUtil:getDeptName(pageContext.request)} 제품완료보고서</li></a>
							<a href="javascript:changeListType('share')" id="share"><li class="change">공동참여 제품완료보고서</li></a>
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
									<option value="searchName">제품명</option>
									<option value="searchProductCode">제품코드</option>
								</select>
							</div>
							<input type="text" name="searchValue" id="searchValue" value="" style="width:180px; margin-left:5px;">
						</dd>
					</li>
					<li>
						<dt>제품구분</dt>
						<dd >
							<div class="selectbox" style="width:100px;" id="searchCategory1_div">  
								<label for="searchCategory1" id="searchCategory1_label">선택</label> 
								<select name="searchCategory1" id="searchCategory1" onChange="fn_changeCategory(this,2)">
								</select>
							</div>
							<div class="selectbox lm5" style="width:100px; margin-left:5px; display:none;" id="searchCategory2_div">  
								<label for="searchCategory2" id="searchCategory2_label">선택</label> 
								<select name="searchCategory2" id="searchCategory2" onChange="fn_changeCategory(this,3)">
								</select>
							</div>
							<div class="selectbox lm5" style="width:100px; margin-left:5px; display:none;" id="searchCategory3_div">  
								<label for="searchCategory3" id="searchCategory3_label">선택</label> 
								<select name="searchCategory3" id="searchCategory3">
								</select>
							</div>
						</dd>
					</li>
					<li id="searchTeam_li" style="display:none">
						<dt>팀</dt>
						<dd >
							<!-- 초기값은 보통으로 -->
							<div class="selectbox" style="width:180px;">  
								<label for="searchTeam" id="searchTeam_label">선택</label> 
								<select name="searchTeam" id="searchTeam" onChange="fn_loadUser()">
								</select>
							</div>
						</dd>
					</li>
					<li id="searchUser_li" style="display:none">
						<dt>담당자</dt>
						<dd >
							<!-- 초기값은 보통으로 -->
							<div class="selectbox" style="width:180px;">  
								<label for="searchUser" id="searchUser_label">선택</label> 
								<select name="searchUser" id="searchUser">
								</select>
							</div>
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
						<col width="45px">
						<col width="10%">
						<col width="15%">
						<col width="4%">	
						<col />
						<col width="20%">
						<col width="8%">
						<col width="8%">						
						<col width="15%">						
					</colgroup>
					<thead id="list_header">
						<tr>
							<th>&nbsp;</th>
							<th>제품코드</th>
							<th>제품명</th>
							<th>버젼</th>
							<th>제목</th>
							<th>제품구분</th>
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
				<button class="btn_admin_red" onclick="javascript:fn_insertForm();">완료보고서 생성</button>
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
