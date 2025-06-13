/**
 * 
 */


var attatchFileArr = [];
var attatchFileTypeArr = [];

function loadCompany(selectBoxId) {
	var URL = "../common/companyListAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
		},
		dataType:"json",
		async:false,
		success:function(data) {
			var list = data.RESULT;
			$("#"+selectBoxId).removeOption(/./);
			$("#"+selectBoxId).addOption("", "전체", false);
			$("#label_"+selectBoxId).html("전체");
			$.each(list, function( index, value ){ //배열-> index, value
				$("#"+selectBoxId).addOption(value.companyCode, value.companyName, false);
			});
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}			
	});
}

function companyChange(companySelectBoxId, selectBoxId) {
	var URL = "../common/plantListAjax";
	var companyCode = $("#"+companySelectBoxId).selectedValues()[0];
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"companyCode" : companyCode
		},
		dataType:"json",
		async:false,
		success:function(data) {
			var list = data.RESULT;
			$("#"+selectBoxId).removeOption(/./);
			$("#"+selectBoxId).addOption("", "전체", false);
			$("#label_"+selectBoxId).html("전체");
			$.each(list, function( index, value ){ //배열-> index, value
				$("#"+selectBoxId).addOption(value.plantCode, value.plantName, false);
			});
			$('#'+selectBoxId).parent().show();
			
			
			if(companyCode == 'MD'){
				$('#calcTypeLi1').hide();
				$('#calcTypeLi2').show();
				
				$('#radio_caclType4').click()
			} else {
				$('#calcTypeLi1').show();
				$('#calcTypeLi2').hide();
				
				$('#radio_caclType1').click()
			}
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}			
	});
}

/* 파일첨부 관련 함수 START */
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
	attatchFileArr.forEach(function(file){
		if(file.name == fileName)
			isDuple = true;
	})
	
	if(isDuple){
		if(!confirm('같은 이름의 파일이 존재합니다. 계속 진행하시겠습니까?')){
			return;
		};
	}
	
	attatchFileArr.push(file[0]);
	attatchFileArr[attatchFileArr.length-1].tempId = randomId;
	attatchFileTypeArr.push({fileType: fileType, fileTypeText: fileTypeText, tempId: randomId});
	
	var childTag = '<li><a href="#none" onclick="removeFile(this, \''+randomId+'\')"><img src="/resources/images/icon_del_file.png"></a><span>'+fileTypeText+'</span>&nbsp;'+fileName+'</li>'
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
}
function uploadFiles(){
	$('#lab_loading').show();
	var docNo = '${productDevDoc.docNo}';
	var docVersion = '${productDevDoc.docVersion}';
	
	var formData = new FormData();
	formData.append('docNo', docNo);
	formData.append('docVersion', docVersion);
	
	/* attatchFileArr.forEach(function(file){
		formData.append('file', file)
	})
	
	attatchFileTypeArr.forEach(function(option, ndx){
		formData.append('fileType', option.fileType)
		formData.append('fileTypeText', option.fileTypeText)
	}) */
	
	for (var i = 0; i < attatchFileArr.length; i++) {
		formData.append('file', attatchFileArr[i])
	}
	
	for (var i = 0; i < attatchFileTypeArr.length; i++) {
		formData.append('fileType', attatchFileTypeArr[i].fileType)
		formData.append('fileTypeText', attatchFileTypeArr[i].fileTypeText)
	}
	
	$.ajax({
		url: '/dev/uploadDevDocFile',
		contentType: 'multipart/form-data', 
		type: 'post',
		data: formData,
		processData: false,
        contentType: false,
        cache: false,
        success: function(data){
        	if(data == 'S'){
        		alert('저장되었습니다');
        		reload();
        	} else if(data == 'E') {
        		$('#lab_loading').hide();
        		return alert('파일저장 오류');
        	} else {
        		$('#lab_loading').hide();
        		return alert('파일이 전달되지 않았습니다');
        	}
        },
        error: function(a,b,c){
        	//console.log(a,b,c)
        	alert('파일저장 오류[2]');
        	$('#lab_loading').hide();
        }
	})
}
/* 파일첨부 관련 함수 END */

/* 페이지 이동 관련 START */


function goMfgDetail(dNo, docNo, docVersion){
	var form = document.createElement('form');
	form.style.display = 'none';
	$('body').append(form);
	form.action = '/dev/manufacturingProdcessDetail';
	form.target = '_blank';
	form.method = 'post';
	
	appendInput(form, 'dNo', dNo);
	appendInput(form, 'docNo', docNo);
	appendInput(form, 'docVersion', docVersion);
	
	$(form).submit();
}

function changeVersion(docVersion){
	var docNo = '${productDevDoc.docNo}';
	
	var form = document.createElement('form');
	$('body').append(form);
	form.action = '/dev/productDevDocDetail';
	form.method = 'post';
	
	appendInput(form, 'docNo', docNo);
	appendInput(form, 'docVersion', docVersion);
	
	$(form).submit();
}

function ceateDesignRequest(){
	var docNo = '${productDevDoc.docNo}';
	var docVersion = '${productDevDoc.docVersion}';
	
	var form = document.createElement('form');
	$('body').append(form);
	form.action = '/dev/designRequestDocCreate';
	form.method = 'post';
	
	appendInput(form, 'docNo', docNo);
	appendInput(form, 'docVersion', docVersion);
	appendInput(form, 'createType', 'N');
	
	$(form).submit();
}

function editMfg(dNo, companyCode, plantCode){
	var URL = "../approval/countReviewDoc";
	var docNo = '${productDevDoc.docNo}';
	var docVersion = '${productDevDoc.docVersion}';
	var userGrade = '${userUtil:getUserGrade(pageContext.request)}';
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"docNo" : docNo,
			"docVersion" : docVersion				
		},
		dataType:"json",
		success:function(data) {
			if(data.count  > 0 && userGrade != '6' ) {
				alert("디자인의뢰서가 1차 검토중일 때는 수정할 수 없습니다.");
				return;
			} else {
				var form = $('#mfgCreateForm');
				form.attr('action', '/dev/manufacturingProdcessEdit')
				form.append('<input type="hidden" name="dNo" value="'+dNo+'">');
				form.append('<input type="hidden" name="companyCode" value="'+companyCode+'">');
				form.append('<input type="hidden" name="plantCode" value="'+plantCode+'">');
				form.submit();
			}
		},
		error:function(request, status, errorThrown){
			alert("오류가 발생하였습니다. \n다시 처리해주세요.");
		}			
	});	
}

function editMfgPackage(dNo, companyCode, plantCode){
	var form = $('#mfgCreateForm');
	form.attr('action', '/dev/manufacturingProdcessEditMarketing')
	form.append('<input type="hidden" name="dNo" value="'+dNo+'">');
	form.append('<input type="hidden" name="companyCode" value="'+companyCode+'">');
	form.append('<input type="hidden" name="plantCode" value="'+plantCode+'">');
	form.submit();
}

function editMfgSpec(dNo, companyCode, plantCode){
	var form = $('#mfgCreateForm');
	form.attr('action', '/dev/manufacturingProdcessEditSpec')
	form.append('<input type="hidden" name="dNo" value="'+dNo+'">');
	form.append('<input type="hidden" name="companyCode" value="'+companyCode+'">');
	form.append('<input type="hidden" name="plantCode" value="'+plantCode+'">');
	form.submit();
}

/* function editMfgMarketing(dNo, companyCode, plantCode){
	var form = $('#mfgCreateForm');
	form.attr('action', '/dev/manufacturingProdcessEditMarketing')
	form.append('<input type="hidden" name="dNo" value="'+dNo+'">');
	form.append('<input type="hidden" name="companyCode" value="'+companyCode+'">');
	form.append('<input type="hidden" name="plantCode" value="'+plantCode+'">');
	form.submit();
} */

function goList(){
	var form = document.createElement('form');
	$('body').append(form);
	form.action = '/dev/productDevDocList';
	form.method = 'post';
	
	$(form).submit();
}

/* 페이지 이동 관련 END */


function changemfg_create_type(e){
	var type = e.target.value.split('type_')[1];
	if(type == 'new'){
		$('#dialog_create div.modal').css('height', '340px');
		$('li[id*=dialog_create_li]').hide();
	} else {
		if(type == 'mfg'){
			$('#dialog_create div.modal').css('height', '430px');
		} else {
			$('#dialog_create div.modal').css('height', '385px');
		}
		$('li[id*=dialog_create_li]').hide();
		$('li[id=dialog_create_li_'+type+']').show();
	}
}

function stopMfgDOc(dNo){
	if(confirm('제조공정서(문서번호:'+dNo+')의 사용을 중지합니다. 진행 할 경우 더이상 수정 및 삭제가 불가능합니다. 계속하시겠습니까?')){
		$.ajax({
			url: '/dev/stopManufacturingProcessDoc',
			type: 'post',
			data: {
				dNo: dNo
			},
			success: function(data){
				if(data == 'S'){
					alert('문서상태가 변경되었습니다.');
					reload();
				} else {
					return alert('사용중지 오류[1]');
				}
			},
			error: function(a,b,c){
				return alert('사용중지 오류[2]');
			}
		})
	}
}

function deleteMfgDoc(dNo){
	var docNo = '${productDevDoc.docNo}';
	var docVersion = '${productDevDoc.docVersion}';
	
	if(confirm('제조공정서(문서번호:'+dNo+')를 정말 삭제하시겠습니까?')){
		$.ajax({
			url: '/dev/deleteManufacturingProcessDoc',
			type: 'post',
			data: {
				dNo: dNo,
				docNo: docNo,
				docVersion: docVersion
			},
			success: function(data){
				if(data == 'S'){
					alert('정삭적으로 삭제되었습니다.');
					reload();
				} else {
					return alert('삭제 오류[1]');
				}
			},
			error: function(a,b,c){
				return alert('삭제 오류[2]');
			}
		})
	} else {
		return;
	}
}

