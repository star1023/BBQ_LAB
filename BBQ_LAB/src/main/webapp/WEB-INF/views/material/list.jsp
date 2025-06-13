<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ page session="false" %>
<title>원료관리</title>
<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="../resources/js/jstree.js"></script>
<script type="text/javascript">
$(document).ready(function(){
	fn_loadList(1);
	fn_loadCategory();
	fn_loadSearchCategory(1,1);
});


var selectedArr = new Array();

function fn_loadList(pageNo) {
	var URL = "../material/selectMaterialListAjax";
	var viewCount = $("#viewCount").selectedValues()[0];
	if( viewCount == '' ) {
		viewCount = "10";
	}
	$("#list").html("<tr><td align='center' colspan='8'>조회중입니다.</td></tr>");
	$('.page_navi').html("");
	$.ajax({
		type:"POST",
		url:URL,
		data:{
				"searchType" : $("#searchType").selectedValues()[0]
				, "searchValue" : $("#searchValue").val()
				, "searchCategory1" : $("#searchCategory1").selectedValues()[0]
				, "searchCategory2" : $("#searchCategory2").selectedValues()[0]
				, "searchCategory3" : $("#searchCategory3").selectedValues()[0]
				, "searchFileTxt" : $("#searchFileTxt").val()
				, "viewCount":viewCount
				, "pageNo":pageNo},
		dataType:"json",
		success:function(data) {
			var html = "";
			if( data.totalCount > 0 ) {
				$("#list").html(html);
				data.list.forEach(function (item) {
					if( item.IS_LAST == 'Y' ) {
						html += "<tr id=\"devDoc_"+item.DOC_NO+"_"+item.VERSION_NO+"\">";	
					} else {
						html += "<tr id=\"devDoc_"+item.DOC_NO+"_"+item.VERSION_NO+"\" class=\"m_version\" style=\"display: none\">";
					}
					html += "	<td>";
					if( item.CHILD_CNT > 0 && item.IS_LAST == 'Y' ) {
						html += "		<img src=\"/resources/images/img_add_doc.png\" style=\"cursor: pointer;\" onclick=\"showChildVersion(this)\"/>";
					} else {
						html += "&nbsp;";
					}
					html += "	</td>";
					html += "	<td>"+nvl(item.MATERIAL_CODE,'&nbsp;')+"</td>";
					html += "	<td>"+nvl(item.SAP_CODE,'&nbsp;')+"</td>";
					html += "	<td><div class=\"ellipsis_txt tgnl\"><a href=\"#\" onClick=\"fn_view('"+item.MATERIAL_IDX+"')\">"+nvl(item.NAME,'&nbsp;')+"</div></td>";
					//html += "	<td>"+nvl(item.PRICE,'&nbsp;')+"</td>";
					html += "	<td>"+nvl(item.UNIT_NAME,'&nbsp;')+"</td>";
					html += "	<td><div class=\"ellipsis_txt tgnl\">";
					if( chkNull(item.CATEGORY_NAME1) ) {
						html += item.CATEGORY_NAME1;
					}
					if( chkNull(item.CATEGORY_NAME2) ) {
						html += " > "+item.CATEGORY_NAME2;
					}
					if( chkNull(item.CATEGORY_NAME3) ) {
						html += " > "+item.CATEGORY_NAME3;
					}
					html += "	</div></td>";
					html += "	<td>";
					html += "		<ul class=\"list_ul2\">";
					html += "			<li class=\""+(item.FILE_CNT10 == 0 ? 's01' : '02')+"\">품</li>";
					html += "			<li class=\""+(item.FILE_CNT20 == 0 ? 's01' : '02')+"\">수</li>";
					html += "			<li class=\""+(item.FILE_CNT30 == 0 ? 's01' : '02')+"\">시</li>";
					html += "			<li class=\""+(item.FILE_CNT40 == 0 ? 's01' : '02')+"\">한</li>";
					html += "			<li class=\""+(item.FILE_CNT50 == 0 ? 's01' : '02')+"\">견</li>";
					html += "		</ul>";
					html += "	</td>";
					html += "	<td>";
					if( item.IS_LAST == 'Y' ) {
						html += "		<li style=\"float:none; display:inline\">";
						html += "			<button class=\"btn_doc\" onclick=\"javascript:fn_goVersionUp('"+item.MATERIAL_IDX+"')\"><img src=\"/resources/images/icon_doc03.png\">개정</button>";
						html += "			<button class=\"btn_doc\" onclick=\"javascript:fn_goViewHistory('"+item.MATERIAL_IDX+"', '"+item.DOC_NO+"')\"><img src=\"/resources/images/icon_doc05.png\">이력</button>";
						html += "			<button class=\"btn_doc\" onClick=\"javascript:fn_goDelete('"+item.MATERIAL_IDX+"', '"+item.DOC_NO+"')\"><img src=\"/resources/images/icon_doc04.png\">삭제</button>";
						html += "		</li>";
					}
					html += "	</td>";
					html += "</tr>"					
				});				
			} else {
				$("#list").html(html);
				html += "<tr><td align='center' colspan='8'>데이터가 없습니다.</td></tr>";
			}			
			$("#list").html(html);
			$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
			$('#pageNo').val(data.navi.pageNo);			
		},
		error:function(request, status, errorThrown){
			var html = "";
			$("#list").html(html);
			html += "<tr><td align='center' colspan='8'>오류가 발생하였습니다.</td></tr>";
			$("#list").html(html);
			$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
			$('#pageNo').val(data.navi.pageNo);
		}			
	});	
}

