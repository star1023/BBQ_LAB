<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="kr.co.genesiskorea.util.*, org.json.simple.*" %>   
<%
String userId = UserUtil.getUserId(request);
String userName = UserUtil.getUserName(request);
//String userGrade = UserUtil.getUserGrade(request);
//String userDept = UserUtil.getDeptCode(request);
//String userTeam = UserUtil.getTeamCode(request);
//String userGradeName = UserUtil.getUserGradeName(request);
//String userDeptName = UserUtil.getDeptCodeName(request);
//String userTeamName = UserUtil.getTeamCodeName(request);
//String isAdmin = UserUtil.getIsAdmin(request);
String theme = UserUtil.getTheme(request);
String contentMode = UserUtil.getContentMode(request);
String widthMode = UserUtil.getWidthMode(request);
JSONArray USER_MENU = (JSONArray)session.getAttribute("USER_MENU");
%>    
<header>
	<nav>
		<div class="main_nav" id="topBar">
			<div  class="menu_position01">
				<!--로고-->
				<a href="../main/main"><h1></h1></a>
				<!-- 추후 수정될 가능성 높음/ 메뉴가 많아질경우 테마 조정 필요 -->
				<ul id="menuDiv" class="main_menu" style=""></ul>
			</div>
		</div>
	</nav>
