<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>표시사항기재양식 생성</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 100px; min-height:100px;}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">

<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	$(document).ready(function(){
		fn.autoComplete($("#keyword"));
	});
	
	function fn_update(idx) {
		location.href = '/package/update?idx='+idx;
	}
	
	function fn_versionUp(idx) {
		location.href = '/package/versionUp?idx='+idx;
	}
	
	function fn_goList() {
		location.href = '/package/list';
	}
	
	function downloadFile(idx){
		location.href = '/common/fileDownload?idx='+idx;
	}
	
	
	function nvl2(str, defaultStr){
	    if(typeof str == "undefined" || str == "undefined" || str == null || str == "" || str == "null")
	        str = defaultStr ;
	     
	    return str ;
	}
	
	function fn_apprSubmit(){
		if( $("#apprLine option").length == 0 ) {
			alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 결재상신 해 주세요.");
			return;
		} else {
			$('#lab_loading').show();
			var formData = new FormData();
			formData.append("docIdx",'${packageInfoData.data.PACKAGE_IDX}');
			formData.append("apprComment", $("#apprComment").val());
			formData.append("apprLine", $("#apprLine").selectedValues());
			formData.append("refLine", $("#refLine").selectedValues());
			formData.append("title", '${packageInfoData.data.PRODUCT_NAME}'+' 표시사항 기재양식 생성.');
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
						alert("결재상신 되었습니다.");
						$('#lab_loading').hide();
						fn_goList();
					} else {
						alert("결재상신 오류가 발생하였습니다."+data.MESSAGE);
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
		표시사항기재양식&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;표시사항기재양식서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Package Info Document</span><span class="title">표시사항기재양식</span>
			<div class="top_btn_box">
				<ul>
					<li>
					<c:if test="${userUtil:getUserId(pageContext.request) == packageInfoData.data.DOC_OWNER}">
						<c:if test="${packageInfoData.data.STATUS == 'TMP' || packageInfoData.data.STATUS == 'COND_APPR'}">
							<button class="btn_circle_modifiy" onclick="fn_update('${packageInfoData.data.PACKAGE_IDX}')">&nbsp;</button>
						</c:if>
						<c:if test="${packageInfoData.data.STATUS == 'COMP' and packageInfoData.data.IS_LAST == 'Y'}">
							<button class="btn_circle_version" onclick="fn_versionUp('${packageInfoData.data.PACKAGE_IDX}')">&nbsp;</button>
						</c:if>
					</c:if>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title2"  style="width: 80%;"><span class="txt">기본정보</span></div>
			<div class="title2" style="width: 20%; display: inline-block;">
				
			</div>
			<div class="main_tbl">
				<table class="insert_proc01">
					<colgroup>
						<col width="15%" />
						<col width="20%" />
						<col width="35%" />
						<col width="30%" />
					</colgroup>
					<tbody>
						<tr>
							<th style="border-left: none;" rowspan="2">해당면</th>
							<td colspan="3">
								포장지 인쇄 표기사항
							</td>
						</tr>
						<tr>
							<td>
								표기사항
							</td>
							<td>
								세부사항
							</td>
							<td>
								&nbsp;
							</td>
						</tr>
						<tr>
							<th style="border-left: none;" rowspan="5">정면(주표시면)</th>
							<td>
								제품명
							</td>
							<td>
								<input type="hidden" name="idx" id="idx" value="${packageInfoData.data.PACKAGE_IDX}"/>
								<input type="hidden" name="docNo" id="docNo" value="${packageInfoData.data.DOC_NO}"/>
								<input type="hidden" name="versionNo" id="versionNo" value="${packageInfoData.data.VERSION_NO}"/>
								<input type="hidden" name="currentStatus" id="currentStatus" value="${packageInfoData.data.STATUS}"/>
								<input type="hidden" name="productCode" id="productCode" value="${packageInfoData.data.PRODUCT_CODE}"/>
								${packageInfoData.data.PRODUCT_NAME}								
							</td>
							<td>
								주표시면(14P이상)
							</td>
						</tr>
						<tr>
							<td>
								&nbsp;
							</td>
							<td>
								${packageInfoData.data.ETC_INFO}
							</td>
							<td rowspan="3">
								주표시면 주원료 함량 표시시
								원재료와 함량 표기 기재 요망
							</td>
						</tr>
						<tr>
							<td>
								중량
							</td>
							<td>
								${packageInfoData.data.WEIGHT}
							</td>
						</tr>
						<tr>
							<td>
								보관방법
							</td>
							<td>
								<c:choose>
									<c:when test="${packageInfoData.data.KEEP_CONDITION == '999'}">
										${packageInfoData.data.KEEP_CONDITION_TXT}
									</c:when>
									<c:otherwise>
										${packageInfoData.data.KEEP_CONDITION_NAME}
									</c:otherwise>
								</c:choose>								
							</td>
						</tr>
						<tr>
							<td>
								마크
							</td>
							<td>
								HACCP
							</td>
							<td>
								&nbsp;
							</td>
						</tr>
						<tr>
							<th style="border-left: none;" rowspan="16">후면 또는 측면<br>(정보표시면)</th>
							<td colspan="3" align="center">
								후면 10p 이상(원산지는 12p 이상)<br>
								장평 90%이상, 자간 -5이상 표시 의문<br>
								(단, 정보표시면 면적이 100cm² 미만시 장평 50%이상, 자간 -5%이상 표시 가능)<br>
							</td>
						</tr>
						<tr>
							<td>제품명</td>
							<td colspan="2">
								${packageInfoData.data.PRODUCT_NAME_BACK}								
							</td>
						</tr>
						<tr>
							<td>식품의 유형</td>
							<td colspan="2">
								<c:choose>
									<c:when test="${packageInfoData.data.FOOD_TYPE == '999'}">
										${packageInfoData.data.FOOD_TYPE_TXT}
									</c:when>
									<c:otherwise>
										${packageInfoData.data.FOOD_TYPE_NAME}
									</c:otherwise>
								</c:choose>
							</td>
						</tr>
						<tr>
							<td>원재료명 및 함량</td>
							<td colspan="2">
								<p style="white-space: pre-line; text-align:left;">${packageInfoData.data.CONTAIN_QUANTITY}</p>							
							</td>
						</tr>
						<tr>
							<td>알러지 유발물질</td>
							<td colspan="2">
								${packageInfoData.data.ALLERGY_OBJECT}								
							</td>
						</tr>
						<tr>
							<td>품목보고번호</td>
							<td colspan="2">
								${packageInfoData.data.MANUFACTURING_NO}
							</td>
						</tr>
						<tr>
							<td>소비기한</td>
							<td colspan="2">
								${packageInfoData.data.EXPIRED_DATE}
							</td>
						</tr>
						<tr>
							<td>포장재질</td>
							<td colspan="2">
								${packageInfoData.data.PACKAGE_OBJECT}
							</td>
						</tr>
						<tr>
							<td>제조원</td>
							<td colspan="2">
								${packageInfoData.data.MAKER}
							</td>
						</tr>
						<tr>
							<td>유통전문판매원</td>
							<td colspan="2">
								${packageInfoData.data.DISTRIBUTION}
							</td>
						</tr>
						<tr>
							<td>반품 및 교환장소</td>
							<td colspan="2">
								${packageInfoData.data.RETURNED}
							</td>
						</tr>
						<tr>
							<td>소비자상담실</td>
							<td colspan="2">
								${packageInfoData.data.CUSTOMER_COUNSEL}
							</td>
						</tr>
						<tr>
							<td>기타사항</td>
							<td colspan="2">
								<c:forEach items="${addInfoList}" var="infoList" varStatus="status">
									${infoList.INFO_TEXT}<br>								
								</c:forEach>
							</td>
						</tr>
						<tr>
							<td>분리배출 표시</td>
							<td colspan="2">
								<c:choose>
									<c:when test="${packageInfoData.data.SEPARATE_DISCHARGE == '999'}">
										${packageInfoData.data.SEPARATE_DISCHARGE_TXT}
									</c:when>
									<c:otherwise>
										${packageInfoData.data.SEPARATE_DISCHARGE_NAME}
									</c:otherwise>
								</c:choose>
							</td>
						</tr>
						<tr>
							<td>주의사항</td>
							<td colspan="2">
								<p style="white-space: pre-line; text-align:left;">${packageInfoData.data.SUGGESTIONS}</p>
							</td>
						</tr>
						<tr>
							<td>조리방법</td>
							<td colspan="2">
								<p style="white-space: pre-line; text-align:left;">${packageInfoData.data.COOK_METHOD}</p>
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
								<c:forEach items="${packageInfoData.fileList}" var="fileList" varStatus="status">
									<li>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
								</c:forEach>
							</ul>
						</dd>
					</li>
				</ul>
			</div>
							
			<div class="main_tbl">
				<div class="btn_box_con5">
					<button class="btn_admin_gray" onClick="fn_goList();" style="width: 120px;">목록</button>
				</div>
				<div class="btn_box_con4">
				<c:if test="${userUtil:getUserId(pageContext.request) == packageInfoData.data.DOC_OWNER}">
				<c:if test="${packageInfoData.data.STATUS == 'TMP' || packageInfoData.data.STATUS == 'COND_APPR'}">
					<button class="btn_admin_sky" onclick="fn_update('${packageInfoData.data.PACKAGE_IDX}')">수정</button>
				</c:if>	
				</c:if>
					<button class="btn_admin_gray" onclick="fn_goList()">취소</button>
				</div>
				<hr class="con_mode" />
			</div>
		</div>			
	</section>
</div>


<!-- SAP 코드 검색 레이어 start-->
<!-- SAP 코드 검색 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_erpMaterial">
	<input id="erpTargetID" type="hidden">
	<input id="erpItemType" type="hidden">
	<div class="modal positionCenter" style="width: 900px; height: 600px; margin-left: -55px; margin-top: -50px ">
		<h5 style="position: relative">
			<span class="title">제품코드 검색</span>
			<div class="top_btn_box">
				<ul>
					<li><button class="btn_madal_close" onClick="fn_closeErpMatRayer()"></button></li>
				</ul>
			</div>
		</h5>

		<div id="erpMatListDiv" class="code_box">
			<input id="searchErpMatValue" type="text" class="code_input" onkeyup="bindDialogEnter(event)" style="width: 300px;" placeholder="일부단어로 검색가능">
			<img src="/resources/images/icon_code_search.png" onclick="fn_searchErpMaterial()"/>
			<div class="code_box2">
				(<strong> <span id="erpMatCount">0</span> </strong>)건
			</div>
			<div class="main_tbl">
				<table class="tbl07">
					<colgroup>
						<col width="40px">
						<col width="10%">
						<col width="20%">
						<col width="8%">
						<col width="8%">
						<col width="8%">
						<col width="auto">
						<col width="10%">
						<col width="10%">
					</colgroup>
					<thead>
						<tr>
							<th></th>
							<th>ERP코드</th>
							<th>상품명</th>
							<th>보관기준</th>
							<th>사이즈</th>
							<th>중량</th>
							<th>규격</th>
							<th>원산지</th>
							<th>유통기한</th>
						<tr>
					</thead>
					<tbody id="erpMatLayerBody">
						<input type="hidden" id="erpMatLayerPage" value="0"/>
						<Tr>
							<td colspan="9">제품코드 혹은 제품명을 검색해주세요</td>
						</Tr>
					</tbody>
				</table>
				<!-- 뒤에 추가 리스트가 있을때는 클래스명 02로 숫자변경 -->
				<div id="erpMatNextPrevDiv" class="page_navi  mt10">
					<button class="btn_code_left01" onclick="fn_searchErpMaterial('prevPage')"></button>
					<button class="btn_code_right02" onclick="fn_searchErpMaterial('nextPage')"></button>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- 코드검색 추가레이어 close-->
<!-- SAP 코드 검색 레이어 close-->

<!-- 첨부파일 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_attatch">
	<div class="modal" style="margin-left: -355px; width: 710px; height: 550px; margin-top: -250px">
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
								<input id="attatch_common_text" class="form-control form_point_color01" type="text" placeholder="파일을 선택해주세요." style="width:308px;float:left; cursor: pointer; color: black;" onclick="callAddFileEvent()" readonly="readonly">
								<!-- <label class="btn-default" for="attatch_common" style="float:left; margin-left: 5px; width: 57px">파일 선택</label> -->
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

<!-- 신규 자재코드 검색 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_material">
	<input id="targetID" type="hidden">
	<input id="itemType" type="hidden">
	<input id="searchType" type="hidden">
	<div class="modal positionCenter" style="width: 900px; height: 600px">
		<h5 style="position: relative">
			<span class="title">원료코드 검색</span>
			<div class="top_btn_box">
				<ul>
					<li><button class="btn_madal_close" onClick="fn_closeMatRayer()"></button></li>
				</ul>
			</div>
		</h5>

		<div id="matListDiv" class="code_box">
			<input id="searchMatValue" type="text" class="code_input" onkeyup="bindDialogEnter(event)" style="width: 300px;" placeholder="일부단어로 검색가능">
			<img src="/resources/images/icon_code_search.png" onclick="searchMaterial()"/>
			<div class="code_box2">
				(<strong> <span id="matCount">0</span> </strong>)건
			</div>
			<div class="main_tbl">
				<table class="tbl07">
					<colgroup>
						<col width="40px">
						<col width="10%">
						<col width="10%">
						<col width="15%">
						<col width="8%">
						<col width="8%">
						<col width="8%">
						<col width="auto">
						<col width="10%">
						<col width="10%">
					</colgroup>
					<thead>
						<tr>
							<th></th>
							<th>원료코드</th>
							<th>ERP코드</th>
							<th>상품명</th>
							<th>보관기준</th>
							<th>사이즈</th>
							<th>중량</th>
							<th>규격</th>
							<th>원산지</th>
							<th>유통기한</th>
						<tr>
					</thead>
					<tbody id="matLayerBody">
						<input type="hidden" id="matLayerPage" value="0"/>
						<Tr>
							<td colspan="10">원료코드 혹은 원료코드명을 검색해주세요</td>
						</Tr>
					</tbody>
				</table>
				<!-- 뒤에 추가 리스트가 있을때는 클래스명 02로 숫자변경 -->
				<div id="matNextPrevDiv" class="page_navi  mt10">
					<button class="btn_code_left01" onclick="searchMaterial('prevPage','')"></button>
					<button class="btn_code_right02" onclick="searchMaterial('nextPage','')"></button>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- 코드검색 추가레이어 close-->

<!-- 결재 상신 레이어  start-->
<div class="white_content" id="approval_dialog">
	<input type="hidden" id="docType" value="PACKAGE"/>
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
			<span class="title">표시사항기재양식 결재 상신</span>
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
