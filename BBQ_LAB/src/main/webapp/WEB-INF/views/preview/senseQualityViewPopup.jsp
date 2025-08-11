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
		<span class="title"><img src="/resources/images/bg_bs_box_fast02.png">&nbsp;관능&품질평가 테스트 결과보고서 미리보기</span>
	</h2>
	<div  class="top_btn_box" style=" position:fixed;">
		<div style="float:right; margin-right: 30px; display:flex; gap:30px;">
			<!-- <button type="button" class="btn_print" onclick="fn_printPreview()"></button> -->
			<button type="button" class="btn_pop_close" onClick="self.close();"></button>		
		</div>
	</div>
	<div style="height: 50px;"></div>
	<div id="wrapper">
		<div class="mainTable" style="width:100%; margin: 10px 0 10px; display:flex; justify-content: space-between;">
    		<div style="width:40%; margin: 0 0 5px; display:flex; justify-content: center; flex-direction: column; align-items: center; font-weight: bold; font-size: 24px;">
				<span style="text-align: center; ">
					${senseQualityData.reportMap.PRODUCT_NAME}
					<br>
					<span style="font-size: 18px; font-weight: normal;">
						<div style="line-height: 1;">관능&품질평가</div>
    					<div style="line-height: 1;">테스트 결과보고서</div>
					</span>
				</span>
			</div>
    		<div style="width:60%">
				<table style="width:100%; border-collapse:collapse; table-layout:fixed;">
				  <colgroup>
				    <col style="width:80px;">
				    <c:choose>
				      <c:when test="${not empty apprItem and fn:length(apprItem) > 0}">
				        <c:forEach items="${apprItem}" var="it"><col /></c:forEach>
				      </c:when>
				      <c:otherwise>
				        <col />
				      </c:otherwise>
				    </c:choose>
				  </colgroup>
				
				  <tbody>
				    <tr>
					  <th rowspan="3" style="border:1px solid #ccc; padding:8px; text-align:center; background:#f2f2f2;">결재</th>
					  <c:choose>
					    <c:when test="${not empty apprItem and fn:length(apprItem) > 0}">
					      <c:forEach items="${apprItem}" var="item">
					        <td style="border:1px solid #ccc;">
					              ${empty item.OBJTTX ? '&nbsp;' : item.OBJTTX}
					        </td>
					      </c:forEach>
					    </c:when>
					    <c:otherwise>
					      <td style="border:1px solid #ccc; padding:0; vertical-align:top;">
					        <div style="display:grid; grid-template-rows:32px auto; width:100%; height:100%;">
					          <div style="height:32px; line-height:32px; text-align:center; font-weight:600; background:#f2f2f2; border-bottom:1px solid #e5e5e5;">
					            1차 결재
					          </div>
					          <div style="padding:8px;">&nbsp;</div>
					        </div>
					      </td>
					    </c:otherwise>
					  </c:choose>
					</tr>
				    <tr>
				      <c:choose>
				        <c:when test="${not empty apprItem and fn:length(apprItem) > 0}">
				          <c:forEach items="${apprItem}" var="item">
				            <td style="border:1px solid #ccc; padding:8px; text-align:left;">
				              ${empty item.TARGET_USER_NAME ? '&nbsp;' : item.TARGET_USER_NAME}
				            </td>
				          </c:forEach>
				        </c:when>
				        <c:otherwise>
				          <td style="border:1px solid #ccc; padding:8px;">&nbsp;</td>
				        </c:otherwise>
				      </c:choose>
				    </tr>
				    <tr>
				      <c:choose>
				        <c:when test="${not empty apprItem and fn:length(apprItem) > 0}">
				          <c:forEach items="${apprItem}" var="item">
				            <td style="border:1px solid #ccc; padding:8px; text-align:left;">
				              <c:choose>
				                <c:when test="${not empty item.REG_DATE}">${item.REG_DATE}</c:when>
				                <c:otherwise>&nbsp;</c:otherwise>
				              </c:choose>
				            </td>
				          </c:forEach>
				        </c:when>
				        <c:otherwise>
				          <td style="border:1px solid #ccc; padding:8px;">&nbsp;</td>
				        </c:otherwise>
				      </c:choose>
				    </tr>
				  </tbody>
				</table>
    		</div>
    	</div>
		<!-- <div style="width=100%; margin: 0 0 5px; display:flex; justify-content: center; font-weight: bold; font-size: 24px;">
			<span>관능&품질평가 테스트 결과보고서</span>
		</div> -->
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
							<th >제목</th>								
							<td colspan="3">
								${senseQualityData.reportMap.TITLE}
							</td>
						</tr>
						<tr>
							<th >업체명</th>
							<td colspan="3">
								${senseQualityData.reportMap.COMPANY_NAME}
							</td>
						</tr>
						<tr>
							<th >제품명</th>
							<td>
								${senseQualityData.reportMap.PRODUCT_NAME}
							</td>
							<th >ERP코드</th>
							<td>
								${senseQualityData.reportMap.SAP_CODE}
							</td>
						</tr>
						<tr>
							<th >테스트 목적</th>
							<td colspan="3">
								${senseQualityData.reportMap.TEST_PURPOSE}
							</td>
						</tr>					
					</tbody>
				</table>
			</div>
			<div>
				<span style="font-size: 14px;">※ 세부내용</span>
			</div>		
			<div class="mainTable">		
				<table>
				  <colgroup>
				    <col width="7%">
				    <col width="23%">
				    <col width="23%">
				    <col width="23%">
				    <col width="24%">
				  </colgroup>
				
				  <c:forEach var="no" begin="0" end="${senseQualityData.modCount - 1}">
				    <c:set var="startNo" value="${no * 3}" />
				    <c:set var="endNo" value="${no * 3 + 2}" />
				
				    <!-- Row 1: 구분 + 컨텐츠 헤더 -->
				      <c:if test="${no == 0}">
					    <tr>
					      <th rowspan="2">구분</th>
					      <td colspan="4" align="center">${senseQualityData.reportMap.CONTENTS_HEADER}</td>
					    </tr>
				      </c:if>
				
				    <!-- Row 2: 구분값들 + 비고 헤더 -->
				      <tr >
				      <c:if test="${no != 0}">
					      <th>구분</th>
				      </c:if>
				      <c:set var="count" value="0" />
				      <c:forEach items="${senseQualityData.contentsList}" var="item" varStatus="status">
				        <c:if test="${status.index >= startNo && status.index <= endNo}">
				          <c:set var="count" value="${count + 1}" />
				          <td>${item.CONTENTS_DIV}</td>
				        </c:if>
				      </c:forEach>
				      <c:if test="${count < 3}">
				        <c:forEach var="i" begin="1" end="${3 - count}">
				          <td>&nbsp;</td>
				        </c:forEach>
				      </c:if>
				      <th>비고</th>
				    </tr>
				
				    <!-- Row 3: 사진들 + 비고 텍스트 (rowspan=2) -->
				    <tr>
				      <th>사진</th>
				      <c:set var="count" value="0" />
				      <c:forEach items="${senseQualityData.contentsList}" var="item" varStatus="status">
				        <c:if test="${status.index >= startNo && status.index <= endNo}">
				          <c:set var="count" value="${count + 1}" />
				          <td style="height: 200px; text-align: center; border: 1px solid #bbb;">
				            <c:if test="${not empty item.FILE_PATH}">
				              <img src="/images${item.FILE_PATH}/${item.ORG_FILE_NAME}" 
				                   style="width: 100%; height: 100%; object-fit: contain; border-radius: 5px;">
				            </c:if>
				          </td>
				        </c:if>
				      </c:forEach>
				      <c:if test="${count < 3}">
				        <c:forEach var="i" begin="1" end="${3 - count}">
				          <td style="height: 200px;">&nbsp;</td>
				        </c:forEach>
				      </c:if>
				      <td rowspan="2">
				        <p style="white-space: pre-line; text-align:left;">
				          ${senseQualityData.infoNoteList[no].INFO_TEXT}
				        </p>
				      </td>
				    </tr>
				
				    <!-- Row 4: 결과 -->
				    <tr>
				      <th>결과</th>
				      <c:set var="count" value="0" />
				      <c:forEach items="${senseQualityData.contentsList}" var="item" varStatus="status">
				        <c:if test="${status.index >= startNo && status.index <= endNo}">
				          <c:set var="count" value="${count + 1}" />
				          <td style="border: 1px solid #bbb;">
				            <p style="white-space: pre-line; text-align:left;">
				              ${item.CONTENTS_RESULT}
				            </p>
				          </td>
				        </c:if>
				      </c:forEach>
				      <c:if test="${count < 3}">
				        <c:forEach var="i" begin="1" end="${3 - count}">
				          <td>&nbsp;</td>
				        </c:forEach>
				      </c:if>
				    </tr>
				
				  </c:forEach>
				</table>
			</div>
			<div>
				<span style="font-size: 14px;">※ 결론</span>
			</div>
			<div class="mainTable">
				<table class="insert_proc01">
					<colgroup>
						<col  />							
					</colgroup>
					<tbody id="result_tbody" name="result_tbody">
					<c:forEach items="${senseQualityData.infoResultList}" var="infoResultList" varStatus="status">
						<tr id="result_tr_${status.count}">
							<td>
								${infoResultList.INFO_TEXT}
							</td>
						</tr>						
					</c:forEach>	
					</tbody>					
				</table>
			</div>
		</div>
</body>
</html>

