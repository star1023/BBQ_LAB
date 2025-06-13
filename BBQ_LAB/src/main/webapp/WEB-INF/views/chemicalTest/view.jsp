<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>  <!-- ✅ 이거 추가 -->
<title>상품설계변경 보고서 생성</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 400px; min-height:150px;}
th.contentBlock {
	text-align: center !important;
}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	$(document).ready(function(){
		fn.autoComplete($("#keyword"));
	});
	
	function fn_goList() {
		location.href = '/chemicalTest/list';
	}
	
	function fn_update(idx) {
		location.href = '/chemicalTest/update?idx='+idx;
	}
	
	function downloadFile(idx){
		location.href = '/test/fileDownload?idx='+idx;
	}
	
	function fn_apprSubmit(){
		if( $("#apprLine option").length == 0 ) {
			alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 결재상신 해 주세요.");
			return;
		} else {
			$('#lab_loading').show();
			var formData = new FormData();
			formData.append("docIdx",'${chemicalTestData.data.CHEMICAL_IDX}');
			formData.append("apprComment", $("#apprComment").val());
			formData.append("apprLine", $("#apprLine").selectedValues());
			formData.append("refLine", $("#refLine").selectedValues());
			formData.append("title", '${chemicalTestData.data.PRODUCT_NAME}');
			formData.append("docType", $("#docType").val());
			formData.append("status", "N");
			var URL = "../approval/insertApprAjax";
			$.ajax({
				type:"POST",
				url:URL,
				dataType:"json",
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				success:function(data) {
					if(data.RESULT == 'S') {
						alert("상신되었습니다.");
						$('#lab_loading').hide();
						fn_goList();
					} else {
						alert("결재선 상신 오류가 발생하였습니다."+data.MESSAGE);
						$('#lab_loading').hide();
						return;
					}
				},
				error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
					$('#lab_loading').hide();
				}			
			});
		}
	}
	
	
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">
		이화학 검사 의뢰서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Request For Chemical Test</span><span class="title">이화학 검사 의뢰서</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<c:if test="${chemicalTestData.data.STATUS == 'REG' }">
							<button class="btn_small_search ml5" onclick="apprClass.openApprovalDialog()" style="float: left">결재</button>
						</c:if>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title2"  style="width: 80%;"><span class="txt">개요</span></div>
			<div class="title2" style="width: 20%; display: inline-block;">
				
			</div>
			<div class="main_tbl">
				<table class="insert_proc01">
					<colgroup>
						<col width="8%" />
						<col width="22%" />
						<col width="9%" />
						<col width="18%" />
						<col width="10%" />
						<col width="12%" />
					</colgroup>
					<tbody>
						<tr>
							<th style="border-left: none;">의뢰일자</th>
							<td>
								${chemicalTestData.data.REQUEST_DATE}								
							</td>
							<th style="border-left: none;">희망 완료일</th>
							<td>
								${chemicalTestData.data.COMPLETION_DATE}
							</td>
							<th style="border-left: none; width:120px;">의뢰자</th>
							<td>
								${chemicalTestData.data.REQUEST_USER}
							</td>
						</tr>		
					</tbody>
				</table>
			</div>
			
			<div class="title2"  style="width: 80%;"><span class="txt">내용</span></div>
			<div class="title2" style="width: 20%; display: inline-block;">
				
			</div>
			<div class="main_tbl">
				<table class="insert_proc01">
					<colgroup>
						<col width="8%" />
						<col width="22%" />
						<col width="9%" />
						<col width="18%" />
						<col width="10%" />
						<col width="12%" />
					</colgroup>
					<tbody>
						<tr>
							<th style="border-left: none;" class="contentBlock">시료명</th>
							<td>
								${chemicalTestData.data.PRODUCT_NAME}								
							</td>
							<th style="border-left: none;" class="contentBlock">시료수량 (EA)</th>
							<td>
								${chemicalTestData.data.PRODUCT_COUNT}
							</td>
							<th style="border-left: none;" class="contentBlock">보관방법</th>
							<!-- 
							<td style="border-top: #ffffff; display: flex; flex-direction: column; gap: 4px" class="search_box">
								<c:set var="preservation" value="${chemicalTestData.data.PRESERVATION}" />
								
								<input type="radio" id="preservation1" name="preservation" value="실온" 
									<c:if test="${preservation eq '실온'}">checked</c:if> disabled />
								<label for="preservation1"><span></span>실온</label>
							
								<input type="radio" id="preservation2" name="preservation" value="냉장" 
									<c:if test="${preservation eq '냉장'}">checked</c:if> disabled />
								<label for="preservation2"><span></span>냉장</label>
							
								<input type="radio" id="preservation3" name="preservation" value="냉동" 
									<c:if test="${preservation eq '냉동'}">checked</c:if> disabled />
								<label for="preservation3"><span></span>냉동</label>
							</td>
							 -->
							<c:set var="preservation" value="${chemicalTestData.data.PRESERVATION}" />
							<c:set var="preservations" value="${fn:split(preservation, ',')}" />
							<td style="border-top: #ffffff; display: flex; flex-direction: column; gap: 4px" class="search_box">
							
								<input type="checkbox" id="preservation1" name="preservation_view" value="실온"
									<c:if test="${fn:contains(preservation, '실온')}">checked</c:if> disabled />
								<label for="preservation1"><span></span>실온</label>
							
								<input type="checkbox" id="preservation2" name="preservation_view" value="냉장"
									<c:if test="${fn:contains(preservation, '냉장')}">checked</c:if> disabled />
								<label for="preservation2"><span></span>냉장</label>
							
								<input type="checkbox" id="preservation3" name="preservation_view" value="냉동"
									<c:if test="${fn:contains(preservation, '냉동')}">checked</c:if> disabled />
								<label for="preservation3"><span></span>냉동</label>
							
							</td>
							
						</tr>		
					</tbody>
				</table>
			</div>
			<br>
			<c:set var="itemList" value="${itemList}" />
			<c:forEach var="item" items="${itemList}">
				<c:if test="${item.TYPE_CODE eq 'PH'}">
					<c:set var="itemContent_PH" value="${item.ITEM_CONTENT}" />
				</c:if>
				<c:if test="${item.TYPE_CODE eq 'BRI'}">
					<c:set var="itemContent_BRI" value="${item.ITEM_CONTENT}" />
				</c:if>
				<c:if test="${item.TYPE_CODE eq 'SAL'}">
					<c:set var="itemContent_SAL" value="${item.ITEM_CONTENT}" />
				</c:if>
				<c:if test="${item.TYPE_CODE eq 'VIS'}">
					<c:set var="itemContent_VIS" value="${item.ITEM_CONTENT}" />
				</c:if>
			</c:forEach>
			<div class="main_tbl">
				<table class="insert_proc01">
					<tbody>
						<tr style="height:60px;">
							<th style="border-left: none;" class="contentBlock">검사요청(항목에 체크)</th>
							<td>
								<div class="search_box" style="text-align:center;">
									<input type="checkbox" id="check_ph" name="testItems" value="PH" disabled 
										<c:if test="${not empty itemContent_PH}">checked</c:if> />
									<label for="check_ph"><span></span>pH</label>
								</div>
							</td>
							<td>
								<div class="search_box" style="text-align:center;">
									<input type="checkbox" id="check_bri" name="testItems" value="BRI" disabled 
										<c:if test="${not empty itemContent_BRI}">checked</c:if> />
									<label for="check_bri"><span></span>Brix</label>
								</div>
							</td>
							<td>
								<div class="search_box" style="text-align:center;">
									<input type="checkbox" id="check_sal" name="testItems" value="SAL" disabled 
										<c:if test="${not empty itemContent_SAL}">checked</c:if> />
									<label for="check_sal"><span></span>염도</label>
								</div>
							</td>
							<td>
								<div class="search_box" style="text-align:center;">
									<input type="checkbox" id="check_vis" name="testItems" value="VIS" disabled 
										<c:if test="${not empty itemContent_VIS}">checked</c:if> />
									<label for="check_vis"><span></span>점도</label>
								</div>
							</td>
						</tr>
			
						<tr style="height:60px;">
							<th style="border-left: none;" class="contentBlock">범위<br>(시료의 대략적인 범위 기재)</th>
							<td style="text-align:center;">
								${itemContent_PH}
							</td>
							<td style="text-align:center;">
								${itemContent_BRI}
							</td>
							<td style="text-align:center;">
								${itemContent_SAL}
							</td>
							<td style="text-align:center;">
								${itemContent_VIS}
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<div class="title2"  style="width: 100%; margin-top:10px;"><span class="txt">이화학 검사 진행 기준</span></div>
			<!-- 
			<div class="main_tbl">
				<div>
					<table class="insert_proc01" style="border-bottom: 2px solid #4b5165;">
						<tr>
							<td>
								<div style="white-space: pre-wrap; max-height: 100%; overflow-y: auto;">
									${chemicalTestData.data.STANDARD_CONTENT}
								</div>
							</td>
						</tr>
					</table>
				</div>
			</div>
			 -->
			 <c:set var="standardList" value="${standardList}" />
			 <div class="main_tbl">
				<span class="txt" style="margin-left:10px;">1. 검사 요청 방법</span>
				<table id="standard1_Table" class="tbl01" style="border-top: 2px solid #4b5165;">
					<colgroup>
						<col  />							
					</colgroup>
					<tbody id="standard1_tbody" name="standard1_tbody">
						<c:forEach items="${standardList}" var="standardData" varStatus="status">
							<c:if test="${standardData.TYPE_CODE == 'MET'}">
							<tr id="standard1_tr_${status.index}">
								<td>
									<div class="ellipsis_txt tgnl" style="padding-left:15px;">
										${standardData.STANDARD_CONTENT}
									</div>
								</td>
							</tr>
							</c:if>
						</c:forEach>	
					</tbody>
				</table>
			</div>
			<br>
			<div class="main_tbl">	
				<span class="txt" style="margin-left:10px;">2. 검사 진행 일정</span>
				<table class="tbl05" style="border-top: 2px solid #4b5165;">
					<colgroup>
						<col  />							
					</colgroup>
					<tbody id="standard2_tbody" name="standard2_tbody" >
						<c:forEach items="${standardList}" var="standardData" varStatus="status">
							<c:if test="${standardData.TYPE_CODE == 'SCH'}">
								<tr id="standard2_tr_${status.index}">
									<td>
										<div class="ellipsis_txt tgnl" style="padding-left:15px;">
											${standardData.STANDARD_CONTENT}
										</div>
									</td>
								</tr>
							</c:if>
						</c:forEach>
					</tbody>
				</table>
			</div>
			
			
			<div class="title2"  style="width: 80%; margin-top:10px;"><span class="txt">기타</span></div>
			<div class="title2" style="width: 20%; display: inline-block;">
				
			 </div>
			<div class="main_tbl">
				<table class="insert_proc01">
					<colgroup>
						<col width="50%" />
						<col width="50%" />
					</colgroup>
					<tbody>
						<tr style="height:60px;">
							<th style="border-left: none;" class="contentBlock">요청 사항</th>
							<th style="border-left: none;" class="contentBlock">시료 사진</th>
						</tr>
						<tr style="height:315px;">
							<!-- 왼쪽: 컨텐츠 영역 -->
							<td style="padding: 10px; overflow-y: auto; max-height: 315px;">
								<div style="white-space: pre-wrap; max-height: 100%; overflow-y: auto;">
									${chemicalTestData.data.REQUEST_CONTENT}
								</div>
							</td>
							<!-- 오른쪽: 이미지 영역 -->
							<td style="height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center;">
								<p>
									<img id="preview" src="/images${chemicalTestData.data.FILE_PATH}/${chemicalTestData.data.FILE_NAME}"
										style="border:1px solid #e1e1e1; border-radius:5px; min-height:300px; max-height:300px; object-fit: contain; min-width:440px; max-width: 440px;">
								</p>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<div class="title2 mt20"  style="width:90%;"><span class="txt">첨부파일</span></div>
			<div class="con_file" style="">
				<ul>
					<li class="point_img">
						<dt>첨부파일</dt><dd>
							<ul>
								<c:forEach items="${chemicalTestData.fileList}" var="fileList" varStatus="status">
									<li>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
								</c:forEach>
							</ul>
						</dd>
					</li>
				</ul>
			</div>
							
			<div class="main_tbl">
				<div class="btn_box_con5">
					
				</div>
				<div class="btn_box_con4">
					<c:if test="${chemicalTestData.data.STATUS == 'COND_APPR'}">
						<button class="btn_admin_sky" onclick="fn_update('${chemicalTestData.data.CHEMICAL_IDX}')">수정</button>
					</c:if>
					<button class="btn_admin_gray" onClick="fn_goList();" style="width: 120px;">목록</button>
				</div>
				<hr class="con_mode" />
			</div>
		</div>
	</section>
