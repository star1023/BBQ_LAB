var fn = new Object();
fn.isEmpty = function(value){
	return ( value === '' || value === null || value === undefined );
}
fn.ajax = function(url,postData,successFn,errorFn,type){
	var ajaxConfig = new Object();
	ajaxConfig.type = (type == null)?"POST":type;
	ajaxConfig.url = url;
	ajaxConfig.dataType = "json";
	ajaxConfig.data = postData;
	ajaxConfig.async = false;
	ajaxConfig.success = successFn; //successFn(responseData);
	ajaxConfig.error = errorFn;     //errorFn(request, status, errorThrown);
	ajaxConfig.traditional = true;
	$.ajax(ajaxConfig);
}
fn.showloading = function(){$('#lab_loading').show();}
fn.hideloading = function(){window.setTimeout(function(){$('#lab_loading').hide();},100)}
fn.ajaxErrorFn = function(){alert('오류(http error)');fn.hideloading();}
fn.autoComplete = function(objKeyWord){
	var config = new Object();
	config.minLength = 1;
	config.delay = 300;
	config.source = function(request, response){
		if(nvl(objKeyWord.val(),"").indexOf("/") > 0) return;
		fn.ajax("/approval/searchUser",{keyword:objKeyWord.val(),userGrade:""},function(data){
			response($.map(data.data, function(item){
				return {
					label: item.userName+" / "+item.userId+" / "+nvl(item.deptCodeName,'')+" / "+nvl(item.teamCodeName,''),
					value: item.userName+" / "+item.userId+" / "+nvl(item.deptCodeName,'')+" / "+nvl(item.teamCodeName,''),
					userId : item.userId,
					deptFulName : item.deptCodeName,
					titCodeName: item.teamCodeName,
					userName : item.userName
				};
			}));
		});
	};
	config.select = function(event,ui){
		$("#deptFulName").val('');
		$("#titCodeName").val('');
		$("#userId").val('');
		$("#userName").val('');
		
		$("#deptFulName").val(ui.item.deptFulName);
		$("#titCodeName").val(ui.item.titCodeName);
		$("#userId").val(ui.item.userId);
		$("#userName").val(ui.item.userName);
	};
	config.focus = function( event, ui ) {
		return false;
	};
	objKeyWord.autocomplete(config);
}

