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
    	}).catch( error => {
    		console.error( error );
    	}); */
		
		ClassicEditor
        .create(document.getElementById("suggestions"), {
			language: 'ko',
			removePlugins: ['Link', 'List', 'Indent', 'Outdent', 'Alignment',
                'Code', 'Image', 'ImageUpload', 'MediaEmbed', 'Table'
            ]
        }).then( editor => {
        	editor2 = editor;
    	}).catch( error => {
    		console.error( error );
    	});	
		
		ClassicEditor
        .create(document.getElementById("cookMethod"), {
			language: 'ko',
			removePlugins: ['Link', 'List', 'Indent', 'Outdent', 'Alignment',
                'Code', 'Image', 'ImageUpload', 'MediaEmbed', 'Table'
            ]
        }).then( editor => {
        	editor3 = editor;
    	}).catch( error => {
    		console.error( error );
    	});	
		fn.autoComplete($("#keyword"));
		
		
		fn_loadCode("UNIT", "packageUnit");
		$("#packageUnit").selectOptions('${packageInfoData.data.PACKAGE_UNIT}');
		$("#packageUnit_label").html($("#packageUnit").selectedTexts());
		fn_loadCode("UNIT", "boxUnit");
		$("#boxUnit").selectOptions('${packageInfoData.data.BOX_UNIT}');
		$("#boxUnit_label").html($("#boxUnit").selectedTexts());
		
		
		
	});
	
	function fn_loadCode(codeId,selectBoxId) {
		var URL = "../common/codeListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{ groupCode : codeId
			},
			dataType:"json",
			async:false,
			success:function(data) {
				var list = data.RESULT;
				$("#"+selectBoxId).removeOption(/./);
				$("#"+selectBoxId).addOption("", "전체", false);
				$.each(list, function( index, value ){ //배열-> index, value
					$("#"+selectBoxId).addOption(value.itemCode, value.itemName, false);
				});
			},
			error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	}

	function fn_closeErpMatRayer(){
		$('#searchErpMatValue').val('')
		$('#erpMatLayerBody').empty();
		$('#erpMatLayerBody').append('<tr><td colspan="10">제품코드 혹은 제품명을 검색해주세요</td></tr>');
		$('#erpMatCount').text(0);
		closeDialog('dialog_erpMaterial');
	}

	function fn_searchErpMaterial(pageType) {
		var pageType = pageType;
		if(!pageType)
			$('#erpMatLayerPage').val(1);
		
		if(pageType == 'nextPage'){
			var totalCount = Number($('#erpMatCount').text());
			var maxPage = totalCount/10+1;
			var nextPage = Number($('#erpMatLayerPage').val())+1;
			
			if(nextPage >= maxPage) return; //nextPage = maxPage
			
			$('#erpMatLayerPage').val(nextPage);
		}

		if(pageType == 'prevPage'){
			var prevPage = Number($('#erpMatLayerPage').val())-1;
			if(prevPage <= 0) return; //prevPage = 1;
			
			$('#erpMatLayerPage').val(prevPage);
		}
		
		$('#lab_loading').show();
		
		$.ajax({
			url: '/material/selectErpMaterialListAjax',
			type: 'post',
			dataType: 'json',
			data: {
				searchValue: $('#searchErpMatValue').val(),
				pageNo: $('#erpMatLayerPage').val()
			},
			success: function(data){
				var jsonData = {};
				jsonData = data;
				$('#erpMatLayerBody').empty();
				$('#erpMatLayerBody').append('<input type="hidden" id="erpMatLayerPage" value="'+data.pageNo+'"/>');
				
				jsonData.list.forEach(function(item){
					
					var row = '<tr onClick="fn_setMaterialPopupData(\''+item.SAP_CODE+'\', \''+item.NAME+'\', \''+item.KEEP_CONDITION+'\', \''+item.TOTAL_WEIGHT+'\', \''+item.TOTAL_WEIGHT_UNIT+'\', \''+item.EXPIRATION_DATE+'\')">';
					//parentRowId, itemImNo, itemSAPCode, itemName, itemUnitPrice
					row += '<td></td>';
					//row += '<Td>'+item.companyCode+'('+item.plant+')'+'</Td>';
					row += '<Td>'+item.SAP_CODE+'</Td>';
					row += '<Td  class="tgnl">'+item.NAME+'</Td>';
					row += '<Td>'+item.KEEP_CONDITION+'</Td>';
					row += '<Td>'+item.WIDTH+'/'+item.LENGTH+'/'+item.HEIGHT+'</Td>';
					row += '<Td>'+item.TOTAL_WEIGHT+'('+item.TOTAL_WEIGHT_UNIT+')'+'</Td>';
					row += '<Td class="tgnl">'+item.STANDARD+'</Td>';
					row += '<Td>'+item.ORIGIN +'</Td>';
					row += '<Td>'+item.EXPIRATION_DATE+'</Td>';
					
					row += '</tr>';
					$('#erpMatLayerBody').append(row);
				})
				$('#erpMatCount').text(jsonData.totalCount)
				
				var isFirst = $('#erpMatLayerPage').val() == 1 ? true : false;
				var isLast = parseInt(jsonData.totalCount/10+1) == Number($('#erpMatLayerPage').val()) ? true : false;
				
				if(isFirst){
					$('#erpMatNextPrevDiv').children('button:first').attr('class', 'btn_code_left01');
				} else {
					$('#erpMatNextPrevDiv').children('button:first').attr('class', 'btn_code_left02');
				}
				
				if(isLast){
					$('#erpMatNextPrevDiv').children('button:last').attr('class', 'btn_code_right01');
				} else {
					$('#erpMatNextPrevDiv').children('button:last').attr('class', 'btn_code_right02');
				}
			},
			error: function(a,b,c){
				alert('원료검색 실패[2] - 시스템 담당자에게 문의하세요');
			},
			complete: function(){
				$('#lab_loading').hide();
			}
		});
	}

	function bindDialogEnter(e){
		if(e.keyCode == 13)
			fn_searchErpMaterial();
	}
	
	function fn_setMaterialPopupData(SAP_CODE, NAME, KEEP_CONDITION, TOTAL_WEIGHT, TOTAL_WEIGHT_UNIT, EXPIRATION_DATE) {
		$("#productName").val(NAME);
		$("#productNameBack").val(NAME);
		//$("#productName").prop("readonly",true);
		$("#productCode").val(SAP_CODE);
		$("#keepCondition").val(KEEP_CONDITION);
		$("#weight").val(TOTAL_WEIGHT+" "+TOTAL_WEIGHT_UNIT);
		$("#expireDate").val(EXPIRATION_DATE);
		fn_closeErpMatRayer();
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
	
	function fn_updateTmp(){
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
			formData.append("currentStatus",$("#currentStatus").val());
			formData.append("productName",$("#productName").val());
			formData.append("productCode",$("#productCode").val());
			formData.append("etcInfo",$("#etcInfo").val());
			formData.append("weight",$("#weight").val());
			formData.append("packageUnit",$("#packageUnit").selectedValues()[0]);
			formData.append("pieceWeight",$("#pieceWeight").val());
			formData.append("boxUnit",$("#boxUnit").selectedValues()[0]);
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
			formData.append("markDeleteFlag", $("#markDeleteFlag").val());
			formData.append("markorgFileName", $("#markorgFileName").val());
			formData.append("markfileName", $("#markfileName").val());
			formData.append("markfilePath", $("#markfilePath").val());
			
			// 이미지 파일
			var imageFile = document.getElementById('fileImageInput').files[0];
			if (imageFile) {
			  formData.append("imageFile", imageFile); // name="imageFile"
			}
			
			// 이미지 파일
			var markFile = document.getElementById('markImageInput').files[0];
			if (markFile) {
			  formData.append("markFile", markFile); // name="imageFile"
			}
			
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
			
			/* $('#deletedFileList option:selected').each(function() {
			    formData.append('deletedFileList', $(this).val());
			}); */
			
			var URL = "../package/updatePackageInfoTmpAjax";
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
						alert($("#productName").val()+" 표시사항 기재양식이 임시저장 되었습니다.");
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
	
	//입력확인
	function fn_update(){
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
			formData.append("currentStatus",$("#currentStatus").val());
			formData.append("productName",$("#productName").val());
			formData.append("productCode",$("#productCode").val());
			formData.append("etcInfo",$("#etcInfo").val());
			formData.append("weight",$("#weight").val());
			formData.append("packageUnit",$("#packageUnit").selectedValues()[0]);
			formData.append("pieceWeight",$("#pieceWeight").val());
			formData.append("boxUnit",$("#boxUnit").selectedValues()[0]);
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
			formData.append("markDeleteFlag", $("#markDeleteFlag").val());
			formData.append("markorgFileName", $("#markorgFileName").val());
			formData.append("markfileName", $("#markfileName").val());
			formData.append("markfilePath", $("#markfilePath").val());
			
			// 이미지 파일
			var imageFile = document.getElementById('fileImageInput').files[0];
			if (imageFile) {
			  formData.append("imageFile", imageFile); // name="imageFile"
			}
			
			// 이미지 파일
			var markFile = document.getElementById('markImageInput').files[0];
			if (markFile) {
			  formData.append("markFile", markFile); // name="imageFile"
			}
			
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
			
			/* $('#deletedFileList option:selected').each(function() {
			    formData.append('deletedFileList', $(this).val());
			}); */
			
			$('#lab_loading').show();
			var URL = "../package/updatePackageInfoTmpAjax";
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
			//$("#apprLine").removeOption(/./); 
			//$("#refLine").removeOption(/./); 
			var apprTxtFull = "";
			$("#apprLine").selectedTexts().forEach(function( item, index ){
				if( apprTxtFull != "" ) {
					apprTxtFull += " > ";
				}
				apprTxtFull += item;
			});
			$("#apprTxtFull").val(apprTxtFull);
			//apprTxtFull
			//refTxtFull
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
	
	function fn_changeImageFile2(input, e) {
		if (input.files && input.files[0]) {
			var reader = new FileReader();
			reader.onload = function (e) {
				document.getElementById('markPreview').src = e.target.result;
			};
			reader.readAsDataURL(input.files[0]);
			
			// 삭제 플래그 설정
			if( $("#markorgFileName").val() != "" ) {
				$("#makrDeleteFlag").val("Y");	
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
	
	function fn_deleteImageFile2(element, e) {
		const markPreview = document.getElementById('markPreview');
		const markImageInput = document.getElementById('markImageInput');

		if (markPreview) markPreview.src = "/resources/images/img_noimg3.png";
		if (markImageInput) markImageInput.value = "";
		
		// 삭제 플래그 설정
		if( $("#markorgFileName").val() != "" ) {
			$("#markDeleteFlag").val("Y");	
		}
	}
	
	function getSelectValue(labelEl, txtEl) {
	    var labelText = labelEl?.innerText?.trim() || "";
	    var txtValue = (txtEl && txtEl.style.display !== "none" && txtEl.value) ? txtEl.value.trim() : labelText;
	    return (txtValue === "선택") ? "" : txtValue;
	}
	
	function fn_previewDataBinding(popup) {
	    var $doc = popup.document;

	    // 텍스트 항목
	    $doc.getElementById("prev_productName").innerText = document.getElementById("productName").value;
	    $doc.getElementById("prev_etcInfo").innerText = document.getElementById("etcInfo").value;
	    $doc.getElementById("prev_weight").innerText = document.getElementById("weight").value;
	    
	    $doc.getElementById("prev_packageUnit").innerText = $("#packageUnit").selectedTexts();
	    $doc.getElementById("prev_pieceWeight").innerText = document.getElementById("pieceWeight").value;
	    $doc.getElementById("prev_boxUnit").innerText = $("#boxUnit").selectedTexts();

	    // 셀렉트 항목
	    $doc.getElementById("prev_keepCondition").innerText = getSelectValue(
	        document.getElementById("keepCondition_label"),
	        document.getElementById("keepConditionTxt")
	    );

	    $doc.getElementById("prev_foodType").innerText = getSelectValue(
	        document.getElementById("foodType_label"),
	        document.getElementById("foodTypeTxt")
	    );

	    $doc.getElementById("prev_separateDischarge").innerText = getSelectValue(
	        document.getElementById("separateDischarge_label"),
	        document.getElementById("separateDischargeTxt")
	    );

	    // 이미지
	    var markImg = document.getElementById("markPreview").getAttribute("src");
	    $doc.getElementById("prev_markImage").innerHTML =
	        '<img src="' + markImg + '" style="max-width: 100%; height: 200px;">';

	    var containImg = document.getElementById("preview").getAttribute("src");
	    $doc.getElementById("prev_containQuantityImg").innerHTML =
	        '<img src="' + containImg + '" style="max-width: 100%; height: 200px;">';

	    // 나머지 단순 항목
	    $doc.getElementById("prev_productNameBack").innerText = document.getElementById("productNameBack").value;
	    $doc.getElementById("prev_containQuantity").innerText = document.getElementById("containQuantity").value;
	    $doc.getElementById("prev_allergyObject").innerText = document.getElementById("allergyObject").value;
	    $doc.getElementById("prev_manufacturingNo").innerText = document.getElementById("manuNo").value;
	    $doc.getElementById("prev_expiredDate").innerText = document.getElementById("expiredDate").value;
	    $doc.getElementById("prev_packageObject").innerText = document.getElementById("packageObject").value;
	    $doc.getElementById("prev_maker").innerText = document.getElementById("maker").value;
	    $doc.getElementById("prev_distribution").innerText = document.getElementById("distribution").value;
	    $doc.getElementById("prev_returned").innerText = document.getElementById("returned").value;
	    $doc.getElementById("prev_customerCounsel").innerText = document.getElementById("customerCounsel").value;

	    // 에디터
	    $doc.getElementById("prev_suggestions").innerHTML = editor2.getData();
	    $doc.getElementById("prev_cookMethod").innerHTML = editor3.getData();

	    // 기타사항 목록
	    var etcInputs = document.getElementsByName("etc");
	    var etcHtml = "";
	    for (var i = 0; i < etcInputs.length; i++) {
	        var val = etcInputs[i].value.trim();
	        if (val) {
	            etcHtml += val + "<br>";
	        }
	    }
	    $doc.getElementById("prev_infoText").innerHTML = etcHtml;
	    
	 // ▼▼▼ [첨부파일] 미리보기 바인딩 추가 시작 ▼▼▼
	    // 파일명 안전 이스케이프
	    const esc = (s) => String(s)
	      .replaceAll("&", "&amp;")
	      .replaceAll("<", "&lt;")
	      .replaceAll(">", "&gt;")
	      .replaceAll('"', "&quot;")
	      .replaceAll("'", "&#39;");

	    // 1) <input type="file" name="files"> 들에서 선택된 파일명 수집
	    const fileNames = [];
	    document.querySelectorAll('input[type="file"][name="files"]').forEach(input => {
	      // 같은 input에 여러 파일이 선택될 수도 있음
	      Array.from(input.files || []).forEach(f => {
	        if (f && f.name) fileNames.push(f.name);
	      });
	    });

	    // 2) 이미 페이지의 파일 목록(UI)에서 표시 중인 항목도 수집 (드래그&드롭 등으로 추가된 케이스)
	    //    - <ul id="attatch_file"><li>...파일명...</li></ul> 형태 가정
	    const $ul = document.getElementById("attatch_file");
	    if ($ul) {
	      $ul.querySelectorAll("li").forEach(li => {
	        // li 안에 a/span이 있든 그냥 텍스트든 전부 텍스트로 인식
	        const t = (li.textContent || "").trim();
	        if (t) fileNames.push(t);
	      });
	    }

	    // 3) 중복 제거 + 공백 제거
	    const uniqueNames = Array.from(new Set(
	      fileNames.map(s => s.trim()).filter(Boolean)
	    ));

	    // 4) 미리보기 페이지에 반영
	    const $prevFile = $doc.getElementById("prev_file");
	    const $prevFileWrap = $doc.getElementById("wrapper_prev_file"); // 있으면 사용, 없으면 무시

	    if (uniqueNames.length > 0) {
	      // <br/>로 줄바꿈하여 넣기
	      $prevFile.innerHTML = uniqueNames.map(n => esc(n)).join("<br/>");
	      if ($prevFileWrap) $prevFileWrap.style.display = "table-row"; // 또는 "block" (미리보기 마크업에 맞게)
	    } else {
	      // 아무 파일도 없으면 숨기거나 대시 처리
	      // ① 숨김
	      if ($prevFileWrap) $prevFileWrap.style.display = "none";
	      // ② 혹은 표시 유지 시 대시
	      // $prevFile.textContent = "-";
	    }
	    // ▲▲▲ [첨부파일] 미리보기 바인딩 추가 끝 ▲▲▲
	    
	}

	function fn_openPreview() {
		var url = "/preview/packageInfoPrevPopup";

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
		표시사항기재양식&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;표시사항기재양식서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Package Info Document</span><span class="title">표시사항기재양식</span>
			<div class="top_btn_box">
				<!-- <ul>
					<li>
						<button class="btn_circle_save" onclick="fn_update()">&nbsp;</button>
					</li>
				</ul> -->
			</div>
		</h2>
		<div class="group01 mt20">
            <div class="title2"  style="display: flex; justify-content:space-between; width: 100%;">
				<span class="txt">기본정보</span>
				<div class="pr15">
					<button id="prevBtn" class="btn_small_search" onclick="fn_openPreview()">미리보기</button>
				</div>
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
							<th style="border-left: none;" rowspan="8">정면(주표시면)</th>
							<td>
								제품명<span class="mandatory">*</span>
							</td>
							<td>
								<input type="hidden" name="idx" id="idx" value="${packageInfoData.data.PACKAGE_IDX}"/>
								<input type="hidden" name="docNo" id="docNo" value="${packageInfoData.data.DOC_NO}"/>
								<input type="hidden" name="versionNo" id="versionNo" value="${packageInfoData.data.VERSION_NO}"/>
								<input type="hidden" name="currentStatus" id="currentStatus" value="${packageInfoData.data.STATUS}"/>
								<input type="hidden" name="productCode" id="productCode" value="${packageInfoData.data.PRODUCT_CODE}"/>
								<input type="text" name="productName" id="productName" style="width:250px;float: left" placeholder="" value="${packageInfoData.data.PRODUCT_NAME}"/>
								<button class="btn_small_search ml5" onclick="openDialog('dialog_erpMaterial')" style="float: left">조회</button>
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
								<input type="text" name="etcInfo" id="etcInfo" style="width:300px;" placeholder="" value="${packageInfoData.data.ETC_INFO}"/>
							</td>
							<td rowspan="6">
								주표시면 주원료 함량 표시시
								원재료와 함량 표기 기재 요망
							</td>
						</tr>
						<tr>
							<td>
								중량
							</td>
							<td>
								<input type="text" name="weight" id="weight" style="width:300px;" placeholder="" value="${packageInfoData.data.WEIGHT}"/>
							</td>
						</tr>
						<tr>
							<td>
								포장단위
							</td>
							<td>
								<div class="selectbox" style="width:200px;">  
									<label for="packageUnit" id="packageUnit_label">선택</label> 
									<select name="packageUnit" id="packageUnit" onChange="">		
									</select>
								</div>
							</td>
						</tr>
						<tr>
							<td>
								낱개 중량
							</td>
							<td>
								<input type="text" name="pieceWeight" id="pieceWeight" style="width:300px;" placeholder="" value="${packageInfoData.data.PIECE_WEIGHT}"/>
							</td>
						</tr>
						<tr>
							<td>
								박스단위
							</td>
							<td>
								<div class="selectbox" style="width:200px;">  
									<label for="boxUnit" id="boxUnit_label">선택</label> 
									<select name="boxUnit" id="boxUnit" onChange="">		
									</select>
								</div>
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
								<input type="text" name="keepConditionTxt" id="keepConditionTxt" style="${packageInfoData.data.KEEP_CONDITION == '999'? '' : 'display:none'}" placeholder="보관방법을 입력하세요." value="${packageInfoData.data.KEEP_CONDITION_TXT}"/>
							</td>
						</tr>
						<tr>
							<td>
								마크
							</td>
							<td>
								<input type="hidden" name="markDeleteFlag" id="markDeleteFlag" value="N">
								<input type="hidden" name="markorgFileName" id="markorgFileName" value="${packageInfoData.data.MARK_ORG_FILE_NAME}">
								<input type="hidden" name="markfileName" id="markfileName" value="${packageInfoData.data.MARK_FILE_NAME}">
								<input type="hidden" name="markfilePath" id="markfilePath" value="${packageInfoData.data.MARK_FILE_PATH}">
								<c:set var="hasImage" value="${not empty packageInfoData.data.MARK_FILE_PATH and not empty packageInfoData.data.MARK_FILE_NAME}" />
								<p><img id="markPreview" src="<c:choose>
								                      <c:when test='${hasImage}'>
								                          /images${packageInfoData.data.MARK_FILE_PATH}/${packageInfoData.data.MARK_FILE_NAME}
								                      </c:when>
								                      <c:otherwise>
								                          /resources/images/img_noimg3.png
								                      </c:otherwise>
								                  </c:choose>" style="border:1px solid #e1e1e1; border-radius:5px; width:310px; height:250px;"></p>
								<p class="pt10">
									<div class="add_file2" style="width:100%; align:center;" onclick="fn_fileDivClick(event)">
										<input type="file" name="file" id="markImageInput" accept="image/*" style="display:none;" onchange="fn_changeImageFile2(this, event)">
										<label for="markImageInput" style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>
									</div>	
								</p>
								<div style=" z-index:3; position:relative;right:-300px; top:-300px; width: 25px; height: 25px;">
									<img src="/resources/images/btn_table_header01_del02.png" onClick="fn_deleteImageFile2(this, event)">
								</div>
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
							<td>제품명<span class="mandatory">*</span></td>
							<td colspan="2">
								<input type="text" name="productNameBack" id="productNameBack" style="width:300px;" placeholder="" value="${packageInfoData.data.PRODUCT_NAME_BACK}"/>
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
								<input type="text" name="foodTypeTxt" id="foodTypeTxt" style="width:300px;${packageInfoData.data.FOOD_TYPE == '999'? '' : 'display:none;'}" placeholder="식품유형을 입력하세요." value="${packageInfoData.data.FOOD_TYPE_TXT}"/>
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
								<input type="text" name="allergyObject" id="allergyObject" style="width:95%;" placeholder="알러지 유발물질을 입력하세요." value="${packageInfoData.data.ALLERGY_OBJECT}"/>
							</td>
						</tr>
						<tr>
							<td>품목보고번호</td>
							<td colspan="2">
								<input type="text" name="manuNo" id="manuNo" style="width:300px;" placeholder="품목보고번호를 입력하세요." value="${packageInfoData.data.MANUFACTURING_NO}"/>
							</td>
						</tr>
						<tr>
							<td>소비기한</td>
							<td colspan="2">
								<input type="text" name="expiredDate" id="expiredDate" style="width:300px;" placeholder="소비기한을 입력하세요." value="${packageInfoData.data.EXPIRED_DATE}"/>
							</td>
						</tr>
						<tr>
							<td>포장재질</td>
							<td colspan="2">
								<input type="text" name="packageObject" id="packageObject" style="width:300px;" placeholder="포장재질을 입력하세요." value="${packageInfoData.data.PACKAGE_OBJECT}"/>
							</td>
						</tr>
						<tr>
							<td>제조원</td>
							<td colspan="2">
								<input type="text" name="maker" id="maker" style="width:95%;" placeholder="제조원을 입력하세요." value="${packageInfoData.data.MAKER}"/>
							</td>
						</tr>
						<tr>
							<td>유통전문판매원</td>
							<td colspan="2">
								<input type="text" name="distribution" id="distribution" style="width:95%;" placeholder="유통전문판매원을 입력하세요." value="${packageInfoData.data.DISTRIBUTION}"/>
							</td>
						</tr>
						<tr>
							<td>반품 및 교환장소</td>
							<td colspan="2">
								<input type="text" name="returned" id="returned" style="width:95%;" placeholder="반품 및 교환장소를 입력하세요." value="${packageInfoData.data.RETURNED}"/>
							</td>
						</tr>
						<tr>
							<td>소비자상담실</td>
							<td colspan="2">
								<input type="text" name="customerCounsel" id="customerCounsel" style="width:300px;" placeholder="소비자상담실 정보를 입력하세요." value="${packageInfoData.data.CUSTOMER_COUNSEL}"/>
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
												<input type="text" name="etc" id="etc" style="width: 90%;" value="${infoList.INFO_TEXT}"/>
											</td>
										</tr>
									</c:forEach>	
									<c:if test="${addInfoList == null or fn:length(addInfoList) == 0}">
										<tr id="etc_tr_1">
											<td>
												<input type="text" name="etc" id="etc" style="width: 90%;"/>
											</td>
										</tr>
									</c:if>
									</tbody>
									<tbody id="etc_tbody_temp" name="etc_tbody_temp" style="display:none">
										<tr id="etc_tmp_tr_1" style="display:none">
											<td>
												<input type="text" name="etc" id="etc" style="width: 90%;"/>
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
								<input type="text" name="separateDischargeTxt" id="separateDischargeTxt" style="width:300px;${packageInfoData.data.SEPARATE_DISCHARGE == '999'? '' : 'display:none;'}" placeholder="분리배출 표시사항을 입력하세요." value="${packageInfoData.data.SEPARATE_DISCHARGE_TXT}"/>
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
					</tbody>
				</table>
			</div>
			
			<div class="title2 mt20"  style="width:90%;"><span class="txt">파일첨부</span></div>
			<div class="list_detail">
				<ul style="">
					<li>
						<dt style="width: 20%">첨부파일</dt>
						<dd style="width: 80%;">
							<div class="add_file" id="add_file2" style="width:100%">
								<span id="upFile">
									<span class="file_load" id="fileSpan2" style="display: none;"><input type="file" name="files" id="file2" onchange="addFile(this, '00')" style="display:none"><label for="file2">첨부파일 등록 <img src="/resources/images/icon_add_file.png"></label></span>
									<span class="file_load" id="fileSpan3"><input type="file" name="files" id="file3" onchange="addFile(this, '00')" style="display:none"><label for="file3">첨부파일 등록 <img src="/resources/images/icon_add_file.png"></label></span>
								</span>
							</div>
							<div id="fileList" class="file_box_pop" style="height: 120px; width: 100%; border-top-left-radius: 0px; border-top-right-radius: 0px; border-top: 1px solid rgb(221, 221, 221); box-sizing: border-box;" ondrop="drop(event)" ondragover="allowDrop(event)" ondragend="drogEnd(event)" ondragleave="drogEnd(event)">
								<ul id="attatch_file">
									<c:forEach items="${packageInfoData.fileList}" var="fileList" varStatus="status">
										<li data-path="${fileList.FILE_PATH}" data-name="${fileList.FILE_NAME}"><a href="#none" onclick="fn_removeTempFile(this, '${fileList.FILE_IDX}')"><img src="/resources/images/icon_del_file.png"></a>${fileList.ORG_FILE_NAME}</li>
									</c:forEach>
								</ul>	
							</div>
						</dd>
					</li>
				</ul>
			</div>
				<%-- <div class="title2 mt20" style="width:10%; display: inline-block;">
					<button class="btn_con_search" onClick="openDialog('dialog_attatch')">
						<img src="/resources/images/icon_s_file.png" />파일첨부 
					</button>
				</div>
				<div class="con_file" style="">
					<ul>
						<li class="point_img">
							<dt>첨부파일</dt><dd>
								<ul id="attatch_file">
								</ul>
							</dd>
						</li>
					</ul>
				</div>
				<c:if test="${not empty packageInfoData.fileList}">
				<select id="tempFileList" name="tempFileList" multiple style="display:none">
				  <c:forEach var="file" items="${packageInfoData.fileList}">
				    <option value="${file.FILE_IDX}">${file.ORG_FILE_NAME}</option>
				  </c:forEach>
				</select>
				<div class="con_file" style="">
					<ul>
						<li class="point_img">
							<dt>기존파일</dt><dd>
								<ul id="attatch_file">
						              <c:forEach var="file" items="${packageInfoData.fileList}">
						              <li data-file-idx="${file.FILE_IDX}">
						                <a href="${file.FILE_PATH}" onclick="removeTempFile('${file.FILE_IDX}', this); return false;">
						                  <img src="/resources/images/icon_del_file.png">
						                </a>&nbsp;${file.ORG_FILE_NAME}
						              </li>
						            </c:forEach>
								</ul>
							</dd>
						</li>
					</ul>
				</div>
			    <!-- 숨겨진 select 박스 -->
				<select name="deletedFileList" id="deletedFileList" multiple style="display: none;"></select>
				</c:if> --%>
							
			<div class="main_tbl">
				<div class="btn_box_con5">
					<button class="btn_admin_gray" onClick="fn_goList();" style="width: 120px;">목록</button>
				</div>
				<div class="btn_box_con4">
					<!-- 
					<button class="btn_admin_red">임시/템플릿저장</button>
					 -->
					<c:if test="${userUtil:getUserId(pageContext.request) == packageInfoData.data.DOC_OWNER}">
						<c:if test="${packageInfoData.data.STATUS == 'TMP'}">
						<button class="btn_admin_navi" onclick="fn_updateTmp()">임시저장</button>
						</c:if>
						<button class="btn_admin_sky" onclick="fn_update()">등록</button>
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
							<th>소비기한</th>
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
							<th>소비기한</th>
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
