
$(document).ready(function(){

});

function openReserve(id,timeCode,day,isTopReserve){
	
	if(isTopReserve == 'Y'){
		$("#isTopReserve").val('Y');
	}else{
		$("#isTopReserve").val('N');
	}
	
	$("#timeCode").val(timeCode);
	
	var html = "<option value=\"\">선택</option>";
	var html2 = "<option value=\"\">선택</option>";
	
	if(day !='' && day !=undefined){
		var today = new Date(day).getDay();
		$("#reserveDate").val(day);
		$("#reserveDayCode").val(today);
	}
	
	if(timeCode !='' && timeCode !=undefined){
		$("label[for=startTime]").text('선택');
		$("label[for=startTime]").val('');
		$("#startTime").val('');
		$("label[for=endTime]").text('선택');
		$("label[for=endTime]").val('');
		$("#endTime").val('');
		$("#startTime").empty();
		$("#endTime").empty();
		$("#title").val('');
		$("#pn").val('');
		$("#notiYN").prop("checked",false);
		
	if($("#fileData li").length > 0){
		for(var i=0; i < $("#fileData li").length; i++){
			
			var fileId = parseInt($("#fileData li").eq(i).attr("id").slice(7));
			
			var fileNo = fileId-1;
			
			$("#file"+fileNo).remove();
			$("#fileSpan"+fileNo).remove();

		}
		
			$("#fileData").empty();
		
			fileListCheck();
	}	
		
		var timeAry = [ '09:00', '09:30', '10:00', '10:30', 
						'11:00', '11:30', '12:00', '12:30', 
						'13:00', '13:30', '14:00', '14:30', 
						'15:00', '15:30', '16:00', '16:30', 
						'17:00', '17:30', '18:00' ];
		
		for ( var i = 0; i < timeAry.length ; i++ ) {
			var isSelected = "";
			if( parseInt(timeCode)-1 == i) {
				isSelected = "selected";
			}
			html += "<option value = \""+timeAry[i]+"\" "+isSelected+">"+timeAry[i]+"</option>";
	    }
		
		for ( var i = 0; i < timeAry.length ; i++ ) {
			var isSelected = "";
			if( parseInt(timeCode) == i) {
				isSelected = "selected";
			}
			html2 += "<option value = \""+timeAry[i]+"\" "+isSelected+">"+timeAry[i]+"</option>";
	    }
		/*
		switch(timeCode){
		
		case '1':
			html =  '<option value = "09:00" selected>AM 09:00</option>'+
			    '<option value = "09:30">AM 09:30</option>'+
				'<option value = "10:00">AM 10:00</option>'+
				'<option value = "10:30">AM 10:30</option>'+
				'<option value = "11:00">AM 11:00</option>'+
				'<option value = "11:30">AM 11:30</option>'+
				'<option value = "12:00">PM 12:00</option>'+
				'<option value = "12:30">PM 12:30</option>'+
				'<option value = "13:00">PM 13:00</option>'+
				'<option value = "13:30">PM 13:30</option>'+
				'<option value = "14:00">PM 14:00</option>'+
				'<option value = "14:30">PM 14:30</option>'+
				'<option value = "15:00">PM 15:00</option>'+
				'<option value = "15:30">PM 15:30</option>'+
				'<option value = "16:00">PM 16:00</option>'+
				'<option value = "16:30">PM 16:30</option>'+
				'<option value = "17:00">PM 17:00</option>'+
				'<option value = "17:30">PM 17:30</option>'+
				'<option value = "18:00">PM 18:00</option>';
			break;
		case '2':
			html = '<option value = "09:30" selected>AM 09:30</option>'+
				'<option value = "10:00">AM 10:00</option>'+
				'<option value = "10:30">AM 10:30</option>'+
		'<option value = "11:00">AM 11:00</option>'+
		'<option value = "11:30">AM 11:30</option>'+
		'<option value = "12:00">PM 12:00</option>'+
		'<option value = "12:30">PM 12:30</option>'+
		'<option value = "13:00">PM 13:00</option>'+
		'<option value = "13:30">PM 13:30</option>'+
		'<option value = "14:00">PM 14:00</option>'+
		'<option value = "14:30">PM 14:30</option>'+
		'<option value = "15:00">PM 15:00</option>'+
		'<option value = "15:30">PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '3':
		html =  '<option value = "10:00" selected>AM 10:00</option>'+
		'<option value = "10:30">AM 10:30</option>'+
		'<option value = "11:00">AM 11:00</option>'+
		'<option value = "11:30">AM 11:30</option>'+
		'<option value = "12:00">PM 12:00</option>'+
		'<option value = "12:30">PM 12:30</option>'+
		'<option value = "13:00">PM 13:00</option>'+
		'<option value = "13:30">PM 13:30</option>'+
		'<option value = "14:00">PM 14:00</option>'+
		'<option value = "14:30">PM 14:30</option>'+
		'<option value = "15:00">PM 15:00</option>'+
		'<option value = "15:30">PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '4':
		html = '<option value = "10:30" selected>AM 10:30</option>'+
		'<option value = "11:00">AM 11:00</option>'+
		'<option value = "11:30">AM 11:30</option>'+
		'<option value = "12:00">PM 12:00</option>'+
		'<option value = "12:30">PM 12:30</option>'+
		'<option value = "13:00">PM 13:00</option>'+
		'<option value = "13:30">PM 13:30</option>'+
		'<option value = "14:00">PM 14:00</option>'+
		'<option value = "14:30">PM 14:30</option>'+
		'<option value = "15:00">PM 15:00</option>'+
		'<option value = "15:30">PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '5':
		html = '<option value = "11:00" selected>AM 11:00</option>'+
		'<option value = "11:30">AM 11:30</option>'+
		'<option value = "12:00">PM 12:00</option>'+
		'<option value = "12:30">PM 12:30</option>'+
		'<option value = "13:00">PM 13:00</option>'+
		'<option value = "13:30">PM 13:30</option>'+
		'<option value = "14:00">PM 14:00</option>'+
		'<option value = "14:30">PM 14:30</option>'+
		'<option value = "15:00">PM 15:00</option>'+
		'<option value = "15:30">PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '6':
		html =  	'<option value = "11:30" selected>AM 11:30</option>'+
		'<option value = "12:00">PM 12:00</option>'+
		'<option value = "12:30">PM 12:30</option>'+
		'<option value = "13:00">PM 13:00</option>'+
		'<option value = "13:30">PM 13:30</option>'+
		'<option value = "14:00">PM 14:00</option>'+
		'<option value = "14:30">PM 14:30</option>'+
		'<option value = "15:00">PM 15:00</option>'+
		'<option value = "15:30">PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '7':
		html =  '<option value = "12:00" selected>PM 12:00</option>'+
		'<option value = "12:30">PM 12:30</option>'+
		'<option value = "13:00">PM 13:00</option>'+
		'<option value = "13:30">PM 13:30</option>'+
		'<option value = "14:00">PM 14:00</option>'+
		'<option value = "14:30">PM 14:30</option>'+
		'<option value = "15:00">PM 15:00</option>'+
		'<option value = "15:30">PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '8':
		html = 	'<option value = "12:30" selected>PM 12:30</option>'+
		'<option value = "13:00">PM 13:00</option>'+
		'<option value = "13:30">PM 13:30</option>'+
		'<option value = "14:00">PM 14:00</option>'+
		'<option value = "14:30">PM 14:30</option>'+
		'<option value = "15:00">PM 15:00</option>'+
		'<option value = "15:30">PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '9':
		html =  '<option value = "13:00" selected>PM 13:00</option>'+
		'<option value = "13:30">PM 13:30</option>'+
		'<option value = "14:00">PM 14:00</option>'+
		'<option value = "14:30">PM 14:30</option>'+
		'<option value = "15:00">PM 15:00</option>'+
		'<option value = "15:30">PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '10':
		html = '<option value = "13:30" selected>PM 13:30</option>'+
		'<option value = "14:00">PM 14:00</option>'+
		'<option value = "14:30">PM 14:30</option>'+
		'<option value = "15:00">PM 15:00</option>'+
		'<option value = "15:30">PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '11':
		html =  '<option value = "14:00" selected>PM 14:00</option>'+
		'<option value = "14:30">PM 14:30</option>'+
		'<option value = "15:00">PM 15:00</option>'+
		'<option value = "15:30">PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '12':
		html =  '<option value = "14:30" selected>PM 14:30</option>'+
		'<option value = "15:00">PM 15:00</option>'+
		'<option value = "15:30">PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '13':
		html = '<option value = "15:00" selected>PM 15:00</option>'+
		'<option value = "15:30">PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '14':
		html = '<option value = "15:30" selected>PM 15:30</option>'+
		'<option value = "16:00">PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '15':
		html =  '<option value = "16:00" selected>PM 16:00</option>'+
		'<option value = "16:30">PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '16':
		html = '<option value = "16:30" selected>PM 16:30</option>'+
		'<option value = "17:00">PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '17':
		html =  
		'<option value = "17:00" selected>PM 17:00</option>'+
		'<option value = "17:30">PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	case '18':
		html =  
		'<option value = "17:30" selected>PM 17:30</option>'+
		'<option value = "18:00">PM 18:00</option>';
	break;
	
	}
	*/
	//$("#startTime,#endTime").html('<option value="">선택</option>'+html);
	$("#startTime").html(html);
	$("label[for=startTime]").html($("#startTime").selectedTexts()[0]);
	
	$("#endTime").html(html2);
	$("label[for=endTime]").html($("#endTime").selectedTexts()[0]);
}
	openDialog(id);
	
}