function fn_goSearch(){
	fn_loadList(1);
}

function fn_view(idx) {
	var URL = "../material/selectMaterialDataAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"idx" : idx
		},
		dataType:"json",
		async:false,
		success:function(data) {
			$("#nameTxt").html(data.data.NAME);			
			$("#matCodeTxt").html(data.data.MATERIAL_CODE);
			$("#sapCodeTxt").html(data.data.SAP_CODE);
			$("#plantTxt").html(data.data.PLANT);
			$("#priceTxt").html(data.data.PRICE);
			$("#unitTxt").html(data.data.UNIT_NAME);
			$("#keepConditionTxt").html(data.data.KEEP_CONDITION);
			$("#sizeTxt").html(nvl(data.data.WIDTH,"0")+" / "+nvl(data.data.LENGTH,"0")+" / "+nvl(data.data.HEIGHT,"0"));
			$("#weightTxt").html(data.data.TOTAL_WEIGHT);
			$("#standardTxt").html(data.data.STANDARD);
			$("#originTxt").html(data.data.ORIGIN);
			$("#expireDateTxt").html(data.data.EXPIRATION_DATE);
			var typeName = "";
			if( chkNull(data.data.MATERIAL_TYPE_NAME1) ) {
				typeName += data.data.MATERIAL_TYPE_NAME1;
			}
			if( chkNull(data.data.MATERIAL_TYPE_NAME2) ) {
				typeName += " > "+data.data.MATERIAL_TYPE_NAME2;
			}
			if( chkNull(data.data.MATERIAL_TYPE_NAME3) ) {
				typeName += " > "+data.data.MATERIAL_TYPE_NAME3;
			}
			$("#typeTxt").html(typeName);
			var fileTypeTxt = "";
			data.fileType.forEach(function (item, index) {
				if( index == 0 ) {
					fileTypeTxt += item.FILE_TEXT
				} else {
					fileTypeTxt += ", "+item.FILE_TEXT
				}
			});
			$("#fileTypeTxt").html(fileTypeTxt);
			$("#fileDataList").html("");
			data.fileList.forEach(function (item) {
				var childTag = '<li>&nbsp;<a href="javascript:downloadFile(\''+item.FILE_IDX+'\')">'+item.ORG_FILE_NAME+'</a></li>'
				$("#fileDataList").append(childTag);
			});
			
			openDialog('open3');
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}			
	});
}

function showChildVersion(imgElement){
	var docNo = $(imgElement).parent().parent().attr('id').split('_')[1];
	var elementImg = $(imgElement).attr('src').split('/')[$(imgElement).attr('src').split('/').length-1];
	
	var addImg = 'img_add_doc.png';
	
	if(elementImg == addImg){
		$(imgElement).attr('src', $(imgElement).attr('src').replace('_add_', '_m_')); 
		$('tr[id*=devDoc_'+docNo+']').show();
	} else {
		$(imgElement).attr('src', $(imgElement).attr('src').replace('_m_', '_add_'));
		$('tr[id*=devDoc_'+docNo+']').toArray().forEach(function(v, i){
			if(i != 0){
				$(v).hide();
			}
		})
	}
}

