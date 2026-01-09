<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*"%>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>상품 레시피 생성</title>
<style>
.positionCenter {
	position: absolute;
	transform: translate(-50%, -45%);
}

.ck-editor__editable {
	max-height: 200px;
	min-height: 200px;
}

li {
	list-style: none;
}
#prevPopup {
	display: none;
}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">

<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../resources/js/jstree.js"></script>
<script type="text/javascript"
	src="../resources/js/appr/apprClass.js?v=<%=System.currentTimeMillis()%>"></script>
<script type="text/javascript"
	src="../resources/js/user/userSearchClass.js?v=<%=System.currentTimeMillis()%>"></script>
<script type="text/javascript"
	src="../resources/js/preview/preview.js?v=<%=System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	$(document).ready(function(){
	});
	
	function fn_update(idx) {
		location.href = '/recipe/update?idx='+idx;
	}

	function fn_goList() {
		location.href = '/recipe/list';
	}
	
	function fn_erp(idx) {
		$('#lab_loading').show();
		var URL = "../recipe/applyErpAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"idx" : idx
			},
			dataType:"json",
			async:false,
			success:function(result) {
				if( result.RESULT == 'S' ) {
					alert("ERP에 정상적으로 등록되었습니다.");
					$('#lab_loading').hide();
					fn_goList();					
				} else {
					alert(result.MESSAGE);
					$('#lab_loading').hide();
					fn_goList();
				}
			},
			error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
				$('#lab_loading').hide();
				fn_goList();	
			}			
		});
	}
	
	function nvl2(str, defaultStr){
	    if(typeof str == "undefined" || str == "undefined" || str == null || str == "" || str == "null")
	        str = defaultStr ;
	     
	    return str ;
	}
	
	function fn_sapCodeview(sapCode) {
		var URL = "../material/selectErpMaterialDataAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"sapCode" : sapCode
			},
			dataType:"json",
			async:false,
			success:function(data) {
				$("#sapCodeTxt").html(data.SAP_CODE);
				$("#nameTxt").html(data.NAME);
				$("#unitTxt").html(data.UNIT);
				$("#keepTxt").html(data.KEEP_CONDITION_TXT);
				$("#weightTxt").html(data.TOTAL_WEIGHT);
				$("#standardTxt").html(data.STANDARD);
				$("#sizeTxt").html(data.WIDTH+"("+data.WIDTH_UNIT+")"+" / "+data.LENGTH+"("+data.LENGTH_UNIT+")"+" / "+data.HEIGHT+"("+data.HEIGHT_UNIT+")");
				$("#originTxt").html(data.ORIGIN);
				$("#expDateTxt").html(data.EXPIRATION_DATE);
				$("#cdTxt").html(data.CD_ACCT);
				openDialog('open3');
			},
			error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	}
	
	function fn_versionUp(idx) {
		location.href = '/recipe/versionUp?idx='+idx;
	}
	
	function fn_pdfDownload(idx) {
		/*var url = "/preview/recipeViewPopup?idx="+idx;
		// 팝업 창 열기
		var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes");*/
		$('#lab_loading').show();
	    fetch("/preview/recipeViewPopup?idx=" + idx)
	        .then(function(res) {
	            return res.text();
	        })
	        .then(function(html) {
	            var parser = new DOMParser();
	            var doc = parser.parseFromString(html, "text/html");

	            var wrapperHTML = doc.querySelector("#wrapper")?.outerHTML;
	            if (!wrapperHTML) {
	                alert("PDF 생성 실패: 출력할 wrapper 요소가 없습니다.");
	                $('#lab_loading').hide();
	                return;
	            }

	            // 전체 HTML로 감싸기 (백틱 없이)
				var fullHtml = ""
				  + "<html>"
				  + "<head>"
				  + "<meta charset='UTF-8'>"
				  + "<style>"
				  + "@page{margin:0}body{margin:0;padding:0;}@media print{body{margin:0;background:white!important;padding:10px}html,body{width:210mm;height:auto;background:white!important}}#wrapper{background:white;padding:20px;box-sizing:border-box}table{table-layout:fixed;border-collapse:collapse;width:100%}.main_tbl{margin:2.5px 0;table-layout:fixed;border-collapse:collapse;width:100%;border:1px solid #333}th{background-color:#f2f2f2;-webkit-print-color-adjust:exact}td,th{border-collapse:collapse;border:1px solid #bbb;text-align:left;font-size:12px;padding:7px}td{background-color:#fff}pre{margin:0;padding:0;line-height:1;white-space:pre-wrap}.inner-table-cell{padding:0;border-collapse:collapse}td.inner-table-cell{padding:1px!important}td.inner-table-cell table{border:1px solid #333}.mainTable{border:1px solid #000;margin:2.5px 0}.btn_print{width:36px;height:36px;border:none;background-color:transparent;cursor:pointer;margin-top:7px}"
				  + "</style>"
				  + "</head>"
				  + "<body>"
				  + wrapperHTML
				  + "</body>"
				  + "</html>";

	            var formData = new FormData();
	            formData.append("htmlContent", fullHtml);
	            formData.append("docIdx", idx);
				formData.append("docType", "RECIPE");
				formData.append("userId", "${userId}");
				var title = "${recipeData.PRODUCT_NAME}_사전원가서";
				formData.append("title", title);
				
	            fetch("/preview/downloadPdf", {
	                method: "POST",
	                body: formData
	            })
	            .then(function(res) {
	                return res.blob();
	            })
	            .then(function(blob) {
	                var url = window.URL.createObjectURL(blob);
	                var a = document.createElement("a");
	                a.href = url;
	                a.download = title+".pdf";
	                a.click();
	                window.URL.revokeObjectURL(url);
	                $('#lab_loading').hide();
	            });
	        });
	}
	
	function downloadFile(idx){
		location.href = '/common/fileDownload?idx='+idx;
	}
	
	function fn_openPreview(idx) {
		var url = "/preview/recipeViewPopup?idx="+idx;

		// 팝업 창 열기
		var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes");
	}
	
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path"> 사전원가서 상세보기&nbsp;&nbsp; <img
		src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;사전원가서상세보기&nbsp;&nbsp; <img src="/resources/images/icon_path.png"
		style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position: relative">
			<span class="title_s">Cost Management</span><span class="title">사전원가서 상세</span>
			<div class="top_btn_box">
				<!-- ul>
					<li>
						<c:if test="${recipeData.DOC_OWNER == userUtil:getUserId(pageContext.request) }">
							<c:if test="${recipeData.STATUS == 'TMP' and recipeData.IS_LAST == 'Y'}">
							<button class="btn_circle_modifiy" onclick="fn_update('${recipeData.RECIPE_IDX}')">&nbsp;</button>
							</c:if>
							<c:if test="${recipeData.STATUS == 'COMP' and recipeData.IS_LAST == 'Y'}">
							<button class="btn_circle_bom" onclick="fn_erp('${recipeData.RECIPE_IDX}')">&nbsp;</button>
							</c:if>
							<c:if test="${recipeData.STATUS == 'BOM_ERROR' and recipeData.IS_LAST == 'Y'}">
							<button class="btn_circle_bom" onclick="fn_erp('${recipeData.RECIPE_IDX}')">&nbsp;</button>
							</c:if>
							<c:if test="${recipeData.STATUS == 'BOM' and recipeData.IS_LAST == 'Y'}">
							<button class="btn_circle_version" onclick="fn_versionUp('${recipeData.RECIPE_IDX}')">&nbsp;</button>
							</c:if>
						</c:if>	
					</li>
				</ul-->
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title">
				<!--span class="txt">연구개발시스템 공지사항</span-->
			</div>
				<div class="title2"  style="display: flex; justify-content:space-between; width: 100%;">
					<span class="txt">제품정보</span>
					<div>
						<button class="btn_small_search ml5" onclick="fn_openPreview('${recipeData.RECIPE_IDX}')">미리보기</button>
						<c:if test="${(recipeData.STATUS eq 'COMP' or recipeData.STATUS eq 'BOM') and recipeData.DOC_OWNER eq userId}">
							<button class="btn_small_search" onclick="fn_pdfDownload('${recipeData.RECIPE_IDX}')">PDF 다운로드</button>
						</c:if>
					</div>
				</div>
				<div class="main_tbl">
					<table class="insert_proc01">
						<colgroup>
							<col width="15%" />
							<col width="35%" />
							<col width="15%" />
							<col width="35%" />
						</colgroup>
						<tbody>
							<tr>
								<th style="border-left: none;">제품코드</th>
								<td>
									<input type="hidden" name="idx" id="idx" value="${recipeData.RECIPE_IDX}">
									<input type="hidden" name="docNo" id="docNo" value="${recipeData.DOC_NO}">
									${recipeData.PRODUCT_CODE}
								</td>
								<th style="border-left: none;">제품명</th>
								<td>
									${recipeData.PRODUCT_NAME}
								</td>
							</tr>
							<c:if test="${userUtil:getUserId(pageContext.request) == recipeData.DOC_OWNER }">
							<tr>
								<th style="border-left: none;">결재라인</th>
								<td colspan="3">
									<c:forEach items="${apprItemList}" var="apprItemList" varStatus="status">
										<c:if test="${status.count > 1}">
											&nbsp; > &nbsp; 
										</c:if>
										${apprItemList.TARGET_USER_NAME}										
									</c:forEach>
								</td>
							</tr>
							<tr>
								<th style="border-left: none;">참조자</th>
								<td colspan="3">
									<c:forEach items="${refList}" var="refList" varStatus="status">
										<c:if test="${status.count > 1}">
											&nbsp; , &nbsp; 
										</c:if>
										${refList.TARGET_USER_NAME}										
									</c:forEach>
								</td>
							</tr>
							</c:if>
							<tr>
								<th style="border-left: none;">플랜트 </th>
								<td colspan="3">
									${recipeData.PLANT_NAME}	
								</td>								
							</tr>
							<tr>
								<th style="border-left: none;">제품수량 </th>
								<td>
									${recipeData.PRODUCT_COUNT}									
								</td>
								<th style="border-left: none;">제품단위</th>
								<td>
									${recipeData.UNIT_NAME}	
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div id="matDiv">
					<div class="title2" style="float: left; margin-top: 30px;">
						<span class="txt">원료</span>
					</div>
					<table id="matTable" class="tbl01" style="border-bottom: 2px solid #4b5165;">
						<colgroup>
							<col width="140">
							<col />
							<col width="150">
							<col width="100">
							<col width="150">
							<col width="100">
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
						<tbody id="mat_tbody" name="mat_tbody">
							<c:forEach items="${materialList}" var="materialList" varStatus="status">
							<tr id="mat_tr_${status.count}" class="temp_color">
								<td>
									<a href="#" onClick="fn_sapCodeview('${materialList.SAP_CODE}')">${materialList.SAP_CODE}</a>
								</td>
								<td>
									${materialList.ITEM_NAME}
								</td>
								<td>
									${materialList.ITEM_COUNT}
								</td>
								<td>
									${materialList.ITEM_UNIT_NAME}
								</td>
								<td>
									${materialList.USED_COUNT}
								</td>
								<td>
									${materialList.USED_UNIT_NAME}
								</td>
							</tr>
							</c:forEach>
						</tbody>
						<tfoot>
						</tfoot>
					</table>
				</div>				


				<div class="title2" style="float: left; margin-top: 30px;">
					<span class="txt">사입품</span>
				</div>
				<table id="new_Table" class="tbl01" style="border-bottom: 2px solid #4b5165;">
					<colgroup>
						<col />
						<col width="100">
						<col width="100">
						<col width="100">
						<col width="100">
						<col width="100">
						<col width="250">
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
					<tbody id="new_tbody" name="new_tbody">
						<c:forEach items="${purchaseList}" var="purchaseList" varStatus="status">
						<tr id="new_tr_${status.count}" class="temp_color">
							<td>
								${purchaseList.ITEM_NAME}
							</td>
							<td>
								${purchaseList.ITEM_COUNT}
							</td>
							<td>
								${purchaseList.ITEM_UNIT_NAME}
							</td>
							<td>
								${purchaseList.USED_COUNT}
							</td>
							<td>
								${purchaseList.USED_UNIT_NAME}
							</td>
							<td>
								${purchaseList.ITEM_PRICE}
							</td>
							<td>
								<span style="text-align: left;">${strUtil:getHtmlBr(purchaseList.ITEM_DESC)}</span>
							</td>
						</tr>
						</c:forEach>
					</tbody>
					<tfoot>
					</tfoot>
				</table>
				
			<div class="title2 mt20"  style="width:90%;"><span class="txt">첨부파일</span></div>
			<div class="list_detail">
				<ul style="">
					<li>
						<dt style="width: 20%">첨부파일</dt>
						<dd style="width: 80%;">
							<div class="add_file" id="add_file2" style="width:100%">
								
							</div>
							<div id="fileList" class="file_box_pop" style="height: 120px; width: 100%; border-top-left-radius: 0px; border-top-right-radius: 0px; border-top: 1px solid rgb(221, 221, 221); box-sizing: border-box;">
								<ul id="attatch_file">
									<c:forEach items="${recipeData.fileList}" var="fileList" varStatus="status">
										<li>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
									</c:forEach>
								</ul>	
							</div>
						</dd>
					</li>
				</ul>
			</div>

			<div class="main_tbl">
				<div class="btn_box_con5">
					<button class="btn_admin_gray" onClick="fn_goList();" style="width: 120px;">목록</button>
				</div>
				<div class="btn_box_con4">
				<c:if test="${recipeData.DOC_OWNER == userUtil:getUserId(pageContext.request) }">
					<c:if test="${recipeData.STATUS == 'TMP' and recipeData.IS_LAST == 'Y'}">
					<button class="btn_admin_navi" onclick="fn_update('${recipeData.RECIPE_IDX}')">수정</button>
					</c:if>
					<c:if test="${recipeData.STATUS == 'COMP' and recipeData.IS_LAST == 'Y'}">
					<button class="btn_admin_navi" onclick="fn_erp('${recipeData.RECIPE_IDX}')">ERP반영</button>
					</c:if>
					<c:if test="${recipeData.STATUS == 'BOM_ERROR' and recipeData.IS_LAST == 'Y'}">
					<button class="btn_admin_red" onclick="fn_erp('${recipeData.RECIPE_IDX}')">ERP재반영</button>
					</c:if>
					<c:if test="${recipeData.STATUS == 'BOM' and recipeData.IS_LAST == 'Y'}">
					<button class="btn_admin_sky" onclick="fn_versionUp('${recipeData.RECIPE_IDX}')">개정</button>
					</c:if>
				</c:if>	
				</div>
				<hr class="con_mode" />
			</div>
		</div>
	</section>
