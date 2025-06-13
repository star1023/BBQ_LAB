
$(document).ready(function(){
		
	$("#designKeyword").autocomplete({
		minLength: 1,
	    delay: 300,
		source: function( request, response ) {
	        $.ajax( {
	          type:"POST",
	          url: "/approval/searchUser",
	          dataType: "json",
	          data: {
	        	  "keyword": $("#designKeyword").val(),
				   "userGrade" : ''
	          },
	          async:false,
	          success: function( data ) {
	        	response($.map(data.data, function(item){
	        		/*return {
                      label: item.userName+" / "+item.userId+" / "+nvl(item.deptCodeName)+" / "+nvl(item.teamCodeName),
                      value: item.userName+" / "+item.userId+" / "+nvl(item.deptCodeName)+" / "+nvl(item.teamCodeName),
                      userId : item.userId,
                      deptFulName : item.deptCodeName,
                      titCodeName: item.teamCodeName,
                      userName : item.userName
        			};*/
        			
        			return {
	        			label: item.userName+" / "+item.userId+" / "+nvl(item.deptCodeName,'')+" / "+nvl(item.teamCodeName,''),
	                    value: item.userName+" / "+item.userId+" / "+nvl(item.deptCodeName,'')+" / "+nvl(item.teamCodeName,''),
	                    userId : item.userId,
	                    deptFulName : item.deptCodeName,
	                    titCodeName: item.teamCodeName,
	                    userName : item.userName
        			};
       			}));
	          }
	        } );
	      },
	      
	      select : function(event,ui){
	    	
	    	$("#deptFulName").val('');
		   	$("#titCodeName").val('');
		    $("#userId").val('');
		    $("#userName").val('');  
	    	  
	    	$("#deptFulName").val(ui.item.deptFulName);
	    	$("#titCodeName").val(ui.item.titCodeName);
	    	$("#userId").val(ui.item.userId);
	    	$("#userName").val(ui.item.userName);
	      },
	      focus: function( event, ui ) {
	    	return false;
	      }
	});
	
	$("#manufacKeyword").autocomplete({
		minLength: 1,
	    delay: 300,
		source: function( request, response ) {
	        $.ajax( {
	          type:"POST",
	          url: "/approval/searchUser",
	          dataType: "json",
	          data: {
	        	  "keyword": $("#manufacKeyword").val(),
				   "userGrade" : ''
	          },
	          async:false,
	          success: function( data ) {
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
	          }
	        } );
	      },
	      
	      select : function(event,ui){
	    	
	    	$("#deptFulName").val('');
		   	$("#titCodeName").val('');
		    $("#userId").val('');
		    $("#userName").val('');  
	    	  
	    	$("#deptFulName").val(ui.item.deptFulName);
	    	$("#titCodeName").val(ui.item.titCodeName);
	    	$("#userId").val(ui.item.userId);
	    	$("#userName").val(ui.item.userName);
	      },
	      focus: function( event, ui ) {
	    	return false;
	      }
	});

	$("#manufacturingNoKeyword").autocomplete({
		minLength: 1,
		delay: 300,
		source: function( request, response ) {
			$.ajax( {
				type:"POST",
				url: "/approval/searchUser",
				dataType: "json",
				data: {
					"keyword": $("#manufacturingNoKeyword").val(),
					"userGrade" : ''
				},
				async:false,
				success: function( data ) {
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
				}
			} );
		},
		select : function(event,ui){

			$("#deptFulName").val('');
			$("#titCodeName").val('');
			$("#userId").val('');
			$("#userName").val('');

			$("#deptFulName").val(ui.item.deptFulName);
			$("#titCodeName").val(ui.item.titCodeName);
			$("#userId").val(ui.item.userId);
			$("#userName").val(ui.item.userName);
		},
		focus: function( event, ui ) {
			return false;
		}
	});

$(document).on("click","[name=delImg]",function(){ 
		
		var text = $(this).parent().children("span").text();
		
		var popupId = $(this).parents("div.white_content").attr("id");
		
		
/*		var marketingUser = [];*/

		var qualityPlanningUser = [];
		
	/*	$.ajax({
			url:'/user/marketingUserList',
			type:'post',
			async:false,
			success:function(data){
				if(data.status=='S'){
					var marketingUserList = data.marketingUserList;
			
					for(var i=0;i<marketingUserList.length;i++){
						marketingUser.push(marketingUserList[i].userId);
					}
				
				}else{
					return alert('마케팅팀 인원 찾아오는데 오류 발생');
				}	
			},
			error:function(a,b,c){
				return alert('오류(http error');
			}
		
		});*/

	console.log("popupId="+popupId + ", text="+text);
		
		$.ajax({
			url:'/user/qualityPlanningUserList',
			type:'post',
			async:false,
			success:function(data){
				if(data.status=='S'){
					var qualityPlanningUserList = data.qualityPlanningUserList;
					
					for(var i=0; i<qualityPlanningUserList.length; i++){
						qualityPlanningUser.push(qualityPlanningUserList[i].userId);
					}
				}else{
					return alert('품질기획팀인원 찾아오는데 오류 발생');
				}
			},
			error:function(a,b,c){
				//return alert('오류(http error');
			}
		
		});
		
		if(text!='참조' && text!='회람'){
			
			var userId = $(this).parent().children("input").val();
			
			var approvalText = $(this).parent().children("span").text();
			
			if(popupId == 'approval_design'){
				if(approvalText == '1차 결재'){
					/*if(userId == 'yeorin' || userId == 'dlach8' || userId=='admin'){
						alert('1차 결재자가 유여린,임초롱은 필수 입니다. 삭제 할수 없습니다.');
						return;
					}*/
					/*for(var i=0; i<qualityPlanningUser.length; i++){
						if(userId == qualityPlanningUser[i]){
							alert('1차 결재자가 품질기획팀원은 필수 입니다. 삭제 할수 없습니다.');
							return;
						}
					}*/
					
				}
			}/*else{
				
				var ManuCompanyCdArr = $("#ManuCompanyCd").val().split(",");
				
				var IsMl = true;
				
				for(var i=0; i<ManuCompanyCdArr.length; i++){
					if(ManuCompanyCdArr[i] != 'MD'){
						IsMl = false;
						break;
					}
				}
				
				if(IsMl == false){
					if(approvalText == '1차 결재'){
						for(var i = 0; i<marketingUser.length; i++){
							if(userId == marketingUser[i]){
								alert("1차 결재자가 마케팅팀원은 필수 입니다. 삭제 할수 없습니다.");
								return;
							}
						}
					}
				}

			}*/
			
			$(this).parent().remove();
			
/*			var userIdTemp = [];
			
			if(popupId == 'approval_design'){
				userIdTemp = $("#userIdDesignArr").val().split(",");
			}else{
				userIdTemp = $("#userIdManuArr").val().split(",");
			}
			
			for(var i=0; i<userIdTemp.length; i++){
				if(userId == userIdTemp[i]){
					userIdTemp.splice(i,1);
					break;
				}
			}*/
			
			var val = "";

			if(popupId == 'approval_manufacturingNo'){

				$("#userIdManufacturingNoArr").val($("#apprLineManufacturingNo li input").eq(0).val());

				var manuId =  $("#userIdManufacturingNoArr").val();

				for(var i=1; i<$("#apprLineManufacturingNo li").length;i++){
					$("#apprLineManufacturingNo li span").eq(i).text(i+"차 결재");

					if(manuId !='' && manuId !=undefined){
						manuId = manuId +","+ $("#apprLineManufacturingNo li input").eq(i).val();
					}else{
						manuId = $("#apprLineManufacturingNo li input").eq(i).val();
					}
				}

				$("#userIdManufacturingNoArr").val(manuId);

			}else if(popupId == 'approval_design'){
				
/*				val = userIdTemp.join(",");
				
				 $("#userIdDesignArr").val(val);*/
				
				 $("#userIdDesignArr").val($("#apprLine li input").eq(0).val());
				 
				 var designId = $("#userIdDesignArr").val();
				 
				 for(var i=1; i<$("#apprLine li").length;i++){
					 $("#apprLine li span").eq(i).text(i+"차 결재");
					 
					 if(designId !='' && designId !=undefined){
						 designId = designId +","+ $("#apprLine li input").eq(i).val();
					 }else{
						 designId = $("#apprLine li input").eq(i).val();
					 }
					 
				 }
				 
				 $("#userIdDesignArr").val(designId);
				 
			}else{
				
/*				val = userIdTemp.join(",");
				
				$("#userIdManuArr").val(val);*/
				
				$("#userIdManuArr").val($("#apprLineManu li input").eq(0).val());
				 
				var manuId =  $("#userIdManuArr").val();
				
				for(var i=1; i<$("#apprLineManu li").length;i++){
					$("#apprLineManu li span").eq(i).text(i+"차 결재");
										
					 if(manuId !='' && manuId !=undefined){
						 manuId = manuId +","+ $("#apprLineManu li input").eq(i).val();
					 }else{
						 manuId = $("#apprLineManu li input").eq(i).val();
					 }
				}
				
				 $("#userIdManuArr").val(manuId);
				
			}

		}else{
	
			$(this).parent().remove();
			
			var userId = $(this).parent().children("input").val();
			
			if($(this).parent().children("span").text()=='참조'){
				
				var userIdTemp = [];

				if(popupId == 'approval_manufacturingNo'){
					userIdTemp =  $("#userId7ManufacturingNo").val().split(",");
				}else if(popupId == 'approval_design'){
					userIdTemp =  $("#userId5").val().split(",");
				}else{
					userIdTemp =  $("#userId7Manu").val().split(",");
				}
				
				for(var i = 0; i<userIdTemp.length; i++){
					
					if(userId == userIdTemp[i]){
						
						userIdTemp.splice(i,1);
						
					   break;
					}
		
				}
				if(popupId == 'approval_manufacturingNo'){
					$("#userId7ManufacturingNo").val(userIdTemp.reverse().join(","));
				}else if(popupId == 'approval_design'){
					$("#userId5").val(userIdTemp.reverse().join(","));
				}else{
					$("#userId7Manu").val(userIdTemp.reverse().join(","));
				}
				
			}else{
				
				var userIdTemp =  [];

				if(popupId == 'approval_manufacturingNo'){
					userIdTemp =  $("#userId8ManufacturingNo").val().split(",");
				}else if(popupId == 'approval_design'){
					userIdTemp =  $("#userId6").val().split(",");
				}else{
					userIdTemp =  $("#userId8Manu").val().split(",");
				}
				
				for(var i = 0; i<userIdTemp.length; i++){
					
					if(userId == userIdTemp[i]){
						
						userIdTemp.splice(i,1);
						
					   break;
					}
					
				 }

				if(popupId == 'approval_manufacturingNo'){
					$("#userId8ManufacturingNo").val(userIdTemp.reverse().join(","));
				}else if(popupId == 'approval_design'){
					$("#userId6").val(userIdTemp.reverse().join(","));
				}else{
					$("#userId8Manu").val(userIdTemp.reverse().join(","));
				}
				
			}
			
		}
		
		
	});

});
/*$(document).on("click","[name=delImg]",function(){ 
		
		var id = $(this).parent().attr("id");
		
		var popupId = $(this).parents("div.white_content").attr("id");
		
		if(id == 'designPayment1' || id== "manufacPayment1"){
			
			$(this).parent().html('<img src="../resources/images/icon_del_file.png" name="delImg"><span>1차 검토 </span>  <strong></strong>');
		
			if(popupId == 'approval_design'){
				$("#userId2").val('');
			}else{
				$("#userId2Manu").val('');
			}
			
		}else if(id == 'designPayment2' || id =="manufacPayment2"){
			
			$(this).parent().html('<img src="../resources/images/icon_del_file.png" name="delImg"><span>2차 검토 </span>  <strong></strong>');
			
			if(popupId =='approval_design'){
				$("#userId3").val('');
			}else{
				$("#userId3Manu").val('');
			}
				
		}else if(id == 'designPaymentMarketing'){
		
			$(this).parent().html('<img src="../resources/images/icon_del_file.png" name="delImg"><span>마케팅 </span>  <strong></strong>');
		
			$("#userId4").val('');
			
		}else if(id=='manufacPaymentParter'){
		
			$(this).parent().html('<img src="../resources/images/icon_del_file.png" name="delImg"><span>파트장</span>  <strong></strong>');
			
			$("#userId4Manu").val('');
			
		}else if(id=='manufacPaymentLeader'){
			
			$(this).parent().html('<img src="../resources/images/icon_del_file.png" name="delImg"><span>팀장</span>  <strong></strong>');
			
			$("#userId5Manu").val('');
			
		}else if(id=='manufacPaymentDirector'){
			
			$(this).parent().html('<img src="../resources/images/icon_del_file.png" name="delImg"><span>연구소장</span>  <strong></strong>');
			
			$("#userId6Manu").val('');
			
		}else{
			$(this).parent().remove();
			
			var userId = $(this).parent().children("input").val();
			
			if($(this).parent().children("span").text()=='참조'){
				
				var userIdTemp = [];
				
				if(popupId == 'approval_design'){
					userIdTemp =  $("#userId5").val().split(",");
				}else{
					userIdTemp =  $("#userId7Manu").val().split(",");
				}
				
				for(var i = 0; i<userIdTemp.length; i++){
					
					if(userId == userIdTemp[i]){
						
						userIdTemp.splice(i,1);
						
					   break;
					}
		
				}
				
				if(popupId == 'approval_design'){
					$("#userId5").val(userIdTemp.reverse().join(","));
				}else{
					$("#userId7Manu").val(userIdTemp.reverse().join(","));
				}
				
			}else{
				
				var userIdTemp =  [];
				
				if(popupId == 'approval_design'){
					userIdTemp =  $("#userId6").val().split(",");
				}else{
					userIdTemp =  $("#userId8Manu").val().split(",");
				}
				
				for(var i = 0; i<userIdTemp.length; i++){
					
					if(userId == userIdTemp[i]){
						
						userIdTemp.splice(i,1);
						
					   break;
					}
					
				 }
				
				if(popupId == 'approval_design'){
					$("#userId6").val(userIdTemp.reverse().join(","));
				}else{
					$("#userId8Manu").val(userIdTemp.reverse().join(","));
				}
				
			}
			
		}
		
		
	});
});*/

