<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>기타 보고서 생성</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 400px; min-height:400px;}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="../resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	$(document).ready(function(){
		CreateEditor("contents");
		
		fn.autoComplete($("#keyword"));
		
		<c:if test="${fn:length(apprItemList) > 0}">
	    fn_loadAppr();
		</c:if>
	});
	
	function CreateEditor(editorId) {
	    ClassicEditor
	        .create(document.getElementById(editorId), {
				language: 'ko',
				removePlugins: ['Link', 'List', 'Indent', 'Outdent', 'Alignment',
	                'Code', 'Image', 'ImageUpload', 'MediaEmbed', 'Table'
	            ]
	        }).then( editor => {
	        	window.editor = editor;
	    	}).catch( error => {
	    		console.error( error );
	    	});
	}
	
	/* 파일첨부 관련 함수 START */
	var attatchFileArr = [];
	var attatchFileTypeArr = [];
	var attatchTempFileArr = [];
	var attatchTempFileTypeArr = [];
	var deletedFileIdArr = [];
	var deletedFileArr = [];
	var deletedFilePathArr = [];
	function callAddFileEvent(){
		//$('#attatch_common').click();
		$('#file3').click();
	}
	function setFileName(element){
		if(element.files.length > 0)
			$(element).parent().children('input[type=text]').val(element.files[0].name);
		else 
			$(element).parent().children('input[type=text]').val('');
	}
	function addFile(element, fileType){
		var randomId = Math.random().toString(36).substr(2, 9);
		
		if($(element).val() == null || $(element).val() == ''){
			return alert('파일을 선택해주세요');
		}
		
		fileElement = document.getElementById($(element).prop("id"));
		
		var file = fileElement.files;
		var fileName = file[0].name
		var fileTypeText = $(element).text();

		
		var isDuple = false;
		attatchTempFileArr.forEach(function(file){
			if(file.name == fileName)
				isDuple = true;
		})
		
		attatchFileArr.forEach(function(file){
			if(file.name == fileName)
				isDuple = true;
		})
		
		if(isDuple){
			if(!confirm('같은 이름의 파일이 존재합니다. 계속 진행하시겠습니까?')){
				return;
			};
		}
		
		if( !checkFileName(fileName) ) {			
			return;
		}
		
		attatchFileArr.push(file[0]);
		attatchFileArr[attatchFileArr.length-1].tempId = randomId;
		attatchFileTypeArr.push({fileType: fileType, fileTypeText: fileTypeText, tempId: randomId});
		
		$(element).val("");
		
		var childTag = '<li><a href="#none" onclick="removeFile(this, \''+attatchFileTypeArr[attatchFileTypeArr.length-1].tempId+'\')"><img src="/resources/images/icon_del_file.png"></a>'+attatchFileArr[attatchFileTypeArr.length-1].name+'</li>';
		$("#attatch_file").append(childTag);
	}
	
	function addDropFile(file, fileType){
		var randomId = Math.random().toString(36).substr(2, 9);
		
		var fileName = file.name;
		var fileTypeText = file.text();
		var isDuple = false;
		
		attatchFileArr.forEach(function(file){
			if(file.name == fileName)
				isDuple = true;
		})
		
		attatchTempFileArr.forEach(function(file){
			if(file.name == fileName)
				isDuple = true;
		})
		
		attatchFileArr.forEach(function(file){
			if(file.name == fileName)
				isDuple = true;
		})
		
		if(isDuple){
			if(!confirm('같은 이름의 파일이 존재합니다. 계속 진행하시겠습니까?')){
				return;
			};
		}
		
		if( !checkFileName(fileName) ) {			
			return;
		}
		
		attatchFileArr.push(file);
		attatchFileArr[attatchFileArr.length-1].tempId = randomId;
		attatchFileTypeArr.push({fileType: fileType, fileTypeText: fileTypeText, tempId: randomId});
		
		var childTag = '<li><a href="#none" onclick="removeFile(this, \''+attatchFileTypeArr[attatchFileTypeArr.length-1].tempId+'\')"><img src="/resources/images/icon_del_file.png"></a>'+attatchFileArr[attatchFileTypeArr.length-1].name+'</li>';
		$("#attatch_file").append(childTag);
	}
	
	function removeTempFile(element, tempId){
		$(element).parent().remove();
		$("#tempFileList").removeOption(tempId);
	}
	
	function removeFile(element, tempId){
		$(element).parent().remove();
		attatchFileArr = attatchFileArr.filter(function(file){
			if(file.tempId != tempId) {
				return file;
			}
		})
		attatchFileTypeArr = attatchFileTypeArr.filter(function(typeObj){
			if(typeObj.tempId != tempId) 
				return typeObj;
		});
		
		if( $("#attatch_file").children().length == 0 ) {
			$("#docTypeTemp").removeOption(/./);
			$("#docTypeTxt").html("");
		}
	}
	
	function fn_removeTempFile(el, fileIdx) {
	    const $li = $(el).closest('li');

	    // li에 data-* 로 박아둔 파일명 및 경로 추출
	    const fileName = $li.data('name');
	    const filePath = $li.data('path');

	    // 배열에 저장
	    deletedFileIdArr.push(fileIdx);
	    deletedFileArr.push(fileName);
	    deletedFilePathArr.push(filePath);
	    $("#tempFileList").removeOption(fileIdx);

	    // 화면에서 삭제
	    $li.remove();
	}
	
	function allowDrop(e) {
		e.preventDefault();
		
		e.target.style.backgroundColor = "black";
		e.target.style.opacity  = "0.2";
	}

	function drag(ev) {
		ev.dataTransfer.setData("text", ev.target.id);
	}

	function drop(e) {
		e.preventDefault();
		
		var files = e.target.files || e.dataTransfer.files;
		for(var i=0; i<files.length; i++){
			addDropFile(files[i], '00')
		}
		e.target.style.backgroundColor = "#fff";
		e.target.style.opacity  = "1";
	}

	function drogEnd(e){
		e.target.style.backgroundColor = "#fff";
		e.target.style.opacity  = "1";
	}
	
	function checkFileName(str){
		var result = true;
	    //1. 확장자 체크
	    var ext =  str.split('.').pop().toLowerCase();
	    if($.inArray(ext, ['pdf','png','jpg','jpeg']) == -1) {
	    	var message = "";
	    	message += ext+'파일은 업로드 할 수 없습니다.';
	    	//message += "\n";
	    	message += "(pdf와 이미지(png,jpg,jpeg)만 가능합니다.)";
	        alert(message);
	        result = false;
	    }
	    return result;
	}
	
	function closeDialogWithClean(dialogId){
		initDialog();
		closeDialog(dialogId);
	}
	
	function initDialog(){
		// 파일첨부
		attatchTempFileArr = [];
		attatchTempFileTypeArr = [];
		$('ul[name=popFileList]').empty();
		$('#attatch_common_text').val('');
		$('#attatch_common').val('')
	}
	
	function fn_updateTmp(){
		//var containQuantity = editor1.getData();
		var contents = editor.getData();
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			$("#title").focus();
			return;
		} else {
			var formData = new FormData();
			formData.append("idx",$("#idx").val());
			formData.append("currentStatus",$("#currentStatus").val());
			formData.append("title",$("#title").val());
			formData.append("contents",contents);
			formData.append("status","TMP");
			
			for (var i = 0; i < attatchFileArr.length; i++) {
				formData.append('file', attatchFileArr[i])
			}
			
			for (var i = 0; i < attatchFileTypeArr.length; i++) {
				formData.append('fileTypeText', attatchFileTypeArr[i].fileTypeText)			
			}
			
			for (var i = 0; i < attatchFileTypeArr.length; i++) {
				formData.append('fileType', attatchFileTypeArr[i].fileType)			
			}
			
			formData.append('deletedFileIdArr', JSON.stringify(deletedFileIdArr));
			formData.append('deletedFileArr', JSON.stringify(deletedFileArr));
			formData.append('deletedFilePathArr', JSON.stringify(deletedFilePathArr));
			
			$('#lab_loading').show();
			URL = "../etcReport/updateTmpEtcAjax";
			$.ajax({
				type:"POST",
				url:URL,
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				dataType:"json",
				success:function(result) {
					if( result.RESULT == 'S' ) {
						if( $("#apprLine option").length > 0 ) {
							var apprFormData = new FormData();
							apprFormData.append("docIdx", '${etcData.data.ETC_IDX}' );
							apprFormData.append("apprIdx", '${apprHeader.APPR_IDX}' );
							apprFormData.append("apprComment", $("#apprComment").val());
							apprFormData.append("apprLine", $("#apprLine").selectedValues());
							apprFormData.append("refLine", $("#refLine").selectedValues());
							apprFormData.append("title", $("#title").val());
							apprFormData.append("docType", $("#docType").val());
							apprFormData.append("status", "N");
							var URL = "../approval/insertApprTmpAjax";
							$.ajax({
								type:"POST",
								url:URL,
								dataType:"json",
								data: apprFormData,
								processData: false,
						        contentType: false,
						        cache: false,
								success:function(data) {
									if(data.RESULT == 'S') {
										alert("임시저장 되었습니다.");
										$('#lab_loading').hide();
										fn_goList();
									} else {
										alert("결재선 등록 중 오류가 발생하였습니다."+data.MESSAGE);
										$('#lab_loading').hide();
										return;
									}
								},
								error:function(request, status, errorThrown){
									alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
									$('#lab_loading').hide();
									fn_goList();
								}			
							});
						} else {
							alert($("#title").val()+" 기타 보고서가 임시저장 되었습니다.");
							$('#lab_loading').hide();
							fn_goList();	
						}
					} else if( result.RESULT == 'F' ) {
						alert(result.MESSAGE);
						$('#lab_loading').hide();						
					} else {
						alert("오류가 발생하였습니다.\n"+result.MESSAGE);
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
	
	//입력확인
	function fn_update(){
		var contents = editor.getData();
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			$("#title").focus();
			return;
		} else if( $("#tempFileList option").length == 0 && attatchFileArr.length == 0 ) {
			alert("첨부파일을 등록해주세요.");		
			return;
		} else if( !chkNull($("#apprTxtFull").val()) ) {
			alert("결재라인을 등록해주세요.");
			return;
		} else {
			var rowCount = 0;
			var validData = true;
			
			
			
			var formData = new FormData();
			formData.append("idx",$("#idx").val());
			formData.append("currentStatus",$("#currentStatus").val());
			formData.append("title",$("#title").val());
			formData.append("contents",contents);
			formData.append("status","REG");
			
			for (var i = 0; i < attatchFileArr.length; i++) {
				formData.append('file', attatchFileArr[i])
			}
			
			for (var i = 0; i < attatchFileTypeArr.length; i++) {
				formData.append('fileTypeText', attatchFileTypeArr[i].fileTypeText)			
			}
			
			for (var i = 0; i < attatchFileTypeArr.length; i++) {
				formData.append('fileType', attatchFileTypeArr[i].fileType)			
			}
			
			formData.append('deletedFileIdArr', JSON.stringify(deletedFileIdArr));
			formData.append('deletedFileArr', JSON.stringify(deletedFileArr));
			formData.append('deletedFilePathArr', JSON.stringify(deletedFilePathArr));
			
			
			$('#lab_loading').show();
			URL = "../etcReport/updateEtcAjax";
			$.ajax({
				type:"POST",
				url:URL,
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				dataType:"json",
				success:function(result) {
					if( result.RESULT == 'S' ) {						
						<c:choose>
					      <c:when test="${etcData.data.STATUS != null && etcData.data.STATUS != 'COND_APPR' }">
						if( $("#apprLine option").length > 0 ) {
								var apprFormData = new FormData();
								apprFormData.append("docIdx", '${etcData.data.ETC_IDX}' );
								apprFormData.append("apprIdx", '${apprHeader.APPR_IDX}' );
								apprFormData.append("apprComment", $("#apprComment").val());
								apprFormData.append("apprLine", $("#apprLine").selectedValues());
								apprFormData.append("refLine", $("#refLine").selectedValues());
								apprFormData.append("title", '${etcData.data.TITLE}');
								apprFormData.append("docType", $("#docType").val());
								apprFormData.append("status", "N");
								var URL = "../approval/insertApprAjax";
								$.ajax({
									type:"POST",
									url:URL,
									dataType:"json",
									data: apprFormData,
									processData: false,
							        contentType: false,
							        cache: false,
									success:function(data) {
										if(data.RESULT == 'S') {
											alert("결재상신이 완료되었습니다.");
											$('#lab_loading').hide();
											fn_goList();
										} else {
											alert("결재선 상신 오류가 발생하였습니다."+data.MESSAGE);
											$('#lab_loading').hide();
											fn_goList();
											return;
										}
									},
									error:function(request, status, errorThrown){
										alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
										$('#lab_loading').hide();
										fn_goList();
									}			
								});
							} else {
								alert("수정되었습니다.");
								$('#lab_loading').hide();
								fn_goList();
							}
						 </c:when>
					      <c:otherwise>
							alert("결재상신이 완료되었습니다.");
							$('#lab_loading').hide();
							fn_goList();
					      </c:otherwise>
					    </c:choose>
					} else {
						alert("오류가 발생하였습니다.\n"+result.MESSAGE);
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

	function fn_goList() {
		location.href = '/etcReport/list';
	}
	
	function fn_apprSubmit(){
		if( $("#apprLine option").length == 0 ) {
			alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 결재상신 해 주세요.");
			return;
		} else {
			fn_loadAppr();
		}
		closeDialog('approval_dialog');
	}
	
	function fn_loadAppr() {
		var apprTxtFull = "";
		$("#apprLine").selectedTexts().forEach(function( item, index ){
			if( apprTxtFull != "" ) {
				apprTxtFull += " > ";
			}
			apprTxtFull += item;
		});
		$("#apprTxtFull").val(apprTxtFull);
		var refTxtFull = "";
		$("#refLine").selectedTexts().forEach(function( item, index ){
			if( refTxtFull != "" ) {
				refTxtFull += ", ";
			}
			refTxtFull += item;
		});
		$("#refTxtFull").html("&nbsp;"+refTxtFull);
	}
	
	function fn_previewDataBinding(popup) {
	    const $doc = popup.document;
	    $doc.title = document.getElementById("title").value+'_기타보고서'
	    // 기본 항목
	    $doc.getElementById("prev_title").innerText = document.getElementById("title").value;
	    
	    // 비고
	    var content = editor.getData().trim();
	    var previewContent = $doc.getElementById("prev_content");
	    var wrapper = $doc.getElementById("wrapper_prev_content");

	}

	function fn_openPreview() {
		var url = "/preview/etcReportPrevPopup";

		// 팝업 창 열기
		var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes");

		// 팝업이 완전히 열린 뒤에 데이터 전달
		popup.onload = function () {
			// 여기서 fn_openPreview() 호출해서 팝업 DOM에 값 세팅
			fn_previewDataBinding(popup);
		};
	}
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">
		기타 보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">ETC Report</span><span class="title">기타 보고서</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<button class="btn_circle_save" onclick="fn_update()">&nbsp;</button>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title2"  style="display: flex; justify-content:space-between; width: 100%;">
				<span class="txt">기본정보</span>
				<div class="pr15">
					<button class="btn_small_search" onclick="fn_openPreview()">미리보기</button>
				</div>
			</div>
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
							<td colspan="5">
								<input type="text" name="title" id="title" style="width: 90%;" class="req" value="${etcData.data.TITLE}"/>
								<input type="hidden" name="idx" id="idx" value="${etcData.data.ETC_IDX}"/>
								<input type="hidden" name="currentStatus" id="currentStatus" value="${etcData.data.STATUS}"/>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">결재라인</th>
							<td colspan="3">
								<input class="" id="apprTxtFull" name="apprTxtFull" type="text" style="width: 450px; float: left" readonly>
								<c:if test="${etcData.data.STATUS != null && etcData.data.STATUS != 'COND_APPR' }">
									<button class="btn_small_search ml5" onclick="apprClass.openApprovalDialog()" style="float: left">결재</button>
								</c:if>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">참조자</th>
							<td colspan="3">
								<div id="refTxtFull" name="refTxtFull"></div>								
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<div class="title2 mt20"  style="width:90%;"><span class="txt">비고</span></div>
			<div class="main_tbl">
				<ul>
					<li style="list-style: none;">
						<div class="text_insert" style="padding: 0px;">
							<textarea name="contents" id="contents" style="width: 666px; height: 200px; display: none;">${etcData.data.CONTENTS}</textarea>
							<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
						</div>
					</li>
				</ul>
			</div>
				
			<div class="title2 mt20"  style="width:90%;"><span class="txt">파일첨부</span></div>
			<div class="list_detail">
				<ul style="">
					<li>
						<dt style="width: 20%">첨부파일 <span class="mandatory">*</span>
							<select id="tempFileList" name="tempFileList" multiple style="display: none">
							<c:forEach items="${etcData.fileList}" var="fileList" varStatus="status">
								<option value="${fileList.FILE_IDX}" selected>${fileList.ORG_FILE_NAME}</option>
							</c:forEach>
							</select>
						</dt>
						<dd style="width: 80%;">
							<div class="add_file" id="add_file2" style="width:100%">
								<span id="upFile">
									<span class="file_load" id="fileSpan2" style="display: none;"><input type="file" name="files" id="file2" onchange="addFile(this, '00')" style="display:none"><label for="file2">첨부파일 등록 <img src="/resources/images/icon_add_file.png"></label></span>
									<span class="file_load" id="fileSpan3"><input type="file" name="files" id="file3" onchange="addFile(this, '00')" style="display:none"><label for="file3">첨부파일 등록 <img src="/resources/images/icon_add_file.png"></label></span>
								</span>
							</div>
							<div id="fileList" class="file_box_pop" style="height: 120px; width: 100%; border-top-left-radius: 0px; border-top-right-radius: 0px; border-top: 1px solid rgb(221, 221, 221); box-sizing: border-box;" ondrop="drop(event)" ondragover="allowDrop(event)" ondragend="drogEnd(event)" ondragleave="drogEnd(event)">
								<ul id="attatch_file">
									<c:forEach items="${etcData.fileList}" var="fileList" varStatus="status">
										<li data-path="${fileList.FILE_PATH}" data-name="${fileList.FILE_NAME}"><a href="#none" onclick="fn_removeTempFile(this, '${fileList.FILE_IDX}')"><img src="/resources/images/icon_del_file.png"></a>${fileList.ORG_FILE_NAME}</li>
									</c:forEach>
								</ul>	
							</div>
						</dd>
					</li>
				</ul>
			</div>
			
			<div class="main_tbl">
				<div class="btn_box_con5">
					<button class="btn_admin_gray" onClick="fn_goList();" style="width: 120px;">목록</button>
				</div>
				<div class="btn_box_con4">
					<c:if test="${userUtil:getUserId(pageContext.request) == etcData.data.DOC_OWNER}">
						<c:if test="${etcData.data.STATUS == 'TMP'}">
						<button class="btn_admin_navi" onclick="fn_updateTmp()">임시저장</button>
						</c:if>
						<button class="btn_admin_sky" onclick="fn_update()">결재</button>
					</c:if>
					<button class="btn_admin_gray" onclick="fn_goList()">취소</button>
				</div>
				<hr class="con_mode" />
			</div>
		</div>
	</section>
</div>

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
	<input type="hidden" id="docType" value="ETC"/>
 	<input type="hidden" id="deptName" />
	<input type="hidden" id="teamName" />
	<input type="hidden" id="userId" />
	<input type="hidden" id="userName"/>
 	<select style="display:none" id=apprLine name="apprLine" multiple>
 	<c:forEach items="${apprItemList}" var="apprItemList" varStatus="status">
 		<option value="${apprItemList.TARGET_USER_ID}" selected>${apprItemList.TARGET_USER_NAME}</option>	
 	</c:forEach>
 	</select>
 	<select style="display:none" id=refLine name="refLine" multiple>
 	<c:forEach items="${refList}" var="refList" varStatus="status">
 		<option value="${refList.TARGET_USER_ID}" selected>${refList.TARGET_USER_NAME}</option>	
 	</c:forEach>
 	</select>
	<div class="modal" style="	margin-left:-500px;width:1000px;height: 550px;margin-top:-300px">
		<h5 style="position:relative">
			<span class="title">상품설계변경보고서 결재 상신</span>
			<div  class="top_btn_box">
				<ul><li><button class="btn_madal_close" onClick="closeDialog('approval_dialog');"></button></li></ul>
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
										<textarea style="width:100%; height:50px" placeholder="의견을 입력하세요" name="apprComment" id="apprComment">${apprHeader.COMMENT}</textarea>
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
								<c:forEach items="${apprItemList}" var="apprItemList" varStatus="status">
								<li>
									<img src='../resources/images/icon_del_file.png' name='delImg' alt='' data-apprtype='A' onclick='apprClass.approvalRemoveLine(this);' >
										<span id="lineLength">${status.count}차 결재</span>${apprItemList.TARGET_USER_NAME}<strong>/ ${apprItemList.TARGET_USER_ID} / ${apprItemList.OBJTTX} / ${apprItemList.RESP_TXT}</strong>
								 		<input type='hidden' name='userIds' data-apprtype='A' value='${apprItemList.TARGET_USER_ID}'/>
								</li>
								</c:forEach>
							</ul>
						</div>
						<div class="file_box_pop3" style="height:190px;">
							<ul id="refLineList">
								<c:forEach items="${refList}" var="refList" varStatus="status">	
									<li>
									<img src='../resources/images/icon_del_file.png' name='delImg' alt='' data-apprtype='R' onclick='apprClass.approvalRemoveLine(this);' >
									<span>참조</span> ${refList.TARGET_USER_NAME}
									<strong>/ ${refList.TARGET_USER_ID} / ${refList.OBJTTX} / ${refList.RESP_TXT}</strong>
									<input type='hidden' name='userIds' data-apprtype='R' value='${refList.TARGET_USER_ID}'/>
									</li>
								</c:forEach>	
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