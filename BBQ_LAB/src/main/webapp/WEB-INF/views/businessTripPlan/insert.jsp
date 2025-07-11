<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>출장계획보고서 생성</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 400px; min-height:150px;}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	var editor1;
	var editor2;
	$(document).ready(function(){
		$("#tripStartDate").datepicker({
			showOn: "both",
			buttonImage: "../resources/images/btn_calendar.png",
			buttonImageOnly: true,
			buttonText: "Select date",
			dateFormat: "yy-mm-dd",
			showButtonPanel: true,
			showAnim: "",
			onClose: function(selectedDate){
				$("#tripEndDate").datepicker("option", "minDate", selectedDate);
			}
		});	//당일 선택 가능 0, 당일 선택 불가능 1
		
		$("#tripEndDate").datepicker({
			showOn: "both",
			buttonImage: "../resources/images/btn_calendar.png",
			buttonImageOnly: true,
			buttonText: "Select date",
			dateFormat: "yy-mm-dd",
			minDate: 0,
			showButtonPanel: true,
			showAnim: "",
			onClose: function(selectedDate){
				$("#tripStartDate").datepicker("option", "maxdate", selectedDate)
			}
		});
		/*
		ClassicEditor
        .create(document.getElementById("tripContents"), {
			language: 'ko',
        }).then( editor => {
        	editor1 = editor;
    		console.log( editor1 );
    	}).catch( error => {
    		console.error( error );
    	});
		
		ClassicEditor
        .create(document.getElementById("tripCost"), {
			language: 'ko',
        }).then( editor => {
        	editor2 = editor;
    		console.log( editor2 );
    	}).catch( error => {
    		console.error( error );
    	});
		*/
		fn.autoComplete($("#keyword"));
		autoComplete2($("#keyword2"));
	});
	
	/*
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
	*/
	
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
		
		$("#docTypeTemp").removeOption(/./);
		var docTypeTxt = "";
		$('input:checkbox[name=docType]').each(function (index) {
			if($(this).is(":checked")==true){
		    	$("#docTypeTemp").addOption($(this).val(), $(this).next("label").text(), true);
		    	//if( index != 0 ) {
	    		if( docTypeTxt != "" ){
	    			docTypeTxt += ", ";
	    		}
	    		docTypeTxt += $(this).next("label").text();
		    	//} else {
		    	//	docTypeTxt += $(this).next("label").text();
		    	//}
		    }
		});
		$("#docTypeTxt").html(docTypeTxt);
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
	
	function fn_insertTmp() {
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			$("#title").focus();
			return;
		} else {
			$('#lab_loading').show();
			var formData = new FormData();
			formData.append("title",$("#title").val());
			formData.append("tripType",$("#tripType").selectedValues()[0]);
			formData.append("tripDiv",$("#tripDiv").selectedValues()[0]);
			
			var deptArr = new Array();
			var positionArr = new Array();
			var nameArr = new Array();
			$('tr[id^=user_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemDept = $('#'+ rowId + ' input[name=dept]').val();
				var itemPosition = $('#'+ rowId + ' input[name=position]').val();
				var itemNmae = $('#'+ rowId + ' input[name=name]').val();				
				deptArr.push(itemDept);
				positionArr.push(itemPosition);
				nameArr.push(itemNmae);
			});
			formData.append("deptArr",JSON.stringify(deptArr));
			formData.append("positionArr",JSON.stringify(positionArr));
			formData.append("nameArr",JSON.stringify(nameArr));
			
			var purposeElements = document.querySelectorAll('input[name="purpose"]');
			var purposeArr = new Array();
			for (var purposeElement of purposeElements) {
				if( purposeElement.value != '' ) {
					purposeArr.push(purposeElement.value);	
				}
			}			
			formData.append("purposeArr",JSON.stringify(purposeArr));
			
			formData.append("tripStartDate",$("#tripStartDate").val());
			formData.append("tripEndDate",$("#tripEndDate").val());
			
			//tripDestination
			var tripDestinationElements = document.querySelectorAll('input[name="tripDestination"]');
			var tripDestinationArr = new Array();
			for (var tripDestinationElement of tripDestinationElements) {
				if( tripDestinationElement.value != '' ) {
					tripDestinationArr.push(tripDestinationElement.value);
				}				
			}			
			formData.append("tripDestinationArr",JSON.stringify(tripDestinationArr));
			
			var scheduleArr = new Array();
			var contentArr = new Array();
			var placeArr = new Array();
			var noteArr = new Array();
			$('tr[id^=contents_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemSchedule = $('#'+ rowId + ' input[name=schedule]').val();
				var itemContent = $('#'+ rowId + ' input[name=content]').val();
				var itemPlace = $('#'+ rowId + ' input[name=place]').val();	
				var itemNote = $('#'+ rowId + ' input[name=note]').val();	
				if( !(itemSchedule == '' && itemContent == '' && itemPlace == '' && itemNote == '') ) {
					scheduleArr.push(itemSchedule);
					contentArr.push(itemContent);
					placeArr.push(itemPlace);
					noteArr.push(itemNote);
				}				
			});
			formData.append("scheduleArr",JSON.stringify(scheduleArr));
			formData.append("contentArr",JSON.stringify(contentArr));
			formData.append("placeArr",JSON.stringify(placeArr));
			formData.append("noteArr",JSON.stringify(noteArr));
			
			formData.append("tripCost",$("#tripCost").val());
			formData.append("calMethod",$("#calMethod").val());
			formData.append("tripEffect",$("#tripEffect").val());
			formData.append("tripTransit",$("#tripTransit").val());
			formData.append("docType", $("#docType").val());
			formData.append("status", "TMP");
			
			for (var i = 0; i < attatchFileArr.length; i++) {
				formData.append('file', attatchFileArr[i])
			}
			
			for (var i = 0; i < attatchFileTypeArr.length; i++) {
				formData.append('fileTypeText', attatchFileTypeArr[i].fileTypeText)			
			}
			
			for (var i = 0; i < attatchFileTypeArr.length; i++) {
				formData.append('fileType', attatchFileTypeArr[i].fileType)			
			}
			
			URL = "../businessTripPlan/insertBusinessTripPlanTmpAjax";
			$.ajax({
				type:"POST",
				url:URL,
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				dataType:"json",
				success:function(result) {
					if(data.RESULT == 'S') {
						alert("임시저장되었습니다.");
						$('#lab_loading').hide();
						fn_goList();
						return;
					} else {
						alert("오류가 발생하였습니다."+data.MESSAGE);
						$('#lab_loading').hide();
						fn_goList();
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
	
	//입력확인
	function fn_insert(){
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			$("#title").focus();
			return;
		} else if( !chkNull($("#tripStartDate").val()) ) {
			alert("출장일을 입력해 주세요.");
			$("#tripStartDate").focus();
			return;
		} else if( !chkNull($("#tripCost").val()) ) {
			alert("경비를 입력해주세요.");		
			return;
		} /* else if( attatchFileArr.length == 0  && $("#tempFileList option").length == 0) {
			alert("첨부파일을 등록해주세요.");		
			return;			
		} */ else {
			var formData = new FormData();
			formData.append("title",$("#title").val());
			formData.append("tripType",$("#tripType").selectedValues()[0]);
			formData.append("tripDiv",$("#tripDiv").selectedValues()[0]);
			
			var deptArr = new Array();
			var positionArr = new Array();
			var nameArr = new Array();
			$('tr[id^=user_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemDept = $('#'+ rowId + ' input[name=dept]').val();
				var itemPosition = $('#'+ rowId + ' input[name=position]').val();
				var itemNmae = $('#'+ rowId + ' input[name=name]').val();				
				deptArr.push(itemDept);
				positionArr.push(itemPosition);
				nameArr.push(itemNmae);
			});
			if( deptArr.length == 0 || positionArr.length == 0 || nameArr.length == 0 ) {
				alert("출장자를 입력해주세요.");
				return;
			}
			formData.append("deptArr",JSON.stringify(deptArr));
			formData.append("positionArr",JSON.stringify(positionArr));
			formData.append("nameArr",JSON.stringify(nameArr));
			
			var purposeElements = document.querySelectorAll('input[name="purpose"]');
			var purposeArr = new Array();
			for (var purposeElement of purposeElements) {
				if( purposeElement.value != '' ) {
					purposeArr.push(purposeElement.value);	
				}
			}	
			if( purposeArr.length == 0 ) {
				alert("출장목적을 입력해주세요.");
				return;
			}
			formData.append("purposeArr",JSON.stringify(purposeArr));
			
			formData.append("tripStartDate",$("#tripStartDate").val());
			formData.append("tripEndDate",$("#tripEndDate").val());
			
			//tripDestination
			var tripDestinationElements = document.querySelectorAll('input[name="tripDestination"]');
			var tripDestinationArr = new Array();
			for (var tripDestinationElement of tripDestinationElements) {
				if( tripDestinationElement.value != '' ) {
					tripDestinationArr.push(tripDestinationElement.value);
				}				
			}	
			if( tripDestinationArr.length == 0 ) {
				alert("출장지를 입력해주세요.");
				return;
			}
			formData.append("tripDestinationArr",JSON.stringify(tripDestinationArr));
			
			var scheduleArr = new Array();
			var contentArr = new Array();
			var placeArr = new Array();
			var noteArr = new Array();
			$('tr[id^=contents_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemSchedule = $('#'+ rowId + ' input[name=schedule]').val();
				var itemContent = $('#'+ rowId + ' input[name=content]').val();
				var itemPlace = $('#'+ rowId + ' input[name=place]').val();	
				var itemNote = $('#'+ rowId + ' input[name=note]').val();	
				if( !(itemSchedule == '' && itemContent == '' && itemPlace == '' && itemNote == '') ) {
					scheduleArr.push(itemSchedule);
					contentArr.push(itemContent);
					placeArr.push(itemPlace);
					noteArr.push(itemNote);
				}
			});
			if( scheduleArr.length == 0 || contentArr.length == 0 || placeArr.length == 0 || noteArr.length == 0 ) {
				alert("업무수행 내용을 입력해주세요.");
				return;
			}
			formData.append("scheduleArr",JSON.stringify(scheduleArr));
			formData.append("contentArr",JSON.stringify(contentArr));
			formData.append("placeArr",JSON.stringify(placeArr));
			formData.append("noteArr",JSON.stringify(noteArr));
			
			formData.append("tripCost",$("#tripCost").val());
			formData.append("calMethod",$("#calMethod").val());
			formData.append("tripEffect",$("#tripEffect").val());
			formData.append("tripTransit",$("#tripTransit").val());
			formData.append("docType", $("#docType").val());
			formData.append("status", "REG");
			
			for (var i = 0; i < attatchFileArr.length; i++) {
				formData.append('file', attatchFileArr[i])
			}
			
			for (var i = 0; i < attatchFileTypeArr.length; i++) {
				formData.append('fileTypeText', attatchFileTypeArr[i].fileTypeText)			
			}
			
			for (var i = 0; i < attatchFileTypeArr.length; i++) {
				formData.append('fileType', attatchFileTypeArr[i].fileType)			
			}
			
			$('#lab_loading').show();
			URL = "../businessTripPlan/insertBusinessTripPlanAjax";
			$.ajax({
				type:"POST",
				url:URL,
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				dataType:"json",
				success:function(result) {
					console.log(result);
					if( result.RESULT == 'S' ) {
						if( result.IDX > 0 ) {
							//alert($("#productName").val()+"("+$("#productCode").val()+")"+"가 정상적으로 생성되었습니다.");
							//fn_goList();
							
							if( $("#apprLine option").length > 0 ) {
								var apprFormData = new FormData();
								apprFormData.append("docIdx", result.IDX );
								apprFormData.append("apprComment", $("#apprComment").val());
								apprFormData.append("apprLine", $("#apprLine").selectedValues());
								apprFormData.append("refLine", $("#refLine").selectedValues());
								apprFormData.append("title", $("#title").val());
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
								alert($("#title").val()+" 문서가 정상적으로 생성되었습니다.");
								$('#lab_loading').hide();
								fn_goList();
							}

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

	function fn_goList() {
		location.href = '/businessTripPlan/list';
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
	
	autoComplete2 = function(objKeyWord){
		var config = new Object();
		config.minLength = 1;
		config.delay = 300;
		config.source = function(request, response){
			if(nvl(objKeyWord.val(),"").indexOf("/") > 0) return;
			fn.ajax("/approval/searchUserAjax",{keyword:objKeyWord.val()},function(data){
				response($.map(data, function(item){
					var txt = item.USER_NAME + ' / '+item.USER_ID + ' / '+ item.OBJTTX + ' / '+ item.TITL_TXT;
					if( nvl(item.RESP_TXT, '') != '' ) {
						txt += "("+item.RESP_TXT+")"
					}
					return {
						label : txt,
						value : txt,
						userId : item.USER_ID,
						deptName : item.OBJTTX,
						postionName : nvl(item.RESP_TXT, ''),
						titleName : item.TITL_TXT,
						userName : item.USER_NAME
					};
				}));
			});
		};
		config.select = function(event,ui){
			console.log(ui);
			jQuery('#addDeptName').val('');
			jQuery('#addDeptName').val(ui.item.deptName);
			
			jQuery('#addPostionName').val('');
			jQuery('#addPostionName').val(ui.item.postionName);
			
			jQuery('#addTitleName').val('');
			jQuery('#addTitleName').val(ui.item.titleName);
			
			jQuery('#addUserName').val('');
			jQuery('#addUserName').val(ui.item.userName);
			
			jQuery('#addUserId').val('');
			jQuery('#addUserId').val(ui.item.userId);
		};
		config.focus = function( event, ui ) {
			return false;
		};
		objKeyWord.autocomplete(config);
	}
	
	function addUser() {
		if( $("#addUserId").val() == '' || $("#addUserName").val() == '' ) {
			alert("출장자를 선택해주세요.");
		} else {
			fn_addCol('user');
			var trObj = $("#user_tbody tr:last");
			trObj.find("input[name='dept']").val($("#addDeptName").val());
			var txt = $("#addTitleName").val();
			if( $("#addPostionName").val() != '' ) {
				txt += "("+$("#addPostionName").val()+")"
			}
			trObj.find("input[name='position']").val(txt);
			trObj.find("input[name='name']").val($("#addUserName").val());			
			$("#keyword2").val("");
			$('#addDeptName').val('');
			$('#addPostionName').val('');
			$('#addTitleName').val('');
			$('#addUserName').val('');
			$('#addDeptName').val('');
		}
	}
	
	function delUser(element) {
		$(element).parent().parent().parent().parent().remove();
	}
	
	function fn_previewDataBinding(popup) {
	    const $doc = popup.document;
	    $doc.title = document.getElementById("title").value + '_출장계획보고서';

	    // 제목
	    $doc.getElementById("prev_title").innerText = document.getElementById("title").value;

	    // 출장구분
	    const tripTypeLabel = document.getElementById("tripType_label").innerText.trim();
	    const tripDivLabel = document.getElementById("tripDiv_label").innerText.trim();
	    const tripTypeText = (tripTypeLabel === "선택" ? "" : tripTypeLabel);
	    const tripDivText = (tripDivLabel === "선택" ? "" : tripDivLabel);
	    const tripTypeResult = [tripTypeText, tripDivText].filter(Boolean).join(" / ");
	    $doc.querySelector("#prev_trip_type").innerText = tripTypeResult;

	    // 출장자
	    const userRows = document.querySelectorAll("#user_tbody tr");
	    const userPreviewTbody = $doc.querySelector("#prev_user_tbody");
	    const userWrapper = userPreviewTbody.closest("div");
	    userPreviewTbody.innerHTML = "";
	    if (userRows.length === 0) {
	        userWrapper.style.display = "none";
	    } else {
	        userWrapper.style.display = "block";
	        userRows.forEach(function (row) {
	            const dept = row.querySelector('input[name="dept"]').value;
	            const position = row.querySelector('input[name="position"]').value;
	            const name = row.querySelector('input[name="name"]').value;

	            const tr = $doc.createElement("tr");
	            [dept, position, name].forEach(function (val) {
	                const td = $doc.createElement("td");
	                td.innerText = val;
	                tr.appendChild(td);
	            });
	            userPreviewTbody.appendChild(tr);
	        });
	    }

	    // 출장목적
	    let purposeHTML = "";
	    document.querySelectorAll("#purpose_tbody input[name='purpose']").forEach(function (input) {
	        const val = input.value.trim();
	        if (val) purposeHTML += val + "<br/>";
	    });
	    $doc.querySelector("#prev_purpose_tbody").innerHTML = purposeHTML;

	    // 출장기간
	    const startDate = document.getElementById("tripStartDate").value.trim();
	    const endDate = document.getElementById("tripEndDate").value.trim();
	    let tripDateText = "";
	    if (startDate && endDate) tripDateText = startDate + " ~ " + endDate;
	    else if (startDate) tripDateText = startDate;
	    else if (endDate) tripDateText = endDate;
	    $doc.querySelector("#prev_trip_date").innerText = tripDateText;

	    // 출장지, 경유지
	    // 출장지
		let destinationText = "";
		document.querySelectorAll('input[name="tripDestination"]').forEach(function(input) {
		    const val = input.value.trim();
		    if (val) destinationText += val + "<br/>";
		});
		$doc.querySelector("#prev_tripDestination").innerHTML = destinationText;
	    $doc.querySelector("#prev_tripTransit").innerText = document.getElementById("tripTransit").value.trim();

	    // 업무수행내용
	    const contentsRows = document.querySelectorAll("#contents_tbody tr");
	    const contentsPreviewTbody = $doc.querySelector("#prev_contents_tbody");
	    const contentsWrapper = contentsPreviewTbody.closest("div");
	    contentsPreviewTbody.innerHTML = "";
	    let hasContentRow = false;
	    contentsRows.forEach(function (row) {
	        const schedule = row.querySelector("input[name='schedule']").value;
	        const content = row.querySelector("input[name='content']").value;
	        const place = row.querySelector("input[name='place']").value;
	        const note = row.querySelector("input[name='note']").value;

	        if (schedule || content || place || note) {
	            hasContentRow = true;
	            const tr = $doc.createElement("tr");
	            [schedule, content, place, note].forEach(function (val) {
	                const td = $doc.createElement("td");
	                td.innerText = val;
	                tr.appendChild(td);
	            });
	            contentsPreviewTbody.appendChild(tr);
	        }
	    });
	    contentsWrapper.style.display = hasContentRow ? "block" : "none";

	    // 예상경비, 산출식, 기대효과
	    $doc.getElementById("prev_tripCost").innerText = document.getElementById("tripCost").value;
	    $doc.getElementById("prev_calMethod").innerText = document.getElementById("calMethod").value;
	    $doc.getElementById("prev_tripEffect").innerText = document.getElementById("tripEffect").value;
	}

	
	function fn_openPreview() {
		var url = "/preview/businessTripPlanPrevPopup";

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
		출장계획 보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Design Change Report</span><span class="title">출장계획보고서</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<button class="btn_circle_save" onclick="fn_insert()">&nbsp;</button>
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
							<td colspan="3"><input type="text" name="title" id="title" style="width: 90%;" class="req" /></td>
						</tr>
						<tr>
							<th style="border-left: none;">출장구분</th>
							<td colspan="3">
								<div class="selectbox" style="width:150px;">  
									<label for="tripType" id="tripType_label">선택</label> 
									<select name="tripType" id="tripType">
										<option value="">선택</option>
										<option value="I">국내</option>
										<option value="O">해외</option>
									</select>
								</div>
								<div class="selectbox" style="width:150px;margin-left:10px;">  
									<label for="tripDiv" id="tripDiv_label">선택</label> 
									<select name="tripDiv" id="tripDiv">
										<option value="">선택</option>
										<option value="T">출장</option>
										<option value="R">시장조사</option>
									</select>
								</div>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">출장자</th>
							<td colspan="3">
								<input type="text" name="keyword2" id="keyword2" style="width: 50%;float: left"/>
								<input type="hidden" name="addUserId" id="addUserId"/>
								<input type="hidden" name="addUserName" id="addUserName"/>
								<input type="hidden" name="addDeptName" id="addDeptName"/>
								<input type="hidden" name="addPostionName" id="addPostionName"/>
								<input type="hidden" name="addTitleName" id="addTitleName"/>
								<button class="btn_small_search ml5" onclick="addUser();" style="float: left" name="user_add_btn" id="user_add_btn">추가</button>
								<table width="100%">
									<tr>
										<td width="30%">소속</td>
										<td width="30%">직위(직급)</td>
										<td width="30%">성명</td>
										<td>&nbsp;</td>
									</tr>
									<tbody id="user_tbody" name="user_tbody">
										<!-- 
										<tr id="user_tr_1">
											<td>
												<input type="text" name="dept" id="dept" style="width: 100%;" class="req" readonly/>
											</td>
											<td>
												<input type="text" name="position" id="position" style="width: 100%;" class="req" readonly/>
											</td>
											<td>
												<input type="text" name="name" id="name" style="width: 100%;" class="req" readonly/>
											</td>
											<td>
												삭제
											</td>
										</tr>
										 -->
									</tbody>
									<tbody id="user_tbody_temp" name="user_tbody_temp" style="display:none">
										<tr id="user_tmp_tr_1" style="display:none">
											<td>
												<input type="text" name="dept" id="dept" style="width: 100%;" class="req" readonly/>
											</td>
											<td>
												<input type="text" name="position" id="position" style="width: 100%;" class="req" readonly/>
											</td>
											<td>
												<input type="text" name="name" id="name" style="width: 100%;" class="req" readonly/>
											</td>
											<td>
												<ul>
												<li style="float:none; display:inline">
													<button class="btn_doc" onClick="javascript:delUser(this)"><img src="/resources/images/icon_doc04.png">삭제</button>
												</li>
												</ul>
											</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">출장목적<span onClick="fn_addCol('purpose')">(+)</span></th>
							<td colspan="3">
								<table width="100%" border="0">
									<tbody id="purpose_tbody" name="purpose_tbody">
										<tr id="purpose_tr_1">
											<td>
												<input type="text" name="purpose" id="purpose" style="width: 100%;" class="req" />
											</td>
										</tr>
									</tbody>
									<tbody id="purpose_tbody_temp" name="purpose_tbody_temp" style="display:none">
										<tr id="purpose_tmp_tr_1" style="display:none">
											<td>
												<input type="text" name="purpose" id="purpose" style="width: 100%;" class="req" />
											</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">출장기간</th>
							<td colspan="3">
								<input type="text" name="tripStartDate" id="tripStartDate" style="width: 120px;" class="req" />
								&nbsp;~&nbsp;
								<input type="text" name="tripEndDate" id="tripEndDate" style="width: 120px;" class="req" />
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">출장지<span onClick="fn_addCol('destination')">(+)</span></th>
							<td>
								
								<table width="100%" border="0">
									<tbody id="destination_tbody" name="destination_tbody">
										<tr id="destination_tr_1">
											<td>
												<input type="text"  style="width:95%; float: left" class="req" name="tripDestination" id="tripDestination" placeholder=""/>
											</td>
										</tr>
									</tbody>
									<tbody id="destination_tbody_temp" name="destination_tbody_temp" style="display:none">
										<tr id="destination_tmp_tr_1" style="display:none">
											<td>
												<input type="text"  style="width:95%; float: left" class="req" name="tripDestination" id="tripDestination" placeholder=""/>
											</td>
										</tr>
									</tbody>
								</table>
							</td>
							<th style="border-left: none;">경유지</th>
							<td>
								<input type="text"  style="width:95%; float: left" class="req" name="tripTransit" id="tripTransit" placeholder=""/>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">업무수행내용<span onClick="fn_addCol('contents')">(+)</span></th>
							<td colspan="3">
								<table width="100%">
									<tr>
										<td>일정</td>
										<td>세부내용</td>
										<td>장소</td>
										<td>비고</td>
									</tr>
									<tbody id="contents_tbody" name="contents_tbody">
										<tr id="contents_tr_1">
											<td>
												<input type="text" name="schedule" id="schedule" style="width: 100%;" class="req" />
											</td>
											<td>
												<input type="text" name="content" id="content" style="width: 100%;" class="req" />
											</td>
											<td>
												<input type="text" name="place" id="place" style="width: 100%;" class="req" />
											</td>
											<td>
												<input type="text" name="note" id="note" style="width: 100%;" class="req" />
											</td>
										</tr>
									</tbody>
									<tbody id="contents_tbody_temp" name="contents_tbody_temp" style="display:none">
										<tr id="contents_tmp_tr_1" style="display:none">
											<td>
												<input type="text" name="schedule" id="schedule" style="width: 100%;" class="req" />
											</td>
											<td>
												<input type="text" name="content" id="content" style="width: 100%;" class="req" />
											</td>
											<td>
												<input type="text" name="place" id="place" style="width: 100%;" class="req" />
											</td>
											<td>
												<input type="text" name="note" id="note" style="width: 100%;" class="req" />
											</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">예상경비</th>
							<td colspan="3">
								<textarea rows='2' cols="130" name="tripCost" id="tripCost"></textarea>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">산출식</th>
							<td colspan="3">
								<textarea rows='2' cols="130" name="calMethod" id="calMethod"></textarea>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">기대효과</th>
							<td colspan="3">
								<textarea rows='2' cols="130" name="tripEffect" id="tripEffect"></textarea>
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
					<button class="btn_admin_navi">임시저장</button>
					 -->
					<button class="btn_admin_navi" onclick="fn_insertTmp()">임시저장</button> 
					<button class="btn_admin_sky" onclick="fn_insert()">저장</button>
					<button class="btn_admin_gray" onclick="fn_goList()">취소</button>
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
	<input type="hidden" id="docType" value="PLAN"/>
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
			<span class="title">출장계획보고서 결재 상신</span>
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