/*function approvalAddLine(obj){
	
	//apprType 1차:2 2차:3    마케팅:4    참조:R 회람:C
	
	
	
	var	popupId = $(obj).parents("div.white_content").attr("id");
	
	if(popupId == 'approval_design'){
		
		if($("#designKeyword").val() =='' && $("#userName").val() ==''){
			alert("정확한 사원을 입력하세요!");
			return false;
		}
		
	}else{
		
		if($("#manufacKeyword").val() ==''  && $("#userName").val() ==''){
			alert("정확한 사원을 입력하세요!");
			return false;
		}
		
	}

	var overApprTypeText = "";
	var drCon = ['yeorin', 'dlach8', 'admin']; // 1차 검토자 아이디가 여기 없을경우 얼럿
	var tarId = "";
	var retVal = true;

	var name = $(obj).attr("name");
	
	var html = '';
	
	tarId = $("#userId").val();
	
	if(name=="firstPayment"){
		
		html = '<img src="../resources/images/icon_del_file.png" name="delImg"><span>1차 검토</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'>';
		
		if(popupId == "approval_design"){
			var retVal = $.inArray(tarId,drCon);
			
			if(retVal < 0 ){
				alert("디자인의뢰서 1차 검토자는 \n임초롱, 유여린 연구원입니다.");
				return false;
			}
		
		
			if($("#designPayment1 strong").text()!='' && $("#designPayment1 strong").text() != null){
				alert("이미 추가된 1차 결제자가 있습니다.");
				return false;
			}
		
			$("#designPayment1").html(html);
		
			$("#userId2").val($("#userId").val());
		
		}else{
			
			if($("#manufacPayment1 strong").text()!='' && $("#manufacPayment1 strong").text() != null){
				alert("이미 추가된 1차 결제자가 있습니다.");
				return false;
			}
			
			$("#manufacPayment1").html(html);
			
			$("#userId2Manu").val($("#userId").val());
			
		}

	}else if(name=="secondPayment"){
		
		html = '<img src="../resources/images/icon_del_file.png" name="delImg"><span>2차 검토</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'>';
		
		if(popupId == "approval_design"){
			
			if($("#designPayment2 strong").text()!='' && $("#designPayment2 strong").text() != null){
				alert("이미 추가된 2차 결제자가 있습니다.");
				return;
			}
			
			$("#designPayment2").html(html);
			
			$("#userId3").val($("#userId").val());
			
		}else{
			
			if($("#manufacPayment2 strong").text()!='' && $("#manufacPayment2 strong").text() != null){
				alert("이미 추가된 2차 결제자가 있습니다.");
				return false;
			}
			
			$("#manufacPayment2").html(html);
			
			$("#userId3Manu").val($("#userId").val());
			
		}
		
	}else if(name=="marketingPayment"){
		
			
			if($("#designPaymentMarketing strong").text()!='' && $("#designPaymentMarketing strong").text() != null){
				alert("이미 추가된 마케팅 결제자가 있습니다.");
				return;
			}
			
			html = '<img src="../resources/images/icon_del_file.png" name="delImg"><span>마케팅</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'>';
			
			$("#designPaymentMarketing").html(html);
			
			$("#userId4").val($("#userId").val());
			
	}else if(name=="circulationPayment" || name=="referPayment"){
		
		if(popupId == 'approval_design'){
			if(name=="referPayment"){

				if($("#userId5").val() == ""){
					$("#userId5").val($("#userId").val());
				}else{
					
					var existId = $("#userId5").val();
					
					$("#userId5").val(existId+","+$("#userId").val());
					
				}
				
				$("#CirculationRefLine").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>참조</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="R"></li>');
			}else{
				
				if($("#userId6").val() == ""){
					$("#userId6").val($("#userId").val());
				}else{
					
					var existId = $("#userId6").val();
					
					$("#userId6").val(existId+","+$("#userId").val());
					
				}
				
				$("#CirculationRefLine").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>회람</span>'+$("#userName").val()+' <strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="C"></li>');
			}
		}else{
			
			if(name=="referPayment"){
				if($("#userId7Manu").val() == ""){
					$("#userId7Manu").val($("#userId").val());
				}else{
					
					var existId = $("#userId7Manu").val();
					
					$("#userId7Manu").val(existId+","+$("#userId").val());
					
				}
				
				$("#CirculationRefLineManu").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>참조</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="R"></li>');
			}else{
				if($("#userId8Manu").val() == ""){
					$("#userId8Manu").val($("#userId").val());
				}else{
					
					var existId = $("#userId8Manu").val();
					
					$("#userId8Manu").val(existId+","+$("#userId").val());
					
				}
				
				$("#CirculationRefLineManu").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>회람</span>'+$("#userName").val()+' <strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="C"></li>');
			}
			
		}
		
		
		}else if(name=='parterPayment'){
			if($("#manufacPaymentParter strong").text()!='' && $("#manufacPaymentParter strong").text() != null){
				alert("이미 추가된 파트장 결제자가 있습니다.");
				return;
			}
			
			html = '<img src="../resources/images/icon_del_file.png" name="delImg"><span>파트장</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'>';
			
			$("#manufacPaymentParter").html(html);
			
			$("#userId4Manu").val($("#userId").val());
		}else if(name=='leaderPayment'){
			if($("#manufacPaymentLeader strong").text()!='' && $("#manufacPaymentLeader strong").text() != null){
				alert("이미 추가된 팀장 결제자가 있습니다.");
				return;
			}
			
			html = '<img src="../resources/images/icon_del_file.png" name="delImg"><span>팀장</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'>';
			
			$("#manufacPaymentLeader").html(html);
			
			$("#userId5Manu").val($("#userId").val());
		}else{
			if($("#manufacPaymentDirector strong").text()!='' && $("#manufacPaymentDirector strong").text() != null){
				alert("이미 추가된 연구소장 결제자가 있습니다.");
				return;
			}
			
			html = '<img src="../resources/images/icon_del_file.png" name="delImg"><span>연구소장</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'>';
			
			$("#manufacPaymentDirector").html(html);
			
			$("#userId6Manu").val($("#userId").val());
		}
	
}*/

