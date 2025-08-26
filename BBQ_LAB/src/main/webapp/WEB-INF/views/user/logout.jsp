<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html class="skin_red">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>BBQ세계식문화과학기술원</title>
<!-- <link href="/resources/css/common.css" rel="stylesheet" type="text/css" />
<link href="/resources/css/layout.css" rel="stylesheet" type="text/css" />	 -->
<link rel="shortcut icon" href="/resources/images/favicon.ico"/>
<link rel="stylesheet" href="/resources/css/login/common.css" type="text/css" />
<link rel="stylesheet" href="/resources/css/login/component.css" type="text/css" />
<link rel="stylesheet" href="/resources/css/login/page.css" type="text/css" />
<link rel="stylesheet" href="/resources/css/login/skinSwitcher.css" type="text/css" />
<link rel="stylesheet" href="/resources/font/font-icon/icons.css" type="text/css" />
<script type="text/javascript" src='<c:url value="/resources/js/jquery-3.3.1.js"/>'></script>
<script type="text/javascript" src='<c:url value="/resources/js/jquery.form.js"/>'></script>
<script>
$(document).ready(function(){
	var winH = $(window).height();
	$("#vWrapper").height(winH);
});

	function fn_login() {
		document.location.href = "/user/login";
	}
</script>
	<!-- <head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
		<title>BBQ 세계식문화과학기술원</title>
	</head>	
	<body bgcolor="#f1f1f1">
 		<div class="login_wrap">
 			<div class="login_box login_ani">
				<div class="login_txt">
					<p class="pb20"><img src="/resources/images/bbq_logo.png" width="250" height=""></p>
					<p><span>로그아웃 페이지입니다.</span></p>			
				</div>
	 			<div class="login_input">
	 				로그아웃 되었습니다.
	 				<br/><br/><br/>
	 				<div>
						<button class="btn_login" onClick="javascript:fn_login();">로그인 페이지</button>
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
	</body> -->
	
	<body>
	
 		<!-- <div class="login_wrap">
 			<div class="login_box login_ani">
				<div class="login_txt">
					<p class="pb20"><img src="/resources/images/bbq_logo.png" width="250" height=""></p>
					<p><span>BBQ 세계식문화과학기술원 PDM 시스템 로그인 페이지입니다.</span></p>			
				</div>
	 			<div class="login_input">
	 				<input type="text" id="userId" name="userId" tabindex="1" class="inputbg01" placeholder="아이디"/>
					<input type="password" id="userPwd" name="userPwd" tabindex="2" onKeyPress="if(window.event.keyCode == 13) { loginProc();}" class="inputbg02" placeholder="비밀번호"/>
					auto_save_off / auto_save_on
					<div class="auto_save">
					아이디 자동저장 <a href="#"><img src="images/auto_save_on.png"/></a>
					</div>
					<div>
						<button class="btn_login" onClick="javascript:loginProc();">로그인</button>
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
		</form> -->
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
							<ul class="">
								<li class="id " style="text-align:center">
									로그아웃 되었습니다.
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
							<button class="loginFooter-btn bgMainGra waves-effect"  id="btnLogin" type="button" onClick="javascript:fn_login();">
								<span>로그인 페이지<i class="fas fa-chevron-right"></i></span>
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
	</body>
</html>