<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*"%>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>상품 레시피 생성</title>
<style>
.positionCenter {
	position: absolute;
	transform: translate(-50%, -45%);
}

.ck-editor__editable {
	max-height: 200px;
	min-height: 200px;
}

li {
	list-style: none;
}
#prevPopup {
	display: none;
}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">

<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../resources/js/jstree.js"></script>
<script type="text/javascript"
	src="../resources/js/appr/apprClass.js?v=<%=System.currentTimeMillis()%>"></script>
<script type="text/javascript"
	src="../resources/js/user/userSearchClass.js?v=<%=System.currentTimeMillis()%>"></script>
<script type="text/javascript"
	src="../resources/js/preview/preview.js?v=<%=System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	$(document).ready(function(){
		fn_loadCode("PLANT", "plant");
		fn_loadCode("UNIT", "unit");
		
		fn.autoComplete($("#keyword"));
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
	
	function fn_closeErpMatRayer(){
		$('#searchErpMatValue').val('')
		$('#erpMatLayerBody').empty();
		$('#erpMatLayerBody').append('<tr><td colspan="10">상품코드 혹은 상품명을 검색해주세요</td></tr>');
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
					
					var row = '<tr onClick="fn_setMaterialPopupData(\''+item.SAP_CODE+'\', \''+item.NAME+'\', \''+item.UNIT+'\')">';
					//parentRowId, itemImNo, itemSAPCode, itemName, itemUnitPrice
					row += '<td></td>';
					//row += '<Td>'+item.companyCode+'('+item.plant+')'+'</Td>';
					row += '<Td>'+item.SAP_CODE+'</Td>';
					row += '<Td  class="tgnl">'+item.NAME+'</Td>';
					row += '<Td>'+item.KEEP_CONDITION_TXT+'</Td>';
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
				alert('상품검색 실패[2] - 시스템 담당자에게 문의하세요');
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
	
	function fn_setMaterialPopupData(SAP_CODE, NAME, UNIT) {
		$("#productName").val(NAME);
		$("#productCode").val(SAP_CODE);
		$("#unit").selectOptions(UNIT);
		$("#unit_label").html($("#unit").selectedTexts());
		fn_closeErpMatRayer();
	}

	
	
	function closeDialogWithClean(dialogId){
		initDialog();
		closeDialog(dialogId);
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
		
		var URL = '/material/selectErpMaterialListAjax';
		
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
					
					var row = '<tr onClick="setMaterialPopupData(\''+$('#targetID').val()+'\', \''+nvl2(item.SAP_CODE,'')+'\', \''+item.NAME+'\', \''+item.UNIT+'\', \''+nvl2(item.RECIPE_UNIT,'')+'\', \''+nvl2(item.RECIPE_AMOUNT,'')+'\')">';
					//parentRowId, itemImNo, itemSAPCode, itemName, itemUnitPrice
					row += '<td></td>';
					//row += '<Td>'+item.companyCode+'('+item.plant+')'+'</Td>';\
					row += '<Td>'+nvl(item.SAP_CODE,'')+'</Td>';
					row += '<Td  class="tgnl">'+item.NAME+'</Td>';
					row += '<Td>'+nvl(item.KEEP_CONDITION_TXT,'')+'</Td>';
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
	
	function setMaterialPopupData(parentRowId, itemSAPCode, itemName, itemUnit, itemRecipeUnit, itemRecipeAmount){
		var isDup = false;
		$('tr[id^=mat_tr]').toArray().forEach(function(newRow){
			var rowId = $(newRow).attr('id');
			if( itemSAPCode == $('#'+ rowId + ' input[name=itemSapCode]').val() ) {
				isDup = true;
			}
		});
		if( isDup ) {
			alert("동일한 원료는 등록할 수 없습니다.");
			return;
		} else {
			$('#'+parentRowId + ' input[name=itemSapCode]').val(itemSAPCode);
			$('#'+parentRowId + ' input[name=itemName]').val(itemName);
			$('#'+parentRowId + ' input[name=itemCompCount]').val(itemRecipeAmount);
			console.log(itemUnit);
			$('#'+parentRowId + ' select[name=itemCompUnit]').val(itemRecipeUnit.toLowerCase());
			$('#'+parentRowId + ' select[name=itemUseUnit]').val(itemRecipeUnit.toLowerCase());
			//$("#itemCompUnit").selectOptions(UNIT);
			//$("#itemCompUnit_label").html($("#unit").selectedTexts());
			fn_closeMatRayer();	
		}
	}
	
	function fn_insertTmp(){
		if( !chkNull($("#productCode").val()) ) {
			alert("제품코드를 입력해 주세요.");
			$("#productCode").focus();
			return;
		} else if( !chkNull($("#productName").val()) ) {
			alert("제품명 입력해 주세요.");
			$("#productName").focus();
			return;
		} else {
			$('#lab_loading').show();
			var formData = new FormData();
			formData.append("productCode",$("#productCode").val());
			formData.append("productName",$("#productName").val());
			formData.append("plant",$("#plant").selectedValues()[0]);
			formData.append("productCount",$("#productCount").val());
			formData.append("unit",$("#unit").selectedValues()[0]);
			
			var matItemSapCodeArr = new Array();
			var matItemNameArr = new Array();
			var matItemCompCountArr = new Array();
			var matItemCompUnitArr = new Array();
			var matItemUseCountArr = new Array();
			var matItemUseUnitArr = new Array();
			var matValid = true;
			$('tr[id^=mat_tr]').toArray().forEach(function(newRow){
				if( matValid ) {
					var rowId = $(newRow).attr('id');
					var itemSapCode = $('#'+ rowId + ' input[name=itemSapCode]').val();
					var itemName = $('#'+ rowId + ' input[name=itemName]').val();
					var itemCompCount = $('#'+ rowId + ' input[name=itemCompCount]').val();
					var itemCompUnit = $('#'+ rowId + ' select[name=itemCompUnit]').selectedValues()[0];
					var itemUseCount = $('#'+ rowId + ' input[name=itemUseCount]').val();
					var itemUseUnit = $('#'+ rowId + ' select[name=itemUseUnit]').selectedValues()[0];
					
					if( itemSapCode.length > 0 || itemName.length > 0 || itemCompCount.length > 0 || itemCompUnit.length > 0 || itemUseCount.length > 0  || itemUseUnit.length > 0 ) {
						if( !chkNull(itemSapCode) ) {
							alert(itemName+"구성품 코드를 등록해주세요.");
							matValid = false;
						} else if( !chkNull(itemCompCount) ) {
							alert(itemName+"구성품수량을 입력해주세요.");
							matValid = false;
						} else if( !chkNull(itemCompUnit) ) {
							alert(itemName+"구성품단위를 선택해주세요.");
							matValid = false;
						} else if( !chkNull(itemUseCount) ) {
							alert(itemName+"사용량을 등록해주세요.");
							matValid = false;
						} else if( !chkNull(itemUseUnit) ) {
							alert(itemName+"사용량단위를 선택해주세요.");
							matValid = false;
						}
						
						matItemSapCodeArr.push(itemSapCode);
						matItemNameArr.push(itemName);
						matItemCompCountArr.push(itemCompCount);
						matItemCompUnitArr.push(itemCompUnit);
						matItemUseCountArr.push(itemUseCount);
						matItemUseUnitArr.push(itemUseUnit);
					}
				}
			});
			
			if(!matValid) {
				$('#lab_loading').hide();
				return false;
			}
			
			if( matItemSapCodeArr.length == 0 ) {
				alert("원료는 한 건이상 입력하여야 합니다.");
				$('#lab_loading').hide();
				return;
			}
			
			
			formData.append("matItemSapCodeArr", JSON.stringify(matItemSapCodeArr));	
			formData.append("matItemNameArr", JSON.stringify(matItemNameArr));	
			formData.append("matItemCompCountArr", JSON.stringify(matItemCompCountArr));	
			formData.append("matItemCompUnitArr", JSON.stringify(matItemCompUnitArr));	
			formData.append("matItemUseCountArr", JSON.stringify(matItemUseCountArr));	
			formData.append("matItemUseUnitArr", JSON.stringify(matItemUseUnitArr));	
			
			
			var newItemNameArr = new Array();
			var newItemCompCountArr = new Array();
			var newItemCompUnitArr = new Array();
			var newItemUseCountArr = new Array();
			var newItemUseUnitArr = new Array();
			var newItemPriceArr = new Array();
			var newItemDescArr = new Array();
			
			var newValid = true;
			$('tr[id^=new_tr]').toArray().forEach(function(newRow){
				if(newValid) {
					var rowId = $(newRow).attr('id');
					console.log(rowId);
					var itemName = $('#'+ rowId + ' input[name=itemName]').val();
					var itemCompCount = $('#'+ rowId + ' input[name=itemCompCount]').val();
					var itemCompUnit = $('#'+ rowId + ' select[name=itemCompUnit]').selectedValues()[0];
					var itemUseCount = $('#'+ rowId + ' input[name=itemUseCount]').val();
					var itemUseUnit = $('#'+ rowId + ' select[name=itemUseUnit]').selectedValues()[0];
					var itemPrice = $('#'+ rowId + ' input[name=itemPrice]').val();
					var itemDesc = $('#'+ rowId + ' textarea[name=itemDesc]').val();
					
					if( itemName.length > 0 || itemCompCount.length > 0 || itemCompUnit.length > 0 || itemUseCount.length > 0  || itemUseUnit.length > 0 || itemPrice.length > 0 ) {
						var message = "";
						if( !chkNull(itemName) ) {
							alert("사입품 제품명을 입력해주세요.");
							newValid = false;
						} else if( !chkNull(itemCompCount) ) {
							alert(itemName+"사입품 구성품수량을 입력해주세요.");
							newValid = false;
						} else if( !chkNull(itemCompUnit) ) {
							alert(itemName+"사입품 구성품단위를 선택해주세요.");
							newValid = false;
						} else if( !chkNull(itemUseCount) ) {
							alert(itemName+"사입품 사용량을 입력해주세요.");
							newValid = false;
						} else if( !chkNull(itemUseUnit) ) {
							alert(itemName+"사입품 사용량단위를 선택해주세요.");
							newValid = false;
						} else if( !chkNull(itemPrice) ) {
							alert(itemName+"사입품 단가를  입력해주세요.");
							newValid = false;
						}
					}
					newItemNameArr.push(itemName);
					newItemCompCountArr.push(itemCompCount);
					newItemCompUnitArr.push(itemCompUnit);
					newItemUseCountArr.push(itemUseCount);
					newItemUseUnitArr.push(itemUseUnit);
					newItemPriceArr.push(itemPrice);
					newItemDescArr.push(itemDesc);
					console.log(itemDesc);					
				}
			});
			
			if(!newValid) {
				$('#lab_loading').hide();
				return false;
			}
			
			formData.append("newItemNameArr", JSON.stringify(newItemNameArr));	
			formData.append("newItemCompCountArr", JSON.stringify(newItemCompCountArr));	
			formData.append("newItemCompUnitArr", JSON.stringify(newItemCompUnitArr));	
			formData.append("newItemUseCountArr", JSON.stringify(newItemUseCountArr));	
			formData.append("newItemUseUnitArr", JSON.stringify(newItemUseUnitArr));	
			formData.append("newItemPriceArr", JSON.stringify(newItemPriceArr));
			formData.append("newItemDescArr", JSON.stringify(newItemDescArr));
			formData.append("status", "TMP");
			
			URL = "../recipe/insertTmpRecipeAjax";
			$.ajax({
				type:"POST",
				url:URL,
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				dataType:"json",
				success:function(result) {
					console.log(result);
					if( result.RESULT == 'S' ) {
						if( result.IDX > 0 ) {
							if( $("#apprLine option").length > 0 ) {
								var apprFormData = new FormData();
								apprFormData.append("docIdx", result.IDX );
								apprFormData.append("apprComment", $("#apprComment").val());
								apprFormData.append("apprLine", $("#apprLine").selectedValues());
								apprFormData.append("refLine", $("#refLine").selectedValues());
								apprFormData.append("title", $("#productName").val()+" 사전원가서 결재요청");
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
										alert($("#productName").val()+"("+$("#productCode").val()+")"+"가 임시저장 되었습니다.");
										$('#lab_loading').hide();
										fn_goList();
									},
									error:function(request, status, errorThrown){
										alert("결재 등록 오류가 발생하였습니다.");
										$('#lab_loading').hide();
									}			
								});
							} else {
								alert($("#productName").val()+"("+$("#productCode").val()+")"+"가 임시저장 되었습니다.");
								$('#lab_loading').hide();
								fn_goList();
							}
						} else {
							alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
							$('#lab_loading').hide();
						}
					} else {
						alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
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
		if( !chkNull($("#productCode").val()) ) {
			alert("제품코드를 입력해 주세요.");
			$("#productCode").focus();
			return;
		} else if( !chkNull($("#productName").val()) ) {
			alert("제품명 입력해 주세요.");
			$("#productName").focus();
			return;
		} else if( !chkNull($("#plant").selectedValues()[0]) ) {
			alert("플랜트를 선택해 주세요.");
			$("#plant").focus();
			return;
		} else if( !chkNull($("#productCount").val()) ) {
			alert("제품수량을 입력해 주세요.");
			$("#productCount").focus();
			return;
		} else if( !chkNull($("#unit").selectedValues()[0]) ) {
			alert("제품단위를 선택해 주세요.");
			$("#unit").focus();
			return;
		} else if( !chkNull($("#apprTxtFull").val()) ) {
			alert("결재라인을 등록해주세요.");
			return;
		} else {
			$('#lab_loading').show();
			var formData = new FormData();
			formData.append("productCode",$("#productCode").val());
			formData.append("productName",$("#productName").val());
			formData.append("plant",$("#plant").selectedValues()[0]);
			formData.append("productCount",$("#productCount").val());
			formData.append("unit",$("#unit").selectedValues()[0]);
			
			var matItemSapCodeArr = new Array();
			var matItemNameArr = new Array();
			var matItemCompCountArr = new Array();
			var matItemCompUnitArr = new Array();
			var matItemUseCountArr = new Array();
			var matItemUseUnitArr = new Array();
			var matValid = true;
			$('tr[id^=mat_tr]').toArray().forEach(function(newRow){
				if( matValid ) {
					var rowId = $(newRow).attr('id');
					var itemSapCode = $('#'+ rowId + ' input[name=itemSapCode]').val();
					var itemName = $('#'+ rowId + ' input[name=itemName]').val();
					var itemCompCount = $('#'+ rowId + ' input[name=itemCompCount]').val();
					var itemCompUnit = $('#'+ rowId + ' select[name=itemCompUnit]').selectedValues()[0];
					var itemUseCount = $('#'+ rowId + ' input[name=itemUseCount]').val();
					var itemUseUnit = $('#'+ rowId + ' select[name=itemUseUnit]').selectedValues()[0];
					
					if( itemSapCode.length > 0 || itemName.length > 0 || itemCompCount.length > 0 || itemCompUnit.length > 0 || itemUseCount.length > 0  || itemUseUnit.length > 0 ) {
						if( !chkNull(itemSapCode) ) {
							alert(itemName+"구성품 코드를 등록해주세요.");
							matValid = false;
						} else if( !chkNull(itemCompCount) ) {
							alert(itemName+"구성품수량을 입력해주세요.");
							matValid = false;
						} else if( !chkNull(itemCompUnit) ) {
							alert(itemName+"구성품단위를 선택해주세요.");
							matValid = false;
						} else if( !chkNull(itemUseCount) ) {
							alert(itemName+"사용량을 등록해주세요.");
							matValid = false;
						} else if( !chkNull(itemUseUnit) ) {
							alert(itemName+"사용량단위를 선택해주세요.");
							matValid = false;
						}
						
						matItemSapCodeArr.push(itemSapCode);
						matItemNameArr.push(itemName);
						matItemCompCountArr.push(itemCompCount);
						matItemCompUnitArr.push(itemCompUnit);
						matItemUseCountArr.push(itemUseCount);
						matItemUseUnitArr.push(itemUseUnit);
					}
				}
			});
			
			if(!matValid) {
				$('#lab_loading').hide();
				return false;
			}
			
			if( matItemSapCodeArr.length == 0 ) {
				alert("원료는 한 건이상 입력하여야 합니다.");
				$('#lab_loading').hide();
				return;
			}
			
			
			formData.append("matItemSapCodeArr", JSON.stringify(matItemSapCodeArr));	
			formData.append("matItemNameArr", JSON.stringify(matItemNameArr));	
			formData.append("matItemCompCountArr", JSON.stringify(matItemCompCountArr));	
			formData.append("matItemCompUnitArr", JSON.stringify(matItemCompUnitArr));	
			formData.append("matItemUseCountArr", JSON.stringify(matItemUseCountArr));	
			formData.append("matItemUseUnitArr", JSON.stringify(matItemUseUnitArr));	
			
			
			var newItemNameArr = new Array();
			var newItemCompCountArr = new Array();
			var newItemCompUnitArr = new Array();
			var newItemUseCountArr = new Array();
			var newItemUseUnitArr = new Array();
			var newItemPriceArr = new Array();
			var newItemDescArr = new Array();
			
			var newValid = true;
			$('tr[id^=new_tr]').toArray().forEach(function(newRow){
				if(newValid) {
					var rowId = $(newRow).attr('id');
					console.log(rowId);
					var itemName = $('#'+ rowId + ' input[name=itemName]').val();
					var itemCompCount = $('#'+ rowId + ' input[name=itemCompCount]').val();
					var itemCompUnit = $('#'+ rowId + ' select[name=itemCompUnit]').selectedValues()[0];
					var itemUseCount = $('#'+ rowId + ' input[name=itemUseCount]').val();
					var itemUseUnit = $('#'+ rowId + ' select[name=itemUseUnit]').selectedValues()[0];
					var itemPrice = $('#'+ rowId + ' input[name=itemPrice]').val();
					var itemDesc = $('#'+ rowId + ' textarea[name=itemDesc]').val();
					
					if( itemName.length > 0 || itemCompCount.length > 0 || itemCompUnit.length > 0 || itemUseCount.length > 0  || itemUseUnit.length > 0 || itemPrice.length > 0 ) {
						var message = "";
						if( !chkNull(itemName) ) {
							alert("사입품 제품명을 입력해주세요.");
							newValid = false;
						} else if( !chkNull(itemCompCount) ) {
							alert(itemName+"사입품 구성품수량을 입력해주세요.");
							newValid = false;
						} else if( !chkNull(itemCompUnit) ) {
							alert(itemName+"사입품 구성품단위를 선택해주세요.");
							newValid = false;
						} else if( !chkNull(itemUseCount) ) {
							alert(itemName+"사입품 사용량을 입력해주세요.");
							newValid = false;
						} else if( !chkNull(itemUseUnit) ) {
							alert(itemName+"사입품 사용량단위를 선택해주세요.");
							newValid = false;
						} else if( !chkNull(itemPrice) ) {
							alert(itemName+"사입품 단가를  입력해주세요.");
							newValid = false;
						}
					}
					newItemNameArr.push(itemName);
					newItemCompCountArr.push(itemCompCount);
					newItemCompUnitArr.push(itemCompUnit);
					newItemUseCountArr.push(itemUseCount);
					newItemUseUnitArr.push(itemUseUnit);
					newItemPriceArr.push(itemPrice);
					newItemDescArr.push(itemDesc);
					console.log(newValid);
				}
			});
			
			if(!newValid) {
				$('#lab_loading').hide();
				return false;
			}
			
			formData.append("newItemNameArr", JSON.stringify(newItemNameArr));	
			formData.append("newItemCompCountArr", JSON.stringify(newItemCompCountArr));	
			formData.append("newItemCompUnitArr", JSON.stringify(newItemCompUnitArr));	
			formData.append("newItemUseCountArr", JSON.stringify(newItemUseCountArr));	
			formData.append("newItemUseUnitArr", JSON.stringify(newItemUseUnitArr));	
			formData.append("newItemPriceArr", JSON.stringify(newItemPriceArr));
			formData.append("newItemDescArr", JSON.stringify(newItemDescArr));
			formData.append("status", "REG");
			
			URL = "../recipe/insertRecipeAjax";
			$.ajax({
				type:"POST",
				url:URL,
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				dataType:"json",
				success:function(result) {
					console.log(result);
					if( result.RESULT == 'S' ) {
						if( result.IDX > 0 ) {							
							if( $("#apprLine option").length > 0 ) {
								var apprFormData = new FormData();
								apprFormData.append("docIdx", result.IDX );
								apprFormData.append("apprComment", $("#apprComment").val());
								apprFormData.append("apprLine", $("#apprLine").selectedValues());
								apprFormData.append("refLine", $("#refLine").selectedValues());
								apprFormData.append("title", $("#productName").val()+" 사전원가서 결재요청");
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
											alert($("#productName").val()+"("+$("#productCode").val()+")"+"가 정상적으로 등록되었습니다.");
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
								alert($("#productName").val()+"("+$("#productCode").val()+")"+"가 정상적으로 등록되었습니다.");
								$('#lab_loading').hide();
								fn_goList();
							}
						} else {
							alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
							$('#lab_loading').hide();
						}
					} else {
						alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
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
		location.href = '/recipe/list';
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
	
	function clearNoNum(obj){
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
	
	function doGetCaretPosition (ctrl){
		var CaretPos = 0;
		if (document.selection){//IE
			ctrl.focus ();
			var Sel = document.selection.createRange ();
			Sel.moveStart ('character', -ctrl.value.length);
			CaretPos = Sel.text.length;
		}else if (ctrl.selectionStart || ctrl.selectionStart == '0'){// Firefox support
			CaretPos = ctrl.selectionStart;
		}
		return (CaretPos);
	}
	
	function setCaretPosition(ctrl, pos){
		if(ctrl.setSelectionRange){
			ctrl.focus();
			ctrl.setSelectionRange(pos,pos);
		}else if (ctrl.createTextRange){
			var range = ctrl.createTextRange();
			range.collapse(true);
			range.moveEnd('character', pos);
			range.moveStart('character', pos);
			range.select();
		}
	}
	
	function clearNum(obj) {
		const regex = /^[0-9]+$/;
		var needToSet = false;
		var numStr = obj.value;
		var CaretPos = doGetCaretPosition(obj); //input field에서의 캐럿의 위치를 확인
		
		if( (/[^\d.]/g).test(numStr) ) {
			numStr = numStr.replace(/[^\d.]/g,"");
			CaretPos--;
			alert("입력은 숫자만 가능 합니다.");('.')
			needToSet = true;
		}
		if(needToSet) { //변경이 필요할 경우에만 셋팅함.
			obj.value = numStr;
			setCaretPosition(obj, CaretPos)
		}
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
	
	function fn_previewDataBinding(popup) {
	    const $doc = popup.document;

	    // 제목
	    $doc.title = document.getElementById("productName").value + '_사전원가서';

	    // 제품 기본 정보
	    $doc.getElementById("prev_productCode").innerText = document.getElementById("productCode").value;
	    $doc.getElementById("prev_productName").innerText = document.getElementById("productName").value;
	    const plantLabel = document.getElementById("plant_label")?.innerText?.trim();
	    $doc.getElementById("prev_plantName").innerText = (plantLabel && plantLabel !== "선택") ? plantLabel : "";
	    $doc.getElementById("prev_plantCount").innerText = document.getElementById("productCount").value;
	    const unitLabel = document.getElementById("unit_label")?.innerText?.trim();
	    $doc.getElementById("prev_unitName").innerText = (unitLabel && unitLabel !== "선택") ? unitLabel : "";

	    // 원료 정보
	    const matRows = document.querySelectorAll("#mat_tbody tr");
	    const matTbody = $doc.getElementById("prev_matTbody");
	    matTbody.innerHTML = "";

	    matRows.forEach(row => {
	        const itemSapCode = row.querySelector("input[name='itemSapCode']").value;
	        const itemName = row.querySelector("input[name='itemName']").value;
	        const itemCompCount = row.querySelector("input[name='itemCompCount']").value;

	        const itemCompUnitSelect = row.querySelector("select[name='itemCompUnit']");
	        const itemCompUnit = itemCompUnitSelect.value ? 
	            itemCompUnitSelect.options[itemCompUnitSelect.selectedIndex].text : "";

	        const itemUseCount = row.querySelector("input[name='itemUseCount']").value;

	        const itemUseUnitSelect = row.querySelector("select[name='itemUseUnit']");
	        const itemUseUnit = itemUseUnitSelect.value ? 
	            itemUseUnitSelect.options[itemUseUnitSelect.selectedIndex].text : "";

	        const tr = $doc.createElement("tr");
	        tr.innerHTML =
	            '<td>' + itemSapCode + '</td>' +
	            '<td>' + itemName + '</td>' +
	            '<td style="text-align:right;">' + itemCompCount + '</td>' +
	            '<td>' + itemCompUnit + '</td>' +
	            '<td style="text-align:right;">' + itemUseCount + '</td>' +
	            '<td>' + itemUseUnit + '</td>';
	        matTbody.appendChild(tr);
	    });

	    // 사입품 정보
	    const newRows = document.querySelectorAll("#new_tbody tr");
	    const newTbody = $doc.getElementById("prev_newMatTbody");
	    newTbody.innerHTML = "";

	    newRows.forEach(row => {
	        const itemName = row.querySelector("input[name='itemName']").value;
	        const itemCompCount = row.querySelector("input[name='itemCompCount']").value;

	        const itemCompUnitSelect = row.querySelector("select[name='itemCompUnit']");
	        const itemCompUnit = itemCompUnitSelect.value ? 
	            itemCompUnitSelect.options[itemCompUnitSelect.selectedIndex].text : "";

	        const itemUseCount = row.querySelector("input[name='itemUseCount']").value;

	        const itemUseUnitSelect = row.querySelector("select[name='itemUseUnit']");
	        const itemUseUnit = itemUseUnitSelect.value ? 
	            itemUseUnitSelect.options[itemUseUnitSelect.selectedIndex].text : "";

	        const itemPrice = row.querySelector("input[name='itemPrice']").value;
	        const itemDesc = row.querySelector("textarea[name='itemDesc']").value;

	        const tr = $doc.createElement("tr");
	        tr.innerHTML =
	            '<td>' + itemName + '</td>' +
	            '<td style="text-align:right;">' + itemCompCount + '</td>' +
	            '<td>' + itemCompUnit + '</td>' +
	            '<td style="text-align:right;">' + itemUseCount + '</td>' +
	            '<td>' + itemUseUnit + '</td>' +
	            '<td style="text-align:right;">' + itemPrice + '</td>' +
	            '<td>' + itemDesc + '</td>';
	        newTbody.appendChild(tr);
	    });
	}
	
	function fn_openPreview() {
		var url = "/preview/recipePrevPopup";

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
	<span class="path"> 사전원가서 등록&nbsp;&nbsp; <img
		src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;사전원가서등록&nbsp;&nbsp; <img src="/resources/images/icon_path.png"
		style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position: relative">
			<span class="title_s">Cost Management</span><span class="title">사전원가서 등록</span>
			<div class="top_btn_box">
				<!-- <ul>
					<li>
						<button class="btn_circle_save" onclick="fn_insert()">&nbsp;</button>
					</li>
				</ul> -->
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title">
				<!--span class="txt">연구개발시스템 공지사항</span-->
			</div>
			<div class="title2"  style="display: flex; justify-content:space-between; width: 100%;">
				<span class="txt">제품정보 <span class="mandatory">*</span></span>
				<div class="pr15">
					<button id="prevBtn" class="btn_small_search" onclick="fn_openPreview()">미리보기</button>
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
								<th style="border-left: none;">제품코드 <span class="mandatory">*</span></th>
								<td>
									<input type="text" style="width: 200px; float: left" name="productCode"onkeyup="clearNoNum(this)" id="productCode" placeholder="코드를 생성 하세요." readonly />
									<button class="btn_small_search ml5" onclick="openDialog('dialog_erpMaterial')" style="float: left">조회</button>
									<button class="btn_small_search ml5" onclick="fn_initForm()" style="float: left">초기화</button>
								</td>
								<th style="border-left: none;">제품명<span class="mandatory">*</span></th>
								<td>
									<input type="text" style="width: 200px; float: left" name="productName" id="productName" placeholder="제품코드를 조회 하세요." readonly />
								</td>
							</tr>
							<tr>
								<th style="border-left: none;">결재라인<span class="mandatory">*</span></th>
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
								<th style="border-left: none;">플랜트 <span class="mandatory">*</span></th>
								<td colspan="3">
									<div class="selectbox req" style="width:147px;">  
										<label for="plant" id="plant_label"> 선택</label> 
										<select id="plant" id="plant">
										</select>
									</div>
								</td>								
							</tr>
							<tr>
								<th style="border-left: none;">제품수량 <span class="mandatory">*</span></th>
								<td>
									<input type="text" style="width: 100px; float: left" name="productCount" id="productCount" placeholder="수량 입력." onkeyup="clearNoNum(this)"/>									
								</td>
								<th style="border-left: none;">제품단위</th>
								<td>
									<div class="selectbox req" style="width:147px;">  
										<label for="unit" id="unit_label"> 선택</label> 
										<select id="unit" id="unit">
										</select>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div id="matDiv">
					<div class="title2" style="float: left; margin-top: 30px;">
						<span class="txt">원료</span>
					</div>
					<div id="matHeaderDiv" class="table_header07">
						<span class="table_order_btn"><button class="btn_up"
								onclick="moveUp(this)"></button>
							<button class="btn_down" onclick="moveDown(this)"></button></span> <span
							class="table_header_btn_box">
							<button class="btn_add_tr" onclick="fn_addCol('mat')"
								id="mat_add_btn"></button>
							<button class="btn_del_tr" onclick="fn_delCol('mat')"></button>
						</span>
					</div>
					<table id="matTable" class="tbl05">
						<colgroup>
							<col width="20">
							<col width="140">
							<col />
							<col width="150">
							<col width="100">
							<col width="150">
							<col width="100">
						</colgroup>
						<thead>
							<tr>
								<th><input type="checkbox" id="matTable_1"
									onclick="checkAll(event)"><label for="matTable_1"><span></span></label></th>
								<th>구성품코드</th>
								<th>구성품명</th>
								<th>구성품수량</th>
								<th>구성품단위</th>
								<th>사용량</th>
								<th>사용량단위</th>
							</tr>
						</thead>
						<tbody id="mat_tbody" name="mat_tbody">
							<tr id="mat_tr_1" class="temp_color">
								<td>
									<input type="checkbox" id="mat_2"><label for="mat_2"><span></span></label> 
									<input type="hidden" name="itemType" value="N" />
								</td>
								<td>
									<input type="text" name="itemSapCode" style="width: 100px" />
									<button class="btn_code_search2" onclick="openMaterialPopup(this,'mat')"></button>
								</td>
								<td>
									<input type="text" name="itemName" style="width: 95%" readonly="readonly" class="read_only" />
								</td>
								<td>
									<input type="text" name="itemCompCount" style="width: 100%; text-align:right;" class="" onkeyup="clearNoNum(this)"/>
								</td>
								<td>
									<!-- <div class="selectbox req" style="width:100%;">  
										<label for="itemCompUnit" id="itemCompUnit_label"> 선택</label> --> 
										<select id="itemCompUnit" name="itemCompUnit" style="width:100%;">
											<option value="">선택</option>
											<option value="ea">개</option>
											<option value="g">그램</option>
										</select>
									<!--  </div> -->	
								</td>
								<td>
									<input type="text" name="itemUseCount" style="width: 100%; text-align:right;" onkeyup="clearNoNum(this)"/>
								</td>
								<td>
									<!--<div class="selectbox req" style="width:100%;">  
										<label for="itemUseUnit" id="itemUseUnit_label"> 선택</label> -->
										<select id="itemUseUnit" name="itemUseUnit" style="width:100%;">
											<option value="">선택</option>
											<option value="ea">개</option>
											<option value="g">그램</option>
										</select>
									<!--</div>-->
								</td>
							</tr>
						</tbody>
						<tbody id="mat_tbody_temp" name="mat_tbody_temp"
						style="display: none">
							<tr id="mat_tmp_tr_1" class="temp_color">
								<td>
									<input type="checkbox" id="mat_2"><label for="mat_2"><span></span></label> 
									<input type="hidden" name="itemType" value="N" />
								</td>
								<td>
									<input type="text" name="itemSapCode" style="width: 100px" />
									<button class="btn_code_search2" onclick="openMaterialPopup(this,'mat')"></button>
								</td>
								<td>
									<input type="text" name="itemName" style="width: 95%" readonly="readonly" class="read_only" />
								</td>
								<td>
									<input type="text" name="itemCompCount" style="width: 100%; text-align:right;" class="" onkeyup="clearNoNum(this)"/>
								</td>
								<td>
									<!--<div class="selectbox req" style="width:100%;">  
										<label for="itemCompUnit" id="itemCompUnit_label"> 선택</label> -->
										<select id="itemCompUnit" name="itemCompUnit" style="width:100%;">
											<option value="">선택</option>
											<option value="ea">개</option>
											<option value="g">그램</option>
										</select>
									</div>	
								</td>
								<td>
									<input type="text" name="itemUseCount" style="width: 100%; text-align:right;" onkeyup="clearNoNum(this)"/>
								</td>
								<td>
									<!--<div class="selectbox req" style="width:100%;">  
										<label for="itemUseUnit" id="itemUseUnit_label"> 선택</label> -->
										<select id="itemUseUnit" name="itemUseUnit" style="width:100%;">
											<option value="">선택</option>
											<option value="ea">개</option>
											<option value="g">그램</option>
										</select>
									<!--</div>-->
								</td>
							</tr>
						</tbody>
						<tfoot>
						</tfoot>
					</table>
				</div>				


				<div class="title2" style="float: left; margin-top: 30px;">
					<span class="txt">사입품</span>
				</div>
				<div id="matHeaderDiv" class="table_header07">
					<span class="table_order_btn"><button class="btn_up"
							onclick="moveUp(this)"></button>
						<button class="btn_down" onclick="moveDown(this)"></button></span> <span
						class="table_header_btn_box">
						<button class="btn_add_tr" onclick="fn_addCol('new')"
							id="new_add_btn"></button>
						<button class="btn_del_tr" onclick="fn_delCol('new')"></button>
					</span>
				</div>
				<table id="new_Table" class="tbl05">
					<colgroup>
						<col width="20">
						<col />
						<col width="100">
						<col width="100">
						<col width="100">
						<col width="100">
						<col width="100">
						<col width="250">
					</colgroup>
					<thead>
						<tr>
							<th></th>
							<th>제품명</th>
							<th>구성품수량</th>
							<th>구성품단위</th>
							<th>사용량</th>
							<th>사용량단위</th>
							<th>단가</th>
							<th>비고</th>
						</tr>
					</thead>
					<tbody id="new_tbody" name="new_tbody">
						<tr id="new_tr_1" class="temp_color">
							<td>
								<input type="checkbox" id="new_1"><label for="new_1"><span></span></label>
							</td>
							<td>
								<input type="text" name="itemName" style="width: 100%;" class="code_tbl" />
							</td>
							<td>
								<input type="text" name="itemCompCount" style="width: 100%; text-align:right;" onkeyup="clearNoNum(this)"/>
							</td>
							<td>
								<!--<div class="selectbox req" style="width:100%;">  
									<label for="itemCompUnit" id="itemCompUnit_label"> 선택</label> -->
									<select id="itemCompUnit" name="itemCompUnit" style="width:100%;">
										<option value="">선택</option>
										<option value="ea">개</option>
										<option value="g">그램</option>
									</select>
								<!--</div>-->
							</td>
							<td>
								<input type="text" name="itemUseCount" style="width: 100%; text-align:right;" class="" onkeyup="clearNoNum(this)"/>
							</td>
							<td>
								<!--<div class="selectbox req" style="width:100%;">  
									<label for="itemUseUnit" id="itemUseUnit_label"> 선택</label> -->
									<select id="itemUseUnit" name="itemUseUnit" style="width:100%;">
										<option value="">선택</option>
										<option value="ea">개</option>
										<option value="g">그램</option>
									</select>
								<!--</div>-->
							</td>
							<td>
								<input type="text" name="itemPrice" style="width: 100%; text-align:right;" class="" onkeyup="clearNum(this)" maxlength="11"/>
							</td>
							<td>
								<textarea style="width:100%; height:35px;" name="itemDesc" id="itemDesc"></textarea>
							</td>
						</tr>
					</tbody>
					<tbody id="new_tbody_temp" name="new_tbody_temp"
						style="display: none">
						<tr id="new_tmp_tr_1" class="temp_color">
							<td>
								<input type="checkbox" id="new_1"><label for="new_1"><span></span></label>
							</td>
							<td>
								<input type="text" name="itemName" style="width: 100%" class="code_tbl" />
							</td>
							<td>
								<input type="text" name="itemCompCount" style="width: 100%; text-align:right;" onkeyup="clearNoNum(this)"/>
							</td>
							<td>
								<!--<div class="selectbox req" style="width:100%;">  
									<label for="itemCompUnit" id="itemCompUnit_label"> 선택</label> -->
									<select id="itemCompUnit" name="itemCompUnit" style="width:100%;">
										<option value="">선택</option>
										<option value="ea">개</option>
										<option value="g">그램</option>
									</select>
								<!--</div>-->
							</td>
							<td>
								<input type="text" name="itemUseCount" style="width: 100%; text-align:right;" class="" onkeyup="clearNoNum(this)"/>
							</td>
							<td>
								<!--<div class="selectbox req" style="width:100%;">  
									<label for="itemUseUnit" id="itemUseUnit_label"> 선택</label> -->
									<select id="itemUseUnit" name="itemUseUnit" style="width:100%;">
										<option value="">선택</option>
										<option value="ea">개</option>
										<option value="g">그램</option>
									</select>
								<!--</div>-->
							</td>
							<td>
								<input type="text" name="itemPrice" style="width: 100%; text-align:right;" class="" onkeyup="clearNum(this)" maxlength="11"/>
							</td>
							<td>
								<textarea style="width:100%; height:35px;" name="itemDesc" id="itemDesc"></textarea>
							</td>
						</tr>
					</tbody>
					<tfoot>
					</tfoot>
				</table>


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
					<button class="btn_admin_sky" onclick="fn_insert()">결재</button>
					<button class="btn_admin_gray" onclick="fn_goList()">취소</button>
				</div>
				<hr class="con_mode" />
			</div>
		</div>
	</section>
</div>

<!-- SAP 코드 검색 레이어 start-->
<!-- SAP 코드 검색 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_erpMaterial">
	<input id="erpTargetID" type="hidden"> <input id="erpItemType"
		type="hidden">
	<div class="modal positionCenter"
		style="width: 900px; height: 600px; margin-left: -55px; margin-top: -50px">
		<h5 style="position: relative">
			<span class="title">상품코드 검색</span>
			<div class="top_btn_box">
				<ul>
					<li><button class="btn_madal_close"
							onClick="fn_closeErpMatRayer()"></button></li>
				</ul>
			</div>
		</h5>

		<div id="erpMatListDiv" class="code_box">
			<input id="searchErpMatValue" type="text" class="code_input"
				onkeyup="bindDialogEnter(event)" style="width: 300px;"
				placeholder="일부단어로 검색가능"> <img
				src="/resources/images/icon_code_search.png"
				onclick="fn_searchErpMaterial()" />
			<div class="code_box2">
				(<strong> <span id="erpMatCount">0</span>
				</strong>)건
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
						<input type="hidden" id="erpMatLayerPage" value="0" />
						<Tr>
							<td colspan="9">상품코드 혹은 상품코드명을 검색해주세요</td>
						</Tr>
					</tbody>
				</table>
				<!-- 뒤에 추가 리스트가 있을때는 클래스명 02로 숫자변경 -->
				<div id="erpMatNextPrevDiv" class="page_navi  mt10">
					<button class="btn_code_left01"
						onclick="fn_searchErpMaterial('prevPage')"></button>
					<button class="btn_code_right02"
						onclick="fn_searchErpMaterial('nextPage')"></button>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- 코드검색 추가레이어 close-->
<!-- SAP 코드 검색 레이어 close-->
<!-- 신규 자재코드 검색 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_material">
	<input id="targetID" type="hidden"> <input id="itemType"
		type="hidden"> <input id="searchType" type="hidden">
	<div class="modal positionCenter" style="width: 900px; height: 600px">
		<h5 style="position: relative">
			<span class="title">상품코드 검색</span>
			<div class="top_btn_box">
				<ul>
					<li><button class="btn_madal_close"
							onClick="fn_closeMatRayer()"></button></li>
				</ul>
			</div>
		</h5>

		<div id="matListDiv" class="code_box">
			<input id="searchMatValue" type="text" class="code_input"
				onkeyup="if (event.keyCode === 13) { searchMaterial('',''); }" style="width: 300px;"
				placeholder="일부단어로 검색가능"> <img
				src="/resources/images/icon_code_search.png"
				onclick="searchMaterial('','');" />
			<div class="code_box2">
				(<strong> <span id="matCount">0</span>
				</strong>)건
			</div>
			<div class="main_tbl">
				<table class="tbl07">
					<colgroup>
						<col width="40px">
						<col width="10%">
						<col width="25%">
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
					<tbody id="matLayerBody">
						<input type="hidden" id="matLayerPage" value="0" />
						<Tr>
							<td colspan="10">상품코드 혹은 상품명을 검색해주세요</td>
						</Tr>
					</tbody>
				</table>
				<!-- 뒤에 추가 리스트가 있을때는 클래스명 02로 숫자변경 -->
				<div id="matNextPrevDiv" class="page_navi  mt10">
					<button class="btn_code_left01"
						onclick="searchMaterial('prevPage','')"></button>
					<button class="btn_code_right02"
						onclick="searchMaterial('nextPage','')"></button>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- 코드검색 추가레이어 close-->

<!-- 결재 상신 레이어  start-->
<div class="white_content" id="approval_dialog">
	<input type="hidden" id="docType" value="RECIPE"/>
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
			<span class="title">사전원가서 결재 상신</span>
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