function modifyPopup(no,text,timeCode){
	
	$("#timeCode").val(timeCode);
	$("#reserveDate").val('');
	
	$("label[for=startTime]").text('선택');
	$("label[for=startTime]").val('');
	$("#startTime").val('');
	
	$("label[for=endTime]").text('선택');
	$("label[for=endTime]").val('');
	$("#endTime").val('');
	
	$("#pn").val('');
	
	$("#title").val('');
	$("#isPast").val('');
	$("#notiYN").prop("checked",false);
/*	$("label[for=reserveRoomCode]").text('---선택---');
	$("label[for=reserveRoomCode]").val('');
	$("#reserveRoomCode").val('');*/
	$("#reserveDayCode").val('');
	$("#modifyRmrNo").val('');
	$("#notiYNval").val('');
	$("#gubun").val('');
	$("#fileDelete").val('');
	$("#meetingCategoryVal").val('');
	
	
	if($("#fileData li").length > 0){
		for(var i=0; i < $("#fileData li").length; i++){
			
			if($("#fileData li").eq(i).attr("id") !='' && $("#fileData li").eq(i).attr("id") != undefined){
				var fileId = parseInt($("#fileData li").eq(i).attr("id").slice(7));
				
				var fileNo = fileId-1;
				
				$("#file"+fileNo).remove();
				$("#fileSpan"+fileNo).remove();
			}	
		}
		
			$("#fileData").empty();
		
			fileListCheck();
	}	
	

	var html = "<option value=\"\">선택</option>";
	var html2 = "<option value=\"\">선택</option>";
	
	var timeAry = [ '09:00', '09:30', '10:00', '10:30', 
		'11:00', '11:30', '12:00', '12:30', 
		'13:00', '13:30', '14:00', '14:30', 
		'15:00', '15:30', '16:00', '16:30', 
		'17:00', '17:30', '18:00' ];
	
	
	for ( var i = 0; i < timeAry.length ; i++ ) {
		var isSelected = "";
		if( parseInt(timeCode)-1 == i) {
			isSelected = "selected";
		}
		html += "<option value = \""+timeAry[i]+"\" "+isSelected+">"+timeAry[i]+"</option>";
    }
	
	for ( var i = 0; i < timeAry.length ; i++ ) {
		var isSelected = "";
		if( parseInt(timeCode) == i) {
			isSelected = "selected";
		}
		html2 += "<option value = \""+timeAry[i]+"\" "+isSelected+">"+timeAry[i]+"</option>";
    }
	
	$("#startTime").html(html);
	$("label[for=startTime]").html($("#startTime").selectedTexts()[0]);
	
	$("#endTime").html(html2);
	$("label[for=endTime]").html($("#endTime").selectedTexts()[0]);
	
	if(text == 'modify'){
		$.ajax({
			 type:"POST",
				url:"/Reserve/ReserveDetail",
				data:{
						"tbKey":no,
					  "tbType":"reserve"
				},
				dataType:"json",
				async:false,
				success:function(data){
					if(data.status == 'S'){
						
						var yearFormat = new Date().getFullYear();
						
						var monthFormat = new Date().getMonth()+1;
						
						var dateFormat = new Date().getDate();
						
						var todayFormat =  yearFormat +"-" + monthFormat +"-"+dateFormat;
						
						$("#reserveDate").val($.trim(data.detailReserve.reserveDateFormat1));
						
						var html = "<option value=\"\">선택</option>";
						var html2 = "<option value=\"\">선택</option>";
						
						if(todayFormat !=  $("#reserveDate").val()){
							for ( var i = 0; i < timeAry.length ; i++ ) {
								var isSelected = "";
								if( parseInt("1")-1 == i) {
									isSelected = "selected";
								}
								html += "<option value = \""+timeAry[i]+"\" "+isSelected+">"+timeAry[i]+"</option>";
						    }
							
							for ( var i = 0; i < timeAry.length ; i++ ) {
								var isSelected = "";
								if( parseInt("1") == i) {
									isSelected = "selected";
								}
								html2 += "<option value = \""+timeAry[i]+"\" "+isSelected+">"+timeAry[i]+"</option>";
						    }
							
							$("#startTime").html(html);
							$("label[for=startTime]").html($("#startTime").selectedTexts()[0]);
							
							$("#endTime").html(html2);
							$("label[for=endTime]").html($("#endTime").selectedTexts()[0]);
						}
						
						if(new Date(todayFormat) > new Date($("#reserveDate").val())){
							$("#isPast").val('Y');
						}
						
		/* 				$("#detailStartTime").html("<dt>시작시간</dt><dd>"+data.detailReserve.startTime+"</dd>");
						$("#detailEndTime").html("<dt>종료시간</dt><dd>"+data.detailReserve.endTime+"</dd>"); */
						
						var gubunSt = "AM";
						var gubunEd = "AM";
						
						if(parseInt(($.trim(data.detailReserve.startTime)).substr(0,2)) >= 12){
							gubunSt = "PM";
						}
						
						if(parseInt(($.trim(data.detailReserve.endTime)).substr(0,2)) >= 12){
							gubunEd = "PM";
						}
						
/*						$("label[for=startTime]").text(gubunSt+" "+$.trim(data.detailReserve.startTime));
						$("label[for=endTime]").text(gubunEd+" "+$.trim(data.detailReserve.endTime));
						
						$("label[for=startTime]").val($.trim(data.detailReserve.startTime));
						$("label[for=endTime]").val($.trim(data.detailReserve.endTime));
						$("#startTime").val($.trim(data.detailReserve.startTime));
						$("#endTime").val($.trim(data.detailReserve.endTime));*/
						$("#reserveDayCode").val($.trim(data.detailReserve.reserveDayCode));
						
						$("#pn").val($.trim(data.detailReserve.pn));
						$("#modifyRmrNo").val($.trim(data.detailReserve.rmrNo));
						
					/*	var reserveCode = $.trim(data.detailReserve.reserveCode);
						
						if(reserveCode == 'V'){
							$("label[for=reserveRoomCode]").text('비전룸');
							$("label[for=reserveRoomCode]").val(reserveCode);
							$("#reserveRoomCode").val(reserveCode);
						}else if(reserveCode == 'Y'){
							$("label[for=reserveRoomCode]").text('열정룸');
							$("label[for=reserveRoomCode]").val(reserveCode);
							$("#reserveRoomCode").val(reserveCode);
						}else if(reserveCode == 'G'){
							$("label[for=reserveRoomCode]").text('가치룸');
							$("label[for=reserveRoomCode]").val(reserveCode);
							$("#reserveRoomCode").val(reserveCode);
						}else{
							$("label[for=reserveRoomCode]").text('신뢰룸');
							$("label[for=reserveRoomCode]").val(reserveCode);
							$("#reserveRoomCode").val(reserveCode);
						}*/
						
						if($.trim(data.detailReserve.notiYN) == 'Y'){
							$("#notiYNval").val('Y');
							$("#notiYN").prop("checked",true);
						}else{
							$("#notiYNval").val('N');
							$("#notiYN").prop("checked",false);
						}
						
						$("#title").val($.trim(data.detailReserve.title));
						$("#insertPopupTitle").text("회의실 수정");
						$("#reserveModifyBtn").text("수정");
						$("#insert_meeting_form").attr("action","/Reserve/ReserveEditAjax");
						
						if(data.fileList.length > 0){
							
							$("#add_file2").prop("class","add_file");
							$("#fileList").show();
							
							for(var i=0;i<data.fileList.length;i++){
								var html = "";
								
								html = "<li><input type='hidden' value="+data.fileList[i].fmNo+" name='fileDeleteInput'/><a href='#' onClick='javascript:deleteFileList(this)'><img src=\"/resources/images/icon_del_file.png\"></a>"+data.fileList[i].orgFileName+"</li>";
								
								$("#fileData").append(html);
							}

						}
						
						if($.trim(data.detailReserve.meetingCategory) == 'Y'){
							$("#meetingCategory").prop("checked",true);
							$("#meetingCategoryVal").val($.trim(data.detailReserve.meetingCategory));
						}else{
							$("#meetingCategory").prop("checked",false);
							$("#meetingCategoryVal").val($.trim(data.detailReserve.meetingCategory));
						}
						
						$("#meetingCategory").prop("disabled",true);
						
						openDialog("insert_meeting");					
					
					}else {
						alert("오류가 발생하였습니다.");
					}
				},
				error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.");
				}
		 });
	}else{
		$("#insertPopupTitle").text("회의실 예약");
		$("#reserveModifyBtn").text("예약");
		$("#insert_meeting_form").attr("action","/Reserve/ReserveSaveAjax");
		$("#meetingCategory").prop("checked",false);
		$("#meetingCategory").prop("disabled",false);
		openDialog("insert_meeting");
	}
	
}