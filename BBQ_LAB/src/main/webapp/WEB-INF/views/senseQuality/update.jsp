<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<% 
	int rowLimit = 4;
%>
<title>상품설계변경 보고서 생성</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 400px; min-height:400px;}


<style type="text/css">
.readOnly {
	background-color: #ddd
}
.positionCenter{
	position: absolute;
	transform: translate(-50%, -50%);
}

table{font-size: 12px}
.intable_title{ border:0; table-layout:fixed;}
.intable_title td{border:1px solid #666; text-align:center; height:22px;}

.intable{ border:0; table-layout:fixed; }
.intable td{border:1px solid #666; text-align:center; height:22px;word-break: break-all;}
.intable th{ }
.intable tfoot td{ background-color:#f2f2f2; border-bottom:none;}
.intable tfoot th{ background-color:#f2f2f2; border-bottom:none;}
.lineall{ border:2px solid #000}
.big_font{ font-size:20px;}
.hftitle{background-color:#f3f3f3;}
.inputText{
    width: 70%;
    height: 25px;
    border: none;
}

/* 제조순서 번호 css */
.imgbox {
    position: relative;
    text-align:left;
  }
.imgNumbox{position: absolute; width:21.5px; height:18px; border: 0.5px solid #000; top:-21px; left:-0.5px; text-align:center; background-color: #fff;}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	$(document).ready(function(){
		fn.autoComplete($("#keyword"));
	});
	
	function fn_updateTmp(){
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			$("#title").focus();
			return;
		} else {
			var formData = new FormData();
			formData.append("idx",$("#idx").val());
			formData.append("title",$("#title").val());
			formData.append("companyName",$("#companyName").val());
			formData.append("productName",$("#productName").val());
			formData.append("testPurpose",$("#testPurpose").val());
			formData.append("contentsHeader",$("#contentsHeader").val());
			formData.append("status", "TMP");

			var contentsDivElements = document.querySelectorAll('input[name="contentsDiv"]');
			var contentsDivArr = new Array();
			var count = 1;
			for (var contentsDivElement of contentsDivElements) {
				if( contentsDiv*3 >= count) {
					contentsDivArr.push(contentsDivElement.value);					
				} else {
					break;
				}
				count++;
			}
			
			var fileElements = document.querySelectorAll('input[name="file"]');
			var fileArr = new Array();
			var orderArr = new Array();
			count = 1;
			for (var fileElement of fileElements) {
				if( contentsDiv*3 >= count) {
					//var order = fileElement.dataset.order;
					if( fileElement.value != '' ) {
						formData.append('file', fileElement.files[0]);
						orderArr.push(fileElement.dataset.order);
					} else {
						formData.append('file', '');
					}
				} else {
					break;
				}
				count++;
			}
			
			formData.append("orderArr",orderArr);
			
			var contentsResultElements = document.querySelectorAll('textarea[name="contentsResult"]');
			var contentsResultArr = new Array();
			count = 1;
			for (var contentsResultElement of contentsResultElements) {
				if( contentsDiv*3 >= count) {
					contentsResultArr.push(contentsResultElement.value);					
				} else {
					break;
				}				
				count++;
			}
			
			var contentsNoteElements = document.querySelectorAll('textarea[name="contentsNote"]');
			var contentsNoteArr = new Array();
			count = 1;
			for (var contentsNoteElement of contentsNoteElements) {
				if( contentsDiv >= count ) {
					contentsNoteArr.push(contentsNoteElement.value);					
				} else {
					break;
				}				
				count++;
			}
			
			var resultArr = new Array();
			var resultCheckCnt = 0;
			$('tr[id^=result_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemResult = $('#'+ rowId + ' input[name=result]').val();
				if( itemResult != '' ) {
					resultArr.push(itemResult);					
				} else {
					resultCheckCnt++;
				}
			});
			
			if( resultCheckCnt > 0 || $('tr[id^=result_tr]').toArray().length < 1 ) {
				alert("결론을 입력해주세요.");
				return;
			}
			
			var inputCheckCnt = 0;
			var nullIdxArr = new Array();
			contentsDivArr.forEach(function(item, index){
				if( item == '' && fileArr[index] == '' && contentsResultArr[index] == '' ) {
					nullIdxArr.push(index);
				} else if( item == '' || fileArr[index] == '' || contentsResultArr[index] == '' ) {
					inputCheckCnt++;
				}
			});
			
			//if( inputCheckCnt > 0 ) {
			//	alert("세부내용은 구분, 사진, 결과를 입력하여야 합니다.");
			//	return;
			//}
			
			for( var i = nullIdxArr.length-1 ; i >= 0 ; i-- ) {
				contentsDivArr.splice(nullIdxArr[i],1);
				fileArr.splice(nullIdxArr[i],1);
				contentsResultArr.splice(nullIdxArr[i],1);
			}
			
			formData.append("contentsDivArr",JSON.stringify(contentsDivArr));
			//formData.append("file",fileArr);
			formData.append("contentsResultArr",JSON.stringify(contentsResultArr));
			formData.append("contentsNoteArr",JSON.stringify(contentsNoteArr));
			formData.append("resultArr",JSON.stringify(resultArr));
			
			
			var displayOrders = document.querySelectorAll('input[name="displayOrder"]');
			var contentsIdxs = document.querySelectorAll('input[name="contentsIdx"]');
			var dataStatuses = document.querySelectorAll('input[name="dataStatus"]');
			
			var displayOrderArr = new Array();
			for (var displayOrder of displayOrders) {
				displayOrderArr.push(displayOrder.value);
			}
			
			var contentsIdxArr = new Array();
			for (var contentsIdx of contentsIdxs) {
				contentsIdxArr.push(contentsIdx.value);
			}
			
			var dataStatusArr = new Array();
			for (var dataStatus of dataStatuses) {
				dataStatusArr.push(dataStatus.value);
			}
			
			for (var contentsNoteElement of contentsNoteElements) {
				if( contentsDiv >= count ) {
					contentsNoteArr.push(contentsNoteElement.value);					
				} else {
					break;
				}				
				count++;
			}
			
			formData.append("displayOrderArr",displayOrderArr);
			formData.append("contentsIdxArr",contentsIdxArr);
			formData.append("dataStatusArr",dataStatusArr);
			
			$('#lab_loading').show();
			var URL = "../senseQuality/updateSenseQualityTmpAjax";

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
						alert("임시저장 되었습니다.");
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
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			$("#title").focus();
			return;
		} else if( !chkNull($("#companyName").val()) ) {
			alert("업체명을 입력해 주세요.");
			$("#companyName").focus();
			return;
		} else if( !chkNull($("#productName").val()) ) {
			alert("제품명을 입력해 주세요.");
			$("#productName").focus();
			return;
		} else if( !chkNull($("#testPurpose").val()) ) {
			alert("테스트 목적을 입력해 주세요.");
			$("#testPurpose").focus();
			return;
		} else if( !chkNull($("#contentsHeader").val()) ) {
			alert("세부내용을 입력해 주세요.");
			$("#contentsHeader").focus();
			return;
		} else {
			var formData = new FormData();
			formData.append("idx",$("#idx").val());
			formData.append("title",$("#title").val());
			formData.append("companyName",$("#companyName").val());
			formData.append("productName",$("#productName").val());
			formData.append("sapCode",$("#sapCode").val());
			formData.append("testPurpose",$("#testPurpose").val());
			formData.append("contentsHeader",$("#contentsHeader").val());
			formData.append("currentStatus", $("#currentStatus").val());
			formData.append("status", "REG");
			formData.append("docType", $("#docType").val());
			

			var contentsDivElements = document.querySelectorAll('input[name="contentsDiv"]');
			var contentsDivArr = new Array();
			var count = 1;
			for (var contentsDivElement of contentsDivElements) {
				if( contentsDiv*3 >= count) {
					contentsDivArr.push(contentsDivElement.value);					
				} else {
					break;
				}
				count++;
			}
			
			var fileElements = document.querySelectorAll('input[name="file"]');
			var fileArr = new Array();
			var orderArr = new Array();
			count = 1;
			for (var fileElement of fileElements) {
				if( contentsDiv*3 >= count) {
					//var order = fileElement.dataset.order;
					if( fileElement.value != '' ) {
						formData.append('file', fileElement.files[0]);
						orderArr.push(fileElement.dataset.order);
					} else {
						formData.append('file', '');
					}
				} else {
					break;
				}
				count++;
			}
			
			formData.append("orderArr",orderArr);
			
			var contentsResultElements = document.querySelectorAll('textarea[name="contentsResult"]');
			var contentsResultArr = new Array();
			count = 1;
			for (var contentsResultElement of contentsResultElements) {
				if( contentsDiv*3 >= count) {
					contentsResultArr.push(contentsResultElement.value);					
				} else {
					break;
				}				
				count++;
			}
			
			var contentsNoteElements = document.querySelectorAll('textarea[name="contentsNote"]');
			var contentsNoteArr = new Array();
			count = 1;
			for (var contentsNoteElement of contentsNoteElements) {
				if( contentsDiv >= count ) {
					contentsNoteArr.push(contentsNoteElement.value);					
				} else {
					break;
				}				
				count++;
			}
			
			var resultArr = new Array();
			var resultCheckCnt = 0;
			$('tr[id^=result_tr]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemResult = $('#'+ rowId + ' input[name=result]').val();
				if( itemResult != '' ) {
					resultArr.push(itemResult);					
				} else {
					resultCheckCnt++;
				}
			});
			
			if( resultCheckCnt > 0 || $('tr[id^=result_tr]').toArray().length < 1 ) {
				alert("결론을 입력해주세요.");
				return;
			}
			
			var inputCheckCnt = 0;
			var nullIdxArr = new Array();
			contentsDivArr.forEach(function(item, index){
				if( item == '' && fileArr[index] == '' && contentsResultArr[index] == '' ) {
					nullIdxArr.push(index);
				} else if( item == '' || fileArr[index] == '' || contentsResultArr[index] == '' ) {
					inputCheckCnt++;
				}
			});
			
			//if( inputCheckCnt > 0 ) {
			//	alert("세부내용은 구분, 사진, 결과를 입력하여야 합니다.");
			//	return;
			//}
			
			for( var i = nullIdxArr.length-1 ; i >= 0 ; i-- ) {
				contentsDivArr.splice(nullIdxArr[i],1);
				fileArr.splice(nullIdxArr[i],1);
				contentsResultArr.splice(nullIdxArr[i],1);
			}
			
			formData.append("contentsDivArr",JSON.stringify(contentsDivArr));
			//formData.append("file",fileArr);
			formData.append("contentsResultArr",JSON.stringify(contentsResultArr));
			formData.append("contentsNoteArr",JSON.stringify(contentsNoteArr));
			formData.append("resultArr",JSON.stringify(resultArr));
			
			
			var displayOrders = document.querySelectorAll('input[name="displayOrder"]');
			var contentsIdxs = document.querySelectorAll('input[name="contentsIdx"]');
			var dataStatuses = document.querySelectorAll('input[name="dataStatus"]');
			
			var displayOrderArr = new Array();
			for (var displayOrder of displayOrders) {
				displayOrderArr.push(displayOrder.value);
			}
			
			var contentsIdxArr = new Array();
			for (var contentsIdx of contentsIdxs) {
				contentsIdxArr.push(contentsIdx.value);
			}
			
			var dataStatusArr = new Array();
			for (var dataStatus of dataStatuses) {
				dataStatusArr.push(dataStatus.value);
			}
			
			for (var contentsNoteElement of contentsNoteElements) {
				if( contentsDiv >= count ) {
					contentsNoteArr.push(contentsNoteElement.value);					
				} else {
					break;
				}				
				count++;
			}
			
			formData.append("displayOrderArr",displayOrderArr);
			formData.append("contentsIdxArr",contentsIdxArr);
			formData.append("dataStatusArr",dataStatusArr);
			
			$('#lab_loading').show();
			var URL = "../senseQuality/updateSenseQualityAjax";
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
							apprFormData.append("docIdx", '${senseQualityData.reportMap.REPORT_IDX}');
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
							alert("수정되었습니다.");
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
		location.href = '/senseQuality/list';
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
				console.log(item);
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
	
	function fn_fileDivClick(e){
		e.stopPropagation();
		$(e.target).children('input').click();
	}
	
	function fn_changeImageFile(element, e){
		var reader = new FileReader();
		reader.onload = function (e) {
			$(element).parent().parent().children("p:eq(0)").children().attr("src", e.target.result);
		};
		reader.readAsDataURL(element.files[0]);
	}
	
	function fn_deleteImageFile(element, e){
		$(element).parent().parent().children("p:eq(0)").children().attr("src", '/resources/images/img_noimg3.png');		
		$(element).parent().parent().children("div:eq(0)").children().val('');
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
	
	var contentsDiv = ${senseQualityData.modCount};
	function fn_addContents() {
		if( contentsDiv < <%=rowLimit+1%> ) {
			contentsDiv++;
			$("#contents_div_"+contentsDiv).show();
		}
		
	}
	
	function fn_delContents(){
		if( contentsDiv > 1 ) {
			$("#contents_div_"+contentsDiv).hide();
			contentsDiv--;
		}
	}
	
	function fn_deleteImageFile2(element, e) {
		if( confirm("이미지를 삭제하시겠습니까?") ) {			
			var contentsIdx = $(element).parent().next().next().val();			
			var URL = "../senseQuality/deleteSenseQualityContenstsDataAjax";
			$.ajax({
				type:"POST",
				url:URL,
				data: {
					"contentsIdx" : contentsIdx
				},
				dataType:"json",
				success:function(result) {
					console.log(result);
					if( result.RESULT == 'S' ) {
						$(element).parent().next().next().next().val('M');
						$(element).parent().parent().hide();
						$(element).parent().parent().next().show();	
					} else {
						alert("이미지 삭제 오류가 발생했습니다.\n다시 시도하여 주세요.");
					}
				},
				error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
				}			
			});
		}
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
					
					var row = '<tr onClick="fn_setMaterialPopupData(\''+item.SAP_CODE+'\', \''+item.NAME+'\')">';
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
	
	function fn_setMaterialPopupData(SAP_CODE, NAME) {
		$("#productName").val(NAME);
		$("#productName").prop("readonly",true);
		$("#sapCode").val(SAP_CODE);
		fn_closeErpMatRayer();
	}
	
	function fn_initForm() {
		$("#productName").val("");
		$("#productName").prop("readonly",false);
		$("#sapCode").val("");
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
		상품설계변경 보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Sense & Quality Test Report</span><span class="title">관능&품질평가 테스트 결과보고서</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<button class="btn_circle_save" onclick="fn_insert()">&nbsp;</button>
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
						<col width="35%" />
						<col width="15%" />
						<col width="35%" />
					</colgroup>
					<tbody>
						<tr>
							<th style="border-left: none;">제목</th>
							<td colspan="3">
								<input type="hidden" name="idx" id="idx" value="${senseQualityData.reportMap.REPORT_IDX}">
								<input type="hidden" name="currentStatus" id="currentStatus" value="${senseQualityData.reportMap.STATUS}">								
								<input type="text" name="title" id="title" style="width: 90%;" class="req" value="${senseQualityData.reportMap.TITLE}"/>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">업체명</th>
							<td colspan="3">
								<input type="text"  style="width:200px; float: left" class="req" name="companyName" id="companyName" placeholder="업체명을 입력하세요." value="${senseQualityData.reportMap.COMPANY_NAME}"/>
							</td>
						</tr>
						<tr>	
							<th style="border-left: none;">제품명</th>
							<td>
								<input type="text"  style="width:90%; float: left" class="req" name="productName" id="productName" placeholder="제품명을 입력하세요." value="${senseQualityData.reportMap.PRODUCT_NAME}"/>
							</td>
							<th style="border-left: none;">ERP코드</th>
							<td>
								<input type="text"  style="width:200px; float: left" class="req" name="sapCode" id="sapCode" placeholder="코드를 조회 하세요." readonly/>
								<button class="btn_small_search ml5" onclick="openDialog('dialog_erpMaterial')" style="float: left">조회</button>
								<button class="btn_small_search ml5" onclick="fn_initForm()" style="float: left">초기화</button>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">테스트 목적</th>
							<td colspan="3">
								<input type="text"  style="width:100%; float: left" class="req" name="testPurpose" id="testPurpose" value="${senseQualityData.reportMap.TEST_PURPOSE}"/>
							</td>
						</tr>
						<c:if test="${senseQualityData.reportMap.STATUS == 'TMP' || senseQualityData.reportMap.STATUS == 'REG'}">
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
						</c:if>
					</tbody>
				</table>
			</div>

			<div class="title2"  style="width: 85%;"><span class="txt">세부내용</span></div>
			<div class="title2" style="width: 15%; display: inline-block;">
				<button class="btn_con_search" onClick="fn_addContents()" id="feature_add_btn">
					<img src="/resources/images/icon_s_write.png" />추가 
				</button>
				<button class="btn_con_search" onClick="fn_delContents()">
					<img src="/resources/images/icon_s_del.png" />삭제 
				</button>
			</div>
			<div id="contents_div_1">
				 <table style="width: 100%"  id="table1" class="intable lineall mb5" >
				 	<colgroup>
			            <col width="10%">
			            <col width="26%">
			            <col width="26%">
			            <col width="26%">
			            <col width="12%">			            
			        </colgroup>
			        <tr>
			        	<td rowspan="2">구분</td>
			        	<td colspan="4" align="center"><input style="border: none; width:40%; height: 30px;" class="" type="text" id="contentsHeader" data-gubun="" name="contentsHeader" placeholder="내용을 입력해주세요." value="${senseQualityData.reportMap.CONTENTS_HEADER}"/></td>
			        </tr>
			        <tr id="contents_div_tr_1">
			        	<c:set var="startNo" value="0"/>
				        <c:set var="endNo" value="2"/>
				        <c:set var="count" value="0" />
			        	<c:forEach items="${senseQualityData.contentsList}" var="contentsList" varStatus="status">	
			        	<c:if test="${status.index >= startNo && status.index <= endNo}">
			        	<c:set var="count" value="${count + 1}" />
			        	<td><input style="border: none; width:98%; height: 30px;" class="" type="text" id="contentsDiv" data-gubun="" name="contentsDiv" placeholder="내용을 입력해주세요." value="${contentsList.CONTENTS_DIV}"/></td>
			        	</c:if>			        	
			        	</c:forEach>
			        	<c:if test="${count < 3 }">
			        	<c:forEach var="cnt" begin="1" end="${3-count}">
			        	<td><input style="border: none; width:98%; height: 30px;" class="" type="text" id="contentsDiv" data-gubun="" name="contentsDiv" placeholder="내용을 입력해주세요."/></td>
			        	</c:forEach>
			        	</c:if>
			        	
			        	<td>비고</td>		        	
			        </tr>
			        <tr>
			        	<td rowspan="2" class="hftitle">사진</td>			        	
			        </tr>
			        <tr>
		        		<c:set var="count" value="0" />
			        	<c:forEach items="${senseQualityData.contentsList}" var="contentsList" varStatus="status">
			        	<c:if test="${status.index >= startNo && status.index <= endNo}">
			        	<c:set var="count" value="${count + 1}" />
			        	<td style="height: 250px">
			        		<div>
			        		<p><img id="preview" src="/images${contentsList.FILE_PATH}/${contentsList.ORG_FILE_NAME}" style="border:1px solid #e1e1e1; border-radius:5px; width:278px; height:223px;"></p>
			        		<div style=" z-index:3; position:relative;right:-265px; top:-225px; width: 25px; height: 25px;">
								<img src="/resources/images/btn_table_header01_del02.png" onClick="fn_deleteImageFile2(this, event)">
							</div>
							<input type="hidden" name="displayOrder" id="displayOrder" value="${contentsList.DISPLAY_ORDER}">
							<input type="hidden" name="contentsIdx" id="contentsIdx" value="${contentsList.CONTENTS_IDX}">
							<input type="hidden" name="dataStatus" id="dataStatus" value="U">
							</div>
							<div style="display:none">
								<p><img id="preview" src="/resources/images/img_noimg3.png" style="border:1px solid #e1e1e1; border-radius:5px; width:258px; height:193px;"></p>
								<p class="pt10">
									<div class="add_file2" style="width:100%; align:center;" onclick="fn_fileDivClick(event)">
										<input type="file" name="file" id="fileImageInput${status.index+1}" accept="image/*" style="display:none;" onchange="fn_changeImageFile(this, event)" data-order="${status.index+1}">
										<label for="fileImageInput${status.index+1}" style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>
									</div>	
								</p>
								<div style=" z-index:3; position:relative;right:-260px; top:-238px; width: 25px; height: 25px;">
									<img src="/resources/images/btn_table_header01_del02.png" onClick="fn_deleteImageFile(this, event)">
								</div>
							</div>
			            </td>
			            </c:if>
			        	</c:forEach>
			        	<c:if test="${count < 3 }">
			        	<c:forEach var="cnt" begin="1" end="${3-count}">
			        	<td style="height: 250px">
			        		<p><img id="preview" src="/resources/images/img_noimg3.png" style="border:1px solid #e1e1e1; border-radius:5px; width:258px; height:193px;"></p>
							<p class="pt10">
								<div class="add_file2" style="width:100%; align:center;" onclick="fn_fileDivClick(event)">
									<input type="file" name="file" id="fileImageInput${cnt+1}" accept="image/*" style="display:none;" onchange="fn_changeImageFile(this, event)" data-order="${cnt+1}">
									<label for="fileImageInput${cnt+1}" style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>
								</div>	
							</p>
							<div style=" z-index:3; position:relative;right:-260px; top:-238px; width: 25px; height: 25px;">
								<img src="/resources/images/btn_table_header01_del02.png" onClick="fn_deleteImageFile(this, event)">
							</div>
			        	</td>
			        	</c:forEach>
			        	</c:if>
			            <td rowspan="2" class="hftitle">
			        		<textarea style="border: ; width:98%; height: 99%;" id="contentsNote" name="contentsNote">${senseQualityData.infoNoteList[0].INFO_TEXT}</textarea>
			        	</td>
			        </tr>
			        
			        <tr>
			        	<td class="hftitle"> 결과 </td>
			        	<c:set var="count" value="0" />
			      		<c:forEach items="${senseQualityData.contentsList}" var="contentsList" varStatus="status">
			        	<c:if test="${status.index >= startNo && status.index <= endNo}">
			        	<c:set var="count" value="${count + 1}" />
			        	<td>
			        		<textarea style="border: ; width:98%; height: 80px;" id="contentsResult" name="contentsResult">${contentsList.CONTENTS_RESULT}</textarea>	
			        	</td>
			        	</c:if>
			        	</c:forEach>
			        	<c:if test="${count < 3 }">
			        	<c:forEach var="cnt" begin="1" end="${3-count}">
			        	<td>
			        		<textarea style="border: ; width:98%; height: 80px;" id="contentsResult" name="contentsResult"></textarea>
			        	</td>
			        	</c:forEach>
			        	</c:if>	
			        </tr>
			      </table> <!-- 첨부파일 고정 -->
			</div>

			<c:forEach var="no" begin="1" end="${senseQualityData.modCount-1}">
			<c:set var="startNo" value="${no*3}"/>
			<c:set var="endNo" value="${no*3+2}"/>
			<div id="contents_div_${no+1}">
				 <table style="width: 100%"  id="table1" class="intable lineall mb5" >
				 	<colgroup>
			            <col width="10%">
			            <col width="26%">
			            <col width="26%">
			            <col width="26%">
			            <col width="12%">			            
			        </colgroup>
			        <tr  id="contents_div_tr_${status.count}">
			        	<td >구분</td>
				        <c:set var="count" value="0" />
			        	<c:forEach items="${senseQualityData.contentsList}" var="contentsList" varStatus="status">	
			        	<c:if test="${status.index >= startNo && status.index <= endNo}">
			        	<c:set var="count" value="${count + 1}" />
			        	<td><input style="border: none; width:98%; height: 30px;" class="" type="text" id="contentsDiv" data-gubun="" name="contentsDiv" placeholder="내용을 입력해주세요." value="${contentsList.CONTENTS_DIV}"/></td>
			        	</c:if>			        	
			        	</c:forEach>
			        	<c:if test="${count < 3 }">
			        	<c:forEach var="cnt" begin="1" end="${3-count}">
			        	<td><input style="border: none; width:98%; height: 30px;" class="" type="text" id="contentsDiv" data-gubun="" name="contentsDiv" value="" placeholder="내용을 입력해주세요."/></td>
			        	</c:forEach>
			        	</c:if>	
			        	<td>비고</td>		        	
			        </tr>
			        <tr>
			        	<td class="hftitle">사진</td>			        	
			        	<c:set var="count" value="0" />
			        	<c:forEach items="${senseQualityData.contentsList}" var="contentsList" varStatus="status">
			        	<c:if test="${status.index >= startNo && status.index <= endNo}">
			        	<c:set var="count" value="${count + 1}" />
			        	<td style="height: 250px">
			        		<div>
				        		<p><img id="preview" src="/images${contentsList.FILE_PATH}/${contentsList.ORG_FILE_NAME}" style="border:1px solid #e1e1e1; border-radius:5px; width:278px; height:223px;"></p>
				        		<div style=" z-index:3; position:relative;right:-265px; top:-225px; width: 25px; height: 25px;">
									<img src="/resources/images/btn_table_header01_del02.png" onClick="fn_deleteImageFile2(this, event)">
								</div>
								<input type="hidden" name="displayOrder" id="displayOrder" value="${contentsList.DISPLAY_ORDER}">
								<input type="hidden" name="contentsIdx" id="contentsIdx" value="${contentsList.CONTENTS_IDX}">
								<input type="hidden" name="dataStatus" id="dataStatus" value="U">
							</div>
							<div style="display:none">
								<p><img id="preview" src="/resources/images/img_noimg3.png" style="border:1px solid #e1e1e1; border-radius:5px; width:258px; height:193px;"></p>
								<p class="pt10">
									<div class="add_file2" style="width:100%; align:center;" onclick="fn_fileDivClick(event)">
										<input type="file" name="file" id="fileImageInput${status.index+1}" accept="image/*" style="display:none;" onchange="fn_changeImageFile(this, event)" data-order="${status.index+1}">
										<label for="fileImageInput${status.index+1}" style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>
									</div>	
								</p>
								<div style=" z-index:3; position:relative;right:-260px; top:-238px; width: 25px; height: 25px;">
									<img src="/resources/images/btn_table_header01_del02.png" onClick="fn_deleteImageFile(this, event)">
								</div>
							</div>	
			            </td>
			            </c:if>
			        	</c:forEach>
			        	<c:if test="${count < 3 }">
			        	<c:forEach var="cnt" begin="1" end="${3-count}">
			        	<td style="height: 250px">
			        		<p><img id="preview" src="/resources/images/img_noimg3.png" style="border:1px solid #e1e1e1; border-radius:5px; width:258px; height:193px;"></p>
							<p class="pt10">
								<div class="add_file2" style="width:100%; align:center;" onclick="fn_fileDivClick(event)">
									<input type="file" name="file" id="fileImageInput${no*3+cnt+1}" accept="image/*" style="display:none;" onchange="fn_changeImageFile(this, event)" data-order="${no*3+cnt+1}">
									<label for="fileImageInput${no*3+cnt+1}" style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>
								</div>	
							</p>
							<div style=" z-index:3; position:relative;right:-255px; top:-238px; width: 25px; height: 25px;">
								<img src="/resources/images/btn_table_header01_del02.png" onClick="fn_deleteImageFile(this, event)">
							</div>
			        	</td>
			        	</c:forEach>
			        	</c:if>
			            <td rowspan="2" class="hftitle">
			        		<textarea style="border: ; width:98%; height: 99%;" id="contentsNote" name="contentsNote">${senseQualityData.infoNoteList[no].INFO_TEXT}</textarea>
			        	</td>
			        </tr>
			        
			        <tr>
			        	<td class="hftitle"> 결과 </td>
			        	<c:set var="count" value="0" />
			      		<c:forEach items="${senseQualityData.contentsList}" var="contentsList" varStatus="status">
			        	<c:if test="${status.index >= startNo && status.index <= endNo}">
			        	<c:set var="count" value="${count + 1}" />
			        	<td>
			        		<textarea style="border: ; width:98%; height: 80px;" id="contentsResult" name="contentsResult">${contentsList.CONTENTS_RESULT}</textarea>	
			        	</td>
			        	</c:if>
			        	</c:forEach>
			        	<c:if test="${count < 3 }">
			        	<c:forEach var="cnt" begin="1" end="${3-count}">
			        	<td>
			        		<textarea style="border: ; width:98%; height: 80px;" id="contentsResult" name="contentsResult"></textarea>
			        	</td>
			        	</c:forEach>
			        	</c:if>	
			        </tr>
			      </table> 
			</div>
			</c:forEach>
			
			<c:set var="rowLimit" value="4"/>
			<c:forEach var="no" begin="0" end="${rowLimit - senseQualityData.modCount}">
			<div id="contents_div_${senseQualityData.modCount+no+1}" style="display:none">
				 <table style="width: 100%"  id="table1" class="intable lineall mb5" >
				 	<colgroup>
			            <col width="10%">
			            <col width="26%">
			            <col width="26%">
			            <col width="26%">
			            <col width="12%">			            
			        </colgroup>
			        <tr  id="contents_div_tr_${senseQualityData.modCount+no+1}">
			        	<td >구분</td>
			        	<td><input style="border: none; width:98%; height: 30px;" class="" type="text" id="contentsDiv" data-gubun="" name="contentsDiv" value="" placeholder="내용을 입력해주세요."/></td>
			        	<td><input style="border: none; width:98%; height: 30px;" class="" type="text" id="contentsDiv" data-gubun="" name="contentsDiv" value="" placeholder="내용을 입력해주세요."/></td>
			        	<td><input style="border: none; width:98%; height: 30px;" class="" type="text" id="contentsDiv" data-gubun="" name="contentsDiv" value="" placeholder="내용을 입력해주세요."/></td>	
			        	<td>비고</td>		        	
			        </tr>
			        <tr>
			        	<td class="hftitle">사진</td>			        	
			        	<td style="height: 250px">
			        		<p><img id="preview" src="/resources/images/img_noimg3.png" style="border:1px solid #e1e1e1; border-radius:5px; width:258px; height:193px;"></p>
							<p class="pt10">
								<div class="add_file2" style="width:100%; align:center;" onclick="fn_fileDivClick(event)">
									<input type="file" name="file" id="fileImageInput${(senseQualityData.modCount+no-1)*3+4}" accept="image/*" style="display:none;" onchange="fn_changeImageFile(this, event)" data-order="${(senseQualityData.modCount+no-1)*3+4}">
									<label for="fileImageInput${(senseQualityData.modCount+no-1)*3+4}" style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>
								</div>	
							</p>
							<div style=" z-index:3; position:relative;right:-255px; top:-238px; width: 25px; height: 25px;">
								<img src="/resources/images/btn_table_header01_del02.png" onClick="fn_deleteImageFile(this, event)">
							</div>
			            </td>
			            <td style="height: 120px">
			            	<p><img id="preview" src="/resources/images/img_noimg3.png" style="border:1px solid #e1e1e1; border-radius:5px; width:258px; height:193px;"></p>
							<p class="pt10">
								<div class="add_file2" style="width:100%; align:center;" onclick="fn_fileDivClick(event)">
									<input type="file" name="file" id="fileImageInput${(senseQualityData.modCount+no-1)*3+5}" accept="image/*" style="display:none;" onchange="fn_changeImageFile(this, event)" data-order="${(senseQualityData.modCount+no-1)*3+5}">
									<label for="fileImageInput${(senseQualityData.modCount+no-1)*3+5}" style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>
								</div>	
							</p>
							<div style=" z-index:3; position:relative;right:-255px; top:-238px; width: 25px; height: 25px;">
								<img src="/resources/images/btn_table_header01_del02.png" onClick="fn_deleteImageFile(this, event)">
							</div>
			            </td>
			            <td style="height: 120px">
			            	<p><img id="preview" src="/resources/images/img_noimg3.png" style="border:1px solid #e1e1e1; border-radius:5px; width:258px; height:193px;"></p>
							<p class="pt10">
								<div class="add_file2" style="width:100%; align:center;" onclick="fn_fileDivClick(event)">
									<input type="file" name="file" id="fileImageInput${(senseQualityData.modCount+no-1)*3+6}" accept="image/*" style="display:none;" onchange="fn_changeImageFile(this, event)" data-order="${(senseQualityData.modCount+no-1)*3+6}">
									<label for="fileImageInput${(senseQualityData.modCount+no-1)*3+6}" style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>
								</div>	
							</p>
							<div style=" z-index:3; position:relative;right:-255px; top:-238px; width: 25px; height: 25px;">
								<img src="/resources/images/btn_table_header01_del02.png" onClick="fn_deleteImageFile(this, event)">
							</div>
			            </td>
			            <td rowspan="2" class="hftitle">
			        		<textarea style="border: ; width:98%; height: 99%;" id="contentsNote" name="contentsNote"></textarea>
			        	</td>
			        </tr>
			        
			        <tr>
			        	<td class="hftitle"> 결과 </td>
			        	<td>
			        		<textarea style="border: ; width:98%; height: 80px;" id="contentsResult" name="contentsResult"></textarea>			        		
			        	</td>
			        	<td>
			        		<textarea style="border: ; width:98%; height: 80px;" id="contentsResult" name="contentsResult"></textarea>			        		
			        	</td>
			        	<td>
			        		<textarea style="border: ; width:98%; height: 80px;" id="contentsResult" name="contentsResult"></textarea>			        		
			        	</td>
			        </tr>
			      </table> 
			</div>
			</c:forEach>
			<div class="title2"  style="width: 80%;"><span class="txt">결론</span></div>
			<div class="title2" style="width: 20%; display: inline-block;">
				<button class="btn_con_search" onClick="fn_addCol('result')" id="feature_add_btn">
					<img src="/resources/images/icon_s_write.png" />추가 
				</button>
				<button class="btn_con_search" onClick="fn_delCol('result')">
					<img src="/resources/images/icon_s_del.png" />삭제 
				</button>
			</div>
			<div class="main_tbl">
				<table class="insert_proc01">
					<colgroup>
						<col width="20" />
						<col  />							
					</colgroup>
					<tbody id="result_tbody" name="result_tbody">
					<c:set var="count" value="0" />
					<c:forEach items="${senseQualityData.infoResultList}" var="infoResultList" varStatus="status">
						<c:set var="count" value="${count + 1}" />
						<tr id="result_tr_${status.count}">
							<td>
								<input type="checkbox" id="result_${status.count}"><label for="result_${status.count}"><span></span></label>
							</td>
							<td>
								<input type="text"  style="width:99%; float: left" class="req" name="result" value="${infoResultList.INFO_TEXT}"/>
							</td>
						</tr>
					</c:forEach>
					<c:if test="${count == 0 }">
						<tr id="result_tr_1">
							<td>
								<input type="checkbox" id="result_1"><label for="result_1}"><span></span></label>
							</td>
							<td>
								<input type="text"  style="width:99%; float: left" class="req" name="result" value="가."/>
							</td>
						</tr>
					</c:if>	
					</tbody>
					<tbody id="result_tbody_temp" name="result_tbody_temp" style="display:none">
						<tr id="result_tmp_tr_1"> 
							<td>
								<input type="checkbox" id="result_1"><label for="result_1"><span></span></label>
							</td>
							<td>
								<input type="text"  style="width:99%; float: left" class="req" name="result"/>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<!-- 
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
			 -->
			 	
			<div class="main_tbl">
				<div class="btn_box_con5">
					<button class="btn_admin_gray" onClick="fn_goList();" style="width: 120px;">목록</button>
				</div>
				<div class="btn_box_con4">
					<!-- 
					<button class="btn_admin_red">임시/템플릿저장</button>
					<button class="btn_admin_navi">임시저장</button>
					 -->
					<c:if test="${senseQualityData.reportMap.STATUS == 'TMP'}">
					<button class="btn_admin_navi" onclick="fn_updateTmp()">임시저장</button>
					</c:if>
					<button class="btn_admin_sky" onclick="fn_update()">저장</button>
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
	<input type="hidden" id="docType" value="SENSE_QUALITY"/>
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
			<span class="title">관능&품질평가 테스트 결과보고서 결재 상신</span>
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
<!-- 코드검색 추가레이어 close-->
<!-- SAP 코드 검색 레이어 close-->