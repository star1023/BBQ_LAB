<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ page import="kr.co.genesiskorea.util.UserUtil" %> 
<% 
	String userId = UserUtil.getUserId(request);
%>    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<script type="text/javascript" src="../resources/js/jquery-3.3.1.js"></script>
<script type="text/javascript">
	
</script>
</head>
<body>
	<table>
		<c:forEach items="${erpList}" var="erpList" varStatus="status">
		<tr>
			<td>${erpList.BUKRS}</td>
			<td>${erpList.MATNR}</td>
			<td>${erpList.MAKTX}</td>
			<td>${erpList.MTART}</td>
			<td>${erpList.STOR_COND}</td>
			<td>${erpList.MATKL}</td>
			<td>${erpList.WGBEZ}</td>
			<td>${erpList.MEINS}</td>
			<td>${erpList.LRMEI}</td>
			<td>${erpList.UMREZ}</td>
			<td>${erpList.RCMEI}</td>
			<td>${erpList.UMREN}</td>
			<td>${erpList.HORIZONTAL}</td>
			<td>${erpList.HORIZONTAL_MEINS}</td>
			<td>${erpList.VERTICAL}</td>
			<td>${erpList.VERTICAL_MEINS}</td>
			<td>${erpList.HEIGHT}</td>
			<td>${erpList.HEIGHT_MEINS}</td>
			<td>${erpList.WEIGHT}</td>
			<td>${erpList.WEIGHT_MEINS}</td>
			<td>${erpList.SIZE_DIM}</td>
			<td>${erpList.ORIG_MAT}</td>
			<td>${erpList.LEADTIMES}</td>
			<td>${erpList.SAFETY_STOCK_DAY}</td>
			<td>${erpList.BOX_STOCK}</td>
			<td>${erpList.PALLET_STOCK}</td>
			<td>${erpList.MWSKZ}</td>
			<td>${erpList.EXP_DATE}</td>
			<td>${erpList.USE_YN}</td>
			<td>${erpList.MOQ}</td>
		</tr>
		</c:forEach>
	</table>
</body>
</html>