<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<title>메뉴완료보고서</title>
<script type="text/javascript">
	$(document).ready(function(){
		fn_loadList(1);
	});
	
	function fn_loadList(pageNo) {
		var URL = "../manual/selectManualListAjax";
		var viewCount = $("#viewCount").selectedValues()[0];
		if( viewCount == '' ) {
			viewCount = "10";
		}
		$("#list").html("<tr><td align='center' colspan='7'>조회중입니다.</td></tr>");
		$('.page_navi').html("");
		
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"searchType" : $("#searchType").selectedValues()[0]
				, "searchValue" : $("#searchValue").val()
				, "searchCategory1" : $("#searchCategory1").selectedValues()[0]
				, "searchCategory2" : $("#searchCategory2").selectedValues()[0]
				, "searchCategory3" : $("#searchCategory3").selectedValues()[0]
				, "searchFileTxt" : $("#searchFileTxt").val()
				, "viewCount":viewCount
				, "pageNo":pageNo
			},
			dataType:"json",
			success:function(data) {
				var html = "";
				if( data.totalCount > 0 ) {
					$("#list").html(html);
					data.list.forEach(function (item) {
						if( item.IS_LAST == 'Y' ) {
							html += "<tr id=\"manual_"+item.DOC_NO+"_"+item.VERSION_NO+"\">";	
						} else {
							html += "<tr id=\"manual_"+item.DOC_NO+"_"+item.VERSION_NO+"\" class=\"m_version\" style=\"display: none\">";
						}
						
						html += "	<td>";
						if( item.CHILD_CNT > 0 && item.IS_LAST == 'Y' ) {
							html += "		<img src=\"/resources/images/img_add_doc.png\" style=\"cursor: pointer;\" onclick=\"showChildVersion(this)\"/>";
						} else {
							html += "&nbsp;";
						}
						html += "	</td>";
						
						html += "	<td>"+nvl(item.MENU_CODE,'&nbsp;')+"</td>";
						html += "	<td><div class=\"\"><a href=\"#\" onClick=\"fn_viewFile('"+item.MANUAL_IDX+"')\">"+nvl(item.NAME,'&nbsp;')+"</a></div></td>";
						html += "	<td>"+nvl(item.VERSION_NO,'&nbsp;')+"</td>";
						html += "	<td><div class=\"ellipsis_txt tgnl\">";
						if( chkNull(item.CATEGORY_NAME1) ) {
							html += item.CATEGORY_NAME1;
						}
						if( chkNull(item.CATEGORY_NAME2) ) { 
							html += " > "+item.CATEGORY_NAME2;
						}
						if( chkNull(item.CATEGORY_NAME3) ) {
							html += " > "+item.CATEGORY_NAME3;
						}
						html += "	</div></td>";
						html += "	<td>"+nvl(item.REG_YN_TXT,'&nbsp;')+"</td>";
						html += "	<td>"+nvl(item.DOC_USER_NAME,'&nbsp;')+"</td>";						
						html += "	<td>";
						if( item.REG_YN == 'N' ) {
							html += "		<li style=\"float:none; display:inline\">";
							html += "			<button class=\"btn_doc\" onclick=\"javascript:fn_attachFileOpen('"+item.MANUAL_IDX+"')\"><img src=\"/resources/images/icon_doc03.png\">매뉴얼등록</button>";
							html += "		</li>";
						} else {
							html += "		<li style=\"float:none; display:inline\">";
							html += "			<button class=\"btn_doc\" onclick=\"javascript:fn_viewFile('"+item.MANUAL_IDX+"')\"><img src=\"/resources/images/icon_doc05.png\">매뉴얼확인</button>";
							html += "		</li>";
						}
						html += "	</td>";
						html += "</tr>"		
					});				
				} else {
					$("#list").html(html);
					html += "<tr><td align='center' colspan='7'>데이터가 없습니다.</td></tr>";
				}			
				$("#list").html(html);
				$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
				$('#pageNo').val(data.navi.pageNo);			
			},
			error:function(request, status, errorThrown){
				var html = "";
				$("#list").html(html);
				html += "<tr><td align='center' colspan='7'>오류가 발생하였습니다.</td></tr>";
				$("#list").html(html);
				$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
				$('#pageNo').val(data.navi.pageNo);
			}			
		});
	}
	
	function showChildVersion(imgElement){
		var docNo = $(imgElement).parent().parent().attr('id').split('_')[1];
		var elementImg = $(imgElement).attr('src').split('/')[$(imgElement).attr('src').split('/').length-1];
		
		var addImg = 'img_add_doc.png';
		
		if(elementImg == addImg){
			$(imgElement).attr('src', $(imgElement).attr('src').replace('_add_', '_m_')); 
			$('tr[id*=manual_'+docNo+']').show();
		} else {
			$(imgElement).attr('src', $(imgElement).attr('src').replace('_m_', '_add_'));
			$('tr[id*=manual_'+docNo+']').toArray().forEach(function(v, i){
				if(i != 0){
					$(v).hide();
				}
			})
		}
	}
	
	function fn_attachFileOpen(idx) {
		$("#menuIdx").val(idx);
		openDialog('dialog_attatch');
	}
	
	function closeDialogWithClean(dialogId){
		initDialog();
		closeDialog(dialogId);
	}
	
	function initDialog(){
		$("#menuIdx").val("");
		attatchFileArr = [];
		attatchTempFileArr = [];
		attatchTempFileTypeArr = [];
		$('ul[name=popFileList]').empty();
		$('#attatch_common_text').val('');
		$('#attatch_common').val('')
	}
	
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
	
	
	function fn_uploadFiles(){
		if( attatchTempFileArr.length == 0 ) {
			alert("파일을 등록해주세요.");
			return;
		}
		
		attatchTempFileArr.forEach(function(tempFile, idx1){
			attatchFileArr.push(tempFile);
			attatchFileTypeArr.push(attatchTempFileTypeArr[idx1]);		
		});
		
		/*
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
		*/
		
		var URL = "../manual/uploadManualAjax";
		var formData = new FormData();
		formData.append('idx', $("#menuIdx").val());
		for (var i = 0; i < attatchFileArr.length; i++) {
			formData.append('file', attatchFileArr[i]);
		}
		$('#lab_loading').show();
		$.ajax({
			url: URL,
			type: 'post',
			dataType: 'json',
			data: formData,
			processData: false,
	        contentType: false,
	        cache: false,
			success: function(result){
				if( result.RESULT == 'S' ) {
					alert("조리매뉴얼 등록이 완료되었습니다.");
					$('#lab_loading').hide();
					fn_loadList(1);
				} else {
					alert("오류가 발생하였습니다.\n"+result.MESSAGE);
					$('#lab_loading').hide();
				}
			},
			error: function(a,b,c){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
				$('#lab_loading').hide();
			}
		});
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
	
	function fn_viewFile(idx) {
		var URL = "../manual/selectManualFileListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"idx" : idx
				, "docType" : 'MANUAL'
			},
			dataType:"json",
			success:function(data) {
				var html = "";
				if( data.length > 0 ) {
					$("#fileDataList").html("");
					data.forEach(function (item) {
						var childTag = '<li>&nbsp;<a href="javascript:downloadFile(\''+item.FILE_IDX+'\')">'+item.ORG_FILE_NAME+'</a></li>'
						$("#fileDataList").append(childTag);
					});				
				} else {
					$("#fileDataList").html("");
				}			
			},
			error:function(request, status, errorThrown){
				$("#fileDataList").html("");
			}			
		});
		openDialog('open3');
	}
	
	function downloadFile(idx){
		location.href = '/common/fileDownload?idx='+idx;
	}
	

