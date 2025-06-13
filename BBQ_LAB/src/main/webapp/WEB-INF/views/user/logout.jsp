<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>삼립식품연구소</title>
<link href="/resources/css/common.css" rel="stylesheet" type="text/css" />
<link href="/resources/css/layout.css" rel="stylesheet" type="text/css" />	
<script type="text/javascript" src='<c:url value="/resources/js/jquery-3.3.1.js"/>'></script>
<script type="text/javascript" src='<c:url value="/resources/js/jquery.form.js"/>'></script>
<script>
	function fn_login() {
		document.location.href = "/user/login";
	}
</script>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
		<title>삼립 연구소 시스템</title>
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
	</body>
</html>