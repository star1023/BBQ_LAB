<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>메뉴완료보고서 상세</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 400px; min-height:400px;}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	$(document).ready(function(){
		//history.replaceState({}, null, location.pathname);
		
		fn.autoComplete($("#keyword"));
		
		<c:forEach var="fileType" items="${menuData.fileType}" varStatus="status">
		$('input[type="checkbox"][value="${fileType.FILE_TYPE}"]').prop('checked', true);
		</c:forEach>
	});
	
	function downloadFile(idx){
		location.href = '/common/fileDownload?idx='+idx;
	}
	
	function fn_view(idx) {
		var URL = "../material/selectMaterialDataAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"idx" : idx
			},
			dataType:"json",
			async:false,
			success:function(data) {
				$("#nameTxt").html(data.data.NAME);
				$("#sapCodeTxt").html(data.data.SAP_CODE);
				$("#plantTxt").html(data.data.PLANT);
				$("#priceTxt").html(data.data.PRICE);
				$("#unitTxt").html(data.data.UNIT_NAME);
				$("#keepConditionTxt").html(data.data.KEEP_CONDITION);
				$("#sizeTxt").html(nvl(data.data.WIDTH,"0")+" / "+nvl(data.data.LENGTH,"0")+" / "+nvl(data.data.HEIGHT,"0"));
				$("#weightTxt").html(data.data.TOTAL_WEIGHT);
				$("#standardTxt").html(data.data.STANDARD);
				$("#originTxt").html(data.data.ORIGIN);
				$("#expireDateTxt").html(data.data.EXPIRATION_DATE);
				var typeName = "";
				if( chkNull(data.data.MATERIAL_TYPE_NAME1) ) {
					typeName += data.data.MATERIAL_TYPE_NAME1;
				}
				if( chkNull(data.data.MATERIAL_TYPE_NAME2) ) {
					typeName += " > "+data.data.MATERIAL_TYPE_NAME2;
				}
				if( chkNull(data.data.MATERIAL_TYPE_NAME3) ) {
					typeName += " > "+data.data.MATERIAL_TYPE_NAME3;
				}
				$("#typeTxt").html(typeName);
				var fileTypeTxt = "";
				data.fileType.forEach(function (item, index) {
					if( index == 0 ) {
						fileTypeTxt += item.FILE_TEXT
					} else {
						fileTypeTxt += ", "+item.FILE_TEXT
					}
				});
				$("#fileTypeTxt").html(fileTypeTxt);
				$("#fileDataList").html("");
				data.fileList.forEach(function (item) {
					var childTag = '<li>&nbsp;<a href="javascript:downloadFile(\''+item.FILE_IDX+'\')">'+item.ORG_FILE_NAME+'</a></li>'
					$("#fileDataList").append(childTag);
				});
				
				openDialog('open3');
			},
			error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	}
	
	function fn_erpview(code) {
		var URL = "../menu/selectErpMaterialDataAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"sapCode" : code
			},
			dataType:"json",
			async:false,
			success:function(data) {
				if( data.SAP_CODE != null && data.SAP_CODE != '' ) {
					$("#sapCodeTxt2").html(data.SAP_CODE);
					$("#nameTxt2").html(data.NAME);
					$("#unitTxt2").html(data.UNIT);
					$("#keepTxt2").html(data.KEEP_CONDITION_TXT);
					$("#matTypeTxt2").html(data.MAT_TYPE_TXT);
					$("#weightTxt2").html(data.TOTAL_WEIGHT);
					$("#changeUnitTxt2").html(data.CHANGE_UNIT);
					$("#changeCountTxt2").html(data.CHANGE_COUNT);
					$("#totalWeightTxt2").html(data.TOTAL_WEIGHT);
					$("#totalWeightUnitTxt2").html(data.TOTAL_WEIGHT_UNIT);
					$("#standardTxt2").html(data.STANDARD);
					$("#sizeTxt2").html(data.WIDTH+"("+data.WIDTH_UNIT+")"+" / "+data.LENGTH+"("+data.LENGTH_UNIT+")"+" / "+data.HEIGHT+"("+data.HEIGHT_UNIT+")");
					$("#originTxt2").html(data.ORIGIN);
					$("#expDateTxt2").html(data.EXPIRATION_DATE);			
					$("#leadTimeTxt2").html(data.LEAD_TIME);
					$("#safetyDayTxt2").html(data.SAFETY_STOCK_DAY);
					$("#boxAmountTxt2").html(data.BOX_AMOUNT);
					$("#palletAmountTxt2").html(data.PALLET_AMOUNT);
					$("#cdTxt2").html(data.CD_ACCT);
					$("#minOrderTxt2").html(data.MIN_ORDER_AMOUNT);			
					openDialog('open4');
				} else {
					alert("삭제된 상품정보입니다.");
				}
			},
			error:function(request, status, errorThrown){
				alert("삭제된 상품정보입니다.");
			}			
		});
	}
	
	function fn_list() {
		location.href = '/menu/list';
	}
	
	function fn_versionUp(idx) {
		location.href = '/menu/versionUp?idx='+idx;
	}
	
	function fn_apprSubmit(){
		if( $("#apprLine option").length == 0 ) {
			alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 결재상신 해 주세요.");
			return;
		} else {
			$('#lab_loading').show();
			var formData = new FormData();
			formData.append("docIdx",'${menuData.data.MENU_IDX}');
			formData.append("apprComment", $("#apprComment").val());
			formData.append("apprLine", $("#apprLine").selectedValues());
			formData.append("refLine", $("#refLine").selectedValues());
			formData.append("title", '${menuData.data.TITLE}');
			formData.append("docType", "MENU");
			formData.append("status", "N");
			var URL = "../approval/insertApprAjax";
			$.ajax({
				type:"POST",
				url:URL,
				dataType:"json",
				data: formData,
				processData: false,
		        contentType: false,
		        cache: false,
				success:function(data) {
					if(data.RESULT == 'S') {
						alert("등록되었습니다.");
						$('#lab_loading').hide();
						fn_list();
					} else {
						alert("결재선 상신 오류가 발생하였습니다."+data.MESSAGE);
						$('#lab_loading').hide();
						return;
					}
				},
				error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
					$('#lab_loading').hide();
				}			
			});
		}
	}
	
	function tabChange(tabId) {
		if( tabId == 'tab1' ) {
			$("#tab1_div").show();
			$("#tab1_li").prop("class","select");
			$("#tab2_div").hide();
			$("#tab2_li").prop("class","");
		} else {
			$("#tab1_div").hide();
			$("#tab1_li").prop("class","");
			$("#tab2_div").show();
			$("#tab2_li").prop("class","select");
		}
	}
	
	function fn_update(idx) {
		location.href = '/menu/update?idx='+idx;
	}
	
	function fn_pdfDownload(idx) {
		$('#lab_loading').show();
	    fetch("/preview/menuViewPopup?idx=" + idx)
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
				  + "@page{margin:0}body{margin:0;padding:0;}@media print{body{margin:0;background:white!important;padding:10px}html,body{width:210mm;height:auto;background:white!important}}#wrapper{background:white;padding:20px;box-sizing:border-box}table{table-layout:fixed;border-collapse:collapse;width:100%}.main_tbl{margin:2.5px 0;table-layout:fixed;border-collapse:collapse;width:100%;border:1px solid #333}th{background-color:#f2f2f2;-webkit-print-color-adjust:exact}td,th{border-collapse:collapse;border:1px solid #bbb;text-align:left;font-size:12px;padding:7px}td{background-color:#fff}pre{margin:0;padding:0;line-height:1.5;white-space:pre-wrap}.inner-table-cell{padding:0;border-collapse:collapse}td.inner-table-cell{padding:1px!important}td.inner-table-cell table{border:1px solid #333}.mainTable{border:1px solid #000;margin:2.5px 0}.btn_print{width:36px;height:36px;border:none;background-color:transparent;cursor:pointer;margin-top:7px}"
				  + "</style>"
				  + "</head>"
				  + "<body>"
				  + wrapperHTML
				  + "</body>"
				  + "</html>";

	            var formData = new FormData();
	            formData.append("htmlContent", fullHtml);
	            formData.append("docIdx", idx);
				formData.append("docType", "MENU");
				formData.append("userId", "${userId}");
				var title = "${menuData.data.TITLE}_메뉴완료보고서";
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
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">
		메뉴완료보고서 상세&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;개발완료보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Complete Document</span><span class="title">메뉴완료보고서 상세</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<c:if test="${menuData.data.STATUS == 'TMP' and menuData.data.IS_LAST == 'Y'}">
						<button class="btn_circle_modifiy" onclick="fn_update('${menuData.data.MENU_IDX}')">&nbsp;</button>
						</c:if>
						<c:if test="${menuData.data.STATUS == 'COMP' and menuData.data.IS_LAST == 'Y'}">
						<button class="btn_circle_version" onclick="fn_versionUp('${menuData.data.MENU_IDX}')">&nbsp;</button>
						</c:if>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="tab02">
				<ul style="display:flex; justify-content:space-between;">
					<!-- 선택됬을경우는 탭 클래스에 select를 넣어주세요 -->
					<!-- 내 메뉴설계서 같은경우는 change select 이렇게 change 그대로 두고 한칸 띄고 select 삽입 -->
					<div>
						<a href="#" onClick="tabChange('tab1')"><li  class="select" id="tab1_li">기안내용</li></a>
						<a href="#" onClick="tabChange('tab2')"><li class="" id="tab2_li">완료보고서상세정보</li></a>
					</div>
					<div>
						<c:if test="${menuData.data.STATUS eq 'COMP' && menuData.data.DOC_OWNER eq userId}">
					    	<button class="btn_small_search ml5" onclick="fn_pdfDownload('${menuData.data.MENU_IDX}')">PDF 다운로드</button>
					    </c:if>
					</div>
				</ul>
			</div>

			<div id="tab1_div">
				<div class="title2"  style="width: 80%;"><span class="txt">제목 </span></div>
				<div class="title2" style="width: 20%; display: inline-block;">						
				</div>
				<div class="main_tbl">
					<table class="tbl05" style="border-top: 2px solid #4b5165;">
						<colgroup>
							<col  />							
						</colgroup>
						<tbody>
							<tr>
								<td>
									<div class="ellipsis_txt tgnl">
									${menuData.data.TITLE}
									</div>
									<input type="hidden" name="idx" id="idx" value="${menuData.data.MENU_IDX}"/>
									<input type="hidden" name="docNo" id="docNo" value="${menuData.data.DOC_NO}"/>
									<input type="hidden" name="currentVersionNo" id="currentVersionNo" value="${menuData.data.VERSION_NO}"/>
									<input type="hidden" name="currentStatus" id="currentStatus" value="${menuData.data.STATUS}"/>
									<input type="hidden" name="menuCode" id="menuCode" value="${menuData.data.MENU_CODE}"/>	
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="title2"  style="width: 80%;"><span class="txt">메뉴명</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">
				</div>
				<div class="main_tbl">
					<table class="tbl05" style="border-top: 2px solid #4b5165;">
						<colgroup>
							<col  />							
						</colgroup>
						<tbody>
							<tr>
								<td>
									<div class="ellipsis_txt tgnl">
									${menuData.data.NAME}
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<c:if test="${menuData.data.VERSION_NO == 1 && addInfoCount.PUR_CNT > 0 }">
				<div class="title2"  style="width: 80%; margin-top:20px;"><span class="txt">개발 목적</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">
				</div>
				<div class="main_tbl">
					<table class="tbl05" style="border-top: 2px solid #4b5165;">
						<colgroup>
							<col  />							
						</colgroup>
						<tbody id="purpose_tbody" name="purpose_tbody">
							<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
								<c:if test="${addInfoList.INFO_TYPE == 'PUR' }">
								<tr id="purpose_tr_${status.count}">
									<td>
										<div class="ellipsis_txt tgnl">
										${addInfoList.INFO_TEXT}
										</div>
									</td>
								</tr>
								</c:if>
							</c:forEach>
						</tbody>
					</table>
				</div>
				</c:if>
				
				<c:if test="${menuData.data.VERSION_NO == 1 && addInfoCount.FEA_CNT > 0 }">
				<div class="title2"  style="width: 80%;"><span class="txt">메뉴 특징</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">
				</div>
				<div class="main_tbl">
					<table class="tbl05" style="border-top: 2px solid #4b5165;">
						<colgroup>
							<col  />							
						</colgroup>
						<tbody id="feature_tbody" name="feature_tbody">
							<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
								<c:if test="${addInfoList.INFO_TYPE == 'FEA' }">
								<tr id="feature_tr_${status.count}">
									<td>
										<div class="ellipsis_txt tgnl">
										${addInfoList.INFO_TEXT}
										</div>
									</td>
								</tr>
								</c:if>
							</c:forEach>
						</tbody>
					</table>
				</div>
				</c:if>
				
				<c:if test="${menuData.data.VERSION_NO != 1 && fn:length(imporvePurposeList) > 0 }">
					<div class="title2" style="float: left; margin-top: 30px;">
						<span class="txt">개선 목적</span>
					</div>
					<table id="improve_pur_Table" class="tbl01">
						<colgroup>
							<col width="30%">
							<col width="30%">
							<col />
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
								<tr id="improve_pur_tr__${status.count}" class="temp_color">
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
						<tfoot>
						</tfoot>
					</table>
				</c:if>
				
				<c:if test="${menuData.data.VERSION_NO != 1 && addInfoCount.IMP_CNT > 0 }">
				<div class="title2"  style="width: 80%;"><span class="txt">개선 사항</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">
				</div>
				<div class="main_tbl">
					<table class="tbl05" style="border-top: 2px solid #4b5165;">
						<colgroup>
							<col  />							
						</colgroup>
						<tbody id="feature_tbody" name="feature_tbody">
							<c:forEach items="${addInfoList}" var="addInfoList" varStatus="status">
								<c:if test="${addInfoList.INFO_TYPE == 'IMP' }">
								<tr id="feature_tr_${status.count}">
									<td>
										<div class="ellipsis_txt tgnl">
										${addInfoList.INFO_TEXT}
										</div>
									</td>
								</tr>
								</c:if>
							</c:forEach>
						</tbody>
					</table>
				</div>
				</c:if>
						
				<c:if test="${addInfoCount.USB_CNT > 0}">
					<div class="title2" style="margin-top:20px;"><span class="txt">브랜드</span></div>
					<div class="main_tbl">
						<table class="tbl05" style="border-top: 2px solid #4b5165;">
							<tbody>
								<tr>
									<td>
										<div class="ellipsis_txt tgnl">
											<%-- USB 총 개수 먼저 계산 --%>
											<c:set var="usbCount" value="0" />
											<c:forEach items="${addInfoList}" var="item">
												<c:if test="${item.INFO_TYPE == 'USB'}">
													<c:set var="usbCount" value="${usbCount + 1}" />
												</c:if>
											</c:forEach>
											
											<%-- 출력 --%>
											<c:set var="usbIndex" value="0" />
											<c:forEach items="${addInfoList}" var="item">
												<c:if test="${item.INFO_TYPE == 'USB'}">
													<c:set var="usbIndex" value="${usbIndex + 1}" />
													${item.INFO_TEXT_NAME}
													<c:if test="${usbIndex < usbCount}">, </c:if>
												</c:if>
											</c:forEach>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</c:if>
				
				<c:if test="${addInfoCount.USC_CNT > 0}">
					<div class="title2"><span class="txt">용도</span></div>
					<div class="main_tbl">
						<table class="tbl05" style="border-top: 2px solid #4b5165;">
							<tbody>
								<tr>
									<td>
										<div class="ellipsis_txt tgnl">
											<c:forEach items="${addInfoList}" var="item" varStatus="loop">
												<c:if test="${item.INFO_TYPE == 'USC'}">
													${item.INFO_TEXT}
													<c:if test="${!loop.last}">, </c:if>
												</c:if>
											</c:forEach>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</c:if>
				
				<div id="">
					<div class="title2" style="float: left; margin-top: 30px;">
						<span class="txt">신규도입품/제품규격</span>
					</div>
					<table id="new_Table" class="tbl01" style="border-bottom: 2px solid #4b5165;">
						<colgroup>
							<col width="140">
							<col width="140">
							<col width="250">
							<col width="150">
							<col />
						</colgroup>
						<thead>
							<tr>
								<th>제품명</th>
								<th>포장규격</th>
								<th>공급처 및 담당자</th>
								<th>보관조건 및 소비기한</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="new_tbody" name="new_tbody">
							<c:if test="${fn:length(newDataList) > 0}">
								<c:forEach items="${newDataList}" var="newDataList" varStatus="status">
									<c:if  test="${newDataList.TYPE_CODE == 'A'}">
										<tr id="new_tr_${status.count}" class="temp_color">
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
									</c:if>
								</c:forEach>							
							</c:if>
						</tbody>
					</table>
				</div>
				
				<div id="">
					<div class="title2" style="float: left;">
						<span class="txt">추정원가</span>
					</div>
					<table id="new1_Table" class="tbl01" style="border-bottom: 2px solid #4b5165;">
						<colgroup>
							<col width="140">
							<col width="140">
							<col width="250">
							<col width="150">
							<col />
						</colgroup>
						<thead>
							<tr>
								<th>메뉴명</th>
								<th>포장규격</th>
								<th>공급처 및 담당자</th>
								<th>보관조건 및 소비기한</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody id="new1_tbody" name="new1_tbody">
							<c:forEach items="${newDataList}" var="newDataList" varStatus="status">
								<c:if  test="${newDataList.TYPE_CODE == 'B'}">
									<tr id="new1_tr_${status.count}" class="temp_color">
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
								</c:if>
							</c:forEach>							
						</tbody>
					</table>
				</div>
				
				<div class="title2"  style="width: 80%;  margin-top: 30px;"><span class="txt">도입 예정일</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">
				</div>
				<div class="main_tbl">
					<table class="tbl05" style="border-top: 2px solid #4b5165;">
						<colgroup>
							<col  />							
						</colgroup>
						<tbody>
							<tr>
								<td>
									<div class="ellipsis_txt tgnl">
									<c:choose>
										<c:when test="${menuData.data.SCHEDULE_DATE != null && menuData.data.SCHEDULE_DATE != '' }">
										${menuData.data.SCHEDULE_DATE}	
										</c:when>
										<c:otherwise>
										&nbsp;결재 후 즉시도입
										</c:otherwise>
									</c:choose>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div class="title2 mt20"  style="width:90%;  margin-top: 30px;"><span class="txt">첨부파일</span></div>
				<div class="list_detail">
					<ul style="">
						<li>
							<dt style="width: 20%">파일유형</dt>
							<dd style="width: 80%;">
								<input id="checkbox_item1" name="docType" type="checkbox" value="10" disabled/>
								<label for="checkbox_item1" style="vertical-align: middle;"><span></span>컨셉서-개발목적</label>
								<input id="checkbox_item2" name="docType" type="checkbox" value="20" disabled/>
								<label for="checkbox_item2" style="vertical-align: middle;"><span></span>추정 원단위표</label>
								<input id="checkbox_item3" name="docType" type="checkbox" value="30" disabled/>
								<label for="checkbox_item3" style="vertical-align: middle;"><span></span>배합비&제조신고용 배합비</label>						
								<input id="checkbox_item4" name="docType" type="checkbox" value="40" disabled/>
								<label for="checkbox_item4" style="vertical-align: middle;"><span></span>제조공정도</label>						
								<input id="checkbox_item5" name="docType" type="checkbox" value="50" disabled/>
								<label for="checkbox_item5" style="vertical-align: middle;"><span></span>제조작업표준서</label>
								<input id="checkbox_item6" name="docType" type="checkbox" value="60" disabled/>
								<label for="checkbox_item6" style="vertical-align: middle;"><span></span>제품규격서</label>
							</dd>
						</li>
						<li>
							<dt style="width: 20%">첨부파일</dt>
							<dd style="width: 80%;">
								<div class="add_file" id="add_file2" style="width:100%">									
								</div>
								<div id="fileList" class="file_box_pop" style="height: 120px; width: 100%; border-top-left-radius: 0px; border-top-right-radius: 0px; border-top: 1px solid rgb(221, 221, 221); box-sizing: border-box;">
									<ul id="attatch_file" class="file_list">
										<c:forEach items="${menuData.fileList}" var="fileList" varStatus="status">
											<li>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
										</c:forEach>
									</ul>	
								</div>
							</dd>
						</li>
					</ul>
				</div>
				<%-- <div class="con_file" style="">
					<ul>
						<li class="point_img" style="display:flex;">
							<dt>첨부파일</dt><dd>
								<ul>
									<c:forEach items="${menuData.fileList}" var="fileList" varStatus="status">
										<li>&nbsp;<a href="javascript:downloadFile('${fileList.FILE_IDX}')">${fileList.ORG_FILE_NAME}</a></li>
									</c:forEach>
								</ul>
							</dd>
						</li>
					</ul>
				</div> --%>
				
			</div>
			<div id="tab2_div" style="display:none">
				<div class="title2"  style="width: 80%;"><span class="txt">기본정보</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">
					
				</div>
				<div class="main_tbl">
					<table class="insert_proc01" style="border-bottom: 2px solid #4b5165;">
						<colgroup>
							<col width="15%" />
							<col width="35%" />
							<col width="15%" />
							<col width="35%" />
						</colgroup>
						<tbody>
							<tr>
								<th style="border-left: none;">메뉴코드</th>
								<td>
									${menuData.data.MENU_CODE}
								</td>
								<th style="border-left: none;">상품코드</th>
								<td>
									${menuData.data.SAP_CODE}
								</td>
							</tr>
							<c:if test="${userUtil:getUserId(pageContext.request) == menuData.data.DOC_OWNER }">
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
							    <th style="border-left: none;">공동 참여자</th>
							    <td colspan="3">
							        <c:forEach var="user" items="${sharedUserList}" varStatus="status">
							            ${user.USER_NAME}<c:if test="${!status.last}">, </c:if>
							        </c:forEach>
							    </td>
							</tr>
							<tr>
								<th style="border-left: none;">버전 No.</th>
								<td colspan="3">
									${menuData.data.VERSION_NO}
								</td>
							</tr>
							<!-- 
							<tr>
								<th style="border-left: none;">중량</th>
								<td>
									${menuData.data.TOTAL_WEIGHT}
								</td>
								<th style="border-left: none;">메뉴규격</th>
								<td>
									${menuData.data.STANDARD}								
								</td>
								
							</tr>
							<tr>
								<th style="border-left: none;">보관방법</th>
								<td>
									${menuData.data.KEEP_CONDITION}	
								</td>
								<th style="border-left: none;">소비기한</th>
								<td>
									${menuData.data.EXPIRATION_DATE}									
								</td>							
							</tr>
							 -->
							<tr>
								<th style="border-left: none;">메뉴유형</th>
								<td colspan="5">
									<c:if test="${menuData.data.MENU_TYPE1 != null }">
									${menuData.data.MENU_TYPE_NAME1}
									</c:if>
									<c:if test="${menuData.data.MENU_TYPE2 != null }">
									&gt; ${menuData.data.MENU_TYPE_NAME2}
									</c:if>
									<c:if test="${menuData.data.MENU_TYPE3 != null }">
									&gt; ${menuData.data.MENU_TYPE_NAME3}
									</c:if>
								</td>
							</tr>
							<tr style='display:none'>
								<th style="border-left: none;">첨부파일 유형</th>
								<td colspan="3">
									<c:forEach items="${menuData.fileType}" var="fileType" varStatus="status">
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
				<c:if test="${menuData.data.IS_NEW_MATERIAL == 'Y' }">
				<div class="title2" style="float: left; margin-top: 30px;">
					<span class="txt">신규원료</span>
				</div>
				<div class="main_tbl">				
					<table class="tbl01 " style="border-bottom: 2px solid #4b5165;">
						<colgroup>
							<col width="140">
							<col width="140">
							<col width="250">
							<col width="150">
							<col width="200">
							<col width="8%">
							<col />
						</colgroup>
						<thead>
							<tr>
								<th>원료코드</th>
								<th>ERP코드</th>
								<th>원료명</th>
								<th>규격</th>
								<th>보관방법 및 소비기한</th>
								<th>공급가</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody>
						<c:forEach items="${menuMaterialData}" var="menuMaterialData" varStatus="status">
						<c:if test="${menuMaterialData.MATERIAL_TYPE == 'Y' }">
							<tr>
								<td>
									<div class=""><a href="#" onClick="fn_view('${menuMaterialData.MATERIAL_IDX}')">${menuMaterialData.MATERIAL_CODE}</a></div>
								</td>
								<td>
									<a href="#" onClick="fn_erpview('${menuMaterialData.SAP_CODE}')">${menuMaterialData.SAP_CODE}</a>
								</td>
								<td>
									${menuMaterialData.NAME}
								</td>
								<td>
									${menuMaterialData.STANDARD}
								</td>
								<td>
									${menuMaterialData.KEEP_EXP}
								</td>
								<td>
									${menuMaterialData.UNIT_PRICE}
								</td>
								<td>
									${menuMaterialData.DESCRIPTION}
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
				
				<div class="title2" style="float: left; margin-top: 30px;">
					<span class="txt">기존원료</span>
				</div>
				<div class="main_tbl">				
					<table class="tbl01 " style="border-bottom: 2px solid #4b5165;">
						<colgroup>
							<col width="140">
							<col width="140">
							<col width="250">
							<col width="150">
							<col width="200">
							<col width="8%">
							<col />
						</colgroup>
						<thead>
							<tr>
								<th>원료코드</th>
								<th>ERP코드</th>
								<th>원료명</th>
								<th>규격</th>
								<th>보관방법 및 소비기한</th>
								<th>공급가</th>
								<th>비고</th>
							</tr>
						</thead>
						<tbody>
						<c:forEach items="${menuMaterialData}" var="menuMaterialData" varStatus="status">
						<c:if test="${menuMaterialData.MATERIAL_TYPE == 'N' }">
							<tr>
								<td>
									<div class=""><a href="#" onClick="fn_erpview('${menuMaterialData.SAP_CODE}')">${menuMaterialData.MATERIAL_CODE}</a></div>
								</td>
								<td>
									<a href="#" onClick="fn_erpview('${menuMaterialData.SAP_CODE}')">${menuMaterialData.SAP_CODE}</a>
								</td>
								<td>
									${menuMaterialData.NAME}
								</td>
								<td>
									${menuMaterialData.STANDARD}
								</td>
								<td>
									${menuMaterialData.KEEP_EXP}
								</td>
								<td>
									${menuMaterialData.UNIT_PRICE}
								</td>
								<td>
									${menuMaterialData.DESCRIPTION}
								</td>
							</tr>
						</c:if>	
						</c:forEach>	
						</tbody>
						<tfoot>
						</tfoot>
					</table>
				</div>
				
				<div class="title2 mt20"  style="width:90%;"><span class="txt">비고</span></div>
				<div>
					<table class="insert_proc01" style="border-bottom: 2px solid #4b5165;">
						<tr>
							<td>${menuData.data.CONTENTS}</td>
						</tr>
					</table>
				</div>
			</div>
			<div class="main_tbl">
				<div class="btn_box_con5">					
				</div>
				<div class="btn_box_con4">
					<c:if test="${userUtil:getUserId(pageContext.request) == menuData.data.DOC_OWNER }">
						<c:if test="${(menuData.data.STATUS == 'TMP' or menuData.data.STATUS == 'COND_APPR') and menuData.data.IS_LAST == 'Y'}">
							<button class="btn_admin_sky" onclick="fn_update('${menuData.data.MENU_IDX}')">수정</button>
						</c:if>	
					</c:if>
					<button class="btn_admin_gray" onClick="fn_list();" style="width: 120px;">목록</button>
				</div>
				<hr class="con_mode" />
			</div>
			
		</div>
	</section>
</div>

<!-- 자재조회 레이어 start-->
<div class="white_content" id="open3">
	<div class="modal" style="	width: 800px;margin-left:-400px;height: 600px;margin-top:-250px;">
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
							<th style="border-left: none;">원료명</th>
							<td id="nameTxt">

							</td>
							<th style="border-left: none;">SAP 코드</th>
							<td id="sapCodeTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">단가</th>
							<td id="priceTxt">

							</td>
							<th style="border-left: none;">단위</th>
							<td id="unitTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">보관기준</th>
							<td id="keepConditionTxt">

							</td>
							<th style="border-left: none;">사이즈</th>
							<td id="sizeTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">중량</th>
							<td id="weightTxt">

							</td>
							<th style="border-left: none;">규격</th>
							<td id="standardTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">원산지</th>
							<td id="originTxt">

							</td>
							<th style="border-left: none;">소비기한</th>
							<td id="expireDateTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">원료구분상세</th>
							<td colspan="3" id="typeTxt">
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">첨부파일 유형</th>
							<td colspan="3" id="fileTypeTxt">
							</td>
						</tr>
<!-- 						<tr>
							<th style="border-left: none;">첨부파일</th>
							<td colspan="3">
								<div class="file_box_pop" style=" height:120px; width:97.5%; border-top-left-radius:0px;border-top-right-radius:0px; border-top:1px solid #ddd;box-sizing:border-box;">
									<ul id="fileDataList">									
									</ul>
								</div>
							</td>
						</tr> -->
					</tbody>
				</table>
			</div>
			<div class="list_detail">
			<ul>
				<li>
					<div class="add_file2" style="width:97.5%">
						<span class="" >
							<label>첨부파일</label>
						</span>						
					</div>
					<div class="file_box_pop" style=" height:120px; width:97.5%; border-top-left-radius:0px;border-top-right-radius:0px; border-top:1px solid #ddd;box-sizing:border-box;">
						<ul id="fileDataList">									
						</ul>
					</div>
				</li>
			</ul>
			</div>
		</div>			
		<div class="btn_box_con">
			<button class="btn_admin_gray" onclick="closeDialog('open3')"> 닫기</button>
		</div>
	</div>
</div>
<!-- 자재조회 레이어 close-->

<!-- 자재 조회레이어 start-->
<div class="white_content" id="open4">
	<div class="modal" style="	width: 800px;margin-left:-400px;height: 550px;margin-top:-250px;">
		<h5 style="position:relative">
			<span class="title">상품 상세 정보</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('open4')"></button>
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
							<td id="sapCodeTxt2">

							</td>
							<th style="border-left: none;">상품명</th>
							<td id="nameTxt2">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">보관조건</th>
							<td id="keepTxt2">

							</td>
							<th style="border-left: none;">유형</th>
							<td id="matTypeTxt2">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">품목단위</th>
							<td id="unitTxt2">

							</td>
							<th style="border-left: none;">중량</th>
							<td id="weightTxt2">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">환산단위</th>
							<td id="changeUnitTxt2">

							</td>
							<th style="border-left: none;">환산수량</th>
							<td id="changeCountTxt2">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">총중량</th>
							<td id="totalWeightTxt2">

							</td>
							<th style="border-left: none;">총중량단위</th>
							<td id="totalWeightUnitTxt2">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">규격</th>
							<td colspan="3" id="standardTxt2">
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">사이즈(W/L/H)</th>
							<td colspan="3" id="sizeTxt2">
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">원산지</th>
							<td id="originTxt2">

							</td>
							<th style="border-left: none;">소비기한</th>
							<td id="expDateTxt2">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">리드타임</th>
							<td id="leadTimeTxt2">
							</td>
							<th style="border-left: none;">안전재고일수</th>
							<td id="safetyDayTxt2">
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">박스당입수량</th>
							<td id="boxAmountTxt2">
							</td>
							<th style="border-left: none;">파레트입수량</th>
							<td id="palletAmountTxt2">
							</td>
						</tr>						
						<tr>
							<th style="border-left: none;">부가세 코드</th>
							<td id="cdTxt2">

							</td>
							<th style="border-left: none;">최소발주량</th>
							<td id="minOrderTxt2">
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>			
		<div class="btn_box_con">
			<button class="btn_admin_gray" onclick="closeDialog('open4')"> 닫기</button>
		</div>
	</div>
</div>
<!-- 자재 상세레이어 close-->

<!-- 결재 상신 레이어  start-->
<div class="white_content" id="approval_dialog">
	<input type="hidden" id="docType" value="PROD"/>
 	<input type="hidden" id="deptName" />
	<input type="hidden" id="teamName" />
	<input type="hidden" id="userId" />
	<input type="hidden" id="userName"/>
 	<select style="display:none" id=apprLine name="apprLine" multiple>
 	</select>
 	<select style="display:none" id=refLine name="refLine" multiple>
 	</select>
	<div class="modal" style="	margin-left:-500px;width:1000px;height: 550px;margin-top:-300px">
		<h5 style="position:relative">
			<span class="title">개발완료보고서 결재 상신</span>
			<div  class="top_btn_box">
				<ul><li><button class="btn_madal_close" onClick="apprClass.apprCancel(); return false;"></button></li></ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li>
					<dt style="width:20%">결재요청의견</dt>
					<dd style="width:80%;">
						<div class="insert_comment">
							<table style=" width:756px">
								<tr>
									<td>
										<textarea style="width:100%; height:50px" placeholder="의견을 입력하세요" name="apprComment" id="apprComment"></textarea>
									</td>
									<td width="98px"></td>
								</tr>
							</table>
						</div>
					</dd>
				</li>
				<li class="pt5">
					<dt style="width:20%">결재자 입력</dt>
					<dd style="width:80%;" class="ppp">
						<input type="text" placeholder="결재자명 2자이상 입력후 선택" style="width:198px; float:left;" class="req" id="keyword" name="keyword">
						<button class="btn_small01 ml5" onclick="apprClass.approvalAddLine(this); return false;" name="appr_add_btn" id="appr_add_btn">결재자 추가</button>
						<button class="btn_small02  ml5" onclick="apprClass.approvalAddLine(this); return false;" name="ref_add_btn" id="ref_add_btn">참조</button>
						<div class="selectbox ml5" style="width:180px;">
							<label for="apprLineSelect" id="apprLineSelect_label">---- 결재라인 불러오기 ----</label>
							<select id="apprLineSelect" name="apprLineSelect" onchange="apprClass.changeApprLine(this);">
								<option value="">---- 결재라인 불러오기 ----</option>
							</select>
						</div>
						<button class="btn_small02  ml5" onclick="apprClass.deleteApprovalLine(this); return false;">선택 결재라인 삭제</button>
					</dd>
				</li>
				<li  class="mt5">
					<dt style="width:20%; background-image:none;" ></dt>
					<dd style="width:80%;">
						<div class="file_box_pop2" style="height:190px;">
							<ul id="apprLineList">
							</ul>
						</div>
						<div class="file_box_pop3" style="height:190px;">
							<ul id="refLineList">
							</ul>
						</div>
						<!-- 현재 추가된 결재선 저장 버튼을 누르면 안보이게 처리 start -->
						<div class="app_line_edit">
							저장 결재선라인 입력 :  <input type="text" name="apprLineName" id="apprLineName" class="req" style="width:280px;"/> 
							<button class="btn_doc" onclick="apprClass.approvalLineSave(this);  return false;"><img src="../resources/images/icon_doc11.png"> 저장</button> 
							<button class="btn_doc" onclick="apprClass.apprLineSaveCancel(this); return false;"><img src="../resources/images/icon_doc04.png">취소</button>
						</div>
						<!-- 현재 추가된 결재선 저장 버튼 눌렀을때 보이게 처리 close -->
					</dd>
				</li>
			</ul>
		</div>
		<div class="btn_box_con4" style="padding:15px 0 20px 0">
			<button class="btn_admin_red" onclick="fn_apprSubmit(); return false;">결재등록</button> 
			<button class="btn_admin_gray" onclick="apprClass.apprCancel(); return false;">결재삭제</button>
		</div>
	</div>
</div>
<!-- 결재 상신 레이어  close-->