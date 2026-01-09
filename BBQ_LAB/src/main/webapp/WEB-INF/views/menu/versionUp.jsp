<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>메뉴완료보고서 개정</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 200px; min-height:200px;}
li {
	list-style: none;
} 
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">

<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../resources/js/jstree.js"></script>
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript" src="../resources/js/user/userSearchClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
var selectedArr = new Array();
	$(document).ready(function(){
		CreateEditor("contents");		
		fn_loadCategory();
		
		if( '${menuData.data.MENU_TYPE3}' != '' ) {
			selectedArr.push('${menuData.data.MENU_TYPE3}');
		}
		if( '${menuData.data.MENU_TYPE2}' != '' ) {
			selectedArr.push('${menuData.data.MENU_TYPE2}');
		}
		if( '${menuData.data.MENU_TYPE1}' != '' ) {
			selectedArr.push('${menuData.data.MENU_TYPE1}');
		}
		
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
		fn2.autoComplete($("#sharedUserKeyword"));
		
		document.querySelectorAll('.brand-token').forEach(token => {
		    token.addEventListener('click', function (e) {
		        if (e.target.textContent === '✕') {
		            token.remove();
		            updateHiddenBrandCodes(1);
		        }
		    });
		});
		
		const sharedUsers = [
	        <c:forEach var="user" items="${sharedUserList}" varStatus="status">
	        <c:if test="${user.USER_ID != null && user.USER_ID != '' }">
	            { userId: "${user.USER_ID}", userName: "${user.USER_NAME}" }<c:if test="${!status.last}">,</c:if>
	        </c:if>	            
	        </c:forEach>
	    ];

	    userSearchClass.renderTokenList(sharedUsers);
	    
	    <c:forEach var="fileType" items="${menuData.fileType}" varStatus="status">
		$('input[type="checkbox"][value="${fileType.FILE_TYPE}"]').prop('checked', true);
		</c:forEach>
		
		// ✅ name="docType" 체크박스 중 모든 항목이 체크되어 있다면 #checkAll 도 체크
	    const docCheckboxes = $('input[name="docType"]'); // checkAll은 name이 없으므로 자동 제외됨
	    const allChecked = docCheckboxes.length > 0 && docCheckboxes.filter(':checked').length === docCheckboxes.length;
	    $('#checkAll').prop('checked', allChecked);
	});
	
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
	
	function fn_closeErpMatRayer(){
		$('#searchErpMatValue').val('')
		$('#erpMatLayerBody').empty();
		$('#erpMatLayerBody').append('<tr><td colspan="9">원료코드 혹은 원료코드명을 검색해주세요</td></tr>');
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
	
	function bindDialogEnter2(e){
		if(e.keyCode == 13)
			searchMaterial();
	}
	
	function fn_setMaterialPopupData(SAP_CODE, NAME, KEEP_CONDITION, WIDTH, LENGTH, HEIGHT, TOTAL_WEIGHT, STANDARD, ORIGIN, EXPIRATION_DATE) {
		//$("#menuName").val(NAME);
		$("#menuSapCode").val(SAP_CODE);
		//$("#isSample").val("N");
		//$("#keepCondition").val(KEEP_CONDITION);
		//$("#weight").val(TOTAL_WEIGHT);
		//$("#standard").val(STANDARD);
		//$("#expireDate").val(EXPIRATION_DATE);
		fn_closeErpMatRayer();
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
			var selectTxtFull = "";
			var parents = data.node.parents;
			var selectTxt = data.node.text;
			var selectId = data.node.id;
			selectedArr.push(selectId);
			selectTxtFull += selectTxt;
			
			$.each(parents, function( index, value ){ //배열-> index, value
				if( value != '#' ) { 
					selectedArr.push(value);
					//selectTxtFull = $(this).jstree(true).get_node(value).text + ">" +selectTxtFull
					selectTxtFull = $.jstree.reference('#jsTree').get_node(value).text + ">" +selectTxtFull
				}
			});
			//$("#selectTxtFull").html(selectTxtFull);
			$("#selectTxtFull").val(selectTxtFull);
			closeDialog('dialog_menu');
		});
		//.bind("refresh.jstree",function(){
		//	
		//});
	}
	
	/* 파일첨부 관련 함수 START */
	var attatchFileArr = [];
	var attatchFileTypeArr = [];
	var attatchTempFileArr = [];
	var attatchTempFileTypeArr = [];
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
	
	/* function removeTempFile(element, tempId){
		$(element).parent().remove();
		attatchTempFileArr = attatchTempFileArr.filter(function(file){
			if(file.tempId != tempId) {
				return file;
			}
		})
		attatchTempFileTypeArr = attatchTempFileTypeArr.filter(function(typeObj){
			if(typeObj.tempId != tempId) 
				return typeObj;
		});
	} */
	
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
	
	
	/* function uploadFiles(){
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
			var childTag = '<li><a href="#none" onclick="removeFile(this, \''+tempId+'\')"><img src="/resources/images/icon_del_file.png"></a><span>'+object.fileTypeText+'</span>&nbsp;'+attatchFileArr[idx].name+'</li>'
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
	} */
	
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
	
	function checkMaterail(e,type){
		if(e.keyCode != 13){
			return;
		}
		var element = e.target
		
		//var userSapCode = e.target.value;
		var userMatCode = e.target.value;
		var rowId = $(element).parent().parent().attr('id');
		var URL = '/menu/checkMaterialAjax';
		if( type == 'mat' ) {
			URL = '/menu/checkErpMaterialAjax';
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
				alert('갱신 실패[2] - 시스템 담당자에게 문의하세요.');
			}
		})
	}
		
	function openMaterialPopup(element,type){
		var parentRowId = $(element).parent().parent('tr')[0].id;
		$('#targetID').val(parentRowId);
		openDialog('dialog_material');
		
		var matCode = $(element).prev().val();
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
				removePlugins: ['Link', 'List', 'Indent', 'Outdent', 'Alignment',
	                'Code', 'Image', 'ImageUpload', 'MediaEmbed', 'Table'
	            ]
	        }).then( editor => {
	        	window.editor = editor;
	    	}).catch( error => {
	    		console.error( error );
	    	});
	}
	
	function fn_insertTmp() {
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			$("#title").focus();
			return;
		} else {
			$('#lab_loading').show();
			var contents = editor.getData();
			var formData = new FormData();
			formData.append("title",$("#title").val());
			formData.append("menuName",$("#menuName").val());
			
			var itemImproveArr = new Array();
			var itemExistArr = new Array();
			var itemNoteArr = new Array();
			$('tr[id^=improve_pur_tr]').toArray().forEach(function(purposeRow){
				var rowId = $(purposeRow).attr('id');
				itemImproveArr.push($('#'+ rowId + ' input[name=itemImprove]').val());
				itemExistArr.push($('#'+ rowId + ' input[name=itemExist]').val());
				itemNoteArr.push($('#'+ rowId + ' input[name=itemNote]').val());
			});		
			formData.append("itemImproveArr", JSON.stringify(itemImproveArr));
			formData.append("itemExistArr", JSON.stringify(itemExistArr));	
			formData.append("itemNoteArr", JSON.stringify(itemNoteArr));	
			
			var improveArr = new Array();
			$('tr[id^=improve_tr]').toArray().forEach(function(purposeRow){
				var rowId = $(purposeRow).attr('id');
				improveArr.push($('#'+ rowId + ' input[name=improve]').val());
			});		
			formData.append("improveArr", JSON.stringify(improveArr));
			
			// 용도 분리 입력 처리
			var brandCodes = $('#brandCodeValues_1').val();
			var customUsage = $('#customUsage_1').val();

			if (brandCodes) {
				formData.append("usageArr", brandCodes); // USB
			}
			if (customUsage) {
				formData.append("customUsage", customUsage.trim()); // USC
			}
			
			formData.append("sharedUserArr", JSON.stringify($('#sharedUserIds').val().split(','))); // ✅ 추가
			
			var newItemNameArr = new Array();
			var newItemStandardArr = new Array();
			var newItemSupplierArr = new Array();
			var newItemKeepExpArr = new Array();
			var newItemNoteArr = new Array();
			var newItemTypeCodeArr = new Array();
			$('tr[id^=new_tr]').toArray().forEach(function(newRow){
				var rowId = $(newRow).attr('id');
				newItemNameArr.push($('#'+ rowId + ' input[name=itemName]').val());
				newItemStandardArr.push($('#'+ rowId + ' input[name=itemStandard]').val());
				newItemSupplierArr.push($('#'+ rowId + ' input[name=itemSupplier]').val());
				newItemKeepExpArr.push($('#'+ rowId + ' input[name=itemKeepExp]').val());
				newItemNoteArr.push($('#'+ rowId + ' input[name=itemNote]').val());
				newItemTypeCodeArr.push('A');
			});
			$('tr[id^=new1_tr]').toArray().forEach(function(newRow){
				var rowId = $(newRow).attr('id');
				newItemNameArr.push($('#'+ rowId + ' input[name=itemName]').val());
				newItemStandardArr.push($('#'+ rowId + ' input[name=itemStandard]').val());
				newItemSupplierArr.push($('#'+ rowId + ' input[name=itemSupplier]').val());
				newItemKeepExpArr.push($('#'+ rowId + ' input[name=itemKeepExp]').val());
				newItemNoteArr.push($('#'+ rowId + ' input[name=itemNote]').val());
				newItemTypeCodeArr.push('B');
			});
			formData.append("newItemNameArr", JSON.stringify(newItemNameArr));	
			formData.append("newItemStandardArr", JSON.stringify(newItemStandardArr));	
			formData.append("newItemSupplierArr", JSON.stringify(newItemSupplierArr));	
			formData.append("newItemKeepExpArr", JSON.stringify(newItemKeepExpArr));	
			formData.append("newItemNoteArr", JSON.stringify(newItemNoteArr));	
			formData.append("newItemTypeCodeArr", JSON.stringify(newItemTypeCodeArr));	
			
			formData.append("scheduleDate",$("#scheduleDate").val());
			
			formData.append("currentIdx",$("#idx").val());
			formData.append("currentVersionNo",$("#currentVersionNo").val());
			formData.append("versionNo",$("#versionNo").val());
			formData.append("docNo",$("#docNo").val());
			formData.append("menuCode",$("#menuCode").val());
			formData.append("menuSapCode",$("#menuSapCode").val());		
			//formData.append("weight",$("#weight").val());
			//formData.append("standard",$("#standard").val());
			//formData.append("keepCondition",$("#keepCondition").val());
			//formData.append("expireDate",$("#expireDate").val());
			formData.append("contents",contents);
			formData.append("newMat",$('input[name=newMat]:checked').val());
			formData.append("menuType",selectedArr);
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
			
			var docTypeArr = new Array();
			var docTypeTextArr = new Array();
			$('input:checkbox[name=docType]').each(function (index) {
				if($(this).is(":checked")==true){
					docTypeArr.push($(this).val());
					docTypeTextArr.push($(this).next("label").text());
			    }
			});
			
			formData.append('docTypeArr', JSON.stringify(docTypeArr));
			formData.append('docTypeTextArr', JSON.stringify(docTypeTextArr));
			
			$('select[name=tempFileList] option:selected').each(function(index){
				formData.append('tempFile', $(this).attr('value'));							
			});
			
			/* $('select[name=docTypeTemp] option:selected').each(function(index){
				formData.append('docType', $(this).attr('value'));
				formData.append('docTypeText', $(this).text());
			});
			
			$('select[name=tempFileList] option:selected').each(function(index){
				formData.append('tempFile', $(this).attr('value'));							
			}); */
			
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
					if( itemMatCode != '' ) {
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
			
		    // 1) 승계할 기존 메뉴얼 파일 ID들
		    $('#manualTempFileList_vu option').each(function(){
		      formData.append('manualTempFile', $(this).val());
		    });

		    // 2) 새로 추가한 메뉴얼 파일들
		    for (var i = 0; i < manualAttachFileArr.length; i++) {
		      formData.append('manualFile', manualAttachFileArr[i]);
		    }
			
			URL = "../menu/insertNewVersionCheckAjax";
			
			$.ajax({
				type:"POST",
				url:URL,
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				dataType:"json",
				success:function(result) {
					if( result.RESULT > 0 ) {
						alert($("#menuName").val()+"(버전 : "+$("#versionNo").val()+")"+"는 존재하는 문서입니다.");
						$('#lab_loading').hide();
						return;
					} else {
						URL = "../menu/insertNewVersionMenuTmpAjax";
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
											apprFormData.append("title", $("#title").val());
											apprFormData.append("docType", "MENU");
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
													alert($("#title").val()+"가 정상적으로 개정되었습니다.");
													$('#lab_loading').hide();
													fn_goList();
												},
												error:function(request, status, errorThrown){
													alert("결재 등록 오류가 발생하였습니다.");		
													$('#lab_loading').hide();
												}			
											});
										} else {
											alert($("#menuName").val()+"("+$("#menuCode").val()+")"+"가 개정되었습니다.");
											$('#lab_loading').hide();
											fn_list();
										}
									} else {
										alert("오류가 발생하였습니다.");
										$('#lab_loading').hide();
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
			
		}
	}
	
	function validatePurposeAndFeature() {
		// ✅ 개선사항 유효성 체크 (3개 항목 모두 빈값이 아닌 행이 하나 이상 있어야 함)
		let validImprovePurposeRowCount = 0;
		$('tr[id^=improve_pur_tr]').each(function () {
			const val1 = $(this).find('input[name=itemImprove]').val();
			const val2 = $(this).find('input[name=itemExist]').val();
			const val3 = $(this).find('input[name=itemNote]').val();

			if (
				$.trim(val1) !== '' &&
				$.trim(val2) !== '' /* &&
				$.trim(val3) !== '' */
			) {
				validImprovePurposeRowCount++;
			}
		});
		if (validImprovePurposeRowCount === 0) {
			alert("개선사항을 하나 이상, 빈 항목 없이 입력해 주세요.");
			return false;
		}

		// ✅ 개선목적 유효성 체크
		var isValidFeature = false;
		$('tr[id^=improve_tr]').each(function () {
			var val = $(this).find('input[name=improve]').val();
			if ($.trim(val) !== '') isValidFeature = true;
		});
		if (!isValidFeature) {
			alert("개선목적을 하나 이상 입력해 주세요.");
			return false;
		}
		
		return true;
	}
	
	//입력확인
	function fn_insert(){
		var contents = editor.getData();
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			tabChange('tab1');
			$("#title").focus();
			return;
		} else if( !chkNull($("#menuName").val()) ) {
			alert("메뉴명을 입력해 주세요.");
			tabChange('tab1');
			$("#menuName").focus();
			return;
		} else if(!validatePurposeAndFeature()){
			tabChange('tab1');
			return;
		} else if(!$.trim($('#brandCodeValues_1').val())){
			alert("브랜드를 선택해 주세요.");
			tabChange('tab1');
			return;
		} else if( !chkNull($("#selectTxtFull").val()) ) {
			alert("메뉴유형을 선택해 주세요.");
			tabChange('tab2');
			return;
		} else if( selectedArr.length == 0 ) {
			alert("메뉴유형을 선택하여 주세요.");
			tabChange('tab2');
			return;
		} else if( attatchFileArr.length == 0 && $("#tempFileList option").length == 0 ) {
			alert("첨부파일을 등록해주세요.");
			tabChange('tab1');
			$("#attatch_file").focus();
			return;
		}  else if( !chkNull($("#apprTxtFull").val()) ) {
			alert("결재라인을 등록해주세요.");
			tabChange('tab2');
			return;
		} else {
			if( $('input[name=newMat]:checked').val() == 'Y' ) {
				var matCount = 0;
				var validMat = true;
				$('tr[id^=newMatRow]').toArray().forEach(function(contRow){
					var rowId = $(contRow).attr('id');
					var itemMatCode = $('#'+ rowId + ' input[name=itemMatCode]').val();
					var itemName = $('#'+ rowId + ' input[name=itemName]').val();
					var mixingRatio = $('#'+ rowId + ' input[name=mixingRatio]').val();
					
					if(itemMatCode.length <= 0 && itemName.length <= 0){
						validMat = false;
						return;
					}
					matCount++;
				})
				if( matCount == 0 || !validMat) {
					alert('신규원료를 체크하셨습니다. 신규원료를 입력해주세요.');
					return;
				}
			}			
			
			if (!validateDocTypeSelected()) return;
			
			//기존 데이터 확인
			var formData = new FormData();
			formData.append("title",$("#title").val());
			formData.append("menuName",$("#menuName").val());
			
			var itemImproveArr = new Array();
			var itemExistArr = new Array();
			var itemNoteArr = new Array();
			$('tr[id^=improve_pur_tr]').toArray().forEach(function(purposeRow){
				var rowId = $(purposeRow).attr('id');
				itemImproveArr.push($('#'+ rowId + ' input[name=itemImprove]').val());
				itemExistArr.push($('#'+ rowId + ' input[name=itemExist]').val());
				itemNoteArr.push($('#'+ rowId + ' input[name=itemNote]').val());
			});		
			formData.append("itemImproveArr", JSON.stringify(itemImproveArr));
			formData.append("itemExistArr", JSON.stringify(itemExistArr));	
			formData.append("itemNoteArr", JSON.stringify(itemNoteArr));	
			
			
			var improveArr = new Array();
			$('tr[id^=improve_tr]').toArray().forEach(function(purposeRow){
				var rowId = $(purposeRow).attr('id');
				improveArr.push($('#'+ rowId + ' input[name=improve]').val());
			});		
			formData.append("improveArr", JSON.stringify(improveArr));		
			
			// 용도 분리 입력 처리
			var brandCodes = $('#brandCodeValues_1').val();
			var customUsage = $('#customUsage_1').val();

			if (brandCodes) {
				formData.append("usageArr", brandCodes); // USB
			}
			if (customUsage) {
				formData.append("customUsage", customUsage.trim()); // USC
			}
			
			formData.append("sharedUserArr", JSON.stringify($('#sharedUserIds').val().split(','))); // ✅ 추가
			
			var newItemNameArr = new Array();
			var newItemStandardArr = new Array();
			var newItemSupplierArr = new Array();
			var newItemKeepExpArr = new Array();
			var newItemNoteArr = new Array();
			var newItemTypeCodeArr = new Array();
			$('tr[id^=new_tr]').toArray().forEach(function(newRow) {
				var rowId = $(newRow).attr('id');
				var itemName = $('#' + rowId + ' input[name=itemName]').val(); // 임시로 이름값이 없으면 안넣음
				if ($.trim(itemName) !== '') {
					newItemNameArr.push(itemName);
					newItemStandardArr.push($('#' + rowId + ' input[name=itemStandard]').val());
					newItemSupplierArr.push($('#' + rowId + ' input[name=itemSupplier]').val());
					newItemKeepExpArr.push($('#' + rowId + ' input[name=itemKeepExp]').val());
					newItemNoteArr.push($('#' + rowId + ' input[name=itemNote]').val());
					newItemTypeCodeArr.push('A');
				}
			});

			$('tr[id^=new1_tr]').toArray().forEach(function(newRow) {
				var rowId = $(newRow).attr('id');
				var itemName = $('#' + rowId + ' input[name=itemName]').val(); // 임시로 이름값이 없으면 안넣음
				if ($.trim(itemName) !== '') {
					newItemNameArr.push(itemName);
					newItemStandardArr.push($('#' + rowId + ' input[name=itemStandard]').val());
					newItemSupplierArr.push($('#' + rowId + ' input[name=itemSupplier]').val());
					newItemKeepExpArr.push($('#' + rowId + ' input[name=itemKeepExp]').val());
					newItemNoteArr.push($('#' + rowId + ' input[name=itemNote]').val());
					newItemTypeCodeArr.push('B');
				}
			});
			formData.append("newItemNameArr", JSON.stringify(newItemNameArr));	
			formData.append("newItemStandardArr", JSON.stringify(newItemStandardArr));	
			formData.append("newItemSupplierArr", JSON.stringify(newItemSupplierArr));	
			formData.append("newItemKeepExpArr", JSON.stringify(newItemKeepExpArr));	
			formData.append("newItemNoteArr", JSON.stringify(newItemNoteArr));	
			formData.append("newItemTypeCodeArr", JSON.stringify(newItemTypeCodeArr));	
			
			formData.append("scheduleDate",$("#scheduleDate").val());
			
			formData.append("menuCode",$("#menuCode").val());
			formData.append("menuSapCode",$("#menuSapCode").val());
			formData.append("currentIdx",$("#idx").val());
			formData.append("currentVersionNo",$("#currentVersionNo").val());
			formData.append("versionNo",$("#versionNo").val());
			formData.append("docNo",$("#docNo").val());			
			//formData.append("weight",$("#weight").val());
			//formData.append("standard",$("#standard").val());
			//formData.append("keepCondition",$("#keepCondition").val());
			//formData.append("expireDate",$("#expireDate").val());
			formData.append("contents",contents);
			formData.append("newMat",$('input[name=newMat]:checked').val());
			formData.append("menuType",selectedArr);
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
			
			var docTypeArr = new Array();
			var docTypeTextArr = new Array();
			$('input:checkbox[name=docType]').each(function (index) {
				if($(this).is(":checked")==true){
					docTypeArr.push($(this).val());
					docTypeTextArr.push($(this).next("label").text());
			    }
			});
			
			formData.append('docTypeArr', JSON.stringify(docTypeArr));
			formData.append('docTypeTextArr', JSON.stringify(docTypeTextArr));
			
			$('select[name=tempFileList] option:selected').each(function(index){
				formData.append('tempFile', $(this).attr('value'));							
			});
			
			/* $('select[name=docTypeTemp] option:selected').each(function(index){
				formData.append('docType', $(this).attr('value'));
				formData.append('docTypeText', $(this).text());
			}); */
			
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
					if( itemMatCode != '' ) {
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
			
			// 1) 승계할 기존 메뉴얼 파일 ID들
		    $('#manualTempFileList_vu option').each(function(){
		      formData.append('manualTempFile', $(this).val());
		    });

		    // 2) 새로 추가한 메뉴얼 파일들
		    for (var i = 0; i < manualAttachFileArr.length; i++) {
		      formData.append('manualFile', manualAttachFileArr[i]);
		    }
			
			$('#lab_loading').show();
			URL = "../menu/insertNewVersionCheckAjax";			
			$.ajax({
				type:"POST",
				url:URL,
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				dataType:"json",
				success:function(result) {
					if( result.RESULT > 0 ) {
						alert($("#menuName").val()+"(버전 : "+$("#versionNo").val()+")"+"는 존재하는 문서입니다.");
						$('#lab_loading').hide();
						return;
					} else {
						URL = "../menu/insertNewVersionMenuAjax";
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
											apprFormData.append("title", $("#title").val());
											apprFormData.append("docType", "MENU");
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
											alert($("#menuName").val()+"("+$("#menuCode").val()+")"+"가 정상적으로 개정되었습니다.");
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
		}
	}

	function validateDocTypeSelected() {
	  const $checked = $('input[name=docType]:checked');
	  if ($checked.length === 0) {
	    alert("파일유형을 최소 1개 이상 선택해 주세요.");
	    // 필요하면 탭 전환/스크롤/포커스
	    if (typeof tabChange === 'function') tabChange('tab1');
	    const first = document.querySelector('#checkbox_item1');
	    if (first) { first.scrollIntoView({behavior:'smooth', block:'center'}); first.focus(); }
	    return false;
	  }
	  return true;
	}
	
	function fn_goList() {
		location.href = '/menu/list';
	}
	
	function nvl2(str, defaultStr){
	    if(typeof str == "undefined" || str == "undefined" || str == null || str == "" || str == "null")
	        str = defaultStr ;
	     
	    return str ;
	}
	
	function chkNum(obj) {
		var numStr = obj.value;
	    var regex = /^[0-9]*$/; // 숫자만 체크
	    if( !regex.test(numStr) ) {
	    	numStr = numStr.replace(/[^\d]/g,"");
	    	$(obj).val(numStr);
	    	alert("숫자만 입력가능합니다.");	    	
	    	return;
	    }	    
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
	
	function fn_list() {
		location.href = '/menu/list';
	}
// ---------------------------------------------- BRAND POPUP -------------------------------------------
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
	    
	    // ✅ 전체 선택 상태 동기화
	    const brandCheckboxes = document.querySelectorAll("input[name='brandChk']");
	    const allChecked = brandCheckboxes.length > 0 && [...brandCheckboxes].every(cb => cb.checked);

	    const selectAllCheckbox = document.getElementById("selectAllBrands");
	    if (selectAllCheckbox) selectAllCheckbox.checked = allChecked;
	}

	function toggleSelectAllBrands(masterCheckbox) {
	    const checkboxes = document.querySelectorAll("#brandLayerBody input[name='brandChk']");
	    checkboxes.forEach(cb => {
	        cb.checked = masterCheckbox.checked;
	    });
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

// ---------------------------------------------- BRAND POPUP -------------------------------------------

	function checkAll(e){
		var tbody = $(e.target).parent().parent().parent().next();
		tbody.children('tr').children('td').children('input[type=checkbox]').toArray().forEach(function(checkbox){
			if(e.target.checked)
				checkbox.checked = true;
			else 
				checkbox.checked = false;
		})
	}
	
	function fn_previewDataBinding(popup) {
	    const $doc = popup.document;
	    $doc.title = document.getElementById("title").value+'_메뉴완료보고서'
	    // 기본 항목
	    $doc.getElementById("prev_title").innerText = document.getElementById("title").value;
	    $doc.getElementById("prev_menuName").innerText = document.getElementById("menuName").value;
	    
	 	// 공동 참여자 바인딩
	    $doc.getElementById("prev_sharedUser").innerText = document.getElementById("sharedUserNames").value.replaceAll(',',', ');
	    
	 	// 🔹 개선 목적
		var improvePurHTML = "";
		const improvePurRows = document.querySelectorAll('tr[id^=improve_pur_tr]');
		improvePurRows.forEach(function (row) {
		    const improveVal = row.querySelector('input[name=itemImprove]')?.value.trim();
		    const existVal = row.querySelector('input[name=itemExist]')?.value.trim();
		    const noteVal = row.querySelector('input[name=itemNote]')?.value.trim();
		
		    // 셋 중 하나라도 값이 있으면 출력
		    if (improveVal || existVal || noteVal) {
		        improvePurHTML += "<tr>";
		        improvePurHTML += "<td>" + (improveVal || "") + "</td>";
		        improvePurHTML += "<td>" + (existVal || "") + "</td>";
		        improvePurHTML += "<td>" + (noteVal || "") + "</td>";
		        improvePurHTML += "</tr>";
		    }
		});
		
		const improveWrapper = $doc.getElementById("wrapper_prev_improve_pur");
		const improveTarget = $doc.getElementById("prev_improve_pur");
		
		if (improvePurHTML) {
		    improveTarget.innerHTML = improvePurHTML;
		    if (improveWrapper) improveWrapper.style.display = "block";
		} else {
	        if (improveWrapper) improveWrapper.style.display = "none";
	    }

	    // 개선 사항
	    var improveHTML = "";
	    document.querySelectorAll('tr[id^=improve_tr]').forEach(function (row) {
	        var val = row.querySelector('input[name=improve]')?.value || "";
	        if (val.trim()) improveHTML += val + "<br/>";
	    });
	    $doc.getElementById("prev_improve").innerHTML = improveHTML;

	    // 브랜드
	    var brandTexts = [];
	    document.querySelectorAll("#brandTokenBox_1 .brand-token").forEach(function (el) {
	        const cloned = el.cloneNode(true); // ✕ 버튼 포함 전체 복사
	        const xBtn = cloned.querySelector("span"); // ✕ 버튼 제거
	        if (xBtn) xBtn.remove();
	        const brandName = cloned.textContent.trim();
	        if (brandName) brandTexts.push(brandName);
	    });
	    $doc.getElementById("prev_brand").innerText = brandTexts.join(", ");

	    // 용도
	    $doc.getElementById("prev_usage").innerText = document.getElementById("customUsage_1").value;

	    // 신규도입품
	    var newHTML = "";
	    document.querySelectorAll('tr[id^=new_tr]').forEach(function (row) {
	        var itemName = row.querySelector('input[name=itemName]')?.value || "";
	        var itemStandard = row.querySelector('input[name=itemStandard]')?.value || "";
	        var itemSupplier = row.querySelector('input[name=itemSupplier]')?.value || "";
	        var itemKeepExp = row.querySelector('input[name=itemKeepExp]')?.value || "";
	        var itemNote = row.querySelector('input[name=itemNote]')?.value || "";

	        if (itemName || itemStandard || itemSupplier || itemKeepExp || itemNote) {
	            newHTML += "<tr><td>" + itemName + "</td><td>" + itemStandard + "</td><td>" + itemSupplier + "</td><td>" + itemKeepExp + "</td><td>" + itemNote + "</td></tr>";
	        }
	    });

	    var newWrap = $doc.getElementById("wrapper_prev_new");
	    if (newHTML.trim()) {
	        $doc.getElementById("prev_new").innerHTML = newHTML;
	        if (newWrap) newWrap.style.display = "block";
	    } else {
	        if (newWrap) newWrap.style.display = "none";
	    }
	    
	 	// 추정원가
	    var newHTML = "";
	    document.querySelectorAll('tr[id^=new1_tr]').forEach(function (row) {
	        var itemName = row.querySelector('input[name=itemName]')?.value || "";
	        var itemStandard = row.querySelector('input[name=itemStandard]')?.value || "";
	        var itemSupplier = row.querySelector('input[name=itemSupplier]')?.value || "";
	        var itemKeepExp = row.querySelector('input[name=itemKeepExp]')?.value || "";
	        var itemNote = row.querySelector('input[name=itemNote]')?.value || "";

	        if (itemName || itemStandard || itemSupplier || itemKeepExp || itemNote) {
	            newHTML += "<tr><td>" + itemName + "</td><td>" + itemStandard + "</td><td>" + itemSupplier + "</td><td>" + itemKeepExp + "</td><td>" + itemNote + "</td></tr>";
	        }
	    });
	    var newWrap = $doc.getElementById("wrapper_prev_new1");
	    if (newHTML.trim()) {
	        $doc.getElementById("prev_new1").innerHTML = newHTML;
	        if (newWrap) newWrap.style.display = "block";
	    } else {
	        if (newWrap) newWrap.style.display = "none";
	    }
	    
	    // 도입 예정일, 제품코드, SAP 코드
	    $doc.getElementById("prev_scheduleDate").innerText = document.getElementById("scheduleDate").value;
	    $doc.getElementById("prev_menuCode").innerText = document.getElementById("menuCode").value;
	    $doc.getElementById("prev_sapCode").innerText = document.getElementById("menuSapCode").value;

	    // 버전, 중량, 규격, 보관조건, 소비기한
	    $doc.getElementById("prev_version").innerText = document.getElementById("versionNo").value;

	    // 제품유형
	    $doc.getElementById("prev_menuType").innerText = document.getElementById("selectTxtFull").value;

	 // ▼ [첨부파일 유형] 미리보기 바인딩 (value → 라벨 텍스트로)
	    (() => {
	      const esc = (s) => String(s)
	        .replaceAll("&", "&amp;")
	        .replaceAll("<", "&lt;")
	        .replaceAll(">", "&gt;")
	        .replaceAll('"', "&quot;")
	        .replaceAll("'", "&#39;");

	      // 체크박스에서 "보이는 텍스트"를 탄탄하게 가져오는 함수
	      const getCheckboxLabel = (cb) => {
	        // 1) 라벨로 감싼 형태 <label><input>텍스트</label>
	        const wrapLabel = cb.closest('label');
	        if (wrapLabel) {
	          const t = wrapLabel.textContent?.trim();
	          if (t) return t;
	        }
	        // 2) for-연결 형태 <input id="x"> + <label for="x">텍스트</label>
	        if (cb.id) {
	          const forLabel = document.querySelector(`label[for="${cb.id}"]`);
	          const t = forLabel?.textContent?.trim();
	          if (t) return t;
	        }
	        // 3) aria-label / data-label
	        const a = cb.getAttribute('aria-label')?.trim();
	        if (a) return a;
	        const d = cb.dataset?.label?.trim();
	        if (d) return d;

	        // 4) 형제 텍스트 노드/요소에서 추출 (커스텀 마크업 대비)
	        let node = cb.nextSibling;
	        while (node) {
	          if (node.nodeType === Node.TEXT_NODE) {
	            const t = node.textContent?.trim();
	            if (t) return t;
	          } else if (node.nodeType === Node.ELEMENT_NODE && node.tagName !== 'INPUT') {
	            const t = node.textContent?.trim();
	            if (t) return t;
	          }
	          node = node.nextSibling;
	        }

	        // 5) 그래도 없으면 최후엔 value로 (코드값)
	        return cb.value ?? '';
	      };

	      // 체크박스 수집 (name은 실제 네임 규칙에 맞추어 조정)
	      const raw = [];
	      document
	        .querySelectorAll('input[type="checkbox"][name^="docType"]:checked, input[type="checkbox"][name^="fileType"]:checked')
	        .forEach(cb => {
	          const label = getCheckboxLabel(cb);
	          if (label) raw.push(label);
	        });

	      // “docTypeTxt”, “docTypeTemp(select multiple)” 쓰면 보조로 병합
	      const txtDiv = document.getElementById('docTypeTxt');
	      if (txtDiv?.textContent?.trim()) {
	        txtDiv.textContent.split(/[\n,]+/).map(s => s.trim()).filter(Boolean).forEach(t => raw.push(t));
	      }
	      const sel = document.getElementById('docTypeTemp');
	      if (sel?.options?.length) {
	        Array.from(sel.options).filter(o => o.selected).forEach(o => raw.push((o.text || o.value || '').trim()));
	      }

	      // 불필요한 항목(예: '전체 선택') 제거 + 중복 제거
	      const blocklist = new Set(['전체 선택', '전체선택', '전체']);
	      const types = Array.from(new Set(raw.map(s => s.trim()).filter(s => s && !blocklist.has(s))));

	      // 미리보기 바인딩
	      const $prev = $doc.getElementById('prev_fileType');

	      if (types.length) {
	    	// 쉼표+공백으로 연결, 마지막에는 자동으로 안 붙음
	    	$prev.innerHTML = types.map(esc).join(', ');
	      }
	      
	    })();

	 // ▼▼▼ [첨부파일] 미리보기 바인딩 추가 시작 ▼▼▼
	    // 1) <input type="file" name="files"> 들에서 선택된 파일명 수집
	    const fileNames = [];
	    const filePaths = [];
	    const fileIds = [];
	    const fileOrgNames = [];
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
			var fileName = $(li).attr("data-name");
			var filePath = $(li).attr("data-path");
			var fileId = $(li).attr("data-id");
			var fileOrgName = $(li).attr("data-orgname");
	      });
	    }

	 // 4) 미리보기 페이지에 반영 (기존파일 + 신규업로드 파일 모두 처리)
	    var $prevFile = $doc.getElementById("prev_file");
	    var $prevFileWrap = $doc.getElementById("wrapper_prev_file"); // 있으면 사용

	    // 4-1) 현재 화면의 <input type="file" name="files">에서 새로 선택된 File 객체들 수집
//	          (UL에 아직 data-id가 없고 data-*가 undefined인 신규 파일을 위해)
	    var newFiles = [];
	    document.querySelectorAll('input[type="file"][name="files"]').forEach(function(input){
	      Array.from(input.files || []).forEach(function(f){
	        if (f) newFiles.push(f);
	      });
	    });

	    // 신규 파일을 이름으로 빠르게 찾기 위한 맵 (orgName 기준)
	    var newFileByName = {};
	    newFiles.forEach(function(f){
	      // orgName 이 따로 없다면 f.name 을 orgName 으로 사용
	      newFileByName[f.name] = f;
	    });

	    // 4-2) 미리보기용 링크 배열과, 나중에 해제할 blob URL 들
	    var previewLinks = [];
	    var blobUrls = [];

	    // 4-3) UL에서 항목을 순회하며 기존 파일/신규 파일을 구분해 앵커 생성
	    if ($ul) {
	      $ul.querySelectorAll("li").forEach(function(li){
	        var fileName = $(li).attr("data-name");       // 서버 저장 파일명
	        var filePath = $(li).attr("data-path");
	        var fileId = $(li).attr("data-id");           // 서버 파일 ID (있으면 기존파일)
	        var fileOrgName = $(li).attr("data-orgname"); // 사용자가 본래 업로드한 파일명

	        // 1) 서버에 이미 존재하는 파일 (fileId 有) → 기존 방식 유지
	        if (fileId && fileOrgName) {
	          previewLinks.push(
	            '<a href="javascript:downloadFile(\'' + fileId + '\')">' + fileOrgName + '</a>'
	          );
	          return;
	        }

	        // 2) 신규 업로드 파일 (fileId 無) → Blob URL 로 즉시 다운로드 가능하게
	        //    우선 li에 orgName이 들어와 있으면 그걸로, 아니면 li의 텍스트를 fallback으로 사용
	        var orgNameGuess = fileOrgName;
	        if (!orgNameGuess) {
	          // li 내부 텍스트에서 파일명 유추 (삭제버튼 아이콘 등의 공백 제거)
	          orgNameGuess = (li.textContent || '').trim();
	        }

	        // 맵에서 동일한 이름의 File 객체 찾기
	        var f = orgNameGuess ? newFileByName[orgNameGuess] : null;

	        // 이름 매칭이 안되면, input.files 전체에서 동일 이름을 탐색 (여러 개 있을 수 있으니 첫 매칭만)
	        if (!f) {
	          for (var i = 0; i < newFiles.length; i++) {
	            if (newFiles[i] && newFiles[i].name === orgNameGuess) {
	              f = newFiles[i];
	              break;
	            }
	          }
	        }

	        if (f) {
	          var url = $doc.defaultView.URL.createObjectURL(f);
	          blobUrls.push(url);
	          // download 속성으로 파일명 지정 → 클릭 시 로컬로 저장됨
	          previewLinks.push(
	            '<a href="' + url + '" download="' + f.name + '">' + f.name + ' (미업로드)</a>'
	          );
	        } else {
	          // 매칭 실패 시 텍스트만 표시 (원하면 여기서도 단순 표시 대신 안내문 넣어도 됨)
	          if (orgNameGuess) {
	            previewLinks.push(orgNameGuess + ' (미업로드)');
	          }
	        }
	      });
	    }

	    // 4-4) UL에 없지만 input에만 존재하는 신규 파일도 표시하고 싶다면(옵션)
//	          UL이 아직 갱신되기 전이라 누락될 수 있으니 보강
	    if (newFiles.length > 0) {
	      // 이미 링크 만든 이름은 제외
	      var alreadyListed = {};
	      previewLinks.join('\n').replace(/>([^<]+)</g, function(_, name){ alreadyListed[name] = true; });

	      newFiles.forEach(function(f){
	        if (!alreadyListed[f.name]) {
	          var url2 = $doc.defaultView.URL.createObjectURL(f);
	          blobUrls.push(url2);
	          previewLinks.push(
	            '<a href="' + url2 + '" download="' + f.name + '">' + f.name + ' (미업로드)</a>'
	          );
	        }
	      });
	    }

	    // 4-5) 출력/표시 처리
	    if (previewLinks.length > 0) {
	      $prevFile.innerHTML = previewLinks.join('<br/>');
	      if ($prevFileWrap) $prevFileWrap.style.display = 'table-row';
	    } else {
	      if ($prevFileWrap) $prevFileWrap.style.display = 'none';
	      // 또는 대시 처리
	      // $prevFile.textContent = '-';
	    }

	    // 4-6) 팝업이 닫힐 때 blob URL 해제
	    $doc.defaultView.addEventListener('beforeunload', function(){
	      blobUrls.forEach(function(u){
	        try { $doc.defaultView.URL.revokeObjectURL(u); } catch (e) {}
	      });
	    });

	    // ▲▲▲ [첨부파일] 미리보기 바인딩 추가 끝 ▲▲▲
	    
	    // ▼ [메뉴얼 첨부] 미리보기 바인딩
		(() => {
		  // 필요시 이스케이프 (이미 있다면 생략 가능)
		  function esc(s) {
		    return String(s)
		      .replaceAll("&", "&amp;")
		      .replaceAll("<", "&lt;")
		      .replaceAll(">", "&gt;")
		      .replaceAll('"', "&quot;")
		      .replaceAll("'", "&#39;");
		  }
		
		  var $prevManual = $doc.getElementById("prev_manual");
		  var $mul = document.getElementById("attach_file_manual_vu"); // 메뉴얼 UL
		
		  var previewLinks = [];
		  var blobUrls = [];
		
		  // 1) UL에 표시된 항목 순회 (서버파일/신규파일 구분)
		  if ($mul) {
		    $mul.querySelectorAll("li").forEach(function(li){
		      var manualId = li.getAttribute("data-id");            // 서버 파일 ID
		      var manualOrgName = li.getAttribute("data-orgname");  // 원본 파일명          // 신규 파일 식별자
		      // (1) 서버에 이미 존재하는 파일
		      if (manualId && manualOrgName) {
		        previewLinks.push(
		          '<a href="javascript:downloadFile(\'' + manualId + '\')">' + esc(manualOrgName) + '</a>'
		        );
		        return;
		      }
		
		      // (3) 정보가 부족한 예외 케이스 → 텍스트만
		      var inferred = manualOrgName || (li.textContent || '').replace(/삭제/g, '').trim();
		      if (inferred) {
		        previewLinks.push(esc(inferred) + ' (미업로드)');
		      }
		    });
		  }
		
		  // 2) input[name=manualFiles] 에만 있고 UL엔 아직 없는 신규 파일도 보강 표시
		  var newManualFiles = [];
		  document.querySelectorAll('input[type="file"][name="manualFiles"]').forEach(function(input){
		    Array.from(input.files || []).forEach(function(f){
		      if (f) newManualFiles.push(f);
		    });
		  });
		
		  // 3) 출력
		  if ($prevManual && previewLinks.length > 0) {
		    $prevManual.innerHTML = previewLinks.join('<br/>');
		  } else if ($prevManual) {
		    // 필요 시 대시 처리
		    // $prevManual.textContent = '-';
		  }
		
		  // 4) 팝업 닫힐 때 Blob URL 정리
		  $doc.defaultView.addEventListener('beforeunload', function(){
		    blobUrls.forEach(function(u){
		      try { $doc.defaultView.URL.revokeObjectURL(u); } catch(e){}
		    });
		  });
		})();
	    
	    // 신규 원료
	    var newMatHTML = "";
	    var newMatRows = document.querySelectorAll('tr[id^=newMatRow]');
	    if (document.querySelector('input[name=newMat]:checked')?.value === 'Y' && newMatRows.length > 0) {
	        newMatRows.forEach(function (row) {
	            var getVal = function (name) {
	                return row.querySelector('input[name=' + name + ']')?.value || "";
	            };
	            if (
	                getVal("itemMatCode") || getVal("itemSapCode") || getVal("itemName") ||
	                getVal("itemStandard") || getVal("itemKeepExp") || getVal("itemUnitPrice") || getVal("itemDesc")
	            ) {
	                newMatHTML += "<tr>";
	                newMatHTML += "<td>" + getVal("itemMatCode") + "</td>";
	                newMatHTML += "<td>" + getVal("itemSapCode") + "</td>";
	                newMatHTML += "<td>" + getVal("itemName") + "</td>";
	                newMatHTML += "<td>" + getVal("itemStandard") + "</td>";
	                newMatHTML += "<td>" + getVal("itemKeepExp") + "</td>";
	                newMatHTML += "<td>" + getVal("itemUnitPrice") + "</td>";
	                newMatHTML += "<td>" + getVal("itemDesc") + "</td>";
	                newMatHTML += "</tr>";
	            }
	        });
	    }

	    var newMatWrap = $doc.getElementById("wrapper_prev_newMat");
	    if (newMatHTML.trim()) {
	        $doc.getElementById("prev_newMat").innerHTML = newMatHTML;
	        if (newMatWrap) newMatWrap.style.display = "block";
	    } else {
	        if (newMatWrap) newMatWrap.style.display = "none";
	    }

	    // 기존 원료
	    var matHTML = "";
	    var matRows = document.querySelectorAll('tr[id^=matRow]');
	    matRows.forEach(function (row) {
	        var getVal = function (name) {
	            return row.querySelector('input[name=' + name + ']')?.value || "";
	        };
	        if (getVal("itemSapCode")) {
	            matHTML += "<tr>";
	            matHTML += "<td>" + getVal("itemMatCode") + "</td>";
	            matHTML += "<td>" + getVal("itemSapCode") + "</td>";
	            matHTML += "<td>" + getVal("itemName") + "</td>";
	            matHTML += "<td>" + getVal("itemStandard") + "</td>";
	            matHTML += "<td>" + getVal("itemKeepExp") + "</td>";
	            matHTML += "<td>" + getVal("itemUnitPrice") + "</td>";
	            matHTML += "<td>" + getVal("itemDesc") + "</td>";
	            matHTML += "</tr>";
	        }
	    });

	    var matWrap = $doc.getElementById("wrapper_prev_newMat1");
	    if (matHTML.trim()) {
	        $doc.getElementById("prev_newMat1").innerHTML = matHTML;
	        if (matWrap) matWrap.style.display = "block";
	    } else {
	        if (matWrap) matWrap.style.display = "none";
	    }

	 	// 🔹 비고 (내용)
	    var contents = editor.getData().trim();
	    var contentTarget = $doc.getElementById("prev_content");
	    var contentWrapper = $doc.getElementById("wrapper_prev_content");

	    if (contents) {
	        contentTarget.innerHTML = contents;
	        if (contentWrapper) contentWrapper.style.display = "block";
	    } else {
	        if (contentWrapper) contentWrapper.style.display = "none";
	    }
	}

	function fn_openPreview() {
		var url = "/preview/menuVersionUpPopup";

		// 팝업 창 열기
		var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes");

		// 팝업이 완전히 열린 뒤에 데이터 전달
		popup.onload = function () {
			// 여기서 fn_openPreview() 호출해서 팝업 DOM에 값 세팅
			fn_previewDataBinding(popup);
		};
	}
	
	function fn_removeTempFile(el, fileIdx) {
		$("#tempFileList").removeOption(fileIdx);
	    // 화면에서 삭제
	    const $li = $(el).closest('li');
	    $li.remove();
	}
	
	function toggleDocTypeCheckboxes(masterCheckbox) {
	    const checkboxes = document.querySelectorAll('input[name="docType"]');
	    checkboxes.forEach(cb => {
	        if (cb.id !== 'checkAll') {
	            cb.checked = masterCheckbox.checked;
	        }
	    });
	}
	
	function syncCheckAll() {
	    const checkboxes = document.querySelectorAll('input[name="docType"]:not(#checkAll)');
	    const allChecked = [...checkboxes].every(cb => cb.checked);
	    document.getElementById("checkAll").checked = allChecked;
	}
	
	  // 전역 배열이 없으면 초기화 (insert.jsp에서 이미 쓰는 네이밍 유지)
	  window.manualFileArr = window.manualFileArr || [];                // 새로 추가한 메뉴얼 파일들
	  window.manualFileTypeArr = window.manualFileTypeArr || [];
	  window.manualDeletedFileIdArr = window.manualDeletedFileIdArr || [];
	  window.manualDeletedFileArr = window.manualDeletedFileArr || [];
	  window.manualDeletedFilePathArr = window.manualDeletedFilePathArr || [];

	  // 메뉴얼 파일 추가: 화면 리스트/배열 둘 다 반영
	  function addManualFile(input) {
	    var files = input.files;
	    if (!files || !files.length) return;

	    for (var i = 0; i < files.length; i++) {
	      var f = files[i];
	      manualFileArr.push(f);
	      // 저장 시 fileType = 'MAN' 으로 넣을 예정
	      manualFileTypeArr.push({ fileType: '00', fileTypeText: 'MANUAL' });

	      // 화면 표시
	      var $li = $('<li/>').text(f.name);
	      // 새로 추가한 파일은 바로 삭제 가능하게 (temp가 아니라 클라이언트 배열에서 제거)
	      var $del = $('<a href="#none"><img src="/resources/images/icon_del_file.png"></a>');
	      $del.on('click', function() {
	        // 클릭된 li의 파일명을 기준으로 배열에서 1건 제거
	        var name = $(this).parent().text();
	        for (var j = manualFileArr.length - 1; j >= 0; j--) {
	          if (manualFileArr[j].name === name) {
	            manualFileArr.splice(j, 1);
	            manualFileTypeArr.splice(j, 1);
	            break;
	          }
	        }
	        $(this).parent().remove();
	      });
	      $li.prepend($del);
	      $('#attach_file_manual').append($li);
	    }
	    // 같은 파일을 다시 선택할 수 있도록 초기화
	    input.value = '';
	  }
	
	/* =====================[ MANUAL 전용 전역 상태 ]===================== */
	/** 새로 추가한 메뉴얼 파일들(아직 서버 미업로드) */
	var manualAttachFileArr = [];
	/** 기존 메뉴얼 파일 삭제용(서버에 이미 존재하던 것들) */
	var manualDeletedFileIdArr   = [];
	var manualDeletedFileArr     = [];   // 변경파일명(= FILE_NAME)
	var manualDeletedFilePathArr = [];   // 경로(= FILE_PATH)

	/* =====================[ 렌더링: 새로 추가한 메뉴얼 파일 ]============ */
	/** 기존(서버에 있던) li 는 건드리지 않고, 새로 추가한 것만 class=manual-new 로 다시 그림 */
	function renderManualNewFiles() {
	  // 새로 추가한 것들만 싹 지우고 다시 그리기
	  $('#attach_file_manual_vu li.manual-new').remove();

	  manualAttachFileArr.forEach(function(file, idx){
	    var li = $(
	      '<li class="manual-new" data-new-index="'+idx+'">'+
	        '<a href="#none" onclick="removeManualNewFile('+idx+')">'+
	          '<img src="/resources/images/icon_del_file.png"></a>' +
	        $('<div>').text(file.name).html() +
	      '</li>'
	    );
	    $('#attach_file_manual_vu').append(li);
	  });
	}

	/* =====================[ 추가: 파일선택 버튼 ]======================= */
	/** input[type=file] (id=manualFile_vu) onchange 핸들러 */
	function addManualFile(input){
	  if(!input || !input.files || input.files.length === 0) return;

	  for (var i=0; i<input.files.length; i++){
	    var f = input.files[i];

	    // 중복 방지(이름+사이즈 기준)
	    var dup = manualAttachFileArr.some(function(x){ return x.name===f.name && x.size===f.size; });
	    if(dup) continue;

	    manualAttachFileArr.push(f);
	  }

	  // 같은 파일 다시 선택할 수 있게 초기화
	  input.value = '';
	  renderManualNewFiles();
	}

	/* =====================[ 추가: 드래그&드롭 ]========================== */
	function dropManual(e) {
	  e.preventDefault();
	  var files = (e.originalEvent ? e.originalEvent.dataTransfer.files : e.dataTransfer.files);
	  if (!files || !files.length) return;
	
	  // 기존 ‘첨부파일’의 drop과 동일한 UX, 단 로직은 manual용 함수 호출
	  var fakeInput = { files: files, value: '' };
	  addManualFile(fakeInput);   // 이미 갖고 있는 manual 추가 함수
	
	  var box = e.currentTarget || e.target; // 스타일 원복
	  box.style.backgroundColor = "#fff";
	  box.style.opacity  = "1";
	}

	/* =====================[ 삭제: 새로 추가한(아직 업로드 전) 파일 ]===== */
	function removeManualNewFile(newIndex){
	  // 방어코드
	  if(newIndex<0 || newIndex>=manualAttachFileArr.length) return;

	  // 배열에서 제거
	  manualAttachFileArr.splice(newIndex, 1);
	  // 다시 그리기
	  renderManualNewFiles();
	}

	/* =====================[ 삭제: 기존(서버 저장된) 메뉴얼 파일 ]======= */
	/** JSP에서 <a onclick="fn_removeManualTempFile(this,'${mfile.FILE_IDX}')"> 로 호출됨 */
	function fn_removeManualTempFile(el, fileIdx) {
	  var $li = $(el).closest('li');
	  var path = $li.data('path'); // FILE_PATH
	  var name = $li.data('name'); // FILE_NAME (변경 파일명)

	  // 삭제배열에 추가(서비스에서 처리)
	  manualDeletedFileIdArr.push(String(fileIdx));
	  manualDeletedFileArr.push(String(name));
	  manualDeletedFilePathArr.push(String(path));

	  // 화면에서 제거
	  $li.remove();

	  // 유지용 select 에서도 제거
	  $('#manualTempFileList_vu option[value="'+fileIdx+'"]').remove();
	}
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">
		메뉴완료보고서 개정&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;메뉴완료보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Menu Version Up Doc</span><span class="title">메뉴완료보고서 개정</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<button class="btn_circle_save" onclick="fn_insert()">&nbsp;</button>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="tab02">
				<ul style="display:flex; justify-content:space-between;">
					<!-- 선택됬을경우는 탭 클래스에 select를 넣어주세요 -->
					<!-- 내 제품설계서 같은경우는 change select 이렇게 change 그대로 두고 한칸 띄고 select 삽입 -->
					<div>
						<a href="#" onClick="tabChange('tab1')"><li  class="select" id="tab1_li">기안내용</li></a>
						<a href="#" onClick="tabChange('tab2')"><li class="" id="tab2_li">완료보고서상세정보</li></a>
					</div>
					<div>
						<button class="btn_small_search ml5" onclick="fn_openPreview()">미리보기</button>
					</div>
				</ul>
			</div>
			
			<div id="tab1_div">
				<div class="title2"  style="width: 80%;"><span class="txt">제목 <span class="mandatory">*</span></span></div>
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
									<input type="text" name="title" id="title" style="width: 99%;" value="${menuData.data.TITLE}"/>
									<input type="hidden" name="idx" id="idx" value="${menuData.data.MENU_IDX}"/>
									<input type="hidden" name="docNo" id="docNo" value="${menuData.data.DOC_NO}"/>
									<input type="hidden" name="currentVersionNo" id="currentVersionNo" value="${menuData.data.VERSION_NO}"/>
									<input type="hidden" name="menuCode" id="menuCode" value="${menuData.data.MENU_CODE}"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="title2"  style="width: 80%;"><span class="txt">메뉴명 <span class="mandatory">*</span></span></div>
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
									<input type="text"  style="width:99%; float: left" name="menuName" id="menuName" value="${menuData.data.NAME}"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div class="title2"  style="width: 80%; "><span class="txt">개선목적 <span class="mandatory">*</span></span></div>
				<div class="title2" style="width: 20%; display: inline-block; text-align: center;">
					<button class="btn_con_search" onClick="fn_addCol('improve')">
						<img src="/resources/images/icon_s_write.png" />추가 
					</button>
					<button class="btn_con_search" onClick="fn_delCol('improve')">
						<img src="/resources/images/icon_s_del.png" />삭제 
					</button>
				</div>
				<div class="main_tbl">
					<table class="insert_proc01">
						<colgroup>
							<col width="20" />
							<col  />							
						</colgroup>
						<tbody id="improve_tbody" name="improve_tbody">
						<c:set var="count" value="0" />
						<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
							<c:if test="${addInfoList.INFO_TYPE == 'IMP' }">
							<c:set var="count" value="${count + 1}" />
							<tr id="improve_tr_${status.count}">
								<td>
									<input type="checkbox" id="improve_${status.count}"><label for="improve_${status.count}"><span></span></label>
								</td>
								<td>
									<input type="text"  style="width:99%; float: left" name="improve" value="${addInfoList.INFO_TEXT}"/>
								</td>
							</tr>
							</c:if>
						</c:forEach>
						<c:if test="${count == 0 }">
							<tr id="improve_tr_1">
								<td>
									<input type="checkbox" id="improve_1"><label for="improve_1"><span></span></label>
								</td>
								<td>
									<input type="text"  style="width:99%; float: left" placeholder="가." name="improve"/>
								</td>
							</tr>
						</c:if>	
						</tbody>
						<tbody id="improve_tbody_temp" name="improve_tbody_temp" style="display:none">
							<tr id="improve_tmp_tr_1"> 
								<td>
									<input type="checkbox" id="improve_1"><label for="improve_1"><span></span></label>
								</td>
								<td>
									<input type="text"  style="width:99%; float: left" name="improve"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div id="">
					<div class="title2" style="float: left; margin-top: 20px;">
						<span class="txt">개선사항 <span class="mandatory">*</span></span>
					</div>
					<div id="matHeaderDiv" class="table_header07">
						<span class="table_order_btn"><button class="btn_up" onclick="moveUp(this)"></button><button class="btn_down" onclick="moveDown(this)"></button></span>
						<span class="table_header_btn_box">
							<button class="btn_add_tr" onclick="fn_addCol('improve_pur')"></button><button class="btn_del_tr" onclick="fn_delCol('improve_pur')"></button>
						</span>
					</div>
					<table id="improve_pur_Table" class="tbl05">
						<colgroup>
							<col width="20">
							<col width="30%">
							<col width="30%">
							<col />
						</colgroup>
						<thead>
							<tr>
								<th><input type="checkbox" id="inproveTable_1" onclick="checkAll(event)"><label for="inproveTable_1"><span></span></label></th>
								<th>개선</th>
								<th>기존</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="improve_pur_tbody" name="improve_pur_tbody">
							<c:forEach items="${imporvePurposeList}" var="imporvePurposeList" varStatus="status">
							<tr id="improve_pur_tr_${status.count}" class="temp_color">
								<td>
									<input type="checkbox" id="improve_pur_${status.count}"><label for="improve_pur_${status.count}"><span></span></label>
								</td>
								<td>
									<input type="text" name="itemImprove" style="width: 100%" class="code_tbl" value="${imporvePurposeList.IMPROVE}"/>
								</td>
								<td>
									<input type="text" name="itemExist" style="width: 100%" value="${imporvePurposeList.EXIST}"/>
								</td>
								<td><input type="text" name="itemNote" style="width: 100%" class="" value="${imporvePurposeList.NOTE}"/></td>
							</tr>
							</c:forEach>	
							<c:if test="${fn:length(imporvePurposeList) == 0 }">
							<tr id="improve_pur_tr_1" class="temp_color">
								<td>
									<input type="checkbox" id="improve_pur_1"><label for="improve_pur_1"><span></span></label>
								</td>
								<td>
									<input type="text" name="itemImprove" style="width: 100%" class="code_tbl"/>
								</td>
								<td>
									<input type="text" name="itemExist" style="width: 100%"/>
								</td>
								<td><input type="text" name="itemNote" style="width: 100%" class=""/></td>
							</tr>
							</c:if>
						</tbody>
						<tbody id="improve_pur_tbody_temp" name="improve_pur_tbody_temp" style="display:none">
							<tr id="improve_pur_tmp_tr_1" class="temp_color">
								<td>
									<input type="checkbox" id="improve_pur_1"><label for="improve_pur_1"><span></span></label>
								</td>
								<td>
										<input type="text" name="itemImprove" style="width: 100%" class="code_tbl"/>
									</td>
									<td>
										<input type="text" name="itemExist" style="width: 100%"/>
									</td>
									<td><input type="text" name="itemNote" style="width: 100%" class=""/></td>
							</tr>
						</tbody>
						<tfoot>
						</tfoot>
					</table>
				</div>
				
				
				
				<!-- ✅ 브랜드 영역 -->
				<div>
				  <div class="title2" style="width: 80%; margin-top:20px;"><span class="txt">브랜드 <span class="mandatory">*</span></span></div>
				  <table class="tbl05">
				    <tbody>
				      <tr>
				        <td>
				          <div style="width: 100%;">
				            <div style="display: flex; margin-left: 10px; justify-content: space-between; align-items: center; gap: 10px;">
				              <div id="brandTokenBox_1" class="token-box" style="display: flex; flex-wrap: wrap; gap: 5px; flex: 1;">
								<c:forEach items="${addInfoList}" var="item">
								  <c:if test="${item.INFO_TYPE == 'USB'}">
								    <c:forEach var="i" begin="0" end="${fn:length(fn:split(item.INFO_TEXT, ',')) - 1}">
								      <c:set var="code" value="${fn:split(item.INFO_TEXT, ',')[i]}" />
								      <c:set var="name" value="${fn:split(item.INFO_TEXT_NAME, ',')[i]}" />
								      <span class="brand-token" data-code="${code}"
								            style="display: flex; align-items: center; background: #e0e0e0; border-radius: 12px; padding: 4px 8px; margin-right: 5px; font-size: 13px;">
								        <span
								          style="font-weight: bold; margin-right: 6px; cursor: pointer; color: #666;">✕</span>
								        ${name}
								      </span>
								    </c:forEach>
								  </c:if>
								</c:forEach>
				              </div>
				
				              <!-- 항상 버튼 노출 -->
				              <div style="display: flex; gap: 5px;">
				                <button class="btn_small_search ml5" onclick="openBrandDialog(1)">조회</button>
				                <button class="btn_small_search ml5" onclick="document.getElementById('brandTokenBox_1').innerHTML=''; document.getElementById('brandCodeValues_1').value='';">초기화</button>
				              </div>
				            </div>
				            <!-- ✅ 숨겨진 브랜드 코드 -->
							<c:set var="brandCodes" value="" />
							<c:forEach items="${addInfoList}" var="item">
							  <c:if test="${item.INFO_TYPE == 'USB'}">
							    <c:choose>
							      <c:when test="${empty brandCodes}">
							        <c:set var="brandCodes" value="${item.INFO_TEXT}" />
							      </c:when>
							      <c:otherwise>
							        <c:set var="brandCodes" value="${brandCodes},${item.INFO_TEXT}" />
							      </c:otherwise>
							    </c:choose>
							  </c:if>
							</c:forEach>
							
							<!-- ✅ 중복된 쉼표 정리는 JS에서 filter(Boolean)으로 가능 -->
							<input type="hidden" id="brandCodeValues_1" name="brandCodeValues_1" value="${brandCodes}" />
				          </div>
				        </td>
				      </tr>
				    </tbody>
				  </table>
				</div>
				
				<!-- ✅ 용도 입력 영역 -->
				<div>
				  <div class="title2" style="width: 80%;"><span class="txt">용도</span></div>
				  <table class="tbl05">
				    <tbody>
				      <tr>
				        <td>
				          <c:set var="customText" value="" />
				          <c:forEach items="${addInfoList}" var="item">
				            <c:if test="${item.INFO_TYPE == 'USC'}">
				              <c:set var="customText" value="${item.INFO_TEXT}" />
				            </c:if>
				          </c:forEach>
				          <input type="text" id="customUsage_1" name="customUsage" value="${customText}" placeholder="용도를 입력하세요" style="width:99%;" />
				        </td>
				      </tr>
				    </tbody>
				  </table>
				</div>
				
				<div id="">
					<div class="title2" style="float: left; margin-top: 30px;">
						<span class="txt">신규도입품/제품규격</span>
					</div>
					<div id="matHeaderDiv" class="table_header07">
						<span class="table_order_btn"><button class="btn_up" onclick="moveUp(this)"></button><button class="btn_down" onclick="moveDown(this)"></button></span>
						<span class="table_header_btn_box">
							<button class="btn_add_tr" onclick="fn_addCol('new')"></button><button class="btn_del_tr" onclick="fn_delCol('new')"></button>
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
								<th><input type="checkbox" id="newTable_1" onclick="checkAll(event)"><label for="newTable_1"><span></span></label></th>
								<th>제품명</th>
								<th>포장규격</th>
								<th>공급처 및 담당자</th>
								<th>보관조건 및 소비기한</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="new_tbody" name="new_tbody">
							<c:forEach items="${newDataList}" var="newDataList" varStatus="status">
								<c:if test="${newDataList.TYPE_CODE == 'A'}">
									<tr id="new_tr_${status.count}" class="temp_color">
										<td>
											<input type="checkbox" id="new_${status.count}"><label for="new_${status.count}"><span></span></label>
										</td>
										<td>
											<input type="text" name="itemName" style="width: 100%" class="code_tbl" value="${newDataList.PRODUCT_NAME}"/>
										</td>
										<td>
											<input type="text" name="itemStandard" style="width: 100%" value="${newDataList.PACKAGE_STANDARD}"/>
										</td>
										<td>
											<input type="text" name="itemSupplier" style="width: 100%" value="${newDataList.SUPPLIER}"/>
										</td>
										<td><input type="text" name="itemKeepExp" style="width: 100%" class="" value="${newDataList.KEEP_EXP}"/></td>
										<td><input type="text" name="itemNote" style="width: 100%" class="" value="${newDataList.NOTE}"/></td>
									</tr>
								</c:if>
							</c:forEach>
							<c:if test="${fn:length(newDataList) == 0 }">
								<tr id="new_tr_1" class="temp_color">
									<td>
										<input type="checkbox" id="new_1"><label for="new_1"><span></span></label>
									</td>
									<td>
										<input type="text" name="itemName" style="width: 100%" class="code_tbl"/>
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
							</c:if>
						</tbody>
						<tbody id="new_tbody_temp" name="new_tbody_temp" style="display:none">
							<tr id="new_tmp_tr_1" class="temp_color">
								<td>
									<input type="checkbox" id="new_1"><label for="new_1"><span></span></label>
								</td>
								<td>
									<input type="text" name="itemName" style="width: 100%" class="code_tbl"/>
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
				
				<div id="">
					<div class="title2" style="float: left; margin-top: 30px;">
						<span class="txt">추정원가</span>
					</div>
					<div id="matHeaderDiv" class="table_header07">
						<span class="table_order_btn"><button class="btn_up" onclick="moveUp(this)"></button><button class="btn_down" onclick="moveDown(this)"></button></span>
						<span class="table_header_btn_box">
							<button class="btn_add_tr" onclick="fn_addCol('new1')"></button><button class="btn_del_tr" onclick="fn_delCol('new1')"></button>
						</span>
					</div>
					<table id="new1_Table" class="tbl05">
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
								<th><input type="checkbox" id="newTable_2" onclick="checkAll(event)"><label for="newTable_2"><span></span></label></th>
								<th>메뉴명</th>
								<th>예상판매가</th>
								<th>예상원가</th>
								<th>원가율(%)</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="new1_tbody" name="new1_tbody">
							<c:forEach items="${newDataList}" var="newDataList" varStatus="status">
								<c:if test="${newDataList.TYPE_CODE == 'B'}">
									<tr id="new1_tr_${status.count}" class="temp_color">
										<td>
											<input type="checkbox" id="new1_${status.count}"><label for="new1_${status.count}"><span></span></label>
										</td>
										<td>
											<input type="text" name="itemName" style="width: 100%" class="code_tbl" value="${newDataList.PRODUCT_NAME}"/>
										</td>
										<td>
											<input type="text" name="itemStandard" style="width: 100%" value="${newDataList.PACKAGE_STANDARD}"/>
										</td>
										<td>
											<input type="text" name="itemSupplier" style="width: 100%" value="${newDataList.SUPPLIER}"/>
										</td>
										<td><input type="text" name="itemKeepExp" style="width: 100%" class="" value="${newDataList.KEEP_EXP}"/></td>
										<td><input type="text" name="itemNote" style="width: 100%" class="" value="${newDataList.NOTE}"/></td>
									</tr>
								</c:if>
							</c:forEach>
							<c:if test="${fn:length(newDataList) == 0 }">
								<tr id="new1_tr_1" class="temp_color">
									<td>
										<input type="checkbox" id="new_1"><label for="new_1"><span></span></label>
									</td>
									<td>
										<input type="text" name="itemName" style="width: 100%" class="code_tbl"/>
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
							</c:if>
						</tbody>
						<tbody id="new1_tbody_temp" name="new1_tbody_temp" style="display:none">
							<tr id="new1_tmp_tr_1" class="temp_color">
								<td>
									<input type="checkbox" id="new1_1"><label for="new1_1"><span></span></label>
								</td>
								<td>
									<input type="text" name="itemName" style="width: 100%" class="code_tbl"/>
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
				
				<div class="title2"  style="width: 80%; margin-top:30px;"><span class="txt">도입 예정일</span></div>
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
									<input type="text" name="scheduleDate" id="scheduleDate" style="width: 120px;" value="${menuData.data.SCHEDULE_DATE}"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div class="title2 mt20"  style="width:90%;"><span class="txt">파일첨부 <span class="mandatory">*</span></span></div>
				<div class="list_detail">
					<ul style="">
						<li>
							<dt style="width: 20%">파일유형 <span class="mandatory">*</span></dt>
							<dd style="width: 80%;">
								<input id="checkAll" type="checkbox" onchange="toggleDocTypeCheckboxes(this)" /><label for="checkAll" style="vertical-align: middle; font-weight: bold;"><span></span>전체 선택</label>
								<input id="checkbox_item1" name="docType" type="checkbox" value="10" onchange="syncCheckAll()"/>
								<label for="checkbox_item1" style="vertical-align: middle;"><span></span>컨셉서-개발목적</label>
								<input id="checkbox_item2" name="docType" type="checkbox" value="20" onchange="syncCheckAll()"/>
								<label for="checkbox_item2" style="vertical-align: middle;"><span></span>추정 원단위표</label>
								<input id="checkbox_item3" name="docType" type="checkbox" value="30" onchange="syncCheckAll()"/>
								<label for="checkbox_item3" style="vertical-align: middle;"><span></span>배합비&제조신고용 배합비</label>						
								<input id="checkbox_item4" name="docType" type="checkbox" value="40" onchange="syncCheckAll()"/>
								<label for="checkbox_item4" style="vertical-align: middle;"><span></span>제조공정도</label>						
								<input id="checkbox_item5" name="docType" type="checkbox" value="50" onchange="syncCheckAll()"/>
								<label for="checkbox_item5" style="vertical-align: middle;"><span></span>제조작업표준서</label>
								<input id="checkbox_item6" name="docType" type="checkbox" value="60" onchange="syncCheckAll()"/>
								<label for="checkbox_item6" style="vertical-align: middle;"><span></span>제품규격서</label>
								<select id="tempFileList" name="tempFileList" multiple style="display: none">
								<c:forEach items="${menuData.fileList}" var="fileList" varStatus="status">
									<option value="${fileList.FILE_IDX}" selected>${fileList.ORG_FILE_NAME}</option>
								</c:forEach>
								</select>
							</dd>
						</li>
						<li>
							<dt style="width: 20%">첨부파일 <span class="mandatory">*</span></dt>
							<dd style="width: 80%;">
								<div class="add_file" id="add_file2" style="width:100%">
									<span id="upFile">
										<span class="file_load" id="fileSpan2" style="display: none;"><input type="file" name="files" id="file2" onchange="addFile(this, '00')" style="display:none"><label for="file2">첨부파일 등록 <img src="/resources/images/icon_add_file.png"></label></span>
										<span class="file_load" id="fileSpan3"><input type="file" name="files" id="file3" onchange="addFile(this, '00')" style="display:none"><label for="file3">첨부파일 등록 <img src="/resources/images/icon_add_file.png"></label></span>
									</span>
								</div>
								<div id="fileList" class="file_box_pop" style="height: 120px; width: 100%; border-top-left-radius: 0px; border-top-right-radius: 0px; border-top: 1px solid rgb(221, 221, 221); box-sizing: border-box;" ondrop="drop(event)" ondragover="allowDrop(event)" ondragend="drogEnd(event)" ondragleave="drogEnd(event)">
									<ul id="attatch_file">
										<c:forEach items="${menuData.fileList}" var="fileList" varStatus="status">
											<li data-orgname="${fileList.ORG_FILE_NAME}" data-id="${fileList.FILE_IDX}" data-path="${fileList.FILE_PATH}" data-name="${fileList.FILE_NAME}"><a href="#none" onclick="fn_removeTempFile(this, '${fileList.FILE_IDX}')"><img src="/resources/images/icon_del_file.png"></a>${fileList.ORG_FILE_NAME}</li>
										</c:forEach>
									</ul>	
								</div>
							</dd>
						</li>
					</ul>
				</div>
				
				<!-- ====================== 메뉴얼 (MANUAL) : versionUp.jsp ====================== -->
				<div class="title2 mb20" style="width:90%;"><span class="txt">메뉴얼</span></div>
				<div class="list_detail">
				  <ul>
				    <li>
				      <dt style="width: 20%">메뉴얼 파일</dt>
				      <dd style="width: 80%;">
				        <!-- 업로드 버튼: MENU 쪽과 id/name 절대 충돌 X -->
				        <div class="add_file" id="add_file_manual_up_vu" style="width:100%">
				          <span class="file_load">
				            <!-- 컨트롤러에서 manualFile로 받는다면 name 그대로 사용 -->
				            <input type="file" name="manualFile" id="manualFile_vu" multiple
				                   onchange="addManualFile(this)" style="display:none">
				            <label for="manualFile_vu">메뉴얼 등록 <img src="/resources/images/icon_add_file.png"></label>
				          </span>
				        </div>
				
				        <!-- 드래그&드롭 영역: 고유 id 사용 -->
				        <div id="manualFileListBox_vu" class="file_box_pop"
						     style="height:120px; width:100%; border-top-left-radius:0; border-top-right-radius:0; border-top:1px solid #ddd; box-sizing:border-box;"
						     ondrop="dropManual(event)" 
						     ondragover="allowDrop(event)" 
						     ondragend="drogEnd(event)" 
						     ondragleave="drogEnd(event)">
						  <ul id="attach_file_manual_vu">
				            <c:forEach items="${menuData.manualFileList}" var="mfile" varStatus="status">
				              <li data-orgname="${mfile.ORG_FILE_NAME}" data-id="${mfile.FILE_IDX}" data-path="${mfile.FILE_PATH}" data-name="${mfile.FILE_NAME}"><a href="#none" onclick="fn_removeManualTempFile(this, '${mfile.FILE_IDX}')"><img src="/resources/images/icon_del_file.png"></a>${mfile.ORG_FILE_NAME}</li>
				            </c:forEach>
				          </ul>
				        </div>
				
				        <!-- 기존 파일 유지용 hidden select: MENU와 분리된 고유 id/name -->
				        <select id="manualTempFileList_vu" name="manualTempFileList" multiple style="display:none">
				          <c:forEach items="${menuData.manualFileList}" var="mfile">
				            <option value="${mfile.FILE_IDX}" selected>${mfile.ORG_FILE_NAME}</option>
				          </c:forEach>
				        </select>
				      </dd>
				    </li>
				  </ul>
				</div>
				
				<!-- <div class="title2 mt20" style="width:10%; display: inline-block;">
					<button class="btn_con_search" onClick="openDialog('dialog_attatch')">
						<img src="/resources/images/icon_s_file.png" />파일첨부 
					</button>
				</div>
				<div class="con_file" style="">
					<ul>
						<li class="point_img" style="display:flex;">
							<dt>첨부파일</dt><dd>
								<ul id="attatch_file">
								</ul>
							</dd>
						</li>
					</ul>
				</div> -->
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
								<th style="border-left: none;">메뉴코드 <span class="mandatory">*</span></th>
								<td>
									${menuData.data.MENU_CODE}
								</td>
								<th style="border-left: none;">상품코드</th>
								<td>
									<input type="text" style="width:200px; float: left" name="menuSapCode" id="menuSapCode" value="${menuData.data.SAP_CODE}" readonly/>
									<c:if test="${menuData.data.SAP_CODE == '' || menuData.data.SAP_CODE == null}">
									<button class="btn_small_search ml5" onclick="openDialog('dialog_erpMaterial')" style="float: left">조회</button>
									</c:if>
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
							    <th style="border-left: none;">공동 참여자</th>
							    <td colspan="3">
							        <div id="sharedUserTokens" style="width: 450px; float: left; min-height: 24px; border: 1px solid #ccc; padding: 5px;"></div>
							
							        <!-- 숨겨진 input에 ID, 이름 저장 -->
							        <input type="hidden" id="sharedUserIds" name="sharedUserIds" />
									<input type="hidden" id="sharedUserNames" name="sharedUserNames" />
									<input type="hidden" id="sharedUserDepts" name="sharedUserDepts" />
									<input type="hidden" id="sharedUserTeams" name="sharedUserTeams" />
							
							        <!-- 버튼 -->
							        <button class="btn_small_search ml5" style="float:left" onclick="userSearchClass.openSharedUserPopup(); return false;">조회</button>
							        <button class="btn_small_search ml5" onclick="userSearchClass.clearTokens(); return false;">초기화</button>
							    </td>
							</tr>
							<tr>
								<th style="border-left: none;">버전 NO.</th>
								<td colspan="3">
									<input type="text" style="width:50px; float: left" name="versionNo" id="versionNo" value="${menuData.data.VERSION_NO+1}" onkeyup="chkNum(this)"/>
								</td>
							</tr>
						<!-- 
							<tr>
								<th style="border-left: none;">중량</th>
								<td>
									<input type="text"  style="width:200px; float: left" class="" name="weight" id="weight" value="${menuData.data.TOTAL_WEIGHT}"/>
								</td>
								<th style="border-left: none;">메뉴규격</th>
								<td>
									<input type="text"  style="width:350px; float: left" class="" name="standard" id="standard" value="${menuData.data.STANDARD}"/>								
								</td>
								
							</tr>
							<tr>
								<th style="border-left: none;">보관방법</th>
								<td>
									<input type="text"  style="width:350px; float: left" class="" name="keepCondition" id="keepCondition" value="${menuData.data.KEEP_CONDITION}"/>
								</td>
								<th style="border-left: none;">소비기한</th>
								<td>
									<input type="text"  style="width:350px; float: left" class="" name="expireDate" id="expireDate" value="${menuData.data.EXPIRATION_DATE}"/>								
								</td>							
							</tr>
						-->
							<tr>
								<th style="border-left: none;">메뉴유형 <span class="mandatory">*</span></th>
								<td colspan="5">
									<input class="" id="selectTxtFull" name="selectTxtFull" type="text" style="width: 450px; float: left" 
									value="${menuData.data.MENU_TYPE_NAME1}>${menuData.data.MENU_TYPE_NAME2}>${menuData.data.MENU_TYPE_NAME3}" readonly>
									<button class="btn_small_search ml5" onclick="openDialog('dialog_menu')" style="float: left">조회</button>
								</td>
							</tr>
							<tr>
								<th style="border-left: none;">신규원료사용 유무</th>
								<td colspan="5">
									<input type="radio" name="newMat" id="newMat1" value="N" onclick="changeNewMat(event)" ${menuData.data.IS_NEW_MATERIAL == 'N' ? 'checked' : ''}>
									<label for="newMat1"><span></span>사용안함</label>
									<input type="radio" name="newMat" id="newMat2" value="Y" onclick="changeNewMat(event)"  ${menuData.data.IS_NEW_MATERIAL == 'Y' ? 'checked' : ''}>
									<label for="newMat2"><span></span>사용</label>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div id="matNewDiv" style="${menuData.data.IS_NEW_MATERIAL == 'N' ? 'display:none' : ''}">
					<div class="title2" style="float: left; margin-top: 30px;">
						<span class="txt">신규원료</span>
					</div>
					<div id="matHeaderDiv" class="table_header07">
						<span class="table_order_btn"><button class="btn_up" onclick="moveUp(this)"></button><button class="btn_down" onclick="moveDown(this)"></button></span>
						<span class="table_header_btn_box">
							<button class="btn_add_tr" onclick="addRow(this, 'newMat')"></button><button class="btn_del_tr" onclick="removeRow(this)"></button>
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
								<th>보관방법 및 소비기한</th>
								<th>공급가</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="matTbody" name="matTbody">
						<c:forEach items="${menuMaterialData}" var="menuMaterialData" varStatus="status">
							<c:if test="${menuMaterialData.MATERIAL_TYPE == 'Y' }">
							<tr id="newMatRow_${status.count}" class="temp_color">
								<td>
									<input type="checkbox" id="mat_${status.count}"><label for="mat_${status.count}"><span></span></label>
									<input type="hidden" name="itemType" value="${menuMaterialData.MATERIAL_TYPE}"/>
									<input type="hidden" name="itemTypeName"/>
								</td>
								<td>
									<input type="hidden" name="itemMatIdx" style="width: 100px" class="code_tbl" value="${menuMaterialData.MATERIAL_IDX}"/>
									<input type="text" name="itemMatCode" style="width: 100px" class="code_tbl" value="${menuMaterialData.MATERIAL_CODE}" onkeyup="checkMaterail(event,'newMat')"/>
									<button class="btn_code_search2" onclick="openMaterialPopup(this,'newMat')"></button>
								</td>
								<td>
									<input type="text" name="itemSapCode" style="width: 100px" class="code_tbl read_only" value="${menuMaterialData.SAP_CODE}" onkeyup="checkMaterail(event,'newMat')" readonly="readonly"/>
								</td>
								<td>
									<input type="text" name="itemName" style="width: 85%" readonly="readonly" value="${menuMaterialData.NAME}" class="read_only" />
								</td>
								<td><input type="text" name="itemStandard" style="width: 100%" value="${menuMaterialData.STANDARD}" class=""/></td>
								<td><input type="text" name="itemKeepExp" style="width: 100%" value="${menuMaterialData.KEEP_EXP}" class=""/></td>
								<td><input type="text" name="itemUnitPrice" style="width: 100%"  value="${menuMaterialData.UNIT_PRICE}" readonly="readonly" class="read_only"/></td>
								<td><input type="text" name="itemDesc" style="width: 100%" value="${menuMaterialData.DESCRIPTION}"/></td>
							</tr>
							</c:if>	
						</c:forEach>
						<c:if test="${fn:length(menuMaterialData) == 0}">
							<tr id="newMatRow_1" class="temp_color">
								<td>
									<input type="checkbox" id="newMat_1"><label for="newMat_1"><span></span></label>
									<input type="hidden" name="itemType" value="Y"/>
									<input type="hidden" name="itemTypeName"/>
								</td>
								<td>
									<input type="hidden" name="itemMatIdx" style="width: 100px" class="code_tbl"/>
									<input type="text" name="itemMatCode" style="width: 100px" class="code_tbl" onkeyup="checkMaterail(event,'newMat')"/>
									<button class="btn_code_search2" onclick="openMaterialPopup(this,'newMat')"></button>
								</td>
								<td>
									<input type="text" name="itemSapCode" style="width: 100px" class="code_tbl read_only" onkeyup="checkMaterail(event,'newMat')" readonly="readonly"/>
								</td>
								<td>
									<input type="text" name="itemName" style="width: 85%" readonly="readonly" class="read_only" />
								</td>
								<td><input type="text" name="itemStandard" style="width: 100%" class=""/></td>
								<td><input type="text" name="itemKeepExp" style="width: 100%" class=""/></td>
								<td><input type="text" name="itemUnitPrice" style="width: 100%"  readonly="readonly" class="read_only"/></td>
								<td><input type="text" name="itemDesc" style="width: 100%"/></td>
							</tr>
						</c:if>	
						</tbody>
						<tfoot>
						</tfoot>
					</table>
				</div>
				
				<div id="matDiv">
					<div class="title2" style="float: left; margin-top: 30px;">
						<span class="txt">기존원료</span>
					</div>
					<div id="matHeaderDiv" class="table_header07">
						<span class="table_order_btn"><button class="btn_up" onclick="moveUp(this)"></button><button class="btn_down" onclick="moveDown(this)"></button></span>
						<span class="table_header_btn_box">
							<button class="btn_add_tr" onclick="addRow(this, 'mat')"></button><button class="btn_del_tr" onclick="removeRow(this)"></button>
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
								<th>보관방법 및 소비기한</th>
								<th>공급가</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="matTbody" name="matTbody">
						<c:forEach items="${menuMaterialData}" var="menuMaterialData" varStatus="status">
							<c:if test="${menuMaterialData.MATERIAL_TYPE == 'N' }">
							<c:set var="count" value="${count + 1}" />
							<tr id="matRow_${status.count}" class="temp_color">
								<td>
									<input type="checkbox" id="mat_${status.count}"><label for="mat_${status.count}"><span></span></label>
									<input type="hidden" name="itemType" value="${menuMaterialData.MATERIAL_TYPE}"/>
									<input type="hidden" name="itemTypeName"/>
								</td>
								<td>
									<input type="hidden" name="itemMatIdx" style="width: 100px" class="code_tbl" value="${menuMaterialData.MATERIAL_IDX}"/>
									<input type="text" name="itemMatCode" style="width: 100px" class="code_tbl read_only" value="${menuMaterialData.MATERIAL_CODE}" onkeyup="checkMaterail(event,'mat')" readonly="readonly"/>
								</td>
								<td>
									<input type="text" name="itemSapCode" style="width: 100px" class="code_tbl" value="${menuMaterialData.SAP_CODE}"/>
									<button class="btn_code_search2" onclick="openMaterialPopup(this,'mat')"></button>						
								</td>
								<td>
									<input type="text" name="itemName" style="width: 85%" readonly="readonly" value="${menuMaterialData.NAME}" class="read_only" />
								</td>
								<td><input type="text" name="itemStandard" style="width: 100%" value="${menuMaterialData.STANDARD}" class=""/></td>
								<td><input type="text" name="itemKeepExp" style="width: 100%" value="${menuMaterialData.KEEP_EXP}" class=""/></td>
								<td><input type="text" name="itemUnitPrice" style="width: 100%"  value="${menuMaterialData.UNIT_PRICE}" readonly="readonly" class="read_only"/></td>
								<td><input type="text" name="itemDesc" style="width: 100%" value="${menuMaterialData.DESCRIPTION}"/></td>
							</tr>
							</c:if>	
						</c:forEach>
						<c:if test="${fn:length(menuMaterialData) == 0}">
							<tr id="matRow_1" class="temp_color">
								<td>
									<input type="checkbox" id="mat_1"><label for="mat_1"><span></span></label>
									<input type="hidden" name="itemType" value="N"/>
									<input type="hidden" name="itemTypeName"/>
								</td>
								<td>
									<input type="hidden" name="itemMatIdx" style="width: 100px" class="code_tbl"/>
									<input type="text" name="itemMatCode" style="width: 100px" class="code_tbl read_only" onkeyup="checkMaterail(event,'mat')" readonly="readonly"/>
								</td>
								<td>
									<input type="text" name="itemSapCode" style="width: 100px" class="code_tbl"/>
									<button class="btn_code_search2" onclick="openMaterialPopup(this,'mat')"></button>							
								</td>
								<td>
									<input type="text" name="itemName" style="width: 85%" readonly="readonly" class="read_only" />
								</td>
								<td><input type="text" name="itemStandard" style="width: 100%" class=""/></td>
								<td><input type="text" name="itemKeepExp" style="width: 100%" class=""/></td>
								<td><input type="text" name="itemUnitPrice" style="width: 100%"  readonly="readonly" class="read_only"/></td>
								<td><input type="text" name="itemDesc" style="width: 100%" /></td>
							</tr>
						</c:if>		
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
								<textarea name="contents" id="contents" style="width: 666px; height: 200px; display: none;">${menuData.data.CONTENTS}</textarea>
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
					<c:if test="${userUtil:getUserId(pageContext.request) == menuData.data.DOC_OWNER}">
					<button class="btn_admin_navi" onclick="fn_insertTmp()">임시저장</button>
					<button class="btn_admin_sky" onclick="fn_insert()">결재</button>
					</c:if>
					<button class="btn_admin_gray" onclick="fn_goList();">취소</button>
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
				<input type="hidden" name="itemMatIdx" style="width: 100px" class="code_tbl" />
				<input type="text" name="itemMatCode" style="width: 100px" class="code_tbl" onkeyup="checkMaterail(event,'newMat')"/>
				<button class="btn_code_search2" onclick="openMaterialPopup(this,'newMat')"></button>
			</td>
			<td>
				<input type="text" name="itemSapCode" class="read_only" style="width: 100px" readonly="readonly"/>
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
				<input type="hidden" name="itemMatIdx" style="width: 100px" class="code_tbl" />
				<input type="text" name="itemMatCode" style="width: 100px" class="code_tbl read_only" onkeyup="checkMaterail(event,'mat')" readonly="readonly"/>
			</td>
			<td>
				<input type="text" name="itemSapCode" style="width: 100px" class="code_tbl"/>
				<button class="btn_code_search2" onclick="openMaterialPopup(this,'mat')"></button>
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
			<span class="title">상품코드 검색</span>
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
<!-- 코드검색 추가레이어 close-->
<!-- SAP 코드 검색 레이어 close-->

<!-- 첨부파일 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<!-- <div class="white_content" id="dialog_attatch">
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
								<label class="btn-default" for="attatch_common" style="float:left; margin-left: 5px; width: 57px">파일 선택</label>
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
</div> -->
<!-- 파일 생성레이어 close-->

<!-- 원료 선택 레이어 start-->
<div class="white_content" id="dialog_menu">
	<div class="modal" style="	width: 400px;margin-left:-210px;height: 350px;margin-top:-100px;">
		<h5 style="position:relative">
			<span class="title">제품구분</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('dialog_menu')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div style="height: 200px; overflow-x: hidden; overflow-y: auto;">
			<div id="jsTree"></div> 
		</div>
		<div class="btn_box_con">
			<button class="btn_small02" onclick="closeDialog('dialog_menu')"> 취소</button>
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
			<span class="title">상품코드 검색</span>
			<div class="top_btn_box">
				<ul>
					<li><button class="btn_madal_close" onClick="fn_closeMatRayer()"></button></li>
				</ul>
			</div>
		</h5>

		<div id="matListDiv" class="code_box">
			<input id="searchMatValue" type="text" class="code_input" onkeyup="bindDialogEnter2(event)" style="width: 300px;" placeholder="일부단어로 검색가능">
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
	<input type="hidden" id="docType" value="MENU"/>
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
			<span class="title">메뉴완료보고서 결재 상신</span>
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
						<th><input  style='width:20px; height:20px;' type="checkbox" id="selectAllBrands" onclick="toggleSelectAllBrands(this)"></th>	
						<th>브랜드 코드</th>
						<th>브랜드 명</th>
					</tr>
				</thead>
				<tbody id="brandLayerBody">
					<input type="hidden" id="brandLayerPage" value="0"/>
					<Tr>
						<td colspan="10">원료코드 혹은 원료코드명을 검색해주세요</td>
					</Tr>
				</tbody>
			</table>
		</div>
		<div style="margin-top: 40px;">
		    <!-- ✅ 선택 완료 버튼 추가 -->
		    <div style="text-align: right;">
		      <button class="btn_admin_red" onclick="chooseBrandMulti()">확인</button>
		      <button class="btn_admin_gray" onclick="closeDialog('dialog_brand')">취소</button>
		    </div>
		</div>
	</div>
</div>
<!-- 브랜드 선택 레이어 close -->
<!-- 공동 참여자 팝업 start -->
<div class="white_content" id="sharedUserDialog">
    <input type="hidden" id="sharedUserId" />
	<input type="hidden" id="sharedUserName" />
	<input type="hidden" id="sharedUserDept" />
	<input type="hidden" id="sharedUserTeam" />

    <div class="modal" style="margin-left:-400px;width:800px;height: 450px;margin-top:-250px">
        <h5 style="position:relative">
            <span class="title">공동 참여자 선택</span>
            <div class="top_btn_box">
                <ul>
                    <li>
                        <button class="btn_madal_close" onClick="userSearchClass.close(); return false;"></button>
                    </li>
                </ul>
            </div>
        </h5>
        <div class="list_detail">
            <ul>
                <!-- 사용자 검색 라인 -->
				<li>
				    <dt style="width:20%">사용자 검색</dt>
				    <dd style="width:80%; display: flex; justify-content: flex; align-items: center;">
				        <input type="text" id="sharedUserKeyword" placeholder="이름 2자 이상 입력" style="width:200px; margin-right: 5px;">
				        <button class="btn_small01" onclick="sharedUserClass.add()">추가</button>
				    </dd>
				</li>
				
				<!-- 선택된 사용자 라인 -->
				<li class="mt5">
				    <dt style="width:20%">선택된 사용자</dt>
				    <dd style="width:80%;">
				        <div class="file_box_pop2" style="height:180px;">
				            <ul id="sharedUserList" style="margin-top:10px;"></ul>
				        </div>
				    </dd>
				</li>
            </ul>
        </div>
        <div class="btn_box_con4" style="padding:15px 0 20px 0">
            <button class="btn_admin_red" onclick="userSearchClass.submit(); return false;">확인</button>
            <button class="btn_admin_gray" onclick="userSearchClass.close(); return false;">취소</button>
        </div>
    </div>
</div>
<!-- 공동 참여자 팝업 close -->