function copyMfgDoc(dNo){
	var docNo = '${productDevDoc.docNo}';
	var docVersion = '${productDevDoc.docVersion}';
	
	if(confirm('제조공정서(문서번호:'+dNo+')를 복사 생성하시겠습니까?')){
		$.ajax({
			url: '/dev/copyManufacturingProcessDoc',
			type: 'post',
			data: {
				dNo: dNo,
				docNo: docNo,
				docVersion: docVersion
			},
			success: function(data){
				if(data.length > 0){
					alert('문서번호:'+data+'로 복사되었습니다');
					reload();
				} else {
					return alert('복사 오류[1]');
				}
			},
			error: function(a,b,c){
				return alert('복사 오류[2]');
			}
		})
	} else {
		return;
	}
}

function deleteFile(ddfNo, fileName){
	if(confirm('첨부 이미지['+fileName+']을(를) 정말 삭제하시겠습니까?')){
		$('#lab_loading').show();
		$.ajax({
			url: '/file/deleteDevDocFile',
			type: 'post',
			data: { ddfNo: ddfNo },
			success: function(data){
				if(data == 'S'){
					alert('정상적으로 삭제되었습니다')
					reload();
				} else if(data == 'E'){
					alert('파일 삭제 오류(1)');
					$('#lab_loading').hide();
				} else {
					alert('존재하지 않는 파일입니다');
					$('#lab_loading').hide();
				}
			},
			error: function(a,b,c){
				//console.log(a,b,c)
				alert('파일 삭제 오류(2)');
				$('#lab_loading').hide();
			}
		})
	}
}

function checkFile(ddfNo, fileName){
	if(confirm('파일['+fileName+']을 확인체크 하시겠습니까?')){
		$.ajax({
			url: '/dev/checkDevDocFile',
			type: 'post',
			data: {
				ddfNo: ddfNo,
			},
			success: function(data){
				if(data == 'S'){
					alert('확인체크 되었습니다.');
					reload();
				} else {
					alert('체크 오류[1]');
				}
			},
			error: function(a,b,c){
				//console.log(a,b,c)
				alert('체크 오류[2]');
			}
		})
	}
	
}

function changeDevDocCloseState(state){
	var ddNo = '${productDevDoc.ddNo}';
	var docNo = '${productDevDoc.docNo}';
	var docVersion = '${productDevDoc.docVersion}';
	var currentState = '${productDevDoc.isClose}';
	var chageStateText;
	var alertMessage = '';
	
	if(state == 0) alertMessage = '문서의 상태를 [진행중]으로 변경하시겠습니까?';
	if(state == 1) alertMessage = '결재중인 문서는 모두 상신취소됩니다. 보류하시겠습니까?';
	if(state == 2) alertMessage = '제품명에 [중단] 표시가 추가됩니다. 계속하시겠습니까?';
	
	if(currentState != state && confirm(alertMessage)){
		$.ajax({
			url: '/dev/updateDevDocCloseState',
			data: {
				ddNo: ddNo,
				docNo: docNo,
				docVersion: docVersion,
				isClose: state
			},
			success: function(data){
				if(data == 'S'){
					alert('변경되었습니다');
					reload();
				} else {
					return alert('변경 오류[1]');
				}
			},
			error: function(a,b,c){
				//console.log(a,b,c)
				return alert('변경 오류[2]');
			}
		})
	}
}

function downloadFile(ddfNo){
	location.href = '/file/downloadDevDocFile?ddfNo='+ddfNo;
}

/* function changeDispImage(ddfNo){
	console.log('changeDispImage()', ddfNo);
} */

function devDocValid(){
	var userGrade = "<%=UserUtil.getUserGrade(request)%>";
	
	if($('#devDocEditForm input[name=productName]').val().length<= 0){
		alert('제품명을 입력해주세요');
		$('#devDocEditForm input[name=productName]').focus();
		return false;
	}
	
	/* if(userGrade != 8){
		if($('#productCode_select').val().length <= 0 && $('#imNo').val().length <= 0){
			alert('제품코드를 검색 후 선택해주세요');
			$('#productCode_select').focus();
			return false;
		}
		
		if($('#reqNum_select').val().length <= 0){
			alert('품목제조보고번호를 검색 후 선택해주세요');
			$('#reqNum_select').focus();
			return false;
		}
	} */
	
	
	if($('#dialog_productType1').val().length <= 0){
		alert('제품유형을 선택해주세요');
		return false;
	}
	
	return true;
}

function updateDevDoc(){
	if(!devDocValid())
		return;
	
	var postData = {
		ddNo: $('#devDocEditForm input[name=ddNo]').val()
		,productCategoryText: $('#devDocEditForm input[name=productCategoryText]').val()
		,productName: $('#devDocEditForm input[name=productName]').val()
		,productCode: $('#devDocEditForm input[name=productCode]').val()
		,imNo: $('#devDocEditForm input[name=imNo]').val() == '' ? '0' : $('#devDocEditForm input[name=imNo]').val()
		,productCode: $('#devDocEditForm input[name=productCode]').val() == '' ? '0' : $('#devDocEditForm input[name=productCode]').val()
		,manufacturingNo: $('#devDocEditForm input[name=manufacturingNo]').val() == '' ? '0' : $('#devDocEditForm input[name=manufacturingNo]').val() 
		,manufacturingNoSeq: $('#devDocEditForm input[name=manufacturingNoSeq]').val() == '' ? '0' : $('#devDocEditForm input[name=manufacturingNoSeq]').val()
		,launchDate:$('#devDocEditForm input[name=launchDate]').val()
		,productType1: $('#devDocEditForm select[name=productType1]').val()
		,productType2: $('#devDocEditForm select[name=productType2]').val()
		,productType3: $('#devDocEditForm select[name=productType3]').val()
		,sterilization: $('#devDocEditForm select[name=sterilization]').val()
		,etcDisplay: $('#devDocEditForm select[name=etcDisplay]').val()
		,explanation: $('#devDocEditForm textarea[name=explanation]').val()
		,isNew: $('#devDocEditForm input[name=isNew]:checked').val()
	};
	
	$.ajax({
		url: '/dev/updateProductDevDoc',
		type: 'post',
		data: postData,
		success: function(data){
			if(data == 'S'){
				alert('수정되었습니다');
				reload();
			} else {
				alert('제품개발문서 수정 오류[1]');
			}
		},
		error: function(a,b,c){
			//console.log(a,b,c)
			alert('제품개발문서 수정 오류[2]');
		}
	})
}

function versionUp(){
	$('#lab_loading').show();
	$('#versionUpBtn').attr('disabled', true);
	var drNoArr = [];
	
	$('input[name^=dialog_check_design_doc]').toArray().forEach(function(element){
		if($(element).is(':checked') == true)
			drNoArr.push($(element).parent().next().text())
	});
	
	$.ajax({
		url: '/dev/versionUpDevDoc',
		type: 'post',
		data: $('#versionUpForm').serialize()+'&drNoArr='+drNoArr,
		success: function(data){
			if(data > 0){
				alert('저장되었습니다')
				changeVersion(data)
			} else {
				return alert('제품개발문서 버전업 오류[1]')
			}
			
		},
		error: function(a,b,c){
			//console.log(a,b,c)
			alert('제품개발문서 버전업 오류[2]');
		}
	})
	
	reload();
}

function callVersionUpDialog(){
	var hasMfgApproval = false;
	var hasDesignApproval = false;
	
	$('input[name=hasMfgApproval]').toArray().forEach(function(element){
		if(element.value == 'true')
			hasMfgApproval = true;
	})
	
	$('input[name=hasDesignApproval]').toArray().forEach(function(element){
		if(element.value == 'true')
			hasDesignApproval = true;
	})
	
	if(hasMfgApproval)
		return alert('결재중인 제조공정서가 있어 버젼을 올릴 수 없습니다.');
	
	if(hasDesignApproval)
		return alert('결재중인 디자인의뢰서가 있어 버젼을 올릴 수 없습니다.');
	
	var designReqDocSize = '${fn:length(designRequestDocList) == 0 ? 1 : fn:length(designRequestDocList)}';
	
	var dialogHeight = 410 + ((designReqDocSize-1)*39);
	$('#dialog_versionUp div:first').css('height', dialogHeight)
	openDialog('dialog_versionUp');
}