function approvalAddLine(obj){
	
	//apprType 1차:2 2차:3    마케팅:4    참조:R 회람:C
	
	var loginUserId = $("#loginUserId").val();
	
	
	var	popupId = $(obj).parents("div.white_content").attr("id");
	
	if(popupId == 'approval_design'){
		
		if($("#designKeyword").val() =='' && $("#userName").val() ==''){
			alert("정확한 사원을 입력하세요!");
			
			$("#designKeyword").val('');
			$("#userId").val('');
			$("#userName").val('');
			$("#deptFulName").val('');
		   	$("#titCodeName").val('');
			
			return false;
		}
		
	}else if(popupId == 'approval_manu'){
		
		if($("#manufacKeyword").val() ==''  && $("#userName").val() ==''){
			alert("정확한 사원을 입력하세요!");
			
			$("#manufacKeyword").val('');
			$("#userId").val('');
			$("#userName").val('');
			$("#deptFulName").val('');
		   	$("#titCodeName").val('');
			
			return false;
		}
		
	}else if(popupId == 'approval_trialprodreport'){
		if( jQuery('#trialKeyword').val() == '' && jQuery('#userName').val() == '' ){
			alert('정확한 사원을 입력하세요!');
			$('#userId').val('');
			$('#userName').val('');
			$('#deptFulName').val('');
		   	$('#titCodeName').val('');
			$('#manufacKeyword').val('');
			return false;
		}
	}else if(popupId == "approval_manufacturingNo"){
		if($("#manufacturingNoKeyword").val() ==''  && $("#userName").val() ==''){
			alert("정확한 사원을 입력하세요!");

			$("#manufacturingNoKeyword").val('');
			$("#userId").val('');
			$("#userName").val('');
			$("#deptFulName").val('');
			$("#titCodeName").val('');

			return false;
		}
	}

	/*if(loginUserId == $("#userId").val()){
		alert("본인은 결제자 추가 불가능!");
		return false;
	}*/
	
	var overApprTypeText = "";
	/*var drCon = ['yeorin', 'dlach8', 'admin'];*/ // 1차 검토자 아이디가 여기 없을경우 얼럿
	var tarId = "";
	var retVal = true;

	var name = $(obj).attr("name");
	
	var html = '';
	
	tarId = $("#userId").val();
	console.log(name);
	if(name == 'baseApprovalDesign'){
		
		var qualityPlanningUser = [];
		
		$.ajax({
			url:'/user/qualityPlanningUserList',
			type:'post',
			async:false,
			success:function(data){
				if(data.status=='S'){
					var qualityPlanningUserList = data.qualityPlanningUserList;
					
					for(var i=0; i<qualityPlanningUserList.length; i++){
						qualityPlanningUser.push(qualityPlanningUserList[i].userId);
					}
				}else{
					return alert('품질기획팀인원 찾아오는데 오류 발생');
				}
			},
			error:function(a,b,c){
				//return alert('오류(http error)');
			}
		
		});
		
		var id = $("#userIdDesignArr").val();
		
//		$("#userIdDesignArr").val(id+","+tarId);
		
		var designArr = $("#userIdDesignArr").val().split(",");
		
		html = "";
		
		var length = designArr.length;
		
		if(length == 1){
			var retVal = $.inArray(tarId,qualityPlanningUser);
			
			if(retVal < 0 ){
				alert("디자인의뢰서 1차 검토자는 \n 품질기획팀팀원 입니다.");
				return false;
			}
		}
		
		$("#userIdDesignArr").val(id+","+tarId);
		
		html = '<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>'+(length)+'차 결재</span>  '+$("#userName").val()+'<strong>'+'/'+$("#userId").val()+'/'+$("#deptFulName").val()+'/'+$("#titCodeName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'></li>';
		
		$("#apprLine").append(html);
		
	}else if(name == 'baseApprovalManu'){
		
		/*var marketingUser = [];

		$.ajax({
			url:'/user/marketingUserList',
			type:'post',
			async:false,
			success:function(data){
				if(data.status=='S'){
					var marketingUserList = data.marketingUserList;
			
					for(var i=0;i<marketingUserList.length;i++){
						marketingUser.push(marketingUserList[i].userId);
					}
				
				}else{
					return alert('마케팅팀 인원 찾아오는데 오류 발생');
				}	
			},
			error:function(a,b,c){
				return alert('오류(http error');
			}
		
		});
		
		var ManuCompanyCdArr = $("#ManuCompanyCd").val().split(",");
		
		var IsMl = true;
		
		for(var i=0; i<ManuCompanyCdArr.length; i++){
			if(ManuCompanyCdArr[i] != 'MD'){
				IsMl = false;
				break;
			}
		}
		
		if(IsMl == false){
			if($("#userIdManuArr").val().split(",").length == 1){
				var retVal = $.inArray(tarId,marketingUser);
				
				if(retVal < 0 ){
					alert("제조공정서 1차 검토자는 \n 마케팅 팀원입니다.");
					return false;
				}
			}
		}*/
	
		var id = $("#userIdManuArr").val();
		
		html = "";
		
		$("#userIdManuArr").val(id+","+tarId);
		
		var manuArr = $("#userIdManuArr").val().split(",");
		
		var length = (manuArr.length)-1;
		
		html = '<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>'+(length)+'차 결재</span>  '+$("#userName").val()+'<strong>'+'/'+$("#userId").val()+'/'+$("#deptFulName").val()+'/'+$("#titCodeName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'></li>';
		
		$("#apprLineManu").append(html);
		
	}else if(name === 'baseApprovalTrial'){
		// 시생산 보고서 > 결재라인 추가
		
		var selectedUserName = document.getElementById('userName');
		var selectedUserIdentity = document.getElementById('userId');
		var selectedApprovalLine = document.getElementById('userIdTrialArr');
		var selectedApprovalLineArray = new Array();
		var length = 0;
		
		selectedApprovalLine.value += ',' + selectedUserIdentity.value;
		selectedApprovalLineArray = selectedApprovalLine.value.split(',');
		length = selectedApprovalLineArray.length - 1;
		
		html = '';
		html += '<li>';
		html += '	<img src="../resources/images/icon_del_file.png" name="delImg">';
		html += '	<span>' + (length) + '차 결재</span> ' + selectedUserName.value + '<strong>' + '/' + selectedUserIdentity.value + '/' + $("#deptFulName").val() + '/' + $("#titCodeName").val() + '</strong>';
		html += '	<input type="hidden" value="' + selectedUserIdentity.value + '">';
		html += '</li>';
		
		document.getElementById('apprLineTrial').innerHTML += html;
		document.getElementById('trialKeyword').value = '';
		
	}else if(name == "circulationPayment" || name=="referPayment"){
		if(popupId == 'approval_design'){
			if(name=="referPayment"){

				if($("#userId5").val() == ""){
					$("#userId5").val($("#userId").val());
				}else{
					
					var existId = $("#userId5").val();
					
					$("#userId5").val(existId+","+$("#userId").val());
					
				}
				
				$("#CirculationRefLine").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>참조</span>  '+$("#userName").val()+'<strong>'+'/'+$("#userId").val()+'/'+$("#deptFulName").val()+'/'+$("#titCodeName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="R"></li>');
			}else{
				
				if($("#userId6").val() == ""){
					$("#userId6").val($("#userId").val());
				}else{
					
					var existId = $("#userId6").val();
					
					$("#userId6").val(existId+","+$("#userId").val());
					
				}
				
				$("#CirculationRefLine").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>회람</span>  '+$("#userName").val()+'<strong>'+'/'+$("#userId").val()+'/'+$("#deptFulName").val()+'/'+$("#titCodeName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="C"></li>');
			}
		}else if(popupId == 'approval_trialprodreport'){
			// 시생산 보고서 결재상신
			
			var userId7Trial = document.getElementById('userId7Trial');
			var userId8Trial = document.getElementById('userId8Trial');
			var selectedUserName = document.getElementById('userName');
			var selectedUserIdentity = document.getElementById('userId');
			var thisHTML = '<li>';
			if(name == 'referPayment'){
				// 참조
				userId7Trial.value = userId7Trial.value !== '' ? userId7Trial.value + ',' + selectedUserIdentity.value : selectedUserIdentity.value;
				thisHTML += '	<img src="../resources/images/icon_del_file.png" name="delImg"><span>참조</span>  ' + selectedUserName.value;
				thisHTML += '	<input type="hidden" name="apprType" value="R">';
			}else{
				// 회람
				userId8Trial.value = userId8Trial.value !== '' ? userId8Trial.value + ',' + selectedUserIdentity.value : selectedUserIdentity.value;
				thisHTML += '	<img src="../resources/images/icon_del_file.png" name="delImg"><span>회람</span>  ' + selectedUserName.value;
				thisHTML += '	<input type="hidden" name="apprType" value="C">';
			}
			thisHTML += '	<input type="hidden" name="userId" value="' + selectedUserIdentity.value + '">';
			thisHTML += '	<strong>' + '/' + selectedUserIdentity.value + '/' + jQuery('#deptFulName').val() + '/' + jQuery('#titCodeName').val() + '</strong>';
			thisHTML += '</li>';
			document.getElementById('CirculationRefLineTrial').innerHTML += thisHTML;
			document.getElementById('trialKeyword').value = '';
			
			
		}else{
			
			if(name=="referPayment"){
				if($("#userId7Manu").val() == ""){
					$("#userId7Manu").val($("#userId").val());
				}else{
					
					var existId = $("#userId7Manu").val();
					
					$("#userId7Manu").val(existId+","+$("#userId").val());
					
				}
				
				$("#CirculationRefLineManu").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>참조</span>  '+$("#userName").val()+'<strong>'+'/'+$("#userId").val()+'/'+$("#deptFulName").val()+'/'+$("#titCodeName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="R"></li>');
			}else{
				if($("#userId8Manu").val() == ""){
					$("#userId8Manu").val($("#userId").val());
				}else{

					var existId = $("#userId8Manu").val();

					$("#userId8Manu").val(existId+","+$("#userId").val());

				}

				$("#CirculationRefLineManu").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>회람</span>  '+$("#userName").val()+'<strong>'+'/'+$("#userId").val()+'/'+$("#deptFulName").val()+'/'+$("#titCodeName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="C"></li>');
			}
			
		}
	}else if(name == 'baseApprovalManufacturingNo'){
		// 품목제조보고서 중단요청 결재자 추가
		var id = $("#userIdManufacturingNoArr").val();
		html = "";
		$("#userIdManufacturingNoArr").val(id+","+tarId);
		var manufacturingNoArr = $("#userIdManufacturingNoArr").val().split(",");
		var length = (manufacturingNoArr.length)-1;

		html = '<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>'+(length)+'차 결재</span>  '+$("#userName").val()+'<strong>'+'/'+$("#userId").val()+'/'+$("#deptFulName").val()+'/'+$("#titCodeName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'></li>';

		$("#apprLineManufacturingNo").append(html);
	}else if(name == "circulationPaymentManufacturingNo"){
		// 품목제조보고서 중단요청 회람
		if($("#userId8ManufacturingNo").val() == ""){
			$("#userId8ManufacturingNo").val($("#userId").val());
		}else{
			var existId = $("#userId8ManufacturingNo").val();
			$("#userId8ManufacturingNo").val(existId+","+$("#userId").val());
		}
		$("#CirculationRefLineManufacturingNo").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>회람</span>  '+$("#userName").val()+'<strong>'+'/'+$("#userId").val()+'/'+$("#deptFulName").val()+'/'+$("#titCodeName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="C"></li>');
	}else if(name == "referPaymentManufacturingNo"){
		// 품목제조보고서 중단요청 참조
		if($("#userId7ManufacturingNo").val() == ""){
			$("#userId7ManufacturingNo").val($("#userId").val());
		}else{
			var existId = $("#userId7ManufacturingNo").val();
			$("#userId7ManufacturingNo").val(existId+","+$("#userId").val());
		}

		$("#CirculationRefLineManufacturingNo").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>참조</span>  '+$("#userName").val()+'<strong>'+'/'+$("#userId").val()+'/'+$("#deptFulName").val()+'/'+$("#titCodeName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="R"></li>');
	}
	
	
	
	$("#deptFulName").val('');
   	$("#titCodeName").val('');
    $("#userId").val('');
    $("#userName").val(''); 
    $("#manufacKeyword").val('');
	$("#designKeyword").val('');
	$("#manufacturingNoKeyword").val("");
	/*if(name=="firstPayment"){
		
		html = '<img src="../resources/images/icon_del_file.png" name="delImg"><span>1차 검토</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'>';
		
		if(popupId == "approval_design"){
			var retVal = $.inArray(tarId,drCon);
			
			if(retVal < 0 ){
				alert("디자인의뢰서 1차 검토자는 \n임초롱, 유여린 연구원입니다.");
				return false;
			}
		
		
			if($("#designPayment1 strong").text()!='' && $("#designPayment1 strong").text() != null){
				alert("이미 추가된 1차 결제자가 있습니다.");
				return false;
			}
		
			$("#designPayment1").html(html);
		
			$("#userId2").val($("#userId").val());
		
		}else{
			
			if($("#manufacPayment1 strong").text()!='' && $("#manufacPayment1 strong").text() != null){
				alert("이미 추가된 1차 결제자가 있습니다.");
				return false;
			}
			
			$("#manufacPayment1").html(html);
			
			$("#userId2Manu").val($("#userId").val());
			
		}

	}else if(name=="secondPayment"){
		
		html = '<img src="../resources/images/icon_del_file.png" name="delImg"><span>2차 검토</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'>';
		
		if(popupId == "approval_design"){
			
			if($("#designPayment2 strong").text()!='' && $("#designPayment2 strong").text() != null){
				alert("이미 추가된 2차 결제자가 있습니다.");
				return;
			}
			
			$("#designPayment2").html(html);
			
			$("#userId3").val($("#userId").val());
			
		}else{
			
			if($("#manufacPayment2 strong").text()!='' && $("#manufacPayment2 strong").text() != null){
				alert("이미 추가된 2차 결제자가 있습니다.");
				return false;
			}
			
			$("#manufacPayment2").html(html);
			
			$("#userId3Manu").val($("#userId").val());
			
		}
		
	}else if(name=="marketingPayment"){
		
			
			if($("#designPaymentMarketing strong").text()!='' && $("#designPaymentMarketing strong").text() != null){
				alert("이미 추가된 마케팅 결제자가 있습니다.");
				return;
			}
			
			html = '<img src="../resources/images/icon_del_file.png" name="delImg"><span>마케팅</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'>';
			
			$("#designPaymentMarketing").html(html);
			
			$("#userId4").val($("#userId").val());
			
	}else if(name=="circulationPayment" || name=="referPayment"){
		
		if(popupId == 'approval_design'){
			if(name=="referPayment"){

				if($("#userId5").val() == ""){
					$("#userId5").val($("#userId").val());
				}else{
					
					var existId = $("#userId5").val();
					
					$("#userId5").val(existId+","+$("#userId").val());
					
				}
				
				$("#CirculationRefLine").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>참조</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="R"></li>');
			}else{
				
				if($("#userId6").val() == ""){
					$("#userId6").val($("#userId").val());
				}else{
					
					var existId = $("#userId6").val();
					
					$("#userId6").val(existId+","+$("#userId").val());
					
				}
				
				$("#CirculationRefLine").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>회람</span>'+$("#userName").val()+' <strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="C"></li>');
			}
		}else{
			
			if(name=="referPayment"){
				if($("#userId7Manu").val() == ""){
					$("#userId7Manu").val($("#userId").val());
				}else{
					
					var existId = $("#userId7Manu").val();
					
					$("#userId7Manu").val(existId+","+$("#userId").val());
					
				}
				
				$("#CirculationRefLineManu").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>참조</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="R"></li>');
			}else{
				if($("#userId8Manu").val() == ""){
					$("#userId8Manu").val($("#userId").val());
				}else{
					
					var existId = $("#userId8Manu").val();
					
					$("#userId8Manu").val(existId+","+$("#userId").val());
					
				}
				
				$("#CirculationRefLineManu").append('<li><img src="../resources/images/icon_del_file.png" name="delImg"><span>회람</span>'+$("#userName").val()+' <strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" name="userId" value='+$("#userId").val()+'><input type="hidden" name="apprType" value="C"></li>');
			}
			
		}
		
		
		}else if(name=='parterPayment'){
			if($("#manufacPaymentParter strong").text()!='' && $("#manufacPaymentParter strong").text() != null){
				alert("이미 추가된 파트장 결제자가 있습니다.");
				return;
			}
			
			html = '<img src="../resources/images/icon_del_file.png" name="delImg"><span>파트장</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'>';
			
			$("#manufacPaymentParter").html(html);
			
			$("#userId4Manu").val($("#userId").val());
		}else if(name=='leaderPayment'){
			if($("#manufacPaymentLeader strong").text()!='' && $("#manufacPaymentLeader strong").text() != null){
				alert("이미 추가된 팀장 결제자가 있습니다.");
				return;
			}
			
			html = '<img src="../resources/images/icon_del_file.png" name="delImg"><span>팀장</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'>';
			
			$("#manufacPaymentLeader").html(html);
			
			$("#userId5Manu").val($("#userId").val());
		}else{
			if($("#manufacPaymentDirector strong").text()!='' && $("#manufacPaymentDirector strong").text() != null){
				alert("이미 추가된 연구소장 결제자가 있습니다.");
				return;
			}
			
			html = '<img src="../resources/images/icon_del_file.png" name="delImg"><span>연구소장</span>'+$("#userName").val()+'<strong>'+$("#titCodeName").val()+'/'+$("#deptFulName").val()+'</strong><input type="hidden" value='+$("#userId").val()+'>';
			
			$("#manufacPaymentDirector").html(html);
			
			$("#userId6Manu").val($("#userId").val());
		}*/
	
}

