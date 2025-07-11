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
	fn_loadUnit();
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
});

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
	
	var childTag = '<li><a href="#none" onclick="removeTempFile(this, \''+randomId+'\')"><img src="/resources/images/icon_del_file.png"></a>&nbsp;'+fileName+'</li>'
	$('ul[name=popFileList]').append(childTag);
	$('#attatch_common').val('');
	$('#attatch_common').change();
}
function removeTempFile(element, tempId){
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
	
	attatchFileTypeArr.forEach(function(object,idx){
		/*if( idx == 0 ) {
			$("#attatch_file_10").html("");
			$("#attatch_file_20").html("");
			$("#attatch_file_30").html("");
			$("#attatch_file_40").html("");
			$("#attatch_file_50").html("");
		}*/
		var tempId = object.tempId;
		var childTag = '<li><a href="#none" onclick="removeFile(this, \''+tempId+'\')"><img src="/resources/images/icon_del_file.png"></a>&nbsp;'+attatchFileArr[idx].name+'</li>'
		//$("#attatch_file_"+object.fileType).append(childTag);
		$("#fileData").append(childTag);
	});
	
	$("#docTypeTemp").removeOption(/./);
	var docTypeTxt = "";
	$('input:checkbox[name=docType]').each(function (index) {
		if($(this).is(":checked")==true){
	    	$("#docTypeTemp").addOption($(this).val(), $(this).next("label").text(), true);
	    	if( index != 0 ) {
	    		docTypeTxt += ", "+$(this).next("label").text();
	    	} else {
	    		docTypeTxt += $(this).next("label").text();
	    	}
	    }
	});
	$("#docTypeTxt").html(docTypeTxt);
	closeDialogWithClean('dialog_attatch');
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
	}/*else if( $("#company").selectedValues()[0] == '' ) {
		alert("회사를 선택하여 주세요.");
		$("#company").focus();
		return;
	} else if( $("#plant").selectedValues()[0] == '' ) {
		alert("공장을 선택하여 주세요.");
		$("#plant").focus();
		return;
	}*/ else if( !chkNull($("#price").val()) ) {
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
	} else if( attatchFileArr.length == 0 ) {
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
		
		console.log(attatchFileArr);
		console.log(attatchFileTypeArr);
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
					alert($("#name").val()+"("+$("#sapCode").val()+")"+"가 정상적으로 개정었습니다.");
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
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="list_detail">
				<ul style="border-top:none;">
					<li  class="pt10">
						<dt>원료 코드</dt>
						<dd>
							<input type="hidden"  name="idx" id="idx" value="${materialData.data.MATERIAL_IDX}"/>
							<input type="hidden"  name="docNo" id="docNo" value="${materialData.data.DOC_NO}"/>
							<input type="hidden"  name="versionNo" id="versionNo" value="${materialData.data.VERSION_NO}"/>
							<input type="hidden"  name="isSample" id="isSample" value="${materialData.data.IS_SAMPLE}"/>
							<input type="hidden"  name="matCode" id="matCode" value="${materialData.data.MATERIAL_CODE}"/>
							${materialData.data.MATERIAL_CODE}
						</dd>
					</li>
					<li class="">
						<dt>ERP 코드</dt>
						<dd>
							<input type="text"  style="width:200px; float: left" class="req" name="sapCode" id="sapCode" value="${materialData.data.SAP_CODE}" placeholder="코드를 조회/생성 하세요." readonly/>
							<button class="btn_small_search ml5" onclick="openDialog('dialog_material')" style="float: left">조회</button>
						</dd>
					</li>
					<li>
						<dt>원료명</dt>
						<dd>
							<input type="text" value="${materialData.data.NAME}" class="req" style="width:302px;" name="name" id="name" placeholder="원료명을 입력하세요."/> 
						</dd>
					</li>
					<!--li>
						<dt>공장</dt>
						<dd>
							<div class="selectbox req" style="width:147px;">  
								<label for="company" id="company_label"> 선택</label> 
								<select id="company" name="company" onChange="companyChange('company','plant')">
								</select>
							</div>
							<div class="selectbox req ml5" style="width:147px;">  
								<label for="plant" id="plant_label"> 선택</label> 
								<select id="plant" name="plant">
								</select>
							</div>
						</dd>
					</li-->
					<li>
						<dt>단가</dt>
						<dd>
							<input type="text" class="req" style="width:149px;" name="price" id="price" placeholder="숫자만 입력하세요." onkeyup="checkDecNum(this)" value="${materialData.data.PRICE}">
						</dd>
					</li>
					<li>
						<dt>단위</dt>
						<dd>
							<div class="selectbox req" style="width:147px;">  
								<label for="unit" id="unit_label"> 선택</label> 
								<select id="unit" id="unit">
								</select>
							</div>
						</dd>
					</li>
					<li>
						<dt>보관기준</dt>
						<dd>
							<input type="text" class="req" style="width:149px;" name="keepCondition" id="keepCondition" value="${materialData.data.KEEP_CONDITION}">
						</dd>
					</li>
					<li>
						<dt>사이즈</dt>
						<dd>
							<input type="text" class="req" style="width:49px;" name="width" id="width" onkeyup="checkDecNum(this)" value="${materialData.data.WIDTH}"> /
							<input type="text" class="req" style="width:49px;" name="length" id="length" onkeyup="checkDecNum(this)" value="${materialData.data.LENGTH}"> /
							<input type="text" class="req" style="width:49px;" name="height" id="height" onkeyup="checkDecNum(this)" value="${materialData.data.HEIGHT}">
						</dd>
					</li>
					<li>
						<dt>중량</dt>
						<dd>
							<input type="text" class="req" style="width:149px;" name="weight" id="weight" placeholder="숫자만 입력하세요." onkeyup="checkDecNum(this)" value="${materialData.data.TOTAL_WEIGHT}">
						</dd>
					</li>
					<li>
						<dt>규격</dt>
						<dd>
							<input type="text" class="req" style="width:302px;" name="standard" id="standard" value="${materialData.data.STANDARD}">
						</dd>
					</li>
					<li>
						<dt>원산지</dt>
						<dd>
							<input type="text" class="req" style="width:302px;" name="origin" id="origin" value="${materialData.data.ORIGIN}">
						</dd>
					</li>
					<li>
						<dt>유통기한</dt>
						<dd>
							<input type="text" class="req" style="width:149px;" name="expireDate" id="expireDate" value="${materialData.data.EXPIRATION_DATE}">
						</dd>
					</li>
					<!--li>
						<dt>원료구분</dt>
						<dd>
							<input type="radio" name="type" id="type1" value="M" checked/ ><label for="type1"><span></span>원료</label>
							<input type="radio" name="type" id="type2" value="S"/><label for="type2"><span></span>부자재</label>
						</dd>
					</li-->
					<li>
						<dt>원료구분상세</dt>
						<dd>
							<input class="" id="selectTxtFull" name="selectTxtFull" type="text" style="width: 250px; float: left" value="${materialData.data.MATERIAL_TYPE_NAME1}>${materialData.data.MATERIAL_TYPE_NAME2}>${materialData.data.MATERIAL_TYPE_NAME3}" readonly>
							<button class="btn_small_search ml5" onclick="openDialog('open2')" style="float: left">조회</button>
						</dd>
					</li>
					<li>
						<dt>제조사/공급처</dt>
						<dd>
							<input type="text" class="req" style="width:302px;" name="supplier" id="supplier" value="${materialData.data.SUPPLIER}">
						</dd>
					</li>
					<li>
						<dt>첨부파일 유형</dt>
						<dd>
							<div id="docTypeTxt">
								<c:forEach items="${fileType}" var="fileType" varStatus="status">
									<c:if test="${status.index ne 0}">, </c:if>${fileType.FILE_TEXT}
								</c:forEach>
							</div>
							<select id="docTypeTemp" name="docTypeTemp" multiple style='display:none'>
								<c:forEach items="${fileType}" var="fileType" varStatus="status">
								<option value="${fileType.FILE_TYPE}">${fileType.FILE_TEXT}</option>
								</c:forEach>
							</select>
						</dd>
					</li>
					<li>
						<div class="add_file2" id="add_file2" style="width:97.5%">
							<span class="file_load" id="fileSpan1">
								<label for="file1" onClick="openDialog('dialog_attatch')">첨부파일 등록 <img src="/resources/images/icon_add_file.png"></label>
							</span>
							<span id="upFile"></span>
						</div>
						<div class="file_box_pop" style=" height:85px; width:97.5%; border-top-left-radius:0px;border-top-right-radius:0px; border-top:1px solid #ddd;box-sizing:border-box;" id="fileList">
							<ul id="fileData">									
							</ul>
						</div>
					</li>
				</ul>
			</div>
			<div class="btn_box_con5">
			</div>
			<div class="btn_box_con4"> 
				<!--input type='button' value="상신" class="btn_admin_red" id="request" onclick="javascript:goInsert();"-->
				<input type='button' value="개정" class="btn_admin_sky" id="save" onclick="javascript:fn_insert();">
				<input type='button' value="취소" class="btn_admin_gray" id="cancel" onclick="javascript:fn_goList();">
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

<!-- 첨부파일 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_attatch">
	<div class="modal" style="margin-left: -355px; width: 750px; height: 550px; margin-top: -250px">
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
					<dt style="width: 20%">파일리스트</dt>
					<dd style="width: 80%;">
						<input id="checkbox_item1" name="docType" type="checkbox" value="10"/>
						<label for="checkbox_item1" style="vertical-align: middle;"><span></span>품목제조보고서</label>
						<input id="checkbox_item2" name="docType" type="checkbox" value="20"/>
						<label for="checkbox_item2" style="vertical-align: middle;"><span></span>수입신고필증</label>
						<input id="checkbox_item3" name="docType" type="checkbox" value="30"/>
						<label for="checkbox_item3" style="vertical-align: middle;"><span></span>시험성적서(국내)</label>
						<input id="checkbox_item4" name="docType" type="checkbox" value="40"/>
						<label for="checkbox_item4" style="vertical-align: middle;"><span></span>시험성적서(해외)</label>
						<br>
						<input id="checkbox_item5" name="docType" type="checkbox" value="50"/>
						<label for="checkbox_item5" style="vertical-align: middle;"><span></span>한글표시사항</label>
						<input id="checkbox_item6" name="docType" type="checkbox" value="60"/>
						<label for="checkbox_item6" style="vertical-align: middle;"><span></span>견적서</label>
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
							<th>유통기한</th>
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