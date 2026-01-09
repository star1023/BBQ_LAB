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
  function downloadFile(idx){
	location.href = '/common/fileDownload?idx='+idx;
  }
  
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
          '<style>@media print { body { margin: 0; } a { text-decoration: none; color: black; }}</style>' +
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
			<button type="button" class="btn_print" onclick="fn_printPreview()"></button>
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
						<td rowSpan="2">해당면</td>
						<th colSpan="3">포장지 인쇄 표기사항</th>
					</tr>
					<tr>						
						<td >표기사항</td>
						<td >세부사항</td>
						<td >&nbsp;</td>
					</tr>
					<tr>
						<td  rowSpan="8">정면(주표시면)</td>
						<th >제품명</th>
						<td id="prev_productName"></td>
						<th >주표시면(14P이상)</th>
					</tr>
					<tr>
						<th >&nbsp;</th>
						<td id="prev_etcInfo"></td>
						<td rowSpan="6">주표시면 주원료 함량 표시시<br>원재료와 함량 표기 기재 요망</td>
					</tr>
					<tr>
						<th >중량</th>
						<td id="prev_weight"></td>
					</tr>
					<tr>
						<th >포장단위</th>
						<td id="prev_packageUnit"></td>
					</tr>
					<tr>
						<th >낱개 중량</th>
						<td id="prev_pieceWeight"></td>
					</tr>
					<tr>
						<th >박스단위</th>
						<td id="prev_boxUnit"></td>
					</tr>
					<tr>
						<th >보관방법</th>
						<td id="prev_keepCondition" >
						</td>
					</tr>
					<tr>
						<th >마크</th>
						<td id="prev_markImage" style="padding:0px; text-align:center;">
							
						</td>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td rowSpan="16">후면 또는 측면<br>(정보표시면)</td>
						<th colspan="3">
							(정보표시면)	후면 10p 이상(원산지는 12p 이상)<br>
							장평 90%이상, 자간 -5이상 표시 의문<br>
							(단, 정보표시면 면적이 100cm² 미만시 장평 50%이상, 자간 -5%이상 표시 가능)
						</th>
					</tr>
					<tr>
						<th>제품명</th>
						<td id="prev_productNameBack" colSpan="2">
							${packageInfoData.data.PRODUCT_NAME_BACK}
						</td>
					</tr>					
					<tr>
						<th>식품의 유형</th>
						<td id="prev_foodType" colSpan="2">
						</td>
					</tr>					
					<tr>
						<th>원재료명 및 함량</th>
						<td ><p style="white-space: pre-line; text-align:left;" id="prev_containQuantity"></p></td>
						<td id="prev_containQuantityImg" style="padding:0px; text-align:center;">
							
						</td>
					</tr>					
					<tr>
						<th>알러지 유발물질</th>
						<td id="prev_allergyObject" colSpan="2">
						</td>
					</tr>					
					<tr>
						<th>품목보고번호</th>
						<td id="prev_manufacturingNo" colSpan="2">
						</td>
					</tr>					
					<tr>
						<th>소비기한</th>
						<td id="prev_expiredDate" colSpan="2">
						</td>
					</tr>					
					<tr>
						<th>포장재질</th>
						<td id="prev_packageObject" colSpan="2">
						</td>
					</tr>					
					<tr>
						<th>제조원</th>
						<td id="prev_maker" colSpan="2">
						</td>
					</tr>					
					<tr>
						<th>유통전문판매원</th>
						<td id="prev_distribution" colSpan="2">
						</td>
					</tr>					
					<tr>
						<th>반품 및 교환장소</th>
						<td id="prev_returned" colSpan="2">
						</td>
					</tr>					
					<tr>
						<th>소비자상담실</th>
						<td id="prev_customerCounsel" colSpan="2">
						</td>
					</tr>										
					<tr>
						<th>기타사항</th>
						<td id="prev_infoText" colSpan="2">
						</td>
					</tr>										
					<tr>
						<th>분리배출 표시</th>
						<td id="prev_separateDischarge" colSpan="2">
						</td>
					</tr>							
					<tr>
						<th>주의사항</th>
						<td colSpan="2" id="prev_suggestions" style="white-space: pre-line; text-align:left;">
						</td>
					</tr>					
					<tr>
						<th>조리방법</th>
						<td colSpan="2" id="prev_cookMethod" style="white-space: pre-line; text-align:left;">
						</td>
					</tr>					
				</tbody>
			</table>
		</div>
		<div id="wrapper_prev_content">
			<div>
				<span style="font-size: 14px;">※ 첨부파일</span>
			</div>
			<table class="insert_proc01">
				<tr> 
					<th style="width:13%;">첨부파일</th>
					<td id="prev_file"></td>
				</tr>
			</table>
		</div>
	</div>
</body>
</html>