/*function approvalLineSave(obj){
	
	var obj = $(obj);
	
	var lineName = obj.parent().children("input").val();
	
	var tbType = "";
	
	if(lineName =='' || lineName == undefined){
		alert("저장 결제선명 입력하세요!");
		return;
	}
	
	 var CirRefLength = $("#CirculationRefLine li").length; 
	
	var CirRefLength = 0;
	
	var popupId = obj.parents("div.white_content").attr("id");
	
	var Payment1Id = '';
	
	var Payment2Id = '';
	
	if(popupId == 'approval_design'){
		
		CirRefLength = $("#CirculationRefLine li").length;
		Payment1Id = $("#designPayment1 input").val();
		Payment2Id = $("#designPayment2 input").val();
		
	}else{
		
		CirRefLength = $("#CirculationRefLineManu li").length;
		Payment1Id = $("#manufacPayment1 input").val();
		Payment2Id = $("#manufacPayment2 input").val();
		
	}
		
	var PaymentMarketingId = $("#designPaymentMarketing input").val();
	
	var PaymentParterId = $("#manufacPaymentParter input").val();
	
	var PaymentLeaderId = $("#manufacPaymentLeader input").val();
	
	var PaymentDirectorId = $("#manufacPaymentDirector input").val();
	
	if(CirRefLength == 0 && Payment1Id == '' && Payment2Id == ''){
	
		if(popupId == 'approval_design'){
			if(PaymentMarketingId == ''){
				alert("최소 한명 이상 결재선을 지정해주세요.!");
				return;
			}
		}else{
			if(PaymentParterId == '' && PaymentLeaderId == '' && PaymentDirectorId == ''){
				alert("최소 한명 이상 결재선을 지정해주세요.!");
				return;
			}	
		}
	
	}
	
	var targetIdArr = [];
	
	var apprTypeArr = [];
	
	if(Payment1Id != '' && Payment1Id != undefined){
		targetIdArr.push(Payment1Id);
		apprTypeArr.push("2");
	}
	
	if(Payment2Id != '' && Payment2Id != undefined){
		targetIdArr.push(Payment2Id);
		apprTypeArr.push("3");
	}
	
	if(popupId == 'approval_design'){
		
		if(PaymentMarketingId !='' && PaymentMarketingId != undefined){
			targetIdArr.push(PaymentMarketingId);
			apprTypeArr.push("4");
		}
		
	}else{
		
		if(PaymentParterId !='' && PaymentParterId != undefined){
			targetIdArr.push(PaymentParterId);
			apprTypeArr.push("4");
		}
		
		if(PaymentLeaderId !='' && PaymentLeaderId != undefined){
			targetIdArr.push(PaymentLeaderId);
			apprTypeArr.push("5");
		}
		
		if(PaymentDirectorId !='' && PaymentDirectorId != undefined){
			targetIdArr.push(PaymentDirectorId);
			apprTypeArr.push("6");
		}
	}
	
	if(CirRefLength != 0){
		
		for(var i =0; i<CirRefLength; i++){
			
			if(popupId == 'approval_design'){
				targetIdArr.push($("#CirculationRefLine li input[name=userId]").eq(i).val());
				apprTypeArr.push($("#CirculationRefLine li input[name=apprType]").eq(i).val());
			}else{
				targetIdArr.push($("#CirculationRefLineManu li input[name=userId]").eq(i).val());
				apprTypeArr.push($("#CirculationRefLineManu li input[name=apprType]").eq(i).val());
			}
				
		}
		
	}
	
	switch(popupId)
	{
		case "open":
	
		break;
		case "open2":
		
		break;
		case "approval_design":
			tbType = "designRequestDoc";
		break;
		case "approval_manu":
			tbType = "manufacturingProcessDoc";
		default:
			
	}
	
	$.ajax({
		type:"POST",
		url:"/approval/approvalLineSave",
		data:{"lineName": lineName,
			   "tbType":tbType,
			   "targetIdArr":targetIdArr,
			   "apprTypeArr":apprTypeArr},
		dataType:"json",
		async:false,
		traditional:true,
		success:function(data) {
			if(data.status == 'success'){
	        	alert("성공적으로 저장되었습니다	. "+data.nextText+"에게 결재요청하였습니다.");	
				document.location="/dev/productDevDocList";
	        } else if( data.status == 'fail' ){
				alert(data.msg);
	        } else {
	        	alert("오류가 발생하였습니다.");
	        }
		},
		error:function(request, status, errorThrown){
			alert("오류가 발생하였습니다.");
		}			
	});	

}*/