function openApprovalDialog(id){
	
	var isValid = checkDesignApprValid();
	if(!isValid){
		return;
	}

	if(id=='approval_design'){
		
		var tbKey = "N";
		
		var tempKey = "${productDevDoc.ddNo}";
		
		var cnt = 0;
		$("input[name=check_design_doc]").each(function(){
			if($(this).is(":checked")){
				cnt++;						
			}
		});
		
		if(cnt > 1){
			return alert("디자인의뢰서는 1개만 결재 상신 가능합니다.!");
		}
		
		$("input[name=check_design_doc]").each(function(){
			if($(this).is(":checked")){
				
				tempKey = "0";
				
				if(tbKey == "N"){
					tbKey = $(this).val();
				}else{
					tbKey = tbKey+","+$(this).val();
				}
				
			}				
		});
		
		 /*  $.ajax({
			url: '/dev/approvalRequestPopup',
			type: 'post',
			 data: {
				tbType : "designRequestDoc"
			}, 
			async : false,
			success: function(data){
				if(data.status == 'S'){
					openDialog(id);
					$("#userId1").val(data.userId);
					$("#userId3").val(data.defaultUserList[0].userId);
					$("#tbKey").val(tbKey);
					$("#tempKey").val(tempKey);
					
					$("#apprLine").empty();
					$("#apprLineSelect").empty();
					
					for(var i=0; i<data.regUserData.length; i++){
						$("#apprLine").append("<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class='s01'>기안자</span>"+data.regUserData[i].userName+"<strong>"+data.regUserData[i].titCodeName+"/"+data.regUserData[i].deptFullName+"</strong></li>");
					}

					$("#apprLine").append("<li id='designPayment1'><img src='../resources/images/icon_del_file.png' name='delImg'><span>1차 검토 </span><strong></strong></li>");
				
					for(var i=0; i<data.defaultUserList.length; i++){
						$("#apprLine").append("<li id='designPayment2'><img src='../resources/images/icon_del_file.png' name='delImg'><span >"+data.defaultUserList[i].type+"</span>"+data.defaultUserList[i].userName+"<strong>"+data.defaultUserList[i].titCodeName+"/"+data.defaultUserList[i].deptFullName+"</strong><input type='hidden' value="+data.defaultUserList[i].userId+"></li>");
					}
					
					$("#apprLine").append("<li id='designPaymentMarketing'><img src='../resources/images/icon_del_file.png' name='delImg'><span>마케팅 </span><strong></strong></li>");
				
					for(var i=0; i<data.approvalLineList.length; i++){
						$("#apprLineSelect").append("<option value"+data.approvalLineList[i].apprLineNo+">"+data.approvalLineList[i].lineName+"</option>");
					}
					
				} else {
					return alert('오류(F)');
				}
			},
			error: function(a,b,c){
				return alert('오류(http error)');
			}
		});   */
		
		$.ajax({
			url: '/dev/approvalRequestPopup',
			type: 'post',
			 data: {
				tbType : "designRequestDoc"
			}, 
			async : false,
			success: function(data){
				if(data.status == 'S'){
					openDialog(id);
					$("#deptFulName").val('');
				   	$("#titCodeName").val('');
				    $("#userId").val('');
				    $("#userName").val('');  
					$("#userIdDesignArr").val('');
					$("#userIdDesignArr").val(data.userId);
					$("#designTitle").val('');
					$("#design_comment").val('');
					$("#designKeyword").val('');
/* 						$("#userId1").val(data.userId);
						$("#userId3").val(data.defaultUserList[0].userId); */
					$("#tbKey").val(tbKey);
					$("#tempKey").val(tempKey);
					
					$("#CirculationRefLine").empty()
					
					$("#apprLine").empty();
					$("#userId5").val('');
					$("#userId6").val('');
					$("#apprLineSelect").empty();
					$(".app_line_edit .req").eq(0).val('');
					
					for(var i=0; i<data.regUserData.length; i++){
						$("#apprLine").append("<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class='s01'>기안자</span>  "+data.regUserData[i].userName+"<strong>"+"/"+data.regUserData[i].userId+"/"+data.regUserData[i].deptCodeName+"/"+data.regUserData[i].teamCodeName+"</strong><input type='hidden' value="+data.regUserData[i].userId+"></li>");
					}

					/* $("#apprLine").append("<li id='designPayment1'><img src='../resources/images/icon_del_file.png' name='delImg'><span>1차 검토 </span><strong></strong></li>");
				
					for(var i=0; i<data.defaultUserList.length; i++){
						$("#apprLine").append("<li id='designPayment2'><img src='../resources/images/icon_del_file.png' name='delImg'><span >"+data.defaultUserList[i].type+"</span>"+data.defaultUserList[i].userName+"<strong>"+data.defaultUserList[i].titCodeName+"/"+data.defaultUserList[i].deptFullName+"</strong><input type='hidden' value="+data.defaultUserList[i].userId+"></li>");
					}
					
					$("#apprLine").append("<li id='designPaymentMarketing'><img src='../resources/images/icon_del_file.png' name='delImg'><span>마케팅 </span><strong></strong></li>"); */
				
					$("label[for=apprLineSelect]").html("----결재선 불러오기----");
					$("#apprLineSelect").append("<option value=''>----결재선 불러오기----</option>");
					
					for(var i=0; i<data.approvalLineList.length; i++){
						$("#apprLineSelect").append("<option value="+data.approvalLineList[i].apprLineNo+">"+data.approvalLineList[i].lineName+"</option>");
					}
					
				} else {
					return alert('오류(F)');
				}
			},
			error: function(a,b,c){
				return alert('오류(http error)');
			}
		});
		
	}else{
		
/* 		if(!validateManufac()){
			return ;
		} */
		
		var tbKey = '';
		var companyCd = '';
		$("input[name=check_mfg_doc]").each(function(){
			if($(this).is(":checked")){
				if(tbKey == ""){
					tbKey = $(this).val();
					companyCd = $(this).siblings("input[name='hidden_mfg_cd']").val();
				}else {
					tbKey = tbKey +","+$(this).val();
					companyCd = companyCd + ","+$(this).siblings("input[name='hidden_mfg_cd']").val();
				}
			}	
		});
			
		
		if(tbKey == ""){
			return alert("상신하실 제조공정서를 선택해주세요.");
		}
		
		$.ajax({
			url: '/dev/disableStr?tbKey='+tbKey,
			type: 'POST',
			async:false,
			success: function(data){
				if(data.status=='S'){
					var list = data.list;
					
					for(var i=0; i<list.length; i++){
						
						
						var stateStr = "";
						
						if(list[i].state == '0'){
							stateStr = "등록";
						}else if(list[i].state == '1'){
							stateStr = "승인";
						}else if(list[i].state == '2'){
							stateStr = "반려";
						}else if(list[i].state == '3'){
							stateStr = "결재중";
						}else if(list[i].state == '4'){
							stateStr = "ERP반영완료";
						}else if(list[i].state == '5'){
							stateStr = "ERP반영오류";
						}else if(list[i].state == '6'){
							stateStr = "사용중지";
						}else if(list[i].state == '7'){
							stateStr = "임시저장";
						}
						
						if(list[i].docType == "E"){
							alert("본 문서(문서번호:"+list[i].dNo+")는 엑셀로 업로드 제조공정서 이므로 결재 상신을 할 수 없습니다.");
							return;
						}else if(list[i].state=="1" || list[i].state=="3" || list[i].state=="4" || list[i].state=="5" || list[i].state=="6" || list[i].state=="7"){
							alert("본 문서(문서번호:"+list[i].dNo+")는 "+stateStr+" 상태이므로 결재상신을 할수 없습니다.");
							return;
						}
						else if(!hasAuthority(data.userId,list[i].regUserId,data.grade,list[i].hasAuthorityCnt)){
							alert("본 문서(문서번호:"+list[i].dNo+")의 작성자가 아니므로 결재상신을 할 수 없습니다.");
							return;
						}
						else{
							if("1" == list[i].subProdCnt){
								
								var sumExcRate = parseFloat(list[i].sumExcRate).toFixed(3);
								
								var sumIncRate = parseFloat(list[i].sumIncRate).toFixed(3);
								
								if(sumExcRate != '100.000' || sumIncRate != '100.000' ){
									alert("본 문서(문서번호:"+list[i].dNo+")는 표시사항 배합비의 합계가 100이 아니므로 결재 상신을 할수 없습니다. * 백분율:" +sumExcRate+" *급수포함: "+sumIncRate);
									return;
								}
								
							}
						} 
					}
					
					var existFile1 = $(".con_file ul:eq(0) dd:eq(1) li").length;
					
					var existFile6 = $(".con_file ul:eq(0) dd:eq(0) li").length;
					
					if(existFile1 == 0 || existFile6 == 0){	
						return alert("<1. 포장지시안>과 <4. 제품이미지> 파일 첨부가 완료된 후에 \n결재상신 가능합니다.");
					} 
					
					$("#tbKeyManu").val(tbKey);
					
					$.ajax({
						url: '/dev/approvalRequestPopup',
						type: 'post',
						data: {
							tbType: "manufacturingProcessDoc"
						}, 
						async : false,
						success: function(data){
							if(data.status == 'S'){
								if(data.grade == '6'){
									return alert("권한이 없습니다.");
								}else{
									openDialog(id);			
									$("#deptFulName").val('');
								   	$("#titCodeName").val('');
								    $("#userId").val('');
								    $("#userName").val('');  
									$("#userIdManuArr").val('');
									$("#userIdManuArr").val(data.userId);
									$("#manuTitle").val('');
									$("#launchDateManu").val('');
									
									$("#CirculationRefLineManu").empty();
									$("#userId7Manu").val('');
									$("#userId8Manu").val('');
									$("#apprLineManu").empty();
									$("#apprLineSelectManu").empty();
									$("#manufacKeyword").val('');
									$(".app_line_edit .req").eq(1).val('');
									$("#ManuCompanyCd").val(companyCd);
									
									for(var i=0 ;i<data.regUserData.length;i++){
										$("#apprLineManu").append("<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class='s01'>기안자</span>  "+data.regUserData[i].userName+"<strong>"+"/"+data.regUserData[i].userId+"/"+data.regUserData[i].deptCodeName+"/"+data.regUserData[i].teamCodeName+"</strong><input type='hidden' value="+data.regUserData[i].userId+"></li>");
									}
									
									$("label[for=apprLineSelectManu]").html("----결재선 불러오기----");
									$("#apprLineSelectManu").append("<option value=''>----결재선 불러오기----</option>");
									
									for(var i=0; i<data.approvalLineList.length; i++){
										$("#apprLineSelectManu").append("<option value="+data.approvalLineList[i].apprLineNo+">"+data.approvalLineList[i].lineName+"</option>");
									}
								}
								
							}
							else {
								return alert('오류(F)');
							}
						},
						error: function(a,b,c){
							return alert('오류(http error)');
						}
					}); 
					
				} else {
					alert('오류[1]');
					return;
				}
			},
			error: function(a,b,c){
				alert('오류[2]');
				return;
			}
			
		});
		
		
/* 			var existFile1 = $(".con_file ul:eq(0) dd:eq(1) li").length;
			
			var existFile6 = $(".con_file ul:eq(0) dd:eq(0) li").length; */
		
	/* 	
	주석 풀것..
	if(existFile1 == 0 || existFile6 == 0){
			
			return alert("<1. 포장지시안>과 <4. 제품이미지> 파일 첨부가 완료된 후에 \n결재상신 가능합니다.");
		} */
		
/* 			var tbKey = "";
			
			$("input[name=check_mfg_doc]").each(function(){
				if($(this).is(":checked")){
					if(tbKey == ""){
						tbKey = $(this).val();		
					}else {
						tbKey = tbKey +","+$(this).val();
					}
				}	
			}); */
		
	/* 	$("#tbKeyManu").val(tbKey); */
		
		
		
		/* $.ajax({
			url: '/dev/approvalRequestPopup',
			type: 'post',
			data: {
				tbType: "manufacturingProcessDoc"
			}, 
			async : false,
			success: function(data){
				if(data.status == 'S'){
					if(data.grade == '6'){
						alert("<1. 포장지시안>과 <4. 제품이미지> 파일 첨부가 완료된 후에 \n결재상신 가능합니다.");
					}else{
						openDialog(id);
						$("#userId1Manu").val(data.userId);
						
						$("#apprLineManu").empty();
						$("#apprLineSelectManu").empty();
						
						for(var i=0 ;i<data.regUserData.length;i++){
							$("#apprLineManu").append("<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class='s01'> 기안자</span>"+data.regUserData[i].userName+"<strong>"+data.regUserData[i].titCodeName+"/"+data.regUserData[i].deptFullName+"</strong></li>");
						}
						
						$("#apprLineManu")
						.append("<li id='manufacPayment1'><img src='../resources/images/icon_del_file.png'><span>합의1</span><strong></strong></li>")
						.append("<li id='manufacPayment2'><img src='../resources/images/icon_del_file.png'><span>합의2</span><strong></strong></li>")
						.append("<li id='manufacPaymentLeader'><img src='../resources/images/icon_del_file.png'><span>팀장</span><strong></strong></li>")
						.append("<li id='manufacPaymentDirector'><img src='../resources/images/icon_del_file.png'><span>연구소장</span> <strong></strong></li>")
						.append("<li id='manufacPaymentParter'><img src='../resources/images/icon_del_file.png'><span>파트장</span><strong></strong></li>");
						
						for(var i=0; i<data.approvalLineList.length; i++){
							$("#apprLineSelectManu").append("<option value"+data.approvalLineList[i].apprLineNo+">"+data.approvalLineList[i].lineName+"</option>");
						}
					}
					
				}
				else {
					return alert('오류(F)');
				}
			},
			error: function(a,b,c){
				return alert('오류(http error)');
			}
		}); */
		/* $.ajax({
			url: '/dev/approvalRequestPopup',
			type: 'post',
			data: {
				tbType: "manufacturingProcessDoc"
			}, 
			async : false,
			success: function(data){
				if(data.status == 'S'){
					if(data.grade == '6'){
						alert("권한이 없습니다.");
					}else{
						openDialog(id);			
						$("#userIdManuArr").val('');
						$("#userIdManuArr").val(data.userId);
						$("#manuTitle").val('');
						$("#launchDateManu").val('');
						
						$("#CirculationRefLineManu").empty();
						$("#userId7Manu").val('');
						$("#userId8Manu").val('');
						$("#apprLineManu").empty();
						$("#apprLineSelectManu").empty();
						
						for(var i=0 ;i<data.regUserData.length;i++){
							$("#apprLineManu").append("<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class='s01'> 기안자</span>"+data.regUserData[i].userName+"<strong>"+data.regUserData[i].titCodeName+"/"+data.regUserData[i].deptFullName+"</strong><input type='hidden' value="+data.regUserData[i].userId+"></li>");
						}
						
						for(var i=0; i<data.approvalLineList.length; i++){
							$("#apprLineSelectManu").append("<option value="+data.approvalLineList[i].apprLineNo+">"+data.approvalLineList[i].lineName+"</option>");
						}
					}
					
				}
				else {
					return alert('오류(F)');
				}
			},
			error: function(a,b,c){
				return alert('오류(http error)');
			}
		});  */
		
	}
	
}

