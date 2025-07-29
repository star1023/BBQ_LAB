<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>  <!-- ✅ 이거 추가 -->
<title>이화학 검사 의뢰서</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 400px; min-height:150px;}

th.contentBlock {
	text-align: center !important;
}
.search_box {
	display: flex;
	align-items: center;   /* 수직 가운데 정렬 */
	justify-content: center; /* 수평 가운데 정렬 */
	height: 100%; /* 높이 지정이 필요할 수 있음 */
}

.ck-editor__editable {
    max-height: 300px;
    min-height: 300px;
}

input:disabled {
	background-color: #f0f0f0;
}
</style>
<link href="../resources/css/common.css" rel="stylesheet" type="text/css" />
<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
const USER_ROLE_CODE = '${userUtil:getRoleCode(pageContext.request)}';
const IS_SAFE_TEAM = (USER_ROLE_CODE === '6' || USER_ROLE_CODE === '7');
	var editor1;
	var editor2;
	$(document).ready(function(){
		$("#requestDate").datepicker({
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
		
		$("#completionDate").datepicker({
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
		
		console.log(IS_SAFE_TEAM);
		
		ClassicEditor
	    .create(document.getElementById("resultContent"), {
	        language: 'ko'
	    })
	    .then(editor => {
	        editor1 = editor;
	        if (!IS_SAFE_TEAM) {
	            editor1.enableReadOnlyMode('lock');
	        }
	    });

		ClassicEditor
	    .create(document.getElementById("requestContents"), {
	        language: 'ko'
	    })
	    .then(editor => {
	        editor2 = editor;
	        if (IS_SAFE_TEAM) {
	            editor2.enableReadOnlyMode('lock');
	        }
	    });
		fn.autoComplete($("#keyword"));
		
		$.ajax({
	        type: "POST",
	        url: "../common/codeListAjax",
	        data: { groupCode: "CHEMICALTEST" },
	        dataType: "json",
	        success: function (data) {
	        	chemicalTestCategory = data.RESULT; // ✅ 전역 변수에 저장
	        	renderChemicalTestTable();
	        },
	        error: function () {
	            alert("브랜드 정보를 불러오는데 실패했습니다.");
	        }
	    });
		
	    if (IS_SAFE_TEAM) {
	        // 모든 input, select, textarea를 비활성화
	        $("input[type='text'], select, textarea").prop("disabled", true);
	        $("input[type='radio'], input[type='checkbox']").prop("disabled", true);
	        // 조회/초기화 버튼도 비활성화
	        $(".btn_small_search").prop("disabled", true);
	        $("#requestDate").datepicker("disable");
	        $("#completionDate").datepicker("disable");
	        // 모든 input, select, textarea를 비활성화
	        $("input[type='text'], select, textarea").prop("disabled", true);
	        $("input[type='radio'], input[type='checkbox']").prop("disabled", true);

	        // 조회/초기화 버튼도 비활성화
	        $(".btn_small_search").prop("disabled", true);

	        // 날짜 선택 막기
	        $("#requestDate").datepicker("disable");
	        $("#completionDate").datepicker("disable");
	    }

	});
	
	var chemicalTestCategory = [];
	const itemList = [
		<c:forEach items="${itemList}" var="item" varStatus="status">
		{
			TYPE_CODE_TEXT: "${item.TYPE_CODE_TEXT}",
			ITEM_IDX: ${item.ITEM_IDX},
			TYPE_CODE: "${item.TYPE_CODE}",
			ITEM_CONTENT: "${item.ITEM_CONTENT}",
			CHEMICAL_IDX: ${item.CHEMICAL_IDX}
		}<c:if test="${!status.last}">,</c:if>
		</c:forEach>
	];
	console.log(itemList);
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
	
	function removeTempFile(fileIdx, element) {
	    // li 삭제
	    $(element).closest('li').remove();

	    // select에 삭제 파일 IDX 추가
	    $('#deletedFileList').append(
	        $('<option>', {
	            value: fileIdx,
	            selected: true
	        })
	    );
	    
	    // tempFileList에서 해당 옵션도 제거
	    $('#tempFileList option').each(function () {
	        if ($(this).val() == fileIdx) {
	            $(this).remove();
	        }
	    });
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
	
	function fn_validateTestRange() {
		let valid = true;

		$("select[id^='testSelect_']").each(function () {
			const idx = $(this).attr("id").split("_")[1];
			const selectedCode = $(this).val();
			const $input = $("input[data-input-index='" + idx + "']");

			if (selectedCode) {
				if (!$input.val().trim()) {
					alert("[" + $(this).find("option:selected").text() + "] 항목의 범위를 입력해주세요.");
					$input.focus();
					valid = false;
					return false;
				}
			}
		});

		return valid;
	}
	
	//입력확인
	function fn_tmp_update(){
		//var standardContent = editor1.getData();
		var requestContent = editor2.getData();
		if( false ) {
		} else if( !chkNull($("#productName").val()) ) {
			alert("시료명을 선택해 주세요.");
			$("#productName").focus();
			return;
		} else {
			var formData = new FormData();
			formData.append("idx",$("#idx").val());
			formData.append("requestDate",$("#requestDate").val());
			formData.append("completionDate",$("#completionDate").val());
			formData.append("requestUser",$("#requestUser").val());
			formData.append("productCode",$("#productCode").val());
			formData.append("productName",$("#productName").val());
			formData.append("sapCode",$("#sapCode").val());
			formData.append("productCount",$("#productCount").val());
			formData.append("ORG_FILE_NAME", $("#orgFileName").val());
			formData.append("FILE_NAME", $("#fileName").val());
			formData.append("FILE_PATH", $("#filePath").val());
			formData.append("imageDeleteFlag",$("#imageDeleteFlag").val());
			//formData.append("preservation", $("input[name='preservation']:checked").val());
			let preservationValues = [];
			$("input[name='preservation']:checked").each(function () {
				preservationValues.push($(this).val());
			});
			formData.append("preservation", preservationValues.join(","));
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
			
			$('#deletedFileList option:selected').each(function() {
			    formData.append('deletedFileList', $(this).val());
			});
			
			const typeCodeArr = [];
			const itemContentArr = [];

			$("select[id^='testSelect_']").each(function () {
				const code = $(this).val();
				const idx = $(this).attr("id").split("_")[1];
				const $input = $("input[data-input-index='" + idx + "']");
				const content = $input.val();

				if (code) {
					typeCodeArr.push(code);
					itemContentArr.push(content || "");
				}
			});
			
			formData.append("typeCodeArr", JSON.stringify(typeCodeArr));
			formData.append("itemContentArr", JSON.stringify(itemContentArr));
			
			// 검사 요청 방법
			var standard1Arr = [];
			$('tr[id^=standard1_tr]').toArray().forEach(function(standard1Row){
				var rowId = $(standard1Row).attr('id'); 
			    var value = $('#' + rowId + ' input[name=standard1]').val();
			    if (value && value.trim() !== "") {
			        standard1Arr.push(value.trim());
			    }
			});
			formData.append("standard1Arr", JSON.stringify(standard1Arr));

			// 검사 진행 일정
			var standard2Arr = [];
			$('tr[id^=standard2_tr]').toArray().forEach(function(standard2Row){
				var rowId = $(standard2Row).attr('id'); 
			    var value = $('#' + rowId + ' input[name=standard2]').val();
			    if (value && value.trim() !== "") {
			        standard2Arr.push(value.trim());
			    }
			});
			formData.append("standard2Arr", JSON.stringify(standard2Arr));

			
			//formData.append("standardContent",standardContent);
			formData.append("requestContent",requestContent);
			formData.append("docType", $("#docType").val())
			
			
			// 이미지 파일
			var imageFile = document.getElementById('fileImageInput').files[0];
			if (imageFile) {
			  formData.append("imageFile", imageFile); // name="imageFile"
			}
			
			for (let pair of formData.entries()) {
				console.log(pair[0] + ':', pair[1]);
			}
			
			$('#lab_loading').show();
			var URL = "../chemicalTest/updateChemicalTestAjax";
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
							if( $("#apprLine option").length > 0 ) {
								var apprFormData = new FormData();
								apprFormData.append("docIdx", result.IDX );
								apprFormData.append("apprComment", $("#apprComment").val());
								apprFormData.append("apprLine", $("#apprLine").selectedValues());
								apprFormData.append("refLine", $("#refLine").selectedValues());
								apprFormData.append("title", $("#productName").val()+" 이화학검사의뢰서");
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
											alert("결재상신 오류가 발생하였습니다."+data.MESSAGE);
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
								alert("시료명 "+$("#productName").val()+"의 이화학 검사 의뢰서가 정상적으로 생성되었습니다.");
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
	//입력확인
	function fn_update(){
		//var standardContent = editor1.getData();
		var requestContent = editor2.getData();
		if( false ) {
		} else if( !chkNull($("#requestDate").val()) ) {
			alert("완료일자를 선택해 주세요.");
			$("#requestDate").focus();
			return;
		} else if( !chkNull($("#completionDate").val()) ) {
			alert("희망 완료일을 선택해 주세요.");
			$("#completionDate").focus();
			return;
		} else if( !chkNull($("#requestUser").val()) ) {
			alert("의뢰자를 입력해 주세요ㅕ.");
			$("#requestUser").focus();
			return;
		} else if( !chkNull($("#productName").val()) ) {
			alert("시료명을 선택해 주세요.");
			$("#productName").focus();
			return;
		} else if( !chkNull($("#productCount").val()) ) {
			alert("시료수량을 입력해 주세요.");
			$("#productCount").focus();
			return;
		} else if ($("select[id^='testSelect_']").filter(function() { return $(this).val(); }).length === 0) {
			alert("검사요청 항목은 한개 이상 선택되어야 합니다.");
			$("select[id^='testSelect_']").first().focus();
			return;
		} else if ($("tr[id^='standard1_tr'] input[name='standard1']").filter(function() { return $(this).val().trim() !== ""; }).length === 0) {
			alert("검사 요청 방법을 하나 이상 입력해 주세요.");
			$("tr[id^='standard1_tr'] input[name='standard1']").first().focus();
			return;
		} else if ($("tr[id^='standard2_tr'] input[name='standard2']").filter(function() { return $(this).val().trim() !== ""; }).length === 0) {
			alert("검사 진행 일정을 하나 이상 입력해 주세요.");
			$("tr[id^='standard2_tr'] input[name='standard2']").first().focus();
			return;
		} else if( !fn_validateTestRange() ) {
			return;
		} else if( attatchFileArr.length == 0 && $("#tempFileList option").length == 0 ) {
			alert("첨부파일을 등록해주세요.");		
			return;		
		} else {	
			var formData = new FormData();
			formData.append("idx",$("#idx").val());
			formData.append("requestDate",$("#requestDate").val());
			formData.append("completionDate",$("#completionDate").val());
			formData.append("requestUser",$("#requestUser").val());
			formData.append("productCode",$("#productCode").val());
			formData.append("productName",$("#productName").val());
			formData.append("sapCode",$("#sapCode").val());
			formData.append("productCount",$("#productCount").val());
			formData.append("ORG_FILE_NAME", $("#orgFileName").val());
			formData.append("FILE_NAME", $("#fileName").val());
			formData.append("FILE_PATH", $("#filePath").val());
			formData.append("imageDeleteFlag",$("#imageDeleteFlag").val());
			//formData.append("preservation", $("input[name='preservation']:checked").val());
			let preservationValues = [];
			$("input[name='preservation']:checked").each(function () {
				preservationValues.push($(this).val());
			});
			formData.append("preservation", preservationValues.join(","));
			formData.append("status", "COMP");
			
			for (var i = 0; i < attatchFileArr.length; i++) {
				formData.append('file', attatchFileArr[i])
			}
			
			for (var i = 0; i < attatchFileTypeArr.length; i++) {
				formData.append('fileTypeText', attatchFileTypeArr[i].fileTypeText)			
			}
			
			for (var i = 0; i < attatchFileTypeArr.length; i++) {
				formData.append('fileType', attatchFileTypeArr[i].fileType)			
			}
			
			$('#deletedFileList option:selected').each(function() {
			    formData.append('deletedFileList', $(this).val());
			});
			
			const typeCodeArr = [];
			const itemContentArr = [];

			$("select[id^='testSelect_']").each(function () {
				const code = $(this).val();
				const idx = $(this).attr("id").split("_")[1];
				const $input = $("input[data-input-index='" + idx + "']");
				const content = $input.val();

				if (code) {
					typeCodeArr.push(code);
					itemContentArr.push(content || "");
				}
			});
			
			formData.append("typeCodeArr", JSON.stringify(typeCodeArr));
			formData.append("itemContentArr", JSON.stringify(itemContentArr));
			
			// 검사 요청 방법
			var standard1Arr = [];
			$('tr[id^=standard1_tr]').toArray().forEach(function(standard1Row){
				var rowId = $(standard1Row).attr('id'); 
			    var value = $('#' + rowId + ' input[name=standard1]').val();
			    if (value && value.trim() !== "") {
			        standard1Arr.push(value.trim());
			    }
			});
			formData.append("standard1Arr", JSON.stringify(standard1Arr));

			// 검사 진행 일정
			var standard2Arr = [];
			$('tr[id^=standard2_tr]').toArray().forEach(function(standard2Row){
				var rowId = $(standard2Row).attr('id'); 
			    var value = $('#' + rowId + ' input[name=standard2]').val();
			    if (value && value.trim() !== "") {
			        standard2Arr.push(value.trim());
			    }
			});
			formData.append("standard2Arr", JSON.stringify(standard2Arr));

			
			//formData.append("standardContent",standardContent);
			formData.append("requestContent",requestContent);
			formData.append("docType", $("#docType").val())
			
			
			// 이미지 파일
			var imageFile = document.getElementById('fileImageInput').files[0];
			if (imageFile) {
			  formData.append("imageFile", imageFile); // name="imageFile"
			}
			
			for (let pair of formData.entries()) {
				console.log(pair[0] + ':', pair[1]);
			}
			
			$('#lab_loading').show();
			var URL = "../chemicalTest/updateChemicalTestAjax";
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
							if( $("#apprLine option").length > 0 ) {
								var apprFormData = new FormData();
								apprFormData.append("docIdx", result.IDX );
								apprFormData.append("apprComment", $("#apprComment").val());
								apprFormData.append("apprLine", $("#apprLine").selectedValues());
								apprFormData.append("refLine", $("#refLine").selectedValues());
								apprFormData.append("title", $("#productName").val()+" 이화학검사의뢰서");
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
											alert("결재상신 오류가 발생하였습니다."+data.MESSAGE);
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
								alert("시료명 "+$("#productName").val()+"의 이화학 검사 의뢰서가 정상적으로 생성되었습니다.");
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
		location.href = '/chemicalTest/list';
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
	
	function fn_closeSearch() {
		closeDialog('dialog_search');
		$("#searchValue").val("");
		$("#searchCategory1").removeOption(/./);
		$("#searchCategory2").removeOption(/./);
		$("#searchCategory2_div").hide();
		$("#searchCategory3").removeOption(/./);
		$("#searchCategory3_div").hide();
		$("#productLayerBody").html("<tr><td colspan=\"4\">검색해주세요</td></tr>");
	}
	
	function fn_search() {
		var URL = "../chemicalTest/searchChemicalTestAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				searchValue : $("#searchValue").val()
			},
			dataType:"json",
			success:function(result) {
				console.log(result);
				//productLayerBody
				var jsonData = {};
				jsonData = result;
				$('#productLayerBody').empty();
				if( jsonData.length == 0 ) {
					var html = "";
					$("#productLayerBody").html(html);
					html += "<tr><td align='center' colspan='5'>데이터가 없습니다.</td></tr>";
					$("#productLayerBody").html(html);
				} else {
					jsonData.forEach(function(item){
						var row = '<tr onClick="fn_copy(\''+item.CHEMICAL_IDX+'\')">';
						row += '<td></td>';
						row += '<td class="tgnl">'+item.PRODUCT_NAME+'</td>';
						row += '<td>'+item.REQUEST_DATE+'</td>';
						row += '<td>'+item.COMPLETION_DATE+'</td>';
						row += '<td>'+item.REQUEST_USER+'</td>';
						row += '</tr>';
						$('#productLayerBody').append(row);
					})
				}
			},
			error:function(request, status, errorThrown){
				var html = "";
				$("#productLayerBody").html(html);
				html += "<tr><td align='center' colspan='5'>오류가 발생하였습니다.</td></tr>";
				$("#productLayerBody").html(html);
			}			
		});
	}
	
	function openMaterialPopup(element,type){
		var parentRowId = $(element).parent().parent('tr')[0].id;
		$('#targetID').val(parentRowId);
		openDialog('dialog_material');
		
		var matCode = $(element).prev().val();
		console.log("matCode : "+matCode);
		$('#searchMatValue').val(matCode);
		$('#itemType').val(itemType);
		$('#searchType').val(type);
		searchMaterial('',type);
	}
	
	function searchMaterial(pageType,type){
		var pageType = pageType;
		var searchType = type;
		if(!pageType)
			$('#matLayerPage').val(1);
		
		if(!searchType)
			searchType = $('#searchType').val();
			
		if(pageType == 'nextPage'){
			var totalCount = Number($('#matCount').text());
			var maxPage = totalCount/10+1;
			var nextPage = Number($('#matLayerPage').val())+1;
			
			if(nextPage >= maxPage) return; //nextPage = maxPage
			
			$('#matLayerPage').val(nextPage);
		}
			
		if(pageType == 'prevPage'){
			var prevPage = Number($('#matLayerPage').val())-1;
			if(prevPage <= 0) return; //prevPage = 1;
			
			$('#matLayerPage').val(prevPage);
		}
			
		$('#lab_loading').show();
		console.log("searchMatValue  :  "+$('#searchMatValue').val());
		
		var URL = '/menu/selectMaterialAjax';
		if( searchType == 'mat' ) {
			URL = '/test/selectErpMaterialListAjax';
		}
		
		$.ajax({
			url: URL,
			type: 'post',
			dataType: 'json',
			data: {
				"searchValue": $('#searchMatValue').val(),
				"pageNo": $('#matLayerPage').val()
			},
			success: function(data){
				var jsonData = {};
				jsonData = data;
				$('#matLayerBody').empty();
				$('#matLayerBody').append('<input type="hidden" id="matLayerPage" value="'+data.pageNo+'"/>');
				
				jsonData.list.forEach(function(item){
					
					var row = '<tr onClick="setMaterialPopupData(\''+$('#targetID').val()+'\', \''+item.MATERIAL_IDX+'\', \''+nvl(item.MATERIAL_CODE,'')+'\', \''+nvl(item.SAP_CODE,'')+'\', \''+item.NAME+'\', \''+item.PRICE+'\', \''+item.UNIT+'\', \''+item.STANDARD+'\', \''+item.KEEP_CONDITION+'\', \''+item.EXPIRATION_DATE+'\')">';
					//parentRowId, itemImNo, itemSAPCode, itemName, itemUnitPrice
					row += '<td></td>';
					//row += '<Td>'+item.companyCode+'('+item.plant+')'+'</Td>';\
					row += '<Td>'+nvl(item.MATERIAL_CODE,'')+'</Td>';
					row += '<Td>'+nvl(item.SAP_CODE,'')+'</Td>';
					row += '<Td  class="tgnl">'+item.NAME+'</Td>';
					row += '<Td>'+nvl(item.KEEP_CONDITION,'')+'</Td>';
					row += '<Td>'+nvl(item.WIDTH,'')+'/'+nvl(item.LENGTH,'')+'/'+nvl(item.HEIGHT,'')+'</Td>';
					row += '<Td>'+nvl(item.TOTAL_WEIGHT,'')+'('+nvl(item.TOTAL_WEIGHT_UNIT,'')+')'+'</Td>';
					row += '<Td class="tgnl">'+nvl(item.STANDARD,'')+'</Td>';
					row += '<Td>'+nvl(item.ORIGIN,'') +'</Td>';
					row += '<Td>'+nvl(item.EXPIRATION_DATE,'')+'</Td>';
					
					row += '</tr>';
					$('#matLayerBody').append(row);
				})
				$('#matCount').text(jsonData.totalCount)
				
				var isFirst = $('#matLayerPage').val() == 1 ? true : false;
				var isLast = parseInt(jsonData.totalCount/10+1) == Number($('#matLayerPage').val()) ? true : false;
				
				if(isFirst){
					$('#matNextPrevDiv').children('button:first').attr('class', 'btn_code_left01');
				} else {
					$('#matNextPrevDiv').children('button:first').attr('class', 'btn_code_left02');
				}
				
				if(isLast){
					$('#matNextPrevDiv').children('button:last').attr('class', 'btn_code_right01');
				} else {
					$('#matNextPrevDiv').children('button:last').attr('class', 'btn_code_right02');
				}
			},
			error: function(a,b,c){
				//console.log(a,b,c);
				alert('자재검색 실패[2] - 시스템 담당자에게 문의하세요');
			},
			complete: function(){
				$('#lab_loading').hide();
			}
		})
	}
	
	function fn_closeErpMatRayer(){
		$('#searchErpMatValue').val('')
		$('#erpMatLayerBody').empty();
		$('#erpMatLayerBody').append('<tr><td colspan="10">원료코드 혹은 원료코드명을 검색해주세요</td></tr>');
		$('#erpMatCount').text(0);
		closeDialog('dialog_erpMaterial');
	}

	function fn_searchErpMaterial(pageType) {
		var pageType = pageType;
		console.log(pageType);
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
			url: '/test/selectErpMaterialListAjax',
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
					
					var row = '<tr onClick="fn_setMaterialPopupData(\''+item.SAP_CODE+'\', \''+item.NAME+'\', \''+item.KEEP_CONDITION+'\', \''+item.WIDTH+'\', \''+item.LENGTH+'\', \''+item.HEIGHT+'\', \''+item.TOTAL_WEIGHT+'\', \''+item.STANDARD+'\', \''+item.ORIGIN+'\', \''+item.EXPIRATION_DATE+'\')">';
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
				//console.log(a,b,c);
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
	
	function fn_setMaterialPopupData(SAP_CODE, NAME, KEEP_CONDITION, WIDTH, LENGTH, HEIGHT, TOTAL_WEIGHT, STANDARD, ORIGIN, EXPIRATION_DATE) {
		$("#productName").val(NAME);
		// PRODUCT_CODE 수정 필요함
		$("#productCode").val('');
		$("#sapCode").val(SAP_CODE);
		$("#isSample").val("N");
		//$("#keepCondition").val(KEEP_CONDITION);
		//$("#width").val(WIDTH);
		//$("#length").val(LENGTH);
		//$("#height").val(HEIGHT);
		//$("#weight").val(TOTAL_WEIGHT);
		//$("#standard").val(STANDARD);
		//$("#origin").val(ORIGIN);
		//$("#expireDate").val(EXPIRATION_DATE);
		fn_closeErpMatRayer();
	}
	function fn_initForm() {
		$("#productName").val("");
		$("#productCode").val("");
		$("#sapCode").val("");
		$("#isSample").val("");
		//$("#keepCondition").val("");
		//$("#weight").val("");
		//$("#standard").val("");
		//$("#expireDate").val("");
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
		}
	}
	function fn_deleteImageFile(element, e) {
	    const preview = document.getElementById('preview');
	    const fileInput = document.getElementById('fileImageInput');

	    if (preview) preview.src = "/resources/images/img_noimg3.png";
	    if (fileInput) fileInput.value = "";

	    // 삭제 플래그 설정
	    document.getElementById("imageDeleteFlag").value = "Y";
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
	
	function renderChemicalTestTable() {
	    const $tbody = $("#testItemsTbody");
	    $tbody.empty();
	    globalChemicalIndex = 0;

	    const safeItemList = Array.isArray(itemList) ? itemList : [];
	    const chunkSize = 4;
	    const totalItems = Math.max(chunkSize, safeItemList.length);
	    const rowCount = Math.ceil(totalItems / chunkSize);

	    for (let i = 0; i < rowCount; i++) {
	        const $trCheck = $("<tr>").addClass("checkRow").css("height", "60px");
	        const $trRange = $("<tr>").addClass("rangeRow").css("height", "60px");
	        const $trResult = $("<tr>").addClass("resultRow").css("height", "60px");

	        $trCheck.append(
	            $("<th></th>").addClass("contentBlock").css("border-left", "none").text("검사요청 항목")
	        );
	        $trRange.append(
	            $("<th></th>").addClass("contentBlock").css("border-left", "none").html("범위<br>(시료의 대략적인 범위 기재)")
	        );
	        $trResult.append(
	            $("<th></th>").addClass("contentBlock").css("border-left", "none").html("검사 결과<br>(식품안전팀 기입)")
	        );

	        for (let j = 0; j < chunkSize; j++) {
	            if (globalChemicalIndex >= chemicalTestCategory.length) {
	                $trCheck.append($("<td></td>"));
	                $trRange.append($("<td></td>"));
	                $trResult.append($("<td></td>"));
	                continue;
	            }

	            const item = chemicalTestCategory[globalChemicalIndex];
	            const idx = globalChemicalIndex++;

	            const selectId = "testSelect_" + idx;
	            const inputId = "itemContent_" + idx;
	            const resultInputId = "itemResult_" + idx;

	            // 검사 항목 select
	            const $select = $("<select></select>")
	                .attr("name", selectId)
	                .attr("id", selectId)
	                .css("width", "90%")
	                .prop("disabled", IS_SAFE_TEAM); // 일반 사용자만 선택 가능

	            $select.append($("<option></option>").val("").text("--선택--").prop("selected", true));
	            $.each(chemicalTestCategory, function (k, opt) {
	                $select.append($("<option></option>").val(opt.itemCode).text(opt.itemName));
	            });

	            const $searchBox = $("<div></div>").addClass("search_box").append($select);
	            $trCheck.append($("<td></td>").append($searchBox));

	            // 범위 input
	            const $input = $("<input>")
	                .attr("type", "text")
	                .attr("id", inputId)
	                .attr("placeholder", "")
	                .attr("data-input-index", idx)
	                .css("width", "95%")
	                .prop("disabled", IS_SAFE_TEAM); // 일반 사용자만 입력 가능
	            $trRange.append($("<td></td>").append($input));

	            // 검사 결과 input
	            const $resultInput = $("<input>")
	                .attr("type", "text")
	                .attr("id", resultInputId)
	                .attr("placeholder", "")
	                .attr("data-result-index", idx)
	                .css("width", "95%")
	                .prop("disabled", !IS_SAFE_TEAM); // 안전팀만 입력 가능
	            $trResult.append($("<td></td>").append($resultInput));
	        }

	        $tbody.append($trCheck).append($trRange).append($trResult);
	    }

	    // 초기값 세팅
	    $("select[id^='testSelect_']").each(function () {
	        const $select = $(this);
	        const idx = $select.attr("id").split("_")[1];
	        const $input = $("input[data-input-index='" + idx + "']");
	        const $resultInput = $("input[data-result-index='" + idx + "']");

	        const item = safeItemList[idx];
	        if (item) {
	            $select.val(item.TYPE_CODE);
	            $input.val(item.ITEM_CONTENT);
	            $resultInput.val(item.ITEM_RESULT);
	            $resultInput.attr("data-item-idx", item.ITEM_IDX);
	        }

	        // 권한에 따라 다시 disabled 설정 (초기값 세팅 후 변경 방지용)
	        $select.prop("disabled", IS_SAFE_TEAM);
	        // ✅ 셀렉트가 비어있으면 무조건 비활성화
	        if (!$select.val()) {
	            $input.prop("disabled", true).val("").attr("placeholder", "").removeAttr("name");
	        } else {
	            $input.prop("disabled", IS_SAFE_TEAM);
	        }
	        $resultInput.prop("disabled", !IS_SAFE_TEAM);

	        $select.data("prev", $select.val());
	    });

	    bindChemicalTestSelectEvents();
	}
	
	let globalChemicalIndex = 0;  // 전역 변수

	function addChemicalTestColumn() {
		const $tbody = $("#testItemsTbody");
		let $checkRow = $tbody.find("tr.checkRow").last();
		let $rangeRow = $tbody.find("tr.rangeRow").last();
		let $resultRow = $tbody.find("tr.resultRow").last();

		const totalCount = $("select[id^='testSelect_']").length;
		if (totalCount >= chemicalTestCategory.length) {
			alert("더 이상 추가할 수 없습니다.");
			return;
		}

		const idx = globalChemicalIndex++;
		const item = chemicalTestCategory[totalCount];

		// 필요한 tr 생성
		if ($checkRow.find("td").length >= 4 || $checkRow.length === 0 || $rangeRow.length === 0 || $resultRow.length === 0) {
			$checkRow = $("<tr class='checkRow' style='height:60px; border-top: 2px solid #aaaaaa;'></tr>");
			$rangeRow = $("<tr class='rangeRow' style='height:60px;'></tr>");
			$resultRow = $("<tr class='resultRow' style='height:60px;'></tr>");

			$checkRow.append($("<th class='contentBlock' style='border-left:none;'>검사요청 항목</th>"));
			$rangeRow.append($("<th class='contentBlock' style='border-left:none;'>범위<br>(시료의 대략적인 범위 기재)</th>"));
			$resultRow.append($("<th class='contentBlock' style='border-left:none;'>검사 결과<br>(식품안전팀 기입)</th>"));

			$tbody.append($checkRow).append($rangeRow).append($resultRow);
		}

		const selectId = "testSelect_" + idx;
		const inputId = "itemContent_" + idx;
		const resultId = "resultInput_" + idx;

		const $select = $("<select></select>")
			.attr("name", selectId)
			.attr("id", selectId)
			.css("width", "90%");
		$select.append($("<option></option>").val("").text("--선택--").prop("selected", true));

		$.each(chemicalTestCategory, function (i, opt) {
			$select.append($("<option></option>").val(opt.itemCode).text(opt.itemName));
		});

		const $input = $("<input>")
			.attr("type", "text")
			.attr("id", inputId)
			.attr("data-input-index", idx)
			.attr("placeholder", "")
			.css("width", "95%")
			.prop("disabled", true);

		const $resultInput = $("<input>")
			.attr("type", "text")
			.attr("id", resultId)
			.attr("name", resultId)
			.css("width", "95%")
			.prop("disabled", true);  // 비활성화 처리

		$checkRow.append($("<td></td>").append($("<div></div>").addClass("search_box").append($select)));
		$rangeRow.append($("<td></td>").append($input));
		$resultRow.append($("<td></td>").append($resultInput));

		bindChemicalTestSelectEvents();
	}
	
	function deleteChemicalTestColumn() {
		const $tbody = $("#testItemsTbody");

		let $checkRow = $tbody.find("tr.checkRow").last();
		let $rangeRow = $tbody.find("tr.rangeRow").last();
		let $resultRow = $tbody.find("tr.resultRow").last();

		const checkRowCount = $tbody.find("tr.checkRow").length;
		const checkTdCount = $checkRow.find("td").length;

		// ✅ 마지막 한 줄이고 td가 정확히 4개면 삭제 불가 (보호)
		if (checkRowCount === 1 && checkTdCount === 4) {
			alert("더 이상 칸을 삭제할 수 없습니다.");
			return;
		}

		// 마지막 열(td) 제거
		$checkRow.find("td").last().remove();
		$rangeRow.find("td").last().remove();
		$resultRow.find("td").last().remove();

		// 열이 모두 제거되면 행 자체도 제거
		if ($checkRow.find("td").length === 0) {
			$checkRow.remove();
			$rangeRow.remove();
			$resultRow.remove();
		}

		if (globalChemicalIndex > 0) globalChemicalIndex--;

		bindChemicalTestSelectEvents();
	}
	
	function bindChemicalTestSelectEvents() {
		$("select[id^='testSelect_']").off("change").on("change", function () {
			const $select = $(this);
			const selectedCode = $select.val(); // ex: "PH"
			const idx = $select.attr("id").split("_")[1];
			const $input = $("input[data-input-index='" + idx + "']");

			const prevVal = $select.data("prev") || "";

			// 중복 검사 (자기 제외)
			let isDuplicate = false;
			$("select[id^='testSelect_']").not($select).each(function () {
				if ($(this).val() === selectedCode && selectedCode !== "") {
					isDuplicate = true;
					return false;
				}
			});

			if (isDuplicate) {
				alert("이미 선택된 항목입니다.");
				// 선택 복원
				$select.val(prevVal);

				// 🔁 input도 상태 복원
				if (prevVal) {
					const prevText = chemicalTestCategory.find(item => item.itemCode === prevVal)?.itemName || "";
					$input.prop("disabled", false)
					      .attr("placeholder", prevText)
					      .attr("name", "itemContent_" + prevVal);
				} else {
					$input.prop("disabled", true).val("").attr("placeholder", "").removeAttr("name");
				}
				return;
			}

			// 정상 선택된 경우
			$select.data("prev", selectedCode);

			if (selectedCode) {
				const selectedName = chemicalTestCategory.find(item => item.itemCode === selectedCode)?.itemName || "";
				$input.prop("disabled", false)
				      .attr("placeholder", selectedName)
				      .attr("name", "itemContent_" + selectedCode);
			} else {
				// --선택-- 상태로 바꿨을 때
				$input.prop("disabled", true).val("").attr("placeholder", "").removeAttr("name");
			}
		});
	}
	
	function fn_safeTeamUpdate() {
		$('#lab_loading').show();
	    const idx = $("#idx").val();
	    const testResult = editor1.getData();
	    const itemList = [];

	    if (IS_SAFE_TEAM) {
	        let hasEmptyResult = false;

	        // 검사 요청 항목 결과 누락 여부 확인
	        $("input[data-result-index]").each(function () {
			    const resultIndex = $(this).data("result-index");
			    const resultValue = $(this).val().trim();
			
			    const typeCode = $('#testSelect_' + resultIndex).val();
			
			    // 검사 항목 선택 안된 경우는 제외
			    if (!typeCode || typeCode === "" || typeCode === "--선택--") {
			        return; // 검사 대상에서 제외
			    }
			
			    // 검사 항목이 선택되었는데 결과값이 비어있는 경우
			    if (resultValue === "") {
			        hasEmptyResult = true;
			    }
			});

	        if (hasEmptyResult) {
	            alert("검사요청 항목에 대한 결과를 입력 해주세요.");
	            $('#lab_loading').hide();
	            return;
	        }

	        // 에디터 검사 결과 입력 확인
	        if (testResult === "" || testResult === "<p>&nbsp;</p>" || testResult === "<p></p>") {
	            alert("검사 결과 내용을 입력 해주세요.");
	            $('#lab_loading').hide();
	            return;
	        }
	    }

	    $("input[data-result-index]").each(function () {
	        const resultIndex = $(this).data("result-index");
	        const resultValue = $(this).val();
	        const typeCode = $("#testSelect_" + resultIndex).val();
	        const itemIdx = $(this).data("item-idx"); // 여기서 추출
			
	        if (typeCode && itemIdx) {
	            itemList.push({
	                itemIdx: itemIdx,
	                itemResult: resultValue
	            });
	        }
	    });
		
	    $.ajax({
	        type: "POST",
	        url: "/chemicalTest/updateSafeResult",
	        contentType: "application/json",
	        data: JSON.stringify({
	            idx: idx,
	            testResult: testResult,
	            itemList: itemList
	        }),
	        success: function (res) {
	            if (res.RESULT === "S") {
	                alert("검사 결과가 저장되었습니다.");
	                fn_goList();
	            } else {
	                alert("저장에 실패했습니다.\n" + res.MESSAGE);
	            }
	            $('#lab_loading').hide();
	        },
	        error: function () {
	            alert("서버와 통신 중 오류가 발생했습니다.");
	            $('#lab_loading').hide();
	        }
	    });
	}
	
	function fn_previewDataBinding(popup) {
	    const $doc = popup.document;
	    $doc.title = document.getElementById("productName").value+'_이화학 검사 의로서'
	    // 기본 항목
	    $doc.getElementById("prev_requestDate").innerText = document.getElementById("requestDate").value;
	    $doc.getElementById("prev_completionDate").innerText = document.getElementById("completionDate").value;
	    $doc.getElementById("prev_requestUser").innerText = document.getElementById("requestUser").value;
	    $doc.getElementById("prev_productCount").innerText = document.getElementById("productCount").value;
	    $doc.getElementById("prev_productName").innerText = document.getElementById("productName").value;
	    
	    // 보관 방법
	    const preservationLabels = [];

		document.querySelectorAll("input[name='preservation']:checked").forEach(chk => {
		    preservationLabels.push(chk.value);
		});
		
		$doc.getElementById("prev_preservation").innerText = preservationLabels.join(", ");
		
		// 요청 항목 & 범위 & 결과
		// prev_preservation 이 있는 td 의 부모 tr 다음에 삽입
		var $preserveRow = $doc.getElementById("prev_preservation").parentElement;
		var $tbody = $preserveRow.parentElement;
		
		var chunkSize = 4;
		var itemCount = document.querySelectorAll("#testItemsTbody select[id^='testSelect_']").length;
		const itemList = [];
		
		const $selectList = document.querySelectorAll("#testItemsTbody select[id^='testSelect_']");
		
		$selectList.forEach(select => {
		    const idx = select.id.replace("testSelect_", "");
		    const contentInput = document.getElementById("itemContent_" + idx);
		    const resultInput = document.getElementById("itemResult_" + idx);
		
		    const item = {
		        TYPE_CODE_TEXT: select?.options[select.selectedIndex]?.text || "",
		        ITEM_CONTENT: contentInput?.value || "",
		        ITEM_RESULT: resultInput?.value || ""
		    };
		
		    if (item.TYPE_CODE_TEXT === "--선택--") return;
		
		    itemList.push(item);
		});
		
		var rowCount = Math.ceil(itemList.length / chunkSize);
		var htmlList = [];
		
		for (var row = 0; row < rowCount; row++) {
		    var start = row * chunkSize;
		    var end = Math.min(start + chunkSize, itemList.length);
		
		    var row1 = "<tr><th style='width: 10%; text-align: center; font-weight: bold;'>검사요청 항목</th>";
		    row1 += "<td colspan='5' style='padding: 0;'><table style='width: 100%; table-layout: fixed; border-collapse: collapse;'><tr>";
		
		    var row2 = "<tr><th style='width: 10%; text-align: center; font-weight: bold;'>범위</th>";
		    row2 += "<td colspan='5' style='padding: 0;'><table style='width: 100%; table-layout: fixed; border-collapse: collapse;'><tr>";
		
		    var row3 = "<tr><th style='width: 10%; text-align: center; font-weight: bold;'>검사 결과</th>";
		    row3 += "<td colspan='5' style='padding: 0;'><table style='width: 100%; table-layout: fixed; border-collapse: collapse;'><tr>";
		
		    for (var i = start; i < end; i++) {
		        var item = itemList[i];
		        row1 += "<th style='width: 25%; text-align: center;'>" + item.TYPE_CODE_TEXT + "</th>";
		        row2 += "<td style='width: 25%; text-align: center;'>" + item.ITEM_CONTENT + "</td>";
		        row3 += "<td style='width: 25%; text-align: center; border: 1px solid #ccc;'>" + (item.ITEM_RESULT || "&nbsp;") + "</td>";
		    }
		
		    var blank = chunkSize - (end - start);
		    for (var b = 0; b < blank; b++) {
		        row1 += "<th style='width: 25%;'></th>";
		        row2 += "<td style='width: 25%;'></td>";
		        row3 += "<td style='width: 25%; border: 1px solid #ccc;'>&nbsp;</td>";
		    }
		
		    row1 += "</tr></table></td></tr>";
		    row2 += "</tr></table></td></tr>";
		    row3 += "</tr></table></td></tr>";
		
		    htmlList.push(row1, row2, row3);
		}
		
		// 정방향으로 삽입
		for (let i = htmlList.length - 1; i >= 0; i--) {
		    $preserveRow.insertAdjacentHTML("afterend", htmlList[i]);
		}


		// 검사 요청 방법
		var reasonHTML1 = "";
		document.querySelectorAll('#standard1_tbody input[name=standard1]').forEach(function(input) {
		    var val = input.value || "";
		    if (val.trim()) reasonHTML1 += val + "<br/>";
		});
		$doc.getElementById("prev_standard1").innerHTML = reasonHTML1;

		// 검사 진행 일정
		var reasonHTML2 = "";
		document.querySelectorAll('#standard2_tbody input[name=standard2]').forEach(function(input) {
		    var val = input.value || "";
		    if (val.trim()) reasonHTML2 += val + "<br/>";
		});
		$doc.getElementById("prev_standard2").innerHTML = reasonHTML2;
	    
	    // 요청 사항
	    var content = editor2.getData().trim();
	    $doc.getElementById("prev_content").innerHTML = content

	 	// ✅ 시료 이미지 처리
	    var fileInput = document.getElementById("fileImageInput");
	    var previewImgContainer = $doc.getElementById("prev_previewImg"); // <td> 자체

	    // 이미지 엘리먼트 생성
	    var img = $doc.createElement("img");
	    img.style.width = "100%";
	    img.style.maxWidth = "220px";
	    img.style.height = "auto";
	    img.style.border = "1px solid #e1e1e1";
	    img.style.borderRadius = "5px";
	    img.style.objectFit = "contain";

	    // 이미지 삽입
	    previewImgContainer.innerHTML = ""; // 혹시 기존에 있을 수도 있으니 초기화
	    previewImgContainer.appendChild(img);

	    // 이미지 소스 지정
	    if (fileInput && fileInput.files && fileInput.files[0]) {
	        var reader = new FileReader();
	        reader.onload = function (e) {
	            img.src = e.target.result;
	        };
	        reader.readAsDataURL(fileInput.files[0]);
	    } else {
	        var originPreviewImg = document.getElementById("preview"); // 기존 이미지
	        if (originPreviewImg && originPreviewImg.src) {
	            img.src = originPreviewImg.src;
	        } else {
	            img.src = "/resources/images/img_noimg3.png"; // fallback
	        }
	    }


	}
	
	function fn_openPreview() {
		var url = "/preview/chemicalTestPrevPopup";

		// 팝업 창 열기
		var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes");

		// 팝업이 완전히 열린 뒤에 데이터 전달
		popup.onload = function () {
			// 여기서 fn_openPreview() 호출해서 팝업 DOM에 값 세팅
			fn_previewDataBinding(popup);
		};
	}
</script>
<c:set var="isSafeTeam" value="${userUtil:getRoleCode(pageContext.request) == '6' || userUtil:getRoleCode(pageContext.request) == '7'}" />
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
						<c:if test="${isSafeTeam}">
							<button class="btn_circle_save" onclick="fn_safeTeamUpdate()">&nbsp;</button>
						</c:if>
						<c:if test="${not isSafeTeam}">
							<button class="btn_circle_save" onclick="fn_update()">&nbsp;</button>
						</c:if>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title2"  style="display: flex; justify-content:space-between; width: 100%;">
				<span class="txt">개요</span>
				<div class="pr15">
					<c:if test="${chemicalTestData.data.DOC_OWNER eq userId}">
						<button class="btn_small_search" onclick="fn_openPreview()">미리보기</button>
					</c:if>
				</div>
			</div>
			<div class="main_tbl">
				<table class="insert_proc01">
					<colgroup>
						<col width="10%" />
						<col width="28%" />
						<col width="12%" />
						<col width="22%" />
						<col width="12%" />
						<col width="8%" />
					</colgroup>
					<tbody>
						<tr>
							<th style="border-left: none;">의뢰일자</th>
							<td>
								<input type="hidden" name="idx" id="idx" value="${chemicalTestData.data.CHEMICAL_IDX}">
								<input type="text" name="requestDate" id="requestDate" class="req" value="${chemicalTestData.data.REQUEST_DATE}"/>								
							</td>
							<th style="border-left: none;">희망 완료일</th>
							<td>
								<input type="text" name="completionDate" id="completionDate" class="req" value="${chemicalTestData.data.COMPLETION_DATE}"/>
							</td>
							<th style="border-left: none; width:120px;">의뢰자</th>
							<td>
								<input type="text" name="requestUser" id="requestUser" class="req" value="${chemicalTestData.data.REQUEST_USER}"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<div class="title2"  style="width: 80%; margin-top:10px;"><span class="txt">내용</span></div>
			<div class="title2" style="width: 20%; display: inline-block;">
				
			 </div>
			<div class="main_tbl">
				<table class="insert_proc01" >
					<colgroup>
						<col width="8%" />
						<col width="22%" />
						<col width="9%" />
						<col width="18%" />
						<col width="10%" />
						<col width="12%" />
					</colgroup>
					<tbody >
						<tr style="height:80px;">
							<th style="border-left: none;" class="contentBlock">시료명</th>
							<td >
								<input type="text"  style="float: left; display: none;" class="req" name="productCode" id="productCode" value="${chemicalTestData.data.PRODUCT_CODE}" placeholder="코드를 조회 하세요." readonly/>
								<input type="text"  style="float: left; display: none;" class="req" name="sapCode" id="sapCode" value="${chemicalTestData.data.SAP_CODE}" placeholder="코드를 조회 하세요." readonly/>
								<input type="text"  style="float: left" class="req" name="productName" id="productName" value="${chemicalTestData.data.PRODUCT_NAME}" placeholder="코드를 조회 하세요." />
								<button class="btn_small_search ml5" onclick="openDialog('dialog_erpMaterial')" style="float: left">조회</button>
								<button class="btn_small_search ml5" onclick="fn_initForm()" style="float: left">초기화</button>
							</td>
							<th style="border-left: none;" class="contentBlock">시료수량 (EA)</th>
							<td>
								<input type="text" id="productCount" name="productCount" class="req" value="${chemicalTestData.data.PRODUCT_COUNT}"/>
							</td>
							<th style="border-left: none;" class="contentBlock">보관방법</th>
							<!-- 
							<td style="text-align:center;">
							  <div style="border-top: #ffffff; display: flex; flex-direction: column; gap: 4px" class="search_box">
							    <input type="radio" id="preservation1" name="preservation" value="실온" checked/>
							    <label for="preservation1" ><span></span>실온</label>
							    <input type="radio" id="preservation2" name="preservation" value="냉장" />
							    <label for="preservation2" ><span></span>냉장</label>
							    <input type="radio" id="preservation3" name="preservation" value="냉동" />
							    <label for="preservation3" ><span></span>냉동</label>
							  </div>
							  -->
							</td>
							<c:set var="preservation" value="${chemicalTestData.data.PRESERVATION}" />
							<c:set var="preservations" value="${fn:split(preservation, ',')}" />
							<td style="border-top: #ffffff; display: flex; flex-direction: column; gap: 4px" class="search_box">
							
								<input type="checkbox" id="preservation1" name="preservation" value="실온"
									<c:if test="${fn:contains(preservation, '실온')}">checked</c:if> />
								<label for="preservation1"><span></span>실온</label>
							
								<input type="checkbox" id="preservation2" name="preservation" value="냉장"
									<c:if test="${fn:contains(preservation, '냉장')}">checked</c:if> />
								<label for="preservation2"><span></span>냉장</label>
							
								<input type="checkbox" id="preservation3" name="preservation" value="냉동"
									<c:if test="${fn:contains(preservation, '냉동')}">checked</c:if> />
								<label for="preservation3"><span></span>냉동</label>
							
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<br>
			<c:if test="${not isSafeTeam}">
				<div style="float:right;">
					<button class="btn_small_search" style="margin:5px;" type="button" onclick="addChemicalTestColumn()">+ 항목 추가</button>
					<button class="btn_small_search" style="margin:5px;" type="button" onclick="deleteChemicalTestColumn()">- 항목 삭제</button>
				</div>
			</c:if>
			<div class="main_tbl">
				<table class="insert_proc01">
					<tbody id="testItemsTbody">
						
					</tbody>
				</table>
			</div>
			
			<div class="title2"  style="width: 80%; margin-top:10px;"><span class="txt">이화학 검사 진행 기준</span></div>
			<div class="title2" style="width: 20%; display: inline-block;">
				
			</div>
			<div class="main_tbl">
				<ul>
					<li style="list-style: none;">
						<!-- 
						<div class="text_insert" style="padding: 0px;">
							<textarea name="standardContents" id="standardContents" style="width: 666px; display: none;">
							
							</textarea>
							<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
						</div>
						 -->
			<c:set var="standardList" value="${standardList}" />
			<c:set var="hasMET" value="false" />
			<c:set var="hasSCH" value="false" />
			
			<c:forEach var="item" items="${standardList}">
				<c:if test="${item.TYPE_CODE eq 'MET'}">
					<c:set var="hasMET" value="true" />
				</c:if>
				<c:if test="${item.TYPE_CODE eq 'SCH'}">
					<c:set var="hasSCH" value="true" />
				</c:if>
			</c:forEach>
			<!-- 1. 검사 요청 방법 -->
			<span class="title3" style="width: 76%; margin-left: 30px;">1. 검사 요청 방법</span>
			<c:if test="${not isSafeTeam}">
				<div class="title2" style="width: 20%; display: inline-block;">
					<button class="btn_con_search" onClick="fn_addCol('standard1')" id="standard1_add_btn">
						<img src="/resources/images/icon_s_write.png" />추가 
					</button>
					<button class="btn_con_search" onClick="fn_delCol('standard1')">
						<img src="/resources/images/icon_s_del.png" />삭제 
					</button>
				</div>
			</c:if>
			<div class="main_tbl">
				<table class="insert_proc01">
					<colgroup>
						<col width="20" />
						<col />							
					</colgroup>
					<tbody id="standard1_tbody" name="standard1_tbody">
						<c:forEach items="${standardList}" var="standardData" varStatus="status">
							<c:if test="${standardData.TYPE_CODE eq 'MET'}">
								<tr id="standard1_tr_${status.index}">
									<td>
										<input type="checkbox" id="standard1_${status.index}">
										<label for="standard1_${status.index}"><span></span></label>
									</td>
									<td>
										<input type="text" name="standard1" class="req" style="width:99%; float: left" value="${standardData.STANDARD_CONTENT}" />
									</td>
								</tr>
							</c:if>
						</c:forEach>
						<!-- MET이 없을 경우 기본 1줄 출력 -->
						<c:if test="${not hasMET}">
							<tr id="standard1_tr_0">
								<td>
									<input type="checkbox" id="standard1_0">
									<label for="standard1_0"><span></span></label>
								</td>
								<td>
									<input type="text" name="standard1" class="req" style="width:99%; float: left" />
								</td>
							</tr>
						</c:if>
					</tbody>
					<tbody id="standard1_tbody_temp" name="standard1_tbody_temp" style="display:none;">
						<tr>
							<td>
								<input type="checkbox" id="standard1_TEMP">
								<label for="standard1_TEMP"><span></span></label>
							</td>
							<td>
								<input type="text" name="standard1" class="req" style="width:99%; float: left" />
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<!-- 2. 검사 진행 일정 -->
			<li style="list-style: none;">
				<span class="title3" style="width: 76%; margin-left: 30px;">2. 검사 진행 일정</span>
				<c:if test="${not isSafeTeam}">
					<div class="title2" style="width: 20%; display: inline-block;">
						<button class="btn_con_search" onClick="fn_addCol('standard2')" id="standard2_add_btn">
							<img src="/resources/images/icon_s_write.png" />추가 
						</button>
						<button class="btn_con_search" onClick="fn_delCol('standard2')">
							<img src="/resources/images/icon_s_del.png" />삭제 
						</button>
					</div>
				</c:if>
				<div class="main_tbl">
					<table class="insert_proc01">
						<colgroup>
							<col width="20" />
							<col />							
						</colgroup>
						<tbody id="standard2_tbody" name="standard2_tbody">
							<c:forEach items="${standardList}" var="standardData" varStatus="status">
								<c:if test="${standardData.TYPE_CODE eq 'SCH'}">
									<tr id="standard2_tr_${status.index}">
										<td>
											<input type="checkbox" id="standard2_${status.index}">
											<label for="standard2_${status.index}"><span></span></label>
										</td>
										<td>
											<input type="text" name="standard2" class="req" style="width:99%; float: left" value="${standardData.STANDARD_CONTENT}" />
										</td>
									</tr>
								</c:if>
							</c:forEach>
							<!-- SCH이 없을 경우 기본 1줄 출력 -->
							<c:if test="${not hasSCH}">
								<tr id="standard2_tr_0">
									<td>
										<input type="checkbox" id="standard2_0">
										<label for="standard2_0"><span></span></label>
									</td>
									<td>
										<input type="text" name="standard2" class="req" style="width:99%; float: left" />
									</td>
								</tr>
							</c:if>
						</tbody>
						<tbody id="standard2_tbody_temp" name="standard2_tbody_temp" style="display:none;">
							<tr>
								<td>
									<input type="checkbox" id="standard2_TEMP">
									<label for="standard2_TEMP"><span></span></label>
								</td>
								<td>
									<input type="text" name="standard2" class="req" style="width:99%; float: left" />
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</li>
			
			<div class="title2" style="width: 80%; margin-top:10px;"><span class="txt">기타</span></div>
			<div class="title2" style="width: 20%; display: inline-block;"></div>
			
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
						<tr style="height:365px;">
							<!-- 왼쪽: 요청사항 에디터 -->
							<td>
								<textarea name="requestContents" id="requestContents" style="width:100%; height:300px;">
									${chemicalTestData.data.REQUEST_CONTENT}
								</textarea>
							</td>
			
							<!-- 오른쪽: 이미지 업로드 및 미리보기 -->
							<td style="display: flex; flex-direction: column; align-items: center;">
								<!-- 이미지 영역 -->
								<div style="position: relative; display: inline-block;">
									<!-- 삭제 버튼 -->
									<c:if test="${not isSafeTeam}">
										<div style="position: absolute; top: 0; right: 0; z-index: 3;">
											<img src="/resources/images/btn_table_header01_del02.png"
												onClick="fn_deleteImageFile(this, event)" style="cursor: pointer;">
										</div>
									</c:if>
									<!-- 미리보기 이미지 -->
									<img id="preview"
										src="<c:choose>
												<c:when test="${not empty chemicalTestData.data.FILE_NAME}">
													/images${chemicalTestData.data.FILE_PATH}/${chemicalTestData.data.FILE_NAME}
												</c:when>
												<c:otherwise>
													/resources/images/img_noimg3.png
												</c:otherwise>
											</c:choose>"
										style="border:1px solid #e1e1e1; border-radius:5px; min-height:300px; max-height:300px; object-fit: contain; min-width:440px; max-width: 440px;">
								</div>
								
								<!-- 업로드 영역 -->
								<p class="pt10" style="margin-top: 8px;">
									<c:if test="${not isSafeTeam}">
										<div class="add_file2" style="width:100%; text-align:center;" onclick="fn_fileDivClick(event)">
											<input type="file" name="file" id="fileImageInput" accept="image/*"
												style="display:none;" onchange="fn_changeImageFile(this, event)" />
											<label for="fileImageInput" style="cursor: pointer;">
												이미지파일 등록 <img src="/resources/images/icon_add_file.png">
											</label>
										</div>
									</c:if>
								</p>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<input type="hidden" name="imageDeleteFlag" id="imageDeleteFlag" value="N">
			<input type="hidden" name="orgFileName" id="orgFileName" value="${chemicalTestData.data.ORG_FILE_NAME}">
			<input type="hidden" name="fileName" id="fileName" value="${chemicalTestData.data.FILE_NAME}">
			<input type="hidden" name="filePath" id="filePath" value="${chemicalTestData.data.FILE_PATH}">
			
			<div class="title2" style="width: 80%; margin-top:10px;"><span class="txt">검사 결과 내용 (식품안전팀 작성)</span></div>
			<div class="title2" style="width: 20%; display: inline-block;"></div>
			
			<div class="main_tbl">
				<table class="insert_proc01">
					<tbody>
						<tr style="height:365px;">
							<!-- 왼쪽: 요청사항 에디터 -->
							<td>
								<textarea name="resultContent" id="resultContent" style="width:100%; height:300px;">
									${chemicalTestData.data.TEST_RESULT}
								</textarea>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
<%-- 		
			<div class="title2"  style="width: 80%; margin-top:10px;"><span class="txt">결재</span></div>
			<div class="title2" style="width: 20%; display: inline-block;">
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
			</div> --%>
			<c:if test="${not isSafeTeam}">
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
				<c:if test="${not empty chemicalTestData.fileList}">
				<select id="tempFileList" name="tempFileList" multiple style="display:none">
				  <c:forEach var="file" items="${chemicalTestData.fileList}">
				    <option value="${file.FILE_IDX}">${file.ORG_FILE_NAME}</option>
				  </c:forEach>
				</select>
				<div class="con_file" style="">
					<ul>
						<li class="point_img">
							<dt>기존파일</dt><dd>
								<ul id="attatch_file">
						              <c:forEach var="file" items="${chemicalTestData.fileList}">
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
				</c:if>
			</c:if>
					
			<div class="main_tbl">
				<div class="btn_box_con5">
					<button class="btn_admin_gray" onClick="fn_goList();" style="width: 120px;">목록</button>
				</div>
				<div class="btn_box_con4">
					<!-- 
					<button class="btn_admin_red">임시/템플릿저장</button>
					<button class="btn_admin_navi">임시저장</button>
					 -->
					<c:if test="${isSafeTeam}">
						<button class="btn_admin_sky" onclick="fn_safeTeamUpdate()">결과 입력</button>
					</c:if>
					<c:if test="${not isSafeTeam}">
						<button class="btn_admin_gray" onclick="fn_tmp_update()">임시저장</button>
						<button class="btn_admin_sky" onclick="fn_update()">등록</button>
					</c:if>
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

<!-- 문서 검색 레이어 start-->
<div class="white_content" id="dialog_search">
	<div class="modal" style="	width: 700px;margin-left:-360px;height: 550px;margin-top:-300px;">
		<h5 style="position:relative">
			<span class="title">이화학 검사 의뢰서 검색</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('dialog_search')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li>
					<dt>보고서검색</dt>
					<dd>
						<input type="text" value="" class="req" style="width:302px; float: left" name="searchValue" id="searchValue" placeholder="시료명, 의뢰일자, 희망 완료일, 의뢰자 등을 입력하세요."/>
						<button class="btn_small_search ml5" onclick="fn_search()" style="float: left">조회</button>
					</dd>
				</li>
			</ul>
		</div>
		<div class="main_tbl" style="height: 300px; overflow-y: auto">
			<table class="tbl07">
				<colgroup>
					<col width="40px">
					<col/>
					<col width="20%">
					<col width="20%">
					<col width="20%">
				</colgroup>
				<thead>
					<tr>
						<th></th>
						<th>시료명</th>
						<th>의뢰일자</th>
						<th>희망 완료일</th>
						<th>의뢰자</th>
					<tr>
				</thead>
				<tbody id="productLayerBody">
					<tr>
						<td colspan="5">검색해주세요</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</div>
<!-- 문서 검색 레이어 close-->

<!-- SAP 코드 검색 레이어 start-->
<!-- SAP 코드 검색 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_erpMaterial">
	<input id="erpTargetID" type="hidden">
	<input id="erpItemType" type="hidden">
	<div class="modal positionCenter" style="width: 900px; height: 600px; margin-left: -55px; margin-top: -50px ">
		<h5 style="position: relative">
			<span class="title">원료코드 검색</span>
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
							<td colspan="9">원료코드 혹은 원료코드명을 검색해주세요</td>
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