function approvalLineSave(obj){
	
	var obj = $(obj);
	
	var lineName = obj.parent().children("input").val();
	
	var tbType = "";
	
	if(lineName =='' || lineName == undefined){
		alert("저장 결제선명 입력하세요!");
		return;
	}

	var CirRefLength = 0;
	
	var apprLength = 0;
	
	var apprLine = "";
	
	var popupId = obj.parents("div.white_content").attr("id");
	
	var Payment1Id = '';
	
	var Payment2Id = '';
	
	var apprIdArr = [];

	if(popupId == "approval_manufacturingNo"){
		//품목보고서 중단요청
		CirRefLength = $("#CirculationRefLineManufacturingNo li").length;
		apprLength = $("#apprLineManufacturingNo li").length;
		apprLine = "apprLineManufacturingNo";
		apprIdArr = $("#userIdManufacturingNoArr").val().split(",");
	}else if(popupId == 'approval_design'){
		
		CirRefLength = $("#CirculationRefLine li").length;
		
		apprLength = $("#apprLine li").length;
		
		apprLine = "apprLine";
		
		apprIdArr = $("#userIdDesignArr").val().split(",");
	}else if(popupId === 'approval_trialprodreport'){
		// 시생산 보고서
		
		CirRefLength = $("#CirculationRefLineTrial li").length;
		apprLength = $("#apprLineTrial li").length;
		apprLine = "apprLineTrial";
		apprIdArr = $("#userIdTrialArr").val().split(",");
		
	}else{
		
		CirRefLength = $("#CirculationRefLineManu li").length;

		apprLength = $("#apprLineManu li").length;
		
		apprLine = "apprLineManu";
		
		apprIdArr = $("#userIdManuArr").val().split(",");
	}
		
	if(CirRefLength == 0 && apprLength == 0){
		return alert('최소 한명 이상의 결재선을 지정해주셔야 합니다.');
	}
	
	var targetIdArr = [];
	
	var apprTypeArr = [];
	
	for(var i=1; i<apprLength; i++){
		targetIdArr.push(apprIdArr[i]);
		
		apprTypeArr.push(i+1);
	}
	
	if(CirRefLength != 0){
		
		for(var i =0; i<CirRefLength; i++){
			if(popupId == "approval_manufacturingNo"){
				targetIdArr.push($("#CirculationRefLineManufacturingNo li input[name=userId]").eq(i).val());
				apprTypeArr.push($("#CirculationRefLineManufacturingNo li input[name=apprType]").eq(i).val());
			}else if(popupId == 'approval_design'){
				targetIdArr.push($("#CirculationRefLine li input[name=userId]").eq(i).val());
				apprTypeArr.push($("#CirculationRefLine li input[name=apprType]").eq(i).val());
			}else if(popupId == 'approval_trialprodreport'){
				targetIdArr.push($("#CirculationRefLineTrial li input[name=userId]").eq(i).val());
				apprTypeArr.push($("#CirculationRefLineTrial li input[name=apprType]").eq(i).val());
			}else{
				targetIdArr.push($("#CirculationRefLineManu li input[name=userId]").eq(i).val());
				apprTypeArr.push($("#CirculationRefLineManu li input[name=apprType]").eq(i).val());
			}
				
		}
		
	}
	
	switch(popupId){
		
		case "open":
			break;
		case "open2":
			break;
		case "approval_design":
			tbType = "designRequestDoc";
			break;
		case "approval_manu":
			tbType = "manufacturingProcessDoc";
			break;
		case "approval_material":
			tbType = "material";
			break;
		case "approval_trialprodreport":
			tbType = 'trialProductionReport';
			break;
		case "approval_manufacturingNo":
			tbType = 'manufacturingNoStopProcess';
			break;
		default:
			break;
	}
	
	$.ajax({
		type:"POST",
		url:"/approval/approvalLineSave",
		data:{"lineName": lineName,
			   "tbType":tbType,
			   "targetIdArr":targetIdArr,
			   "apprTypeArr":apprTypeArr},
		dataType:"json",
		async:false,
		traditional:true,
		success:function(data) {
			if(data.status == 'success'){

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
	        				alert("성공적으로 저장되었습니다	.");
	        				
	        				var apprLineList = data.approvalLineList;
	        				if(tbType == "manufacturingNoStopProcess"){
								$("#apprLineSelectManufacturingNo").empty();

								$("label[for=apprLineSelectManufacturingNo]").html("----결재선 불러오기----");
								$("#apprLineSelectManufacturingNo").append("<option value=''>---- 결재선 불러오기 ----</option>");

								for(var i=0;i<apprLineList.length;i++){
									$("#apprLineSelectManufacturingNo").append("<option value="+apprLineList[i].apprLineNo+">"+apprLineList[i].lineName+"</option>");
								}
							}else if(tbType == 'designRequestDoc'){
		    	        		$("#apprLineSelect").empty();
		    	        		
		    	        		$("label[for=apprLineSelect]").html("----결재선 불러오기----");
		    	        		$("#apprLineSelect").append("<option value=''>---- 결재선 불러오기 ----</option>");
		    	        		
		    	        		for(var i=0;i<apprLineList.length;i++){
		    	        			$("#apprLineSelect").append("<option value="+apprLineList[i].apprLineNo+">"+apprLineList[i].lineName+"</option>");
		    	        		}
		    	        	}else if(tbType === 'trialProductionReport'){
								
								$("#apprLineSelectTrial").empty();
								$("label[for=apprLineSelectTrial]").html("----결재선 불러오기----");
		    	        		$("#apprLineSelectTrial").append("<option value=''>---- 결재선 불러오기 ----</option>");
		    	        		
		    	        		for(var i=0;i<apprLineList.length;i++){
		    	        			$("#apprLineSelectTrial").append("<option value="+apprLineList[i].apprLineNo+">"+apprLineList[i].lineName+"</option>");
		    	        		}
								
							}else{
		    	        		$("#apprLineSelectManu").empty();
		    	        		
		    	        		$("label[for=apprLineSelectManu]").html("----결재선 불러오기----");
		    	        		$("#apprLineSelectManu").append("<option value=''>---- 결재선 불러오기 ----</option>");
		    	        		
		    	        		for(var i=0;i<apprLineList.length;i++){
		    	        			$("#apprLineSelectManu").append("<option value="+apprLineList[i].apprLineNo+">"+apprLineList[i].lineName+"</option>");
		    	        		}
		    	        	}
	        			}else if(data.status=='F'){
	        				alert(data.msg);
	        			}else{
	        				alert('오류가 발생하였습니다.');
	        			}
	    	        	
	        		},
	        		error:function(request,status,errorThrown){
	        			alert('오류 발생');
	        		}
	        	});
	        	
	        	
	        } else if( data.status == 'fail' ){
				alert(data.msg);
	        } else {
	        	alert("오류가 발생하였습니다.");
	        }
		},
		error:function(request, status, errorThrown){
			alert("오류가 발생하였습니다.");
		}			
	});	

}

