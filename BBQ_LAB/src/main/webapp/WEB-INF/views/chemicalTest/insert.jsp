<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
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
	//var editor1;
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
		
		/*
		ClassicEditor
        .create(document.getElementById("standardContents"), {
			language: 'ko',
        }).then( editor => {
        	editor1 = editor;
    		console.log( editor1 );
    	}).catch( error => {
    		console.error( error );
    	});
		*/
		
		ClassicEditor
        .create(document.getElementById("requestContents"), {
			language: 'ko',
        }).then( editor => {
        	editor2 = editor;
    		console.log( editor2 );
    	}).catch( error => {
    		console.error( error );
    	});
		fn.autoComplete($("#keyword"));
		
		// 초기 상태: 체크되지 않은 항목은 input 비활성화
		$("input[name='testItems']").each(function () {
			let type = $(this).val(); // PH, BRI 등
			let inputSelector = "input[name='itemContent_" + type + "']";
			if (!$(this).is(":checked")) {
				$(inputSelector).prop("disabled", true);
			}
		});

		// 체크 변경 이벤트로 제어
		$("input[name='testItems']").change(function () {
			let type = $(this).val(); // 예: PH
			let inputSelector = "input[name='itemContent_" + type + "']";
			if ($(this).is(":checked")) {
				$(inputSelector).prop("disabled", false);
			} else {
				$(inputSelector).prop("disabled", true).val(""); // 체크 해제 시 값도 제거
			}
		});
		
	});
	
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
		let isValid = true;
		let focusTarget = null;

		$("input[name='testItems']:checked").each(function () {
			let value = $(this).val(); // "PH", "HEAVY", etc
			let inputSelector = "";

			if (value === "PH") inputSelector = "input[name='itemContent_PH']";
			else if (value === "BRI") inputSelector = "input[name='itemContent_BRI']";
			else if (value === "SAL") inputSelector = "input[name='itemContent_SAL']";
			else if (value === "VIS") inputSelector = "input[name='itemContent_VIS']";

			if (inputSelector && $(inputSelector).val().trim() === "") {
				focusTarget = $(inputSelector);
				isValid = false;
				return false; // break $.each
			}
		});

		if (!isValid) {
			alert("검사요청 항목에 대한 범위를 기재해 주세요.");
			if (focusTarget) focusTarget.focus();
			return false;
		}
		return true;
	}
	
	//입력확인
	function fn_insert(){
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
		} else if ($("input[name='testItems']:checked").length === 0) {
			alert("검사요청 항목은 한개 이상 선택되어야 합니다.");
			$("input[name='testItems']").first().focus();
			return;
		} else if( !fn_validateTestRange() ) {
			return;
		} else if( attatchFileArr.length == 0 && $("#tempFileList option").length == 0 ) {
			alert("첨부파일을 등록해주세요.");		
			return;		
		} else {
			var formData = new FormData();
			formData.append("requestDate",$("#requestDate").val());
			formData.append("completionDate",$("#completionDate").val());
			formData.append("requestUser",$("#requestUser").val());
			formData.append("productCode",$("#productCode").val());
			formData.append("productName",$("#productName").val());
			formData.append("sapCode",$("#sapCode").val());
			formData.append("productCount",$("#productCount").val());
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
			
			/*
			$('select[name=tempFileList] option:selected').each(function(index){
				formData.append('tempFile', $(this).attr('value'));							
			});
			*/
			
			var typeCodeArr = [];
			var itemContentArr = [];
			$("input[name='testItems']:checked").each(function () {
				let typeCode = $(this).val(); // PH, BRI, etc
				let content = $("input[name='itemContent_"+typeCode+"']").val() || ""; // 대응되는 범위값
				typeCodeArr.push(typeCode);
				itemContentArr.push(content);
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
			var URL = "../chemicalTest/insertChemicalTestAjax";
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
								alert("시료명 "+$("#productName").val()+"에 대한 이화학 검사 의뢰서가 정상적으로 생성되었습니다.");
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
	
	function fn_copySearch() {
		openDialog('dialog_search');
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
	
	function fn_copy(idx) {
		var URL = "../chemicalTest/selectChemicalTestDataAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"idx" : idx
			},
			dataType:"json",
			success:function(result) {
				console.log(result);
				
				var data = result.chemicalTestData.data;
				var itemList = result.itemList;
				var standardList = result.standardList;
				// 기본 필드
				$("#requestDate").val(data.REQUEST_DATE);
				$("#completionDate").val(data.COMPLETION_DATE);
				$("#requestUser").val(data.REQUEST_USER);
				$("#productCode").val(data.PRODUCT_CODE);
				$("#productName").val(data.PRODUCT_NAME);
				$("#sapCode").val(data.SAP_CODE);
				$("#productCount").val(data.PRODUCT_COUNT);

				// 보관방법 (checkbox)
				$("input[name='preservation']").prop("checked", false); // 초기화
				if (data.PRESERVATION) {
					var values = data.PRESERVATION.split(",");
					$.each(values, function(i, val) {
						$("input[name='preservation'][value='" + val + "']").prop("checked", true);
					});
				}

				// 요청사항 (CKEditor)
				if (editor2) {
					editor2.setData(data.REQUEST_CONTENT || "");
				}

				// 검사 항목
				$("input[name='testItems']").prop("checked", false); // 초기화
				$.each(itemList, function(i, item) {
					var type = item.TYPE_CODE;
					$("input[name='testItems'][value='" + type + "']").prop("checked", true);
					$("input[name='itemContent_" + type + "']").val(item.ITEM_CONTENT).prop("disabled", false);
				});

				// 검사 기준 항목
				$("#standard1_tbody").empty();
				$("#standard2_tbody").empty();
				$.each(standardList, function(i, std) {
					var type = std.TYPE_CODE === "MET" ? "1" : "2";
					var html =
						'<tr id="standard' + type + '_tr_' + i + '">' +
							'<td>' +
								'<input type="checkbox" id="standard' + type + '_' + i + '">' +
								'<label for="standard' + type + '_' + i + '"><span></span></label>' +
							'</td>' +
							'<td>' +
								'<input type="text" name="standard' + type + '" style="width:99%;" value="' + std.STANDARD_CONTENT + '"/>' +
							'</td>' +
						'</tr>';
					$("#standard" + type + "_tbody").append(html);
				});
				
				/*
				// 이미지 파일 미리보기
				if (data.FILE_NAME && data.FILE_PATH) {
					var fullPath = "/images" + data.FILE_PATH + "/" + data.FILE_NAME;
					$("#preview").attr("src", fullPath);
				} else {
					$("#preview").attr("src", "/resources/images/img_noimg3.png");
				}
				*/

				/*
				// ✅ 첨부파일 목록 (삭제 가능)
				const fileList = result.chemicalTestData.fileList || [];
				
				$("#temp_attatch_file").empty();
				$("#tempFileList").empty(); // 기존 파일 ID 목록 초기화
				
				if( fileList.length > 0 ) {
					$("#temp_file").show();
					fileList.forEach(function(item,index){
						$("#tempFileList").addOption(item.FILE_IDX, item.ORG_FILE_NAME, true);
						var childTag = '<li><a href="#none" onclick="removeTempFile(this, \''+item.FILE_IDX+'\')"><img src="/resources/images/icon_del_file.png"></a>'+item.ORG_FILE_NAME+'</li>'
						$("#temp_attatch_file").append(childTag);
					});
				}
				*/
				closeDialog('dialog_search')
			},
			error:function(request, status, errorThrown){
			}			
		});
	}
	
	function removeTempFile(element, tempId){
		$(element).parent().remove();
		$("#tempFileList").removeOption(tempId);
		if( $("#tempFileList option").length == 0 ) {
			$("#temp_file").hide();
		}
	}
	
	function fn_deleteOldFile(element, fileIdx) {
		if (!confirm("첨부파일을 삭제하시겠습니까?")) return;

		$(element).closest("li").remove();
		$("#tempFileList option[value='" + fileIdx + "']").remove();
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
			URL = '/material/selectErpMaterialListAjax';
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
		$("#productName").prop("readonly",true);
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
		$("#productName").prop("readonly",false);
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
						<button class="btn_circle_modifiy" onclick="fn_copySearch()">&nbsp;</button>
						<button class="btn_circle_save" onclick="fn_insert()">&nbsp;</button>
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
								<input type="text" name="requestDate" id="requestDate" class="req" />								
							</td>
							<th style="border-left: none;">희망 완료일</th>
							<td>
								<input type="text" name="completionDate" id="completionDate" class="req" />
							</td>
							<th style="border-left: none; width:120px;">의뢰자</th>
							<td>
								<input type="text" name="requestUser" id="requestUser" class="req"/>
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
								<input type="text"  style="float: left; display: none;" class="req" name="sapCode" id="sapCode" placeholder="코드를 조회 하세요." readonly/>
								<input type="text"  style="float: left" class="req" name="productName" id="productName" placeholder="코드를 조회 하세요." readonly/>
								<button class="btn_small_search ml5" onclick="openDialog('dialog_erpMaterial')" style="float: left">조회</button>
								<button class="btn_small_search ml5" onclick="fn_initForm()" style="float: left">초기화</button>
							</td>
							<th style="border-left: none;" class="contentBlock">시료수량 (EA)</th>
							<td>
								<input type="text" id="productCount" name="productCount" class="req" />
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
							<td style="text-align:center;">
							  <div style="display: flex; flex-direction: column; gap: 4px;" class="search_box">
							    <input type="checkbox" id="preservation1" name="preservation" value="실온"/>
							    <label for="preservation1"><span></span>실온</label>
							    <input type="checkbox" id="preservation2" name="preservation" value="냉장"/>
							    <label for="preservation2"><span></span>냉장</label>
							    <input type="checkbox" id="preservation3" name="preservation" value="냉동"/>
							    <label for="preservation3"><span></span>냉동</label>
							  </div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<br>
			<div class="main_tbl">
				<table class="insert_proc01">
					<tbody>
					<tr style="height:60px;">
						<th style="border-left: none;" class="contentBlock">검사요청(항목에 체크)</th>
						<td>
							<div class="search_box" >
								<input type="checkbox" id="check_ph" name="testItems" value="PH" >
								<label for="check_ph"><span></span>pH</label>
							</div>
						</td>
						<td>
							<div class="search_box">
								<input type="checkbox" id="check_heavy" name="testItems" value="BRI">
								<label for="check_heavy"><span></span>Brix</label>
							</div>
						</td>
						<td>
							<div class="search_box">
								<input type="checkbox" id="check_bacteria" name="testItems" value="SAL">
								<label for="check_bacteria"><span></span>염도</label>
							</div>
						</td>
						<td>
							<div class="search_box">
								<input type="checkbox" id="check_etc" name="testItems" value="VIS">
								<label for="check_etc"><span></span>점도</label>
							</div>
						</td>
					</tr>
						<tr style="height:60px;">
							<th style="border-left: none;" class="contentBlock">범위<br>(시료의 대략적인 범위 기재)</th>
							<td>
								<input type="text" name="itemContent_PH" placeholder="pH" style="width: 95%;">
							</td>
							<td>
								<input type="text" name="itemContent_BRI" placeholder="Brix" style="width: 95%;">
							</td>
							<td>
								<input type="text" name="itemContent_SAL" placeholder="염도" style="width: 95%;">
							</td>
							<td>
								<input type="text" name="itemContent_VIS" placeholder="점도" style="width: 95%;">
							</td>
						</tr>
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
						<span class="title3" style="width: 76%; margin-left: 30px;">1. 검사 요청 방법</span>
		 				<div class="title2" style="width: 20%; display: inline-block;">
							<button class="btn_con_search" onClick="fn_addCol('standard1')" id="standard1_add_btn">
								<img src="/resources/images/icon_s_write.png" />추가 
							</button>
							<button class="btn_con_search" onClick="fn_delCol('standard1')">
								<img src="/resources/images/icon_s_del.png" />삭제 
							</button>
						</div>
						<div class="main_tbl">
							<table class="insert_proc01">
								<colgroup>
									<col width="20" />
									<col  />							
								</colgroup>
								<tbody id="standard1_tbody" name="standard1_tbody">
									<tr id="standard1_tr_1">
										<td>
											<input type="checkbox" id="standard1_1"><label for="standard1_1"><span></span></label>
										</td>
										<td>
											<input type="text"  style="width:99%; float: left" class="req" name="standard1" value="가."/>
										</td>
									</tr>
								</tbody>
								<tbody id="standard1_tbody_temp" name="standard1_tbody_temp" style="display:none">
									<tr id="standard1_tmp_tr_1"> 
										<td>
											<input type="checkbox" id="standard1_1"><label for="standard1_1"><span></span></label>
										</td>
										<td>
											<input type="text"  style="width:99%; float: left" class="req" name="standard1"/>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
					</li>
					<li style="list-style: none;">
						<span class="title3" style="width: 76%; margin-left: 30px;">2. 검사 진행 일정</span>
		 				<div class="title2" style="width: 20%; display: inline-block;">
							<button class="btn_con_search" onClick="fn_addCol('standard2')" id="standard2_add_btn">
								<img src="/resources/images/icon_s_write.png" />추가 
							</button>
							<button class="btn_con_search" onClick="fn_delCol('standard2')">
								<img src="/resources/images/icon_s_del.png" />삭제 
							</button>
						</div>
						<div class="main_tbl">
							<table class="insert_proc01">
								<colgroup>
									<col width="20" />
									<col  />							
								</colgroup>
								<tbody id="standard2_tbody" name="standard2_tbody">
									<tr id="standard2_tr_1">
										<td>
											<input type="checkbox" id="standard2_1"><label for="standard2_1"><span></span></label>
										</td>
										<td>
											<input type="text"  style="width:99%; float: left" class="req" name="standard2" value="가."/>
										</td>
									</tr>
								</tbody>
								<tbody id="standard2_tbody_temp" name="standard2_tbody_temp" style="display:none">
									<tr id="standard2_tmp_tr_1"> 
										<td>
											<input type="checkbox" id="standard2_1"><label for="standard2_1"><span></span></label>
										</td>
										<td>
											<input type="text"  style="width:99%; float: left" class="req" name="standard2"/>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
					</li>
				</ul>
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
						<tr style="height:365px;">
							<td>
								<textarea name="requestContents" id="requestContents" display: none;" >

								</textarea>
							</td>
							<td style="display: flex; flex-direction: column; align-items: center;">
								<!-- 이미지 영역을 relative로 감쌈 -->
								<div style="position: relative; display: inline-block;">
									<!-- 이미지 삭제 버튼 -->
									<div style="position: absolute; top: 0; right: 0; z-index: 3;">
										<img src="/resources/images/btn_table_header01_del02.png" onClick="fn_deleteImageFile(this, event)" style="cursor: pointer;">
									</div>
									<!-- 미리보기 이미지 -->
									<img id="preview" src="/resources/images/img_noimg3.png"
     									style="border:1px solid #e1e1e1; border-radius:5px; width:400px; height:300px; object-fit: contain;">
								</div>
							
								<!-- 파일 업로드 영역 -->
								<p class="pt10" style="margin-top: 8px;">
									<div class="add_file2" style="width:100%; text-align:center;" onclick="fn_fileDivClick(event)">
										<input type="file" name="file" id="fileImageInput" accept="image/*" style="display:none;" onchange="fn_changeImageFile(this, event)" />
										<label for="fileImageInput" style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>
									</div>	
								</p>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
		
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
			<div class="con_file" style="display:none" id="temp_file">
				<select id="tempFileList" name="tempFileList" multiple style="display:none"></select>
				<ul>
					<li class="point_img">
						<dt>기존파일</dt><dd>
							<ul id="temp_attatch_file">
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
						<th>이망 완료일</th>
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
							<th>유통기한</th>
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