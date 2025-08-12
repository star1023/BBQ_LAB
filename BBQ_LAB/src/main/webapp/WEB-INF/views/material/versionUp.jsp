<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.genesiskorea.util.*" %> 
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ page session="false" %>
<title>원료등록</title>
<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="../resources/js/jstree.js"></script>
<script>
var selectedArr = new Array();
$(document).ready(function(){
	fn_loadCategory();
	fn_loadCode("UNIT", "unit");
	fn_loadCode("KEEP_CONDITION", "keepCondition");
	if( '${materialData.data.MATERIAL_TYPE3}' != '' ) {
		selectedArr.push('${materialData.data.MATERIAL_TYPE3}');
	}
	if( '${materialData.data.MATERIAL_TYPE2}' != '' ) {
		selectedArr.push('${materialData.data.MATERIAL_TYPE2}');
	}
	if( '${materialData.data.MATERIAL_TYPE1}' != '' ) {
		selectedArr.push('${materialData.data.MATERIAL_TYPE1}');
	}
	console.log(selectedArr);
	
	$("#unit").val('${materialData.data.UNIT}').prop("selected", true);
	$("#unit_label").html($("#unit option:checked").text());
	
	$("#keepCondition").val('${materialData.data.KEEP_CONDITION}').prop("selected", true);
	$("#keepCondition_label").html($("#keepCondition option:checked").text());
	
	
	<c:forEach var="fileType" items="${materialData.fileType}" varStatus="status">
	$('input[type="checkbox"][value="${fileType.FILE_TYPE}"]').prop('checked', true);
	</c:forEach>
	
	const docCheckboxes = $('input[name="docType"]'); // checkAll은 name이 없으므로 자동 제외됨
	const allChecked = docCheckboxes.length > 0 && docCheckboxes.filter(':checked').length === docCheckboxes.length;
	$('#checkAll').prop('checked', allChecked);
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
				if( value.itemCode != '999' ) {
					$("#"+selectBoxId).addOption(value.itemCode, value.itemName, false);	
				}
			});
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}			
	});
}

function fn_loadUnit() {
	var URL = "../common/unitListAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			
		},
		dataType:"json",
		async:false,
		success:function(data) {
			var list = data;
			$("#unit").removeOption(/./);
			$("#unit").addOption("", "전체", false);
			$.each(list, function( index, value ){ //배열-> index, value
				if( '${materialData.data.UNIT}' == value ) {
					$("#unit").addOption(value.unitCode, value.unitName, true);
				} else {
					$("#unit").addOption(value.unitCode, value.unitName, false);	
				}
				
			});
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}			
	});
	$("#unit").val('${materialData.data.UNIT}').prop("selected", true);
	$("#unit_label").html($("#unit option:checked").text());
}

function fn_loadCategory() {
	var URL = "../common/categoryListAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			pId : "1"
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
		 //$(this).jstree("open_all");
	}).on("select_node.jstree",function(e,data){
		selectedArr = new Array();
		//console.log(e);
		console.log(data);
		var selectTxtFull = "";
		var parents = data.node.parents;
		var selectTxt = data.node.text;
		var selectId = data.node.id;
		console.log(parents);
		console.log(selectTxt);
		selectedArr.push(selectId);
		selectTxtFull += selectTxt;
		
		$.each(parents, function( index, value ){ //배열-> index, value
			if( value != '#' ) { 
				console.log($(this).jstree(true).get_node(value).text);
				selectedArr.push(value);
				selectTxtFull = $(this).jstree(true).get_node(value).text + ">" +selectTxtFull
			}
		});
		console.log(selectedArr);
		//$("#selectTxtFull").html(selectTxtFull);
		$("#selectTxtFull").val(selectTxtFull);
		closeDialog('open2');
	});
	//.bind("refresh.jstree",function(){
	//	
	//});
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