</div>

<!-- 자재 조회레이어 start-->
<div class="white_content" id="open3">
	<div class="modal" style="	width: 800px;margin-left:-400px;height: 450px;margin-top:-200px;">
		<h5 style="position:relative">
			<span class="title">상품 상세 정보</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('open3')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<div class="main_tbl">
				<table class="insert_proc01">
					<colgroup>
						<col width="15%" />
						<col width="35%" />
						<col width="15%" />
						<col width="35%" />
					</colgroup>
					<tbody>
						<tr>
							<th style="border-left: none;">상품코드</th>
							<td id="sapCodeTxt">

							</td>
							<th style="border-left: none;">상품명</th>
							<td id="nameTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">품목단위</th>
							<td colspan="3" id="unitTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">보관조건</th>
							<td id="keepTxt">

							</td>
							<th style="border-left: none;">중량</th>
							<td id="weightTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">규격</th>
							<td colspan="3" id="standardTxt">
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">사이즈(W/L/H)</th>
							<td colspan="3" id="sizeTxt">
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">원산지</th>
							<td id="originTxt">

							</td>
							<th style="border-left: none;">소비기한</th>
							<td id="expDateTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">부가가치세 코드</th>
							<td id="cdTxt" colspan="3">

							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>			
		<div class="btn_box_con">
			<button class="btn_admin_gray" onclick="closeDialog('open3')"> 닫기</button>
		</div>
	</div>
</div>
<!-- 자재 조회레이어 close-->
