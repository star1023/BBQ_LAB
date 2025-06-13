<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<script type="text/javascript" src="/resources/js/jquery-3.3.1.js"></script>
<script type="text/javascript" src="/resources/js/jquery.form.js"></script>
<script type="text/javascript">
//로그인 처리
function loginProc(){
	if($("#userId").val() == '' ) {
		alert("아이디를 입력하세요.");
		$("#userId").focus();
		return;
	} else if( $("#userPwd").val() == '' ) {
		alert("비밀번호를 입력하세요.");
		$("#userPwd").focus();
		return;
	} else {
		
	}
}
</script>
<html>
<head>
	<title>로그인</title>
</head>
<body>
	<h1>
		로그인 화면  
	</h1>

	<div class="login_input">
		<input type="text" id="userId" name="userId" tabindex="1" class="inputbg01" placeholder="아이디"/>
		<br/>
		<input type="password" id="userPwd" name="userPwd" tabindex="2" onKeyPress="if(window.event.keyCode == 13) { loginProc();}" class="inputbg02" placeholder="비밀번호"/>
		<!-- auto_save_off / auto_save_on -->
		<div class="auto_save">
		<!--아이디 자동저장 <a href="#"><img src="images/auto_save_on.png"/></a>-->
		</div>
		<div>
			<button class="btn_login" onClick="javascript:loginProc();">관리자 로그인</button>
		</div>
	</div>
</body>
</html>
