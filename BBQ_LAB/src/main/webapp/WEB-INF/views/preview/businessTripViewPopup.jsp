<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page import="kr.co.genesiskorea.util.*" %> 
<%@ page session="false" %>
<!DOCTYPE html>
<html>
<head>
  <title>${businessTripData.data.TITLE}_출장결과보고서</title>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
  <link rel="stylesheet" type="text/css" href="../../resources/css/preview.css"></link>
  <meta charset="UTF-8">
  <title>프린트 미리보기</title>
  <script type="text/javascript">
  function fn_printPreview() {
	  console.log("dd");
    var printContent = document.getElementById("wrapper").outerHTML;

    var iframe = document.createElement("iframe");
    iframe.style.position = "fixed";
    iframe.style.right = "0";
    iframe.style.bottom = "0";
    iframe.style.width = "0";
    iframe.style.height = "0";
    iframe.style.border = "0";
    document.body.appendChild(iframe);

    var doc = iframe.contentWindow.document;

    doc.open();
    doc.write(
      '<html>' +
        '<head>' +
          '<title>인쇄 미리보기</title>' +
          '<link rel="stylesheet" type="text/css" href="../../resources/css/preview.css">' +
          '<style>@media print { body { margin: 0; } }</style>' +
        '</head>' +
        '<body onload="window.focus(); window.print();">' +
          printContent +
        '</body>' +
      '</html>'
    );
    doc.close();

    setTimeout(function () {
      document.body.removeChild(iframe);
    }, 1000);
  }
</script>
</head>
<body>
	<h2 style=" position:fixed; background-color: #38b6e6 !important;" class="print_hidden">
		<span class="title"><img src="/resources/images/bg_bs_box_fast02.png">&nbsp;출장결과보고서 미리보기</span>
	</h2>
	<div  class="top_btn_box" style=" position:fixed;">
		<div style="float:right; margin-right: 30px; display:flex; gap:30px;">
			<button type="button" class="btn_print" onclick="fn_printPreview()"></button>
			<button type="button" class="btn_pop_close" onClick="self.close();"></button>		
		</div>
	</div>
	<div style="height: 50px;"></div>
	<div id="wrapper">
		<div style="width=100%; margin: 0 0 5px; display:flex; justify-content: center; font-weight: bold; font-size: 24px;">
			<span>출장결과보고서</span>
		</div>
		<div class="mainTable">
			<table >
				<colgroup>
					<col width="15%" />
					<col width="35%" />
					<col width="15%" />
					<col width="35%" />
				</colgroup>
				<tbody>
					<tr>
						<th  >제목</th>
						<td colspan="3">
							${businessTripData.data.TITLE}
						</td>
					</tr>
					<tr>
						<th  >출장구분</th>								
						<td colspan="3">
							${businessTripData.data.TRIP_TYPE_TXT}
						</td>
					</tr>
					<tr>
						<th  >출장자</th>								
						<td colspan="3" class="inner-table-cell">
							<table width="100%" class="inner-table">
								<tr>
									<th width="35%">소속</th>
									<th width="35%">직위(직급)</th>
									<th width="30%">성명</th>
								</tr>
								<tbody id="user_tbody" name="user_tbody">
								<c:forEach items="${userList}" var="userList" varStatus="status">
									<tr>
										<td>
											${userList.DEPT}
										</td>
										<td>
											${userList.POSITION}
										</td>
										<td>
											${userList.NAME}
										</td>
									</tr>
								</c:forEach>	
								</tbody>
							</table>
						</td>
					</tr>
					<tr>
						<th  >출장목적</th>								
						<td colspan="3">
							<c:forEach items="${infoList}" var="infoList" varStatus="status">
							<c:if test="${infoList.INFO_TYPE == 'PUR' }">
								${infoList.INFO_TEXT}<br>
							</c:if>
							</c:forEach>
						</td>
					</tr>
					<tr>
						<th  >출장기간</th>
						<td colspan="3">
							${businessTripData.data.TRIP_START_DATE} 
							<c:if test="${businessTripData.data.TRIP_END_DATE != null && businessTripData.data.TRIP_END_DATE != '' }">
							~ 
							${businessTripData.data.TRIP_END_DATE}
							</c:if>
						</td>
					</tr>
					<tr>
						<th  >출장지</th>
						<td>
							<c:forEach items="${infoList}" var="infoList" varStatus="status">
							<c:if test="${infoList.INFO_TYPE == 'DEST' }">
								${infoList.INFO_TEXT}<br>
							</c:if>
							</c:forEach>
						</td>
						<th  >경유지</th>
						<td>
							${businessTripData.data.TRIP_TRANSIT}								
						</td>
					</tr>
					<tr>
						<th  >출장내용</th>
						<td colspan="3" class="inner-table-cell">
							<table width="100%" class="inner-table">
								<tr>
									<th width="25%">일정</th>
									<th width="25%">세부내용</th>
									<th width="25%">장소</th>
									<th width="25%">비고</th>
								</tr>
								<tbody id="contents_tbody" name="contents_tbody">
								<c:forEach items="${contentsList}" var="contentsList" varStatus="status">	
									<tr>
										<td>
											${contentsList.SCHEDULE}
										</td>
										<td>
											${contentsList.CONTENT}												
										</td>
										<td>
											${contentsList.PLACE}												
										</td>
										<td>
											${contentsList.NOTE}												
										</td>
									</tr>
								</c:forEach>	
								</tbody>
							</table>
						</td>
					</tr>
					<tr>
						<th  >업무수행내용</th>
						<td colspan="3">
							${businessTripData.data.TRIP_CONTENTS}
						</td>
					</tr>
					<tr>
						<th  >경비</th>
						<td colspan="3">
							${businessTripData.data.TRIP_COST}
						</td>
					</tr>
					<tr>
						<th  >초과사유</th>
						<td colspan="3">
							${businessTripData.data.OVER_REASON}
						</td>
					</tr>
					<tr>
						<th  >출장효과</th>
						<td colspan="3">
							${businessTripData.data.TRIP_EFFECT}
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</body>
</html>