</script>

<input type="hidden" name="pageNo" id="pageNo" value="${paramVO.pageNo}">
<div class="wrap_in" id="fixNextTag">
	<span class="path">매뉴얼&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Manual List</span>
			<span class="title">매뉴얼</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<!-- <button type="button" class="btn_circle_red" onClick="javascript:fn_insertForm();">&nbsp;</button>-->
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="tab02">
				<!--  ul>
					<a href="/material/list"><li class="select">자재관리</li></a>
					<a href="/material/changeList"><li class="">변경관리</li></a>
				</ul-->
			</div>
			<div class="search_box" >
				<ul style="border-top:none">
					<li>
						<dt>키워드</dt>
						<dd >
							<!-- 초기값은 보통으로 -->
							<div class="selectbox" style="width:100px;">  
								<label for="searchType" id="searchType_label">선택</label> 
								<select name="searchType" id="searchType">
									<option value="">선택</option>
									<option value="searchName">제품명</option>
									<option value="searchProductCode">제품코드</option>
								</select>
							</div>
							<input type="text" name="searchValue" id="searchValue" value="" style="width:180px; margin-left:5px;">
						</dd>
					</li>
					<li>
						<dt>제품구분</dt>
						<dd >
							<div class="selectbox" style="width:100px;" id="searchCategory1_div">  
								<label for="searchCategory1" id="searchCategory1_label">선택</label> 
								<select name="searchCategory1" id="searchCategory1" onChange="fn_changeCategory(this,2)">
								</select>
							</div>
							<div class="selectbox lm5" style="width:100px; margin-left:5px; display:none;" id="searchCategory2_div">  
								<label for="searchCategory2" id="searchCategory2_label">선택</label> 
								<select name="searchCategory2" id="searchCategory2" onChange="fn_changeCategory(this,3)">
								</select>
							</div>
							<div class="selectbox lm5" style="width:100px; margin-left:5px; display:none;" id="searchCategory3_div">  
								<label for="searchCategory3" id="searchCategory3_label">선택</label> 
								<select name="searchCategory3" id="searchCategory3">
								</select>
							</div>
						</dd>
					</li>
					<li>
						<dt>첨부 내용</dt>
						<dd >
							<input type="text" name="searchFileTxt" id="searchFileTxt" value="" style="width:180px;">
						</dd>
					</li>
					<li>
						<dt>표시수</dt>
						<dd >
							<div class="selectbox" style="width:100px;">  
								<label for="viewCount" id="viewCount_label">선택</label> 
								<select name="viewCount" id="viewCount">		
									<option value="">선택</option>													
									<option value="10">10</option>
									<option value="20">20</option>
									<option value="50">50</option>
									<option value="100">100</option>
								</select>
							</div>
						</dd>
					</li>
				</ul>
				<div class="fr pt5 pb10">
					<button type="button" class="btn_con_search" onClick="javascript:fn_search();"><img src="/resources/images/btn_icon_search.png" style="vertical-align:middle;"/> 검색</button>
					<button type="button" class="btn_con_search" onClick="javascript:fn_searchClear();"><img src="/resources/images/btn_icon_refresh.png" style="vertical-align:middle;"/> 검색 초기화</button>					
				</div>
			</div>
			<div class="main_tbl">
				<table class="tbl01">
					<colgroup id="list_colgroup">
						<col width="45px">
						<col width="10%">
						<col width="20%">
						<col width="8%">
						<col width="20%">
						<col width="15%">
						<col width="8%">						
						<col width="15%">						
					</colgroup>
					<thead id="list_header">
						<tr>
							<th>&nbsp;</th>
							<th>메뉴코드</th>
							<th>메뉴명</th>
							<th>버젼</th>
							<th>메뉴구분</th>
							<th>매뉴얼등록상태</th>
							<th>담당자</th>
							<th></th>
						<tr>
					</thead>
					<tbody id="list">						
					</tbody>
				</table>
				<div class="page_navi  mt10">
				</div>
			</div>
			<div class="btn_box_con"> 
				<!--  <button class="btn_admin_red" onclick="javascript:fn_insertForm();">완료보고서 생성</button> -->
			</div>
	 		<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
	</section>
