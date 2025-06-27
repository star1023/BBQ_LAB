<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"	trimDirectiveWhitespaces="true"%>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE HTML>
<html lang="ko">
<head>
<meta charset="utf-8">
<title>에러</title>
<style>
table{border-collapse:collapse;}
.body01 {}
.body02 { background:url(../resources/images/bg_cont.jpg) -73px -64px ;background-repeat:no-repeat; }
*{padding:0; margin: 0;}
img{border:0;}
.spage_header{ height:140px; background-image:url(../resources/images/bg_error.gif); background-repeat:repeat-x; text-align:center; width:100%;}
.spage_header_in{ margin:0 auto; text-align:left; padding-top:90px;}
.spage_header_bar{ background-color:#3e5196; height:5px; background-repeat:no-repeat; font-size:5px;}
.spage_content{ padding:50px 20px 50px 20px; height:100%;}
.spage_content_in{font-family:'맑은고딕', Malgun Gothic;font-size:13px; color:#a69c8e; line-height:16px; height:100%;margin:0 auto; text-align:center;}
.spage_footer{ border-top:1px solid #e3e0dc; background-image:url(../resources/images/bg_error_bottom.gif); background-position:top; background-repeat:repeat-x; bottom:0px; }
.spage_footer_in{ width:995px; margin:0 auto; text-align:left; padding-top:50px;}
/* 폰트 포인트 컬러 */
.font_red{ color:#e51d55;}
.font_blue{ color:#e26d1f;}
.font_bold{ font-weight:bold;}
.font_big01{font-family:'맑은고딕', Malgun Gothic; font-size:25px; color:#666; color:#96834e;}
.font_big02{ font-family:'맑은고딕', Malgun Gothic; font-size:25px; color:#666; color:#a1a1a1;}

.btn_admin_red{background-image: url(../resources/images/bg_btn_s.png); background-repeat:no-repeat; background-position:right 6px;height:40px;  background-color:#d15b47; font-family:'맑은고딕',Malgun Gothic; font-size:14px; color:#fff; padding:0 30px 3px 20px; cursor:pointer; border:none; min-width:100px}
.btn_admin_red:hover{background-color:#e87663;}

</style>
<script type="text/javascript">

</script>
</head>
<body class="body02">
	<table width="100%" border="0">
		<tr>
			<td valign="top">
				<div class="spage_content_in">
					<br /><br /><br />
					<!--img src="../resources/images/img_error01.gif" /--><br />
					<br/>
					<span class="font_big01">SSO 오류가 발생했습니다.</span><br /><br />
					<br />
					<span class="font_big02">
					<c:choose>
						<c:when test="${RESULT == 'NO_USER'}">
						${USER_ID} 계정은 시스템에 존재하지 않는 사용자입니다.
						</c:when>
						<c:when test="${RESULT == 'IS_LOCK'}">
						${USER_ID} 계정은 잠금처리된 사용자 입니다.
						</c:when>
						<c:when test="${RESULT == 'RETIRED'}">
						${USER_ID} 계정은 퇴직자입니다. 퇴직자의 경우 접속하실 수 없습니다.
						</c:when>
						<c:when test="${RESULT == 'NO_DATA'}">
						전달된 SSO 정보가 올바르지 않습니다.
						</c:when>
						<c:otherwise></c:otherwise>
					</c:choose>
					
					<br /><br />동일한 오류가 발생하는 경우 관리자에게 문의하세요.</span><br /><br />
					<br /><br /><br />
					<button type="button" class="btn_admin_red" onClick="self.window.close()">닫기</button><br />
					<br />
					<!-- 컨텐츠 close -->
				</div>
			</td>
		</tr>
	</table>
	<!-- <div class="login_input">
		<br /><br />
		<img src="../resources/images/img_error01.gif" /><br />
		<span class="font_big02">문서 접근권한이 없습니다.</span><br /><br />
		<div>
			<button class="btn_login" onClick="fn_goReturn('${returnPage}')">확인</button>
		</div>
	</div> -->
<!-- //wrap  -->
</body>
</html>