function hasAuthority(userId,regUserId,grade,hasAuthorityCnt){
	
	if(grade == '8'){
		return true;
	}else if(userId == regUserId){
		return true;
	}else if(hasAuthorityCnt > 0){
		return true;
	}else{
		return false;
	}
	
}

function checkDesignApprValid(){
	var drNoCnt = $('input[type=checkbox][name=check_design_doc]:checked').length;
	
	if(drNoCnt == 0){
		alert('선택된 디자인의뢰서가 없습니다. 디자인의뢰서를 선택해주세요');
		$('#lab_loading').hide();
		return false;
	}
	if(drNoCnt > 1){
		alert('하나의 디자인의뢰서만 선택해주세요.');
		$('#lab_loading').hide();
		return false;
	}
	
	var drTargetObj = $('input[type=checkbox][name=check_design_doc]:checked');
	var state = drTargetObj.siblings('input[name=designReqDocState]').val();
	var designReqDocregUserId = drTargetObj.siblings('input[name=designReqDocregUserId]').val();
	var loginUserId = '${userUtil:getUserId(pageContext.request)}';
	
	if(loginUserId != designReqDocregUserId){
		alert("본 문서의 작성자가 아니므로 결재 상신을 할 수 없습니다.");
		return false;
	}
	
	if(state == '1'){
		alert("이미 검토중입니다.");
		$(obj).prop("checked",false);
		return false;
	} else if(state == '2'){
		alert("검토완료된 문서입니다.");
		$(obj).prop("checked",false);
		return false;
	}
	
	return true;
}

function targetCheck(obj,state,regUserId){
	
	var userId = "${userId}";
	
	if(state == '1'){
		alert("이미 검토중입니다.");
		$(obj).prop("checked",false);
		return;
	} else if(state == '2'){
		alert("검토완료된 문서입니다.");
		$(obj).prop("checked",false);
		return;
	}
	
	if(userId != regUserId){
		alert("본 문서의 작성자가 아니므로 결재 상신을 할 수 없습니다.");
		$(obj).prop("checked",false);
		return;
	}
	
   var cnt = 0;
	$("input[name=check_design_doc]").each(function(){
		if($(this).is(":checked")){
			cnt++;						
			if(cnt > 1){
				alert("이미 선택된 건이 있습니다.");
				$(this).prop("checked", false);
				return;
			}
		}
	});
	
}


function disableStr(obj,state,docType,subProdCnt,sumExcRate,sumIncRate){
	
	return;

	var stateStr = "";
	
	var hasAuthority = "${hasAuthority}"
	
	if(state == "0"){
		stateStr = "등록";
	}else if(state == "1"){
		stateStr = "승인";
	}else if(state == "2"){
		stateStr = "반려";
	}else if(state == "3"){
		stateStr = "결재중";
	}else if(state == "4"){
		stateStr = "ERP반영완료";
	}else if(state == "5"){
		stateStr = "ERP반영오류";
	}else if(state == "6"){
		stateStr = "사용중지";
	}else if(state == "7"){
		stateStr = "임시저장";
	}
	
	if(docType == "E"){
		alert("본 문서는 엑셀로 업로드 제조공정서 이므로 결재 상신을 할 수 없습니다.");
		$(obj).prop("checked",false);
	} else if(state=="1" || state=="3" || state=="4" || state=="5" || state=="6" || state=="7"){
		alert("본 문서는 "+stateStr+" 상태이므로 결재상신을 할수 없습니다.");
		$(obj).prop("checked",false);
	} else if(hasAuthority == "false"){
		alert("본 문서의 작성자가 아니므로 결재상신을 없습니다.");
		$(obj).prop("checked",false);
	} else{
		
		if("1"==subProdCnt){
			
			if(sumExcRate != '100.000' || sumIncRate != '100.000' ){
				alert("본 문서는 표시사항 배합비의 합계가 100이 아니므로 결재 상신을 할수 없습니다. * 백분율:" +sumExcRate+" *급수포함: "+sumIncRate);
				$(obj).prop("checked",false);
			}
		}
	}
}

function loadCodeList( groupCode, objectId ) {
	var URL = "../common/codeListAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"groupCode":groupCode
		},
		dataType:"json",
		async:false,
		success:function(data) {
			var list = data.RESULT;
			$("#"+objectId).removeOption(/./);
			$("#"+objectId).addOption("", "전체", false);
			$("#label_"+objectId).html("전체");
			$.each(list, function( index, value ){ //배열-> index, value
				$("#"+objectId).addOption(value.itemCode, value.itemName, false);
			});
			
		},
		error:function(request, status, errorThrown){
			$("#"+objectId).removeOption(/./);
			alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}			
	});
}

function loadProductType( e, grade, objectId ) {
	var URL = "../common/productTypeListAjax";
	var groupCode = "PRODCAT"+grade;
	var codeValue = e.target.value;
	
	$(e.target).parent().parent().children().toArray().forEach(function(prodTypeDiv, index){
		if(index >= (Number(grade)-1)) $(prodTypeDiv).hide();
	})
	
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"groupCode":groupCode,
			"codeValue":codeValue
		},
		dataType:"json",
		async:false,
		success:function(data) {
			var list = data.RESULT;
			$("#"+objectId).removeOption(/./);
			$("#"+objectId).addOption("", "전체", false);
			$("#label_"+objectId).html("전체");
			$.each(list, function( index, value ){ //배열-> index, value
				$("#"+objectId).addOption(value.itemCode, value.itemName, false);
			});
			if(list.length > 0) $(e.target).parent().next().show();
		},
		error:function(request, status, errorThrown){
			element.removeOption(/./);
			$("#li_"+element.prop("id")).hide();
			alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}			
	});
}

