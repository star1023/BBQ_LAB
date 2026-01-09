<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>  <!-- ✅ 이거 추가 -->
<title>메뉴 품질 점검 결과 보고서</title>
<style>
#dynamicHeaderRow th{
	background-color: #fafafa;
}
</style>
<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
$(document).ready(function(){
	//history.replaceState({}, null, location.pathname);
	
	fn.autoComplete($("#keyword"));
});
// ✅ 강제로 최대화 상태로 설정
/* stepchage('width_wrap', 'wrap_in02');
setPersonalization('WIDTH_MODE', 'wrap_in02'); */

let _columnFullList = [];
let _columnStateCodes = "${newProductResultData.data.COLUMN_STATE}".split(',');
let resultItemList = [];
<c:if test="${not empty itemList}">
    resultItemList = [
    <c:forEach var="item" items="${itemList}" varStatus="status">
        {
            ROW_NO: ${item.ROW_NO},
            COLUMN_CODE: "${item.COLUMN_CODE}",
            COLUMN_VALUE: "${item.COLUMN_VALUE}"
        }<c:if test="${!status.last}">,</c:if>
    </c:forEach>
    ];
</c:if>
$(document).ready(function () {
	// ✅ 섹션 숨김 조건 추가
	if (_columnStateCodes.length === 1 && _columnStateCodes[0] === "" && resultItemList.length === 0) {
	    document.getElementById("dynamicTableSection").style.display = "none";
	}

});

// ✅ 페이지 로드시 코드 목록 먼저 불러오고 렌더링
$.ajax({
    type: "POST",
    url: "../common/codeListAjax",
    data: { groupCode: "COLUMN" },
    dataType: "json",
    success: function (data) {
        _columnFullList = data.RESULT;
        renderDynamicColGroup();
        renderDynamicHeader();  // 헤더 그리기
        renderDynamicBody()		// 바디 그리기
    },
    error: function () {
        alert("컬럼 정보를 불러오는데 실패했습니다.");
    }
});

function renderDynamicBody() {
    const tbody = document.getElementById("dynamicBody");

    const rowMap = {};
    resultItemList.forEach(item => {
        const rowNo = item.ROW_NO;
        const colCode = item.COLUMN_CODE;
        const colValue = item.COLUMN_VALUE;

        if (!rowMap[rowNo]) rowMap[rowNo] = {};
        rowMap[rowNo][colCode] = colValue;
    });

    let imageMap = {};
    <c:if test="${not empty itemImageList}">
        imageMap = {
            <c:forEach var="img" items="${itemImageList}" varStatus="status">
                "${img.ROW_NO}": (imageMap["${img.ROW_NO}"] || []).concat(["/images${img.FILE_PATH}/${img.FILE_NAME}"])
                <c:if test="${!status.last}">,</c:if>
            </c:forEach>
        };
    </c:if>

    Object.keys(rowMap).sort((a, b) => a - b).forEach(rowNo => {
        const tr = document.createElement("tr");
        _columnStateCodes.forEach(code => {
            const td = document.createElement("td");

            // 컬럼명 확인 (코드로 매칭)
            const colMeta = _columnFullList.find(c => c.itemCode === code);
            const isImageColumn = colMeta && colMeta.itemName.includes("이미지");

            if (isImageColumn) {
                td.style.textAlign = "center"; // 가운데 정렬

                const images = imageMap[rowNo];
                if (images && images.length > 0) {
                	images.forEach(src => {
                	    const a = document.createElement("a");
                	    a.href = src;
                	    a.target = "_blank"; // 새창 열기
                	    a.style.display = "inline-block";
                	    a.style.marginRight = "5px";

                	    const img = document.createElement("img");
                	    img.src = src;
                	    img.style.maxWidth = "240px";
                	    img.style.maxHeight = "200px";
                	    img.style.height = "auto";
                	    img.style.objectFit = "contain";

                	    a.appendChild(img);     // ⬅️ 이미지 <a> 안에 삽입
                	    td.appendChild(a);      // ⬅️ <a>를 <td>에 추가
                	});
                } else {
                    // ✅ 이미지 없을 때 기본 이미지 표시
                    const img = document.createElement("img");
                    img.src = "/resources/images/img_noimg3.png"; // 기본 이미지 경로
                    img.style.width = "80px";
                    img.style.height = "80px";
                    img.style.objectFit = "contain";
                    img.style.border = "1px solid #ccc";
                    img.style.borderRadius = "4px";
                    td.appendChild(img);
                }
            } else {
            	const val = rowMap[rowNo][code] || "\u00A0";
            	td.textContent = val;
            }

            tr.appendChild(td);
        });

        tbody.appendChild(tr);
    });
}
// 동적 헤더 생성
function renderDynamicHeader() {
    const headerRow = document.getElementById("dynamicHeaderRow");
    if (!_columnFullList || _columnFullList.length === 0) return;

    _columnStateCodes.forEach(code => {
        let match = _columnFullList.find(c => c.itemCode === code);
        let th = document.createElement("th");
        th.textContent = match ? match.itemName : code;
        headerRow.appendChild(th);
    });
}

