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
		<span class="title"><img src="/resources/images/bg_bs_box_fast02.png">&nbsp;표시사항기재양식 미리보기</span>
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
			<span>표시사항기재양식</span>
		</div>
		<div class="mainTable">
			<table  >
				<colgroup>
					<col width="16%">
					<col width="16%">
					<col width="34%">
					<col width="34%">
				</colgroup>
				<tbody>
					<tr>
						<th rowSpan="2">해당면</th>
						<td colSpan="3">포장지 인쇄 표기사항</td>
					</tr>
					<tr>						
						<td >표기사항</td>
						<td >세부사항</td>
						<td >&nbsp;</td>
					</tr>
					<tr>
						<th  rowSpan="5">정면(주표시면)</th>
						<td >제품명</td>
						<td >${packageInfoData.data.PRODUCT_NAME}</td>
						<td >주표시면(14P이상)</td>
					</tr>
					<tr>
						<td >&nbsp;</td>
						<td class="value">${packageInfoData.data.ETC_INFO}</td>
						<td rowSpan="3">주표시면 주원료 함량 표시시 원재료와 함량 표기 기재 요망</td>
					</tr>
					<tr>
						<td >중량</td>
						<td class="value">${packageInfoData.data.WEIGHT}</td>
					</tr>
					<tr>
						<td >보관방법</td>
						<td class="value">
							<c:choose>
								<c:when test="${packageInfoData.data.KEEP_CONDITION == '999'}">
									${packageInfoData.data.KEEP_CONDITION_TXT}
								</c:when>
								<c:otherwise>
									${packageInfoData.data.KEEP_CONDITION_NAME}
								</c:otherwise>
							</c:choose>	
						</td>
					</tr>
					<tr>
						<td >마크</td>
						<td class="value" style="padding:0px; text-align:center;">
							<c:set var="hasMarkImage" value="${not empty packageInfoData.data.MARK_FILE_PATH and not empty packageInfoData.data.MARK_FILE_NAME}" />
							<p>
							    <a href="<c:if test='${hasMarkImage}'><c:out value='/images${packageInfoData.data.MARK_FILE_PATH}/${packageInfoData.data.MARK_FILE_NAME}'/></c:if>" 
							       target="_blank">
							        <img id="markPreview"
							             src="<c:choose>
							                      <c:when test='${hasMarkImage}'>
							                          /images${packageInfoData.data.MARK_FILE_PATH}/${packageInfoData.data.MARK_FILE_NAME}
							                      </c:when>
							                      <c:otherwise>
							                          /resources/images/img_noimg3.png
							                      </c:otherwise>
							                  </c:choose>"
							             style="width: 100%; height: auto; max-height: 200px; object-fit: contain; border:1px solid #e1e1e1;">
							    </a>
							</p>
						</td>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<th rowSpan="16">후면 또는 측면<br>(정보표시면)</th>
						<td colspan="3">
							(정보표시면)	후면 10p 이상(원산지는 12p 이상)<br>
							장평 90%이상, 자간 -5이상 표시 의문<br>
							(단, 정보표시면 면적이 100cm² 미만시 장평 50%이상, 자간 -5%이상 표시 가능)
						</td>
					</tr>
					<tr>
						<td>제품명</td>
						<td class="value" colSpan="2">
							${packageInfoData.data.PRODUCT_NAME_BACK}
						</td>
					</tr>					
					<tr>
						<td>식품의 유형</td>
						<td class="value" colSpan="2">
							<c:choose>
								<c:when test="${packageInfoData.data.FOOD_TYPE == '999'}">
									${packageInfoData.data.FOOD_TYPE_TXT}
								</c:when>
								<c:otherwise>
									${packageInfoData.data.FOOD_TYPE_NAME}
								</c:otherwise>
							</c:choose>
						</td>
					</tr>					
					<tr>
						<td>원재료명 및 함량</td>
						<td class="value" ><p style="white-space: pre-line; text-align:left;">${packageInfoData.data.CONTAIN_QUANTITY}</p></td>
						<td class="value" style="padding:0px; text-align:center;">
							<c:set var="hasImage" value="${not empty packageInfoData.data.CONTAIN_QUANTITY_FILE_PATH and not empty packageInfoData.data.CONTAIN_QUANTITY_FILE_NAME}" />
							<p>
							    <a href="<c:if test='${hasImage}'><c:out value='/images${packageInfoData.data.CONTAIN_QUANTITY_FILE_PATH}/${packageInfoData.data.CONTAIN_QUANTITY_FILE_NAME}'/></c:if>" 
							       target="_blank">
							        <img id="preview"
							             src="<c:choose>
							                      <c:when test='${hasImage}'>
							                          /images${packageInfoData.data.CONTAIN_QUANTITY_FILE_PATH}/${packageInfoData.data.CONTAIN_QUANTITY_FILE_NAME}
							                      </c:when>
							                      <c:otherwise>
							                          /resources/images/img_noimg3.png
							                      </c:otherwise>
							                  </c:choose>"
							             style="width: 100%; height: auto; max-height: 200px; object-fit: contain; border:1px solid #e1e1e1;">
							    </a>
							</p>
						</td>
					</tr>					
					<tr>
						<td>알러지 유발물질</td>
						<td class="value" colSpan="2">
							${packageInfoData.data.ALLERGY_OBJECT}
						</td>
					</tr>					
					<tr>
						<td>품목보고번호</td>
						<td class="value" colSpan="2">
							${packageInfoData.data.MANUFACTURING_NO}
						</td>
					</tr>					
					<tr>
						<td>소비기한</td>
						<td class="value" colSpan="2">
							${packageInfoData.data.EXPIRED_DATE}
						</td>
					</tr>					
					<tr>
						<td>포장재질</td>
						<td class="value" colSpan="2">
							${packageInfoData.data.PACKAGE_OBJECT}
						</td>
					</tr>					
					<tr>
						<td>제조원</td>
						<td class="value" colSpan="2">
							${packageInfoData.data.MAKER}
						</td>
					</tr>					
					<tr>
						<td>유통전문판매원</td>
						<td class="value" colSpan="2">
							${packageInfoData.data.DISTRIBUTION}
						</td>
					</tr>					
					<tr>
						<td>반품 및 교환장소</td>
						<td class="value" colSpan="2">
							${packageInfoData.data.RETURNED}
						</td>
					</tr>					
					<tr>
						<td>소비자상담실</td>
						<td class="value" colSpan="2">
							${packageInfoData.data.CUSTOMER_COUNSEL}
						</td>
					</tr>										
					<tr>
						<td>기타사항</td>
						<td class="value" colSpan="2">
							<c:forEach items="${addInfoList}" var="infoList" varStatus="status">
								${infoList.INFO_TEXT}<br>								
							</c:forEach>
						</td>
					</tr>										
					<tr>
						<td>분리배출 표시</td>
						<td class="value" colSpan="2">
							<c:choose>
								<c:when test="${packageInfoData.data.SEPARATE_DISCHARGE == '999'}">
									${packageInfoData.data.SEPARATE_DISCHARGE_TXT}
								</c:when>
								<c:otherwise>
									${packageInfoData.data.SEPARATE_DISCHARGE_NAME}
								</c:otherwise>
							</c:choose>
						</td>
					</tr>							
					<tr>
						<td>주의사항</td>
						<td class="value" colSpan="2">
							<p style="white-space: pre-line; text-align:left;">${packageInfoData.data.SUGGESTIONS}</p>
						</td>
					</tr>					
					<tr>
						<td>조리방법</td>
						<td class="value" colSpan="2">
							<p style="white-space: pre-line; text-align:left;">${packageInfoData.data.COOK_METHOD}</p>
						</td>
					</tr>					
				</tbody>
			</table>
		</div>
	</div>
</body>
</html>