function approvalLineCancel(obj){
	
	var obj = $(obj);
	
	obj.parent().children("input").val('');
	
}


function doSubmit(){
	$('#lab_loading').show();
/*	if(!validate()){
		return;
	}	*/
	
	
	var length = $("#userIdDesignArr").val().split(",").length;
	
	if(length <= 1 ){
		alert("결재선을 지정하세요");
		$('#lab_loading').hide();
		return;
	}
	
	if($("#designTitle").val() == ''){
		alert("제목을 입력하세요.");
		$('#lab_loading').hide();
		return;
	}
	
	/*if($("#design_comment").val() == ''){
		alert("의견을 입력하세요.");
		return;
	}*/
	
	var msg = "검토요청하시겠습니까?";
	
	if($("#tbKey").val() == "0"){
		msg = "작성된 디자인의뢰서가 없습니다. 작성요청하시겠습니까?";
	}
	
	var qualityPlanningUser = [];
	$.ajax({
		url:'/user/qualityPlanningUserList',
		type:'post',
		async:false,
		success:function(data){
			if(data.status=='S'){
				var qualityPlanningUserList = data.qualityPlanningUserList;
				
				for(var i=0; i<qualityPlanningUserList.length; i++){
					qualityPlanningUser.push(qualityPlanningUserList[i].userId);
				}
			}else{
				$('#lab_loading').hide();
				return alert('품질기획팀인원 찾아오는데 오류 발생');
			}
		},
		error:function(a,b,c){
			//return alert('오류(http error');
		}
	});
	
	var count = 0;
	for(var i=0; i<qualityPlanningUser.length; i++){
		if($("#apprLine li input").eq(1).val() == qualityPlanningUser[i]){
			count++;
		}
	}
	if( count == 0 ) {
		alert("1차 결재자는 품질기획팀으로 지정되어야 합니다.");
		$('#lab_loading').hide();
		return;
	}
	
	if(confirm(msg)){
		
		$.ajax({
			type:"POST",
			url:"/dev/docReviewRequestSave",
			data:{ "tbType" : "designRequestDoc",
				   "tbKey" : $("#tbKey").val(),
				   "tempKey" : $("#tempKey").val(),
				   "title" :$("#designTitle").val(),
				   "userId2" : $("#userId2").val(),
				   "userId3" : $("#userId3").val(),
				   "userId4" : $("#userId4").val(),
				   "referenceId" : $("#userId5").val(),
				   "circulationId" : $("#userId6").val(),
				   "comment" : $("#design_comment").val(),
				   "userIdDesignArr" : $("#userIdDesignArr").val()
				},
			dataType:"json",
			async:false,
			traditional:true,
			success:function(data) {
				if(data.status == 'S'){
		        	alert("성공적으로 상신되었습니다!");	
					document.location="/dev/productDevDocDetail?docNo="+$("#hiddenDocNo").val()+"&docVersion="+$("#hiddenDocVersion").val();
					$('#lab_loading').hide();
		        } else if( data.status == 'F' ){
		        	$('#lab_loading').hide();
					alert(data.msg);
		        } else {
		        	$('#lab_loading').hide();
		        	alert("상신 실패되었습니다.");
		        }
			},
			error:function(request, status, errorThrown){
				$('#lab_loading').hide();
				alert("상신 실패되었습니다.");
			}	
		});
	} else {
		$('#lab_loading').hide();
	}
}

