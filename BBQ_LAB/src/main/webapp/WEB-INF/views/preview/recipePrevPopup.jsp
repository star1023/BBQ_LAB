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
  <title>${recipeData.PRODUCT_NAME}_사전원가서</title>
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
		<span class="title"><img src="/resources/images/bg_bs_box_fast02.png">&nbsp;사전원가서 미리보기</span>
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
			<span>사전원가서</span>
		</div>
    	<div class="mainTable">
			<table>
				<colgroup>
					<col width="15%" />
					<col width="35%" />
					<col width="15%" />
					<col width="35%" />
				</colgroup>
				<tbody>
					<tr>
						<th style="border-left: none;">제품코드</th>
						<td id="prev_productCode">
						</td>
						<th style="border-left: none;">제품명</th>
						<td id="prev_productName">
						</td>
					</tr>
					<tr>
						<th style="border-left: none;">플랜트 </th>
						<td colspan="3" id="prev_plantName">
						</td>								
					</tr>
					<tr>
						<th style="border-left: none;">제품수량 </th>
						<td id="prev_plantCount">
						</td>
						<th style="border-left: none;">제품단위</th>
						<td id="prev_unitName">
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div>
			<span style="font-size: 14px;">※ 원료</span>
		</div>
		<div class="mainTable">
			<table >
				<colgroup>
					<col width="9%">
					<col width="25%"/>
					<col width="8%">
					<col width="7%">
					<col width="8%">
					<col width="7%">
				</colgroup>
				<thead>
					<tr>
						<th>구성품코드</th>
						<th>구성품명</th>
						<th>구성품수량</th>
						<th>구성품단위</th>
						<th>사용량</th>
						<th>사용량단위</th>
					</tr>
				</thead>
				<tbody id="prev_matTbody">
					
				</tbody>
				<tfoot>
				</tfoot>
			</table>
		</div>
		<div>
			<span style="font-size: 14px;">※ 사입품</span>
		</div>
		<div class="mainTable">
			<table >
				<colgroup>
					<col width="10%">
					<col width="10%">
					<col width="10%">
					<col width="10%">
					<col width="10%">
					<col width="10%">
					<col width="15%">
				</colgroup>
				<thead>
					<tr>
						<th>제품명</th>
						<th>구성품수량</th>
						<th>구성품단위</th>
						<th>사용량</th>
						<th>사용량단위</th>
						<th>단가</th>
						<th>비고</th>
					</tr>
				</thead>
				<tbody id="prev_newMatTbody">
					
				</tbody>
				<tfoot>
				</tfoot>
			</table>
		</div>
    </div>
</body>
</html>