function fn_apprSubmit(){
	if( $("#apprLine option").length == 0 ) {
		alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 결재상신 해 주세요.");
		return;
	} else {
		$('#lab_loading').show();
		var formData = new FormData();
		formData.append("docIdx",'${newProductResultData.data.RESULT_IDX}');
		formData.append("apprComment", $("#apprComment").val());
		formData.append("apprLine", $("#apprLine").selectedValues());
		formData.append("refLine", $("#refLine").selectedValues());
		formData.append("title", "${newProductResultData.data.TITLE}");
		formData.append("docType", "RESULT");
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
function fn_list() {
	location.href = '/newProductResult/list';
}
function fn_update(idx) {
	location.href = '/newProductResult/update?idx='+idx;
}

function downloadFile(idx){
	location.href = '/common/fileDownload?idx='+idx;
}

function fn_pdfDownload(idx) {
	$('#lab_loading').show();
	//var url = "/preview/newProductViewPopup?idx=" + idx
	//var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes");
    fetch("/preview/newProductViewPopup?idx=" + idx)
        .then(function(res) {
            return res.text();
        })
        .then(function(html) {
            var parser = new DOMParser();
            var doc = parser.parseFromString(html, "text/html");

            var imgTags = doc.querySelectorAll("img");

            // 이미지 base64 변환
            var imagePromises = Array.from(imgTags).map(function(img) {
            var src = img.getAttribute("src");
                if (!src || src.startsWith("data:")) {
                    return Promise.resolve();
                }

                var absoluteSrc = src.startsWith("http") ? src : location.origin + src;

                return fetch(absoluteSrc)
                    .then(function(res) { return res.blob(); })
                    .then(function(blob) {
                        return new Promise(function(resolve) {
                            var reader = new FileReader();
                            reader.onloadend = function() {
                                img.setAttribute("src", reader.result);
                                resolve();
                            };
                            reader.readAsDataURL(blob);
                        });
                    })
                    .catch(function(e) {
                        console.warn("이미지 변환 실패", src, e);
                    });
            });

            Promise.all(imagePromises).then(function() {
                var wrapperHTML = doc.querySelector("#wrapper")?.outerHTML;
                if (!wrapperHTML) {
                    alert("PDF 생성 실패: 출력할 wrapper 요소가 없습니다.");
                    $('#lab_loading').hide();
                    return;
                }

                // 기존 스타일/레이아웃 절대 수정하지 않음
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
                formData.append("docType", "RESULT");
                formData.append("userId", "${userId}");
                formData.append("title", "${newProductResultData.data.TITLE}_메뉴품질점검결과보고서");

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
                        a.download = "${newProductResultData.data.TITLE}_메뉴품질점검결과보고서.pdf";
                        a.click();
                        window.URL.revokeObjectURL(url);
                        $('#lab_loading').hide();
                    });
            });
        });
}
function renderDynamicColGroup() {
    const colgroup = document.getElementById("dynamicColGroup");
    colgroup.innerHTML = ""; // 초기화

    if (!_columnStateCodes || _columnStateCodes.length === 0) return;

    const colWidth = (100 / _columnStateCodes.length).toFixed(2) + "%";

    _columnStateCodes.forEach(() => {
        const col = document.createElement("col");
        col.style.width = colWidth;
        colgroup.appendChild(col);
    });
}

