<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page import="kr.co.genesiskorea.util.*" %> 
<%@ page session="false" %>
<title>결재함</title>
<style>
/*추가*/
.outside{ border:0; font-family:'맑은고딕',Malgun Gothic; font-size:12px;}
.outside td{border:2px solid #666;}
.intable_title{ border:0;}
.intable_title td{border:1px solid #666; text-align:center; height:22px;}
.jungjong{ border:0; text-align:center;}
.jungjong th,.jungjong td{ border:1px solid #666; height:18px;}
.jungjong tbody td{ border-bottom:1px solid #ddd !important; border-top:1px solid #ddd !important;}
.jungjong th, .jungjong tfoot td{ background-color:#ebebeb;}

.material{border:0; text-align:center;}
.material th,.material td{ border:1px solid #666; height:18px;}
.material tr th{ background-color:#ebebeb;}

.material_inbox{ border:1px solid #999; text-align:center;}
.material_inbox th,.material_inbox td{  height:18px;}
.material_inbox tbody td{ border-top:1px solid #ddd !important;}
.material_inbox th{ }
.water_mark{font-family:'맑은고딕',Malgun Gothic; font-size:13px; margin-top:10px; float:left;}
.big_font{ font-size:20px;}
.color01{ background-color:#eaf1dd;}
.color02{background-color:#fde9d9;}
.color03{background-color:#dbe5f1;}
.color04{background-color:#ddd9c3;}
.color05{background-color:#f3f3f3;}

/* 제조순서 번호css */
.imgbox {
    display: flex;
    flex-direction: row;
    justify-content: space-around;
  }
.imgNumbox{width:10%; border: 0.5px solid #000;}
.imgDescriptbox{width: 90%;}

</style>
<script type="text/javascript">
$(document).ready(function() {
	  document.oncontextmenu = function (e) {
		   return false;
	  }
	  document.ondragstart = function (e) {
		   return false;
	 }
	  document.onselectstart = function (e) {
		   return false;
	 }
});

function fn_approvalSubmit() {
	console.log($("#apprIdx").val());
	if(confirm("승인하시겠습니까?")) {
		var URL = "../approval/approvalSubmitAjax";
		$('#lab_loading').show();
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"apprIdx" : '${apprHeader.APPR_IDX}',
				"idx" : '${paramVO.idx}',
				"docIdx" : '${apprHeader.DOC_IDX}',
				"docType" : '${apprHeader.DOC_TYPE}',
				"totalStep" : '${apprHeader.TOTAL_STEP}',
				"currentStep" : '${apprHeader.CURRENT_STEP}',
				"currentUserId" : '${apprHeader.CURRENT_USER_ID}',
				"regUser" : '${apprHeader.REG_USER}',
				"itemIdx" : '${apprHeader.ITEM_IDX}',
				"apprNo" : '${apprHeader.APPR_NO}',
				"targetUserId" : '${apprHeader.TARGET_USER_ID}',
				"comment" : $("#comment").val(),
				"apprStatus" : 'Y'
			},
			dataType:"json",
			success:function(data) {
				if(data.RESULT == 'S' ) {
					alert("결재가 완료되었습니다.");
					window.opener.loadMyApprList('1');
					self.close();
				} else {
					if(data.RESULT == 'F'){
						alert(data.MESSAGE);
						self.close();
					}else{
						alert("결재 승인 중 오류가 발생하였습니다. \n다시 처리해주세요.");
					}
				}
			},
			error:function(request, status, errorThrown){
				alert("결재 승인 중 오류가 발생하였습니다. \n다시 처리해주세요.");
			},
			complete: function(){
				$('#lab_loading').hide();
			}
		});	
	}
}

function fn_approvalCondSubmit() {
	console.log($("#apprIdx").val());
	if( !chkNull($("#comment").val()) ) {
		alert("결재 의견을 입력해주세요.");
		$("#comment").focus();
		return;
	} else {
		if(confirm("부분승인 하시겠습니까?")) {
			var URL = "../approval/approvalCondSubmitAjax";
			$('#lab_loading').show();
			$.ajax({
				type:"POST",
				url:URL,
				data:{
					"apprIdx" : '${apprHeader.APPR_IDX}',
					"idx" : '${paramVO.idx}',
					"docIdx" : '${apprHeader.DOC_IDX}',
					"docType" : '${apprHeader.DOC_TYPE}',
					"totalStep" : '${apprHeader.TOTAL_STEP}',
					"currentStep" : '${apprHeader.CURRENT_STEP}',
					"currentUserId" : '${apprHeader.CURRENT_USER_ID}',
					"regUser" : '${apprHeader.REG_USER}',
					"itemIdx" : '${apprHeader.ITEM_IDX}',
					"apprNo" : '${apprHeader.APPR_NO}',
					"targetUserId" : '${apprHeader.TARGET_USER_ID}',
					"comment" : $("#comment").val(),
					"apprStatus" : 'C'
				},
				dataType:"json",
				success:function(data) {
					if(data.RESULT == 'S' ) {
						alert("결재가 완료되었습니다.");
						window.opener.loadMyApprList('1');
						self.close();
					} else {
						if(data.RESULT == 'F'){
							alert(data.MESSAGE);
							self.close();
						}else{
							alert("결재 승인 중 오류가 발생하였습니다. \n다시 처리해주세요.");
						}
					}
				},
				error:function(request, status, errorThrown){
					alert("결재 승인 중 오류가 발생하였습니다. \n다시 처리해주세요.");
				},
				complete: function(){
					$('#lab_loading').hide();
				}
			});	
		}
	}
}

function fn_approvalReject() {
	console.log($("#apprIdx").val());
	if( !chkNull($("#comment").val()) ) {
		alert("결재 의견을 입력해주세요.");
		$("#comment").focus();
		return;
	} else {
		if(confirm("반려 하시겠습니까?")) {
			var URL = "../approval/approvalRejectAjax";
			$('#lab_loading').show();
			$.ajax({
				type:"POST",
				url:URL,
				data:{
					"apprIdx" : '${apprHeader.APPR_IDX}',
					"idx" : '${paramVO.idx}',
					"docIdx" : '${apprHeader.DOC_IDX}',
					"docType" : '${apprHeader.DOC_TYPE}',
					"totalStep" : '${apprHeader.TOTAL_STEP}',
					"currentStep" : '${apprHeader.CURRENT_STEP}',
					"currentUserId" : '${apprHeader.CURRENT_USER_ID}',
					"regUser" : '${apprHeader.REG_USER}',
					"itemIdx" : '${apprHeader.ITEM_IDX}',
					"apprNo" : '${apprHeader.APPR_NO}',
					"targetUserId" : '${apprHeader.TARGET_USER_ID}',
					"comment" : $("#comment").val(),
					"apprStatus" : 'R'
				},
				dataType:"json",
				success:function(data) {
					if(data.RESULT == 'S' ) {
						alert("반려되었습니다.");
						window.opener.loadMyApprList('1');
						self.close();
					} else {
						if(data.RESULT == 'F'){
							alert(data.MESSAGE);
							self.close();
						}else{
							alert("반려처리 중 오류가 발생하였습니다. \n다시 처리해주세요.");
						}
					}
				},
				error:function(request, status, errorThrown){
					alert("반려처리 중 오류가 발생하였습니다. \n다시 처리해주세요.");
				},
				complete: function(){
					$('#lab_loading').hide();
				}
			});	
		}
	}
}

function fn_viewComment(itemIdx) {
	var URL = "../approval/selectApprItemAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"itemIdx" : itemIdx
		},
		dataType:"json",
		success:function(data) {
			$("#viewComment").html(getTextareaHTML(data.COMMENT));
		},
		error:function(request, status, errorThrown){
			alert("오류가 발생하였습니다.");
		}			
	});
}

function getTextareaHTML(note) {
    return "</p><p>"+ note.trim().replace(/\n\r?/g,"</p><p>") +"</p>";
}

function downloadFile(idx){
	location.href = '/test/fileDownload?idx='+idx;
}
</script>
<h2 style=" position:fixed;" class="print_hidden">
	<span class="title"><img src="/resources/images/bg_bs_box_fast02.png">결재</span>
</h2>
<div  class="top_btn_box" style=" position:fixed;">
	<ul>
		<li><button type="button" class="btn_pop_close" onClick="self.close();"></button></li>
	</ul>
</div>
<div id='print_page'  style="padding:60px 0 20px 20px;">
	<div class="group01 mt20">
		<div class="main_tbl">
			<form name="form" id="form" method="post" action="">
			<input type="hidden" name="apprIdx" id="apprIdx" value="${paramVO.apprIdx }">
			<table width="100%" cellpadding="0" cellspacing="0" class="print_hidden">
				<tr>
					<td valign="top">
						<div class="main_tbl">
							<table class="insert_proc01 tbl_app">
								<colgroup>
									<col width="13%"/>
									<col width="50%"/>
									<col />
								</colgroup>
								<tbody>
									<tr>
										<th style="border-left: none;">결재요청의견</th>
										<td colspan="3">
											${apprHeader.COMMENT}
										</td>
									</tr>
									<tr>
										<th style="border-left: none;"> 결재자</th>
										<td>
											<div class="file_box_pop5">
												<ul>
													<c:forEach items = "${apprItem}" var = "item" varStatus= "status">
													<input type="hidden" name="itemIdx" id="itemIdx" value="${item.ITEM_IDX }">
													<fmt:parseNumber var="itemIdx" type="number" value="${item.ITEM_IDX}" />
													<li onMouseOver="location.href='#'">
														<span>
															${item.APPR_NO}차 결재
														</span> 
														${item.TARGET_USER_NAME}
														(${item.STATUS_TXT})
														<c:if test="${item.COMMENT !=null && item.COMMENT ne '' }">
															<a href="#" onclick="fn_viewComment('${item.ITEM_IDX}');">
																의견 <img src="/resources/images/icon_app_mass.png"/>
															</a>
														</c:if>
													</li>										
													</c:forEach>
												</ul>
											</div>
										</td>
										<td id="viewComment">결재자 리스트 클릭시 결재의견을 확인할 수 있습니다.</td>
									</tr>
									<tr>
										<th style="border-left: none; ">참조자</th>
										<td colspan="2">
											<div class="file_box_pop4">
													<c:forEach items = "${refList}" var = "ref" varStatus= "status">
														&nbsp;${ref.TARGET_USER_NAME}
														<c:if test="${status.index > 0}"> , </c:if>
													</c:forEach>												
											</div>
										</td>
									</tr>
									<c:if test="${paramVO.viewType eq 'myApprList' }">
									<c:if test="${apprHeader.LAST_STATUS eq 'N' || apprHeader.LAST_STATUS eq 'A' }">
									<c:if test = "${apprHeader.CURRENT_USER_ID eq paramVO.userId}">
									<tr>
										<th style="border-left: none; ">결재의견</th>
										<td colspan="3">
											<textarea style="width:100%; height:60px" name="comment" id="comment"></textarea>
										</td>
									</tr>
									</c:if>
									</c:if>
									</c:if>
								</tbody>
							</table>
						</div>
						<div class="fr pt20 pb10" style="margin-bottom:10px;"  id="buttonArea2">
						<c:if test="${paramVO.viewType eq 'myApprList' }">
						<c:if test="${apprHeader.LAST_STATUS eq 'N' || apprHeader.LAST_STATUS eq 'A' }">
							<c:if test = "${apprHeader.CURRENT_USER_ID eq paramVO.userId}">
								<button class="btn_con_search" style="border-color:#09F; color:#09F"  onclick="fn_approvalSubmit(); return false;" id="btn_submit"><img src="/resources/images/icon_s_approval.png"> 승인</button>
								<c:if test="${apprHeader.CURRENT_STEP < apprHeader.TOTAL_STEP}">
								<button class="btn_con_search" style="border-color:#09F; color:#09F"  onclick="fn_approvalCondSubmit(); return false;" id="btn_submit"><img src="/resources/images/icon_s_approval.png"> 부분승인</button>
								</c:if>
								<button class="btn_con_search" onclick="fn_approvalReject(); return false;" id="btn_reject"><img src="/resources/images/icon_doc06.png"> 반려</button>					
							</c:if>	
						</c:if>
						</c:if>
						</div>
					</td>
				</tr>
			</table>
			</form>
		</div>
	</div>	
	<div class="group01 mt5">
		<div class="main_tbl">
			<table class="insert_proc01">
				<colgroup>
					<col width="15%" />
					<col width="35%" />
					<col width="15%" />
					<col width="35%" />
				</colgroup>
				<tbody>
					<tr>
						<th style="border-left: none;">제목</th>
						<td colspan="3">${designData.data.TITLE}</td>
					</tr>
					<tr>
						<th style="border-left: none;">제품명</th>
						<td>
							${designData.data.PRODUCT_NAME}
						</td>
						<th style="border-left: none;">ERP코드</th>
						<td>
							${designData.data.SAP_CODE}
						</td>
					</tr>
					<tr>
						<th style="border-left: none;">변경사유</th>
						<td colspan="3">
							<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
							<c:if test="${addInfoList.INFO_TYPE == 'REA' }">	
								&nbsp;${addInfoList.INFO_TEXT} <br/>
							</c:if>	
							</c:forEach>	
						</td>
					</tr>
					<tr>
						<th style="border-left: none;">변경사항</th>
						<td colspan="3">
							<table class="tbl05" style="border-top: 2px solid #4b5165;">
								<colgroup>
									<col width="15%">
									<col width="34%">
									<col />
									<col width="15%">
								</colgroup>
								<thead>
									<tr>
										<th>구분</th>
										<th>기존</th>
										<th>변경</th>
										<th>비고</th>
									</tr>
								</thead>
								<tbody>
								<c:forEach items="${designChangeList}" var="designChangeList" varStatus="status">
									<tr>
										<td>
											${designChangeList.ITEM_DIV}				
										</td>
										<td>
											${strUtil:getHtml(designChangeList.ITEM_CURRENT)}							
										</td>
										<td>
											${strUtil:getHtml(designChangeList.ITEM_CHANGE)}							
										</td>
										<td>
											${designChangeList.ITEM_NOTE}
										</td>
									</tr>
								</c:forEach>	
								</tbody>
							</table>
						</td>
					</tr>
					<tr>
						<th style="border-left: none;">변경 적용 시점</th>
						<td colspan="3">
							<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
							<c:if test="${addInfoList.INFO_TYPE == 'TIME' }">	
								&nbsp;${addInfoList.INFO_TEXT}<br>
							</c:if>	
							</c:forEach>
						</td>
					</tr>
					<tr>
						<th style="border-left: none;">첨부파일</th>
						<td colspan="3" class="con_file">
							<ul>
								<li class="point_img">
									<dd>
										<ul>
											<c:forEach items="${designData.fileList}" var="fileList" varStatus="status">
												<li>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
											</c:forEach>
										</ul>
									</dd>
								</li>
							</ul>	
						</td>
					</tr>
				</tbody>
			</table>
		</div>
			
		<div>
			<table class="insert_proc01">
				<tr>
					<td><pre>${designData.data.CONTENTS}</pre></td>
				</tr>
			</table>
		</div>
	</div>
</div>