var apprClass = new Object();
apprClass.getPopupId = function(obj){
	var div = $(obj).parents("div.white_content");
	var id = div.attr("id");
	return id;
}
apprClass.getApprLines = function(selectId,tbType,successFn){
	fn.ajax("/dev/approvalRequestPopup",{"tbType":tbType},function(data){
			console.log(data);
			if(data.status == 'S'){
				var selectObj = $("#" + selectId);
				selectObj.empty();
				$("label[for=" + selectId + "]").html("----결재선 불러오기----");
				selectObj.append("<option value=''>----결재선 불러오기----</option>");
				for(var i=0; i<data.approvalLineList.length; i++){
					selectObj.append("<option value="+data.approvalLineList[i].apprLineNo+">"+data.approvalLineList[i].lineName+"</option>");
				}
				if(successFn != null){
					successFn(data);
				}
			}else{
				return alert('오류(F)');
			}
		},
		fn.ajaxErrorFn);
}
//need coding
apprClass.openApprovalDialog = function(popupId){
	console.log("apprClass.openApprovalDialog popupId=" + popupId);
	var callback = null,tbType = "",selectId = "";
	
	//-------- 결재별 변수 세팅 start -------------------------------
	//시생산보고서 생성
	if(popupId == "approval_trialReportCreate"){
		var isValid = trialReport.checkTrialReportCreate();
		if(!isValid){return;}
		tbType = trialReport.tbType;
		selectId = trialReport.selectId;
		callback = function(data){
			$("#userIdTrialCreateArr").val(data.userId);
			$("#trialCreateTitle").val("");
			$("#trialCreateComment").val("");
			$("#trialCreateKeyword").val("");
			$("#tbKey").val("");//tbKey
			$("#apprLineTrialCreate").empty();
			$("#CirculationRefLineTrialCreate").empty();
			for(var i=0; i<data.regUserData.length; i++){
				$("#apprLineTrialCreate").append("<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class='s01'>기안자</span>  "+data.regUserData[i].userName+"<strong>"+"/"+data.regUserData[i].userId+"/"+data.regUserData[i].deptCodeName+"/"+data.regUserData[i].teamCodeName+"</strong><input type='hidden' value="+data.regUserData[i].userId+"></li>");
			}
		};
	}
	//시생산보고서 2차 결재
	if(popupId == "approval_trialReportAppr2"){
		tbType = trialAppr2.tbType;
		selectId = trialAppr2.selectId;
		callback = function(data){
			$("#userIdTrialAppr2Arr").val(data.userId);
			$("#trialAppr2Title").val("");
			$("#trialAppr2Comment").val("");
			$("#trialAppr2Keyword").val("");
			$("#tbKey").val("");//tbKey
			$("#apprLineTrialAppr2").empty();
			$("#CirculationRefLineTrialAppr2").empty();
			for(var i=0; i<data.regUserData.length; i++){
				$("#apprLineTrialAppr2").append("<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class='s01'>기안자</span>  "+data.regUserData[i].userName+"<strong>"+"/"+data.regUserData[i].userId+"/"+data.regUserData[i].deptCodeName+"/"+data.regUserData[i].teamCodeName+"</strong><input type='hidden' value="+data.regUserData[i].userId+"></li>");
			}
		};
	}
	//-------- 결재별 변수 세팅 end -------------------------------
	
	$("#deptFulName").val("");
	$("#titCodeName").val("");
	$("#userId").val("");
	$("#userName").val("");
	apprClass.getApprLines(selectId,tbType,callback);
	openDialog(popupId);
	
	//그리드 존재하는 화면에서 작동
	if(Grids != null){
		Grids.Active = null;
		Grids.Focused = null;
	}
}
//need coding
apprClass.approvalAddLine = function(obj){
	var	popupId = apprClass.getPopupId(obj);
	var name = $(obj).attr("name");
	var inputKeyWord = null;        // 결재자 입력
	var objUserIdArr = null;        // hidden 결재자라인
	var divLine = null;             // ul 결재자라인 view
	var apprtype = "A";          // appr: 결재자, refer: 참조, circular: 회람
	
	//-------- 결재별 변수 세팅 start -------------------------------
	//시생산보고서 생성
	if(popupId == "approval_trialReportCreate" && name == "baseApprovalTrialCreate"){
		inputKeyWord = $("#trialCreateKeyword");
		objUserIdArr = $("#userIdTrialCreateArr");
		divLine = $("#apprLineTrialCreate");
		apprtype = "A";
	}
	if(popupId == "approval_trialReportCreate" && name == "referPaymentCreate"){
		inputKeyWord = $("#trialCreateKeyword");
		objUserIdArr = $("#userId7TrialCreate");
		divLine = $("#CirculationRefLineTrialCreate");
		apprtype = "R";
	}
	//시생산보고서 2차 결재
	if(popupId == "approval_trialReportAppr2" && name == "baseApprovalTrialAppr2"){
		inputKeyWord = $("#trialAppr2Keyword");
		objUserIdArr = $("#userIdTrialAppr2Arr");
		divLine = $("#apprLineTrialAppr2");
		apprtype = "A";
	}
	if(popupId == "approval_trialReportAppr2" && name == "referPaymentAppr2"){
		inputKeyWord = $("#trialAppr2Keyword");
		objUserIdArr = $("#userId7TrialAppr2");
		divLine = $("#CirculationRefLineTrialAppr2");
		apprtype = "R";
	}
	//-------- 결재별 변수 세팅 end -------------------------------
	
	if(inputKeyWord.val() == ''  && $("#userName").val() ==''){
		alert("정확한 사원을 입력하세요!");
		objKeyWord.val('');
		$("#userId").val('');
		$("#userName").val('');
		$("#deptFulName").val('');
		$("#titCodeName").val('');
		return false
	}
	
	var tarId = $("#userId").val(), tarUserName = $("#userName").val(), tarDeptFullName = $("#deptFulName").val(), tarTitCodeName = $("#titCodeName").val();
	if(nvl(tarId,"") == ""){return;}
	var objIds = $("[name=hidden_" + objUserIdArr.attr("id") + "]");
	var arrIds = new Array();
	$.each(objIds,function(index,objId){ arrIds.push($(objId).val()); });
	arrIds.push(tarId);
	objUserIdArr.val(arrIds.join(","));
	var html = "";
	if(apprtype == "A"){
		html = "<li>";
		html += "<img src='../resources/images/icon_del_file.png' name='delImg' alt='' data-apprtype='A' onclick='apprClass.approvalRemoveLine(this);' >";
		html += "<span>" + (arrIds.length) + "차 결재</span>  " + tarUserName;
		html += "<strong>/" + tarId + "/" + tarDeptFullName + "/" + tarTitCodeName + "</strong>";
		html += "<input type='hidden' name='hidden_" + objUserIdArr.attr("id") + "' data-apprtype='A' value='" + tarId + "'/>";
		html += "</li>";
	}
	if(apprtype == "R"){
		html = "<li>";
		html += "<img src='../resources/images/icon_del_file.png' name='delImg' alt='' data-apprtype='R' onclick='apprClass.approvalRemoveLine(this);' >";
		html += "<span>참조</span>  " + tarUserName;
		html += "<strong>/" + tarId + "/" + tarDeptFullName + "/" + tarTitCodeName + "</strong>";
		html += "<input type='hidden' name='hidden_" + objUserIdArr.attr("id") + "' data-apprtype='R' value='" + tarId + "'/>";
		html += "</li>";
	}
	if(apprtype == "C"){
		html = "<li>";
		html += "<img src='../resources/images/icon_del_file.png' name='delImg' alt='' data-apprtype='C' onclick='apprClass.approvalRemoveLine(this);' >";
		html += "<span>회람</span>  " + tarUserName;
		html += "<strong>/" + tarId + "/" + tarDeptFullName + "/" + tarTitCodeName + "</strong>";
		html += "<input type='hidden' name='hidden_" + objUserIdArr.attr("id") + "' data-apprtype='C' value='" + tarId + "'/>";
		html += "</li>";
	}
	divLine.append(html);
	inputKeyWord.val("");
}
//need coding
apprClass.approvalRemoveLine = function(obj){
	var	popupId = apprClass.getPopupId(obj);
	var apprtype = $(obj).data("apprtype");
	var objUserIdArr = null;    // hidden 결재자라인
	
	//-------- 결재별 변수 세팅 start -------------------------------
	//시생산보고서 생성
	if(popupId == "approval_trialReportCreate" && apprtype == "A"){
		objUserIdArr = $("#userIdTrialCreateArr");
	}
	if(popupId == "approval_trialReportCreate" && apprtype == "R"){
		objUserIdArr = $("#userId7TrialCreate");
	}
	if(popupId == "approval_trialReportCreate" && apprtype == "C"){
		objUserIdArr = $("#userId8TrialCreate");
	}
	//시생산보고서 2차 결재
	if(popupId == "approval_trialReportAppr2" && apprtype == "A"){
		objUserIdArr = $("#userIdTrialAppr2Arr");
	}
	if(popupId == "approval_trialReportAppr2" && apprtype == "R"){
		objUserIdArr = $("#userId7TrialAppr2");
	}
	if(popupId == "approval_trialReportAppr2" && apprtype == "C"){
		objUserIdArr = $("#userId8TrialAppr2");
	}
	//-------- 결재별 변수 세팅 end -------------------------------
	
	var ul = $(obj).parent().parent();
	$(obj).parent().remove();
	if(apprtype == "A"){
		var liArr = ul.find("li");
		$.each(liArr,function(index,liItem){
			if(index > 0){
				$(liItem).find("span").eq(0).text(index + "차 결재");
			}
		});
	}
	
	var objIds = $("[name=hidden_" + objUserIdArr.attr("id") + "]");
	var arrIds = new Array();
	$.each(objIds,function(index,objId){
		if($(objId).data("apprtype") == apprtype){
			arrIds.push($(objId).val());
		}
	});
	objUserIdArr.val(arrIds.join(","));
	
	
}
//need coding
apprClass.changeApprLine = function(obj){
	var	popupId = apprClass.getPopupId(obj);
	var apprLineNo = $(obj).val();
	var objUserIdArr = null;        // hidden 결재자라인
	var divLine = null;             // ul 결재자라인 view
	var objRefUserIdArr = null;     // hidden 참조라인
	var objCirUserIdArr = null;     // hidden 회람라인
	var divCirRefLine = null;       // ul 회람,참조자 view
	
	//-------- 결재별 변수 세팅 start -------------------------------
	//시생산보고서 생성
	if(popupId == "approval_trialReportCreate"){
		objUserIdArr = $("#userIdTrialCreateArr");
		divLine = $("#apprLineTrialCreate");
		objRefUserIdArr = $("#userId7TrialCreate");
		objCirUserIdArr = $("#userId8TrialCreate");
		divCirRefLine = $("#CirculationRefLineTrialCreate");
	}
	//시생산보고서 2차 결재
	if(popupId == "approval_trialReportAppr2"){
		objUserIdArr = $("#userIdTrialAppr2Arr");
		divLine = $("#apprLineTrialAppr2");
		objRefUserIdArr = $("#userId7TrialAppr2");
		objCirUserIdArr = $("#userId8TrialAppr2");
		divCirRefLine = $("#CirculationRefLineTrialAppr2");
	}
	//-------- 결재별 변수 세팅 end ---------------------------------
	
	var successFn = function(data){
		if(data.status == 'S'){
			var approvalLineList = data.approvalLineList;
			var approvalLineAppr = [];
			var approvalLineRef = [];
			// 결재자라인, 회람참조 초기화
			var apprLineLiArr = divLine.find("li");//$("#" + divLine.attr("id") + " li");
			var lineLiLength = apprLineLiArr.length;
			while ( lineLiLength > 1 ){
				apprLineLiArr.eq(1).remove();
				lineLiLength--;
			}
			var apprUserIdArr = objUserIdArr.val().split(",");
			objUserIdArr.val(apprUserIdArr[0]);
			objRefUserIdArr.val("");
			objCirUserIdArr.val("");
			divCirRefLine.empty();
			
			// 라인 세팅
			$.each(approvalLineList,function(index,approvalLineItem){
				if(approvalLineItem.apprType != "R" && approvalLineItem.apprType != "C"){
					approvalLineAppr.push(approvalLineItem);
				}else{
					approvalLineRef.push(approvalLineItem);
				}
			});
			
			var html = "";
			var newApprUserIdArr = [],newApprRefArr = [], newApprCirArr = [];
			//결재 라인 세팅
			newApprUserIdArr.push(objUserIdArr.val());
			$.each(approvalLineAppr,function(index,apprItem){
				html = "<li>";
				html += "<img src='../resources/images/icon_del_file.png' name='delImg' alt='' data-apprtype='A' onclick='apprClass.approvalRemoveLine(this);' >";
				html += "<span>" + (index + 1) + "차 결재</span>  " + apprItem.userName;
				html += "<strong>/" + apprItem.targetUserId + "/" + apprItem.deptCodeName + "/" + apprItem.teamCodeName + "</strong>";
				html += "<input type='hidden' name='hidden_" + objUserIdArr.attr("id") + "' data-apprtype='A' value='" + apprItem.targetUserId + "'/>";
				html += "</li>";
				divLine.append(html);
				newApprUserIdArr.push(apprItem.targetUserId);
			});
			objUserIdArr.val(newApprUserIdArr.join(","));
			
			//참조, 회람 세팅
			$.each(approvalLineRef,function(index,refItem){
				if(refItem.apprType == "R"){
					html = "<li>";
					html += "<img src='../resources/images/icon_del_file.png' name='delImg' alt=''data-apprtype='R' onclick='apprClass.approvalRemoveLine(this);' >";
					html += "<span>참조</span>  " + refItem.userName;
					html += "<strong>/" + refItem.targetUserId + "/" + refItem.deptCodeName + "/" + refItem.teamCodeName + "</strong>";
					html += "<input type='hidden' name='hidden_" + objRefUserIdArr.attr("id") + "' data-apprtype='R' value='" + refItem.targetUserId + "'/>";
					html += "</li>";
					newApprRefArr.push(refItem.targetUserId);
				}else{
					html = "<li>";
					html += "<img src='../resources/images/icon_del_file.png' name='delImg' alt='' data-apprtype='C' onclick='apprClass.approvalRemoveLine(this);' >";
					html += "<span>회람</span>  " + refItem.userName;
					html += "<strong>/" + refItem.targetUserId + "/" + refItem.deptCodeName + "/" + refItem.teamCodeName + "</strong>";
					html += "<input type='hidden' name='hidden_" + objCirUserIdArr.attr("id") + "' data-apprtype='C' value='" + refItem.targetUserId + "'/>";
					html += "</li>";
					newApprCirArr.push(refItem.targetUserId);
				}
				divCirRefLine.append(html);
			});
			objRefUserIdArr.val(newApprRefArr.join(","));
			objCirUserIdArr.val(newApprCirArr.join(","));
		}else{
			return alert('오류(F)');
		}
	};
	fn.ajax("/approval/getDetailApprovalLineList",{"apprLineNo":apprLineNo},successFn,fn.ajaxErrorFn);
}
//need coding
apprClass.deleteApprovalLine = function(obj){
	var	popupId = apprClass.getPopupId(obj);
	var tbType = "",selectId = "";
	
	//-------- 결재별 변수 세팅 start -------------------------------
	//시생산보고서 생성
	if(popupId == "approval_trialReportCreate"){
		tbType = trialReport.tbType;
		selectId = trialReport.selectId;
	}
	//시생산보고서 2차 결재
	if(popupId == "approval_trialReportAppr2"){
		tbType = trialAppr2.tbType;
		selectId = trialAppr2.selectId;
	}
	//-------- 결재별 변수 세팅 end ---------------------------------
	
	var apprLineNo = $("#"+selectId).val();
	if(apprLineNo =='' || apprLineNo == undefined){
		alert('삭제하실 결재선을 선택해주세요!');
		return false;
	}
	
	var successFn = function(data){
		if(data.status == 'S'){
			alert("성공적으로 삭제되었습니다.");
			apprClass.getApprLines(selectId,tbType,null);
		}else if(data.status=='F'){
			alert(data.msg);
		}else{
			alert("오류가 발생하였습니다.");
		}
	};
	fn.ajax("/approval/approvalLineDelete",{"apprLineNo":apprLineNo},successFn,fn.ajaxErrorFn);
}
//need coding
apprClass.approvalLineSave = function(obj){
	var popupId = apprClass.getPopupId(obj);
	var lineName = $(obj).parent().children("input").val();
	
	if(lineName =='' || lineName == undefined){
		alert("저장 결제선명 입력하세요!");
		return;
	}
	var divLine = null;             // ul 결재자라인 view
	var divCirRefLine = null;       // ul 회람,참조자 view
	var tbType = "",selectId = "";
	
	//-------- 결재별 변수 세팅 start -------------------------------
	//시생산보고서 생성
	if(popupId == "approval_trialReportCreate"){
		divLine = $("#apprLineTrialCreate");
		divCirRefLine = $("#CirculationRefLineTrialCreate");
		tbType = trialReport.tbType;
		selectId = trialReport.selectId;
	}
	//시생산보고서 2차 결재
	if(popupId == "approval_trialReportAppr2"){
		divLine = $("#apprLineTrialAppr2");
		divCirRefLine = $("#CirculationRefLineTrialAppr2");
		tbType = trialAppr2.tbType;
		selectId = trialAppr2.selectId;
	}
	//-------- 결재별 변수 세팅 end ---------------------------------
	
	var targetIdArr = [];
	var apprTypeArr = [];
	var userIdArr = $("#" + divLine.attr("id") + " input[type=hidden]");//$("[name=hidden_]" + objUserIdArr.attr("id"));
	$.each(userIdArr,function(index,item){
		if(index > 0){
			targetIdArr.push($(item).val());
			apprTypeArr.push((index + 1) + "");
		}
	});
	
	var refCriUserArr = $("#" + divCirRefLine.attr("id") + " input[type=hidden]");
	$.each(refCriUserArr,function(index,item){
		targetIdArr.push($(item).val());
		apprTypeArr.push($(item).data("apprtype"));
	});
	console.log("targetIdArr=" + targetIdArr.join(","));
	console.log("apprTypeArr=" + apprTypeArr.join(","));
	
	if(targetIdArr.length == 0){
		return alert('최소 한명 이상의 결재선을 지정해주셔야 합니다.');
	}
	
	var successFn = function(data){
		if(data.status=='success'){
			alert("성공적으로 저장되었습니다.");
			apprClass.getApprLines(selectId,tbType,null);
		}else if(data.status=='F'){
			alert(data.msg);
		}else{
			alert('오류가 발생하였습니다.');
		}
	};
	var ajaxConfig = {
		type:"POST",
		url:"/approval/approvalLineSave",
		data:{"lineName":lineName, "tbType":tbType, "targetIdArr":targetIdArr, "apprTypeArr":apprTypeArr},
		dataType:"json",
		async:false,
		traditional:true,
		success:successFn,
		error:fn.ajaxErrorFn
	};
	$.ajax(ajaxConfig);
}
apprClass.approvalLineCancel = function(obj){
	$(obj).parent().children("input").val("");
}
//need coding
apprClass.doApprSubmit = function(popupId,tbKey,sussesFn){
	var url = "";
	var postData = new Object();
	if(popupId == "approval_trialReportCreate"){
		url = "/trialReport/approvalTrialReportCreate";
		postData.tbType = trialReport.tbType;
		postData.tbKey = tbKey;
		postData.type = 5;      // 0 일반결재; 3 프린트결재; 5 생성결재; 6 작성완료상신
		postData.title = $("#trialCreateTitle").val();
		postData.userId1 = $("#userId1TrialCreate").val();
		postData.referenceId = $("#userId7TrialCreate").val();
		postData.circulationId = $("#userId8TrialCreate").val();
		postData.docNo = $("#docNoTrialCreate").val();
		postData.docVersion =  $("#docVersionTrialCreate").val();
		postData.userIdArr = $("#userId1TrialCreate").val() + "," + $("#userIdTrialCreateArr").val();
		postData.comment =  $("#trialCreateComment").val();
	}
	if(popupId == "approval_trialReportAppr2"){
		url = "/trialReport/approvalTrialReportAppr2";
		postData.tbType = trialAppr2.tbType;
		postData.tbKey = tbKey;
		postData.type = 6;      // 0 일반결재; 3 프린트결재; 5 생성결재; 6 작성완료상신
		postData.title = $("#trialAppr2Title").val();
		postData.userId1 = $("#userId1TrialAppr2").val();
		postData.referenceId = $("#userId7TrialAppr2").val();
		postData.circulationId = $("#userId8TrialAppr2").val();
		postData.userIdArr = $("#userId1TrialAppr2").val() + "," + $("#userIdTrialAppr2Arr").val();
		postData.comment =  $("#trialAppr2Comment").val();
	}
	
	var ajaxConfig = {
		type:"POST",
		url:url,
		data: postData,
		dataType:"json",
		async:false,
		traditional:true,
		success:function(data){
			if(data.status == 'S'){
				alert("성공적으로 상신되었습니다!");
				if(sussesFn != null){
					window.setTimeout(function(){sussesFn(data);},100);
				}
			} else if( data.status == 'E' ){
				fn.ajaxErrorFn();
				console.log(data.msg)
			} else {
				alert("상신 실패되었습니다.");
			}
			closeDialog(popupId);
			fn.hideloading();
		},
		error:function(request, status, errorThrown){
			fn.ajaxErrorFn();
		}
	}
	$.ajax(ajaxConfig);
}