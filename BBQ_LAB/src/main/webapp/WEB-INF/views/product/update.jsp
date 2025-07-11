<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>개선완료보고서 생성</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 200px; min-height:200px;}
li {
	list-style:none;
}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">

<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../resources/js/jstree.js"></script>
<script type="text/javascript" src="../resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript" src="../resources/js/user/userSearchClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
var selectedArr = new Array();
	$(document).ready(function(){
		CreateEditor("contents");		
		fn_loadCategory();
		
		if( '${productData.data.PRODUCT_TYPE3}' != '' ) {
			selectedArr.push('${productData.data.PRODUCT_TYPE3}');
		}
		if( '${productData.data.PRODUCT_TYPE2}' != '' ) {
			selectedArr.push('${productData.data.PRODUCT_TYPE2}');
		}
		if( '${productData.data.PRODUCT_TYPE1}' != '' ) {
			selectedArr.push('${productData.data.PRODUCT_TYPE1}');
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
	            { userId: "${user.USER_ID}", userName: "${user.USER_NAME}" }<c:if test="${!status.last}">,</c:if>
	        </c:forEach>
	    ];

	    userSearchClass.renderTokenList(sharedUsers);
	});
	
	let _brandFullList = []; // 전체 브랜드 저장용 전역변수
	
	function fn_closeErpMatRayer(){
		$('#searchErpMatValue').val('')
		$('#erpMatLayerBody').empty();
		$('#erpMatLayerBody').append('<tr><td colspan="9">상품코드 혹은 상품명을 검색해주세요</td></tr>');
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
		//$("#productName").val(NAME);
		$("#productSapCode").val(SAP_CODE);
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
					//console.log($.jstree.reference('#jsTree').get_node(value).text);
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
	
	/* 파일첨부 관련 함수 START */
	var attatchFileArr = [];
	var attatchFileTypeArr = [];
	var attatchTempFileArr = [];
	var attatchTempFileTypeArr = [];
	var deletedFileArr = [];
	var deletedFilePathArr = [];
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
			var childTag = '<li><a href="#none" onclick="removeFile(this, \''+tempId+'\')"><img src="/resources/images/icon_del_file.png"></a>&nbsp;'+attatchFileArr[idx].name+'</li>'
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
	
	function downloadFile(idx){
		location.href = '/common/fileDownload?idx='+idx;
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
		$('#matLayerBody').append('<tr><td colspan="10">상품코드 혹은 상품명을 검색해주세요</td></tr>');
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
	
	function selectNewCode() {
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
	
	//입력확인
	function fn_updateTmp(){
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			$("#title").focus();
			return;
		} else {
			$('#lab_loading').show();
			var contents = editor.getData();
			var formData = new FormData();
			formData.append("idx",$("#idx").val());
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
			
			const version = '${menuData.data.VERSION_NO}';
			
			// (버전 > 1일 때만 전송)
			if (version !== '1') {
				// 개선 목적
				var itemImproveArr = [];
				var itemExistArr = [];
				var itemNoteArr = [];
				// 개선사항 (항상 포함 — 공통 항목)
				var improveArr = [];
				
				$('tr[id^=improve_pur_tr]').toArray().forEach(function(purposeRow){
					var rowId = $(purposeRow).attr('id');
					itemImproveArr.push($('#' + rowId + ' input[name=itemImprove]').val().trim());
					itemExistArr.push($('#' + rowId + ' input[name=itemExist]').val().trim());
					itemNoteArr.push($('#' + rowId + ' input[name=itemNote]').val().trim());
				});
				formData.append("itemImproveArr", JSON.stringify(itemImproveArr));
				formData.append("itemExistArr", JSON.stringify(itemExistArr));	
				formData.append("itemNoteArr", JSON.stringify(itemNoteArr));	
				
				$('tr[id^=improve_tr]').toArray().forEach(function(purposeRow){
					var rowId = $(purposeRow).attr('id');
					improveArr.push($('#' + rowId + ' input[name=improve]').val().trim());
				});
				formData.append("improveArr", JSON.stringify(improveArr));
			} else {
				// 버전이 1이면 빈 배열로 초기화
				formData.append("itemImproveArr", JSON.stringify([]));
				formData.append("itemExistArr", JSON.stringify([]));	
				formData.append("itemNoteArr", JSON.stringify([]));	
				formData.append("improveArr", JSON.stringify([]));
			}
			
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
			
			deletedFileArr.forEach(val => formData.append("deleteFileArr", val));
			deletedFilePathArr.forEach(val => formData.append("deleteFilePathArr", val));
			
			URL = "../product/updateTmpProductAjax";
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
						fn_list();
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
	
	function validatePurposeAndFeature() {
		const versionNo = '${productData.data.VERSION_NO}';
		
		if (versionNo === '1') {
			// ✅ 개발 목적 유효성 체크
			var isValidPurpose = false;
			$('tr[id^=purpose_tr]').each(function () {
				var val = $(this).find('input[name=purpose]').val();
				if ($.trim(val) !== '') isValidPurpose = true;
			});
			if (!isValidPurpose) {
				alert("개발 목적을 하나 이상 입력해 주세요.");
				return false;
			}

			// ✅ 메뉴 특징 유효성 체크
			var isValidFeature = false;
			$('tr[id^=feature_tr]').each(function () {
				var val = $(this).find('input[name=feature]').val();
				if ($.trim(val) !== '') isValidFeature = true;
			});
			if (!isValidFeature) {
				alert("제품 특징을 하나 이상 입력해 주세요.");
				return false;
			}
		} else {
			// ✅ 개선 목적 유효성 체크 (3개 항목 모두 빈값이 아닌 행이 하나 이상 있어야 함)
			let validImprovePurposeRowCount = 0;
			$('tr[id^=improve_pur_tr]').each(function () {
				const val1 = $(this).find('input[name=itemImprove]').val();
				const val2 = $(this).find('input[name=itemExist]').val();
				const val3 = $(this).find('input[name=itemNote]').val();

				if (
					$.trim(val1) !== '' &&
					$.trim(val2) !== '' &&
					$.trim(val3) !== ''
				) {
					validImprovePurposeRowCount++;
				}
			});
			if (validImprovePurposeRowCount === 0) {
				alert("개선 목적을 하나 이상, 빈 항목 없이 입력해 주세요.");
				return false;
			}

			// ✅ 개선 사항 유효성 체크
			var isValidFeature = false;
			$('tr[id^=improve_tr]').each(function () {
				var val = $(this).find('input[name=improve]').val();
				if ($.trim(val) !== '') isValidFeature = true;
			});
			if (!isValidFeature) {
				alert("개선 사항을 하나 이상 입력해 주세요.");
				return false;
			}
		}

		return true;
	}
	
	//입력확인
	function fn_update(){
		var contents = editor.getData();
		if( !chkNull($("#title").val()) ) {
			alert("제목을 입력해 주세요.");
			tabChange('tab1');
			$("#title").focus();
			return;
		} else if( !chkNull($("#productName").val()) ) {
			alert("제품명을 입력해 주세요.");
			tabChange('tab1');
			$("#productName").focus();
			return;
		} else if( !chkNull($("#productCode").val()) ) {
			alert("제품 코드를 입력해 주세요.");
			tabChange('tab2');
			$("#productCode").focus();
			return;
		} else if(!validatePurposeAndFeature()){
			tabChange('tab1');
			return;
		} else if(!$.trim($('#brandCodeValues_1').val())){
			alert("브랜드를 선택해 주세요.");
			tabChange('tab1');
			return;
		} else if( !chkNull($("#selectTxtFull").val()) ) {
			alert("제품유형을 선택해 주세요.");
			tabChange('tab2');
			return;
		} else if( selectedArr.length == 0 ) {
			alert("제품유형을 선택하여 주세요.");
			tabChange('tab2');
			return;
		} else if( $("#temp_attatch_file").children("li").length == 0 && attatchFileArr.length == 0 ) {
			alert("첨부파일을 등록해주세요.");		
			tabChange('tab1');
			return;
		} else {
			if( $('input[name=newMat]:checked').val() == 'Y' ) {
				var matCount = 0;
				var validMat = true;
				$('tr[id^=matRow]').toArray().forEach(function(contRow){
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
					alert('신규원료를 입력해주세요.');
					return;
				}
			}			
			//기존 데이터 확인
			var formData = new FormData();
			var contents = editor.getData();
			var formData = new FormData();
			formData.append("idx",$("#idx").val());
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
			
			const version = '${menuData.data.VERSION_NO}';
			
			// (버전 > 1일 때만 전송)
			if (version !== '1') {
				// 개선 목적
				var itemImproveArr = [];
				var itemExistArr = [];
				var itemNoteArr = [];
				// 개선사항 (항상 포함 — 공통 항목)
				var improveArr = [];
				
				$('tr[id^=improve_pur_tr]').toArray().forEach(function(purposeRow){
					var rowId = $(purposeRow).attr('id');
					itemImproveArr.push($('#' + rowId + ' input[name=itemImprove]').val().trim());
					itemExistArr.push($('#' + rowId + ' input[name=itemExist]').val().trim());
					itemNoteArr.push($('#' + rowId + ' input[name=itemNote]').val().trim());
				});
				formData.append("itemImproveArr", JSON.stringify(itemImproveArr));
				formData.append("itemExistArr", JSON.stringify(itemExistArr));	
				formData.append("itemNoteArr", JSON.stringify(itemNoteArr));	
				
				$('tr[id^=improve_tr]').toArray().forEach(function(purposeRow){
					var rowId = $(purposeRow).attr('id');
					improveArr.push($('#' + rowId + ' input[name=improve]').val().trim());
				});
				formData.append("improveArr", JSON.stringify(improveArr));
			} else {
				// 버전이 1이면 빈 배열로 초기화
				formData.append("itemImproveArr", JSON.stringify([]));
				formData.append("itemExistArr", JSON.stringify([]));	
				formData.append("itemNoteArr", JSON.stringify([]));	
				formData.append("improveArr", JSON.stringify([]));
			}
			
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
			formData.append("currentIdx",$("#idx").val());
			formData.append("currentVersionNo",$("#currentVersionNo").val());
			formData.append("currentStatus",$("#currentStatus").val());
			formData.append("docNo",$("#docNo").val());
			formData.append("weight",$("#weight").val());
			formData.append("standard",$("#standard").val());
			formData.append("keepCondition",$("#keepCondition").val());
			formData.append("expireDate",$("#expireDate").val());
			formData.append("contents",contents);
			formData.append("newMat",$('input[name=newMat]:checked').val());
			formData.append("productType",selectedArr);
			
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
			
			deletedFileArr.forEach(val => formData.append("deleteFileArr", val));
			deletedFilePathArr.forEach(val => formData.append("deleteFilePathArr", val));
			
			$('#lab_loading').show();
			var URL = "../product/updateProductAjax";
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
							apprFormData.append("docIdx", '${productData.data.PRODUCT_IDX}' );
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
										fn_list();
									} else {
										alert("결재선 상신 오류가 발생하였습니다."+data.MESSAGE);
										$('#lab_loading').hide();
										fn_list();
										return;
									}
								},
								error:function(request, status, errorThrown){
									alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
									$('#lab_loading').hide();
									fn_list();
								}			
							});
						} else {
							alert($("#productName").val()+"("+$("#productCode").val()+")"+"가 정상적으로 생성되었습니다.");
							$('#lab_loading').hide();
							fn_list();
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

	function fn_list() {
		location.href = '/product/list';
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
	
	function fn_removeTempFile(el, fileIdx) {
	    const $li = $(el).closest('li');

	    // li에 data-* 로 박아둔 파일명 및 경로 추출
	    const fileName = $li.data('name');
	    const filePath = $li.data('path');
	    
	    // 배열에 저장
	    deletedFileArr.push(fileName);
	    deletedFilePathArr.push(filePath);

	    // 화면에서 삭제
	    $li.remove();
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
	    const tokenBox = document.getElementById('brandTokenBox_' + idx);
	    const hiddenInput = document.getElementById('brandCodeValues_' + idx);

	    const codes = [];
	    tokenBox.querySelectorAll('.brand-token').forEach(token => {
	        const code = token.dataset.code;
	        if (code) codes.push(code);
	    });

	    hiddenInput.value = codes.join(',');
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
	
	function fn_previewDataBinding(popup) {
	    const $doc = popup.document;

	    // 기본 항목
	    $doc.getElementById("prev_title").innerText = document.getElementById("title").value;
	    $doc.getElementById("prev_productName").innerText = document.getElementById("productName").value;
	    
	 	// 공동 참여자 바인딩
	    $doc.getElementById("prev_sharedUser").innerText = document.getElementById("sharedUserNames").value.replaceAll(',',', ');
	    
	    var version = '${productData.data.VERSION_NO}';
	    if (version === '1') {
	    	togglePreviewRows('1', $doc);  // ← tr 표시 제어
	    	console.log("진입");
	    	// 개발 목적
	    	let purposeHTML = "";
	    	document.querySelectorAll('tr[id^=purpose_tr]').forEach(function (row) {
	    		const val = row.querySelector('input[name=purpose]')?.value || "";
	    		if (val.trim()) purposeHTML += val + "<br/>";
	    	});
	    	$doc.getElementById("prev_purpose").innerHTML = purposeHTML;

	    	// 제품 특징
	    	let featureHTML = "";
	    	document.querySelectorAll('tr[id^=feature_tr]').forEach(function (row) {
	    		const val = row.querySelector('input[name=feature]')?.value || "";
	    		if (val.trim()) featureHTML += val + "<br/>";
	    	});
	    	$doc.getElementById("prev_feature").innerHTML = featureHTML;
	    	console.log("종료");
	    } else {
	    	togglePreviewRows('2', $doc);  // ← tr 표시 제어

	    	// 개선 목적
	    	let improvePurHTML = "";
	    	const improvePurRows = document.querySelectorAll('tr[id^=improve_pur_tr]');
	    	improvePurRows.forEach(function (row) {
	    		const improveVal = row.querySelector('input[name=itemImprove]')?.value.trim();
	    		const existVal = row.querySelector('input[name=itemExist]')?.value.trim();
	    		const noteVal = row.querySelector('input[name=itemNote]')?.value.trim();

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

	    	// 개선 항목
	    	let improveHTML = "";
	    	document.querySelectorAll('tr[id^=improve_tr]').forEach(function (row) {
	    		const val = row.querySelector('input[name=improve]')?.value || "";
	    		if (val.trim()) improveHTML += val + "<br/>";
	    	});
	    	$doc.getElementById("prev_improve").innerHTML = improveHTML;
	    }

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

	    // 도입 예정일, 제품코드, SAP 코드
	    $doc.getElementById("prev_scheduleDate").innerText = document.getElementById("scheduleDate").value;
	    $doc.getElementById("prev_productCode").innerText = document.getElementById("productCode").value;
	    $doc.getElementById("prev_sapCode").innerText = document.getElementById("productSapCode").value;

	    // 버전, 중량, 규격, 보관조건, 소비기한
	    $doc.getElementById("prev_version").innerText = version;
	    $doc.getElementById("prev_weight").innerText = document.getElementById("weight").value;
	    $doc.getElementById("prev_standard").innerText = document.getElementById("standard").value;
	    $doc.getElementById("prev_keepCondition").innerText = document.getElementById("keepCondition").value;
	    $doc.getElementById("prev_expireDate").innerText = document.getElementById("expireDate").value;

	    // 제품유형
	    $doc.getElementById("prev_productType").innerText = document.getElementById("selectTxtFull").value;

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
		var url = "/preview/productUpdatePopup";

		// 팝업 창 열기
		var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes");

		// 팝업이 완전히 열린 뒤에 데이터 전달
		popup.onload = function () {
			// 여기서 fn_openPreview() 호출해서 팝업 DOM에 값 세팅
			fn_previewDataBinding(popup);
		};
	}
	
	function togglePreviewRows(version, $doc) {
		const isVersion1 = (version === '1');

		$doc.querySelectorAll(".tr_prev_version1").forEach(row => {
			row.style.display = isVersion1 ? "table-row" : "none";
		});
		$doc.querySelectorAll(".tr_prev_version2").forEach(row => {
			row.style.display = isVersion1 ? "none" : "table-row";
		});
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
			<span class="title_s">Product Update Doc</span><span class="title">제품개발완료보고서</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<button class="btn_circle_save" onclick="fn_update()">&nbsp;</button>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="tab02">
				<ul style="display: flex; justify-content: space-between;">
					<!-- 선택됬을경우는 탭 클래스에 select를 넣어주세요 -->
					<!-- 내 제품설계서 같은경우는 change select 이렇게 change 그대로 두고 한칸 띄고 select 삽입 -->
					<div>
						<a href="#" onClick="tabChange('tab1')"><li class="select"
							id="tab1_li">기안내용</li></a> <a href="#" onClick="tabChange('tab2')"><li
							class="" id="tab2_li">완료보고서상세정보</li></a>
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
									<input type="text" name="title" id="title" style="width: 99%;" value="${productData.data.TITLE}"/>
									<input type="hidden" name="idx" id="idx" value="${productData.data.PRODUCT_IDX}"/>
									<input type="hidden" name="docNo" id="docNo" value="${productData.data.DOC_NO}"/>
									<input type="hidden" name="currentVersionNo" id="currentVersionNo" value="${productData.data.VERSION_NO}"/>
									<input type="hidden" name="currentStatus" id="currentStatus" value="${productData.data.STATUS}"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="title2"  style="width: 80%;"><span class="txt">제품명 <span class="mandatory">*</span></span></div>
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
									<input type="text"  style="width:99%; float: left" name="productName" id="productName" value="${productData.data.NAME}"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div style="${productData.data.VERSION_NO == 1 ? '' : 'display:none'}">
					<div class="title2"  style="width: 80%;"><span class="txt">개발 목적 <span class="mandatory">*</span></span></div>
					<div class="title2" style="width: 20%; display: inline-block;">
						<button class="btn_con_search" onClick="fn_addCol('purpose')">
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
								<c:set var="count" value="0" />
								<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
									<c:if test="${addInfoList.INFO_TYPE == 'PUR' }">
									<c:set var="count" value="${count + 1}" />
									<tr id="purpose_tr_${status.count}">
										<td>
											<input type="checkbox" id="purpose_${status.count}"><label for="purpose_${status.count}"><span></span></label>
										</td>
										<td>
											<input type="text"  style="width:99%; float: left" name="purpose" placeholder="가." value="${addInfoList.INFO_TEXT}"/>
										</td>
									</tr>
									</c:if>
								</c:forEach>
								<c:if test="${count == 0 }">
									<tr id="purpose_tr_1">
										<td>
											<input type="checkbox" id="purpose_1"><label for="purpose_1"><span></span></label>
										</td>
										<td>
											<input type="text"  style="width:99%; float: left" name="purpose"/>
										</td>
									</tr>
								</c:if>
							</tbody>
							<tbody id="purpose_tbody_temp" name="purpose_tbody_temp" style="display:none">
								<tr id="purpose_tmp_tr_1"> 
									<td>
										<input type="checkbox" id="purpose_1"><label for="purpose_1"><span></span></label>
									</td>
									<td>
										<input type="text"  style="width:99%; float: left" name="purpose"/>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				
				<div style="${productData.data.VERSION_NO == 1 ? '' : 'display:none'}">
					<div class="title2"  style="width: 80%;"><span class="txt">제품 특징 <span class="mandatory">*</span></span></div>
					<div class="title2" style="width: 20%; display: inline-block;">
						<button class="btn_con_search" onClick="fn_addCol('feature')">
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
								<c:set var="count" value="0" />
								<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
									<c:if test="${addInfoList.INFO_TYPE == 'FEA' }">
									<c:set var="count" value="${count + 1}" />
									<tr id="feature_tr_${status.count}">
										<td>
											<input type="checkbox" id="feature_${status.count}"><label for="feature_${status.count}"><span></span></label>
										</td>
										<td>
											<input type="text"  style="width:99%; float: left" name="feature" placeholder="가." value="${addInfoList.INFO_TEXT}"/>
										</td>
									</tr>
									</c:if>
								</c:forEach>
								<c:if test="${count == 0 }">
									<tr id="feature_tr_1">
										<td>
											<input type="checkbox" id="feature_1"><label for="feature_1"><span></span></label>
										</td>
										<td>
											<input type="text"  style="width:99%; float: left" name="feature"/>
										</td>
									</tr>
								</c:if>
							</tbody>
							<tbody id="feature_tbody_temp" name="feature_tbody_temp" style="display:none">
								<tr id="feature_tmp_tr_1"> 
									<td>
										<input type="checkbox" id="feature_1"><label for="feature_1"><span></span></label>
									</td>
									<td>
										<input type="text"  style="width:99%; float: left" name="feature"/>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>	
				
				<div style="${productData.data.VERSION_NO == 1 ? 'display:none' : ''}">
					<div class="title2" style="float: left; margin-top: 30px;">
						<span class="txt">개선목적 <span class="mandatory">*</span></span>
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
								<th></th>
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
				
				<div style="${productData.data.VERSION_NO == 1 ? 'display:none' : ''}">
					<div class="title2"  style="width: 80%;"><span class="txt">개선 사항 <span class="mandatory">*</span></span></div>
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
									<input type="text"  style="width:99%; float: left" name="improve"/>
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
								<th></th>
								<th>제품명</th>
								<th>포장규격</th>
								<th>공급처 및 담당자</th>
								<th>보관조건 및 소비기한</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="new_tbody" name="new_tbody">
							<c:forEach items="${newDataList}" var="newDataList" varStatus="status">
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
									<input type="text" name="scheduleDate" id="scheduleDate" style="width: 120px;" value="${productData.data.SCHEDULE_DATE}"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div class="title2 mt20"  style="width:90%;"><span class="txt">파일첨부 <span class="mandatory">*</span></span></div>
				<div class="title2 mt20" style="width:10%; display: inline-block;">
					<button class="btn_con_search" onClick="openDialog('dialog_attatch')">
						<img src="/resources/images/icon_s_file.png" />파일첨부 
					</button>
				</div>
				<div class="con_file" style="">
					<ul>
						<li class="point_img" style="display:flex;">
							<dt>첨부파일</dt><dd>
								<ul id="temp_attatch_file">
									<c:forEach items="${productData.fileList}" var="fileList" varStatus="status">
										<li data-path="${fileList.FILE_PATH}" data-name="${fileList.FILE_NAME}">
											<a href="#none" onclick="fn_removeTempFile(this, '${fileList.FILE_IDX}')">
												<img src="/resources/images/icon_del_file.png">
											</a>&nbsp;
											<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a>
										</li>
									</c:forEach>
								</ul>
								<ul id="attatch_file">								
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
								<th style="border-left: none;">제품코드 <span class="mandatory">*</span></th>
								<td>
									<c:choose>
										<c:when test = "${productData.data.PRODUCT_CODE eq '' || empty productData.data.PRODUCT_CODE }">
											<input type="text"  style="width:200px; float: left" name="productCode" id="productCode" placeholder="코드를 생성 하세요." readonly/>
											<button class="btn_small_search ml5" onclick="selectNewCode()" style="float: left">생성</button>
										</c:when>
										<c:otherwise>
											<input type="hidden"  name="productCode" id="productCode" value="${productData.data.PRODUCT_CODE}"/>
											${productData.data.PRODUCT_CODE}
										</c:otherwise>
									</c:choose>
								</td>
								<th style="border-left: none;">상품코드</th>
								<td>
									<input type="text" style="width:200px; float: left" name="productSapCode" id="productSapCode" value="${productData.data.SAP_CODE}" readonly/>
									<button class="btn_small_search ml5" onclick="openDialog('dialog_erpMaterial')" style="float: left">조회</button>
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
								<th style="border-left: none;">버젼 NO.</th>
								<td colspan="3">
									${productData.data.VERSION_NO}
								</td>
							</tr>
							<tr>
								<th style="border-left: none;">중량</th>
								<td>
									<input type="text"  style="width:200px; float: left" class="" name="weight" id="weight" value="${productData.data.TOTAL_WEIGHT}"/>
								</td>
								<th style="border-left: none;">제품규격</th>
								<td>
									<input type="text"  style="width:350px; float: left" class="" name="standard" id="standard" value="${productData.data.STANDARD}"/>								
								</td>
								
							</tr>
							<tr>
								<th style="border-left: none;">보관방법</th>
								<td>
									<input type="text"  style="width:350px; float: left" class="" name="keepCondition" id="keepCondition" value="${productData.data.KEEP_CONDITION}"/>
								</td>
								<th style="border-left: none;">소비기한</th>
								<td>
									<input type="text"  style="width:350px; float: left" class="" name="expireDate" id="expireDate" value="${productData.data.EXPIRATION_DATE}"/>								
								</td>							
							</tr>
							<tr>
								<th style="border-left: none;">제품유형 <span class="mandatory">*</span></th>
								<td colspan="5">
									<input class="" id="selectTxtFull" name="selectTxtFull" type="text" style="width: 450px; float: left" 
									value="${productData.data.PRODUCT_TYPE_NAME1} ${productData.data.PRODUCT_TYPE_NAME2 eq '' || empty productData.data.PRODUCT_TYPE_NAME2 ? '' : '>' } ${productData.data.PRODUCT_TYPE_NAME2} ${productData.data.PRODUCT_TYPE_NAME3 eq '' || empty productData.data.PRODUCT_TYPE_NAME3 ? '' : '>' } ${productData.data.PRODUCT_TYPE_NAME3}" readonly>
									<button class="btn_small_search ml5" onclick="openDialog('dialog_product')" style="float: left">조회</button>
								</td>
							</tr>
							<tr>
								<th style="border-left: none;">신규원료사용 유무</th>
								<td colspan="5">
									<input type="radio" name="newMat" id="newMat1" value="N" onclick="changeNewMat(event)" ${productData.data.IS_NEW_MATERIAL == 'N' ? 'checked' : ''}>
									<label for="newMat1"><span></span>사용안함</label>
									<input type="radio" name="newMat" id="newMat2" value="Y" onclick="changeNewMat(event)" ${productData.data.IS_NEW_MATERIAL == 'Y' ? 'checked' : ''}>
									<label for="newMat2"><span></span>사용</label>
								</td>
							</tr>
							<tr>
								<th style="border-left: none;">첨부파일 유형</th>
								<td colspan="5">
									<div id="docTypeTxt">
										<c:forEach items="${productData.fileType}" var="fileType" varStatus="status">
											<c:if test="${status.index ne 0}">, </c:if>${fileType.FILE_TEXT}
										</c:forEach>
									</div>
									<select id="docTypeTemp" name="docTypeTemp" multiple style='display:none'>
										<c:forEach items="${productData.fileType}" var="fileType" varStatus="status">
										<option value="${fileType.FILE_TYPE}" selected>${fileType.FILE_TEXT}</option>
										</c:forEach>
									</select>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div id="matNewDiv" style="${productData.data.IS_NEW_MATERIAL == 'N' ? 'display:none' : ''}">
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
								<th>보관방법 및 유통기한</th>
								<th>공급가</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="matTbody" name="matTbody">
						<c:set var="count" value="0" />
						<c:forEach items="${productMaterialData}" var="productMaterialData" varStatus="status">
							<c:if test="${productMaterialData.MATERIAL_TYPE == 'Y' }">
							<c:set var="count" value="${count + 1}" />
							<tr id="newMatRow_${status.count}" class="temp_color">
								<td>
									<input type="checkbox" id="mat_${status.count}"><label for="mat_${status.count}"><span></span></label>
									<input type="hidden" name="itemType" value="${productMaterialData.MATERIAL_TYPE}"/>
									<input type="hidden" name="itemTypeName"/>
								</td>
								<td>
									<input type="hidden" name="itemMatIdx" style="width: 100px" class="code_tbl" value="${productMaterialData.MATERIAL_IDX}"/>
									<input type="text" name="itemMatCode" style="width: 100px" class="code_tbl" value="${productMaterialData.MATERIAL_CODE}" onkeyup="checkMaterail(event,'newMat')"/>
									<button class="btn_code_search2" onclick="openMaterialPopup(this,'newMat')"></button>
								</td>
								<td>
									<input type="text" name="itemSapCode" style="width: 100px" class="code_tbl" value="${productMaterialData.SAP_CODE}" onkeyup="checkMaterail(event,'newMat')"/>
								</td>
								<td>
									<input type="text" name="itemName" style="width: 85%" readonly="readonly" value="${productMaterialData.NAME}" class="read_only" />
								</td>
								<td><input type="text" name="itemStandard" style="width: 100%" value="${productMaterialData.STANDARD}" class=""/></td>
								<td><input type="text" name="itemKeepExp" style="width: 100%" value="${productMaterialData.KEEP_EXP}" class=""/></td>
								<td><input type="text" name="itemUnitPrice" style="width: 100%"  value="${productMaterialData.UNIT_PRICE}" readonly="readonly" class="read_only"/></td>
								<td><input type="text" name="itemDesc" style="width: 100%" value="${productMaterialData.DESCRIPTION}"/></td>
							</tr>
							</c:if>	
						</c:forEach>
						<c:if test="${count == 0}">
							<tr id="newMatRow_1" class="temp_color">
								<td>
									<input type="checkbox" id="mat_1"><label for="mat_1"><span></span></label>
									<input type="hidden" name="itemType" value="Y"/>
									<input type="hidden" name="itemTypeName"/>
								</td>
								<td>
									<input type="hidden" name="itemMatIdx" style="width: 100px" class="code_tbl"/>
									<input type="text" name="itemMatCode" style="width: 100px" class="req code_tbl" onkeyup="checkMaterail(event,'newMat')"/>
									<button class="btn_code_search2" onclick="openMaterialPopup(this,'newMat')"></button>
								</td>
								<td>
									<input type="text" name="itemSapCode" style="width: 100px" class="code_tbl" onkeyup="checkMaterail(event,'newMat')"/>
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
								<th>보관방법 및 유통기한</th>
								<th>공급가</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="matTbody" name="matTbody">
						<c:set var="count" value="0" />
						<c:forEach items="${productMaterialData}" var="productMaterialData" varStatus="status">
							<c:if test="${productMaterialData.MATERIAL_TYPE == 'N' }">
							<c:set var="count" value="${count + 1}" />
							<tr id="matRow_${status.count}" class="temp_color">
								<td>
									<input type="checkbox" id="mat_${status.count}"><label for="mat_${status.count}"><span></span></label>
									<input type="hidden" name="itemType" value="${productMaterialData.MATERIAL_TYPE}"/>
									<input type="hidden" name="itemTypeName"/>
								</td>
								<td>
									<input type="hidden" name="itemMatIdx" style="width: 100px" class="code_tbl" value="${productMaterialData.MATERIAL_IDX}"/>
									<input type="text" name="itemMatCode" style="width: 100px" class="code_tbl" value="${productMaterialData.MATERIAL_CODE}" onkeyup="checkMaterail(event,'mat')"/>
									<button class="btn_code_search2" onclick="openMaterialPopup(this,'mat')"></button>
								</td>
								<td>
									<input type="text" name="itemSapCode" style="width: 100px" class="code_tbl" value="${productMaterialData.SAP_CODE}"/>								
								</td>
								<td>
									<input type="text" name="itemName" style="width: 85%" readonly="readonly" value="${productMaterialData.NAME}" class="read_only" />
								</td>
								<td><input type="text" name="itemStandard" style="width: 100%" value="${productMaterialData.STANDARD}" class=""/></td>
								<td><input type="text" name="itemKeepExp" style="width: 100%" value="${productMaterialData.KEEP_EXP}" class=""/></td>
								<td><input type="text" name="itemUnitPrice" style="width: 100%"  value="${productMaterialData.UNIT_PRICE}" readonly="readonly" class="read_only"/></td>
								<td><input type="text" name="itemDesc" style="width: 100%" value="${productMaterialData.DESCRIPTION}"/></td>
							</tr>
							</c:if>	
						</c:forEach>
						<c:if test="${count == 0}">
							<tr id="matRow_1" class="temp_color">
								<td>
									<input type="checkbox" id="mat_1"><label for="mat_1"><span></span></label>
									<input type="hidden" name="itemType" value="N"/>
									<input type="hidden" name="itemTypeName"/>
								</td>
								<td>
									<input type="hidden" name="itemMatIdx" style="width: 100px" class="code_tbl"/>
									<input type="text" name="itemMatCode" style="width: 100px" class="code_tbl" onkeyup="checkMaterail(event,'mat')"/>
									<button class="btn_code_search2" onclick="openMaterialPopup(this,'mat')"></button>
								</td>
								<td>
									<input type="text" name="itemSapCode" style="width: 100px" class="code_tbl"/>								
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
								<textarea name="contents" id="contents" style="width: 666px; height: 200px; display: none;">${productData.data.CONTENTS}</textarea>
								<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
							</div>
						</li>
					</ul>
				</div>
			</div>
			
			
			
			
			<div class="main_tbl">
				<div class="btn_box_con5">
					<button class="btn_admin_gray" onClick="fn_list();" style="width: 120px;">목록</button>
				</div>
				<div class="btn_box_con4">
					<!-- 
					<button class="btn_admin_red">임시/템플릿저장</button>
					<button class="btn_admin_navi">임시저장</button>
					 -->
					<c:if test="${productData.data.STATUS == 'TMP' }">
					<button class="btn_admin_navi" onclick="fn_updateTmp()">임시저장</button>
					</c:if>
					<button class="btn_admin_sky" onclick="fn_update()">수정</button>
					<button class="btn_admin_gray" onclick="fn_list();">취소</button>
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
			<th>상품코드</th>
			<th>상품명</th>
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
				<input type="text" name="itemSapCode" style="width: 100px" class="req code_tbl"/>
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
					<tbody id="erpMatLayerBody">
						<input type="hidden" id="erpMatLayerPage" value="0"/>
						<Tr>
							<td colspan="9">상품코드 혹은 상품명을 검색해주세요</td>
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
			<span class="title">상품코드 검색</span>
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
							<td colspan="10">상품코드 혹은 상품명을 검색해주세요</td>
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
						<td colspan="10">원료코드 혹은 원료코드명을 검색해주세요</td>
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