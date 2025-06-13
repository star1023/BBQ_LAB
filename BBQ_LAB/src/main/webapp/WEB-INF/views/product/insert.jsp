<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>개발완료보고서 생성</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 200px; min-height:200px;}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">

<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../resources/js/jstree.js"></script>
<script type="text/javascript" src="../resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	$(document).ready(function(){
		CreateEditor("contents");		
		fn_loadCategory();
		
		$("#scheduleDate").datepicker({
			showOn: "both",
			buttonImage: "../resources/images/btn_calendar.png",
			buttonImageOnly: true,
			buttonText: "Select date",
			dateFormat: "yy-mm-dd",
			showButtonPanel: true,
			showAnim: ""
		});
		
		fn.autoComplete($("#keyword"));
	});
	
	var selectedArr = new Array();
	let _brandFullList = []; // 전체 브랜드 저장용 전역변수
	
	
	function loadCode(codeId,selectBoxId) {
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
	
	function fn_loadCategory() {
		var URL = "../common/categoryListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				pId : "2"
			},
			dataType:"json",
			async:false,
			success:function(data) {
				fn_createJSTree(data);
			},
			error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	}
	
	function fn_createJSTree(data) {
		$("#jsTree").jstree(
			{
				'core' : {
					'data' : data
				},
				"plugins" : [ "wholerow" ]
		   	}
		).bind("loaded.jstree",function(){
			 $(this).jstree("open_all");
		}).on("select_node.jstree",function(e,data){
			selectedArr = new Array();
			console.log(e);
			console.log("data : "+data);
			var selectTxtFull = "";
			var parents = data.node.parents;
			var selectTxt = data.node.text;
			var selectId = data.node.id;
			console.log("parents : "+parents);
			console.log("selectTxt : "+selectTxt);
			selectedArr.push(selectId);
			selectTxtFull += selectTxt;
			
			$.each(parents, function( index, value ){ //배열-> index, value
				if( value != '#' ) { 
					console.log($.jstree.reference('#jsTree').get_node(value).text);
					//console.log($(this).jstree(true).get_node(value).text);					
					selectedArr.push(value);
					//selectTxtFull = $(this).jstree(true).get_node(value).text + ">" +selectTxtFull
					selectTxtFull = $.jstree.reference('#jsTree').get_node(value).text + ">" +selectTxtFull
				}
			});
			console.log(selectedArr);
			//$("#selectTxtFull").html(selectTxtFull);
			$("#selectTxtFull").val(selectTxtFull);
			closeDialog('dialog_product');
		});
		//.bind("refresh.jstree",function(){
		//	
		//});
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
		$("#productSapCode").val(SAP_CODE);
		$("#isSample").val("N");
		$("#keepCondition").val(KEEP_CONDITION);
		//$("#width").val(WIDTH);
		//$("#length").val(LENGTH);
		//$("#height").val(HEIGHT);
		$("#weight").val(TOTAL_WEIGHT);
		$("#standard").val(STANDARD);
		//$("#origin").val(ORIGIN);
		$("#expireDate").val(EXPIRATION_DATE);
		fn_closeErpMatRayer();
	}
	
	function selectNewCode() {
		console.log("새 코드를 조회한다.");
		var URL = "../product/selectNewCodeAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{},
			dataType:"json",
			async:false,
			success:function(data) {
				$("#productCode").val("P"+data);
				$("#isSample").val("Y");
			},
			error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
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
		
		if( $('input:checkbox[name=docType]:checked').length == 0 ) {
			alert("첨부파일 유형을 선택해주세요.");
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
	
	function changeNewMat(e){
		var newMat = $('input[name=newMat]:checked').val();
		if( newMat == "Y" ) {
			$("#matNewDiv").show();
		} else {
			$("#matNewDiv").hide();
		}
	}
	
	function addRow(element, type){
			
		var randomId = randomId = Math.random().toString(36).substr(2, 9);
		var randomId2 = randomId = Math.random().toString(36).substr(2, 9);
		var row= '';
		if( type == 'newMat' ) {
			var row= '<tr>'+$('tbody[name=tmpMatTbody]').children('tr').html()+'</tr>';
		} else {
			var row= '<tr>'+$('tbody[name=tmpMatTbody2]').children('tr').html()+'</tr>';
		}

		$(element).parent().parent().next().children('tbody').append(row);
		var bodyId = $(element).parent().parent().next().children('tbody').attr('id').split('_')[1];
		$(element).parent().parent().next().children('tbody').children('tr:last').attr('id', type + 'Row_' + randomId);
		//$(element).parent().parent().next().children('tbody').children('tr:last').attr('id', 'matRow_' + randomId);
		$(element).parent().parent().next().children('tbody').children('tr:last').children('td').children('input[type=checkbox]').attr('id', type+'_'+randomId);
		$(element).parent().parent().next().children('tbody').children('tr:last').children('td').children('label').attr('for', type+'_'+randomId);
		if( type == 'newMat' ) {
			$(element).parent().parent().next().children('tbody').children('tr:last').children('td').children('input[name=itemType]').val("Y");
		} else {
			$(element).parent().parent().next().children('tbody').children('tr:last').children('td').children('input[name=itemType]').val("N");
		}
		//var itemSapCodeElement = $(element).parent().parent().next().children('tbody').children('tr:last').children('td').children('input[name=itemSapCode]');
		//bindEnterKeySapCode(itemSapCodeElement);
	}
	
	function removeRow(element){
		var tbody = $(element).parent().parent().next().children('tbody');
		var checkboxArr = tbody.children('tr').children('td').children('input[type=checkbox]').toArray();
		
		var checkedCnt = 0;
		var checkedId;
		checkboxArr.forEach(function(v, i){
			if($(v).is(':checked')){
				checkedCnt++;
			}
		});
		
		if(checkedCnt == 0) return alert('삭제하실 항목을 선택해주세요');
		
		$(element).parent().parent().next().children('tbody').children('tr').toArray().forEach(function(v, i){
			var checkBoxId = $(v).children('td:first').children('input[type=checkbox]')[0].id;
			if($('#'+checkBoxId).is(':checked')) $(v).remove();
		})
	}
	
	function moveUp(element){
		var tbody = $(element).parent().parent().next().children('tbody');
		var checkboxArr = tbody.children('tr').children('td').children('input[type=checkbox]').toArray();
		
		var checkedCnt = 0;
		var checkedId;
		checkboxArr.forEach(function(v, i){
			if($(v).is(':checked')){
				checkedCnt++;
			}
		});
		
		if(checkedCnt == 0) return alert('이동시키려는 열을 선택해주세요');
		
		if(checkedCnt > 1) return alert('열을 이동하는 하는 경우에는 1개의 열만 선택해주세요');
		
		
		checkboxArr.forEach(function(v, i){
			if($(v).is(':checked')){
				checkedId = v.id
				
				var $element = $('#'+checkedId).parent().parent();
				$element.prev().before($element);
			}
		});
	}
	
	function moveDown(element){
		var tbody = $(element).parent().parent().next().children('tbody');
		var checkboxArr = tbody.children('tr').children('td').children('input[type=checkbox]').toArray();
		
		var checkedCnt = 0;
		var checkedId;
		
		checkboxArr.reverse().forEach(function(v, i){
			if($(v).is(':checked')){
				checkedCnt++;
			}
		});
		
		if(checkedCnt == 0) return alert('이동시키려는 열을 선택해주세요');
		
		if(checkedCnt > 1) return alert('열을 이동하는 하는 경우에는 1개의 열만 선택해주세요');
		
		
		checkboxArr.reverse().forEach(function(v, i){
			if($(v).is(':checked')){
				checkedId = v.id
				
				var $element = $('#'+checkedId).parent().parent();
				$element.next().after($element);
			}
		});
	}
	
	function checkAll(e){
		var tbody = $(e.target).parent().parent().parent().next();
		tbody.children('tr').children('td').children('input[type=checkbox]').toArray().forEach(function(checkbox){
			if(e.target.checked)
				checkbox.checked = true;
			else 
				checkbox.checked = false;
		})
	}
	
	function checkMaterail(e,type){
		if(e.keyCode != 13){
			return;
		}
		var element = e.target
		
		//var userSapCode = e.target.value;
		var userMatCode = e.target.value;
		console.log(userMatCode);
		var rowId = $(element).parent().parent().attr('id');
		var URL = '/product/checkMaterialAjax';
		if( type == 'mat' ) {
			URL = '/product/checkErpMaterialAjax';
		}
		$.ajax({
			url: URL,
			type: 'post',
			dataType: 'json',
			data: {
				matCode: userMatCode
				, sapCode: userSapCode
			},
			success: function(data){
				var materailList = data;
				//if(false){
				if(materailList.length == 1){
					//pop
					var item = materailList[0];
					var varKeep = nvl2(item.KEEP_CONDITION,'');
					var varExp = nvl2(item.EXPIRATION_DATE,'');
					var varKeepExp = "";
					if( varKeep != '' && varExp != '' ) {
						varKeepExp = varKeep+" / "+varExp;
					} else {
						if( varKeep != '' ) {
							varKeepExp = varKeep;
						}
						
						if( varExp != '' ) {
							varKeepExp = varExp;
						}
					}
					
					if(item.isSample == 'Y'){
						$('#'+rowId).css('background-color', '#ffdb8c'); //#ffdb8c
					} else {
						$('#'+rowId).css('background-color', '#fff');
					}
				} else {
					// popup
					openMaterialPopup($(element).next(),type);
				}
			},
			error: function(a,b,c){
				//console.log(a,b,c)
				alert('갱신 실패[2] - 시스템 담당자에게 문의하세요.');
			}
		})
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
		
		var URL = '/product/selectMaterialAjax';
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
	
	function fn_closeMatRayer(){
		$('#searchMatValue').val('')
		$('#matLayerBody').empty();
		$('#matLayerBody').append('<tr><td colspan="10">원료코드 혹은 원료코드명을 검색해주세요</td></tr>');
		$('#matCount').text(0);
		closeDialog('dialog_material');
	}
	
	function setMaterialPopupData(parentRowId, itemMatIdx, itemMatCode, itemSAPCode, itemName, itemUnitPrice, itemUnit, itemStandard, itemKeep, itemExp){
		var varMatIdx = nvl2(itemMatIdx,'0');
		var varKeep = nvl2(itemKeep,'');
		var varExp = nvl2(itemExp,'');
		var varPrice = nvl2(itemUnitPrice,'');

		var varKeepExp = "";
		if( varKeep != '' && varExp != '' ) {
			varKeepExp = varKeep+" / "+varExp;
		} else {
			if( varKeep != '' ) {
				varKeepExp = varKeep;
			}
			
			if( varExp != '' ) {
				varKeepExp = varExp;
			}
		}
		$('#'+parentRowId + ' input[name$=itemMatIdx]').val(varMatIdx);
		$('#'+parentRowId + ' input[name$=itemMatCode]').val(itemMatCode);
		$('#'+parentRowId + ' input[name$=itemSapCode]').val(itemSAPCode);
		$('#'+parentRowId + ' input[name$=itemName]').val(itemName);
		$('#'+parentRowId + ' input[name$=itemStandard]').val(nvl2(itemStandard,''));

		$('#'+parentRowId + ' input[name$=itemKeepExp]').val(varKeepExp);
		$('#'+parentRowId + ' input[name$=itemUnitPrice]').val(varPrice);
				
		fn_closeMatRayer();
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
	function fn_insertTmp(){
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			$("#title").focus();
			return;
		} else {
			$('#lab_loading').show();
			var contents = editor.getData();
			var formData = new FormData();
			formData.append("title",$("#title").val());
			formData.append("productName",$("#productName").val());
			
			var purposeArr = new Array();
			$('tr[id^=purpose_tr]').toArray().forEach(function(purposeRow){
				var rowId = $(purposeRow).attr('id');
				purposeArr.push($('#'+ rowId + ' input[name=purpose]').val());
			});		
			formData.append("purposeArr", JSON.stringify(purposeArr));		
			
			var featureArr = new Array();
			$('tr[id^=feature_tr]').toArray().forEach(function(featureRow){
				var rowId = $(featureRow).attr('id');
				featureArr.push($('#'+ rowId + ' input[name=feature]').val());
			});
			formData.append("featureArr", JSON.stringify(featureArr));
			
			// 용도
			const usageType = $('select[name=usageSelect]').val();

			if (usageType === 'BRAND') {
			    const brandCodes = $('#brandCodeValues_1').val(); // 예: "1,2,3"
			    if (brandCodes) {
			        formData.append("usageArr", brandCodes); // 그대로 넣음
			    }
			} else if (usageType === 'CUSTOM') {
			    const customText = $('#customUsage_1').val();
			    if (customText) {
			        formData.append("usageArr", customText.trim()); // 문자열 그대로 넣음
			    }
			}
			formData.append("usageType", usageType); // 그대로 넣음
			
			var newItemNameArr = new Array();
			var newItemStandardArr = new Array();
			var newItemSupplierArr = new Array();
			var newItemKeepExpArr = new Array();
			var newItemNoteArr = new Array();
			$('tr[id^=new_tr]').toArray().forEach(function(newRow){
				var rowId = $(newRow).attr('id');
				newItemNameArr.push($('#'+ rowId + ' input[name=itemName]').val());
				newItemStandardArr.push($('#'+ rowId + ' input[name=itemStandard]').val());
				newItemSupplierArr.push($('#'+ rowId + ' input[name=itemSupplier]').val());
				newItemKeepExpArr.push($('#'+ rowId + ' input[name=itemKeepExp]').val());
				newItemNoteArr.push($('#'+ rowId + ' input[name=itemNote]').val());
			});
			formData.append("newItemNameArr", JSON.stringify(newItemNameArr));	
			formData.append("newItemStandardArr", JSON.stringify(newItemStandardArr));	
			formData.append("newItemSupplierArr", JSON.stringify(newItemSupplierArr));	
			formData.append("newItemKeepExpArr", JSON.stringify(newItemKeepExpArr));	
			formData.append("newItemNoteArr", JSON.stringify(newItemNoteArr));	
			
			formData.append("scheduleDate",$("#scheduleDate").val());
			
			
			formData.append("productCode",$("#productCode").val());
			formData.append("productSapCode",$("#productSapCode").val());		
			formData.append("weight",$("#weight").val());
			formData.append("standard",$("#standard").val());
			formData.append("keepCondition",$("#keepCondition").val());
			formData.append("expireDate",$("#expireDate").val());
			formData.append("contents",contents);
			formData.append("newMat",$('input[name=newMat]:checked').val());
			formData.append("productType",selectedArr);
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
			
			$('select[name=docTypeTemp] option:selected').each(function(index){
				formData.append('docType', $(this).attr('value'));
				formData.append('docTypeText', $(this).text());
			});
			
			$('select[name=tempFileList] option:selected').each(function(index){
				formData.append('tempFile', $(this).attr('value'));							
			});
			
			var rowIdArr = new Array();
			var itemTypeArr = new Array();
			var itemMatIdxArr = new Array();
			var itemMatCodeArr = new Array();
			var itemSapCodeArr = new Array();
			var itemNameArr = new Array();
			var itemStandardArr = new Array();
			var itemKeepExpArr = new Array();
			var itemUnitPriceArr = new Array();
			var itemDescArr = new Array();
			
			if( $('input[name=newMat]:checked').val() == 'Y' ) {
				$('tr[id^=newMatRow]').toArray().forEach(function(contRow){
					var rowId = $(contRow).attr('id');
					var itemType = $('#'+ rowId + ' input[name=itemType]').val();
					var itemMatIdx = $('#'+ rowId + ' input[name=itemMatIdx]').val();
					var itemMatCode = $('#'+ rowId + ' input[name=itemMatCode]').val();
					var itemSapCode = $('#'+ rowId + ' input[name=itemSapCode]').val();
					var itemName = $('#'+ rowId + ' input[name=itemName]').val();
					var itemStandard = $('#'+ rowId + ' input[name=itemStandard]').val();
					var itemKeepExp = $('#'+ rowId + ' input[name=itemKeepExp]').val();
					var itemUnitPrice = $('#'+ rowId + ' input[name=itemUnitPrice]').val();
					var itemDesc = $('#'+ rowId + ' input[name=itemDesc]').val();
					rowIdArr.push(rowId);
					itemTypeArr.push(itemType);
					itemMatIdxArr.push(itemMatIdx);
					itemMatCodeArr.push(itemMatCode);
					itemSapCodeArr.push(itemSapCode);
					itemNameArr.push(itemName);
					itemStandardArr.push(itemStandard);
					itemKeepExpArr.push(itemKeepExp);
					itemUnitPriceArr.push(itemUnitPrice);
					itemDescArr.push(itemDesc);
				});
			}

			$('tr[id^=matRow]').toArray().forEach(function(contRow){
				var rowId = $(contRow).attr('id');
				var itemType = $('#'+ rowId + ' input[name=itemType]').val();
				var itemMatIdx = $('#'+ rowId + ' input[name=itemMatIdx]').val();
				var itemMatCode = $('#'+ rowId + ' input[name=itemMatCode]').val();
				var itemSapCode = $('#'+ rowId + ' input[name=itemSapCode]').val();
				var itemName = $('#'+ rowId + ' input[name=itemName]').val();
				var itemStandard = $('#'+ rowId + ' input[name=itemStandard]').val();
				var itemKeepExp = $('#'+ rowId + ' input[name=itemKeepExp]').val();
				var itemUnitPrice = $('#'+ rowId + ' input[name=itemUnitPrice]').val();
				var itemDesc = $('#'+ rowId + ' input[name=itemDesc]').val();
				if( itemSapCode != '' ) {
					rowIdArr.push(rowId);
					itemTypeArr.push(itemType);
					itemMatIdxArr.push(itemMatIdx);
					itemMatCodeArr.push(itemMatCode);
					itemSapCodeArr.push(itemSapCode);
					itemNameArr.push(itemName);
					itemStandardArr.push(itemStandard);
					itemKeepExpArr.push(itemKeepExp);
					itemUnitPriceArr.push(itemUnitPrice);
					itemDescArr.push(itemDesc);
				}
			});
			
			formData.append("rowIdArr", JSON.stringify(rowIdArr));
			formData.append("itemTypeArr", JSON.stringify(itemTypeArr));
			formData.append("itemMatIdxArr", JSON.stringify(itemMatIdxArr));
			formData.append("itemMatCodeArr", JSON.stringify(itemMatCodeArr));
			formData.append("itemSapCodeArr", JSON.stringify(itemSapCodeArr));
			formData.append("itemNameArr", JSON.stringify(itemNameArr));
			formData.append("itemStandardArr", JSON.stringify(itemStandardArr));
			formData.append("itemKeepExpArr", JSON.stringify(itemKeepExpArr));
			formData.append("itemUnitPriceArr", JSON.stringify(itemUnitPriceArr));
			formData.append("itemDescArr", JSON.stringify(itemDescArr));
			
			URL = "../product/insertTmpProductAjax";
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
	function fn_insert(){
		var contents = editor.getData();
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			$("#title").focus();
			return;
		} else if( !chkNull($("#productCode").val()) ) {
			alert("제품 코드를 입력해 주세요.");
			$("#productCode").focus();
			return;
		} else if( !chkNull($("#productName").val()) ) {
			alert("제품명을 입력해 주세요.");
			$("#productName").focus();
			return;
		} else if( !chkNull($("#selectTxtFull").val()) ) {
			alert("제품유형을 선택해 주세요.");
			return;
		} else if( selectedArr.length == 0 ) {
			alert("제품유형을 선택하여 주세요.");		
			return;
		} else if( attatchFileArr.length == 0 && $("#tempFileList option").length == 0 ) {
			alert("첨부파일을 등록해주세요.");		
			return;			
		} else {
			if( $('input[name=newMat]:checked').val() == 'Y' ) {
				var matCount = 0;
				var validMat = true;
				$('tr[id^=newMatRow]').toArray().forEach(function(contRow){
					var rowId = $(contRow).attr('id');
					var itemSapCode = $('#'+ rowId + ' input[name=itemSapCode]').val();
					var itemName = $('#'+ rowId + ' input[name=itemName]').val();
					var mixingRatio = $('#'+ rowId + ' input[name=mixingRatio]').val();
					
					if(itemSapCode.length <= 0){
						validMat = false;
						return;
					}
					if(itemName.length <= 0){
						validMat = false;
						return;
					}
					matCount++;
				})
				if( matCount == 0 || !validMat) {
					alert('원료를 입력해주세요.');
					return;
				}
			}			
			//기존 데이터 확인
			$('#lab_loading').show();
			var URL = "../product/selectProductCountAjax";
			$.ajax({
				type:"POST",
				url:URL,
				data:{
					"productCode":$("#productCode").val()
				},
				dataType:"json",
				success:function(result) {
					if( result.COUNT > 0 ) {
						alert("이미 존재하는 코드입니다.");
						$('#lab_loading').hide();
					    return;
					} else {
						var formData = new FormData();
						formData.append("title",$("#title").val());
						formData.append("productName",$("#productName").val());						
						
						var purposeArr = new Array();
						$('tr[id^=purpose_tr]').toArray().forEach(function(purposeRow){
							var rowId = $(purposeRow).attr('id');
							purposeArr.push($('#'+ rowId + ' input[name=purpose]').val());
						});		
						formData.append("purposeArr", JSON.stringify(purposeArr));		
						
						var featureArr = new Array();
						$('tr[id^=feature_tr]').toArray().forEach(function(featureRow){
							var rowId = $(featureRow).attr('id');
							featureArr.push($('#'+ rowId + ' input[name=feature]').val());
						});
						formData.append("featureArr", JSON.stringify(featureArr));
						
						// 용도
						const usageType = $('select[name=usageSelect]').val();

						if (usageType === 'BRAND') {
						    const brandCodes = $('#brandCodeValues_1').val(); // 예: "1,2,3"
						    if (brandCodes) {
						        formData.append("usageArr", brandCodes); // 그대로 넣음
						    }
						} else if (usageType === 'CUSTOM') {
						    const customText = $('#customUsage_1').val();
						    if (customText) {
						        formData.append("usageArr", customText.trim()); // 문자열 그대로 넣음
						    }
						}
						formData.append("usageType", usageType); // 그대로 넣음
						
						var newItemNameArr = new Array();
						var newItemStandardArr = new Array();
						var newItemSupplierArr = new Array();
						var newItemKeepExpArr = new Array();
						var newItemNoteArr = new Array();
						$('tr[id^=new_tr]').toArray().forEach(function(newRow){
							var rowId = $(newRow).attr('id');
							newItemNameArr.push($('#'+ rowId + ' input[name=itemName]').val());
							newItemStandardArr.push($('#'+ rowId + ' input[name=itemStandard]').val());
							newItemSupplierArr.push($('#'+ rowId + ' input[name=itemSupplier]').val());
							newItemKeepExpArr.push($('#'+ rowId + ' input[name=itemKeepExp]').val());
							newItemNoteArr.push($('#'+ rowId + ' input[name=itemNote]').val());
						});
						formData.append("newItemNameArr", JSON.stringify(newItemNameArr));	
						formData.append("newItemStandardArr", JSON.stringify(newItemStandardArr));	
						formData.append("newItemSupplierArr", JSON.stringify(newItemSupplierArr));	
						formData.append("newItemKeepExpArr", JSON.stringify(newItemKeepExpArr));	
						formData.append("newItemNoteArr", JSON.stringify(newItemNoteArr));	
						
						formData.append("scheduleDate",$("#scheduleDate").val());
						
						formData.append("productCode",$("#productCode").val());
						formData.append("productSapCode",$("#productSapCode").val());
						formData.append("weight",$("#weight").val());
						formData.append("standard",$("#standard").val());
						formData.append("keepCondition",$("#keepCondition").val());
						formData.append("expireDate",$("#expireDate").val());
						formData.append("contents",contents);
						formData.append("newMat",$('input[name=newMat]:checked').val());
						formData.append("productType",selectedArr);
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
						
						$('select[name=docTypeTemp] option:selected').each(function(index){
							formData.append('docType', $(this).attr('value'));
							formData.append('docTypeText', $(this).text());
						});
						
						$('select[name=tempFileList] option:selected').each(function(index){
							formData.append('tempFile', $(this).attr('value'));							
						});
						
						var rowIdArr = new Array();
						var itemTypeArr = new Array();
						var itemMatIdxArr = new Array();
						var itemMatCodeArr = new Array();
						var itemSapCodeArr = new Array();
						var itemNameArr = new Array();
						var itemStandardArr = new Array();
						var itemKeepExpArr = new Array();
						var itemUnitPriceArr = new Array();
						var itemDescArr = new Array();
						
						if( $('input[name=newMat]:checked').val() == 'Y' ) {
							$('tr[id^=newMatRow]').toArray().forEach(function(contRow){
								var rowId = $(contRow).attr('id');
								var itemType = $('#'+ rowId + ' input[name=itemType]').val();
								var itemMatIdx = $('#'+ rowId + ' input[name=itemMatIdx]').val();
								var itemMatCode = $('#'+ rowId + ' input[name=itemMatCode]').val();
								var itemSapCode = $('#'+ rowId + ' input[name=itemSapCode]').val();
								var itemName = $('#'+ rowId + ' input[name=itemName]').val();
								var itemStandard = $('#'+ rowId + ' input[name=itemStandard]').val();
								var itemKeepExp = $('#'+ rowId + ' input[name=itemKeepExp]').val();
								var itemUnitPrice = $('#'+ rowId + ' input[name=itemUnitPrice]').val();
								var itemDesc = $('#'+ rowId + ' input[name=itemDesc]').val();
								rowIdArr.push(rowId);
								itemTypeArr.push(itemType);
								itemMatIdxArr.push(itemMatIdx);
								itemMatCodeArr.push(itemMatCode);
								itemSapCodeArr.push(itemSapCode);
								itemNameArr.push(itemName);
								itemStandardArr.push(itemStandard);
								itemKeepExpArr.push(itemKeepExp);
								itemUnitPriceArr.push(itemUnitPrice);
								itemDescArr.push(itemDesc);
							});
						}

						$('tr[id^=matRow]').toArray().forEach(function(contRow){
							var rowId = $(contRow).attr('id');
							var itemType = $('#'+ rowId + ' input[name=itemType]').val();
							var itemMatIdx = $('#'+ rowId + ' input[name=itemMatIdx]').val();
							var itemMatCode = $('#'+ rowId + ' input[name=itemMatCode]').val();
							var itemSapCode = $('#'+ rowId + ' input[name=itemSapCode]').val();
							var itemName = $('#'+ rowId + ' input[name=itemName]').val();
							var itemStandard = $('#'+ rowId + ' input[name=itemStandard]').val();
							var itemKeepExp = $('#'+ rowId + ' input[name=itemKeepExp]').val();
							var itemUnitPrice = $('#'+ rowId + ' input[name=itemUnitPrice]').val();
							var itemDesc = $('#'+ rowId + ' input[name=itemDesc]').val();
							if( itemSapCode != '' ) {
								rowIdArr.push(rowId);
								itemTypeArr.push(itemType);
								itemMatIdxArr.push(itemMatIdx);
								itemMatCodeArr.push(itemMatCode);
								itemSapCodeArr.push(itemSapCode);
								itemNameArr.push(itemName);
								itemStandardArr.push(itemStandard);
								itemKeepExpArr.push(itemKeepExp);
								itemUnitPriceArr.push(itemUnitPrice);
								itemDescArr.push(itemDesc);
							}
						});
						
						formData.append("rowIdArr", JSON.stringify(rowIdArr));
						formData.append("itemTypeArr", JSON.stringify(itemTypeArr));
						formData.append("itemMatIdxArr", JSON.stringify(itemMatIdxArr));
						formData.append("itemMatCodeArr", JSON.stringify(itemMatCodeArr));
						formData.append("itemSapCodeArr", JSON.stringify(itemSapCodeArr));
						formData.append("itemNameArr", JSON.stringify(itemNameArr));
						formData.append("itemStandardArr", JSON.stringify(itemStandardArr));
						formData.append("itemKeepExpArr", JSON.stringify(itemKeepExpArr));
						formData.append("itemUnitPriceArr", JSON.stringify(itemUnitPriceArr));
						formData.append("itemDescArr", JSON.stringify(itemDescArr));
						
						URL = "../product/insertProductAjax";
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
											alert($("#productName").val()+"("+$("#productCode").val()+")"+"가 정상적으로 생성되었습니다.");
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
				},
				error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
					$('#lab_loading').hide();
				}			
			});
			
			//formdata 설정 및 저장
		}
	}

	function fn_goList() {
		location.href = '/product/list';
	}
	
	function fn_loadSearchCategory(pIdx, level) {
		
		if( level == 2 ) {
			$("#searchCategory"+(level+1)).removeOption(/./);
			$("#searchCategory"+(level+1)+"_div").hide();
		}
		
		if( pIdx == '' ) {
			$("#searchCategory"+level).removeOption(/./);
			$("#searchCategory"+level+"_div").hide();
			return;
		}
		
		var URL = "../common/selectCategoryByPIdAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				pIdx : pIdx
			},
			dataType:"json",
			async:false,
			success:function(data) {
				var list = data;
				$("#searchCategory"+level).removeOption(/./);
				$("#searchCategory"+level).addOption("", "전체", false);
				$("#searchCategory"+level+"_label").html("전체");
				if( list.length > 0 ) {
					$("#searchCategory"+level+"_div").show();
					$.each(list, function( index, value ){ //배열-> index, value
						$("#searchCategory"+level).addOption(value.CATEGORY_IDX, value.CATEGORY_NAME, false);
					});
				}
			},
			error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	}
	
	function fn_changeCategory(obj,level){
		fn_loadSearchCategory($(obj).selectedValues()[0], level);
	}
	
	function fn_copySearch() {
		fn_loadSearchCategory(2,1);
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
		$("#productLayerBody").html("<tr><td colspan=\"5\">제품코드 혹은 제품명을 검색해주세요</td></tr>");
	}
	
	function fn_search() {
		var URL = "../product/selectSearchProductAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				searchValue : $("#searchValue").val()
				, "searchCategory1" : $("#searchCategory1").selectedValues()[0]
				, "searchCategory2" : $("#searchCategory2").selectedValues()[0]
				, "searchCategory3" : $("#searchCategory3").selectedValues()[0]
			},
			dataType:"json",
			success:function(result) {
				console.log(result);
				//productLayerBody
				var jsonData = {};
				jsonData = result;
				$('#productLayerBody').empty();
				console.log(jsonData.list.length);
				if( jsonData.list.length == 0 ) {
					var html = "";
					$("#productLayerBody").html(html);
					html += "<tr><td align='center' colspan='5'>데이터가 없습니다.</td></tr>";
					$("#productLayerBody").html(html);
				} else {
					jsonData.list.forEach(function(item){
						var row = '<tr onClick="fn_copy(\''+item.PRODUCT_IDX+'\')">';
						row += '<td></td>';
						row += '<td>'+item.PRODUCT_CODE+'</td>';
						row += '<td  class="tgnl">'+item.NAME+'</td>';
						row += '<td>'+item.VERSION_NO+'</td>';
						row += "<td><div class=\"ellipsis_txt tgnl\">";
						if( chkNull(item.CATEGORY_NAME1) ) {
							row += item.CATEGORY_NAME1;
						}
						if( chkNull(item.CATEGORY_NAME2) ) {
							row += " > "+item.CATEGORY_NAME2;
						}
						if( chkNull(item.CATEGORY_NAME3) ) {
							row += " > "+item.CATEGORY_NAME3;
						}
						row += "</div></td>";
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
		console.log(idx);
		var URL = "../product/selectProductDataAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				idx : idx
			},
			dataType:"json",
			success:function(result) {
				console.log(result);
				var data = result.productData.data;
				var addInfoCount = result.addInfoCount;
				var addInfoList = result.addInfoList;
				var newDataList = result.newDataList;
				var fileList = result.productData.fileList;
				var fileType = result.productData.fileType;
				var materialList = result.productMaterialData;
				
				console.log(data);
				console.log(addInfoCount);
				console.log(addInfoList);
				console.log(newDataList);
				$("#productName").val(data.NAME);
				
				if( addInfoCount.PUR_CNT > 0 ) {
					$("#purpose_tbody").html("");
					addInfoList.forEach(function(item){
						if( item.INFO_TYPE == 'PUR' ){
							$("#purpose_add_btn").trigger("click");
							var trObj = $("#purpose_tbody tr:last");
							trObj.find("input[name='purpose']").val(item.INFO_TEXT);
						}
					});
				}
				
				if( addInfoCount.FEA_CNT > 0 ) {
					$("#feature_tbody").html("");
					addInfoList.forEach(function(item){
						if( item.INFO_TYPE == 'FEA' ){
							$("#feature_add_btn").trigger("click");
							var trObj = $("#feature_tbody tr:last");
							trObj.find("input[name='feature']").val(item.INFO_TEXT);
						}
					});
				}
				
				if( newDataList.length > 0 ) {
					$("#new_tbody").html("");
					newDataList.forEach(function(item){
						$("#new_add_btn").trigger("click");
						var trObj = $("#new_tbody tr:last");
						trObj.find("input[name='itemName']").val(item.PRODUCT_NAME);
						trObj.find("input[name='itemStandard']").val(item.PACKAGE_STANDARD);
						trObj.find("input[name='itemSupplier']").val(item.SUPPLIER);
						trObj.find("input[name='itemKeepExp']").val(item.KEEP_EXP);
						trObj.find("input[name='itemNote']").val(item.NOTE);
					});
				}
				
				$("#scheduleDate").val(data.SCHEDULE_DATE);	
				
				
				$("#productSapCode").val(data.SAP_CODE);				
				$("#weight").val(data.TOTAL_WEIGHT);
				$("#standard").val(data.STANDARD);
				$("#keepCondition").val(data.KEEP_CONDITION);
				$("#expireDate").val(data.EXPIRATION_DATE);
				var selectTxtFull = "";
				console.log(data.PRODUCT_TYPE1);
				console.log(nvl2(data.PRODUCT_TYPE1,""));
				console.log(!chkNull(nvl2(data.PRODUCT_TYPE1,"")));
				//if( !chkNull(data.PRODUCT_TYPE1) ) {
				if( nvl2(data.PRODUCT_TYPE1,"") != "" ) {	
					selectTxtFull += data.PRODUCT_TYPE_NAME1;
				}
				//if( !chkNull(data.PRODUCT_TYPE2) ) {
				if( nvl2(data.PRODUCT_TYPE2,"") != "" ) {		
					selectTxtFull += " > "+data.PRODUCT_TYPE_NAME2;
				}
				//if( !chkNull(data.PRODUCT_TYPE3) ) {
				if( nvl2(data.PRODUCT_TYPE3,"") != "" ) {	
					selectTxtFull += " > "+data.PRODUCT_TYPE_NAME3;
				}
				
				$("#selectTxtFull").val(selectTxtFull);
				
				//if( !chkNull(data.PRODUCT_TYPE3) ) {
				if( nvl2(data.PRODUCT_TYPE3,"") != "" ) {	
					selectedArr.push(data.PRODUCT_TYPE3);
				}
				//if( !chkNull(data.PRODUCT_TYPE2) ) {
				if( nvl2(data.PRODUCT_TYPE2,"") != "" ) {	
					selectedArr.push(data.PRODUCT_TYPE2);
				}
				//if( !chkNull(data.PRODUCT_TYPE1) ) {
				if( nvl2(data.PRODUCT_TYPE1,"") != "" ) {	
					selectedArr.push(data.PRODUCT_TYPE1);
				}
				$("input[name='newMat'][value='"+data.IS_NEW_MATERIAL+"']").prop("checked", true);
				
				var netMatCnt = 0;
				var matCnt = 0;
				materialList.forEach(function(item){
					if( item.MATERIAL_TYPE == 'Y' ){
						netMatCnt++;
					} else {
						matCnt++;
					}
				});
				
				if( data.IS_NEW_MATERIAL == 'Y' ) {
					if( netMatCnt > 0 ) {
						$("#newMatTbody").html("");
						$("#matNewDiv").show();
						materialList.forEach(function(item){
							if( item.MATERIAL_TYPE == 'Y' ){
								$("#matNew_add_btn").trigger("click");
								var trObj = $("#newMatTbody tr:last");
								trObj.find("input[name='itemMatIdx']").val(item.MATERIAL_IDX);
								trObj.find("input[name='itemMatCode']").val(item.MATERIAL_CODE);
								trObj.find("input[name='itemSapCode']").val(item.SAP_CODE);
								trObj.find("input[name='itemName']").val(item.NAME);
								trObj.find("input[name='itemStandard']").val(item.STANDARD);
								trObj.find("input[name='itemKeepExp']").val(item.KEEP_EXP);
								trObj.find("input[name='itemUnitPrice']").val(item.UNIT_PRICE);
								trObj.find("input[name='itemDesc']").val(item.DESCRIPTION);
							}
						});
					}
				}
				
				if( matCnt > 0 ) {
					$("#matTbody").html("");
					materialList.forEach(function(item){
						if( item.MATERIAL_TYPE == 'N' ){
							$("#mat_add_btn").trigger("click");
							var trObj = $("#matTbody tr:last");
							trObj.find("input[name='itemMatIdx']").val(item.MATERIAL_IDX);
							trObj.find("input[name='itemMatCode']").val(item.MATERIAL_CODE);
							trObj.find("input[name='itemSapCode']").val(item.SAP_CODE);
							trObj.find("input[name='itemName']").val(item.NAME);
							trObj.find("input[name='itemStandard']").val(item.STANDARD);
							trObj.find("input[name='itemKeepExp']").val(item.KEEP_EXP);
							trObj.find("input[name='itemUnitPrice']").val(item.UNIT_PRICE);
							trObj.find("input[name='itemDesc']").val(item.DESCRIPTION);
						}
					});
				} else {
					$("#matTbody").html("");
					$("#mat_add_btn").trigger("click");
				}
				
				var fileTypeTxt = "";
				fileType.forEach(function(item,index){
					$("#docTypeTemp").addOption(item.FILE_TYPE, item.FILE_TEXT, true);
					if( fileTypeTxt != ""  ){
						fileTypeTxt += ", ";
					}
					fileTypeTxt += item.FILE_TEXT;
				});
				$("#docTypeTxt").html(fileTypeTxt);

				console.log(fileList);
				if( fileList.length > 0 ) {
					$("#temp_file").show();
					fileList.forEach(function(item,index){
						$("#tempFileList").addOption(item.FILE_IDX, item.ORG_FILE_NAME, true);
						var childTag = '<li><a href="#none" onclick="removeTempFile(this, \''+item.FILE_IDX+'\')"><img src="/resources/images/icon_del_file.png"></a>'+item.ORG_FILE_NAME+'</li>'
						$("#temp_attatch_file").append(childTag);
					});
				}
				
				// 용도 초기화
				$("#usageContentArea_1").html('');
				$("select[name='usageSelect']").val(""); // 기본값으로 초기화

				addInfoList.forEach(function(item){
					if (item.INFO_TYPE === 'USB') {
						// BRAND 선택 설정 및 브랜드 내용 렌더링
						const select = document.querySelector("select[name='usageSelect']");
						select.value = "BRAND";
						onUsageChange(select, 1); // 동적으로 영역 생성

						// 브랜드 코드, 이름 파싱
						const codeArr = item.INFO_TEXT.split(",");
						const nameArr = item.INFO_TEXT_NAME.split(",");

						const tokenBox = document.getElementById("brandTokenBox_1");
						const hiddenInput = document.getElementById("brandCodeValues_1");
						tokenBox.innerHTML = '';
						let brandCodes = [];

						codeArr.forEach((code, i) => {
							const name = nameArr[i];
							brandCodes.push(code);

							const token = document.createElement("span");
							token.className = "brand-token";
							token.setAttribute("data-code", code);
							token.style = `
								display: flex;
								align-items: center;
								background: #e0e0e0;
								border-radius: 12px;
								padding: 4px 8px;
								margin-right: 5px;
								font-size: 13px;
							`;

							const removeBtn = document.createElement("span");
							removeBtn.textContent = "✕";
							removeBtn.style = `
								font-weight: bold;
								margin-right: 6px;
								cursor: pointer;
								color: #666;
							`;
							removeBtn.onclick = function () {
								token.remove();
								updateHiddenBrandCodes(1);
							};

							token.appendChild(removeBtn);
							token.append(name);
							tokenBox.appendChild(token);
						});

						hiddenInput.value = brandCodes.join(',');
					}

					if (item.INFO_TYPE === 'USC') {
						// CUSTOM 선택 설정 및 input 생성
						const select = document.querySelector("select[name='usageSelect']");
						select.value = "CUSTOM";
						onUsageChange(select, 1); // 동적으로 영역 생성

						const input = document.getElementById("customUsage_1");
						input.value = item.INFO_TEXT;
					}
				});
			},
			error:function(request, status, errorThrown){

			}			
		});
		fn_closeSearch();
	}
	
	function removeTempFile(element, tempId){
		$(element).parent().remove();
		$("#tempFileList").removeOption(tempId);
		if( $("#tempFileList option").length == 0 ) {
			$("#temp_file").hide();
		}
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

	
	function tabChange(tabId) {
		if( tabId == 'tab1' ) {
			$("#tab1_div").show();
			$("#tab1_li").prop("class","select");
			$("#tab2_div").hide();
			$("#tab2_li").prop("class","");
		} else {
			$("#tab1_div").hide();
			$("#tab1_li").prop("class","");
			$("#tab2_div").show();
			$("#tab2_li").prop("class","select");
		}
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
	
	function onUsageChange(select, idx) {
	    // label 업데이트
	    const label = select.parentNode.parentNode.querySelector('label');
	    if (label) {
  	      label.textContent = select.options[select.selectedIndex].text;
	    }
	    // 3단계 위로 올라가서 td 찾기
	    var td = select.parentNode.parentNode.parentNode;
	    var contentTd = td.nextElementSibling; // 옆에 있는 내용 td

	    contentTd.innerHTML = ''; // 내용 초기화

	    if (select.value === 'BRAND') {
	        const wrapper = document.createElement('div');
	        wrapper.style = 'width: 100%;';

	        // ✅ 전체를 감쌀 컨테이너 (토큰 + 버튼)
	        const flexContainer = document.createElement('div');
	        flexContainer.style = 'display: flex; margin-left: 10px; justify-content: space-between; align-items: center; gap: 10px;';

	        // ✅ 토큰이 보여질 영역 (왼쪽)
	        const tokenDiv = document.createElement('div');
	        tokenDiv.id = 'brandTokenBox_' + idx;
	        tokenDiv.className = 'token-box';
	        tokenDiv.style = 'display: flex; flex-wrap: wrap; gap: 5px; flex: 1;';

	        // ✅ 버튼 그룹 (오른쪽)
	        const buttonGroup = document.createElement('div');
	        buttonGroup.style = 'display: flex; gap: 5px;';

	        const btnSearch = document.createElement('button');
	        btnSearch.className = 'btn_small_search ml5';
	        btnSearch.textContent = '조회';
	        btnSearch.onclick = function () {
	            openBrandDialog(idx);
	        };

	        const btnReset = document.createElement('button');
	        btnReset.className = 'btn_small_search ml5';
	        btnReset.textContent = '초기화';
	        btnReset.onclick = function () {
	            tokenDiv.innerHTML = '';
	            hiddenInput.value = '';
	        };

	        buttonGroup.appendChild(btnSearch);
	        buttonGroup.appendChild(btnReset);

	        // ✅ 숨겨진 input (브랜드 코드 값들)
	        const hiddenInput = document.createElement('input');
	        hiddenInput.type = 'hidden';
	        hiddenInput.id = 'brandCodeValues_' + idx;
	        hiddenInput.name = 'brandCodeValues_' + idx;

	        // ✅ 조합
	        flexContainer.appendChild(tokenDiv);
	        flexContainer.appendChild(buttonGroup);
	        wrapper.appendChild(flexContainer);
	        wrapper.appendChild(hiddenInput);
	        contentTd.appendChild(wrapper);
	    } else if (select.value === 'CUSTOM') {
	        const input = document.createElement('input');
	        input.type = 'text';
	        input.id = 'customUsage_' + idx;
	        input.placeholder = '용도를 입력하세요';
	        input.className = 'req';
	        input.style = 'width:99%;';
	        contentTd.appendChild(input);
	    }
	}

	function openBrandDialog(idx) {
	    window._brandIdx = idx;
	    document.getElementById("dialog_brand").style.display = "block";

	    if (_brandFullList.length > 0) {
	        // 이미 로드된 경우 필터 없이 전체 출력
	        renderBrandTable(_brandFullList);
	        return;
	    }

	    $.ajax({
	        type: "POST",
	        url: "../common/codeListAjax",
	        data: { groupCode: "BRAND" },
	        dataType: "json",
	        success: function (data) {
	            _brandFullList = data.RESULT; // ✅ 전역 변수에 저장
	            renderBrandTable(_brandFullList); // 전체 출력
	        },
	        error: function () {
	            alert("브랜드 정보를 불러오는데 실패했습니다.");
	        }
	    });
	}
	
	function renderBrandTable(brandList) {
	    const idx = window._brandIdx;
	    const selectedCodesStr = document.getElementById("brandCodeValues_" + idx)?.value || "";
	    const selectedCodes = selectedCodesStr.split(',').map(code => code.trim());

	    const tbody = document.getElementById("brandLayerBody");
	    tbody.innerHTML = "";

	    const countElement = document.getElementById("brandCount") || document.getElementById("matCount");

	    if (!brandList || brandList.length === 0) {
	        tbody.innerHTML = "<tr><td colspan='3'>검색 결과가 없습니다.</td></tr>";
	        if (countElement) countElement.textContent = "0";
	        return;
	    }

	    brandList.forEach(function (brand) {
	        const isChecked = selectedCodes.includes(brand.itemCode);

	        const row = document.createElement("tr");
	        row.innerHTML =
	            "<td><input type='checkbox' style='width:20px; height:20px;' name='brandChk' value='" +
	            brand.itemCode +
	            "' data-name='" +
	            brand.itemName +
	            "'" + (isChecked ? " checked" : "") + "></td>" +
	            "<td>" + brand.itemCode + "</td>" +
	            "<td>" + brand.itemName + "</td>";
	        tbody.appendChild(row);
	    });

	    if (countElement) countElement.textContent = brandList.length;
	}

	
	function chooseBrandMulti() {
	    const idx = window._brandIdx;
	    const checked = document.querySelectorAll("input[name='brandChk']:checked");

	    const tokenBox = document.getElementById("brandTokenBox_" + idx);
	    const hiddenInput = document.getElementById("brandCodeValues_" + idx);

	    tokenBox.innerHTML = ''; // 기존 토큰 초기화
	    let selectedCodes = [];

	    checked.forEach(item => {
	        const code = item.value;
	        const name = item.getAttribute("data-name");
	        selectedCodes.push(code);

	        const token = document.createElement("span");
	        token.className = "brand-token";
	        token.setAttribute("data-code", code);
	        token.style = `
	            display: flex;
	            align-items: center;
	            background: #e0e0e0;
	            border-radius: 12px;
	            padding: 4px 8px;
	            margin-right: 5px;
	            font-size: 13px;
	        `;

	        // ❌ 삭제 버튼
	        const removeBtn = document.createElement("span");
	        removeBtn.textContent = "✕";
	        removeBtn.style = `
	            font-weight: bold;
	            margin-right: 6px;
	            cursor: pointer;
	            color: #666;
	        `;
	        removeBtn.onclick = function () {
	            token.remove();
	            updateHiddenBrandCodes(idx);
	        };

	        token.appendChild(removeBtn);
	        token.append(name); // 브랜드명만 보여줌
	        tokenBox.appendChild(token);
	    });

	    hiddenInput.value = selectedCodes.join(',');
	    closeDialog('dialog_brand');
	}
	
	function searchBrand() {
	    const keyword = document.getElementById("searchBandValue").value.trim().toLowerCase();

	    const filtered = _brandFullList.filter(function (brand) {
	        return brand.itemCode.toLowerCase().includes(keyword) || brand.itemName.toLowerCase().includes(keyword);
	    });

	    renderBrandTable(filtered);
	}

	// 엔터키 검색용
	function bindBrandDialogEnter(e) {
	    if (e.key === 'Enter') {
	        searchBrand();
	    }
	}
	
	function updateHiddenBrandCodes(idx) {
	    const tokens = document.querySelectorAll("#brandTokenBox_" + idx + " .brand-token");
	    const codes = [...tokens].map(t => t.getAttribute("data-code"));
	    document.getElementById("brandCodeValues_" + idx).value = codes.join(',');
	}
	
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">
		제품개발완료보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;제품 완료보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Product Complete Doc</span><span class="title">제품개발완료보고서</span>
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
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="tab02">
				<ul>
					<!-- 선택됬을경우는 탭 클래스에 select를 넣어주세요 -->
					<!-- 내 제품설계서 같은경우는 change select 이렇게 change 그대로 두고 한칸 띄고 select 삽입 -->
					<a href="#" onClick="tabChange('tab1')"><li  class="select" id="tab1_li">기안내용</li></a>
					<a href="#" onClick="tabChange('tab2')"><li class="" id="tab2_li">완료보고서상세정보</li></a>
				</ul>
			</div>
			<div id="tab1_div">
				<div class="title2"  style="width: 80%;"><span class="txt">제목 </span></div>
				<div class="title2" style="width: 20%; display: inline-block;">						
				</div>
				<div class="main_tbl">
					<table class="insert_proc01">
						<colgroup>
							<col  />							
						</colgroup>
						<tbody>
							<tr>
								<td><input type="text" name="title" id="title" style="width: 99%;" class="req" /></td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="title2"  style="width: 80%;"><span class="txt">제품명</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">
				</div>
				<div class="main_tbl">
					<table class="insert_proc01">
						<colgroup>
							<col  />							
						</colgroup>
						<tbody>
							<tr>
								<td>
									<input type="text"  style="width:99%; float: left" class="req" name="productName" id="productName"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div class="title2"  style="width: 80%;"><span class="txt">개발 목적</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">
					<button class="btn_con_search" onClick="fn_addCol('purpose')" id="purpose_add_btn">
						<img src="/resources/images/icon_s_write.png" />추가 
					</button>
					<button class="btn_con_search" onClick="fn_delCol('purpose')">
						<img src="/resources/images/icon_s_del.png" />삭제 
					</button>
				</div>
				<div class="main_tbl">
					<table class="insert_proc01">
						<colgroup>
							<col width="20" />
							<col  />							
						</colgroup>
						<tbody id="purpose_tbody" name="purpose_tbody">
							<tr id="purpose_tr_1">
								<td>
									<input type="checkbox" id="purpose_1"><label for="purpose_1"><span></span></label>
								</td>
								<td>
									<input type="text"  style="width:99%; float: left" class="req" name="purpose" value="가."/>
								</td>
							</tr>
						</tbody>
						<tbody id="purpose_tbody_temp" name="purpose_tbody_temp" style="display:none">
							<tr id="purpose_tmp_tr_1"> 
								<td>
									<input type="checkbox" id="purpose_1"><label for="purpose_1"><span></span></label>
								</td>
								<td>
									<input type="text"  style="width:99%; float: left" class="req" name="purpose"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				
				<div class="title2"  style="width: 80%;"><span class="txt">제품 특징</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">
					<button class="btn_con_search" onClick="fn_addCol('feature')" id="feature_add_btn">
						<img src="/resources/images/icon_s_write.png" />추가 
					</button>
					<button class="btn_con_search" onClick="fn_delCol('feature')">
						<img src="/resources/images/icon_s_del.png" />삭제 
					</button>
				</div>
				<div class="main_tbl">
					<table class="insert_proc01">
						<colgroup>
							<col width="20" />
							<col  />							
						</colgroup>
						<tbody id="feature_tbody" name="feature_tbody">
							<tr id="feature_tr_1">
								<td>
									<input type="checkbox" id="feature_1"><label for="feature_1"><span></span></label>
								</td>
								<td>
									<input type="text"  style="width:99%; float: left" class="req" name="feature" value="가."/>
								</td>
							</tr>
						</tbody>
						<tbody id="feature_tbody_temp" name="feature_tbody_temp" style="display:none">
							<tr id="feature_tmp_tr_1"> 
								<td>
									<input type="checkbox" id="feature_1"><label for="feature_1"><span></span></label>
								</td>
								<td>
									<input type="text"  style="width:99%; float: left" class="req" name="feature"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div id="">
					<div class="title2"  style="width: 80%;"><span class="txt">용도</span></div>
					<table id="usage_Table" class="tbl05">
						<colgroup>
							<col width="100">
							<col width="600">
							<col />
						</colgroup>
						<thead>
							<tr>
								<th>용도선택</th>
								<th>내용</th>
							</tr>
						</thead>
						<tbody id="brand_tbody" name="brand_tbody">
							<tr id="brand_tr_1" class="temp_color">
								<td>
									<div class="search_box" style="width:100%;" >
										<div class="selectbox" style="width:100%; text-align:center;" >
											<label>-- 선택 --</label>
										    <select name="usageSelect" onchange="onUsageChange(this, 1);">
										      <option value="">-- 선택 --</option>
										      <option value="BRAND">브랜드선택</option>
										      <option value="CUSTOM">제품 용도 기입</option>
										    </select>
										</div>
									</div>
								</td>
								<td id="usageContentArea_1">
								</td>
							</tr>
						</tbody>
						<tfoot>
						</tfoot>
					</table>
				</div>	
				
				<div id="">
					<div class="title2" style="float: left; margin-top: 30px;">
						<span class="txt">신규도입품/제품규격</span>
					</div>
					<div id="matHeaderDiv" class="table_header07">
						<span class="table_order_btn"><button class="btn_up" onclick="moveUp(this)"></button><button class="btn_down" onclick="moveDown(this)"></button></span>
						<span class="table_header_btn_box">
							<button class="btn_add_tr" onclick="fn_addCol('new')" id="new_add_btn"></button><button class="btn_del_tr" onclick="fn_delCol('new')"></button>
						</span>
					</div>
					<table id="new_Table" class="tbl05">
						<colgroup>
							<col width="20">
							<col width="140">
							<col width="140">
							<col width="250">
							<col width="150">
							<col />
						</colgroup>
						<thead>
							<tr>
								<th></th>
								<th>제품명</th>
								<th>포장규격</th>
								<th>공급처 및 담당자</th>
								<th>보관조건 및 소비기한</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="new_tbody" name="new_tbody">
							<tr id="new_tr_1" class="temp_color">
								<td>
									<input type="checkbox" id="new_1"><label for="new_1"><span></span></label>
								</td>
								<td>
									<input type="text" name="itemName" style="width: 100%" class="req code_tbl"/>
								</td>
								<td>
									<input type="text" name="itemStandard" style="width: 100%"/>
								</td>
								<td>
									<input type="text" name="itemSupplier" style="width: 100%"/>
								</td>
								<td><input type="text" name="itemKeepExp" style="width: 100%" class=""/></td>
								<td><input type="text" name="itemNote" style="width: 100%" class=""/></td>
							</tr>
						</tbody>
						<tbody id="new_tbody_temp" name="new_tbody_temp" style="display:none">
							<tr id="new_tmp_tr_1" class="temp_color">
								<td>
									<input type="checkbox" id="new_1"><label for="new_1"><span></span></label>
								</td>
								<td>
									<input type="text" name="itemName" style="width: 100%" class="req code_tbl"/>
								</td>
								<td>
									<input type="text" name="itemStandard" style="width: 100%"/>
								</td>
								<td>
									<input type="text" name="itemSupplier" style="width: 100%"/>
								</td>
								<td><input type="text" name="itemKeepExp" style="width: 100%" class=""/></td>
								<td><input type="text" name="itemNote" style="width: 100%" class=""/></td>
							</tr>
						</tbody>
						<tfoot>
						</tfoot>
					</table>
				</div>
				
				<div class="title2"  style="width: 80%;"><span class="txt">도입 예정일</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">
				</div>
				<div class="main_tbl">
					<table class="insert_proc01">
						<colgroup>
							<col  />							
						</colgroup>
						<tbody>
							<tr>
								<td>
									<input type="text" name="scheduleDate" id="scheduleDate" style="width: 120px;"/>
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
				
			</div>
			<div id="tab2_div" style="display:none">
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
								<th style="border-left: none;">제품코드</th>
								<td>
									<input type="hidden"  name="isSample" id="isSample" value="N"/>
									<input type="text"  style="width:200px; float: left" class="req" name="productCode" id="productCode" placeholder="코드를 생성 하세요." readonly/>
									<button class="btn_small_search ml5" onclick="selectNewCode()" style="float: left">생성</button>
								</td>
								<th style="border-left: none;">상품코드</th>
								<td>
									<input type="text"  style="width:200px; float: left" class="req" name="productSapCode" id="productSapCode" placeholder="코드를 조회 하세요." readonly/>
									<button class="btn_small_search ml5" onclick="openDialog('dialog_erpMaterial')" style="float: left">조회</button>
									<button class="btn_small_search ml5" onclick="fn_initForm()" style="float: left">초기화</button>
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
							
							<tr>
								<th style="border-left: none;">중량</th>
								<td>
									<input type="text"  style="width:200px; float: left" class="" name="weight" id="weight"/>
								</td>
								<th style="border-left: none;">제품규격</th>
								<td>
									<input type="text"  style="width:350px; float: left" class="" name="standard" id="standard"/>								
								</td>
								
							</tr>
							<tr>
								<th style="border-left: none;">보관방법</th>
								<td>
									<input type="text"  style="width:350px; float: left" class="" name="keepCondition" id="keepCondition"/>
								</td>
								<th style="border-left: none;">소비기한</th>
								<td>
									<input type="text"  style="width:350px; float: left" class="" name="expireDate" id="expireDate"/>								
								</td>							
							</tr>
							<tr>
								<th style="border-left: none;">제품유형</th>
								<td colspan="5">
									<input class="" id="selectTxtFull" name="selectTxtFull" type="text" style="width: 450px; float: left" readonly>
									<button class="btn_small_search ml5" onclick="openDialog('dialog_product')" style="float: left">조회</button>
								</td>
							</tr>
							<tr>
								<th style="border-left: none;">신규원료사용 유무</th>
								<td colspan="5">
									<input type="radio" name="newMat" id="newMat1" value="N" onclick="changeNewMat(event)" checked="checked">
									<label for="newMat1"><span></span>사용안함</label>
									<input type="radio" name="newMat" id="newMat2" onclick="changeNewMat(event)" value="Y">
									<label for="newMat2"><span></span>사용</label>
								</td>
							</tr>
							<tr>
								<th style="border-left: none;">첨부파일 유형</th>
								<td colspan="5">
									<div id="docTypeTxt"></div>
									<select id="docTypeTemp" name="docTypeTemp" multiple style='display:none'>
									</select>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div id="matNewDiv" style="display:none">
					<div class="title2" style="float: left; margin-top: 30px;">
						<span class="txt">신규원료</span>
					</div>
					<div id="matHeaderDiv" class="table_header07">
						<span class="table_order_btn"><button class="btn_up" onclick="moveUp(this)"></button><button class="btn_down" onclick="moveDown(this)"></button></span>
						<span class="table_header_btn_box">
							<button class="btn_add_tr" onclick="addRow(this, 'newMat')" id="matNew_add_btn"></button><button class="btn_del_tr" onclick="removeRow(this)"></button>
						</span>
					</div>
					<table id="matTable" class="tbl05">
						<colgroup>
							<col width="20">
							<col width="140">
							<col width="140">
							<col width="250">
							<col width="150">
							<col width="200">
							<col width="8%">
							<col />
						</colgroup>
						<thead>
							<tr>
								<th><input type="checkbox" id="matTable_2" onclick="checkAll(event)"><label for="matTable_2"><span></span></label></th>
								<th>원료코드</th>
								<th>ERP코드</th>
								<th>원료명</th>
								<th>규격</th>
								<th>보관방법 및 유통기한</th>
								<th>공급가</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="newMatTbody" name="newMatTbody">
							<Tr id="newMatRow_1" class="temp_color">
								<td>
									<input type="checkbox" id="mat_1"><label for="mat_1"><span></span></label>
									<input type="hidden" name="itemType" value="Y"/>
								</td>
								<td>
									<input type="hidden" name="itemMatIdx" style="width: 100px" class="req code_tbl" />
									<input type="text" name="itemMatCode" style="width: 100px" class="req code_tbl" onkeyup="checkMaterail(event,'newMat')"/>
									<button class="btn_code_search2" onclick="openMaterialPopup(this,'newMat')"></button>
								</td>
								<td>
									<input type="text" name="itemSapCode" style="width: 100px"/>
								</td>
								<td>
									<input type="text" name="itemName" style="width: 85%" readonly="readonly" class="read_only" />
								</td>
								<td><input type="text" name="itemStandard" style="width: 100%" class=""/></td>
								<td><input type="text" name="itemKeepExp" style="width: 100%" class=""/></td>
								<td><input type="text" name="itemUnitPrice" style="width: 100%"  readonly="readonly" class="read_only"/></td>
								<td><input type="text" name="itemDesc" style="width: 100%"/></td>
							</Tr>
						</tbody>
						<tfoot>
						</tfoot>
					</table>
				</div>
				
				<div id="matDiv">
					<div class="title2" style="float: left; margin-top: 30px;">
						<span class="txt">원료</span>
					</div>
					<div id="matHeaderDiv" class="table_header07">
						<span class="table_order_btn"><button class="btn_up" onclick="moveUp(this)"></button><button class="btn_down" onclick="moveDown(this)"></button></span>
						<span class="table_header_btn_box">
							<button class="btn_add_tr" onclick="addRow(this, 'mat')" id="mat_add_btn"></button><button class="btn_del_tr" onclick="removeRow(this)"></button>
						</span>
					</div>
					<table id="matTable" class="tbl05">
						<colgroup>
							<col width="20">
							<col width="140">
							<col width="140">
							<col width="250">
							<col width="150">
							<col width="200">
							<col width="8%">
							<col />
						</colgroup>
						<thead>
							<tr>
								<th><input type="checkbox" id="matTable_1" onclick="checkAll(event)"><label for="matTable_1"><span></span></label></th>
								<th>원료코드</th>
								<th>ERP코드</th>
								<th>원료명</th>
								<th>규격</th>
								<th>보관방법 및 유통기한</th>
								<th>공급가</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="matTbody" name="matTbody">
							<tr id="matRow_1" class="temp_color">
								<td>
									<input type="checkbox" id="mat_2"><label for="mat_2"><span></span></label>
									<input type="hidden" name="itemType" value="N"/>
								</td>
								<td>
									<input type="hidden" name="itemMatIdx" style="width: 100px" class="req code_tbl" />
									<input type="text" name="itemMatCode" style="width: 100px" class="req code_tbl" onkeyup="checkMaterail(event,'mat')"/>
									<button class="btn_code_search2" onclick="openMaterialPopup(this,'mat')"></button>
								</td>
								<td>
									<input type="text" name="itemSapCode" style="width: 100px"/>
								</td>
								<td>
									<input type="text" name="itemName" style="width: 85%" readonly="readonly" class="read_only" />
								</td>
								<td><input type="text" name="itemStandard" style="width: 100%" class=""/></td>
								<td><input type="text" name="itemKeepExp" style="width: 100%" class=""/></td>
								<td><input type="text" name="itemUnitPrice" style="width: 100%"  readonly="readonly" class="read_only"/></td>
								<td><input type="text" name="itemDesc" style="width: 100%"/></td>
							</tr>
						</tbody>
						<tfoot>
						</tfoot>
					</table>
				</div>
				
				<div class="title2 mt20"  style="width:90%;"><span class="txt">비고</span></div>
				<div class="main_tbl">
					<ul>
						<li class="">
							<div class="text_insert" style="padding: 0px;">
								<textarea name="contents" id="contents" style="width: 666px; height: 120px; display: none;">
								<!--<h2><strong>1. 제품명</strong></h2><p>&nbsp;</p><h2><strong>2. 개발목적</strong></h2><p>&nbsp;</p><h2><strong>3. 제품특징</strong></h2><p>&nbsp;</p><h2><strong>4. 용도</strong></h2><p>&nbsp;</p><h2><strong>5. 제품규격</strong></h2><p>&nbsp;</p><h2><strong>6. 도입예정일</strong></h2><p>&nbsp;</p><p>&nbsp;</p>-->
								</textarea>
								<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
							</div>
						</li>
					</ul>
				</div>
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

<table id="tmpMatTable" class="tbl05" style="display:none">
	<colgroup>
		<col width="20">
		<col width="140">
		<col />
		<col width="8%">
		<col width="5%">
		<col width="8%">
	</colgroup>
	<thead>
		<tr>
			<th><input type="checkbox" id="matTable_1" onclick="checkAll(event)"><label for="matTable_1"><span></span></label></th>
			<th>원료코드</th>
			<th>원료명</th>
			<th>단가</th>
			<th>수량</th>
			<th>가격</th>
		</tr>
	</thead>
	<tbody id="tmpMatTbody" name="tmpMatTbody">
		<tr id="tempMatRow_1" class="temp_color">
			<td>
				<input type="checkbox" id="mat_1"><label for="mat_1"><span></span></label>
				<input type="hidden" name="itemType"/>
			</td>
			<td>
				<input type="hidden" name="itemMatIdx" style="width: 100px" class="req code_tbl" />
				<input type="text" name="itemMatCode" style="width: 100px" class="req code_tbl" onkeyup="checkMaterail(event,'newMat')"/>
				<button class="btn_code_search2" onclick="openMaterialPopup(this,'newMat')"></button>
			</td>
			<td>
				<input type="text" name="itemSapCode" style="width: 100px"/>
			</td>
			<td>
				<input type="text" name="itemName" style="width: 85%" readonly="readonly" class="read_only" />
			</td>
			<td><input type="text" name="itemStandard" style="width: 100%" class=""/></td>
			<td><input type="text" name="itemKeepExp" style="width: 100%" class=""/></td>
			<td><input type="text" name="itemUnitPrice" style="width: 100%"  readonly="readonly" class="read_only"/></td>
			<td><input type="text" name="itemDesc" style="width: 100%"/></td>
		</tr>
	</tbody>
	<tbody id="tmpMatTbody2" name="tmpMatTbody2">
		<tr id="tempMatRow_1" class="temp_color">
			<td>
				<input type="checkbox" id="mat_1"><label for="mat_1"><span></span></label>
				<input type="hidden" name="itemType"/>
			</td>
			<td>
				<input type="hidden" name="itemMatIdx" style="width: 100px" class="req code_tbl" />
				<input type="text" name="itemMatCode" style="width: 100px" class="req code_tbl" onkeyup="checkMaterail(event,'mat')"/>
				<button class="btn_code_search2" onclick="openMaterialPopup(this,'mat')"></button>
			</td>
			<td>
				<input type="text" name="itemSapCode" style="width: 100px"/>
			</td>
			<td>
				<input type="text" name="itemName" style="width: 85%" readonly="readonly" class="read_only" />
			</td>
			<td><input type="text" name="itemStandard" style="width: 100%" class=""/></td>
			<td><input type="text" name="itemKeepExp" style="width: 100%" class=""/></td>
			<td><input type="text" name="itemUnitPrice" style="width: 100%"  readonly="readonly" class="read_only"/></td>
			<td><input type="text" name="itemDesc" style="width: 100%"/></td>
		</tr>
	</tbody>
	<tfoot>
	</tfoot>
</table>

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
								<input id="attatch_common_text" class="form-control form_point_color01" type="text" placeholder="파일을 선택해주세요." style="width:145px;/* width:308px;  */float:left; cursor: pointer; color: black;" onclick="callAddFileEvent()" readonly="readonly">
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
					<dt style="width: 20%">파일유형</dt>
					<dd style="width: 80%;">
						<input id="checkbox_item1" name="docType" type="checkbox" value="10"/>
						<label for="checkbox_item1" style="vertical-align: middle;"><span></span>컨셉서-개발목적</label>
						<input id="checkbox_item2" name="docType" type="checkbox" value="20"/>
						<label for="checkbox_item2" style="vertical-align: middle;"><span></span>추정 원단위표</label>
						<input id="checkbox_item3" name="docType" type="checkbox" value="30"/>
						<label for="checkbox_item3" style="vertical-align: middle;"><span></span>배합비&제조신고용 배합비</label>						
						<br/>
						<input id="checkbox_item4" name="docType" type="checkbox" value="40"/>
						<label for="checkbox_item4" style="vertical-align: middle;"><span></span>제조공정도</label>						
						<input id="checkbox_item5" name="docType" type="checkbox" value="50"/>
						<label for="checkbox_item5" style="vertical-align: middle;"><span></span>제조작업표준서</label>
						<input id="checkbox_item6" name="docType" type="checkbox" value="60"/>
						<label for="checkbox_item6" style="vertical-align: middle;"><span></span>제품규격서</label>
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

<!-- 원료 선택 레이어 start-->
<div class="white_content" id="dialog_product">
	<div class="modal" style="	width: 400px;margin-left:-210px;height: 350px;margin-top:-100px;">
		<h5 style="position:relative">
			<span class="title">제품구분</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('dialog_product')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div style="height: 200px; overflow-x: hidden; overflow-y: auto;">
			<div id="jsTree"></div> 
		</div>
		<div class="btn_box_con">
			<button class="btn_small02" onclick="closeDialog('dialog_product')"> 취소</button>
		</div>
	</div>
</div>
<!-- 원료 선택 레이어 close-->

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

<!-- 문서 검색 레이어 start-->
<div class="white_content" id="dialog_search">
	<div class="modal" style="	width: 700px;margin-left:-360px;height: 550px;margin-top:-300px;">
		<h5 style="position:relative">
			<span class="title">개발완료보고서검색</span>
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
					<dt>제품검색</dt>
					<dd>
						<input type="text" value="" class="req" style="width:302px; float: left" name="searchValue" id="searchValue" placeholder="제품코드/제품명을 입력하세요."/>
						<button class="btn_small_search ml5" onclick="fn_search()" style="float: left">조회</button>
					</dd>
				</li>
				<li>
					<dt>제품구분</dt>
					<dd >
						<div class="selectbox" style="width:100px;" id="searchCategory1_div">  
							<label for="searchCategory1" id="searchCategory1_label">선택</label> 
							<select name="searchCategory1" id="searchCategory1" onChange="fn_changeCategory(this,2)">
							</select>
						</div>
						<div class="selectbox lm5" style="width:100px; margin-left:5px; display:none;" id="searchCategory2_div">  
							<label for="searchCategory2" id="searchCategory2_label">선택</label> 
							<select name="searchCategory2" id="searchCategory2" onChange="fn_changeCategory(this,3)">
							</select>
						</div>
						<div class="selectbox lm5" style="width:100px; margin-left:5px; display:none;" id="searchCategory3_div">  
							<label for="searchCategory3" id="searchCategory3_label">선택</label> 
							<select name="searchCategory3" id="searchCategory3">
							</select>
						</div>
					</dd>
				</li>
			</ul>
		</div>
		<div class="main_tbl" style="height: 300px; overflow-y: auto">
			<table class="tbl07">
				<colgroup>
					<col width="40px">
					<col width="17%">
					<col width="23%">
					<col width="10%">
					<col />
				</colgroup>
				<thead>
					<tr>
						<th></th>
						<th>제품코드</th>
						<th>제품명</th>
						<th>버젼</th>
						<th>제품구분</th>
					<tr>
				</thead>
				<tbody id="productLayerBody">
					<tr>
						<td colspan="5">제품코드 혹은 제품명을 검색해주세요</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</div>
<!-- 원료 선택 레이어 close-->

<!-- 결재 상신 레이어  start-->
<div class="white_content" id="approval_dialog">
	<input type="hidden" id="docType" value="PROD"/>
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
			<span class="title">개발완료보고서 결재 상신</span>
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

<!-- 브랜드 선택 레이어 open -->
<div class="white_content" id="dialog_brand" style="display: none;">
	<input id="targetID" type="hidden">
	<input id="itemType" type="hidden">
	<input id="searchType" type="hidden">
	<div class="modal" style="width: 700px; margin-left: -400px; height: 650px; margin-top: -300px;">
		<h5 style="position:relative">
			<span class="title">브랜드 선택</span>
			<div class="top_btn_box">
				<ul>
					<li><button class="btn_madal_close" onclick="closeDialog('dialog_brand')"></button></li>
				</ul>
			</div>
		</h5>
		<div style="width:100%; text-align:center;">
			<input id="searchBandValue" type="text" class="code_input" onkeyup="bindBrandDialogEnter(event)" style="width: 300px;" placeholder="일부단어로 검색가능">
			<img src="/resources/images/icon_code_search.png" onclick="searchBrand()"/>
		</div>
		<div class="code_box2">
			(<strong> <span id="brandCount">0</span> </strong>)건
		</div>
		<div class="main_tbl" style="height: 400px; overflow-y: auto;">
			<table class="tbl02">
				<colgroup>
					<col width="20%">
					<col width="40%">
					<col width="40%">
				</colgroup>
				<thead>
					<tr>
						<th></th>	
						<th>브랜드 코드</th>
						<th>브랜드 명</th>
					</tr>
				</thead>
				<tbody id="brandLayerBody">
					<input type="hidden" id="brandLayerPage" value="0"/>
					<Tr>
						<td colspan="10">브랜드코드 혹은 브랜드명을 검색해주세요</td>
					</Tr>
				</tbody>
			</table>
		</div>
		<div style="margin-top: 40px;">
		    <!-- ✅ 선택 완료 버튼 추가 -->
		    <div style="text-align: center;">
		      <button class="btn_large_search" onclick="chooseBrandMulti()">선택 완료</button>
		    </div>
		</div>
	</div>
</div>
<!-- 브랜드 선택 레이어 close -->
