<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>시장조사결과 보고서 생성</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.btn_small_plus {
  appearance: none;
  background: transparent;
  border: none;
  color: #b92c35;          /* 붉은색 */
  font-weight: 500;        /* 굵게 */
  font-size: 16px;         /* 플러스 크기 */
  line-height: 1;
  padding: 6px 8px;
  border-radius: 8px;
  cursor: pointer;
  outline: none;
  transition: box-shadow .15s ease, background-color .15s ease, color .15s ease, transform .05s ease;

  /* ✅ 평상시에도 옅은 테두리 */
  box-shadow: inset 0 0 0 1px rgba(211, 47, 47, 0.2);
}

/* hover 시 더 진하고 뚜렷하게 */
.btn_small_plus:hover {
  background-color: rgba(211, 47, 47, 0.06);
  box-shadow:
    0 0 0 2px rgba(211, 47, 47, 0.25),  /* 외곽 흐림 */
    inset 0 0 0 1px #d32f2f;            /* 진한 테두리 */
  color: #b71c1c;
}

/* 클릭 순간 살짝 눌림 */
.btn_small_plus:active {
  transform: translateY(1px);
  box-shadow:
    0 0 0 2px rgba(211, 47, 47, 0.25),
    inset 0 0 0 2px #d32f2f;
}
[id$="_minus"][disabled] { display: none !important; }
.ck-editor__editable { max-height: 400px; min-height:150px;}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	$(document).ready(function(){
		$("#researchDate").datepicker({
			showOn: "both",
			buttonImage: "../resources/images/btn_calendar.png",
			buttonImageOnly: true,
			buttonText: "Select date",
			dateFormat: "yy-mm-dd",
			showButtonPanel: true,
			showAnim: ""
		});	//당일 선택 가능 0, 당일 선택 불가능 1
		
		fn.autoComplete($("#keyword"));
		autoComplete2($("#keyword2"));
		
		// 기존 1행 기준으로 −버튼 상태 세팅
	    ['market','purpose','address'].forEach(toggleMinus);
		
		<c:if test="${fn:length(apprItemList) > 0}">
	    fn_loadAppr();
		</c:if>
	});
	
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
	
	function fn_updateTmp() {
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			$("#title").focus();
			return;
		} else {
			$('#lab_loading').show();
			var formData = new FormData();
			formData.append("idx",$("#idx").val());
			formData.append("planIdx",$("#planIdx").val());
			formData.append("title",$("#title").val());
			formData.append("tripType",$("#tripType").selectedValues()[0]);
			
			var marketNameArr = new Array();
			$('tr[id^=market_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemMarketName = $('#'+ rowId + ' input[name=marketName]').val();
				if( itemMarketName != '' ) {
					marketNameArr.push(itemMarketName);	
				}
			});
			formData.append("marketNameArr",JSON.stringify(marketNameArr));
			
			var purposeArr = new Array();
			$('tr[id^=purpose_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemPurpose = $('#'+ rowId + ' input[name=purpose]').val();
				if( itemPurpose != '' ) {
					purposeArr.push(itemPurpose);
				}
			});
			formData.append("purposeArr",JSON.stringify(purposeArr));
			
			formData.append("researchDate",$("#researchDate").val());
			
			var marketAddressArr = new Array();
			$('tr[id^=address_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemMarketAddress = $('#'+ rowId + ' input[name=marketAddress]').val();
				if( itemMarketAddress != '' ) {
					marketAddressArr.push(itemMarketAddress);	
				}
			});
			formData.append("marketAddressArr",JSON.stringify(marketAddressArr));
			
			formData.append("cost",$("#cost").val());
			
			var deptArr = new Array();
			var positionArr = new Array();
			var nameArr = new Array();
			var validUser = true;
			$('tr[id^=user_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemDept = $('#'+ rowId + ' input[name=dept]').val();
				var itemPosition = $('#'+ rowId + ' input[name=position]').val();
				var itemNmae = $('#'+ rowId + ' input[name=name]').val();
				if( itemDept == '' && itemPosition == '' && itemNmae == '' ) {
					validUser = false;
				}
				deptArr.push(itemDept);
				positionArr.push(itemPosition);
				nameArr.push(itemNmae);
			});
			
			formData.append("deptArr",JSON.stringify(deptArr));
			formData.append("positionArr",JSON.stringify(positionArr));
			formData.append("nameArr",JSON.stringify(nameArr));
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
			
			formData.append('deletedFileIdArr', JSON.stringify(deletedFileIdArr));
			formData.append('deletedFileArr', JSON.stringify(deletedFileArr));
			formData.append('deletedFilePathArr', JSON.stringify(deletedFilePathArr));
			
			var URL = "../marketResearch/updateMarketResearchTmpAjax";
			$.ajax({
				type:"POST",
				url:URL,
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				dataType:"json",
				success:function(result) {
					if(result.RESULT == 'S') {
						if( $("#apprLine option").length > 0 ) {
							var apprFormData = new FormData();
							apprFormData.append("docIdx", '${researchData.data.RESEARCH_IDX}' );
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
							alert("임시저장되었습니다.");
							$('#lab_loading').hide();
							fn_goList();
						}
					} else {
						alert("오류가 발생하였습니다."+result.MESSAGE);
						$('#lab_loading').hide();
						fn_goList();
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
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			$("#title").focus();
			return;
		} else if( !chkNull($("#researchDate").val()) ) {
			alert("시장조사일시를 입력해 주세요.");
			$("#researchDate").focus();
			return;
		} else if( !chkNull($("#cost").val()) ) {
			alert("비용을 입력해 주세요.");
			$("#cost").focus();
			return;
		} else if( !chkNull($("#apprTxtFull").val()) ) {
			alert("결재라인을 등록해주세요.");
			return;
		} else {
			var formData = new FormData();
			formData.append("idx",$("#idx").val());
			formData.append("planIdx",$("#planIdx").val());
			formData.append("title",$("#title").val());
			formData.append("tripType",$("#tripType").selectedValues()[0]);
			
			var marketNameArr = new Array();
			$('tr[id^=market_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemMarketName = $('#'+ rowId + ' input[name=marketName]').val();
				if( itemMarketName != '' ) {
					marketNameArr.push(itemMarketName);	
				}
			});
			
			if( marketNameArr.length == 0 ) {
				alert("대상업소를 입력해주세요.");
				return;
			}
			
			formData.append("marketNameArr",JSON.stringify(marketNameArr));
			
			var purposeArr = new Array();
			$('tr[id^=purpose_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemPurpose = $('#'+ rowId + ' input[name=purpose]').val();
				if( itemPurpose != '' ) {
					purposeArr.push(itemPurpose);
				}
			});
			
			if( purposeArr.length == 0 ) {
				alert("시장조사 목적을 입력해주세요.");
				return;
			}
			
			formData.append("purposeArr",JSON.stringify(purposeArr));
			
			formData.append("researchDate",$("#researchDate").val());
			
			var marketAddressArr = new Array();
			$('tr[id^=address_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemMarketAddress = $('#'+ rowId + ' input[name=marketAddress]').val();
				if( itemMarketAddress != '' ) {
					marketAddressArr.push(itemMarketAddress);	
				}
			});
			
			if( marketAddressArr.length == 0 ) {
				alert("시장조사 장소의 주소를 입력해주세요.");
				return;
			}
			
			formData.append("marketAddressArr",JSON.stringify(marketAddressArr));
			
			formData.append("cost",$("#cost").val());
			
			var deptArr = new Array();
			var positionArr = new Array();
			var nameArr = new Array();
			var validUser = true;
			$('tr[id^=user_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemDept = $('#'+ rowId + ' input[name=dept]').val();
				var itemPosition = $('#'+ rowId + ' input[name=position]').val();
				var itemNmae = $('#'+ rowId + ' input[name=name]').val();
				if( itemDept == '' && itemPosition == '' && itemNmae == '' ) {
					validUser = false;
				}
				deptArr.push(itemDept);
				positionArr.push(itemPosition);
				nameArr.push(itemNmae);
			});
			
			if( !validUser ) {
				alert("조사자를 입력해주세요.");
				return;
			}
			
			formData.append("deptArr",JSON.stringify(deptArr));
			formData.append("positionArr",JSON.stringify(positionArr));
			formData.append("nameArr",JSON.stringify(nameArr));
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
			
			formData.append('deletedFileIdArr', JSON.stringify(deletedFileIdArr));
			formData.append('deletedFileArr', JSON.stringify(deletedFileArr));
			formData.append('deletedFilePathArr', JSON.stringify(deletedFilePathArr));
			
			$('#lab_loading').show();
			URL = "../marketResearch/updateMarketResearchAjax";
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
							apprFormData.append("docIdx", '${researchData.data.RESEARCH_IDX}' );
							apprFormData.append("apprIdx", '${apprHeader.APPR_IDX}' );
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
							alert("보고서가 정상적으로 생성되었습니다.");
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
		location.href = '/marketResearch/list';
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
		var URL = "../businessTripPlan/searchBusinessTripPlanListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				searchValue : $("#searchValue").val()
			},
			dataType:"json",
			success:function(result) {
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
						var row = '<tr onClick="fn_copy(\''+item.PLAN_IDX+'\')">';
						row += '<td></td>';
						row += '<td class="tgnl">'+item.TITLE+'</td>';
						row += '<td>'+item.TRIP_DESTINATION+'</td>';
						row += '<td>';
						row += ''+item.TRIP_START_DATE;
						if( item.TRIP_END_DATE != '' ) {
							row += ' ~ '+item.TRIP_END_DATE;	
						}
						row += '</td>';
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
		var URL = "../businessTripPlan/selectBusinessTripPlanDataAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"idx" : idx
			},
			dataType:"json",
			success:function(result) {
				$("#tripType").selectOptions(result.TRIP_TYPE);
				$("#tripType_label").html($("#tripType").selectedTexts());
				$("#tripStartDate").val(result.TRIP_START_DATE);
				$("#tripEndDate").val(result.TRIP_END_DATE);
				$("#title").val(result.TITLE);
				$("#dept").val(result.DEPT);
				$("#position").val(result.POSITION);
				$("#name").val(result.NAME);
				$("#tripPurpose").val(result.TRIP_PURPOSE);
				$("#tripDestination").val(result.TRIP_DESTINATION);
				$("#tripTransit").val(result.TRIP_TRANSIT);
				editor1.setData(result.CONTENTS);
				editor2.setData(result.TRIP_COST);
				$("#tripEffect").val(result.TRIP_EFFECT);
				fn_closeSearch();
			},
			error:function(request, status, errorThrown){
				
			}			
		});
	}
	
	function fn_addCol(type) {
		var randomId = randomId = Math.random().toString(36).substr(2, 9);
		var randomId2 = randomId = Math.random().toString(36).substr(2, 9);
		var row= '<tr>'+$('tbody[name='+type+'_tbody_temp]').children('tr').html()+'</tr>';
		
		$("#"+type+"_tbody").append(row);
		$("#"+type+"_tbody").children('tr:last').attr('id', type + '_tr_' + randomId);
		$("#"+type+"_tbody").children('tr:last').children('td').children('input[type=checkbox]').attr('id', type+'_'+randomId);
		$("#"+type+"_tbody").children('tr:last').children('td').children('label').attr('for', type+'_'+randomId);
		
		// ✅ minus 토글
		  toggleMinus(type);
	}
	
	function fn_addCol2(section) {
	  const $newRow = $('#contents_tmp_tr_1').clone(true, true).removeAttr('id').show();
	  $newRow.find('input').val('');

	  const idx = $('#contents_tbody tr').length + 1;   // 현재 행 개수 + 1

	  // ✅ 새로 추가되는 tr에도 저장 로직이 인식할 id 부여
	  $newRow.attr('id', 'contents_tr_' + idx);

	  // 일정 input 고유 id + datepicker 부착
	  const $sch = $newRow.find('input[name="schedule"]');
	  $sch.attr('id', 'schedule_' + idx).datepicker(DATEPICKER_OPTS);

	  // tbody에 추가
	  $('#contents_tbody').append($newRow);

	  // 출장기간 범위 동기화(있다면)
	  updateScheduleDateRange();

	  // 마이너스 버튼 토글
	  toggleMinus(section);
	}
	
	// ✅ 공용: minus 버튼 활성/비활성 토글
	function toggleMinus(section) {
	  const $tbody = $('#' + section + '_tbody');
	  const rowCount = $tbody.children('tr').length;
	  $('#' + section + '_minus').prop('disabled', rowCount <= 1);
	}
	
	// 마지막 행 제거 (둘 다 공용)
	function fn_removeLastRow(section) {
	  const $tbody = $('#' + section + '_tbody');
	  const $lastTr = $tbody.children('tr:last');

	  // 한 줄뿐이면 삭제 금지 & 버튼은 비활성
	  if ($tbody.children('tr').length <= 1) {
	    toggleMinus(section);
	    return;
	  }

	  // datepicker 붙어있으면 먼저 destroy
	  $lastTr.find('input.hasDatepicker').each(function () {
	    try { $(this).datepicker('destroy'); } catch (e) {}
	  });

	  $lastTr.remove();

	  // ✅ minus 토글
	  toggleMinus(section);
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
		$doc.title = document.getElementById("title").value + '_시장조사결과보고서';

		// 제목
		$doc.querySelector("#prev_title").innerText = document.getElementById("title").value;

		// 출장구분
		const tripTypeLabel = document.getElementById("tripType_label").innerText.trim();
		$doc.querySelector("#prev_trip_type").innerText = (tripTypeLabel === "선택" ? "" : tripTypeLabel);

		// 대상업소
		let marketHtml = "";
		document.querySelectorAll("#market_tbody input[name=marketName]").forEach(input => {
			if (input.value.trim()) {
				marketHtml += input.value.trim() + "<br/>";
			}
		});
		$doc.querySelector("#prev_market_tbody").innerHTML = marketHtml;

		// 목적
		let purposeHtml = "";
		document.querySelectorAll("#purpose_tbody input[name=purpose]").forEach(input => {
			if (input.value.trim()) {
				purposeHtml += input.value.trim() + "<br/>";
			}
		});
		$doc.querySelector("#prev_purpose_tbody").innerHTML = purposeHtml;

		// 일시
		$doc.querySelector("#prev_researchDate").innerText = document.getElementById("researchDate").value;

		// 주소
		let addressHtml = "";
		document.querySelectorAll("#address_tbody input[name=marketAddress]").forEach(input => {
			if (input.value.trim()) {
				addressHtml += input.value.trim() + "<br/>";
			}
		});
		$doc.querySelector("#prev_address_tbody").innerHTML = addressHtml;

		// 비용
		$doc.querySelector("#prev_cost").innerText = document.getElementById("cost").value;

		// 조사자
		let userHtml = "";
		document.querySelectorAll("#user_tbody tr").forEach(row => {
			const dept = row.querySelector("input[name=dept]")?.value.trim();
			const position = row.querySelector("input[name=position]")?.value.trim();
			const name = row.querySelector("input[name=name]")?.value.trim();

			if (dept || position || name) {
				userHtml += "<tr>";
				userHtml += "<td>" + (dept || "") + "</td>";
				userHtml += "<td>" + (position || "") + "</td>";
				userHtml += "<td>" + (name || "") + "</td>";
				userHtml += "</tr>";
			}
		});
		
		const userTableDiv = $doc.querySelector("#prev_user_tbody").closest("div");
		if (userHtml) {
			$doc.querySelector("#prev_user_tbody").innerHTML = userHtml;
			userTableDiv.style.display = "block";
		} else {
			userTableDiv.style.display = "none";
		}
	}
	
	function fn_openPreview() {
		var url = "/preview/marketResearchPrevPopup";

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
		시장조사결과 보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Market Research Report</span><span class="title">시장조사결과보고서</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<!-- <button class="btn_circle_modifiy" onclick="fn_copySearch()">&nbsp;</button>
						<button class="btn_circle_save" onclick="fn_update()">&nbsp;</button> -->
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
							<th style="border-left: none;">제목<span class="mandatory">*</span></th>
							<td colspan="3">
								<input type="hidden" name="idx" id="idx"value="${researchData.data.RESEARCH_IDX}"/>
								<input type="hidden" name="planIdx" id="planIdx"value="${researchData.data.PLAN_IDX}"/>
								<input type="text" name="title" id="title" style="width: 90%;" value="${researchData.data.TITLE}"/>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">결재라인</th>
							<td colspan="3">
								<input class="" id="apprTxtFull" name="apprTxtFull" type="text" style="width: 450px; float: left" readonly>
								<c:if test="${researchData.data.STATUS != null && researchData.data.STATUS != 'COND_APPR' }">
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
						<tr>
							<th style="border-left: none;">출장구분</th>
							<td colspan="3">
								<div class="selectbox" style="width:100px;">  
									<label for="tripType" id="tripType_label">${researchData.data.TRIP_TYPE_TXT}</label> 
									<select name="tripType" id="tripType">
										<option value="">선택</option>
										<option value="I" ${researchData.data.TRIP_TYPE == 'I' ? 'selected' : ''}>국내</option>
										<option value="O" ${researchData.data.TRIP_TYPE == 'O' ? 'selected' : ''}>해외</option>
									</select>
								</div>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">
								<div style="display:flex; justify-content: space-between;">
									<span>대상업소<span class="mandatory">*</span></span>
									<div>
										<button class="btn_small_plus" onClick="fn_addCol('market')" >+</button>
										<button type="button" id="market_minus" class="btn_small_plus" onclick="fn_removeLastRow('market')" disabled>−</button>
									</div>
								</div>
							</th>
							<td colspan="3">
								<table width="100%" border="0">
									<tbody id="market_tbody" name="market_tbody">
										<c:set var="count" value="0" />
										<c:forEach items="${infoList}" var="infoList" varStatus="status">
										<c:if test="${infoList.INFO_TYPE == 'NAME' }">
										<c:set var="count" value="${count + 1}" />
										<tr id="market_tr_${status.count}">
											<td>
												<input type="text"  style="width:90%; float: left" name="marketName" id="marketName" placeholder="" value="${infoList.INFO_TEXT}"/>
											</td>
										</tr>
										</c:if>
										</c:forEach>
										<c:if test="${count == 0 }">
										<tr id="market_tr_1">
											<td>
												<input type="text"  style="width:90%; float: left" name="marketName" id="marketName" placeholder="" value="가."/>
											</td>
										</tr>
										</c:if>
									</tbody>
									<tbody id="market_tbody_temp" name="market_tbody_temp" style="display:none">
										<tr id="market_tmp_tr_1" style="display:none">
											<td>
												<input type="text"  style="width:90%; float: left" name="marketName" id="marketName" placeholder=""/>
											</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">
								<div style="display:flex; justify-content: space-between;">
									<span>목적<span class="mandatory">*</span></span>
									<div>
										<button class="btn_small_plus" onClick="fn_addCol('purpose')" >+</button>
										<button type="button" id="purpose_minus" class="btn_small_plus" onclick="fn_removeLastRow('purpose')" disabled>−</button>
									</div>
								</div>
							</th>
							<td colspan="3">								
								<table width="100%" border="0">
									<tbody id="purpose_tbody" name="purpose_tbody">
										<c:set var="count" value="0" />
										<c:forEach items="${infoList}" var="infoList" varStatus="status">
										<c:if test="${infoList.INFO_TYPE == 'PUR' }">
										<c:set var="count" value="${count + 1}" />
										<tr id="purpose_tr_${status.count}">
											<td>
												<input type="text" name="purpose" id="purpose" style="width: 90%;" value="${infoList.INFO_TEXT}"/>
											</td>
										</tr>
										</c:if>
										</c:forEach>
										<c:if test="${count == 0 }">
										<tr id="purpose_tr_1">
											<td>
												<input type="text" name="purpose" id="purpose" style="width: 90%;" />
											</td>
										</tr>
										</c:if>
									</tbody>
									<tbody id="purpose_tbody_temp" name="purpose_tbody_temp" style="display:none">
										<tr id="purpose_tmp_tr_1" style="display:none">
											<td>
												<input type="text" name="purpose" id="purpose" style="width: 90%;" />
											</td>
										</tr>
									</tbody>
								</table>	
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">일시<span class="mandatory">*</span></th>
							<td colspan="3">
								<input type="text" name="researchDate" id="researchDate" style="width: 150px;" value="${researchData.data.RESEARCH_DATE}"/>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">
								<div style="display:flex; justify-content: space-between;">
									<span>주소</span>
									<div>
										<button class="btn_small_plus" onClick="fn_addCol('address')" >+</button>
										<button type="button" id="address_minus" class="btn_small_plus" onclick="fn_removeLastRow('address')" disabled>−</button>
									</div>
								</div>
							</th>
							<td colspan="3">
								<table width="100%" border="0">
									<tbody id="address_tbody" name="address_tbody">
										<c:set var="count" value="0" />
										<c:forEach items="${infoList}" var="infoList" varStatus="status">
										<c:if test="${infoList.INFO_TYPE == 'ADDRESS' }">
										<c:set var="count" value="${count + 1}" />
										<tr id="address_tr_${status.count}">
											<td>
												<input type="text" name="marketAddress" id="marketAddress" style="width: 90%;" value="${infoList.INFO_TEXT}"/>
											</td>
										</tr>
										</c:if>
										</c:forEach>
										<c:if test="${count == 0 }">
										<tr id="address_tr_1">
											<td>
												<input type="text" name="marketAddress" id="marketAddress" style="width: 90%;"/>
											</td>
										</tr>
										</c:if>
									</tbody>
									<tbody id="address_tbody_temp" name="address_tbody_temp" style="display:none">
										<tr id="address_tmp_tr_1" style="display:none">
											<td>
												<input type="text" name="marketAddress" id="marketAddress" style="width: 90%;"/>
											</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">비용</th>
							<td colspan="3">
								<textarea name="cost" id="cost" style="width: 95%; height: 40px; ">${researchData.data.COST}</textarea>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">조사자<span onClick="fn_addCol('user')" id="span_user">(+)</span><span class="mandatory">*</span></th>
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
										<c:set var="count" value="0" />
										<c:forEach items="${userList}" var="userList" varStatus="status">
										<c:set var="count" value="${count + 1}" />
										<tr id="user_tr_${status.count}">
											<td>
												<input type="text" name="dept" id="dept" style="width: 100%;" value="${userList.DEPT}"/>
											</td>
											<td>
												<input type="text" name="position" id="position" style="width: 100%;" value="${userList.POSITION}"/>
											</td>
											<td>
												<input type="text" name="name" id="name" style="width: 100%;" value="${userList.NAME}"/>
											</td>
											<td>
												<ul>
													<li style="float:none; display:inline">
														<button class="btn_doc" onClick="javascript:delUser(this)"><img src="/resources/images/icon_doc04.png">삭제</button>
													</li>
												</ul>
											</td>
										</tr>
										</c:forEach>
									</tbody>
									<tbody id="user_tbody_temp" name="user_tbody_temp" style="display:none">
										<tr id="user_tmp_tr_1" style="display:none">
											<td>
												<input type="text" name="dept" id="dept" style="width: 100%;" readonly/>
											</td>
											<td>
												<input type="text" name="position" id="position" style="width: 100%;" readonly/>
											</td>
											<td>
												<input type="text" name="name" id="name" style="width: 100%;" readonly/>
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
									<c:forEach items="${researchData.fileList}" var="fileList" varStatus="status">
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
							<ul id="temp_attatch_file">
								<c:forEach items="${researchData.fileList}" var="fileList" varStatus="status">
									<li><a href="#none" onclick="fn_removeTempFile(this, '${fileList.FILE_IDX}')"><img src="/resources/images/icon_del_file.png"></a>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
								</c:forEach>
							</ul>
							<ul id="attatch_file">								
							</ul>
						</dd>
					</li>
				</ul>
			</div> --%>
							
			<div class="main_tbl">
				<div class="btn_box_con5">
					<button class="btn_admin_gray" onClick="fn_goList();" style="width: 120px;">목록</button>
				</div>
				<div class="btn_box_con4">
					<!-- 
					<button class="btn_admin_red">임시/템플릿저장</button>
					 -->
					<c:if test="${userUtil:getUserId(pageContext.request) == researchData.data.DOC_OWNER}">
						<c:if test="${researchData.data.STATUS == 'TMP'}">
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
	<input type="hidden" id="docType" value="RESEARCH"/>
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
			<span class="title">시장조사결과보고서 결재 상신</span>
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

<!-- 문서 검색 레이어 start-->
<div class="white_content" id="dialog_search">
	<div class="modal" style="	width: 700px;margin-left:-360px;height: 550px;margin-top:-300px;">
		<h5 style="position:relative">
			<span class="title">출장계획보고서 검색</span>
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
						<input type="text" value="" class="req" style="width:302px; float: left" name="searchValue" id="searchValue" placeholder="제목, 목적, 출장지, 업무내용 등을 입력하세요."/>
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
					<col width="23%">
					<col width="30%">
				</colgroup>
				<thead>
					<tr>
						<th></th>
						<th>제목</th>
						<th>출장지</th>
						<th>출장일</th>
					<tr>
				</thead>
				<tbody id="productLayerBody">
					<tr>
						<td colspan="4">검색해주세요</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</div>
<!-- 문서 검색 레이어 close-->