function doSubmitManu(){
	$('#lab_loading').show();
	
	var user2 = $("#userId2Manu").val();
	var user3 = $("#userId3Manu").val();
	var user4 = $("#userId4Manu").val();		
	var user5 = $("#userId5Manu").val();		
	var user6 = $("#userId6Manu").val();		
	var user7 = $("#userId7Manu").val();		
	var user8 = $("#userId8Manu").val();
	
	var length =  $("#userIdManuArr").val().split(",").length;
	
	if(length <=1){
		alert("결재선을 지정하세요.");
		$('#lab_loading').hide();
		return;
	}
	
	if($("#launchDateManu").val()==""){
		alert("제품 출시일을 지정하세요.");
		$('#lab_loading').hide()
		return;
	}

	
	if($("#manuTitle").val() ==""){
		$("#manuTitle").focus();
		$('#lab_loading').hide()
		return alert("결재 제목을 입력하세요.");
	}
	
	if(confirm("상신하시겠습니까?")){
		
		$.ajax({
			type:"POST",
			url:"/dev/approvalBoxSave",
			data:{ "tbType" : "manufacturingProcessDoc",
				   "tbKey" : $("#tbKeyManu").val(),
				   "type" : $("#typeManu").val(),
				   "totalStep" : $("#totalStepManu").val(),
				   "title" : $("#manuTitle").val(),
				   "userId1" :$("#userId1Manu").val(),
				   "userId2" : user2,
				   "userId3" : user3,
				   "userId4" : user4,
				   "userId5" : user5,
				   "userId6" : user6,
				   "referenceId" : user7,
				   "circulationId" : user8,
				   "launchDate" : $("#launchDateManu").val(),
				   "docNo" : $("#docNoManu").val(),
				   "docVersion" : $("#docVersionManu").val(),
				   "userIdManuArr" : $("#userIdManuArr").val(),
				   "comment" : $("#manu_comment").val()
				},
			dataType:"json",
			async:false,
			traditional:true,
			success:function(data) {
				if(data.status == 'S'){
		        	alert("성공적으로 상신되었습니다!");	
		        	document.location="/dev/productDevDocDetail?docNo="+$("#hiddenDocNo").val()+"&docVersion="+$("#hiddenDocVersion").val();
		        } else if( data.status == 'F' ){
					alert(data.msg);
		        } else {
		        	alert("상신 실패되었습니다.");
		        }
				$('#lab_loading').hide()
			},
			error:function(request, status, errorThrown){
				alert("상신 실패되었습니다.");
				$('#lab_loading').hide()
			}	
		});
		
	} else {
		$('#lab_loading').hide();
	}
}

