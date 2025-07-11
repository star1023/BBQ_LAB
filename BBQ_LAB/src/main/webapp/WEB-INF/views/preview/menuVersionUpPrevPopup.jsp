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
		<span class="title"><img src="/resources/images/bg_bs_box_fast02.png">&nbsp;메뉴완료보고서 미리보기</span>
	</h2>
	<div  class="top_btn_box" style=" position:fixed;">
		<div style="float:right; margin-right: 30px; display:flex; gap:30px;">
			<!-- <button type="button" class="btn_print" onclick="fn_printPreview()"></button> -->
			<button type="button" class="btn_pop_close" onClick="self.close();"></button>		
		</div>
	</div>
	<div style="height: 50px;"></div>
    <div id="wrapper">
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
						<td colspan="3"><span id="prev_title"></span></td>
					</tr>
					<tr>
						<th  >메뉴명</th>
						<td colspan="3"><span id="prev_menuName" class="preview_2"></span></td>
					</tr>
					<tr>
						<th  >공동 참여자</th>
						<td colspan="3"><span id="prev_sharedUser" ></span></td>
					</tr>
					<tr>
						<th  >개선 목적</th>
						<td colspan="3" class="inner-table-cell">
							<div id="wrapper_prev_improve_pur" style="display:none;">
							    <table >
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
							        <tbody id="prev_improve_pur"></tbody>
							    </table>
							</div>
						</td>
					</tr>
					<tr>
						<th  >개선 사항</th>
						<td colspan="3" id="prev_improve">
						</td>
					</tr>
					<tr>
						<th  >브랜드</th>
						<td colspan="3" id="prev_brand">
						</td>
					</tr>
					<tr>
						<th  >용도</th>
						<td colspan="3" id="prev_usage">
						</td>
					</tr>
					<tr>
						<th  >신규도입품 /<br>제품규격</th>
						<td colspan="3" class="inner-table-cell">
							<div id="wrapper_prev_new" style="display:none;">
								<table >
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
											<th>공급처 및<br> 담당자</th>
											<th>보관조건 및<br> 소비기한</th>
											<th>비고</th>
										</tr>
									</thead>
									<tbody id="prev_new">
									</tbody>
								</table>	
							</div>
						</td>
					</tr>
					<tr>
						<th  >추정원가</th>
						<td colspan="3" class="inner-table-cell">
							<div id="wrapper_prev_new1" style="display:none;">
								<table >
									<colgroup>
										<col width="20%"></col>
										<col width="20%"></col>
										<col width="20%"></col>
										<col width="20%"></col>
										<col width="20%"></col>
									</colgroup>
									<thead>
										<tr>
											<th>메뉴명</th>
											<th>예상판매가</th>
											<th>예상원가</th>
											<th>원가율(%)</th>
											<th>비고</th>
										</tr>
									</thead>
									<tbody id="prev_new1">
									</tbody>
								</table>	
							</div>
						</td>
					</tr>
					<tr>
						<th  >도입 예정일</th>
						<td colspan="3" id="prev_scheduleDate">
						</td>
					</tr>
					<tr>
						<th  >메뉴코드</th>
						<td id="prev_menuCode">
						</td>
						<th  >상품코드</th>
						<td id="prev_sapCode">
						</td>
					</tr>
					<tr>
						<th  >버젼 No.</th>
						<td colspan="3" id="prev_version">
						</td>
					</tr>
					<tr>
						<th  >메뉴유형</th>
						<td colspan="5" id="prev_menuType">
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div id="wrapper_prev_newMat" style="display:none;">
			<div>
				<span style="font-size: 14px;">※ 신규원료</span>
			</div>
			<div class="mainTable">				
				<table class="tbl01">
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
					<tbody id="prev_newMat">
					</tbody>
					<tfoot>
					</tfoot>
				</table>
			</div>
		</div>
		<div id="wrapper_prev_newMat1" style="display:none;">
			<div>
				<span style="font-size: 14px;">※ 기존원료</span>
			</div>
			<div class="mainTable">				
				<table  >
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
							<th>보관방법 및 유통기한</th>
							<th>공급가</th>
							<th>비고</th>
						</tr>
					</thead>
					<tbody id="prev_newMat1">
					</tbody>
					<tfoot>
					</tfoot>
				</table>
			</div>
		</div>
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
		<div id="wrapper_prev_content" style="display:none;">
			<div>
				<span style="font-size: 14px;">※ 비고</span>
			</div>
			<table class="insert_proc01">
				<tr>
					<td><pre id="prev_content" style="white-space: pre-wrap; word-wrap: break-word;"></pre></td>
				</tr>
			</table>
		</div>
	</div>
</body>
</html>
<!-- 미리보기 팝업 --> 