function fn_goViewHistory(idx, docNo) {
	var URL = "../material/selectHistoryAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"idx" : idx
			, "docNo" : docNo
		},
		dataType:"json",
		async:false,
		success:function(data) {
			var html = "";
			data.forEach(function (item) {
				html += "<li>";
				html += item.NAME+"("+item.SAP_CODE+")이(가)";
				if( item.HISTORY_TYPE == 'I' ) {
					html += " 생성되었습니다.(버젼 : "+item.VERSION_NO+")";
				} else if( item.HISTORY_TYPE == 'V' ) {
					html += " 개정되었습니다.(버젼 : "+item.VERSION_NO+")";
				} else if( item.HISTORY_TYPE == 'D' ) {
					html += " 삭제되었습니다.";
				} 
				html += "<br/><span>"+item.USER_NAME+"</span>&nbsp;&nbsp;<span class=\"date\">"+item.REG_DATE+"</span>";
				html += "</li>"; 
			});
			$("#historyDiv").html(html);
			openDialog('dialog_history');
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}
	});
}

function fn_insert() {
	$("#name").val("");
	$("#sapCode").val("");
	$("company").removeOption(/./);
	//loadCompany('company');
	$("company").selectOptions("");
	$("plant").removeOption(/./);
	$("plant").selectOptions("");
	$("#price").val("");
	fn_loadUnit();
	$("#unit").selectOptions("");
	//$("#selectTxtFull").html("");
	$("#selectTxtFull").val("");
	$("#fileData").html("");
	$("#create").show();
	$("#update").hide();
	
	location.href = '/material/insert';
}

function fn_goVersionUp(idx) {
	console.log(idx);
	location.href = '/material/versionUp?idx='+idx;
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
				$("#unit").addOption(value.unitCode, value.unitName, false);
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
		//console.log(selectedArr.reverse());
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
	
	var childTag = '<li><a href="#none" onclick="removeTempFile(this, \''+randomId+'\')"><img src="/resources/images/icon_del_file.png"></a><span>'+fileTypeText+'</span>&nbsp;'+fileName+'</li>'
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
		var childTag = '<li><a href="#none" onclick="removeFile(this, \''+tempId+'\')"><img src="/resources/images/icon_del_file.png"></a><span>'+object.fileTypeText+'</span>&nbsp;'+attatchFileArr[idx].name+'</li>'
		//$("#attatch_file_"+object.fileType).append(childTag);
		$("#fileData").append(childTag);
	});
	
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