function checkDecNum(obj){
	var needToSet = false;
	var numStr = obj.value;
	var temps = numStr.split("."); //소수점 체크를 위해 입력값을 '.'을 기준으로 나누고 temps는 배열이됨
	var CaretPos = doGetCaretPosition(obj); //input field에서의 캐럿의 위치를 확인
	if(2 < temps.length){ //배열 사이즈가 2보다 크면, '.' 가 두개 이상인 경우임.
		var tempIdx = 0;
		numStr = "";
		for(i=0;i<temps.length;i++) {
			numStr += temps[i];   //최종 문자에 현재 스트링을 합한다.
		}
		needToSet = true;
		alert("소수점은 두개이상 입력 하시면 안됩니다.");
	} 
	if((/[^\d.]/g).test(numStr)) {  //숫자 '.'  이외 엔 없는지 확인 후 있으면 replace
		numStr = numStr.replace(/[^\d.]/g,"");
		CaretPos--;
		alert("입력은 숫자와 소수점 만 가능 합니다.");('.')
		needToSet = true;
	} 
	if ((/^\./g).test(numStr)){ //첫번째가 '.' 이면 .를 삭제
		numStr = numStr.replace(/^\./g, "");
		alert("소수점이 첫 글자이면 안됩니다.");
		needToSet = true;
	}
	if(needToSet) { //변경이 필요할 경우에만 셋팅함.
		obj.value = numStr;
		setCaretPosition(obj, CaretPos)
	}
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
	//console.log(attatchFileArr);
}