function doSubmitTrial(){
	$('#lab_loading').show();
	
	var user2 = $("#userId2Trial").val();
	var user3 = $("#userId3Trial").val();
	var user4 = $("#userId4Trial").val();		
	var user5 = $("#userId5Trial").val();		
	var user6 = $("#userId6Trial").val();		
	var user7 = $("#userId7Trial").val();		
	var user8 = $("#userId8Trial").val();
	
	var length =  $("#userIdTrialArr").val().split(",").length;
	
	if(length <= 1){
		alert("결재선을 지정하세요.");
		$('#lab_loading').hide();
		return;
	}
	
	if($("#trialTitle").val() ==""){
		$("#trialTitle").focus();
		$('#lab_loading').hide()
		return alert("결재 제목을 입력하세요.");
	}
	
	if(confirm("상신하시겠습니까?")){
		
		$.ajax({
			async : false,
			type : "POST",
//			traditional : true,
			url : "/dev/approvalBoxSaveTrial",
			dataType : "json",
			data : {
				"tbType" : "trialProductionReport",
				"tbKey" : $("#tbKeyTrial").val(),
				"type" : $("#typeTrial").val(),
				"totalStep" : $("#totalStepTrial").val(),
				"userId1" : $("#userId1Trial").val(),
				"userId2" : user2,
				"userId3" : user3,
				"userId4" : user4,
				"userId5" : user5,
				"userId6" : user6,
				"referenceId" : user7,
				"circulationId" : user8,
				"docNo" : $("#docNoTrial").val(),
				"docVersion" : $("#docVersionTrial").val(),
				"userIdTrialArr" : $("#userIdTrialArr").val(),
				"title" : $("#trialTitle").val(),
				"comment" : $("#trialComment").val()
			},
			success : function(data) {
				if(data.status == 'S'){
					alert("성공적으로 상신되었습니다!");
					document.location="/dev/productDevDocDetail?docNo="+$("#hiddenDocNo").val()+"&docVersion="+$("#hiddenDocVersion").val();
		        } else if( data.status == 'F' ){
					alert(data.msg);
		        } else {
		        	alert("상신 실패되었습니다.");
		        }
				$('#lab_loading').hide()
			},
			error:function(request, status, errorThrown){
				alert("상신 실패되었습니다.");
				$('#lab_loading').hide()
			}	
		});
		
	} else {
		$('#lab_loading').hide();
	}
}

/*function validate(){
	if($("#userId2").val() == ""){
		alert("1차 검토자를 지정하세요.");
		return false;
	}
	
	if($("#userId3").val() == ""){
		alert("2차 검토자를 지정하세요.");
		return false;
	}
	
	if($("#userId4").val() == ""){
		alert("마케팅 담당자를 지정하세요.");
		return false;
	}
	
	if($("#designTitle").val() == ""){
		alert("제목을 입력하세요.");
		$("#designTitle").focus();
		return false;
	}
	
	if($("#design_comment").val()==""){
		alert("결재 의견을 입력해주세요.");
		$("#design_comment").focus();
		return false;
	}
	
	return true;
}*/

function doSubmitManufacturingNo(callback){
    $('#lab_loading').show();

    var user2 = $("#userId2ManufacturingNo").val();
    var user3 = $("#userId3ManufacturingNo").val();
    var user4 = $("#userId4ManufacturingNo").val();
    var user5 = $("#userId5ManufacturingNo").val();
    var user6 = $("#userId6ManufacturingNo").val();
    var user7 = $("#userId7ManufacturingNo").val();
    var user8 = $("#userId8ManufacturingNo").val();

    var length =  $("#userIdManufacturingNoArr").val().split(",").length;

    if(length <= 1){
        alert("결재선을 지정하세요.");
        $('#lab_loading').hide();
        return;
    }

    if($("#stopMonthManufacturingNo").val()==""){
        alert("제품 중단월을 지정하세요.");
        $('#lab_loading').hide()
        return;
    }


    if($("#ManufacturingNoTitle").val() ==""){
        $("#ManufacturingNoTitle").focus();
        $('#lab_loading').hide()
        return alert("결재 제목을 입력하세요.");
    }

    if(confirm("상신하시겠습니까?")){

        $.ajax({
            type:"POST",
            url:"/dev/approvalBoxSaveManufacturingNoStop",
            data:{ "tbType" : "manufacturingNoStopProcess", //"manufacturingProcessDoc",
                "tbKey" : $("#tbKeyManufacturingNo").val(),
                "type" : $("#typeManufacturingNo").val(),		// 0 일반결재; 3 프린트결재
                "title" : $("#ManufacturingNoTitle").val(),
                "userId1" :$("#userId1ManufacturingNo").val(),
                // "userId2" : user2,
                // "userId3" : user3,
                // "userId4" : user4,
                // "userId5" : user5,
                // "userId6" : user6,
                "referenceId" : user7,
                "circulationId" : user8,
                "stopMonth" : $("#stopMonthManufacturingNo").val(),
                "docNo" : $("#docNoManufacturingNo").val(),
                "docVersion" : $("#docVersionManufacturingNo").val(),
                "userIdManuArr" : $("#userIdManufacturingNoArr").val(),
                "comment" : $("#manufacturingNo_comment").val()
            },
            dataType:"json",
            async:false,
            traditional:true,
            success:function(data) {
                if(data.status == 'S'){
                    alert("성공적으로 상신되었습니다!");
					if(callback == null){
						if(isNull($("#hiddenDocNo").val()) != "" && isNull($("#hiddenDocVersion").val()) != ""){
							document.location="/dev/productDevDocDetail?docNo="+$("#hiddenDocNo").val()+"&docVersion="+$("#hiddenDocVersion").val();
						}else{
							document.location.reload();
						}
					}else{
						callback();
					}
                } else if( data.status == 'F' ){
                    alert(data.msg);
                } else {
					console.log(data);
                    alert("상신 실패되었습니다.");
                }
                $('#lab_loading').hide()
            },
            error:function(request, status, errorThrown){
	            console.log(request);
	            console.log(status);
	            console.log(errorThrown);
                alert("오류(http error)");
                $('#lab_loading').hide()
            }
        });

    } else {
        $('#lab_loading').hide();
    }
}

/*<!-- Builder 개발서버 반영 원복 재실행을 위한 주석 추가 -->*/