//입력확인
function goInsert(){
	if( !chkNull($("#name").val()) || $("#name").val() == "[임시]" ) {
		alert("원료명을 입력하여 주세요.");
		$("#name").focus();
		return;
	} else if( !chkNull($("#sapCode").val()) ) {
		alert("SAP 코드를 입력하여 주세요.");
		$("#sapCode").focus();
		return;
	} /*else if( $("#company").selectedValues()[0] == '' ) {
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
	} else {
		
		var URL = "../material/selectMaterialDataCountAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"sapCode":$("#sapCode").val()
				, "company": $("#company").selectedValues()[0]
				, "plant": $("#plant").selectedValues()[0]
			},
			dataType:"json",
			success:function(result) {
				if( result.COUNT > 0 ) {
					alert("이미 존재하는 코드입니다.");
				    return;
				} else {
					URL = "../material/insertMaterialAjax";
					var formData = new FormData();
					formData.append("name",$("#name").val());
					formData.append("sapCode",$("#sapCode").val());
					formData.append("company",$("#company").selectedValues()[0]);
					formData.append("plant",$("#plant").selectedValues()[0]);
					formData.append("price",$("#price").val());
					formData.append("unit",$("#unit").selectedValues()[0]);
					formData.append("materialType",selectedArr.reverse());
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
					
					//selectedArr
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
								alert("정상적으로 생성되었습니다.");
								fn_loadList(1);
							} else {
								alert("오류가 발생하였습니다.\n"+result.MESSAGE);
							}
						},
						error:function(request, status, errorThrown){
							alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
						}			
					});
				}
			},
			error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	}
}

function fn_goDelete(idx, docNo) {
	var URL = "../material/deleteMaterialAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			idx : idx
			, docNo : docNo
		},
		dataType:"json",
		async:false,
		success:function(result) {
			if( result.RESULT == 'S' ) {
				alert("삭제되었습니다.");
				fn_loadList(1);
			} else {
				alert("오류가 발생하였습니다.\n"+result.MESSAGE);
			}
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}			
	});
}


function downloadFile(idx){
	location.href = '/file/fileDownload?idx='+idx;
}

function fn_searchClear() {
	$("#searchType").selectOptions("");
	$("#searchType_label").html("선택");
	$("#searchValue").val("");
	$("#searchCategory1").selectOptions("");
	$("#searchCategory1_label").html("선택");
	$("#searchCategory2").removeOption(/./);
	$("#searchCategory2_div").hide("");
	$("#searchCategory2_label").html("선택");
	$("#searchCategory3_div").hide("");
	$("#searchCategory3_label").html("선택");
	$("#searchFileTxt").val("");
	$("#viewCount").selectOptions("");
	$("#viewCount_label").html("선택");
}

function paging(pageNo) {
	fn_loadList(pageNo);
}
</script>
<input type="hidden" name="pageNo" id="pageNo" value="">
<div class="wrap_in" id="fixNextTag">
	<span class="path">원료관리&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Material management</span>
			<span class="title">원료관리</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button type="button" class="btn_circle_red" onClick="javascript:fn_insert();">&nbsp;</button>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="tab02">
			</div>
			<div class="search_box" >
				<ul style="border-top:none">
					<li>
						<dt>키워드</dt>
						<dd >
							<!-- 초기값은 보통으로 -->
							<div class="selectbox" style="width:100px;">  
								<label for="searchType" id="searchType_label">선택</label> 
								<select name="searchType" id="searchType">
									<option value="">선택</option>
									<option value="searchName">원료명</option>
									<option value="searchMatCode">원료코드</option>
									<option value="searchSapCode">ERP코드</option>
								</select>
							</div>
							<input type="text" name="searchValue" id="searchValue" value="" style="width:180px; margin-left:5px;">
						</dd>
					</li>
					<li>
						<dt>원료구분</dt>
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
					<li>
						<dt>첨부파일</dt>
						<dd >
							<input type="text" name="searchFileTxt" id="searchFileTxt" value="" style="width:180px;">
						</dd>
					</li>
					<li>
						<dt>표시수</dt>
						<dd >
							<div class="selectbox" style="width:100px;">  
								<label for="viewCount" id="viewCount_label">선택</label> 
								<select name="viewCount" id="viewCount">		
									<option value="">선택</option>													
									<option value="10">10</option>
									<option value="20">20</option>
									<option value="50">50</option>
									<option value="100">100</option>
								</select>
							</div>
						</dd>
					</li>
				</ul>
				<div class="fr pt5 pb10">
					<button type="button" class="btn_con_search" onClick="javascript:fn_goSearch();"><img src="/resources/images/btn_icon_search.png" style="vertical-align:middle;"/> 검색</button>
					<button type="button" class="btn_con_search" onClick="javascript:fn_searchClear();"><img src="/resources/images/btn_icon_refresh.png" style="vertical-align:middle;"/> 검색 초기화</button>					
				</div>
			</div>
			<div class="main_tbl">
				<table class="tbl01">
					<colgroup id="list_colgroup">
						<col width="45px">						
						<col width="9%">
						<col width="9%">
						<col width="15%">
						<!--col width="8%"-->
						<col width="8%">
						<col width="20%">
						<col width="20%">
						<col />
					</colgroup>
					<thead id="list_header">
						<tr>
							<th>&nbsp;</th>
							<th>원료코드</th>
							<th>ERP코드</th>
							<th>원료명</th>
							<!--th>단가</th-->
							<th>단위</th>
							<th>원료구분</th>
							<th>첨부문서</th>
							<th>설정</th>
						<tr>
					</thead>
					<tbody id="list">						
					</tbody>
				</table>
				<div class="page_navi  mt10">
				</div>
			</div>
			<div class="btn_box_con"> 
				<button class="btn_admin_red" onclick="javascript:fn_insert();">원료 생성</button>
			</div>
	 		<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
	</section>
</div>

<!-- 자재 생성레이어 start-->
<div class="white_content" id="open">
	<div class="modal" style="	width: 700px;margin-left:-350px;height: 560px;margin-top:-300px;">
		<h5 style="position:relative">
			<span class="title">원료 생성</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('open')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li class="pt10">
					<dt>원료명</dt>
					<dd>
						<input type="text" value="" class="req" style="width:302px;" name="name" id="name" placeholder="원료명을 입력하세요."/> 
					</dd>
				</li>
				<li>
					<dt>SAP 코드</dt>
					<dd>
						<input type="text"  style="width:200px; float: left" class="req" name="sapCode" id="sapCode" placeholder="코드를 조회/생성 하세요." readonly/>
						<button class="btn_small_search ml5" onclick="" style="float: left">조회</button>
						<button class="btn_small_search ml5" onclick="" style="float: left">생성</button>
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
						<input type="text" class="req" style="width:149px;" name="price" id="price" placeholder="숫자만 입력하세요." onkeyup="checkDecNum(this)">
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
						<input class="" id="selectTxtFull" name="selectTxtFull" type="text" style="width: 250px; float: left" readonly>
						<button class="btn_small_search ml5" onclick="openDialog('open2')" style="float: left">조회</button>
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
		<div class="btn_box_con">
			<button class="btn_admin_red" id="create" onclick="javascript:goInsert();">원료 생성</button> 
			<button class="btn_admin_red" id="update" onclick="javascript:goUpdate();" style="display:none">원료 수정</button>
			<button class="btn_admin_gray" onclick="closeDialog('open')"> 취소</button>
		</div>
	</div>
</div>
<!-- 자재 생성레이어 close-->

<!-- 자재 조회레이어 start-->
<div class="white_content" id="open3">
	<div class="modal" style="	width: 700px;margin-left:-350px;height: 810px;margin-top:-400px;">
		<h5 style="position:relative">
			<span class="title">원료 상세 정보</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('open3')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li class="">
					<dt>원료명</dt>
					<dd>
						 <div id="nameTxt"></div>
					</dd>
				</li>
				<li>
					<dt>원료 코드</dt>
					<dd>
						<div id="matCodeTxt"></div>
					</dd>
				</li>
				<li>
					<dt>SAP 코드</dt>
					<dd>
						<div id="sapCodeTxt"></div>
					</dd>
				</li>
				<li>
					<dt>단가</dt>
					<dd>
						<div id="priceTxt"></div>
					</dd>
				</li>
				<li>
					<dt>단위</dt>
					<dd>
						<div id="unitTxt"></div>
					</dd>
				</li>
				<li>
					<dt>보관기준</dt>
					<dd>
						<div id="keepConditionTxt"></div>
					</dd>
				</li>
				<li>
					<dt>사이즈</dt>
					<dd>
						<div id="sizeTxt"></div>
					</dd>
				</li>
				<li>
					<dt>중량</dt>
					<dd>
						<div id="weightTxt"></div>
					</dd>
				</li>
				<li>
					<dt>규격</dt>
					<dd>
						<div id="standardTxt"></div>
					</dd>
				</li>
				<li>
					<dt>원산지</dt>
					<dd>
						<div id="originTxt"></div>
					</dd>
				</li>
				<li>
					<dt>유통기한</dt>
					<dd>
						<div id="expireDateTxt"></div>
					</dd>
				</li>
				<li>
					<dt>원료구분상세</dt>
					<dd>
						<div id="typeTxt"></div>
					</dd>
				</li>
				<li>
					<dt>첨부파일 유형</dt>
					<dd>
						<div id="fileTypeTxt"></div>
					</dd>
				</li>
				<li>
					<div class="add_file2" style="width:97.5%">
						<span class="" >
							<label>첨부파일</label>
						</span>						
					</div>
					<div class="file_box_pop" style=" height:120px; width:97.5%; border-top-left-radius:0px;border-top-right-radius:0px; border-top:1px solid #ddd;box-sizing:border-box;">
						<ul id="fileDataList">									
						</ul>
					</div>
				</li>
			</ul>
		</div>
		<div class="btn_box_con">
			<button class="btn_admin_gray" onclick="closeDialog('open3')"> 닫기</button>
		</div>
	</div>
</div>
<!-- 자재 생성레이어 close-->

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
<!-- 자재 생성레이어 close-->

<!-- 첨부파일 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_attatch">
	<div class="modal" style="margin-left: -355px; width: 750px; height: 500px; margin-top: -250px">
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
							<button class="btn_small02 ml5" onclick="addFile(this, '10')">품목제조보고서</button>
							<button class="btn_small02 ml5" onclick="addFile(this, '20')">수입신고필증</button>
							<button class="btn_small02 ml5" onclick="addFile(this, '30')">시험성적서</button>
							<button class="btn_small02 ml5" onclick="addFile(this, '40')">한글표시사항</button>
							<button class="btn_small02 ml5" onclick="addFile(this, '50')">기타</button>
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
<!-- 이력내역 레이어 start-->
<div class="white_content" id="dialog_history">
	<div class="modal"
		style="margin-left: -300px; width: 500px; height: 420px; margin-top: -210px">
		<h5 style="position: relative">
			<span class="title">문서이력</span>
			<div class="top_btn_box">
				<ul>
					<li><button class="btn_madal_close" onClick="closeDialog('dialog_history')"></button></li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul id="historyDiv" class="pop_notice_con history_option">
			</ul>
		</div>
		<div class="btn_box_con4" style="padding: 15px 0 20px 0">
			<button class="btn_admin_red" onclick="closeDialog('dialog_history')">확인</button>
		</div>
	</div>
</div>
<!-- 이력내역 레이어 생성레이어 close-->