function getPrdCode(e){
	$('#lab_loading').show();
	$('#prdCodeDiv').hide();
	e.preventDefault();
	
	var productCode = $('#productCode').val();
	if(productCode.length != 6){
		alert('제품코드 6자리를 입력해주세요');
		$('#lab_loading').hide();
		return;
	}
	
	var searchValue = $('#productCode').val();
	$.ajax({
		url: '/data/getMaterialList',
		type: 'post',
		dataType: 'json',
		data: {
			searchValue: searchValue
		},
		success: function(data){
			if(data.length <= 0){
				alert('제품코드와 일치하는 정보를 찾을 수 없습니다.');
				$('#lab_loading').hide();
				return;
			}
			
			$('#productCode_select').empty();
			$('#productCode_select').append('<option value="">선택</option>')
			$('#label_productCode_select').text('선택');
			data.forEach(function(mat){
				var text = '[' + mat.company + '-'+mat.plant + '] ' + mat.name + '(' + mat.regDate +')';
				$('#productCode_select').append('<option value="'+mat.imNo+','+mat.sapCode+'">' + text + '</option>')
			})
			
			$('#prdCodeDiv').show();
			$('#lab_loading').hide();
		},
		error: function(a,b,c){
			//console.log(a,b,c)
			alert('제품코드 검색 실패[2] - 시스템 담당자에게 문의하세요');
			$('#lab_loading').hide();
		}
	})
}

// 홍원석

function changePrdCode(e){
	var imNo = e.target.value.split(',')[0];
	var sapCdoe = e.target.value.split(',')[1];
	var name = $('#productCode_select option:selected').text();
	
	var startNdx = $('#productCode_select option:selected').text().indexOf('] ');
	var endNdx = $('#productCode_select option:selected').text().lastIndexOf('(');
	var name = name.substr(startNdx+2, endNdx-(startNdx+2));
	
	$('#productCode').val(sapCdoe);
	$('#imNo').val(imNo);
	$('input[name=productName]').val(name)
}

function getMfgNo(e){
	$('#lab_loading').show();
	$('#reqDiv').hide();
	e.preventDefault();
	
	var mfgNo = $('input[name=manufacturingNo]').val();
	$.ajax({
		url: '/manufacturingNo/getMfgNoList',
		type: 'post',
		dataType: 'json',
		data: {
			mfgNo: mfgNo
		},
		success: function(data){
			if(data.length <= 0){
				alert('품목제조보고 번호를 찾을 수 없습니다.');
				$('#lab_loading').hide();
				return;
			}
			
			$('#reqNum_select').empty();
			$('#reqNum_select').append('<option value="">선택</option>')
			data.forEach(function(row){
				var text = '[' + row.manufacturingNo + '] ' + row.companyCode + ' ' + row.manufacturingName;
				$('#reqNum_select').append('<option value="'+ row.seq+','+ row.manufacturingNo+'">' + text + '</option>')
			})
			
			$('#reqDiv').show();
			$('#lab_loading').hide();
		},
		error: function(a,b,c){
			//console.log(a,b,c)
			alert('품목제조보고번호 검색 실패[2] - 시스템 담당자에게 문의하세요');
			$('#lab_loading').hide();
		}
	})
}

function changeRegNum(e){
	var manufacturingNo = e.target.value.split(',')[1];
	var seq = e.target.value.split(',')[0];
	
	$('#reqNum').val(manufacturingNo);
	$('#manufacturingNoSeq').val(seq);
}

function openStateDialog(state){
	var docNo = '${productDevDoc.docNo}';
	var docVersion = '${productDevDoc.docVersion}';
	var stateText = ( (state == 2) ? '보류' : (state == 1) ? '제품중단' : '진행(생산)중' );
	
	$('#changeStateForm input[name=isClose]').val(state);
	
	if(confirm('제품개발문서의 상태를 ['+stateText+'](으)로 변경하시겠습니까?')){
		if(state == 0){
			$.ajax({
				url: '/dev/updateDevDocCloseState',
				type: 'post',
				data: $('#changeStateForm').serialize(),
				success:function(data){
					if(data == 'S'){
						alert('상태가 변경되었습니다');
						reload();
						return;
					} else {
						return ('상태 변경 오류[1]');
					}
				},
				error: function(a,b,c){
					//console.log(a,b,c)
					return ('상태 변경 오류[2]');
				}
			})
		}
		
		if(state == 1 || state == 2){
			openDialog('dialog_state');
		}
	}
}

function changeDevDocState(state){
	$.ajax({
		url: '/dev/updateDevDocCloseState',
		type: 'post',
		data: $('#changeStateForm').serialize(),
		success:function(data){
			if(data == 'S'){
				alert('상태가 변경되었습니다');
				reload();
				return;
			} else {
				alert('상태변경 오류');
				return ('상태 변경 오류[1]');
			}
		},
		error: function(a,b,c){
			//console.log(a,b,c)
			return ('상태 변경 오류[2]');
		}
	})
}

function changeApprLine(obj){
	
	var obj =  $(obj);

	var selectId = obj.attr("id");
	
	var apprLineNo = $("#"+selectId).val();
	
	$.ajax({
		url: '/approval/getDetailApprovalLineList',
		type: 'post',
		data: {
			apprLineNo: apprLineNo
		}, 
		async : false,
		success: function(data){
			if(data.status == 'S'){
				
				var length = '';
				
				var approvalLineList = data.approvalLineList;
				
				var approvalLineAppr = [];
				
				var approvalLineRef = [];
				
				var html = "";
				
				if(selectId == 'apprLineSelect'){
					
					length = $("#apprLine li").length;
					
					for(var i=1; i<length; i++){
						$("#apprLine li").eq(1).remove();
					} 
					
					var userIdDesignArr = $("#userIdDesignArr").val().split(",");
					
					$("#userIdDesignArr").val(userIdDesignArr[0]);
					
					$("#CirculationRefLine").empty();
					$("#userId5").val('');
					$("#userId6").val('');
					
					for(var i=0; i<approvalLineList.length; i++){
						if(approvalLineList[i].apprType !='R' && approvalLineList[i].apprType !='C'){
							approvalLineAppr.push(approvalLineList[i]);
						}else{
							approvalLineRef.push(approvalLineList[i]);
						}
					}
					
					var newUserDesignIdArr =  $("#userIdDesignArr").val().split(",");
					
					
					for(var i=0; i<approvalLineAppr.length; i++){
						
						html = '<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>'+(i+1)+'차 결재</span>  '+approvalLineAppr[i].userName+'<strong>'+"/"+approvalLineAppr[i].targetUserId+"/"+approvalLineAppr[i].deptCodeName+'/'+approvalLineAppr[i].teamCodeName+'</strong><input type="hidden" value='+approvalLineAppr[i].targetUserId+'></li>';
						
						$("#apprLine").append(html);
						
						newUserDesignIdArr.push(approvalLineAppr[i].targetUserId);
					}
					
					$("#userIdDesignArr").val(newUserDesignIdArr.join(","));
					
					var newUserId5Arr = [];
					
					var newUserId6Arr = [];
					
					for(var i=0; i<approvalLineRef.length; i++){
						
						if(approvalLineRef[i].apprType == 'R'){
							html = '<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>참조</span>  '+approvalLineRef[i].userName+'<strong>'+'/'+approvalLineRef[i].targetUserId+"/"+approvalLineRef[i].deptCodeName+'/'+approvalLineRef[i].teamCodeName+'</strong><input type="hidden" name="userId" value='+approvalLineRef[i].targetUserId+'><input type="hidden" name="apprType" value="R"></li>';
							newUserId5Arr.push(approvalLineRef[i].targetUserId);
						
						}else{
							html = '<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>회람</span>  '+approvalLineRef[i].userName+'<strong>'+'/'+approvalLineRef[i].targetUserId+"/"+approvalLineRef[i].deptCodeName+'/'+approvalLineRef[i].teamCodeName+'</strong><input type="hidden" name="userId" value='+approvalLineRef[i].targetUserId+'><input type="hidden" name="apprType" value="C"></li>';
							newUserId6Arr.push(approvalLineRef[i].targetUserId);
						}
						
						$("#CirculationRefLine").append(html);
							
					}
					
					$("#userId5").val(newUserId5Arr.join(","));
					
					$("#userId6").val(newUserId6Arr.join(","));
					
				}else{
					
					length = $("#apprLineManu li").length;
					
					for(var i=1; i<length; i++){
						$('#apprLineManu li').eq(1).remove();
					} 
					
					var userIdManuArr = $("#userIdManuArr").val().split(",");
					
					$("#userIdManuArr").val(userIdManuArr[0]);
					
					$("#CirculationRefLineManu").empty();
					$("#userId7Manu").val('');
					$("#userId8Manu").val('');
					
					for(var i=0; i<approvalLineList.length; i++){
						if(approvalLineList[i].apprType !='R' && approvalLineList[i].apprType !='C'){
							approvalLineAppr.push(approvalLineList[i]);
						}else{
							approvalLineRef.push(approvalLineList[i]);
						}
					}
					
					var newUserManuIdArr =  $("#userIdManuArr").val().split(",");
					
					for(var i=0; i<approvalLineAppr.length; i++){
						
						html = '<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>'+(i+1)+'차 결재</span>  '+approvalLineAppr[i].userName+'<strong>'+'/'+approvalLineAppr[i].targetUserId+'/'+approvalLineAppr[i].deptCodeName+'/'+approvalLineAppr[i].teamCodeName+'</strong><input type="hidden" value='+approvalLineAppr[i].targetUserId+'></li>';
						
						$("#apprLineManu").append(html);
						
						newUserManuIdArr.push(approvalLineAppr[i].targetUserId);
					}
					
					$("#userIdManuArr").val(newUserManuIdArr.join(","));
					
					var newUserId7ManuArr = [];
						
					var newUserId8ManuArr = [];
					
					for(var i=0; i<approvalLineRef.length; i++){
						
						if(approvalLineRef[i].apprType == 'R'){
							html = '<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>참조</span>  '+approvalLineRef[i].userName+'<strong>'+'/'+approvalLineRef[i].targetUserId+'/'+approvalLineRef[i].deptCodeName+'/'+approvalLineRef[i].teamCodeName+'</strong><input type="hidden" name="userId" value='+approvalLineRef[i].targetUserId+'><input type="hidden" name="apprType" value="R"></li>';
							newUserId7ManuArr.push(approvalLineRef[i].targetUserId);
						}else{
							html = '<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>회람</span>  '+approvalLineRef[i].userName+'<strong>'+'/'+approvalLineRef[i].targetUserId+'/'+approvalLineRef[i].deptCodeName+'/'+approvalLineRef[i].teamCodeName+'</strong><input type="hidden" name="userId" value='+approvalLineRef[i].targetUserId+'><input type="hidden" name="apprType" value="C"></li>';
							newUserId8ManuArr.push(approvalLineRef[i].targetUserId);
						}
						
						$("#CirculationRefLineManu").append(html);
					}
					
					$("#userId7Manu").val(newUserId7ManuArr.join(","));
					
					$("#userId8Manu").val(newUserId8ManuArr.join(","));
					
				}
				

			}
			else {
				return alert('오류(F)');
			}
		},
		error: function(a,b,c){
			return alert('오류(http error)');
		}
	});
	
}