</div>

<table id="tmpTable" class="tbl05" style="display:none">
	<tbody id="tmpChangeTbody" name="tmpChangeTbody">
		<tr id="tmpChangeRow_1" class="temp_color">
			<td>
				<input type="checkbox" id="change_1"><label for="change_1"><span></span></label>
			</td>
			<td>
				<input type="text" name="itemDiv" style="width: 99%" class="req code_tbl"/>							
			</td>
			<td>
				<textarea style="width:95%; height:50px" placeholder="기존정보를 입력하세요." name="itemCurrent" id="itemCurrent" class="req code_tbl"></textarea>
			</td>
			<td>
				<textarea style="width:95%; height:50px" placeholder="변경정보를 입력하세요." name="itemChange" id="itemChange" class="req code_tbl"></textarea>
			</td>
			<td>
				<input type="text" name="itemNote" style="width: 99%" class="req code_tbl"/>
			</td>
		</tr>
	</tbody>
</table>

<!-- 첨부파일 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_attatch">
	<div class="modal" style="margin-left: -355px; width: 710px; height: 480px; margin-top: -250px">
		<h5 style="position: relative">
			<span class="title">첨부파일 추가</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialogWithClean('dialog_attatch')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li class="pt10 mb5">
					<dt style="width: 20%">파일 선택</dt>
					<dd style="width: 80%" class="ppp">
						<div style="float: left; display: inline-block;">
							<span class="file_load" id="fileSpan">
								<input id="attatch_common_text" class="form-control form_point_color01" type="text" placeholder="파일을 선택해주세요." style="width:308px; float:left; cursor: pointer; color: black;" onclick="callAddFileEvent()" readonly="readonly">
								<input id="attatch_common" type="file" style="display:none;" onchange="setFileName(this)">
							</span>
							<button class="btn_small02 ml5" onclick="addFile(this, '00')">파일등록</button>
						</div>
						<div style="float: left; display: inline-block; margin-top: 5px">
							
						</div>
					</dd>
				</li>
				<li class=" mb5">
					<dt style="width: 20%">파일리스트</dt>
					<dd style="width: 80%;">
						<div class="file_box_pop" style="width:95%">
							<ul name="popFileList"></ul>
						</div>
					</dd>
				</li>
			</ul>
		</div>
		<div class="btn_box_con">
			<button class="btn_admin_red" onclick="uploadFiles();">파일 등록</button>
			<button class="btn_admin_gray" onClick="closeDialogWithClean('dialog_attatch')">등록 취소</button>
		</div>
	</div>