</div>

<!-- 첨부파일 추가레이어 start-->
<!-- 신규로 레이어창을 생성하고싶을때는  아이디값 교체-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="dialog_attatch">
	<input type="hidden" name="menuIdx" id="menuIdx">
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
								<input id="attatch_common_text" class="form-control form_point_color01" type="text" placeholder="파일을 선택해주세요." style="width:308px;float:left; cursor: pointer; color: black;" onclick="callAddFileEvent()" readonly="readonly">
								<!-- <label class="btn-default" for="attatch_common" style="float:left; margin-left: 5px; width: 57px">파일 선택</label> -->
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
			<button class="btn_admin_red" onclick="fn_uploadFiles();">파일 등록</button>
			<button class="btn_admin_gray" onClick="closeDialogWithClean('dialog_attatch')">등록 취소</button>
		</div>
	</div>
</div>
<!-- 파일 생성레이어 close-->

<!-- 자재 조회레이어 start-->
<div class="white_content" id="open3">
	<div class="modal" style="	width: 550px;margin-left:-350px;height: 350px;margin-top:-200px;">
		<h5 style="position:relative">
			<span class="title">매뉴얼 상세 정보</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('open3')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li>
					<div class="add_file2" style="width:97.5%">
						<span class="" >
							<label>매뉴얼</label>
						</span>						
					</div>
					<div class="file_box_pop" style=" height:120px; width:97.5%; border-top-left-radius:0px;border-top-right-radius:0px; border-top:1px solid #ddd;box-sizing:border-box;">
						<ul id="fileDataList">									
						</ul>
					</div>
				</li>
			</ul>
		</div>
		<div class="btn_box_con">
			<button class="btn_admin_gray" onclick="closeDialog('open3')"> 닫기</button>
		</div>
	</div>
</div>
<!-- 자재 생성레이어 close-->

<!-- 이력내역 레이어 start-->
<div class="white_content" id="dialog_history">
	<div class="modal"
		style="margin-left: -300px; width: 500px; height: 420px; margin-top: -210px">
		<h5 style="position: relative">
			<span class="title">문서이력</span>
			<div class="top_btn_box">
				<ul>
					<li><button class="btn_madal_close" onClick="closeDialog('dialog_history')"></button></li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul id="historyDiv" class="pop_notice_con history_option">
			</ul>
		</div>
		<div class="btn_box_con4" style="padding: 15px 0 20px 0">
			<button class="btn_admin_red" onclick="closeDialog('dialog_history')">확인</button>
		</div>
	</div>
</div>
<!-- 이력내역 레이어 생성레이어 close-->