function updateBOM(){
	$('#lab_loading').show();
	var selectedMfgDNoArr = [];
	var selectedStateArr = [];
	var productCode = '${productDevDoc.productCode}';
	
	var mfgBody = $('#mfgTable').children('tbody');
	mfgBody.children('tr').children('td').children('input[type=checkbox]').toArray().forEach(function(input){
		if($(input).is(':checked')){
			selectedMfgDNoArr.push($(input).parent().next().children('a').text())
			selectedStateArr.push($(input).next().next().next().val());
		}
	})
	
	if(productCode == null || productCode == '0'){
		alert('필수값 입력 오류: 제품코드를 입력 하지 않았습니다.');
		$('#lab_loading').hide();
		return;
	}
	
	
	if(selectedMfgDNoArr.length <= 0){
		alert('선택된 제조공정서가 없습니다. 제조공정서를 선택해주세요');
		$('#lab_loading').hide();
		return 
	} else {
		/* 
		if(selectedMfgDNoArr.length > 1){
			return alert('하나의 제조공정서만 선택해주세요.');
		}
		 */
		var count = 0;
		selectedStateArr.forEach(function(item){
			// BOM반영 가능 state값  = 1: 승인, 4: ERP반영 완료, 5: ERP반영 오류
			if( item != '1' && item != '4' && item != '5' ) {
				count++;
			}
		});
		
		if( count > 0 ) {
			//alert("BOM 반영을 할 수 없습니다.");
			alert("BOM 반영을 할 수 없는 상태의 제조공정서가 포함되어 있습니다.")
			$('#lab_loading').hide();
		} else {
			$.ajax({
				url: '/dev/updateBOM?dNoList='+selectedMfgDNoArr,
				type: 'POST',
				dataType: 'JSON',
				success: function(data){
					var alertStr = "";
					
					if(data.header == null){
						alert("BOM등록 오류");
						reload();
						
						$('#lab_loading').hide();
						return;
					}
					
					if(data.header.resultFlag == 'S'){
						if(data.item.resultFlag == 'S' || data.item.resultFlag == 'X'){
							alertStr = '등록되었습니다.';
							if(data.item.resultFlag == 'X'){
								alertStr += '\n(세부항목은 변경되지 않았습니다)'
							}
						} else {
							alertStr = 'BOM등록 오류['+data.item.resultFlag+'] '+data.item.resultMessage;
							if(data.item.itemErrMessage != undefined){
								alertStr += "\n\n" + data.item.itemErrMessage;
							}
						}
					} else {
						alertStr = 'BOM등록 오류['+data.header.resultFlag+'] '+data.header.resultMessage;
					}
					
					alert(alertStr);
					reload();

					$('#lab_loading').hide();
				},
				error: function(a,b,c){
					//console.log(a,b,c)
					alert('BOM업데이트 오류[2]');
					reload();
					
					$('#lab_loading').hide();
					return;
				}
			});
		}
	}
}

