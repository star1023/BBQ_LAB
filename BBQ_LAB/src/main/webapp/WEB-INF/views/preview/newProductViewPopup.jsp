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
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
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
		<span class="title"><img src="/resources/images/bg_bs_box_fast02.png">&nbsp;메뉴 품질 점검 결과보고서 미리보기</span>
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
    		<div style="width:40%; margin: 0 0 5px; display:flex; justify-content: center; align-items: center; font-weight: bold; font-size: 24px;">
				<span style="text-align: center;">메뉴 품질 점검 결과보고서</span>
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
			<span>메뉴 품질 점검 결과보고서</span>
		</div> -->
		<div class="mainTable">
            <c:set var="columnState" value="${fn:split(newProductResultData.data.COLUMN_STATE, ',')}" />
		    <table class="insert_proc01">
		        <colgroup>
		            <col />
		            <col id="titleCol" />
		        </colgroup>
		        <tbody>
		            <tr>
		                <th>제목</th>
		                <td id="titleTd" colspan="${fn:length(columnState)}">${newProductResultData.data.TITLE}</td>
		            </tr>
		            <tr>
		                <th>시행월</th>
		                <td id="monthTd" colspan="${fn:length(columnState)}">${newProductResultData.data.EXCUTE_DATE}</td>
		            </tr>
		            <c:if test="${fn:length(newProductResultData.data.COLUMN_STATE) > 0}">
		            <tr>
		                <th>내용</th>
		                <td id="inspectionTd" class="inner-table-cell" colspan="${fn:length(columnState)}">

							<table class="inner-table">
								<c:set var="colCount" value="${fn:length(columnState)}" />
								<c:set var="colWidth" value="${100 / colCount}" />
							    <colgroup>
							        <c:forEach var="colCode" items="${columnState}">
									    <col style="width: ${colWidth}%" />
									</c:forEach>
							    </colgroup>
							    <thead>
							        <tr>
							            <c:forEach var="colCode" items="${columnState}">
							                <c:forEach var="code" items="${codeList}">
							                    <c:if test="${code.itemCode == colCode}">
							                        <th>${code.itemName}</th>
							                    </c:if>
							                </c:forEach>
							            </c:forEach>
							        </tr>
							    </thead>
							    <tbody>
							        <c:forEach var="rowNum" begin="0" end="20">
								    <c:set var="hasRow" value="false" />
								    <c:forEach var="item" items="${newProductResultItemList}">
								        <c:if test="${item.ROW_NO == rowNum}">
								            <c:set var="hasRow" value="true" />
								        </c:if>
								    </c:forEach>
								
								    <c:if test="${hasRow}">
								        <tr>
								            <c:forEach var="colCode" items="${columnState}">
											    <c:set var="cellValue" value="" />
											    <c:set var="isImageColumn" value="false" />
											    
											    <!-- 코드 이름 확인 -->
											    <c:forEach var="code" items="${codeList}">
											        <c:if test="${code.itemCode == colCode && fn:contains(code.itemName, '이미지')}">
											            <c:set var="isImageColumn" value="true" />
											        </c:if>
											    </c:forEach>
											
											    
											        <c:choose>
											            <c:when test="${isImageColumn}">
											                <c:set var="hasImage" value="false" />
											                <td style="padding:3px;">
											                <c:forEach var="img" items="${newProductResultImageList}">
											                    <c:if test="${img.ROW_NO == rowNum}">
											                        <img src="/images${img.FILE_PATH}/${img.FILE_NAME}"
											                             style="border:1px solid #e1e1e1; width: 100%; object-fit: contain;" />
											                        <c:set var="hasImage" value="true" />
											                    </c:if>
											                </c:forEach>
											                <c:if test="${!hasImage}">
											                    <img src="/resources/images/img_noimg3.png"
											                         style="border:1px solid #e1e1e1; width: 100%; object-fit: contain;"/>
											                </c:if>
											            </c:when>
											            <c:otherwise>
											            <td>
											                <c:forEach var="item" items="${newProductResultItemList}">
											                    <c:if test="${item.ROW_NO == rowNum && item.COLUMN_CODE == colCode + 0}">
											                        ${item.COLUMN_VALUE}
											                    </c:if>
											                </c:forEach>
											            </c:otherwise>
											        </c:choose>
											    </td>
											</c:forEach>

								        </tr>
								    </c:if>
								</c:forEach>
							    </tbody>
							</table>

		                </td>
		            </tr>
		            </c:if>
		            <tr>
		                <th>첨부파일</th>
		                <td colspan="${fn:length(columnState)}">
			                <c:forEach items="${newProductResultData.fileList}" var="fileList" varStatus="status">
								${fileList.ORG_FILE_NAME}<br>
							</c:forEach>
						</td>
		            </tr>
		        </tbody>
		    </table>
		</div>
	</div>
</body>
</html>