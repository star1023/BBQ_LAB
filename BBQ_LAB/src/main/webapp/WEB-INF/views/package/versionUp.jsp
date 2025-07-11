<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%> 
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
<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	var editor1;
	var editor2;
	var editor3;
	$(document).ready(function(){
		/* ClassicEditor
        .create(document.getElementById("containQuantity"), {
			language: 'ko',
        }).then( editor => {
        	editor1 = editor;
    		console.log( editor1 );
    	}).catch( error => {
    		console.error( error );
    	}); */
		
		ClassicEditor
        .create(document.getElementById("suggestions"), {
			language: 'ko',
        }).then( editor => {
        	editor2 = editor;
    		console.log( editor2 );
    	}).catch( error => {
    		console.error( error );
    	});	
		
		ClassicEditor
        .create(document.getElementById("cookMethod"), {
			language: 'ko',
        }).then( editor => {
        	editor3 = editor;
    		console.log( editor3 );
    	}).catch( error => {
    		console.error( error );
    	});	
		fn.autoComplete($("#keyword"));
	});

	/* 파일첨부 관련 함수 START */
	var attatchFileArr = [];
	var attatchFileTypeArr = [];
	var attatchTempFileArr = [];
	var attatchTempFileTypeArr = [];
	function callAddFileEvent(){
		$('#attatch_common').click();
	}
	function setFileName(element){
		if(element.files.length > 0)
			$(element).parent().children('input[type=text]').val(element.files[0].name);
		else 
			$(element).parent().children('input[type=text]').val('');
	}
	function addFile(element, fileType){
		var randomId = Math.random().toString(36).substr(2, 9);
		
		if($('#attatch_common').val() == null || $('#attatch_common').val() == ''){
			return alert('파일을 선택해주세요');
		}
		
		fileElement = document.getElementById('attatch_common');
		
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
		
		
		
		attatchTempFileArr.push(file[0]);
		attatchTempFileArr[attatchTempFileArr.length-1].tempId = randomId;
		attatchTempFileTypeArr.push({fileType: fileType, fileTypeText: fileTypeText, tempId: randomId});
		
		var childTag = '<li><a href="#none" onclick="removeFile(this, \''+randomId+'\')"><img src="/resources/images/icon_del_file.png"></a>&nbsp;'+fileName+'</li>'
		$('ul[name=popFileList]').append(childTag);
		$('#attatch_common').val('');
		$('#attatch_common').change();
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
		//console.log($("#attatch_file").children().length);
	}
	
	
	function uploadFiles(){
		if( attatchTempFileArr.length == 0 ) {
			alert("파일을 등록해주세요.");
			return;
		}
		
		attatchTempFileArr.forEach(function(tempFile, idx1){
			attatchFileArr.push(tempFile);
			attatchFileTypeArr.push(attatchTempFileTypeArr[idx1]);		
		});
		
		$("#attatch_file").html("");
		attatchFileTypeArr.forEach(function(object,idx){
			var tempId = object.tempId;
			var childTag = '<li><a href="#none" onclick="removeFile(this, \''+tempId+'\')"><img src="/resources/images/icon_del_file.png"></a>'+attatchFileArr[idx].name+'</li>'
			$("#attatch_file").append(childTag);
		});
		closeDialogWithClean('dialog_attatch');
	}
	
	function checkFileName(str){
		var result = true;
	    //1. 확장자 체크
	    var ext =  str.split('.').pop().toLowerCase();
	    if($.inArray(ext, ['pdf']) == -1) {
	    	var message = "";
	    	message += ext+'파일은 업로드 할 수 없습니다.';
	    	//message += "\n";
	    	message += "(pdf 만 가능합니다.)";
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
	
	function fn_removeTempFile(element, tempId){
		//서버의 파일을 삭제한다.
		var URL = '/file/deleteFile2Ajax';
		$.ajax({
			type:"POST",
			url:URL,
			data: {
				"fileIdx": tempId
			},
			dataType:"json",
			success:function(result) {
				if( result.RESULT == 'S' ) {
					$(element).parent().remove();
				} else {
					alert("오류가 발생하였습니다.\n"+result.MESSAGE);
				}
			},
			error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	}
	
	function CreateEditor(editorId) {
	    ClassicEditor
	        .create(document.getElementById(editorId), {
				language: 'ko',
	        }).then( editor => {
	        	window.editor = editor;
	    		console.log( editor );
	    	}).catch( error => {
	    		console.error( error );
	    	});
	}
	
	function fn_versionUpTmp(){
		//var containQuantity = editor1.getData();
		var suggestions = editor2.getData();
		var cookMethod = editor3.getData();
		if( !chkNull($("#productName").val()) ) {
			alert("제품명을 입력해 주세요.");
			$("#productName").focus();
			return;
		} else {
			$('#lab_loading').show();
			var formData = new FormData();
			formData.append("idx",$("#idx").val());
			formData.append("docNo",$("#docNo").val());
			formData.append("versionNo",$("#versionNo").val());
			formData.append("productName",$("#productName").val());
			formData.append("productCode",$("#productCode").val());
			formData.append("etcInfo",$("#etcInfo").val());
			formData.append("weight",$("#weight").val());
			formData.append("keepCondition",$("#keepCondition").selectedValues()[0]);
			formData.append("keepConditionTxt",$("#keepConditionTxt").val());
			formData.append("productNameBack",$("#productNameBack").val());
			formData.append("foodType",$("#foodType").selectedValues()[0]);
			formData.append("foodTypeTxt",$("#foodTypeTxt").val());
			//formData.append("containQuantity",containQuantity);
			formData.append("containQuantity",$("#containQuantity").val());
			formData.append("allergyObject",$("#allergyObject").val());
			formData.append("manuNo",$("#manuNo").val());
			formData.append("expiredDate",$("#expiredDate").val());
			formData.append("packageObject",$("#packageObject").val());
			formData.append("maker",$("#maker").val());
			formData.append("distribution",$("#distribution").val());
			formData.append("returned",$("#returned").val());
			formData.append("customerCounsel",$("#customerCounsel").val());
			var etcArr = new Array();
			$('tr[id^=etc_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemEtc = $('#'+ rowId + ' input[name=etc]').val();
				if( itemEtc != '' ) {
					etcArr.push(itemEtc);	
				}
			});
			formData.append("etcArr",JSON.stringify(etcArr));			
			formData.append("separateDischarge",$("#separateDischarge").selectedValues()[0]);
			formData.append("separateDischargeTxt",$("#separateDischargeTxt").val());
			formData.append("suggestions",suggestions);
			formData.append("cookMethod",cookMethod);
			formData.append("docType",$("#docType").val());
			formData.append("status", "TMP");
			formData.append("imageDeleteFlag", $("#imageDeleteFlag").val());
			formData.append("orgFileName", $("#orgFileName").val());
			formData.append("fileName", $("#fileName").val());
			formData.append("filePath", $("#filePath").val());
			
			// 이미지 파일
			var imageFile = document.getElementById('fileImageInput').files[0];
			if (imageFile) {
			  formData.append("imageFile", imageFile); // name="imageFile"
			}
			
			var URL = "../package/insertVersionUpTmpAjax";
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
						if( result.IDX > 0 ) {
							alert($("#productName").val()+" 표시사항 기재양식이 임시저장 되었습니다.");
							$('#lab_loading').hide();
							fn_goList();
						} else {
							alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
							$('#lab_loading').hide();
							fn_goList();
						}
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
	function fn_versionUp(){
		//var containQuantity = editor1.getData();
		var suggestions = editor2.getData();
		var cookMethod = editor3.getData();
		if( !chkNull($("#productName").val()) ) {
			alert("제품명을 입력해 주세요.");
			$("#productName").focus();
			return;
		} else {
			var formData = new FormData();
			formData.append("idx",$("#idx").val());
			formData.append("docNo",$("#docNo").val());
			formData.append("versionNo",$("#versionNo").val());
			formData.append("productName",$("#productName").val());
			formData.append("productCode",$("#productCode").val());
			formData.append("etcInfo",$("#etcInfo").val());
			formData.append("weight",$("#weight").val());
			formData.append("keepCondition",$("#keepCondition").selectedValues()[0]);
			formData.append("keepConditionTxt",$("#keepConditionTxt").val());
			formData.append("productNameBack",$("#productNameBack").val());
			formData.append("foodType",$("#foodType").selectedValues()[0]);
			formData.append("foodTypeTxt",$("#foodTypeTxt").val());
			//formData.append("containQuantity",containQuantity);
			formData.append("containQuantity",$("#containQuantity").val());
			formData.append("allergyObject",$("#allergyObject").val());
			formData.append("manuNo",$("#manuNo").val());
			formData.append("expiredDate",$("#expiredDate").val());
			formData.append("packageObject",$("#packageObject").val());
			formData.append("maker",$("#maker").val());
			formData.append("distribution",$("#distribution").val());
			formData.append("returned",$("#returned").val());
			formData.append("customerCounsel",$("#customerCounsel").val());
			var etcArr = new Array();
			$('tr[id^=etc_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemEtc = $('#'+ rowId + ' input[name=etc]').val();
				if( itemEtc != '' ) {
					etcArr.push(itemEtc);	
				}
			});
			formData.append("etcArr",JSON.stringify(etcArr));			
			formData.append("separateDischarge",$("#separateDischarge").selectedValues()[0]);
			formData.append("separateDischargeTxt",$("#separateDischargeTxt").val());
			formData.append("suggestions",suggestions);
			formData.append("cookMethod",cookMethod);
			formData.append("docType",$("#docType").val());
			formData.append("status", "COMP");			
			formData.append("imageDeleteFlag", $("#imageDeleteFlag").val());
			formData.append("orgFileName", $("#orgFileName").val());
			formData.append("fileName", $("#fileName").val());
			formData.append("filePath", $("#filePath").val());
			
			// 이미지 파일
			var imageFile = document.getElementById('fileImageInput').files[0];
			if (imageFile) {
			  formData.append("imageFile", imageFile); // name="imageFile"
			}
			
			$('#lab_loading').show();
			var URL = "../package/insertVersionUpAjax";
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
						alert($("#productName").val()+" 표시사항 기재양식이 정상적으로 생성되었습니다.");
						$('#lab_loading').hide();
						fn_goList();
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
		location.href = '/package/list';
	}
	
	
	function nvl2(str, defaultStr){
	    if(typeof str == "undefined" || str == "undefined" || str == null || str == "" || str == "null")
	        str = defaultStr ;
	     
	    return str ;
	}
	
	function fn_initForm() {
		$("#productName").val("");
		$("#productName").prop("readonly",false);
		$("#productSapCode").val("");
		$("#isSample").val("");
		$("#keepCondition").val("");
		$("#weight").val("");
		$("#standard").val("");
		$("#expireDate").val("");
	}
	
	function fn_apprSubmit(){
		if( $("#apprLine option").length == 0 ) {
			alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 결재상신 해 주세요.");
			return;
		} else {
			var apprTxtFull = "";
			$("#apprLine").selectedTexts().forEach(function( item, index ){
				console.log(item);
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
		closeDialog('approval_dialog');
	}
	
	function fn_addCol(type) {
		var randomId = randomId = Math.random().toString(36).substr(2, 9);
		var randomId2 = randomId = Math.random().toString(36).substr(2, 9);
		var row= '<tr>'+$('tbody[name='+type+'_tbody_temp]').children('tr').html()+'</tr>';
		
		$("#"+type+"_tbody").append(row);
		$("#"+type+"_tbody").children('tr:last').attr('id', type + '_tr_' + randomId);
		$("#"+type+"_tbody").children('tr:last').children('td').children('input[type=checkbox]').attr('id', type+'_'+randomId);
		$("#"+type+"_tbody").children('tr:last').children('td').children('label').attr('for', type+'_'+randomId);
	}
	
	function fn_delCol(type) {
		var tbody = $("#"+type+"_tbody");
		var checkboxArr = tbody.children('tr').children('td').children('input[type=checkbox]').toArray();
		
		var checkedCnt = 0;
		var checkedId;
		checkboxArr.forEach(function(v, i){
			if($(v).is(':checked')){
				checkedCnt++;
			}
		});
		
		if(checkedCnt == 0) return alert('삭제하실 항목을 선택해주세요');
		
		tbody.children('tr').toArray().forEach(function(v, i){
			var checkBoxId = $(v).children('td:first').children('input[type=checkbox]')[0].id;
			if($('#'+checkBoxId).is(':checked')) $(v).remove();
		})
	}
	
	function fn_changeSelect(element) {
		var id = $(element).attr("id");
		if( $(element).selectedValues()[0] == '999' ) {
			$("#"+id+"Txt").val("");
			$("#"+id+"Txt").show();
		} else {
			$("#"+id+"Txt").val("");
			$("#"+id+"Txt").hide();
		}
	}
	
	function fn_fileDivClick(e){
		e.stopPropagation();
		$(e.target).children('input').click();
	}
	
	function fn_changeImageFile(input, e) {
		if (input.files && input.files[0]) {
			var reader = new FileReader();
			reader.onload = function (e) {
				document.getElementById('preview').src = e.target.result;
			};
			reader.readAsDataURL(input.files[0]);
			
			// 삭제 플래그 설정
			if( $("#orgFileName").val() != "" ) {
				$("#imageDeleteFlag").val("Y");	
			}
		}
	}
	function fn_deleteImageFile(element, e) {
		const preview = document.getElementById('preview');
		const fileInput = document.getElementById('fileImageInput');

		if (preview) preview.src = "/resources/images/img_noimg3.png";
		if (fileInput) fileInput.value = "";
		
		// 삭제 플래그 설정
		if( $("#orgFileName").val() != "" ) {
			$("#imageDeleteFlag").val("Y");	
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
						<button class="btn_circle_save" onclick="fn_update()">&nbsp;</button>
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
								<input type="hidden" name="productCode" id="productCode" value="${packageInfoData.data.PRODUCT_CODE}"/>
								<input type="hidden" name="productName" id="productName" value="${packageInfoData.data.PRODUCT_NAME}"/>
								<b>${packageInfoData.data.PRODUCT_NAME}</b>
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
								<input type="text" name="etcInfo" id="etcInfo" style="width:300px;" class="req" placeholder="" value="${packageInfoData.data.ETC_INFO}"/>
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
								<input type="text" name="weight" id="weight" style="width:300px;" class="req" placeholder="" value="${packageInfoData.data.WEIGHT}"/>
							</td>
						</tr>
						<tr>
							<td>
								보관방법
							</td>
							<td>
								<div class="selectbox" style="width:150px;">  
									<label for="keepCondition" id="keepCondition_label">${packageInfoData.data.KEEP_CONDITION_NAME}</label> 
									<select name="keepCondition" id="keepCondition" onChange="fn_changeSelect(this)">
										<option value="">전체</option>
										<c:forEach items="${codeMap.keepConditonList}" var="keepConditonList" varStatus="status">
										<option value="${keepConditonList.itemCode}" ${keepConditonList.itemCode == packageInfoData.data.KEEP_CONDITION? 'selected' : ''}>${keepConditonList.itemName}</option>
										</c:forEach>
									</select>
								</div>
								<input type="text" name="keepConditionTxt" id="keepConditionTxt" style="${packageInfoData.data.KEEP_CONDITION == '999'? '' : 'display:none'}" class="req" placeholder="보관방법을 입력하세요." value="${packageInfoData.data.KEEP_CONDITION_TXT}"/>
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
								<input type="hidden" name="productNameBack" id="productNameBack" value="${packageInfoData.data.PRODUCT_NAME_BACK}"/>
								<b>${packageInfoData.data.PRODUCT_NAME_BACK}</b>
							</td>
						</tr>
						<tr>
							<td>식품의 유형</td>
							<td colspan="2">
								<div class="selectbox" style="width:200px;">  
									<label for="foodType" id="foodType_label">${packageInfoData.data.FOOD_TYPE_NAME}</label> 
									<select name="foodType" id="foodType" onChange="fn_changeSelect(this)">
										<option value="">전체</option>
										<c:forEach items="${codeMap.foodTypeList}" var="foodTypeList" varStatus="status">
										<option value="${foodTypeList.itemCode}" ${foodTypeList.itemCode == packageInfoData.data.FOOD_TYPE? 'selected' : ''}>${foodTypeList.itemName}</option>
										</c:forEach>		
									</select>
								</div>
								<input type="text" name="foodTypeTxt" id="foodTypeTxt" style="width:300px;${packageInfoData.data.FOOD_TYPE == '999'? '' : 'display:none;'}" class="req" placeholder="식품유형을 입력하세요." value="${packageInfoData.data.FOOD_TYPE_TXT}"/>
							</td>
						</tr>
						<tr style="height:285px;">
							<td>원재료명 및 함량</td>
							<td>
								<textarea name="containQuantity" id="containQuantity" style="resize: none;width:100%;height:285px">${packageInfoData.data.CONTAIN_QUANTITY}</textarea>
							</td>
							<td>
								<input type="hidden" name="imageDeleteFlag" id="imageDeleteFlag" value="N">
								<input type="hidden" name="orgFileName" id="orgFileName" value="${packageInfoData.data.CONTAIN_QUANTITY_ORG_FILE_NAME}">
								<input type="hidden" name="fileName" id="fileName" value="${packageInfoData.data.CONTAIN_QUANTITY_FILE_NAME}">
								<input type="hidden" name="filePath" id="filePath" value="${packageInfoData.data.CONTAIN_QUANTITY_FILE_PATH}">
								<c:set var="hasImage" value="${not empty packageInfoData.data.CONTAIN_QUANTITY_FILE_PATH and not empty packageInfoData.data.CONTAIN_QUANTITY_FILE_NAME}" />
								<p><img id="preview" src="<c:choose>
								                      <c:when test='${hasImage}'>
								                          /images${packageInfoData.data.CONTAIN_QUANTITY_FILE_PATH}/${packageInfoData.data.CONTAIN_QUANTITY_FILE_NAME}
								                      </c:when>
								                      <c:otherwise>
								                          /resources/images/img_noimg3.png
								                      </c:otherwise>
								                  </c:choose>" style="border:1px solid #e1e1e1; border-radius:5px; width:310px; height:250px;"></p>
								<p class="pt10">
									<div class="add_file2" style="width:100%; align:center;" onclick="fn_fileDivClick(event)">
										<input type="file" name="file" id="fileImageInput" accept="image/*" style="display:none;" onchange="fn_changeImageFile(this, event)">
										<label for="fileImageInput" style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>
									</div>	
								</p>
								<div style=" z-index:3; position:relative;right:-300px; top:-300px; width: 25px; height: 25px;">
									<img src="/resources/images/btn_table_header01_del02.png" onClick="fn_deleteImageFile(this, event)">
								</div>
							</td>
						</tr>
						<tr>
							<td>알러지 유발물질</td>
							<td colspan="2">
								<input type="text" name="allergyObject" id="allergyObject" style="width:95%;" class="req" placeholder="알러지 유발물질을 입력하세요." value="${packageInfoData.data.ALLERGY_OBJECT}"/>
							</td>
						</tr>
						<tr>
							<td>품목보고번호</td>
							<td colspan="2">
								<input type="text" name="manuNo" id="manuNo" style="width:300px;" class="req" placeholder="품목보고번호를 입력하세요." value="${packageInfoData.data.MANUFACTURING_NO}"/>
							</td>
						</tr>
						<tr>
							<td>소비기한</td>
							<td colspan="2">
								<input type="text" name="expiredDate" id="expiredDate" style="width:300px;" class="req" placeholder="소비기한을 입력하세요." value="${packageInfoData.data.EXPIRED_DATE}"/>
							</td>
						</tr>
						<tr>
							<td>포장재질</td>
							<td colspan="2">
								<input type="text" name="packageObject" id="packageObject" style="width:300px;" class="req" placeholder="포장재질을 입력하세요." value="${packageInfoData.data.PACKAGE_OBJECT}"/>
							</td>
						</tr>
						<tr>
							<td>제조원</td>
							<td colspan="2">
								<input type="text" name="maker" id="maker" style="width:95%;" class="req" placeholder="제조원을 입력하세요." value="${packageInfoData.data.MAKER}"/>
							</td>
						</tr>
						<tr>
							<td>유통전문판매원</td>
							<td colspan="2">
								<input type="text" name="distribution" id="distribution" style="width:95%;" class="req" placeholder="유통전문판매원을 입력하세요." value="${packageInfoData.data.DISTRIBUTION}"/>
							</td>
						</tr>
						<tr>
							<td>반품 및 교환장소</td>
							<td colspan="2">
								<input type="text" name="returned" id="returned" style="width:95%;" class="req" placeholder="반품 및 교환장소를 입력하세요." value="${packageInfoData.data.RETURNED}"/>
							</td>
						</tr>
						<tr>
							<td>소비자상담실</td>
							<td colspan="2">
								<input type="text" name="customerCounsel" id="customerCounsel" style="width:300px;" class="req" placeholder="소비자상담실 정보를 입력하세요." value="${packageInfoData.data.CUSTOMER_COUNSEL}"/>
							</td>
						</tr>
						<tr>
							<td>기타사항<span onClick="fn_addCol('etc')" id="span_etc">(+)</span></td>
							<td colspan="2">
								<table width="100%" border="0">
									<tbody id="etc_tbody" name="etc_tbody">
									<c:forEach items="${addInfoList}" var="infoList" varStatus="status">
										<tr id="etc_tr_${status.count}">
											<td>
												<input type="text" name="etc" id="etc" style="width: 90%;" class="req" value="${infoList.INFO_TEXT}"/>
											</td>
										</tr>
									</c:forEach>	
									<c:if test="${addInfoList == null or fn:length(addInfoList) == 0}">
										<tr id="etc_tr_1">
											<td>
												<input type="text" name="etc" id="etc" style="width: 90%;" class="req"/>
											</td>
										</tr>
									</c:if>
									</tbody>
									<tbody id="etc_tbody_temp" name="etc_tbody_temp" style="display:none">
										<tr id="etc_tmp_tr_1" style="display:none">
											<td>
												<input type="text" name="etc" id="etc" style="width: 90%;" class="req" />
											</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
						<tr>
							<td>분리배출 표시</td>
							<td colspan="2">
								<div class="selectbox" style="width:150px;">  
									<label for="separateDischarge" id="separateDischarge_label">${packageInfoData.data.SEPARATE_DISCHARGE_NAME}</label> 
									<select name="separateDischarge" id="separateDischarge" onChange="fn_changeSelect(this)">
										<option value="">전체</option>
										<c:forEach items="${codeMap.dischargeDisplayList}" var="dischargeDisplayList" varStatus="status">
										<option value="${dischargeDisplayList.itemCode}" ${dischargeDisplayList.itemCode == packageInfoData.data.SEPARATE_DISCHARGE? 'selected' : ''}>${dischargeDisplayList.itemName}</option>
										</c:forEach>		
									</select>
								</div>
								<input type="text" name="separateDischargeTxt" id="separateDischargeTxt" style="width:300px;${packageInfoData.data.SEPARATE_DISCHARGE == '999'? '' : 'display:none;'}" class="req" placeholder="분리배출 표시사항을 입력하세요." value="${packageInfoData.data.SEPARATE_DISCHARGE_TXT}"/>
							</td>
						</tr>
						<tr>
							<td>주의사항</td>
							<td colspan="2">
								<textarea name="suggestions" id="suggestions" style="width: 95%; height: 40px; ">${packageInfoData.data.SUGGESTIONS}</textarea>
							</td>
						</tr>
						<tr>
							<td>조리방법</td>
							<td colspan="2">
								<textarea name="cookMethod" id="cookMethod" style="width: 95%; height: 40px; ">${packageInfoData.data.COOK_METHOD}</textarea>
							</td>
						</tr>																	
						<tr>
							<th style="border-left: none;">결재라인</th>
							<td colspan="3">
								<input class="" id="apprTxtFull" name="apprTxtFull" type="text" style="width: 450px; float: left" readonly>
								<button class="btn_small_search ml5" onclick="apprClass.openApprovalDialog()" style="float: left">결재</button>
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
			
			<div class="title2 mt20"  style="width:90%;"><span class="txt">파일첨부</span></div>
			<div class="title2 mt20" style="width:10%; display: inline-block;">
				<button class="btn_con_search" onClick="openDialog('dialog_attatch')">
					<img src="/resources/images/icon_s_file.png" />파일첨부 
				</button>
			</div>
			<div class="con_file" style="">
				<ul>
					<li class="point_img">
						<dt>첨부파일</dt><dd>
							<ul id="temp_attatch_file">
								<c:forEach items="${packageInfoData.fileList}" var="fileList" varStatus="status">
									<li><a href="#none" onclick="fn_removeTempFile(this, '${fileList.FILE_IDX}')"><img src="/resources/images/icon_del_file.png"></a>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
								</c:forEach>
							</ul>
							<ul id="attatch_file">								
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
					<!-- 
					<button class="btn_admin_red">임시/템플릿저장</button>
					 -->
					<button class="btn_admin_navi" onclick="fn_versionUpTmp()">임시저장</button>
					<button class="btn_admin_sky" onclick="fn_versionUp()">개정</button>
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
