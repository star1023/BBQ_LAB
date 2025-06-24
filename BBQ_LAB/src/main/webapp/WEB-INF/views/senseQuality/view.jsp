<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<% 
	int rowLimit = 3;
%>
<title>상품설계변경 보고서 조회</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 400px; min-height:400px;}


<style type="text/css">
.readOnly {
	background-color: #ddd
}
.positionCenter{
	position: absolute;
	transform: translate(-50%, -50%);
}

table{font-size: 12px}
.intable_title{ border:0; table-layout:fixed;}
.intable_title td{border:1px solid #666; text-align:center; height:22px;}

.intable{ border:0; table-layout:fixed; }
.intable td{border:1px solid #666; text-align:center; height:22px;word-break: break-all;}
.intable th{ }
.intable tfoot td{ background-color:#f2f2f2; border-bottom:none;}
.intable tfoot th{ background-color:#f2f2f2; border-bottom:none;}
.lineall{ border:2px solid #000}
.big_font{ font-size:20px;}
.hftitle{background-color:#f3f3f3;}
.inputText{
    width: 70%;
    height: 25px;
    border: none;
}

/* 제조순서 번호 css */
.imgbox {
    position: relative;
    text-align:left;
  }
.imgNumbox{position: absolute; width:21.5px; height:18px; border: 0.5px solid #000; top:-21px; left:-0.5px; text-align:center; background-color: #fff;}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
	$(document).ready(function(){
		fn.autoComplete($("#keyword"));
	});
	
	/* 파일첨부 관련 함수 START */
	var attatchFileArr = [];
	var attatchFileTypeArr = [];
	var attatchTempFileArr = [];
	var attatchTempFileTypeArr = [];
	function callAddFileEvent(){
		$('#attatch_common').click();
	}
	function setFileName(element){
		if(element.files.length > 0)
			$(element).parent().children('input[type=text]').val(element.files[0].name);
		else 
			$(element).parent().children('input[type=text]').val('');
	}
	function addFile(element, fileType){
		var randomId = Math.random().toString(36).substr(2, 9);
		
		if($('#attatch_common').val() == null || $('#attatch_common').val() == ''){
			return alert('파일을 선택해주세요');
		}
		
		fileElement = document.getElementById('attatch_common');
		
		var file = fileElement.files;
		var fileName = file[0].name
		var fileTypeText = $(element).text();
		var isDuple = false;
		attatchTempFileArr.forEach(function(file){
			if(file.name == fileName)
				isDuple = true;
		})
		
		attatchFileArr.forEach(function(file){
			if(file.name == fileName)
				isDuple = true;
		})
		
		if(isDuple){
			if(!confirm('같은 이름의 파일이 존재합니다. 계속 진행하시겠습니까?')){
				return;
			};
		}
		
		if( !checkFileName(fileName) ) {			
			return;
		}
		
		
		
		attatchTempFileArr.push(file[0]);
		attatchTempFileArr[attatchTempFileArr.length-1].tempId = randomId;
		attatchTempFileTypeArr.push({fileType: fileType, fileTypeText: fileTypeText, tempId: randomId});
		
		var childTag = '<li><a href="#none" onclick="removeFile(this, \''+randomId+'\')"><img src="/resources/images/icon_del_file.png"></a>&nbsp;'+fileName+'</li>'
		$('ul[name=popFileList]').append(childTag);
		$('#attatch_common').val('');
		$('#attatch_common').change();
	}
	
	function removeFile(element, tempId){
		$(element).parent().remove();
		attatchFileArr = attatchFileArr.filter(function(file){
			if(file.tempId != tempId) {
				return file;
			}
		})
		attatchFileTypeArr = attatchFileTypeArr.filter(function(typeObj){
			if(typeObj.tempId != tempId) 
				return typeObj;
		});
		
		if( $("#attatch_file").children().length == 0 ) {
			$("#docTypeTemp").removeOption(/./);
			$("#docTypeTxt").html("");
		}
		//console.log($("#attatch_file").children().length);
	}
	
	
	function uploadFiles(){
		if( attatchTempFileArr.length == 0 ) {
			alert("파일을 등록해주세요.");
			return;
		}
		
		attatchTempFileArr.forEach(function(tempFile, idx1){
			attatchFileArr.push(tempFile);
			attatchFileTypeArr.push(attatchTempFileTypeArr[idx1]);		
		});
		
		$("#attatch_file").html("");
		attatchFileTypeArr.forEach(function(object,idx){
			var tempId = object.tempId;
			var childTag = '<li><a href="#none" onclick="removeFile(this, \''+tempId+'\')"><img src="/resources/images/icon_del_file.png"></a>'+attatchFileArr[idx].name+'</li>'
			$("#attatch_file").append(childTag);
		});
		
		$("#docTypeTemp").removeOption(/./);
		var docTypeTxt = "";
		$('input:checkbox[name=docType]').each(function (index) {
			if($(this).is(":checked")==true){
		    	$("#docTypeTemp").addOption($(this).val(), $(this).next("label").text(), true);
		    	//if( index != 0 ) {
	    		if( docTypeTxt != "" ){
	    			docTypeTxt += ", ";
	    		}
	    		docTypeTxt += $(this).next("label").text();
		    	//} else {
		    	//	docTypeTxt += $(this).next("label").text();
		    	//}
		    }
		});
		$("#docTypeTxt").html(docTypeTxt);
		closeDialogWithClean('dialog_attatch');
	}
	
	function checkFileName(str){
		var result = true;
	    //1. 확장자 체크
	    var ext =  str.split('.').pop().toLowerCase();
	    if($.inArray(ext, ['pdf']) == -1) {
	    	var message = "";
	    	message += ext+'파일은 업로드 할 수 없습니다.';
	    	//message += "\n";
	    	message += "(pdf 만 가능합니다.)";
	        alert(message);
	        result = false;
	    }
	    return result;
	}
	
	function closeDialogWithClean(dialogId){
		initDialog();
		closeDialog(dialogId);
	}
	
	function initDialog(){
		// 파일첨부
		attatchTempFileArr = [];
		attatchTempFileTypeArr = [];
		$('ul[name=popFileList]').empty();
		$('#attatch_common_text').val('');
		$('#attatch_common').val('')
	}
	
	function fn_update(idx) {
		location.href = '/senseQuality/update?idx='+idx;
	}

	function fn_goList() {
		location.href = '/senseQuality/list';
	}
	
	
	function fn_apprSubmit(){
		if( $("#apprLine option").length == 0 ) {
			alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 결재상신 해 주세요.");
			return;
		} else {
			$('#lab_loading').show();
			var formData = new FormData();
			formData.append("docIdx",'${senseQualityData.reportMap.REPORT_IDX}');
			formData.append("apprComment", $("#apprComment").val());
			formData.append("apprLine", $("#apprLine").selectedValues());
			formData.append("refLine", $("#refLine").selectedValues());
			formData.append("title", '${senseQualityData.reportMap.TITLE}');
			formData.append("docType", $("#docType").val());
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
						alert("결재상신 되었습니다.");
						$('#lab_loading').hide();
						fn_goList();
					} else {
						alert("결재상신 오류가 발생하였습니다."+data.MESSAGE);
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
	
	function fn_fileDivClick(e){
		e.stopPropagation();
		$(e.target).children('input').click();
	}
	
	function fn_changeImageFile(element, e){
		var reader = new FileReader();
		reader.onload = function (e) {
			$(element).parent().parent().children("p:eq(0)").children().attr("src", e.target.result);
		};
		reader.readAsDataURL(element.files[0]);
	}
	
	function fn_deleteImageFile(element, e){
		$(element).parent().parent().children("p:eq(0)").children().attr("src", '/resources/images/img_noimg3.png');		
		$(element).parent().parent().children("div:eq(0)").children().val('');
	}
	
	function fn_addCol(type) {
		var randomId = randomId = Math.random().toString(36).substr(2, 9);
		var randomId2 = randomId = Math.random().toString(36).substr(2, 9);
		var row= '<tr>'+$('tbody[name='+type+'_tbody_temp]').children('tr').html()+'</tr>';
		
		$("#"+type+"_tbody").append(row);
		$("#"+type+"_tbody").children('tr:last').attr('id', type + '_tr_' + randomId);
		$("#"+type+"_tbody").children('tr:last').children('td').children('input[type=checkbox]').attr('id', type+'_'+randomId);
		$("#"+type+"_tbody").children('tr:last').children('td').children('label').attr('for', type+'_'+randomId);
	}
	
	function fn_delCol(type) {
		var tbody = $("#"+type+"_tbody");
		var checkboxArr = tbody.children('tr').children('td').children('input[type=checkbox]').toArray();
		
		var checkedCnt = 0;
		var checkedId;
		checkboxArr.forEach(function(v, i){
			if($(v).is(':checked')){
				checkedCnt++;
			}
		});
		
		if(checkedCnt == 0) return alert('삭제하실 항목을 선택해주세요');
		
		tbody.children('tr').toArray().forEach(function(v, i){
			var checkBoxId = $(v).children('td:first').children('input[type=checkbox]')[0].id;
			if($('#'+checkBoxId).is(':checked')) $(v).remove();
		})
	}
	
	var contentsDiv = 1;
	function fn_addContents() {
		if( contentsDiv < <%=rowLimit+1%> ) {
			contentsDiv++;
			$("#contents_div_"+contentsDiv).show();
		}
		
	}
	
	function fn_delContents(){
		if( contentsDiv > 1 ) {
			$("#contents_div_"+contentsDiv).hide();
			contentsDiv--;
		}
	}
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">
		상품설계변경 보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;보고서&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
		<h2 style="position:relative">
			<span class="title_s">Sense & Quality Test Report</span><span class="title">관능&품질평가 테스트 결과보고서</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<c:if test="${senseQualityData.reportMap.STATUS == 'REG' }">
						<button class="btn_small_search ml5" onclick="apprClass.openApprovalDialog()" style="float: left">결재</button>
						</c:if>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title2"  style="width: 80%;"><span class="txt">기본정보</span></div>
			<div class="title2" style="width: 20%; display: inline-block;">
				
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
							<th style="border-left: none;">제목</th>
							<td colspan="3">
								${senseQualityData.reportMap.TITLE}
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">업체명</th>
							<td colspan="3">
								${senseQualityData.reportMap.COMPANY_NAME}
							</td>
						</tr>
						<tr>	
							<th style="border-left: none;">제품명</th>
							<td>
								${senseQualityData.reportMap.PRODUCT_NAME}
							</td>
							<th style="border-left: none;">ERP코드</th>
							<td>
								${senseQualityData.reportMap.SAP_CODE}
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">테스트 목적</th>
							<td colspan="3">
								${senseQualityData.reportMap.TEST_PURPOSE}
							</td>
						</tr>
					</tbody>
				</table>
			</div>

			<div class="title2"  style="width: 100%;"><span class="txt">세부내용</span></div>
			<div id="contents_div_1">
				 <table style="width: 100%"  id="table1" class="intable lineall mb5" >
				 	<colgroup>	
			            <col width="10%">
			            <col width="26%">
			            <col width="26%">
			            <col width="26%">
			            <col width="12%">			            
			        </colgroup>
			        <tr>
			        	<td rowspan="2">구분</td>
			        	<td colspan="4" align="center">
			        		${senseQualityData.reportMap.CONTENTS_HEADER}
			        	</td>
			        </tr>
			        <tr id="contents_div_tr_1">
				        <c:set var="startNo" value="0"/>
				        <c:set var="endNo" value="2"/>
				        <c:set var="count" value="0" />
			        	<c:forEach items="${senseQualityData.contentsList}" var="contentsList" varStatus="status">	
			        	<c:if test="${status.index >= startNo && status.index <= endNo}">
			        	<c:set var="count" value="${count + 1}" />
			        	<td>${contentsList.CONTENTS_DIV}</td>
			        	</c:if>			        	
			        	</c:forEach>
			        	<c:if test="${count < 3 }">
			        	<c:forEach var="cnt" begin="1" end="${3-count}">
			        	<td>&nbsp;</td>
			        	</c:forEach>
			        	</c:if>		
			        	<td>비고</td>		        	
			        </tr>
			        <tr>
			        	<td rowspan="2" class="hftitle">사진</td>			        	
			        </tr>
			        <tr>
			        	<c:set var="count" value="0" />
			        	<c:forEach items="${senseQualityData.contentsList}" var="contentsList" varStatus="status">
			        	<c:if test="${status.index >= startNo && status.index <= endNo}">
			        	<c:set var="count" value="${count + 1}" />
			        	<td style="height: 250px">
			        		<p>
								<a href="/images${contentsList.FILE_PATH}/${contentsList.ORG_FILE_NAME}" target="_blank">
									<img id="preview" 
									     src="/images${contentsList.FILE_PATH}/${contentsList.ORG_FILE_NAME}" 
									     style="border:1px solid #e1e1e1; border-radius:5px; width:278px; height:223px; cursor:pointer;">
								</a>
							</p>
			            </td>
			            </c:if>
			        	</c:forEach>
			        	<c:if test="${count < 3 }">
			        	<c:forEach var="cnt" begin="1" end="${3-count}">
			        	<td style="height: 250px">
			        		&nbsp;
			        	</td>
			        	</c:forEach>
			        	</c:if>	
			            <td rowspan="2" class="">
			        		<p style="white-space: pre-line; text-align:left;">${senseQualityData.infoNoteList[0].INFO_TEXT}</p>
			        	</td>
			        </tr>
			        
			        <tr>
			        	<td class="hftitle"> 결과 </td>
			        	<c:set var="count" value="0" />
			      		<c:forEach items="${senseQualityData.contentsList}" var="contentsList" varStatus="status">
			        	<c:if test="${status.index >= startNo && status.index <= endNo}">
			        	<c:set var="count" value="${count + 1}" />
			        	<td>
			        		<p style="white-space: pre-line; text-align:left;">${contentsList.CONTENTS_RESULT}</p>
			        	</td>
			        	</c:if>
			        	</c:forEach>
			        	<c:if test="${count < 3 }">
			        	<c:forEach var="cnt" begin="1" end="${3-count}">
			        	<td>
			        		&nbsp;
			        	</td>
			        	</c:forEach>
			        	</c:if>	
			        </tr>
			      </table> 
			</div>
			<c:forEach var="no" begin="1" end="${senseQualityData.modCount-1}">
			<c:set var="startNo" value="${no*3}"/>
			<c:set var="endNo" value="${no*3+2}"/>
			<div id="contents_div_${no+1}">
				 <table style="width: 100%"  id="table1" class="intable lineall mb5" >
				 	<colgroup>
			            <col width="10%">
			            <col width="26%">
			            <col width="26%">
			            <col width="26%">
			            <col width="12%">			            
			        </colgroup>
			        <tr  id="contents_div_tr_${no+1}">
			        	<td >구분</td>
			        	<c:set var="count" value="0" />
			        	<c:forEach items="${senseQualityData.contentsList}" var="contentsList" varStatus="status">	
			        	<c:if test="${status.index >= startNo && status.index <= endNo}">
			        	<c:set var="count" value="${count + 1}" />
			        	<td>${contentsList.CONTENTS_DIV}</td>
			        	</c:if>
			        	</c:forEach>
			        	<c:if test="${count < 3 }">
			        	<c:forEach var="cnt" begin="1" end="${3-count}">
			        	<td>&nbsp;</td>
			        	</c:forEach>
			        	</c:if>
			        	<td>비고</td>		        	
			        </tr>
			        <tr>
			        	<td class="hftitle">사진</td>
			        	<c:set var="count" value="0" />
			        	<c:forEach items="${senseQualityData.contentsList}" var="contentsList" varStatus="status">
			        	<c:if test="${status.index >= startNo && status.index <= endNo}">
			        	<c:set var="count" value="${count + 1}" />
			        	<td style="height: 250px">
			        		<p><img id="preview" src="/picture${contentsList.FILE_PATH}/${contentsList.ORG_FILE_NAME}" style="border:1px solid #e1e1e1; border-radius:5px; width:278px; height:223px;"></p>
			            </td>
			            </c:if>
			        	</c:forEach>
			        	<c:if test="${count < 3 }">
			        	<c:forEach var="cnt" begin="1" end="${3-count}">
			        	<td style="height: 250px">&nbsp;</td>
			        	</c:forEach>
			        	</c:if>
			            <td rowspan="2" class="">
			        		<p style="white-space: pre-line; text-align:left;">${senseQualityData.infoNoteList[no].INFO_TEXT}</p>
			        	</td>
			        </tr>
			        
			        <tr>
			        	<td class="hftitle"> 결과 </td>
			        	<c:set var="count" value="0" />
			        	<c:forEach items="${senseQualityData.contentsList}" var="contentsList" varStatus="status">
			        	<c:if test="${status.index >= startNo && status.index <= endNo}">
			        	<c:set var="count" value="${count + 1}" />
			        	<td>
			        		<p style="white-space: pre-line; text-align:left;">${contentsList.CONTENTS_RESULT}</p>
			        	</td>
			        	</c:if>
			        	</c:forEach>
			        	<c:if test="${count < 3 }">
			        	<c:forEach var="cnt" begin="1" end="${3-count}">
			        	<td>&nbsp;</td>
			        	</c:forEach>
			        	</c:if>
			        </tr>
			      </table> 
			</div>
			</c:forEach>

			<div class="title2"><span class="txt">결론</span></div>
			<div class="main_tbl">
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
			 	
			<div class="main_tbl">
				<div class="btn_box_con5">
				</div>
				<div class="btn_box_con4">
					<!-- 
					<button class="btn_admin_red">임시/템플릿저장</button>
					<button class="btn_admin_navi">임시저장</button>
					 -->
					<c:if test="${senseQualityData.reportMap.STATUS == 'TMP'}">
					<button class="btn_admin_navi" onclick="fn_update('${senseQualityData.reportMap.REPORT_IDX}')">수정</button>
					</c:if> 
					<button class="btn_admin_gray" onclick="fn_goList()">목록</button>
				</div>
				<hr class="con_mode" />
			</div>
		</div>
	</section>
</div>

<!-- 첨부파일 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_attatch">
	<div class="modal" style="margin-left: -355px; width: 710px; height: 480px; margin-top: -250px">
		<h5 style="position: relative">
			<span class="title">첨부파일 추가</span>
			<div class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialogWithClean('dialog_attatch')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li class="pt10 mb5">
					<dt style="width: 20%">파일 선택</dt>
					<dd style="width: 80%" class="ppp">
						<div style="float: left; display: inline-block;">
							<span class="file_load" id="fileSpan">
								<input id="attatch_common_text" class="form-control form_point_color01" type="text" placeholder="파일을 선택해주세요." style="width:308px; float:left; cursor: pointer; color: black;" onclick="callAddFileEvent()" readonly="readonly">
								<input id="attatch_common" type="file" style="display:none;" onchange="setFileName(this)">
							</span>
							<button class="btn_small02 ml5" onclick="addFile(this, '00')">파일등록</button>
						</div>
						<div style="float: left; display: inline-block; margin-top: 5px">
							
						</div>
					</dd>
				</li>
				<li class=" mb5">
					<dt style="width: 20%">파일리스트</dt>
					<dd style="width: 80%;">
						<div class="file_box_pop" style="width:95%">
							<ul name="popFileList"></ul>
						</div>
					</dd>
				</li>
			</ul>
		</div>
		<div class="btn_box_con">
			<button class="btn_admin_red" onclick="uploadFiles();">파일 등록</button>
			<button class="btn_admin_gray" onClick="closeDialogWithClean('dialog_attatch')">등록 취소</button>
		</div>
	</div>
</div>
<!-- 파일 생성레이어 close-->

<!-- 결재 상신 레이어  start-->
<div class="white_content" id="approval_dialog">
	<input type="hidden" id="docType" value="SENSE_QUALITY"/>
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
			<span class="title">관능&품질평가 테스트 결과보고서 결재 상신</span>
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