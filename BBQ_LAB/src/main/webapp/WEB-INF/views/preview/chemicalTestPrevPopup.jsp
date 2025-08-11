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
			<button type="button" class="btn_print" onclick="fn_printPreview()"></button>
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
						<td id="prev_requestDate"></td>
						<th  >희망 완료일</th>
						<td id="prev_completionDate"></td>
						<th  >의뢰자</th>
						<td id="prev_requestUser"></td>
					</tr>
					<tr>
						<th  >시료명</th>
						<td colspan="5" id="prev_productName">
							
						</td>
					</tr>
					<tr>
						<th  >시료 수량</th>
						<td colspan="5" id="prev_productCount">
							
						</td>
					</tr>
					<tr>
						<th  >보관방법</th>
						<td colspan="5" id="prev_preservation">
							
						</td>
					</tr>
					<!-- 요청항목 & 값 & 결과 -->
					<tr id="prev_testItem"></tr>
					
					<tr>
					    <th  >검사 요청 방법</th>
					    <td colspan="5" id="prev_standard1">
					    </td>
					</tr>
					<tr>
					    <th  >검사 진행 일정</th>
					    <td colspan="5" id="prev_standard2">
					    </td>
					</tr>
					<tr>
						<th colspan="3">요청사항</th>
						<th colspan="3">시료 사진</th>
					</tr>
					<tr>
						<td colspan="3" id="prev_content">
							
						</td>
						<td colspan="3" style="text-align: center;" id="prev_previewImg"></td>
					</tr>
				</tbody>
			</table>
		</div>
		<div>
			<span style="font-size: 14px;">※ 검사 결과 내용</span>
		</div>
		<div class="mainTable">
			<table style="min-height:250px;">
				<tr >
					<td><pre></pre></td>
				</tr>
			</table>
		</div>
	</div>
</body>
</html>