<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>

<title>공지사항 등록</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { min-height:400px;} 

/* 회색 테두리 유지 (비활성 상태일 때) */
.insert_proc01 input.gray-border {
  border-bottom: 1px solid #e8e8e8 !important;
}
.insert_proc01 input.red-border {
  border-bottom: 1px solid #d45656 !important;
}
.insert_proc01 input.gray-border:hover,
.insert_proc01 input.gray-border:focus {
  border-bottom: 1px solid #e8e8e8 !important;
  background-color: inherit !important;
  box-shadow: none !important;
  outline: none !important;
}
</style>
<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<link href="../resources/css/common.css" rel="stylesheet" type="text/css" />
<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../resources/js/jstree.js"></script>
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript">
$(document).ready(function () {
	CreateEditor("contents");
	// 요청일자
	
	var datepickers = ["#postStartDate", "#postEndDate", "#popStartDate", "#popEndDate"]
    datepickers.forEach(selector => {
        $(selector).datepicker({
            showOn: "both",
            buttonImage: "/resources/images/btn_calendar.png",
            buttonImageOnly: true,
            buttonText: "Select date",
            dateFormat: "yy-mm-dd",
            showButtonPanel: true,
            changeMonth: true,
            changeYear: true,
            yearRange: "2000:2099"
        }).datepicker("disable")          // ❌ 기본은 disable
          .addClass("gray-border");       // ✅ 회색 테두리 적용
    });
	
    $('.ui-datepicker-trigger').css({
        'margin-left': '8px',
        'margin-top': '-5px'
    });
	
});