function deleteDevDoc(){
	if(!confirm('현재버전의 제품개발문서를 삭제하시겠습니까?')){
		return;
	}
	var ddNo = '${productDevDoc.ddNo}';
	var docNo = '${productDevDoc.docNo}';
	var docVersion = '${productDevDoc.docVersion}';
	
	$.ajax({
		url: '/dev/deleteProductDevDoc',
		type: 'post',
		data: {
			ddNo: ddNo,
			docNo: docNo,
			docVersion: docVersion
		},
		success: function(data){
			//console.log(data);
			if(data == 'S'){
				alert('정상적으로 삭제되었습니다');
				
				var docVersionList = '${docVersionList}';
				docVersionList = docVersionList.replace('[','').replace(']','').replace(/"/g,'').split(',');
				if(docVersionList.length > 1){
					changeVersion(docVersionList[1].trim());
				} else {
					location.href = '/dev/productDevDocList';
				}
			} else {
				return alert('제품개발문서 삭제오류[1]')
			}
		},
		error: function(a,b,c){
			//console.log(a,b,c)
			return alert('제품개발문서 삭제오류[2]')
		}
	})
}

function deleteDesignReqDoc(drNo){
	if(!confirm('디자인의뢰서[문서번호:'+drNo+']를 삭제하시겠습니까?')){
		return;
	}
	
	$.ajax({
		url: '/dev/deleteDesignRequestDoc',
		type: 'post',
		data: {
			drNo: drNo
		},
		success: function(data){
			if(data == 'S'){
				alert('정상적으로 삭제되었습니다');
				reload();
			} else {
				return alert('제품개발문서 삭제오류[1]')
			}
		},
		error: function(a,b,c){
			//console.log(a,b,c)
			return alert('제품개발문서 삭제오류[2]')
		}
	})
}

function editCommentMode(e, cNo, dNo){
	var comment = $(e.target).parent().children('span.comment_data').html().replace(/<br>/g, '\n');
	$(e.target).parent().parent().hide();
	
	var editElement = '<div class="comment_obj2">';
	editElement += '<div class="insert_comment">';
	editElement += '<table style="width: 738px; margin-left: 2px;">';
	editElement += '<tr>';
	editElement += '<td><textarea style="width: 100%; height: 50px; background-color: #fffeea;" placeholder="의견을 입력하세요">'+comment+'</textarea></td>';
	editElement += '<td width="81px"><button style="width: 95%; height: 52px; margin-top: -2px; font-size: 13px;" onclick="updateComment(event, \''+cNo+'\', \''+dNo+'\')">수정</button></td>';
	editElement += '<td width="80px"><button style="width: 100%; height: 52px; margin-top: -2px; font-size: 13px;" onclick="editCommentCancel(event)">수정취소</button></td>';
	editElement += '</tr>';
	editElement += '</table>';
	editElement += '</div>';
	editElement += '</div>';
	
	$(e.target).parent().parent().after(editElement);
}

function updateComment(e, cNo, dNo){
	$('#lab_loading').show();
	var comment = $(e.target).parent().prev().children('textarea').val();
	
	$.ajax({
	    url: '/comment/updateComment',
	    type: 'post',
	    data: {
	        cNo: cNo,
	        dNo: dNo,
	        comment: comment,
	    },
	    success: function(data){
	    	if(data == 'S'){
	    		alert('수정되었습니다.');
	    		openComment(dNo);
	    	} else {
	    		alert('수정 오류[1]');
	    	}
	    },
	    error: function(a,b,c){
	    	//console.log(a,b,c);
	    	return alert('수정 오류[2]');
	    },
	    complete: function(){
	    	$('#lab_loading').hide();
	    }
	})
	
}

function editCommentCancel(e){
	$(e.target).parent().parent().parent().parent().parent().parent().prev().show();
	$(e.target).parent().parent().parent().parent().parent().parent().remove();
}

function openComment(dNo){
	// 수정내역
	/* 
	var tr_id = 'mgf_tr_'+dNo;

	var userGrade = $('#userGrade').val();
	var isAdmin = $('#isAdmin').val()
	
	var currentUserId = '${userId}';
	var tbType = 'manufacturingProcessDoc';
	$('#lab_loading').show();
	openDialog('dialog_comment');
	
	$('#commentListDiv').empty();
	$('#commentTbType').val(tbType);
	$('#commentTbKey').val(dNo);
	
	$.ajax({
	    url: '/comment/getCommentList',
	    type: 'post',
	    dataType: 'json',
	    data: {
	        tbKey: dNo,
	        tbType: tbType,
	    },
	    success: function(data){
	        if(data.length>0){
	        	$('#layerCommentCnt').text('의견('+data.length+')');
	        	$('#'+tr_id+' td:last span.badgeCnt').text(data.length)
		        data.forEach(function(comment){
			        var commentElement = '<div class="comment_obj2">';
			        commentElement += '<span class="comment_id">'+comment.userName+'</span>';
			        commentElement += '<span class="comment_date"> '+comment.regDate;
			        if(userGrade == '3' || isAdmin == 'Y'){
			        //if(currentUserId == comment.reguserId){
				        commentElement += '&nbsp;&nbsp&nbsp;&nbsp;<a href="javascript:;" onclick="editCommentMode(event, \''+comment.cNo+'\', \''+dNo+'\')"><img src="/resources/images/icon_doc03.png"> 수정</a>';
				        commentElement += ' | <a href="javascript:;" onclick="deleteComment(\''+comment.cNo+'\', \''+dNo+'\')"><img src="/resources/images/icon_doc04.png"> 삭제</a>';
			        }
			        commentElement += '<span class="comment_data">'+comment.comment.replace(/(?:\r\n|\r|\n)/g, '<br />')+'</span>';
			        commentElement += '</div>';
			        $('#commentListDiv').append(commentElement);
		        })
	        } else {
	        	var commentElement = '<div class="comment_obj2"><span class="comment_data">입력된 수정내역이 없습니다.</span></div>';
	        	$('#commentListDiv').append(commentElement);
	        }
	        
	    },
	    error: function(a,b,c){
	        //console.log(a,b,c)
	        alert('코멘트 불러오기 실패[2] - 시스템 담당자에게 문의하세요');
	    }
	    , complete: function(){
	    	$('#lab_loading').hide();
	    }
	})
	 */
	
	
	var url = '/comment/commentPopup';
	url += "?dNo="+dNo;
	url += "&tbType=manufacturingProcessDoc";
			
	var popupName = 'commentPopup';
	var w=1100;
	var h=650;
	var winl = (screen.width-w)/2;
	var wint = (screen.height-h)/2;
	var option ='height='+h+',';
	option +='width='+w+',';
	option +='scrollbars=yes,';
	option +='resizable=no';
	
	//window.open(url, popupName, option);
	window.open(url, '', option);
}

function deleteComment(cNo, dNo){
	if(!confirm('선택한 의견을 정말 삭제하시겠습니까?')){
		return;
	}
	$('#lab_loading').show();
	var dNo = $('#commentTbKey').val();
	
	$.ajax({
	    url: '/comment/deleteComment',
	    type: 'post',
	    data: { cNo: cNo, dNo: dNo},
	    success: function(data){
	    	if(data == 'S'){
	    		$('#commentText').val('');
	    		alert('삭제되었습니다.');
	    		openComment(dNo);
	    	} else {
	    		alert('삭제 오류[1]');
	    	}
	    },
	    error: function(a,b,c){
	    	//console.log(a,b,c);
	    	return alert('삭제 오류[2]');
	    },
	    complete: function(){
	    	$('#lab_loading').hide();
	    }
	})
}

function addComment(){
	$('#lab_loading').show();
	var dNo = $('#commentTbKey').val();
	var docNo = '${productDevDoc.docNo}';
	var docVersion = '${productDevDoc.docVersion}';
	
	$.ajax({
	    url: '/comment/addComment',
	    type: 'post',
	    data: {
	        tbType: $('#commentTbType').val(),
	        tbKey: dNo,
	        comment: $('#commentText').val(),
	        docNo: docNo,
	        docVersion : docVersion
	    },
	    success: function(data){
	    	if(data == 'S'){
	    		$('#commentText').val('');
	    		alert('등록되었습니다.');
	    		openComment(dNo);
	    	} else {
	    		alert('등록 오류[1]');
	    	}
	    },
	    error: function(a,b,c){
	    	//console.log(a,b,c);
	    	return alert('등록 오류[2]');
	    },
	    complete: function(){
	    	$('#lab_loading').hide();
	    }
	})
}

function openDispPopup(dNo, docProdName){
	$('#selectedDocProdName').val(docProdName);
	
	var url = '/dev/dispPopup';
	url += "?dNo="+dNo;
	url += "&docProdName="+encodeURIComponent(docProdName);
	/* 
	if(confirm("백분율 출력은 '확인' 급수포함 출력은 '취소'를 선택해주세요.")){
		url += "&type=exc";
	} else {
		url += "&type=inc";
	}
	 */		
	var popupName = 'dispPopup';
	var w=1100;
	var h=650;
	var winl = (screen.width-w)/2;
	var wint = (screen.height-h)/2;
	var option ='height='+h+',';
	option +='width='+w+',';
	option +='scrollbars=yes,';
	option +='resizable=no';
	
	//window.open(url, popupName, option);
	window.open(url, '', option);
}

function preView( tbType, tbKey, docNo, docVersion ) {
	var url = "";
	var mode = "";
	if( tbType == 'manufacturingProcessDoc' ) {
		url = "/dev/manufacturingProcessDetailPopup?tbKey="+tbKey+"&tbType="+tbType+"&docNo="+docNo+"&docVersion="+docVersion;
		mode = "width=1100, height=650, left=100, top=50, scrollbars=yes";
	} else if( tbType == 'designRequestDoc' ) {
		url = "/dev/designRequestDetailPopup?tbKey="+tbKey+"&tbType="+tbType;
		mode = "width=1100, height=650, left=100, top=50, scrollbars=yes";
	}	
	//window.open(url, "devDocPopup", mode );
	window.open(url, "", mode );
}

function editDesignReqDoc(drNo,isLatest){
	var docNo = '${productDevDoc.docNo}';
	var docVersion = '${productDevDoc.docVersion}';
	
	var form = document.createElement('form');
	form.style.display = 'none';
	$('body').append(form);
	form.action = '/dev/designRequestDocEdit';
	form.method = 'post';

	appendInput(form, 'docNo', docNo);
	appendInput(form, 'docVersion', form);
	appendInput(form, 'drNo', drNo);
	appendInput(form, 'isLatest', isLatest);
	
	form.submit();
}

function designReqView(drNo,isLatest){
	var docNo = '${productDevDoc.docNo}';
	var docVersion = '${productDevDoc.docVersion}';
	
	var form = document.createElement('form');
	form.style.display = 'none';
	$('body').append(form);
	form.action = '/dev/designRequestDocView';
	form.target = '_blank';
	form.method = 'post';

	appendInput(form, 'docNo', docNo);
	appendInput(form, 'docVersion', form);
	appendInput(form, 'drNo', drNo);
	appendInput(form, 'isLatest', isLatest);
	
	form.submit();
}

function copyDesignReqDoc(drNo){
	$('#lab_loading').show();
	
	if(!confirm('선택하신 디자인의뢰서를 복사하시겠습니까?')){
		$('#lab_loading').hide();
		return;
	}
	
	var docNo = '${productDevDoc.docNo}';
	var docVersion = '${productDevDoc.docVersion}';
	
	$.ajax({
		url: '/dev/designRequestDocCopy',
		type: 'post',
		data: {
			drNo: drNo,
			docNo: docNo,
			docVersion: docVersion
		},
		success: function(data){
			if(data == "S"){
				alert('디자인의뢰서가 복사되었습니다.');
				reload();
				window.opener.location.href = window.opener.location.href
			} else {
				alert('복사 실패[1] - 시스템 담당자에게 문의하세요');
				$('#lab_loading').hide();
			}
		},
		error: function(a,b,c){
			alert('복사 실패[1] - 시스템 담당자에게 문의하세요');
			$('#lab_loading').hide();
		}
	})
}

function deleteApprovalLine(obj){
	
	var id = $(obj).siblings("div").children("select").attr("id");
	
	var selectApprNo = $("#"+id).val();
	
	if(selectApprNo =='' || selectApprNo == undefined){
		alert('삭제하실 결재선을 선택해주세요!');
		return false;
	}
	
	var tbType = "";
	
	if(id=='apprLineSelectManu'){
		tbType = 'manufacturingProcessDoc';
	}else{
		tbType = 'designRequestDoc';
	}
	
	$.ajax({
		type:'POST',
		url:"/approval/approvalLineDelete",
		data:{"apprLineNo" : selectApprNo
		},
		async:false,
		success:function(data){
			if(data.status == 'S'){
				
				$.ajax({
					type:"POST",
					url:"/approval/getApprLineList",
					data:{
						"tbType":tbType
					},
					dataType:"json",
					async:false,
					success:function(data){
						if(data.status=='S'){
							alert("성공적으로 삭제되었습니다.");
							
							var apprLineList = data.approvalLineList;
	        				
		    	        	if(tbType == 'designRequestDoc'){
		    	        		$("#deptFulName").val('');
							   	$("#titCodeName").val('');
							    $("#userId").val('');
							    $("#userName").val('');  
								$("#userIdDesignArr").val('');
								$("#userIdDesignArr").val(data.userId);
								$("#designTitle").val('');
								$("#design_comment").val('');
								$("#designKeyword").val('');
		    	        		
								$("#CirculationRefLine").empty()
								
								$("#userId5").val('');
								$("#userId6").val('');
								$(".app_line_edit .req").eq(0).val('');
								
								var apprLength = $("#apprLine li").length;
								
								for(var i=1; i<apprLength;i++){
									$("#apprLine li").eq(1).remove();
								}
								
		    	        		$("#apprLineSelect").empty();
		    	        		
		    	        		$("label[for=apprLineSelect]").html("---- 결재선 불러오기 ----");
		    	        		$("#apprLineSelect").append("<option value=''>---- 결재선 불러오기 ----</option>");
		    	        		
		    	        		for(var i=0;i<apprLineList.length;i++){
		    	        			$("#apprLineSelect").append("<option value="+apprLineList[i].apprLineNo+">"+apprLineList[i].lineName+"</option>");
		    	        		}
		    	        	}else{
		    	        		
		    	        		$("#deptFulName").val('');
							   	$("#titCodeName").val('');
							    $("#userId").val('');
							    $("#userName").val('');  
							    $("#userIdManuArr").val('');
								$("#userIdManuArr").val(data.userId);
								$("#manuTitle").val('');
								$("#launchDateManu").val('');
								$("#CirculationRefLineManu").empty();
								$("#userId7Manu").val('');
								$("#userId8Manu").val('');
								$("#manufacKeyword").val('');
								$(".app_line_edit .req").eq(1).val('');
								
								var apprLength = $("#apprLineManu li").length;
								
								for(var i=1; i<apprLength;i++){
									$("#apprLineManu li").eq(1).remove();
								}
								
		    	        		$("#apprLineSelectManu").empty();
		    	        		
		    	        		$("label[for=apprLineSelectManu]").html("---- 결재선 불러오기 ----");
		    	        		$("#apprLineSelectManu").append("<option value=''>---- 결재선 불러오기 ----</option>");
		    	        		
		    	        		for(var i=0;i<apprLineList.length;i++){
		    	        			$("#apprLineSelectManu").append("<option value="+apprLineList[i].apprLineNo+">"+apprLineList[i].lineName+"</option>");
		    	        		}
		    	        	}
							
						}else if(data.status=='F'){
							alert(data.msg);
						}else{
							alert("오류가 발생하였습니다.");
						}
					},
					error:function(request,status,errorThrown){
						alert("오류 발생");
					}
				});
				
			}else{
				alert("삭제 실패되었습니다.");
			}
		},
		error:function(a,b,c){
			return alert('오류(http error)');
		}
		
	})
	
}

function openHistoryDialog(dNo){
	$('#lab_loading').show();
	
	$.ajax({
		url: '/dev/getHistoryList',
		type: 'post',
		dataType: 'json',
		data: {
			tbType: 'manufacturingProcessDoc',
			tbKey: dNo
		},
		success: function(data){
			var historyList = data;
			
			$('#historyDiv').empty();
			
			if(historyList.length > 0){
				historyList.forEach(function(history){
					var historyElement = '<li>'
					historyElement += '<strong>['+history.typeText+']</strong> ' + history.comment
					historyElement += ' - ' +  history.regUserName + '(' + history.regUserId + ')<br/>'
					historyElement += '<span class="date">'+history.regDate+'</span>'
					historyElement +='</li>';
					/* var historyElement = '<li>'
					historyElement += '<strong>('+history.resultFlagText+') '+history.regUserName+'</strong>님이 '
					historyElement += '제조공정서['+dNo+']를 <strong>'+history.typeText+'</strong>했습니다.<br />'
					historyElement += '<span class="date">'+history.regDate+'</span>'
					historyElement +='</li>' */
					$('#historyDiv').append(historyElement);
				})
			} else {
				var historyElement = '<li><span class="notice_none">등록된 이력이 없습니다.</span></li>';
				$('#historyDiv').append(historyElement);
			}
		},
		error: function(a,b,c){
			//console.log(a,b,c)
			alert('조회 실패[2] - 시스템 담당자에게 문의하세요');
		},
		complete: function(){
			openDialog('dialog_history');
			$('#lab_loading').hide();
		}
	})
}


function approvalDetail( tbKey, tbType ) {
	var url = "";
	var mode = "";
	url = "/approval/approvalInfoPopup?tbKey="+tbKey+"&tbType="+tbType;
	mode = "width=1100, height=300, left=100, top=50, scrollbars=yes";
	
	window.open(url, "ApprovalPopup", mode );
}

function initDialog(){
	// 문서상태변경
	$('textarea[name=closeMemo]').val('');
	
	// 제품개발문서 수정
	$('#devDocEditForm input[name=productName]').val('${fn:escapeXml(productDevDoc.productName)}');
	$('#productCode').val('${productDevDoc.productCode}');
	$('#imNo').val('${productDevDoc.imNo}');
	$('#prdCodeDiv').hide();
	$('#reqNum').val('${productDevDoc.manufacturingNo}');
	$('#manufacturingNoSeq').val('${productDevDoc.manufacturingNoSeq}');
	$('#reqDiv').hide();
	$('#launchDate').val('${fn:substring(productDevDoc.launchDate, 0, 10)}')
	var productType1 = '${productDevDoc.productType1}';
	var productType2 = '${productDevDoc.productType2}';
	var productType3 = '${productDevDoc.productType3}';
	if(productType1.length > 0){ 
		$('#dialog_productType1 option[value='+productType1+']').prop('selected', true);
		$('#dialog_productType1').change();
	}
	if(productType2.length > 0){ 
		$('#dialog_productType2 option[value='+productType2+']').prop('selected', true);
		$('#dialog_productType2').change();
	}
	if(productType3.length > 0){ 
		$('#dialog_productType3 option[value='+productType3+']').prop('selected', true);
		$('#dialog_productType3').change();
	}
	var sterilization = '${productDevDoc.sterilization}';
	var etcDisplay = '${productDevDoc.etcDisplay}';
	
	if(sterilization.length > 0){ 
		$('#sterilization option[value='+sterilization+']').prop('selected', true);
		$('#sterilization').change();
	}
	if(etcDisplay.length > 0){ 
		$('#etcDisplay option[value='+etcDisplay+']').prop('selected', true);
		$('#etcDisplay').change();
	}
	
	$('textarea[name=explanation]').val($('#explanation_hidden').val());
	
	// 버전업
	$('input[name=dialog_check_design_doc]').toArray().forEach(function(input){
	    $(input).prop('checked',false);
	})
	$('textarea[name=versionUpMemo]').val('');
	
	// 제조공정서 생성
	$('#companyCode option:first').prop('selected', true);
	$('#companyCode').change();
	$('#plant').parent().hide();
	$('input[name=dialog_calcType]:first').click();
	
	
	// 파일첨부
	attatchFileArr = [];
	$('ul[name=popFileList]').empty();
	$('#attatch_common_text').val('');
	$('#attatch_common').val('')
}

function closeDialogWithClean(dialogId){
	initDialog();
	closeDialog(dialogId);
}

function reload(){
	var form = document.createElement('form');
	form.style.display = 'none';
	$('body').append(form);
	form.action = '/dev/productDevDocDetail';
	form.method = 'post';

	appendInput(form, 'docNo', '${productDevDoc.docNo}');
	appendInput(form, 'docVersion', '${productDevDoc.docVersion}');

	$(form).submit();
}

function checkMfgDoc(e, term, state, stateText){
	var userType = '${userUtil:getUserGrade(pageContext.request)}'; // 3: BOM담당자
	var isChecked = $(e.target).is(':checked'); // checkbox 클릭 시 상태
	
	// BOM 담당자인 경우에만 아래 메시지
	if( isChecked && userType == 3 ){
		if( !(state == 1 || state == 4 || state == 5) ){
			return alert("본 문서는 "+stateText+" 상태 이므로 BOM반영을 할 수 없습니다.");
		}
		/* 
		if( (term < 1) && (state == 1 || state == 4 || state == 5) ){
			return alert("SAP BOM의 헤더는 1일 1회 반영 가능하며, 오늘은 더이상 반영할 수 없습니다. BOM Item만 변경합니다.");
		}
		 */
	}
}

function getProductName(){
	var productName = '${strUtil:getHtmlBr(productDevDoc.productName)}';
	return productName;
}

function getDocVersion(){
	var docVersion = '${productDevDoc.docVersion}';
	return docVersion;
}

function getParentParams(){
	var result = {};
	result.productName = '${strUtil:getHtmlBr(productDevDoc.productName)}';
	result.docProdName = $('#selectedDocProdName').val();
	result.docNo = '${productDevDoc.docNo}';
	result.docVersion = '${productDevDoc.docVersion}';
	result.modDate = '${productDevDoc.modDate}';
	return result;
}

function updateQns(){
	var dNo = $('#dialog_qns_dNo').val();
	var qns = $('#dialog_qns_no').val();
	
	$.ajax({
	    url: '/dev/updateQns',
	    data: { dNo: dNo, qns: qns },
	    success: function(data){
	        //console.log(data);
	        if(data.status == "success"){1
	        	alert("저장되었습니다.");
	        	reload();
	        } else {
	        	alert(data.msg);
	        }
	    },
	    error: function(a,b,c){
	        alert("시스템 오류 - 담당자에게 문의하세요.");
	    }
	})
}

function callQnsDialog(dNo, qns){
	if(qns == 'undefined') qns = '';
	$('#dialog_qns_no').val(qns);
	$('#dialog_qns_dNo').val(dNo)
	openDialog('dialog_qns')
}

function closeQnsDialog(){
	$('#dialog_qns_no').val("");
	$('#dialog_qns_dNo').val("");
	closeDialog('dialog_qns')
}

function closeSetQnshDialog(){
	$('#qnsh_category_select option:first').prop('selected', true);
	$('#qnsh_category_select').change();
	closeDialog('dialog_set_qnsh')
}


function setQNSDocument(){
	$('#lab_loading').show();
	
	var dNoCnt = $('input[type=checkbox][name=check_mfg_doc]:checked').length;
	var drNoCnt = $('input[type=checkbox][name=check_design_doc]:checked').length;
	var qnshCategory = $('#qnsh_category_select').val();
	 
	if(dNoCnt == 0){
		alert('선택된 제조공정서가 없습니다. 제조공정서를 선택해주세요');
		$('#lab_loading').hide();
		return;
	}
	if(dNoCnt > 1){
		alert('하나의 제조공정서만 선택해주세요.');
		$('#lab_loading').hide();
		return;
	}
	
	if(drNoCnt == 0){
		alert('선택된 디자인의뢰서가 없습니다. 디자인의뢰서를 선택해주세요');
		$('#lab_loading').hide();
		return;
	}
	if(drNoCnt > 1){
		alert('하나의 디자인의뢰서만 선택해주세요.');
		$('#lab_loading').hide();
		return;
	}
	if(qnshCategory.length <= 0){
		alert('QNSH 항목을 선택해주세요.');
		$('#lab_loading').hide();
		return;
	}
	
	var dNo = '';
	var qns = '';
	var drNo = '';
	
	
	var mfgTargetObj = $('input[type=checkbox][name=check_mfg_doc]:checked');
	dNo = mfgTargetObj.siblings('input[name=hidden_mfg_dNo]').val();
	qns = mfgTargetObj.siblings('input[name=hidden_mfg_qns]').val();
	
	var drTargetObj = $('input[type=checkbox][name=check_design_doc]:checked');
	drNo = drTargetObj.parent().next().text();
	
	if(dNo == ''){
		alert('제조공정서를 찾을 수 없습니다.');
		$('#lab_loading').hide();
		return;
	}
	if(qns == ''){
		alert('QNSH를 찾을 수 없습니다.');
		$('#lab_loading').hide();
		return;
	}
	if(drNo == ''){
		alert('디자인의뢰서를 찾을 수 없습니다.');
		$('#lab_loading').hide();
		return;
	}
	
	$.ajax({
		url: '/qns/setQNSDocument',
		type: 'post',
		data: {
			tbType: 'manufacturingProcessDoc',
			tbKey: dNo,
			docNo: '${productDevDoc.docNo}',
			docVersion: '${productDevDoc.docVersion}',
			dNo: dNo,
			drNo: drNo,
			qns: qns,
			qnshCategory: qnshCategory
		},
		success: function(data){
			//console.log(data);
			if(data.status == 'S'){
				alert('저장되었습니다.');
				closeSetQnshDialog('dialog_set_qnsh');
			} else {
				alert('저장 오류');
			}
		},
		error: function(a,b,c){console.log(a,b,c)},
		complete: function(){
			$('#lab_loading').hide();
		}
		
	})
}