</div>
<!-- 파일 생성레이어 close-->

<!-- 결재 상신 레이어  start-->
<div class="white_content" id="approval_dialog">
	<input type="hidden" id="docType" value="CHEMICAL"/>
 	<input type="hidden" id="deptName" />
	<input type="hidden" id="teamName" />
	<input type="hidden" id="userId" />
	<input type="hidden" id="userName"/>
 	<select style="display:none" id=apprLine name="apprLine" multiple>
 	</select>
 	<select style="display:none" id=refLine name="refLine" multiple>
 	</select>
	<div class="modal" style="	margin-left:-500px;width:1000px;height: 550px;margin-top:-300px">
		<h5 style="position:relative">
			<span class="title">이화학 검사 의뢰서 결재 상신</span>
			<div  class="top_btn_box">
				<ul><li><button class="btn_madal_close" onClick="apprClass.apprCancel(); return false;"></button></li></ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li>
					<dt style="width:20%">결재요청의견</dt>
					<dd style="width:80%;">
						<div class="insert_comment">
							<table style=" width:756px">
								<tr>
									<td>
										<textarea style="width:100%; height:50px" placeholder="의견을 입력하세요" name="apprComment" id="apprComment"></textarea>
									</td>
									<td width="98px"></td>
								</tr>
							</table>
						</div>
					</dd>
				</li>
				<li class="pt5">
					<dt style="width:20%">결재자 입력</dt>
					<dd style="width:80%;" class="ppp">
						<input type="text" placeholder="결재자명 2자이상 입력후 선택" style="width:198px; float:left;" class="req" id="keyword" name="keyword">
						<button class="btn_small01 ml5" onclick="apprClass.approvalAddLine(this); return false;" name="appr_add_btn" id="appr_add_btn">결재자 추가</button>
						<button class="btn_small02  ml5" onclick="apprClass.approvalAddLine(this); return false;" name="ref_add_btn" id="ref_add_btn">참조</button>
						<div class="selectbox ml5" style="width:180px;">
							<label for="apprLineSelect" id="apprLineSelect_label">---- 결재라인 불러오기 ----</label>
							<select id="apprLineSelect" name="apprLineSelect" onchange="apprClass.changeApprLine(this);">
								<option value="">---- 결재라인 불러오기 ----</option>
							</select>
						</div>
						<button class="btn_small02  ml5" onclick="apprClass.deleteApprovalLine(this); return false;">선택 결재라인 삭제</button>
					</dd>
				</li>
				<li  class="mt5">
					<dt style="width:20%; background-image:none;" ></dt>
					<dd style="width:80%;">
						<div class="file_box_pop2" style="height:190px;">
							<ul id="apprLineList">
							</ul>
						</div>
						<div class="file_box_pop3" style="height:190px;">
							<ul id="refLineList">
							</ul>
						</div>
						<!-- 현재 추가된 결재선 저장 버튼을 누르면 안보이게 처리 start -->
						<div class="app_line_edit">
							저장 결재선라인 입력 :  <input type="text" name="apprLineName" id="apprLineName" class="req" style="width:280px;"/> 
							<button class="btn_doc" onclick="apprClass.approvalLineSave(this);  return false;"><img src="../resources/images/icon_doc11.png"> 저장</button> 
							<button class="btn_doc" onclick="apprClass.apprLineSaveCancel(this); return false;"><img src="../resources/images/icon_doc04.png">취소</button>
						</div>
						<!-- 현재 추가된 결재선 저장 버튼 눌렀을때 보이게 처리 close -->
					</dd>
				</li>
			</ul>
		</div>
		<div class="btn_box_con4" style="padding:15px 0 20px 0">
			<button class="btn_admin_red" onclick="fn_apprSubmit(); return false;">결재등록</button> 
			<button class="btn_admin_gray" onclick="apprClass.apprCancel(); return false;">결재삭제</button>
		</div>
	</div>
</div>
<!-- 결재 상신 레이어  close-->