function fn_removeTempFile(el, fileIdx) {
	$("#tempFileList").removeOption(fileIdx);
    // 화면에서 삭제
    const $li = $(el).closest('li');
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

//입력확인
function fn_insert(){
	if( !chkNull($("#name").val()) || $("#name").val() == "[임시]" ) {
		alert("원료명을 입력하여 주세요.");
		$("#name").focus();
		return;
	} else if( !chkNull($("#price").val()) ) {
		alert("단가를 입력하여 주세요.");
		$("#price").focus();
		return;
	} else if( $("#unit").selectedValues()[0] == '' ) {
		alert("단위를 선택하여 주세요.");
		$("#unit").focus();
		return;
	} else if( selectedArr.length == 0 ) {
		alert("원료구분을 선택하여 주세요.");		
		return;
	} else if( attatchFileArr.length == 0 && $("#tempFileList option").length == 0 ) {
		alert("첨부파일을 등록해주세요.");		
		return;
	} else {
		$('#lab_loading').show();
		URL = "../material/insertNewVersionAjax";
		var formData = new FormData();
		formData.append("name",$("#name").val());
		formData.append("matCode",$("#matCode").val());
		formData.append("sapCode",$("#sapCode").val());
		formData.append("company",$("#company").selectedValues()[0]);
		formData.append("plant",$("#plant").selectedValues()[0]);
		formData.append("price",$("#price").val());
		formData.append("unit",$("#unit").selectedValues()[0]);
		formData.append("materialType",selectedArr.reverse());
		formData.append("currentIdx",$("#idx").val());
		formData.append("currentVersionNo",$("#versionNo").val());
		formData.append("docNo",$("#docNo").val());
		formData.append("isLast","Y");
		formData.append("isSample",$("#isSample").val());
		formData.append("keepCondition",$("#keepCondition").val());
		formData.append("width",$("#width").val());
		formData.append("length",$("#length").val());
		formData.append("height",$("#height").val());
		formData.append("weight",$("#weight").val());
		formData.append("standard",$("#standard").val());
		formData.append("origin",$("#origin").val());
		formData.append("expireDate",$("#expireDate").val());
		formData.append("supplier",$("#supplier").val());
		
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
					alert($("#name").val()+"가 정상적으로 개정었습니다.");
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
	location.href = '/material/list';
}

function fn_closeMatRayer(){
	$('#searchMatValue').val('')
	$('#matLayerBody').empty();
	$('#matLayerBody').append('<tr><td colspan="9">원료코드 혹은 원료코드명을 검색해주세요</td></tr>');
	$('#matCount').text(0);
	closeDialog('dialog_material');
}

function fn_searchErpMaterial(pageType) {
	var pageType = pageType;
	console.log(pageType);
	if(!pageType)
		$('#matLayerPage').val(1);
	
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
	
	$.ajax({
		url: '/material/selectErpMaterialListAjax',
		type: 'post',
		dataType: 'json',
		data: {
			searchValue: $('#searchMatValue').val(),
			pageNo: $('#matLayerPage').val()
		},
		success: function(data){
			var jsonData = {};
			jsonData = data;
			$('#matLayerBody').empty();
			$('#matLayerBody').append('<input type="hidden" id="matLayerPage" value="'+data.pageNo+'"/>');
			
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
	$("#name").val(NAME);
	$("#sapCode").val(SAP_CODE);
	$("#isSample").val("N");
	$("#keepCondition").val(KEEP_CONDITION);
	$("#width").val(WIDTH);
	$("#length").val(LENGTH);
	$("#height").val(HEIGHT);
	$("#weight").val(TOTAL_WEIGHT);
	$("#standard").val(STANDARD);
	$("#origin").val(ORIGIN);
	$("#expireDate").val(EXPIRATION_DATE);
	$("#name").prop("readonly",true);
	fn_closeMatRayer();
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

function fn_initalCode() {
	$("#name").val("");
	$("#sapCode").val("");
}

</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">원료관리&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative"><span class="title_s">Material management</span>
			<span class="title" id="span_reportTitle">원료등록</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_circle_nomal" onClick="fn_goList(); return false;">&nbsp;</button>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title2"  style="display: flex; justify-content:space-between; width: 100%;">
				<span class="txt">기본정보</span>
				<div class="pr15">
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
							<th style="border-left: none;">ERP 코드<span class="mandatory">*</span></th>
							<td>
								<input type="hidden"  name="idx" id="idx" value="${materialData.data.MATERIAL_IDX}"/>
								<input type="hidden"  name="docNo" id="docNo" value="${materialData.data.DOC_NO}"/>
								<input type="hidden"  name="versionNo" id="versionNo" value="${materialData.data.VERSION_NO}"/>
								<input type="hidden"  name="isSample" id="isSample" value="${materialData.data.IS_SAMPLE}"/>
								<input type="hidden"  name="matCode" id="matCode" value="${materialData.data.MATERIAL_CODE}"/>
								<input type="text"  style="width:200px; float: left"  name="sapCode" id="sapCode" placeholder="코드를 조회/생성 하세요." readonly/>
								<button class="btn_small_search ml5" onclick="openDialog('dialog_material')" style="float: left">조회</button>
								<button class="btn_small_search ml5" onclick="fn_initalCode()" style="float: left">초기화</button>
							</td>
							<th style="border-left: none;">원료명<span class="mandatory">*</span></th>
							<td>
								<input type="text" value="${materialData.data.NAME}" style="width:302px;" name="name" id="name" placeholder="원료명을 입력하세요."/>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">단가</th>
							<td>
								<input type="text"  style="width:149px;" name="price" id="price" placeholder="숫자만 입력하세요." onkeyup="checkDecNum(this)" value="${materialData.data.PRICE}">
							</td>
							<th style="border-left: none;">단위<span class="mandatory">*</span></th>
							<td>
								<div class="selectbox" style="width:147px;">  
									<label for="unit" id="unit_label"> 선택</label> 
									<select id="unit" id="unit">
									</select>
								</div>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">보관기준<span class="mandatory">*</span></th>
							<td>
								<div class="selectbox" style="width:147px;">  
									<label for="keepCondition" id="keepCondition_label"> 선택</label> 
									<select id="keepCondition" id="keepCondition">
									</select>
								</div>
							</td>
							<th style="border-left: none;">사이즈<span class="mandatory">*</span></th>
							<td>
								<input type="text"  style="width:49px;" name="width" id="width" onkeyup="checkDecNum(this)" value="${materialData.data.WIDTH}"> /
								<input type="text"  style="width:49px;" name="length" id="length" onkeyup="checkDecNum(this)" value="${materialData.data.LENGTH}"> /
								<input type="text"  style="width:49px;" name="height" id="height" onkeyup="checkDecNum(this)" value="${materialData.data.HEIGHT}">
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">중량<span class="mandatory">*</span></th>
							<td>
								<input type="text" style="width:149px;" name="weight" id="weight" placeholder="숫자만 입력하세요." onkeyup="checkDecNum(this)" value="${materialData.data.TOTAL_WEIGHT}">
							</td>
							<th style="border-left: none;">규격<span class="mandatory">*</span></th>
							<td>
								<input type="text"  style="width:302px;" name="standard" id="standard" value="${materialData.data.STANDARD}">
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">원산지<span class="mandatory">*</span></th>
							<td>
								<input type="text"  style="width:302px;" name="origin" id="origin" value="${materialData.data.ORIGIN}">
							</td>
							<th style="border-left: none;">소비기한<span class="mandatory">*</span></th>
							<td>
								<input type="text"  style="width:149px;" name="expireDate" id="expireDate" value="${materialData.data.EXPIRATION_DATE}">
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">원료구분상세<span class="mandatory">*</span></th>
							<td colspan="3">
								<input class="" id="selectTxtFull" name="selectTxtFull" type="text" style="width: 302px; float: left" value="${materialData.data.MATERIAL_TYPE_NAME1}>${materialData.data.MATERIAL_TYPE_NAME2}>${materialData.data.MATERIAL_TYPE_NAME3}" readonly>
								<button class="btn_small_search ml5" onclick="openDialog('open2')" style="float: left">조회</button>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">제조사/공급처</th>
							<td colspan="3">
								<input type="text"  style="width:302px;" name="supplier" id="supplier" value="${materialData.data.SUPPLIER}">
							</td>
						</tr>
					</tbody>					
				</table>	
			</div>
			
			<div class="title2 mt20" style="width: 90%;">
				<span class="txt">파일첨부</span>
			</div>
			<div class="list_detail">
				<ul style="">
					<li>
						<dt style="width: 20%">파일유형 <span class="mandatory">*</span></dt>
						<dd style="width: 80%;">
							<input id="checkAll" type="checkbox" onchange="toggleDocTypeCheckboxes(this)" /><label for="checkAll" style="vertical-align: middle; font-weight: bold;"><span></span>전체 선택</label> 
							<input id="checkbox_item1" name="docType" type="checkbox" value="10" onchange="syncCheckAll()"/><label for="checkbox_item1" style="vertical-align: middle;"><span></span>품목제조보고서</label>
							<input id="checkbox_item2" name="docType" type="checkbox" value="20" onchange="syncCheckAll()"/><label for="checkbox_item2" style="vertical-align: middle;"><span></span>수입신고필증</label>
							<input id="checkbox_item3" name="docType" type="checkbox" value="30" onchange="syncCheckAll()"/><label for="checkbox_item3" style="vertical-align: middle;"><span></span>시험성적서(국내)</label>
							<input id="checkbox_item4" name="docType" type="checkbox" value="40" onchange="syncCheckAll()"/><label for="checkbox_item4" style="vertical-align: middle;"><span></span>시험성적서(해외)</label>
							<input id="checkbox_item5" name="docType" type="checkbox" value="50" onchange="syncCheckAll()"/><label for="checkbox_item5" style="vertical-align: middle;"><span></span>한글표시사항</label>
							<input id="checkbox_item6" name="docType" type="checkbox" value="60" onchange="syncCheckAll()"/><label for="checkbox_item6" style="vertical-align: middle;"><span></span>견적서</label>
							<select id="tempFileList" name="tempFileList" multiple style="display: none">
							<c:forEach items="${materialData.fileList}" var="fileList" varStatus="status">
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
									<c:forEach items="${materialData.fileList}" var="fileList" varStatus="status">
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
				</div>
				<div class="btn_box_con4">
					<button class="btn_admin_sky" onclick="javascript:fn_insert();">개정</button>
					<button class="btn_admin_gray" onclick="fn_goList()">목록</button>
				</div>
				<hr class="con_mode" />
			</div>
		</div>
	</section>	
</div>

<!-- 원료 선택 레이어 start-->
<div class="white_content" id="open2">
	<div class="modal" style="	width: 400px;margin-left:-210px;height: 350px;margin-top:-100px;">
		<h5 style="position:relative">
			<span class="title">원료구분</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('open2')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div style="height: 200px; overflow-x: hidden; overflow-y: auto;">
			<div id="jsTree"></div> 
		</div>
		<div class="btn_box_con">
			<button class="btn_small02" onclick="closeDialog('open2')"> 취소</button>
		</div>
	</div>
</div>
<!-- 원료 선택 레이어 close-->

<!-- SAP 코드 검색 레이어 start-->
<!-- SAP 코드 검색 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_material">
	<input id="targetID" type="hidden">
	<input id="itemType" type="hidden">
	<div class="modal positionCenter" style="width: 900px; height: 600px; margin-left: -455px; margin-top: -250px ">
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
			<img src="/resources/images/icon_code_search.png" onclick="fn_searchErpMaterial()"/>
			<div class="code_box2">
				(<strong> <span id="matCount">0</span> </strong>)건
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
							<th>SAP코드</th>
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
							<td colspan="9">원료코드 혹은 원료코드명을 검색해주세요</td>
						</Tr>
					</tbody>
				</table>
				<!-- 뒤에 추가 리스트가 있을때는 클래스명 02로 숫자변경 -->
				<div id="matNextPrevDiv" class="page_navi  mt10">
					<button class="btn_code_left01" onclick="fn_searchErpMaterial('prevPage')"></button>
					<button class="btn_code_right02" onclick="fn_searchErpMaterial('nextPage')"></button>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- 코드검색 추가레이어 close-->
<!-- SAP 코드 검색 레이어 close-->