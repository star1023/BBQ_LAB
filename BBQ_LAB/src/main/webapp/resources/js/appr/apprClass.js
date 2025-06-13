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
		fn.ajax("/approval/searchUserAjax",{keyword:objKeyWord.val()},function(data){
			response($.map(data, function(item){
				return {
					label : item.USER_NAME + ' / '+item.USER_ID + ' / '+'부서명' + ' / '+'팀명',
					value : item.USER_NAME + ' / '+item.USER_ID + ' / '+'부서명' + ' / '+'팀명',
					userId : item.USER_ID,
					deptName : '부서명',
					teamName : '팀명',
					userName : item.USER_NAME
				};
			}));
		});
	};
	config.select = function(event,ui){
		jQuery('#deptName').val('');
		jQuery('#deptName').val(ui.item.deptName);
		
		jQuery('#teamName').val('');
		jQuery('#teamName').val(ui.item.teamName);
		
		jQuery('#userId').val('');
		jQuery('#userId').val(ui.item.userId);
		
		jQuery('#userName').val('');
		jQuery('#userName').val(ui.item.userName);
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
apprClass.loadApprovalLine = function(docType){
	fn.ajax("../approval/selectApprovalLineAjax",{"docType":docType},function(data){
			$("#apprLineSelect").removeOption(/./);
			data.forEach(function(item){
				$("#apprLineSelect").addOption(item.LINE_IDX, item.NAME, false);	
			});
		},
		fn.ajaxErrorFn);
}
//need coding
apprClass.openApprovalDialog = function(){
	apprClass.loadApprovalLine("");
	openDialog("approval_dialog");
}
//need coding
apprClass.approvalAddLine = function(obj){
	var	popupId = apprClass.getPopupId(obj);
	var id = $(obj).attr("id");
	var html = "";
	if( id == 'appr_add_btn' ) {
		if( $("#userId").val() == '' ) {
			alert("결재자를 선택해주세요.");
			return;
		}
		if( $("#apprLine").containsOption($("#userId").val()) ) {
			alert("이미 등록된 결재자입니다.");
			$("#keyword").val("");
			$("#userId").val("");
			$("#userName").val("");
			$("#deptName").val("");
			$("#teamName").val("");
			return;
		}
		$("#apprLine").addOption($("#userId").val(), $("#userName").val(), true);
		var lineLength = $("#apprLineList").children().length+1;
		html = "<li>";
		html += "<img src='../resources/images/icon_del_file.png' name='delImg' alt='' data-apprtype='A' onclick='apprClass.approvalRemoveLine(this);' >";
		html += "<span id=\"lineLength\">"+lineLength+"차 결재</span> " + $("#userName").val();
		html += "<strong>/" + $("#userId").val() + "/" + $("#deptName").val() + "/" + $("#teamName").val() + "</strong>";
		html += "<input type='hidden' name='userIds' data-apprtype='A' value='" + $("#userId").val() + "'/>";
		html += "</li>";
		$("#apprLineList").append(html);
		$("#keyword").val("");
		$("#userId").val("");
		$("#userName").val("");
		$("#deptName").val("");
		$("#teamName").val("");
		
		$("#apprLineList").children("li").toArray().forEach(function(item,index) { 
			$(item).children("span").html((index+1)+"차 결재");
		});
		
	} else if( id == 'ref_add_btn' ){
		if( $("#userId").val() == '' ) {
			return;
		}
		if( $("#refLine").containsOption($("#userId").val()) ) {
			alert("이미 등록된 참조자입니다.");
			$("#keyword").val("");
			$("#userId").val("");
			$("#userName").val("");
			$("#deptName").val("");
			$("#teamName").val("");
			return;
		}
		$("#refLine").addOption($("#userId").val(), $("#userName").val(), true);
		html = "<li>";
		html += "<img src='../resources/images/icon_del_file.png' name='delImg' alt='' data-apprtype='R' onclick='apprClass.approvalRemoveLine(this);' >";
		html += "<span>참조</span> " + $("#userName").val();
		html += "<strong>/" + $("#userId").val() + "/" + $("#deptName").val() + "/" + $("#teamName").val() + "</strong>";
		html += "<input type='hidden' name='userIds' data-apprtype='R' value='" + $("#userId").val() + "'/>";
		html += "</li>";
		$("#refLineList").append(html);
		$("#keyword").val("");
		$("#userId").val("");
		$("#userName").val("");
		$("#deptName").val("");
		$("#teamName").val("");
	}
}
//need coding
apprClass.approvalRemoveLine = function(obj){
	var	popupId = apprClass.getPopupId(obj);
	var apprtype = $(obj).data("apprtype");
	console.log(apprtype);
	if( apprtype == 'A' ) {
		$("#apprLine").removeOption($(obj).parent().children("input").val());
		$(obj).parent().remove();
		$("#apprLineList").children("li").toArray().forEach(function(item,index) { 
			$(item).children("span").html((index+1)+"차 결재");
		});
	} else if( apprtype == 'R' ) {
		$("#refLine").removeOption($(obj).parent().children("input").val());
		$(obj).parent().remove();
	}
}
//need coding
apprClass.changeApprLine = function(obj){
	var	popupId = apprClass.getPopupId(obj);
	var successFn = function(data){
		console.log(data);
		$("#apprLine").removeOption(/./);
		$("#apprLineList").html("");
		data.forEach(function(item){
			$("#apprLine").addOption(item.USER_ID, item.USER_NAME, true);
			var lineLength = $("#apprLineList").children().length+1;
			html = "<li>";
			html += "<img src='../resources/images/icon_del_file.png' name='delImg' alt='' data-apprtype='A' onclick='apprClass.approvalRemoveLine(this);' >";
			html += "<span id=\"lineLength\">"+lineLength+"차 결재</span> " + item.USER_NAME;
			html += "<strong>/" + item.USER_ID + "/" + item.DEPT_NAME + "/" + item.TEAM_NAME + "</strong>";
			html += "<input type='hidden' name='userIds' data-apprtype='A' value='" + item.USER_ID + "'/>";
			html += "</li>";
			$("#apprLineList").append(html);
		});
	};
	if( $("#apprLineSelect").selectedValues()[0] != "" ) {
		fn.ajax("../approval/selectApprovalLineItemAjax",{"lineIdx":$("#apprLineSelect").selectedValues()[0]},successFn,fn.ajaxErrorFn);
	}
}
//need coding
apprClass.deleteApprovalLine = function(obj){
	var	popupId = apprClass.getPopupId(obj);
	var docType="", selectId = "apprLineSelect";
	
	var apprLineNo = $("#"+selectId).selectedValues()[0];
	if(apprLineNo =='' || apprLineNo == undefined){
		alert('삭제하실 결재선을 선택해주세요!');
		return false;
	}
	
	var successFn = function(data){
		if( data.RESULT == 'S' ) {
			alert("삭제하였습니다.");
			apprClass.loadApprovalLine(docType);
		} else {
			alert("오류가 발생했습니다."+data.MESSAGE);
		}
	};
	fn.ajax("../approval/deleteApprLineAjax",{"lineIdx":apprLineNo},successFn,fn.ajaxErrorFn);
}
//need coding
apprClass.approvalLineSave = function(obj){
	var popupId = apprClass.getPopupId(obj);
	var lineName = $("#apprLineName").val();
	
	if(lineName =='' || lineName == undefined){
		alert("저장 결제선명 입력하세요!");
		return;
	}
	var docType = "",selectId = "",docType = "";
	
	if( $("#apprLine option").length == 0 ) {
		alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 저장해주세요.");
		return;
	} 

	var successFn = function(data){
		if(data.RESULT == 'S') {
			alert("등록되었습니다.");
			apprClass.loadApprovalLine(docType);
		} else {
			alert("결재선 저장시 오류가 발생하였습니다."+data.MESSAGE);
			return;
		}
	};
	
	var formData = new FormData();
	formData.append("apprLineName", $("#apprLineName").val());
	formData.append("apprLine", $("#apprLine").selectedValues());
	formData.append("docType", $("#docType").val());
	var ajaxConfig = {
		type:"POST",
		url:"../approval/insertApprLineAjax",
		dataType:"json",
		data: formData,
		processData: false,
        contentType: false,
        cache: false,
		async:false,
		success:successFn,
		error:fn.ajaxErrorFn
	};
	$.ajax(ajaxConfig);
}
apprClass.apprLineSaveCancel = function(obj){
	$("#apprLineName").val("");
}

apprClass.apprCancel = function(){
	$("#apprLine").removeOption(/./);
	$("#refLine").removeOption(/./);
	$("#apprLineSelect_label").html("---- 결재라인 불러오기 ----");	
	$("#apprLineList").html("");
	$("#refLineList").html("");
	$("#keyword").val("");
	$("#userId").val("");
	$("#userName").val("");
	$("#deptName").val("");
	$("#teamName").val("");
	closeDialog('approval_dialog');
}