function fn_openPreview(idx) {
	var url = "/preview/newProductViewPopup?idx="+idx;

	// 팝업 창 열기
	var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes");
}
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">
		메뉴 품질 점검 결과 보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Menu Quality Test Report</span><span class="title">메뉴 품질 점검 결과 보고서</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<c:if test="${newProductResultData.data.STATUS == 'REG' }">
							<button class="btn_small_search ml5" onclick="apprClass.openApprovalDialog()" style="float: left">결재</button>
						</c:if>
					</li>
				</ul>
			</div>
		</h2>
		
		<div class="group01 mt20">
			<div class="title2"  style="display: flex; justify-content:space-between; width: 100%;">
				<span class="txt">기본정보</span>
				<div class="pr15">
					<button class="btn_small_search ml5" onclick="fn_openPreview('${newProductResultData.data.RESULT_IDX}')">미리보기</button>
					<c:if test="${newProductResultData.data.STATUS eq 'COMP' && newProductResultData.data.DOC_OWNER eq userId && fn:length(newProductResultData.data.COLUMN_STATE) > 0}">
						<button class="btn_small_search" onclick="fn_pdfDownload('${newProductResultData.data.RESULT_IDX}')">PDF 다운로드</button>
					</c:if>
				</div>
			</div>
			<div class="main_tbl">
				<table class="insert_proc01">
					<colgroup>
						<col width="20%" />
						<col width="80%" />
					</colgroup>
					<tbody>
						<tr>
						    <th style="border-left: none;">제목</th>
						    <td>${newProductResultData.data.TITLE}</td>
						</tr>
						<c:if test="${userUtil:getUserId(pageContext.request) == newProductResultData.data.DOC_OWNER }">
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
						    <th style="border-left: none;">시행월</th>
						    <td>${newProductResultData.data.EXCUTE_DATE}</td>
						</tr>		
					</tbody>
				</table>
			</div>
		</div>
		
		<div id="dynamicTableSection" class="group01 mt20">
			<div class="title2"  style="width: 80%;"><span class="txt">내용</span></div>
			<div class="title2" style="width: 20%; display: inline-block;">
				
			</div>
			<div class="main_tbl">
				<table class="insert_proc01">
					<colgroup id="dynamicColGroup">
					</colgroup>
				    <thead>
				        <tr id="dynamicHeaderRow">
							
				        </tr>
				    </thead>
				    <tbody id="dynamicBody">
				        
				    </tbody>
				</table>
			</div>
		</div>
		
		<div class="group01 mt20">
			<div class="title2"  style="width:90%;"><span class="txt">첨부파일</span></div>
			<div class="list_detail">
				<ul style="">
					<li>
						<dt style="width: 20%">첨부파일</dt>
						<dd style="width: 80%;">
							<div class="add_file" id="add_file2" style="width:100%">
								
							</div>
							<div id="fileList" class="file_box_pop" style="height: 120px; width: 100%; border-top-left-radius: 0px; border-top-right-radius: 0px; border-top: 1px solid rgb(221, 221, 221); box-sizing: border-box;">
								<ul id="attatch_file">
									<c:forEach items="${newProductResultData.fileList}" var="fileList" varStatus="status">
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
					<li class="point_img">
						<dt>첨부파일</dt><dd>
							<ul>
		                        <c:forEach items="${newProductResultData.fileList}" var="file" varStatus="status">
		                            <li>&nbsp;<a href="javascript:downloadFile('${file.FILE_IDX}')">${file.ORG_FILE_NAME}</a></li>
		                        </c:forEach>
							</ul>
						</dd>
					</li>
				</ul>
			</div> --%>
		</div>

			<div class="main_tbl">
				<div class="btn_box_con5">
					
				</div>
				<div class="btn_box_con4">
					<c:if test="${userUtil:getUserId(pageContext.request) == newProductResultData.data.DOC_OWNER }">
						<c:if test="${newProductResultData.data.STATUS == 'COND_APPR' or newProductResultData.data.STATUS == 'TMP'}">
							<button class="btn_admin_sky" onclick="fn_update('${newProductResultData.data.RESULT_IDX}')">수정</button>
						</c:if>
					</c:if>
					<button class="btn_admin_gray" onClick="fn_list();" style="width: 120px; margin-right: 20px;">목록</button>
				</div>
				<hr class="con_mode" />
			</div>
	</section>
</div>

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