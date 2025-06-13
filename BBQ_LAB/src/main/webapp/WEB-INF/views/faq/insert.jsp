<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>

<title>FAQ 등록</title>
<style>
.ck-editor__editable_inline {
   min-height: 400px; /* ✅ 원하는 높이로 조절 */
}
</style>
<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<link href="../resources/css/common.css" rel="stylesheet" type="text/css" />
<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../resources/js/jstree.js"></script>
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
<script type="text/javascript">

let _faqCategoryFullList = []; // 전체 FAQ 카테고리 저장용 전역변수

$(document).ready(function () {
	CreateEditor('answer');
	loadCode('FAQ_CATEGORY', 'faqCategory');
});

function loadCode(codeId,selectBoxId) {
	var URL = "../common/codeListAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{ groupCode : codeId
		},
		dataType:"json",
		async:false,
		success:function(data) {
			var list = data.RESULT;
			$("#"+selectBoxId).removeOption(/./);
			$("#"+selectBoxId).addOption("", "--선택--", false);
			$.each(list, function( index, value ){ //배열-> index, value
				$("#"+selectBoxId).addOption(value.itemCode, value.itemName, false);
			});
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}			
	});
}

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

function closeDialogWithClean(dialogId){
	initDialog();
	closeDialog(dialogId);
}


function fn_insert() {
    // 질문 유형
    const category = $("#faqCategory").val();
    if (!category) {
        alert("질문 유형을 선택하십시오.");
        $("#faqCategory").focus();
        return;
    }

    // 질문 내용
    const question = $("#title").val().trim();
    if (!question) {
        alert("질문 내용을 입력하십시오.");
        $("#title").focus();
        return;
    }

    // 답변 내용 (CKEditor)
    const answer = window.editor.getData();
    if (!answer || answer.trim() === "") {
        alert("답변 내용을 입력하십시오.");
        return;
    }

    // ✅ FormData 구성
    const formData = new FormData();
    formData.append("category", category);
    formData.append("question", question);
    formData.append("answer", answer);
	
    $('#lab_loading').show();
    // ✅ AJAX 전송
    $.ajax({
        url: "/faq/insertFaqAjax",
        type: "POST",
        data: formData,
        processData: false,
        contentType: false,
        success: function (res) {
            if (res.success) {
                alert("FAQ가 성공적으로 등록되었습니다.");
                $('#lab_loading').hide();
                fn_goList();
            } else {
                alert("등록 실패: " + (res.message || "알 수 없는 오류"));
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
    location.href = "/faq/list";
}

</script>

<div class="wrap_in" id="fixNextTag">
    <span class="path">FAQ &nbsp;&nbsp;
        <img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;게시판&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;<a href="#none">${strUtil:getSystemName()}</a>
    </span>

    <section class="type01">
        <h2 style="position:relative">
            <span class="title_s">Frequently Asked Questions</span>
            <span class="title">FAQ 등록</span>
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
				<div class="title2"  style="width: 80%;"><span class="txt">자주 묻는 질문</span></div>
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
								<th>질문 유형</th>
								<td colspan="3">
								<div class="selectbox" style="width:160px; border: 1px #d45656 solid;">  
									<label for="faqCategory" id="faqCategory_label">--선택--</label> 
									<select class="req" name=""faqCategory id="faqCategory">
										<option value="">선택</option>
									</select>
								</div>
								</td>
							</tr>
							<tr>
								<th>질문 내용</th>
								<td colspan="3">
									<input type="text" name="title" id="title" style="width: 99%; font-weight: bold;" class="req" />
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="title2 mt20"  style="width: 80%;"><span class="txt">질문에 대한 답변</span></div>
				<div class="title2" style="width: 20%; display: inline-block;">
				</div>
				<div class="main_tbl">
					<ul>
						<li class="" style="list-style: none;">
							<div class="text_insert" style="padding: 0px;">
								<textarea name="answer" id="answer" style="width: 666px; height: 500px; display: none;">
								</textarea>
							</div>
						</li>
					</ul>
				</div>
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