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
  <title>${productData.data.TITLE}_제품완료보고서</title>
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
		<span class="title"><img src="/resources/images/bg_bs_box_fast02.png">&nbsp;제품완료보고서 미리보기</span>
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
			<span>제품완료보고서</span>
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
						<th >제목</th>
						<td colspan="3">${productData.data.TITLE}</td>
					</tr>
					<tr>
						<th >제품명</th>
						<td colspan="3">
							${productData.data.NAME}
						</td>
					</tr>
					<c:if test="${productData.data.VERSION_NO == 1 && addInfoCount.PUR_CNT > 0 }">
						<tr>
							<th >개발 목적</th>
							<td colspan="3">
								<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
									<c:if test="${addInfoList.INFO_TYPE == 'PUR' }">
										${addInfoList.INFO_TEXT} <br>
									</c:if>
								</c:forEach>
							</td>
						</tr>
					</c:if>
					<c:if test="${productData.data.VERSION_NO == 1 && addInfoCount.FEA_CNT > 0 }">
						<tr>
							<th >제품 특징</th>
							<td colspan="3">
								<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
									<c:if test="${addInfoList.INFO_TYPE == 'FEA' }">
										${addInfoList.INFO_TEXT} <br>
									</c:if>
								</c:forEach>
							</td>
						</tr>
					</c:if>
					<c:if test="${productData.data.VERSION_NO != 1 && fn:length(imporvePurposeList) > 0 }">
						<tr>
							<th >개선 목적</th>
							<td colspan="3" class="inner-table-cell">
								<div id="wrapper_prev_improve_pur" >
									<table class="inner-table">
										<colgroup>
											<col width="33.33%">
											<col width="33.33%">
											<col width="33.33%">
										</colgroup>
										<thead>
											<tr>
												<th>개선</th>
												<th>기존</th>
												<th>비고</th>
											</tr>
										</thead>
										<tbody id="improve_pur_tbody" name="improve_pur_tbody">
											<c:forEach items="${imporvePurposeList}" var="imporvePurposeList" varStatus="status">
												<tr id="improve_pur_tr__${status.count}" >
													<td>
														${imporvePurposeList.IMPROVE}
													</td>
													<td>
														${imporvePurposeList.EXIST}
													</td>
													<td>
														${imporvePurposeList.NOTE}
													</td>
												</tr>
											</c:forEach>	
										</tbody>
									</table>
								</div>
							</td>
						</tr>
					</c:if>
					<c:if test="${productData.data.VERSION_NO != 1 && fn:length(addInfoCount) > 0 }">
						<tr class="tr_prev_version2">
							<th >개선 사항</th>
							<td colspan="3" id="prev_improve">
								<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
								<c:if test="${addInfoList.INFO_TYPE == 'IMP' }">
										${addInfoList.INFO_TEXT}<br>
								</c:if>
							</c:forEach>
							</td>
						</tr>
					</c:if>
					<c:set var="brandText" value="" />
					<c:set var="usageText" value="" />
					
					<c:forEach items="${addInfoList}" var="item">
					    <c:if test="${item.INFO_TYPE == 'USB'}">
					        <c:choose>
					            <c:when test="${empty brandText}">
					                <c:set var="brandText" value="${item.INFO_TEXT_NAME}" />
					            </c:when>
					            <c:otherwise>
					                <c:set var="brandText" value="${brandText}, ${item.INFO_TEXT_NAME}" />
					            </c:otherwise>
					        </c:choose>
					    </c:if>
					    <c:if test="${item.INFO_TYPE == 'USC' && empty usageText}">
					        <c:set var="usageText" value="${item.INFO_TEXT}" />
					    </c:if>
					</c:forEach>
					<tr>
					    <th >브랜드</th>
					    <td colspan="3">
					        ${brandText}
					    </td>
					</tr>
					<tr>
					    <th >용도</th>
					    <td colspan="3">
					        ${usageText}
					    </td>
					</tr>
					<tr>
						<th >신규도입품 /<br>제품규격</th>
						<td colspan="3" class="inner-table-cell">
							<c:if test="${not empty newDataList}">
							<table class="inner-table">
								<colgroup>
									<col width="20%"></col>
									<col width="20%"></col>
									<col width="20%"></col>
									<col width="20%"></col>
									<col width="20%"></col>
								</colgroup>
								<thead>
									<tr>
										<th>제품명</th>
										<th>포장규격</th>
										<th>공급처 및 담당자</th>
										<th>보관조건 및<br>소비기한</th>
										<th>비고</th>
									</tr>
								</thead>
								<tbody>
									<c:forEach items="${newDataList}" var="newDataList" varStatus="status">
										<tr id="new_tr_${status.count}" >
											<td>
												${newDataList.PRODUCT_NAME}
											</td>
											<td>
												${newDataList.PACKAGE_STANDARD}
											</td>
											<td>
												${newDataList.SUPPLIER}
											</td>
											<td>${newDataList.KEEP_EXP}</td>
											<td>${newDataList.NOTE}</td>
										</tr>
									</c:forEach>
								</tbody>
							</table>
							</c:if>	
						</td>
					</tr>
					<tr>
						<th >도입 예정일</th>
						<td colspan="3">
							${productData.data.SCHEDULE_DATE}
						</td>
					</tr>
					<tr>
						<th >제품코드</th>
						<td>
							${productData.data.PRODUCT_CODE}
						</td>
						<th >상품코드</th>
						<td>
							${productData.data.SAP_CODE}
						</td>
					</tr>
					<tr>
						<th >버젼 No.</th>
						<td colspan="3">
							${productData.data.VERSION_NO}
						</td>
					</tr>
					<tr>
						<th>중량</th>
						<td>
							${productData.data.TOTAL_WEIGHT}
						</td>
						<th>제품규격</th>
						<td>
							${productData.data.STANDARD}								
						</td>
						
					</tr>
					<tr>
						<th>보관방법</th>
						<td>
							${productData.data.KEEP_CONDITION}	
						</td>
						<th>소비기한</th>
						<td>
							${productData.data.EXPIRATION_DATE}									
						</td>							
					</tr>
					<tr>
						<th >제품유형</th>
						<td colspan="5">
							<c:if test="${productData.data.PRODUCT_TYPE1 != null }">
							${productData.data.PRODUCT_TYPE_NAME1}
							</c:if>
							<c:if test="${productData.data.PRODUCT_TYPE2 != null }">
							&gt; ${productData.data.PRODUCT_TYPE_NAME2}
							</c:if>
							<c:if test="${productData.data.PRODUCT_TYPE3 != null }">
							&gt; ${productData.data.PRODUCT_TYPE_NAME3}
							</c:if>
						</td>
					</tr>
					<tr>
						<th >첨부파일 유형</th>
						<td colspan="3">
							<c:forEach items="${productData.fileType}" var="fileType" varStatus="status">
								<c:if test="${status.index != 0 }">
								,
								</c:if>
								${fileType.FILE_TEXT}
							</c:forEach>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<c:if test="${productData.data.IS_NEW_MATERIAL == 'Y' }">
		<div>
			<span style="font-size: 14px;">※ 신규원료</span>
		</div>
		<div class="mainTable">				
			<table>
				<colgroup>
					<col width="6%">
					<col width="5%">
					<col width="12%">
					<col width="6%">
					<col width="10%">
					<col width="7%">
					<col width="6%">
				</colgroup>
				<thead>
					<tr>
						<th>원료코드</th>
						<th>ERP코드</th>
						<th>원료명</th>
						<th>규격</th>
						<th>보관방법 및<br>유통기한</th>
						<th>공급가</th>
						<th>비고</th>
					</tr>
				</thead>
				<tbody>
				<c:forEach items="${productMaterialData}" var="productMaterialData" varStatus="status">
				<c:if test="${productMaterialData.MATERIAL_TYPE == 'Y' }">
					<tr>
						<td>
							<div>${productMaterialData.MATERIAL_CODE}</div>
						</td>
						<td>
							${productMaterialData.SAP_CODE}
						</td>
						<td>
							${productMaterialData.NAME}
						</td>
						<td>
							${productMaterialData.STANDARD}
						</td>
						<td>
							${productMaterialData.KEEP_EXP}
						</td>
						<td>
							${productMaterialData.UNIT_PRICE}
						</td>
						<td>
							${productMaterialData.DESCRIPTION}
						</td>
					</tr>
				</c:if>	
				</c:forEach>	
				</tbody>
				<tfoot>
				</tfoot>
			</table>
		</div>
		</c:if>
		
		<c:set var="hasErpMaterial" value="false" />
		<c:forEach items="${productMaterialData}" var="item">
		    <c:if test="${item.MATERIAL_TYPE == 'N'}">
		        <c:set var="hasErpMaterial" value="true" />
		    </c:if>
		</c:forEach>
		<c:if test="${hasErpMaterial}">
			<div>
				<span style="font-size: 14px;">※ 기존원료</span>
			</div>
			<div class="mainTable">				
				<table >
					<colgroup>
						<col width="6%">
						<col width="5%">
						<col width="12%">
						<col width="6%">
						<col width="10%">
						<col width="7%">
						<col width="6%">
					</colgroup>
					<thead>
						<tr>
							<th>원료코드</th>
							<th>ERP코드</th>
							<th>원료명</th>
							<th>규격</th>
							<th>보관방법 및<br>유통기한</th>
							<th>공급가</th>
							<th>비고</th>
						</tr>
					</thead>
					<tbody>
					<c:forEach items="${productMaterialData}" var="productMaterialData" varStatus="status">
					<c:if test="${productMaterialData.MATERIAL_TYPE == 'N' }">
						<tr>
							<td>
								<div class=""><a href="#" onClick="fn_erpview('${productMaterialData.SAP_CODE}')">${productMaterialData.MATERIAL_CODE}</a></div>
							</td>
							<td>
								${productMaterialData.SAP_CODE}
							</td>
							<td>
								${productMaterialData.NAME}
							</td>
							<td>
								${productMaterialData.STANDARD}
							</td>
							<td>
								${productMaterialData.KEEP_EXP}
							</td>
							<td>
								${productMaterialData.UNIT_PRICE}
							</td>
							<td>
								${productMaterialData.DESCRIPTION}
							</td>
						</tr>
					</c:if>	
					</c:forEach>	
					</tbody>
					<tfoot>
					</tfoot>
				</table>
			</div>
		</c:if>
		<!-- 
		<div class="con_file" style="">
			<ul>
				<li class="point_img">
					<dt>첨부파일</dt><dd>
						<ul>
							<c:forEach items="${productData.fileList}" var="fileList" varStatus="status">
								<li>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
							</c:forEach>
						</ul>
					</dd>
				</li>
			</ul>
		</div>
		 -->
		<c:if test="${not empty productData.data.CONTENTS}">
			<div>
				<span style="font-size: 14px;">※ 비고</span>
			</div>
			<div class="mainTable">
				<table >
					<tr>
						<td><pre>${productData.data.CONTENTS}</pre></td>
					</tr>
				</table>
			</div>
		</c:if>
    </div>
</body>
</html>