function CreateEditor(editorId) {
    ClassicEditor
        .create(document.getElementById(editorId), {
			language: 'ko',
        }).then( editor => {
        	window.editor = editor;
    	}).catch( error => {
    		console.error( error );
    	});
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
    if($.inArray(ext, ['exe','msi','bat','js','java']) != -1) {
    	var message = "";
    	message += ext+'파일은 업로드 할 수 없습니다.';
    	//message += "\n";
    	//message += "(pdf 만 가능합니다.)";
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

function handleNoticeTypeChange() {
    const isImportant = document.getElementById("type_important").checked;
    toggleDateFieldByRadio(isImportant, $("#postStartDate"), $("#postEndDate"));
}

function handlePopupToggle() {
    const isPopup = document.getElementById("popup_y").checked;
    toggleDateFieldByRadio(isPopup, $("#popStartDate"), $("#popEndDate"));
}

function toggleDateFieldByRadio(isChecked, $startInput, $endInput) {
    // 스타일 초기화
    $startInput.removeClass("gray-border red-border");
    $endInput.removeClass("gray-border red-border");

    // 달력 아이콘 요소 선택
    const $startIcon = $startInput.next(".ui-datepicker-trigger");
    const $endIcon = $endInput.next(".ui-datepicker-trigger");

    if (isChecked) {
        $startInput.addClass("red-border").datepicker("enable");
        $endInput.addClass("red-border").datepicker("enable");

        $startIcon.css("cursor", "pointer");
        $endIcon.css("cursor", "pointer");
    } else {
    	$startInput.addClass("gray-border").datepicker("disable").val(""); // 값 초기화
        $endInput.addClass("gray-border").datepicker("disable").val("");   // 값 초기화

        $startIcon.css("cursor", "default");
        $endIcon.css("cursor", "default");
    }
}


function fn_insert() {
    // 제목
    const title = $("#title").val().trim();
    if (!title) {
        alert("제목을 입력해주세요.");
        $("#title").focus();
        return;
    }

    // 유형
    const type = $("input[name='typeSelect']:checked").val();
    if (!type) {
        alert("유형을 선택해주세요.");
        return;
    }

    // 게시 기간
    const postStartDate = $("#postStartDate").val();
    const postEndDate = $("#postEndDate").val();
    if (type === "I" && (!postStartDate || !postEndDate)) {
        alert("공지 유형은 게시 기간을 입력해야 합니다.");
        return;
    }

    // 팝업 노출 여부
    const isPopup = $("input[name='isPopUpSelect']:checked").val();
    const popStartDate = $("#popStartDate").val();
    const popEndDate = $("#popEndDate").val();
    if (isPopup === "Y" && (!popStartDate || !popEndDate)) {
        alert("팝업 사용 시 팝업 노출 기간을 입력해주세요.");
        return;
    }

    // 내용 (CKEditor)
    const contents = window.editor.getData();
    if (!contents || contents.trim() === "") {
        alert("내용을 입력해주세요.");
        return;
    }

    // 첨부파일 (FormData에 포함)
    const formData = new FormData();
    formData.append("title", title);
    formData.append("type", type);
    formData.append("postStartDate", postStartDate);
    formData.append("postEndDate", postEndDate);
    formData.append("isPopup", isPopup || "N");
    formData.append("popStartDate", popStartDate);
    formData.append("popEndDate", popEndDate);
    formData.append("contents", contents);

    console.log(attatchFileArr);
    
    // 첨부파일들 추가
	for (var i = 0; i < attatchFileArr.length; i++) {
		formData.append('file', attatchFileArr[i])
	}

    
    // 전송
    /*
    */
    $('#lab_loading').show();
    $.ajax({
        url: "/notice/insertNoticeAjax",
        type: "POST",
        data: formData,
        processData: false,
        contentType: false,
        success: function (res) {
            if (res.success) {
                alert("공지사항이 등록되었습니다.");
                $('#lab_loading').hide();
                fn_goList();
            } else {
                alert("등록 중 오류가 발생했습니다: " + res.message);
                $('#lab_loading').hide();
            }
        },
        error: function (xhr, status, error) {
            console.error(error);
            alert("서버 오류가 발생했습니다.");
            $('#lab_loading').hide();
        }
    });
}

function fn_goList() {
    location.href = "/notice/list";
}

</script>

<div class="wrap_in" id="fixNextTag">
    <span class="path">공지사항 &nbsp;&nbsp;
        <img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;게시판&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
    </span>

    <section class="type01">
        <h2 style="position:relative">
            <span class="title_s">Notice</span>
            <span class="title">공지사항 등록</span>
            <div class="top_btn_box">
                <ul>
					<li>
						<!-- 
						<button class="btn_circle_modifiy" onclick="fn_copySearch()">&nbsp;</button>
						 -->
						<button class="btn_circle_save" onclick="fn_insert()">&nbsp;</button>
					</li>
                </ul>
            </div>
        </h2>

        <div class="group01 mt20">
    		<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
        	<div id="tab1_div">
				<div class="title2"  style="width: 80%;"><span class="txt">기본정보</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">						
				</div>
				<div class="main_tbl">
					<table class="insert_proc01">
						<colgroup>
							<col  width="20%" />							
							<col  width="20%" />							
							<col  width="20%" />							
							<col  width="40%" />							
						</colgroup>
						<tbody>
							<tr>
								<th>제목</th>
								<td colspan="3">
									<input type="text" name="title" id="title" style="width: 99%;" class="req" />
								</td>
							</tr>
							<tr>
								<th>유형</th>
								<td>
									<div class="search_box" style="display: flex; gap: 20px; justify-content: Left;">
									    <input type="radio" id="type_important" name="typeSelect" value="I" onchange="handleNoticeTypeChange()">
									    <label for="type_important" style="color:red;"><span></span>[공지]</label>
									
									    <input type="radio" id="type_normal" name="typeSelect" value="N" onchange="handleNoticeTypeChange()">
									    <label for="type_normal"><span></span>[일반]</label>
									</div>
								</td>
								<th>게시 기간</th>
								<td>
									<input type="text" id="postStartDate" class="" placeholder="" readonly style="width: 150px;"> ~ <input type="text" id="postEndDate" class="" placeholder="" readonly style="width: 150px;">
								</td>
							</tr>
							<tr>
								<th>팝업 노출</th>
								<td>
									<div class="search_box" style="display: flex; gap: 20px; justify-content: Left;">
									    <input type="radio" id="popup_y" name="isPopUpSelect" value="Y" onchange="handlePopupToggle()">
									    <label for="popup_y" ><span></span>사용</label>
									
									    <input type="radio" id="type_n" name="isPopUpSelect" value="N" onchange="handlePopupToggle()">
									    <label for="type_n"><span></span>미사용</label>
									</div>
								</td>
								<th>팝업 노출 기간</th>
								<td>
									<input type="text" id="popStartDate" class="" placeholder="" readonly style="width: 150px;"> ~ <input type="text" id="popEndDate" class="" placeholder="" readonly style="width: 150px;">
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="title2 mt20"  style="width: 80%;"><span class="txt">내용</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">
				</div>
				<div class="main_tbl">
					<ul>
						<li class="" style="list-style: none;">
							<div class="text_insert" style="padding: 0px;">
								<textarea name="contents" id="contents" style="width: 666px; height: 120px; display: none;">
								</textarea>
								<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
							</div>
						</li>
					</ul>
				</div>
       		</div>
       		
       		<div class="title2 mt20"  style="width:90%;"><span class="txt">파일첨부</span></div>
			<div class="title2 mt20" style="width:10%; display: inline-block;">
				<button class="btn_con_search" onClick="openDialog('dialog_attatch')">
					<img src="/resources/images/icon_s_file.png" />파일첨부 
				</button>
			</div>
			<div class="con_file" style="">
				<ul>
					<li class="point_img">
						<dt>첨부파일</dt><dd>
							<ul id="attatch_file">
							</ul>
						</dd>
					</li>
				</ul>
			</div>
				<div class="btn_box_con5 mt20">
					<button class="btn_admin_gray" onClick="fn_goList();" style="width: 120px;">목록</button>
				</div>
				<div class="btn_box_con4 mt20">
					<!-- 
					<button class="btn_admin_red">임시/템플릿저장</button>
					<button class="btn_admin_navi">임시저장</button>
					 <button class="btn_admin_navi" onclick="fn_insertTmp()">임시저장</button>
					 -->
					<button class="btn_admin_sky" onclick="fn_insert()">저장</button>
					<button class="btn_admin_gray" onclick="fn_goList()">취소</button>
				</div>
				<hr class="con_mode" />
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