</header>
<!--header close-->
				<!-- 퀵메뉴 팝업 start-->
				<!-- 퀵메뉴 개인설정 start-->
				<!-- 추후에 삭제되거나 홈아이콘으로 변경될 수 있음 -->
				<div class="cbp-spmenu cbp-spmenu-vertical cbp-spmenu-left" id="cbp-spmenu-s1">
					<h3><span class="title">개인설정</span><span class="right_box"><a href="javascript:resetleftLi();" id="showClose"><img src="../resources/images/btn_quick_close.png" alt="닫기"></a></span></h3>
					<div class="group03 pop"></div>
				</div>
				<!-- 퀵메뉴 개인설정 close-->
				<!-- 퀵메뉴 알림설정 start-->
				<div class="cbp-spmenu cbp-spmenu-vertical cbp-spmenu-left" id="cbp-spmenu-s2">
					<h3><span class="title">알림</span><span class="right_box"><a href="javascript:resetleftLi();" id="showClose2"><img src="../resources/images/btn_quick_close.png" alt="닫기"></a></span></h3>
					<div class="group03 pop" style=" height:100%; ">
						<ul class="pop_notice_con" id="notiList">
						<!-- 알림종류에 따라서 title01/02/03/04 를 사용해주세요  -->
							<li>
								<span class="title01">제품개발문서</span><br/>신선한 생크림빵 문서가 <strong>수정</strong>되었습니다.<span class="icon_new">N</span><br/>


								<span class="date">2019.01.12 02:02:02</span>
							</li>
							<li>
								<span class="title02">제품개발문서</span><br/>신선한 생크림빵 문서가 <strong>수정</strong>되었습니다.<span class="icon_new">N</span><br/>
								<span class="date">2019.01.12 02:02:02</span>
							</li>
							<li>
								<span class="title03">제품개발문서</span><br/>신선한 생크림빵 문서가 <strong>수정</strong>되었습니다.<span class="icon_new">N</span><br/>
								<span class="date">2019.01.12 02:02:02</span>
							</li>
								<li>
								<span class="title04">제품개발문서</span><br/>신선한 생크림빵 문서가 <strong>수정</strong>되었습니다.<span class="icon_new">N</span><br/>
								<span class="date">2019.01.12 02:02:02</span>
							</li>
							<li>
								<span class="title01">제품개발문서</span><br/>신선한 생크림빵 문서가 <strong>수정</strong>되었습니다.<span class="icon_new">N</span><br/>
								<span class="date">2019.01.12 02:02:02</span>
							</li>
							<li>
								<span class="title02">제품개발문서</span><br/>신선한 생크림빵 문서가 <strong>수정</strong>되었습니다.<span class="icon_new">N</span><br/>
								<span class="date">2019.01.12 02:02:02</span>
							</li>
							<li>
								<span class="title03">제품개발문서</span><br/>신선한 생크림빵 문서가 <strong>수정</strong>되었습니다.<span class="icon_new">N</span><br/>
								<span class="date">2019.01.12 02:02:02</span>
							</li>
								<li>
								<span class="title04">제품개발문서</span><br/>신선한 생크림빵 문서가 <strong>수정</strong>되었습니다.<span class="icon_new">N</span><br/>
								<span class="date">2019.01.12 02:02:02</span>
							</li>
							<li>
								<span class="title01">제품개발문서</span><br/>신선한 생크림빵 문서가 <strong>수정</strong>되었습니다.<span class="icon_new">N</span><br/>
								<span class="date">2019.01.12 02:02:02</span>
							</li>
							<li>
								<span class="title02">제품개발문서</span><br/>신선한 생크림빵 문서가 <strong>수정</strong>되었습니다.<span class="icon_new">N</span><br/>
								<span class="date">2019.01.12 02:02:02</span>
							</li>
							<li>
								<span class="title03">제품개발문서</span><br/>신선한 생크림빵 문서가 <strong>수정</strong>되었습니다.<span class="icon_new">N</span><br/>
								<span class="date">2019.01.12 02:02:02</span>
							</li>
								<li>
								<span class="title04">제품개발문서</span><br/>신선한 생크림빵 문서가 <strong>수정</strong>되었습니다.<span class="icon_new">N</span><br/>
								<span class="date">2019.01.12 02:02:02</span>
							
							</li>
							<!-- 기간은 알아서 조정해주세요 -->
							<li><span class="notice_none">알림은 최근 3일치만 제공합니다.</span></li>
							<li><span class="notice_none">등록된 알림이 없습니다.</span></li>

						</ul>
					
				
					
					</div>
				</div>
				<!-- 퀵메뉴 알림설정 close-->
				<!-- 퀵메뉴 테마설정 start-->
				<div class="cbp-spmenu cbp-spmenu-vertical cbp-spmenu-left" id="cbp-spmenu-s3">
					<h3><span class="title">테마설정</span><span class="right_box"><a href="javascript:resetleftLi();" id="showClose3"><img src="../resources/images/btn_quick_close.png" alt="닫기"></a></span></h3>
					<div class="group05 pop">
						<ul class="theme_cont">
							<li>
								<dt>스킨</dt>
								<dd><span class="theme_cont_title">컬러선택</span>
									<ul class="theme_choice">
										<li class="theme_color01"><button onClick="stepchage('theme','theme01');setPersonalization('theme','theme01');" class="btn_theme01"></button></li>
										<li class="theme_color02"><button onClick="stepchage('theme','theme02');setPersonalization('theme','theme02');" class="btn_theme02"></button></li>
										<li class="theme_color03"><button onClick="stepchage('theme','theme03');setPersonalization('theme','theme03');" class="btn_theme03"></button></li>
										<li class="theme_color04"><button onClick="stepchage('theme','theme04');setPersonalization('theme','theme04');" class="btn_theme04"></button></li>
										<li class="theme_color05"><button onClick="stepchage('theme','theme05');setPersonalization('theme','theme05');" class="btn_theme05"></button></li>
									</ul>
						</dd>
					</li>
				<li>
						<dt>인터페이스</dt>
						<dd>
							<span class="theme_cont_title">심플컨텐츠 모드</span>
							<span class="theme_cont_btnbox">
								<button  onClick="stepchage('content_d','content_theme01');setPersonalization('contentMode','content_theme01');" class="btn_cont01"></button><button  onClick="stepchage('content_d','content_theme02');setPersonalization('contentMode','content_theme02');" class="btn_cont02"></button>
								</span>
						<span class="theme_exp">심플 컨텐츠 모드 활성화시, 상하단의 여백을 최소화하여 밀도있는 화면을 지원합니다.</span>
						<span class="exp_img">&nbsp;</span>
	

						
						<hr/>
						<span class="theme_cont_title">화면 최대화</span>
						<span class="theme_cont_btnbox">
								<button  onClick="stepchage('width_wrap','wrap_in01');setPersonalization('widthMode','wrap_in01');"class="btn_extend"></button><button  onClick="stepchage('width_wrap','wrap_in02');setPersonalization('widthMode','wrap_in02');" class="btn_reduce"></button>
								</span>
							<span class="theme_exp">화면 최대화 활성화시, 좌우 여백없이 모니터의 해상도에 맞춰 컨텐츠가 배치됩니다.</span>
						<span class="exp_img02">&nbsp;</span>
						</dd>
					</li>
				
					</ul>
					<!--div class="submit_report"><button class="btn_b_red">요청서 등록</button></div-->
					 </div>
					
				</div>
			<!-- 퀵메뉴 팝업 close-->
 			<!-- 퀵메뉴 start--> 
			<aside>
		 		<section class="quick">
					<ul class="quick_menu">
						<!--a onClick="javascript:;" id="showLeft" class="tooltip" title="개인설정"><li class="select"><dd><img src="../resources/images/icon_quick01.png"></dd><dt></dt></li></a--><!-- 개인설정-->
						<!-- 알림이 있을경우는 dt에 class명 bell02 / 없을경우는 01 -->
						<!-- a onClick="javascript:;" id="showLeft2" class="tooltip" title="알림"><li><dd><img src="../resources/images/icon_quick02.png"></dd><dt id="notiCount" class="bell01">0</dt></li></a--><!--알림-->
						<!-- a onClick="javascript:;" id="showLeft3" class="tooltip" title="테마설정"><li><dd><img src="../resources/images/icon_quick03.png"></dd><dt></dt></li></a--><!--테마설정-->
						<!-- 
						<a href="javascript:openCreateMaterial();" class="tooltip" title="자재생성"><li><dd><img src="../resources/images/icon_quick05.png"></dd><dt></dt></li></a>
						<a href="javascript:openCallMaterial();" class="tooltip" title="자재호출"><li><dd><img src="../resources/images/icon_quick06.png"></dd><dt></dt></li></a>
						 -->
						<a href="../user/logout" class="tooltip" title="로그아웃"><li><dd><img src="../resources/images/icon_quick04.png"></dd><dt></dt></li></a><!-- 로그아웃-->
					</ul>
				</section>
			</aside>
			
			<!-- 원료 선택 레이어 start-->
			<div class="white_content" id="dialog_noti">
				<div class="modal" style="	width: 400px;margin-left:-210px;height: 350px;margin-top:-200px;">
					<h5 style="position:relative">
						<span class="title">알림</span>
						<div class="top_btn_box">
							<ul>
								<li>
									<button class="btn_madal_close" onClick="closeDialog('dialog_noti')"></button>
								</li>
							</ul>
						</div>
					</h5>
					<div style="height: 200px; overflow-x: hidden; overflow-y: auto;">
						<ul id="popNoti" class="pop_notice_con history_option">
						</ul> 
					</div>
					<div class="btn_box_con">
						<button class="btn_small02" onclick="closeDialog('dialog_noti')"> 취소</button>
					</div>
				</div>
			</div>
			<!-- 원료 선택 레이어 close-->

			<script src="../../resources/js/classie.js"></script>
			<script>
			$(document).ready(function(){
				setHeaderMenu();
				stepchage('theme','theme02');
				//loadNotificationCount();
				//setInterval(loadNotificationCount, 300000);
				
				 $('.tooltip').tooltipster({
					    theme: 'tooltipster-light',
					    side : 'right'
				 });
				 
				const eventSource = new EventSource('/subscribe/<%=userId%>');
				window.addEventListener("beforeunload", function () {
				    if (eventSource) {
				        eventSource.close();
				    }
				});
				eventSource.addEventListener("sse", function (event) {
			    	console.log(event.data);
			    	if( event.data == '<%=userId%>' ) {
			    		var URL = "../common/readNotificationAjax";
						$.ajax({
							type:"POST",
							url:URL,
							data:{
								"userId" : event.data
							},
							dataType:"json",
							success:function(data) {
								console.log(data);
								if( data.length > 0 ) {
									var html = "";
									data.forEach(function (item) {
										html += "<li>";
										html += item.NOTI_IDX+" / "+item.TYPE+item.TYPE_TXT+item.MESSAGE;
										html += "</li>";
									});									
									$("#popNoti").html(html);
									openDialog('dialog_noti');	
								}
							},
							error:function(request, status, errorThrown){
							}			
						});
			    		
			    	} else if( event.data == 'ALL' ){
			    		openDialog('dialog_noti');
			    	} else if( event.data == 'FIRST' ){
			    		var URL = "../common/readNotificationAjax";
						$.ajax({
							type:"POST",
							url:URL,
							data:{
								"userId" : '<%=userId%>'
							},
							dataType:"json",
							success:function(data) {
								console.log(data);
								if( data.length > 0 ) {
									var html = "";
									data.forEach(function (item) {
										html += "<li>";
										html += item.NOTI_IDX+" / "+item.TYPE+item.TYPE_TXT+item.MESSAGE;
										html += "</li>";
									});									
									$("#popNoti").html(html);
									openDialog('dialog_noti');	
								}
							},
							error:function(request, status, errorThrown){
							}			
						});
			    	}
			    });
			});	
			
			function setPersonalization(type,value) {
				var URL = "../user/setPersonalizationAjax";
				$.ajax({
					type:"POST",
					url:URL,
					data:{
						"type" : type,
						"value" : value
					},
					dataType:"json",
					success:function(data) {
						
					},
					error:function(request, status, errorThrown){
					}			
				});	
			}
			
			function loadNotificationCount() {
				/*
				var URL = "../common/notificationCountAjax";
				var requestPath = "${requestScope['javax.servlet.forward.servlet_path']}";
				$.ajax({
					type:"POST",
					url:URL,
					data:{
					},
					dataType:"json",
					success:function(data) {
						if( data.notiCount > 0 ) {
							$("#notiCount").html(data.notiCount);
							$("#notiCount").prop('class','bell02');
							if(requestPath.split('/')[1] == 'main'){
								$("#main_bell").html(data.notiCount);
								$("#main_bell").prop('class','bell02');
							}
						} else {
							$("#notiCount").html("0");
							$("#notiCount").prop('class','bell01');
							if(requestPath.split('/')[1] == 'main'){
								$("#main_bell").html("0");
								$("#main_bell").prop('class','bell01');
							}
						}
					},
					error:function(request, status, errorThrown){
						$("#notiCount").html("0");
						$("#notiCount").prop('class','bell01');
						if(requestPath.split('/')[1] == 'main'){
							$("#main_bell").html("0");
							$("#main_bell").prop('class','bell01');
						}
					}			
				});	
				*/
			}
			
			function loadNotificationList() {
				var URL = "../common/notificationListAjax";
				$.ajax({
					type:"POST",
					url:URL,
					data:{
					},
					dataType:"json",
					success:function(data) {
						var list = data;
						var html = "";
						$("#notiList").html(html);
						if( list.length > 0 ) {
							var nIdArray = new Array();
							list.forEach(function (item) {
								html += "<li>";
								html += "	<span class=\"title"+item.type+"\">"+item.typeText+"</span><br/>";
								html += "	"+item.message;
								if( item.isRead == 'N' ) {
									html += "	<span class=\"icon_new\">N</span><br/>";
									nIdArray.push(item.nId);
								} else {
									html += "	<span class=\"icon_new\"></span><br/>";
								}
								html += "	<span class=\"date\">"+item.regDate+"</span>";
								html += "</li>";
								
							});
							html += "<li><span class=\"notice_none\">알림은 최근 3일치만 제공합니다.</span></li>";
							$("#notiList").html(html);
							updateNotificationData(nIdArray);
						} else {
							html += "<li><span class=\"notice_none\">알림은 최근 3일치만 제공합니다.</span></li>";
							html += "<li><span class=\"notice_none\">등록된 알림이 없습니다.</span></li>";
							$("#notiList").html(html);
						}
					},
					error:function(request, status, errorThrown){
						var html = "";
						$("#notiList").html("");
						html += "<li><span class=\"notice_none\">오류가 발생하였습니다.</span></li>";
						html += "<li><span class=\"notice_none\">알림은 최근 3일치만 제공합니다.</span></li>";
						html += "<li><span class=\"notice_none\">등록된 알림이 없습니다.</span></li>";
						$("#notiList").html(html);
					}			
				});	
			}
			
			function updateNotificationData(nIdArray) {
				var URL = "../common/updateNotificationAjax";
				$.ajax({
					type:"POST",
					url:URL,
					data:{
						"nId":nIdArray
					},
					traditional : true,
					dataType:"json",
					success:function(data) {
						loadNotificationCount();
					},
					error:function(request, status, errorThrown){
						
					}			
				});	
			}
			
			function openCreateMaterial() {
				openDialog('createMaterial');
				$("#mat_name").val("[임시]");
				$("#mat_sapCode").val("");
				$("mat_company").removeOption(/./);
				loadMatCompany('mat_company');
				$("#mat_company").selectOptions("");
				$("#mat_plant").removeOption(/./);
				$("#mat_plant").selectOptions("");
				$("#mat_price").val("");
				loadMatUnit();
				$("mat_unit").selectOptions("");
				$("input:radio[name='mat_type'][value='B']").prop('checked', true);
				$("#mat_create").show();
				$("#mat_update").hide();
			}
			
			function closeCreateMaterial() {
				closeDialog('createMaterial');
				matClear();
			} 
			
			function openCallMaterial() {
				matClear();
				openDialog('callMaterial');
				loadMatCompany('mat_company2');
			}
			
			function closeCallMaterial() {
				closeDialog('callMaterial');
				matClear();
			} 
			
			function loadMatCompany(selectBoxId) {
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
						$.each(list, function( index, value ){ //배열-> index, value
							$("#"+selectBoxId).addOption(value.companyCode, value.companyName, false);
						});
					},
					error:function(request, status, errorThrown){
							alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
					}			
				});
			}
			function loadMatUnit() {
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
						$("#mat_unit").removeOption(/./);
						$("#mat_unit").addOption("", "전체", false);
						$.each(list, function( index, value ){ //배열-> index, value
							$("#mat_unit").addOption(value.unitCode, value.unitName, false);
						});
					},
					error:function(request, status, errorThrown){
							alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
					}			
				});
			}
			
			function matCompanyChange(companySelectBoxId, selectBoxId) {
				var URL = "../common/plantListAjax";
				$.ajax({
					type:"POST",
					url:URL,
					data:{
						"companyCode" : $("#"+companySelectBoxId).selectedValues()[0]
					},
					dataType:"json",
					async:false,
					success:function(data) {
						var list = data.RESULT;
						$("#"+selectBoxId).removeOption(/./);
						$("#"+selectBoxId).addOption("", "전체", false);
						$.each(list, function( index, value ){ //배열-> index, value
							$("#"+selectBoxId).addOption(value.plantCode, value.plantName, false);
						});
						
					},
					error:function(request, status, errorThrown){
							alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
					}			
				});
			}
			
			//입력확인
			function goMatInsert(){
				if( !chkNull($("#mat_name").val()) || $("#mat_name").val() == "[임시]" ) {
					alert("자재명을 입력하여 주세요.");
					$("#mat_name").focus();
					return;
				} else if ($("#mat_name").val().indexOf("[임시]") == -1) {
					alert("자재명은 [임시]를 포함해야 합니다.");
					$("#mat_name").val("[임시]"+$("#mat_name").val());
					$("#mat_name").focus();			
					return;
				} else if( !chkNull($("#mat_sapCode").val()) ) {
					alert("SAP 코드를 입력하여 주세요.");
					$("#mat_sapCode").focus();
					return;
				} else if( $("#mat_company").selectedValues()[0] == '' ) {
					alert("회사를 선택하여 주세요.");
					$("#mat_company").focus();
					return;
				} else if( $("#mat_plant").selectedValues()[0] == '' ) {
					alert("공장을 선택하여 주세요.");
					$("#mat_plant").focus();
					return;
				} else if( !chkNull($("#mat_price").val()) ) {
					alert("단가를 입력하여 주세요.");
					$("#mat_price").focus();
					return;
				} else if( $("#mat_unit").selectedValues()[0] == '' ) {
					alert("단위를 선택하여 주세요.");
					$("#mat_unit").focus();
					return;
				} else {
					var URL = "../material/materialCountAjax";
					$.ajax({
						type:"POST",
						url:URL,
						data:{"sapCode":$("#mat_sapCode").val(),
							"company": $("#mat_company").selectedValues()[0],
							"plant": $("#mat_plant").selectedValues()[0]
						},
						dataType:"json",
						success:function(result) {
							if( result.RESULT >= 1) {
								alert("이미 존재하는 SAP코드입니다.");
							    return;
							} else {
								URL = "../material/insertAjax";
								$.ajax({
									type:"POST",
									url:URL,
									data:{"name":$("#mat_name").val() , "sapCode":$("#mat_sapCode").val(),
										"company": $("#mat_company").selectedValues()[0],"plant": $("#mat_plant").selectedValues()[0],
										"price": $("#mat_price").val(),"unit": $("#mat_unit").selectedValues()[0],
										"type": $(":input:radio[name=mat_type]:checked").val()						
									},
									dataType:"json",
									success:function(result) {
										if(result.status == 'success'){
								        	alert("생성되었습니다.");	
								        	matClear();
								        	closeDialog("createMaterial");					        	
								        } else if( result.status == 'fail' ){
											alert(result.msg);
								        } else {
								        	alert("오류가 발생하였습니다.");
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
			
			function goMatRfcCall(){
				if(  !chkNull($("#mat_company2").selectedValues()[0]) ) {
					alert("회사를 선택해 주세요.");
					$("#mat_company2").focus();
					return;
				} else if( !chkNull($("#mat_sapCode2").val()) ) {
					alert("자재코드 입력하여 주세요.");
					$("#mat_sapCode2").focus();
					return;
				} else {
					$('#lab_loading').show();
					var URL = "../material/rfcCallAjax";
					$.ajax({
						type:"POST",
						url:URL,
						data:{"company":$("#mat_company2").selectedValues()[0], "sapCode":$("#mat_sapCode2").val()},
						dataType:"json",
						async:false,
						success:function(result) {
							if(result.status == 'success'){
								alert(result.msg);
								closeCallMaterial();
					        } else if( result.status == 'fail' ){
								alert(result.msg);
					        } else {
					        	alert("오류가 발생하였습니다.");
					        }
							$('#lab_loading').hide();
						},
						error:function(request, status, errorThrown){
							alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
							$('#lab_loading').hide();
						}			
					});	
				}
			}
			
			function matClear() {
				$("#mat_name").val("[임시]");
				$("#mat_sapCode").val(""),
				$("#mat_company_label").html("선택");
				$("#mat_company").selectOptions("");
				$("#mat_plant_label").html("선택");
				$("#mat_plant").selectOptions("");
				$("#mat_price").val("");
				$("#mat_unit_label").html("선택");
				$("#mat_unit").selectOptions("");
				$("#mat_sapCode2").val("");
				$("#mat_company2_label").html("선택");
				$("#mat_company2").selectOptions("");
			}

			// 개인설정 팝업 호출
			$('#showLeft').click(function(){
				// 초기화
				resetleftLi();
				$(this).addClass('active');
				$('#cbp-spmenu-s1').addClass('cbp-spmenu-open');
			});

			// 알림 팝업 호출
			$('#showLeft2').click(function(){
				// 초기화
				resetleftLi();
				loadNotificationList();
				$(this).addClass('active');
				$('#cbp-spmenu-s2').addClass('cbp-spmenu-open');
			});

			// 전화요청 작성 팝업 호출
			$('#showLeft3').click(function(){
				// 초기화
				resetleftLi();
				$(this).addClass('active');
				$('#cbp-spmenu-s3').addClass('cbp-spmenu-open');
			});
			
			// left 팝업 리셋
			function resetleftLi(){
				$('.quick_menu li').each(function(){
					$(this).removeClass('select');
				});
				$('.quick_menu a').each(function(){
					$(this).removeClass('active');
				});

				if($('#cbp-spmenu-s1').hasClass('cbp-spmenu-open')){
					$('#cbp-spmenu-s1').removeClass('cbp-spmenu-open');
				}
				if($('#cbp-spmenu-s2').hasClass('cbp-spmenu-open')){
					$('#cbp-spmenu-s2').removeClass('cbp-spmenu-open');
				}
				if($('#cbp-spmenu-s3').hasClass('cbp-spmenu-open')){
					$('#cbp-spmenu-s3').removeClass('cbp-spmenu-open');
				}
			}
			
			function setHeaderMenu(){
				var USER_MENU = '${USER_MENU}'; // 로그인 시 session에 저장되어있는 메뉴목록 (JSON형식 String)
				var userMenuList = JSON.parse(USER_MENU);
				
				userMenuList.forEach(function(menu){
					var menuCode = menu.menuId;
					var depth = menu.level;
					var url = menu.url;
					var name = menu.menuName;
					var sortOrder = menu.displayOrder;
					
					if(depth == 1){
						var parent_li_a = document.createElement("a");
						parent_li_a.setAttribute("href", url);
						// parent_li_a.appendChild(name);
						parent_li_a.innerText = name;

						var parent_li = document.createElement("li");
						parent_li.appendChild(parent_li_a);
						
						// var childMenuList = userMenuList.filter(childMenu => menuCode == childMenu.PARENT_CODE);
						var childMenuList = userMenuList.filter(function(childMenu){
							return (menuCode == childMenu.pMenuId);
						});

						if(childMenuList.length > 0){
							var child_ul = document.createElement("ul");
							// childMenuList.map( childMenu => {
							childMenuList.map(function(childMenu){
								var child_li_a = document.createElement("a");
								child_li_a.setAttribute("href", childMenu.url);
								// child_li_a.appendChild(childMenu.MENU_NAME);
								child_li_a.innerText = childMenu.menuName;

								var child_li = document.createElement("li");
								child_li.appendChild(child_li_a);
								
								child_ul.appendChild(child_li);
							} )
							parent_li.appendChild(child_ul);
						}
						
						var menuDiv = document.getElementById("menuDiv")
						menuDiv.appendChild(parent_li);
					}
				});
			}
		</script>
