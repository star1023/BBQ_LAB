<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<html class="skin_red">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
<title>BBQ세계식문화과학기술원</title>
	<!-- <link href="/resources/css/common.css" rel="stylesheet" type="text/css" />
	<link href="/resources/css/layout.css" rel="stylesheet" type="text/css" /> -->
	<link rel="shortcut icon" href="/resources/images/favicon.ico"/>
	<link rel="stylesheet" href="/resources/css/login/common.css" type="text/css" />
	<link rel="stylesheet" href="/resources/css/login/component.css" type="text/css" />
	<link rel="stylesheet" href="/resources/css/login/page.css" type="text/css" />
	<link rel="stylesheet" href="/resources/css/login/skinSwitcher.css" type="text/css" />
	<link rel="stylesheet" href="/resources/font/font-icon/icons.css" type="text/css" />
		
<script type="text/javascript" src="/resources/js/jquery-3.3.1.js"></script>
<script type="text/javascript" src="/resources/js/jquery.form.js"></script>
<script type="text/javascript">
$(document).ready(function(){
	var winH = $(window).height();
	$("#vWrapper").height(winH);
});
//로그인 처리
function pwdInit(){
	if( $("#newPassword").val() == '' ) {
		alert("비밀번호를 입력하세요.");
		$("#newPassword").focus();
		return;
	} else if( $("#rePassword").val() == '' ) {
		alert("신규 비밀번호 확인을 입력하세요.");
		$("#rePassword").focus();
		return;
	} else if( $("#newPassword").val() != $("#rePassword").val() ) {
		alert("신규 비밀번호와 신규 비밀번호 확인이 맞지 않습니다.");
		$("#rePassword").focus();
		return;
	} else {
		var URL = "/user/pwdCheckAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"userId" : $("#userId").val(),
				"newPassword": $("#newPassword").val()
			},
			dataType:"json",
			async:false,
			success:function(data) {
				if( data.RESULT == 'S' ) {
					var URL = "/user/pwdCheckAjax";
					$.ajax({
						type:"POST",
						url:URL,
						data:{
							"userId" : $("#userId").val(),
							"newPassword": $("#newPassword").val()
						},
						dataType:"json",
						async:false,
						success:function(data) {
							if( data.RESULT == 'S' ) {
								var URL = "../user/pwdUpdateAjax";
								$.ajax({
									type:"POST",
									url:URL,
									data:{
										"userId" : $("#userId").val(),
										"newPassword": $("#newPassword").val()
									},
									dataType:"json",
									async:false,
									success:function(data) {
										if(data.RESULT == 'S'){
											location.href = '../main/main';			
								        } else if( data.RESULT == 'E'){
											if( data.RESULT_TYPE == 'FAIL' ) {
												alert(data.MESSAGE);	
											} else if( data.RESULT_TYPE == 'ERROR' ) {
												alert(data.MESSAGE);
											} else if( data.RESULT_TYPE == 'LOCK' ) {
												//잠김페이지로 이동
											} else if( data.RESULT_TYPE == 'DELETE' ) {
												//잠김페이지로 이동
											} else if( data.RESULT_TYPE == 'RETIRED' ) {
												//잠김페이지로 이동
												alert("퇴직자는 시스템을 사용하실 수 없습니다.");
											} else if( data.RESULT_TYPE == 'PWD_INIT' ) {
												//잠김페이지로 이동
												alert("비밀번호 초기화 대상입니다.\n비밀번호 초기화 화면으로 이동합니다.");
												document.form1.action = "/user/pwdInit";
												$("#userIdTemp").val($("#userId").val());
												document.form1.submit();
											}
								        } else{
											alert('아이디 또는 비밀번호가 일치하지 않습니다.');
								        }
									},
									error:function(request, status, errorThrown){
										alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
									}			
								});
							} else if( data.RESULT == 'F' ){
								alert(data.MESSAGE);
								return;
							} else {
								alert(data.MESSAGE);
								return;
							}
						},
						error:function(request, status, errorThrown){
							$("#"+objectId).removeOption(/./);
							alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
						}			
					});
				} else if( data.RESULT == 'F' ){
					alert(data.MESSAGE);
					return;
				} else {
					alert(data.MESSAGE);
					return;
				}
			},
			error:function(request, status, errorThrown){
				$("#"+objectId).removeOption(/./);
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	}
	
	
}
</script>
	<%-- <body bgcolor="#f1f1f1">
 		<div class="login_wrap">
 			<div class="login_box login_ani">
				<div class="login_txt">
					<p class="pb20"><img src="/resources/images/bbq_logo.png" width="250" height=""></p>
					<p><span>BBQ 세계식문화과학기술원 비밀번호 변경 화면입니다.</span></p>			
				</div>
	 			<div class="login_input">
	 				<input type="hidden" id="userId" name="userId" value="${userId}"/>
					<input type="password" id="newPassword" name="newPassword" tabindex="1" onKeyPress="if(window.event.keyCode == 13) { pwdInit();}" class="inputbg02" placeholder="비밀번호"/>
					<input type="password" id="rePassword" name="rePassword" tabindex="1" onKeyPress="if(window.event.keyCode == 13) { pwdInit();}" class="inputbg02" placeholder="비밀번호 확인"/>
					<!-- auto_save_off / auto_save_on -->
					<div class="auto_save">
					<!--아이디 자동저장 <a href="#"><img src="images/auto_save_on.png"/></a>-->
					</div>
					<div>
						<button class="btn_login" onClick="javascript:pwdInit();">비밀번호 변경</button>
					</div>
				</div>
			<br/><br/><br/> 
	 		</div>
		<footer>
			<div id="main_footer">
				<span>서울특별시 송파구 중대로 64(문정동) (주)제너시스 <i> | </i> 대표이사 최영 <i> | </i> 정보보호 최고책임자 <br/>(c) GENESIS BBQ ALL Rights Reserved.
		   		</span>
			</div>
		</footer>
		</div>
		<form name="form1" method="post">
			<input type="hidden" id="userIdTemp" name="userIdTemp"/>
		</form>
	</body> --%>
	
	<body>
		<form id="frmLogin" name="frmLogin" method="post" class="material">
			
			<div class="loginWrap bgGray" id="vWrapper">
				<div class="loginForm">			
					<div class="loginFormBox">
						<div class="loginFormBox-border bgMainGra"></div>
						<div class="loginHeader">
							<div class="loginLogo"><img id="logo" src="/resources/images/bbq_logo.png" alt="(주)제너시스비비큐" ></div>
							<div class="loginStc">BBQ세계식문화과학기술원</div>
						</div>
						
						<div class="loginBody">
							<ul class="loginInputLst">
								<li class="id inputFocusOut flex">
									<div class="loginInputIcon fixCol"><i class="mdi mdi-account-circle-outline"></i></div>
									<div class="flexCol">
										<input type="text" title="사용자ID" id="userId" name="userId" class="loginInput" value="${userId}" readonly>						
									</div>
								</li>
								<li class="pw inputFocusOut flex">
									<div class="loginInputIcon fixCol"><i class="mdi mdi-lock-outline"></i></div>
									<div class="flexCol">
										<input type="password" title="사용자ID" id="newPassword" name="newPassword" tabindex="1" class="loginInput" placeholder="신규 비밀번호를 입력해주세요." autofocus onKeyPress="if(window.event.keyCode == 13) { pwdInit();}">						
									</div>
								</li>
								<li class="pw inputFocusOut flex">
									<div class="loginInputIcon fixCol"><i class="mdi mdi-lock-outline"></i></div>
									<div class="flexCol">
										<input type="password" title="비밀번호" id="rePassword" name="rePassword" tabindex="2" onKeyPress="if(window.event.keyCode == 13) { loginProc();}" class="loginInput" placeholder="비밀번호 확인을 위해 다시한번 입력해주세요." onKeyPress="if(window.event.keyCode == 13) { pwdInit();}">
									</div>
								</li>
							</ul>
							
							<!-- <div class="loginOptionArea">
								<div class="rememberPw">
									<span class="chk-wrap" id="cookie_save_yn_span">
										<input type="checkbox" id="cookieSaveYn" name="cookieSaveYn" value="Y">
										<label for="cookieSaveYn"><span></span>로그인 정보 저장</label>
									</span>
								</div>
							</div> -->				
						</div>
										
						<div class="loginFooter">
							<button class="loginFooter-btn bgMainGra waves-effect"  id="btnLogin" type="button" onClick="javascript:pwdInit();">
								<span>비밀번호 변경<i class="fas fa-chevron-right"></i></span>
							</button>
						</div>			
					</div>
				</div>	
						
				<div class="copy">
					이 사이트는 Microsoft Edge, Chrome, Firefox에 최적화 되어 있습니다.<br>
					서울특별시 송파구 중대로 64(문정동) (주)제너시스 <i> | </i> 대표이사 최영 <i> | </i> 정보보호 최고책임자 <br/>(c) GENESIS BBQ ALL Rights Reserved.
				</div>
			</div>
		</form>
		<form name="form1" method="post">
			<input type="hidden" id="userIdTemp" name="userIdTemp"/>
		</form>
	</body>
</html>