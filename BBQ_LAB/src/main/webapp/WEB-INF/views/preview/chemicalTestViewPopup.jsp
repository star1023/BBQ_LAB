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
  <title></title>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
  <link rel="stylesheet" type="text/css" href="../../resources/css/preview.css"></link>
  <meta charset="UTF-8">
  <title>프린트 미리보기</title>
  <script type="text/javascript">
  function fn_printPreview() {
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
		<span class="title"><img src="/resources/images/bg_bs_box_fast02.png">&nbsp;이화학 검사 의뢰서 미리보기</span>
	</h2>
	<div  class="top_btn_box" style=" position:fixed;">
		<div style="float:right; margin-right: 30px; display:flex; gap:30px;">
			<!-- <button type="button" class="btn_print" onclick="fn_printPreview()"></button> -->
			<button type="button" class="btn_pop_close" onClick="self.close();"></button>		
		</div>
	</div>
	<div style="height: 50px;"></div>
	<div id="wrapper">
		<div style="width=100%; margin: 0 0 5px; display:flex; justify-content: center; font-weight: bold; font-size: 24px;">
			<span>이화학 검사 의뢰서</span>
		</div>
		<div class="mainTable">
			<table  >
				<colgroup>
					<col width="16.66%">
					<col width="16.66%">
					<col width="16.66%">
					<col width="16.66%">
					<col width="16.66%">
					<col width="16.66%">
				</colgroup>
				<tbody>
					<tr>
						<th  >의뢰일</th>
						<td >${chemicalTestData.data.REQUEST_DATE}</td>
						<th  >희망 완료일</th>
						<td >${chemicalTestData.data.COMPLETION_DATE}</td>
						<th  >의뢰자</th>
						<td >${chemicalTestData.data.REQUEST_USER}</td>
					</tr>
					<tr>
						<th  >시료명</th>
						<td colspan="5">
							${chemicalTestData.data.PRODUCT_NAME}
						</td>
					</tr>
					<tr>
						<th  >시료 수량</th>
						<td colspan="5">
							${chemicalTestData.data.PRODUCT_COUNT}
						</td>
					</tr>
					<tr>
						<th  >보관방법</th>
						<td colspan="5">
							${chemicalTestData.data.PRESERVATION}
						</td>
					</tr>
					<c:forEach var="start" begin="0" end="${fn:length(itemList)-1}" step="4">
					  <!-- 검사 요청 항목 -->
					  <tr>
					    <th style="width: 10%; text-align: center; font-weight: bold;">검사요청 항목</th>
					    <td colspan="5" style="padding: 0;">
					      <table style="border:none; width: 100%; table-layout: fixed; border-collapse: collapse;">
					        <tr>
					          <c:forEach var="i" begin="${start}" end="${start + 3}">
					            <c:choose>
					              <c:when test="${i lt fn:length(itemList)}">
					                <th style="width: 25%; text-align: center;">
					                  ${itemList[i].TYPE_CODE_TEXT}
					                </th>
					              </c:when>
					              <c:otherwise>
					                <th style="width: 25%;"></th>
					              </c:otherwise>
					            </c:choose>
					          </c:forEach>
					        </tr>
					      </table>
					    </td>
					  </tr>
					
					  <!-- 범위 -->
					  <tr>
					    <th style="width: 10%; text-align: center; font-weight: bold;">범위</th>
					    <td colspan="5" style="padding: 0;">
					      <table style="width: 100%; table-layout: fixed; border-collapse: collapse;">
					        <tr>
					          <c:forEach var="i" begin="${start}" end="${start + 3}">
					            <c:choose>
					              <c:when test="${i lt fn:length(itemList)}">
					                <td style="width: 25%; text-align: center;">
					                  ${itemList[i].ITEM_CONTENT}
					                </td>
					              </c:when>
					              <c:otherwise>
					                <td style="width: 25%;"></td>
					              </c:otherwise>
					            </c:choose>
					          </c:forEach>
					        </tr>
					      </table>
					    </td>
					  </tr>
					  
					  <!-- 검사 결과 -->
					  <tr>
					  	<th style="width: 10%; text-align: center; font-weight: bold;">검사 결과</th>
					    <td colspan="5" style="padding: 0;">
					      <table style="border:none; width: 100%; table-layout: fixed; border-collapse: collapse;">
					        <tr>
					          <c:forEach var="i" begin="${start}" end="${start + 3}">
					            <c:choose>
					              <c:when test="${i lt fn:length(itemList)}">
					                <td style="width: 25%; text-align: center;">
					                  ${empty itemList[i].ITEM_RESULT ? '&nbsp;' : itemList[i].ITEM_RESULT}
					                </td>
					              </c:when>
					              <c:otherwise>
					                <td style="width: 25%;">&nbsp;</td>
					              </c:otherwise>
					            </c:choose>
					          </c:forEach>
					        </tr>
					      </table>
					    </td>
					  </tr>
					</c:forEach>
					
					<tr>
					    <th  >검사 요청 방법</th>
					    <td colspan="5">
					        <c:forEach var="item" items="${standardList}">
					            <c:if test="${item.TYPE_CODE eq 'MET'}">
					                ${item.STANDARD_CONTENT}<br/>
					            </c:if>
					        </c:forEach>
					    </td>
					</tr>
					<tr>
					    <th  >검사 진행 일정</th>
					    <td colspan="5">
					        <c:forEach var="item" items="${standardList}">
					            <c:if test="${item.TYPE_CODE eq 'SCH'}">
					                ${item.STANDARD_CONTENT}<br/>
					            </c:if>
					        </c:forEach>
					    </td>
					</tr>
					<tr>
						<th colspan="3">요청사항</th>
						<th colspan="3">시료 사진</th>
					</tr>
					<tr>
						<td colspan="3">
							<pre>${chemicalTestData.data.REQUEST_CONTENT}</pre>
						</td>
						<td colspan="3" style="text-align: center;">
							<c:choose>
								<c:when test="${not empty chemicalTestData.data.FILE_NAME}">
									<img id="preview"
										src="/images${chemicalTestData.data.FILE_PATH}/${chemicalTestData.data.FILE_NAME}"
										style="border:1px solid #e1e1e1; border-radius:5px; width:400px; height:300px; object-fit: contain;">
								</c:when>
								<c:otherwise>
									<img id="preview"
										src="/resources/images/img_noimg3.png"
										alt="이미지 없음"
										style="border:1px solid #e1e1e1; border-radius:5px; width:400px; height:300px; object-fit: contain;">
								</c:otherwise>
							</c:choose>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div>
			<span style="font-size: 14px;">※ 검사 결과 내용</span>
		</div>
		<div class="mainTable">
			<c:choose>
				<c:when test="
					    ${not empty chemicalTestData.data.TEST_RESULT}
					">
					<table >
						<tr>
							<td><pre>${chemicalTestData.data.TEST_RESULT}</pre></td>
						</tr>
					</table>
				</c:when>
				<c:otherwise>
					<table style="min-height:250px;">
						<tr >
							<td><pre></pre></td>
						</tr>
					</table>
				</c:otherwise>
			</c:choose>
		</div>
	</div>
</body>
</html>