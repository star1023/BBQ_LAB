<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>메뉴 품질 점검 결과 보고서 생성</title>
<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<link href="../resources/css/common.css" rel="stylesheet" type="text/css" />
<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
.ck-editor__editable { max-height: 400px; min-height:150px;}
.search_box {
	justify-content: center;
}
.btn_col_arrow {
  border: none;
  background-color: transparent;
  color: #cc0000; /* 진한 붉은색 */
  font-size: 16px;
  cursor: pointer;
  padding: 0 4px;
}
.btn_col_arrow:hover {
  color: #ff4444;
}
</style>

<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<link href="../resources/css/common.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
<script src="/resources/js/jquery.ui.monthpicker.js"></script>
<script type="text/javascript">
	var editor1;
	var editor2;
	let _multiSelectCache = {
		    store: [],
		    product: [],
			column : []
	};
	$(document).ready(function() {
		// ✅ 강제로 최대화 상태로 설정
/* 		stepchage('width_wrap', 'wrap_in02');
		setPersonalization('widthMode', 'wrap_in02'); */
		
	    var startYear = (new Date()).getFullYear();

	    $("#excuteDate").monthpicker({
	        dateFormat: 'yy-mm',
	        showOn: 'button',
	        buttonImage: '../resources/images/btn_calendar.png',
	        buttonImageOnly: true,
	        monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
	        monthNames: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
	        yearRange: (startYear - 2) + ":" + (startYear + 2)
	    });

	    // 버튼 위치 조정
	    $('.ui-monthpicker-trigger').css({
	        'cursor': 'pointer'
	    });
	    
	    // AJAX로 데이터 로드
	    $.ajax({
	        type: "POST",
	        url: "../common/codeListAjax",
	        data: { 'groupCode': 'COLUMN' },
	        dataType: "json",
	        success: function (data) {
	            _multiSelectCache.column = data.RESULT;
	            initFixedColumns(); // ✅ 고정 컬럼 4개 생성

	        },
	        error: function () {
	            alert(" 정보를 불러오는데 실패했습니다.");
	        }
	    });
	    	
    	fn.autoComplete($("#keyword"));
    	$("#dynamicTableSection").hide();  // 업로드 모드일 때 기본 숨김
	});
	
	/* 파일첨부 관련 함수 START */
	var attatchFileArr = [];
	var attatchFileTypeArr = [];
	var attatchTempFileArr = [];
	var attatchTempFileTypeArr = [];
	function callAddFileEvent(){
		//$('#attatch_common').click();
		$('#file3').click();
	}
	function setFileName(element){
		if(element.files.length > 0)
			$(element).parent().children('input[type=text]').val(element.files[0].name);
		else 
			$(element).parent().children('input[type=text]').val('');
	}
	function addFile(element, fileType){
		var randomId = Math.random().toString(36).substr(2, 9);
		
		if($(element).val() == null || $(element).val() == ''){
			return alert('파일을 선택해주세요');
		}
		
		fileElement = document.getElementById($(element).prop("id"));
		
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
		
		attatchFileArr.push(file[0]);
		attatchFileArr[attatchFileArr.length-1].tempId = randomId;
		attatchFileTypeArr.push({fileType: fileType, fileTypeText: fileTypeText, tempId: randomId});
		
		$(element).val("");
		
		var childTag = '<li><a href="#none" onclick="removeFile(this, \''+attatchFileTypeArr[attatchFileTypeArr.length-1].tempId+'\')"><img src="/resources/images/icon_del_file.png"></a>'+attatchFileArr[attatchFileTypeArr.length-1].name+'</li>';
		$("#attatch_file").append(childTag);
	}
	
	function addDropFile(file, fileType){
		var randomId = Math.random().toString(36).substr(2, 9);
		
		var fileName = file.name;
		var fileTypeText = file.text();
		var isDuple = false;
		
		attatchFileArr.forEach(function(file){
			if(file.name == fileName)
				isDuple = true;
		})
		
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
		
		attatchFileArr.push(file);
		attatchFileArr[attatchFileArr.length-1].tempId = randomId;
		attatchFileTypeArr.push({fileType: fileType, fileTypeText: fileTypeText, tempId: randomId});
		
		var childTag = '<li><a href="#none" onclick="removeFile(this, \''+attatchFileTypeArr[attatchFileTypeArr.length-1].tempId+'\')"><img src="/resources/images/icon_del_file.png"></a>'+attatchFileArr[attatchFileTypeArr.length-1].name+'</li>';
		$("#attatch_file").append(childTag);
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
	}
	
	
	function allowDrop(e) {
		e.preventDefault();
		
		e.target.style.backgroundColor = "black";
		e.target.style.opacity  = "0.2";
	}

	function drag(ev) {
		ev.dataTransfer.setData("text", ev.target.id);
	}

	function drop(e) {
		e.preventDefault();
		
		var files = e.target.files || e.dataTransfer.files;
		for(var i=0; i<files.length; i++){
			addDropFile(files[i], '00')
		}
		e.target.style.backgroundColor = "#fff";
		e.target.style.opacity  = "1";
	}

	function drogEnd(e){
		e.target.style.backgroundColor = "#fff";
		e.target.style.opacity  = "1";
	}
	
	function checkFileName(str){
		var result = true;
	    //1. 확장자 체크
	    var ext =  str.split('.').pop().toLowerCase();
	    if($.inArray(ext, ['pdf','png','jpg','jpeg']) == -1) {
	    	var message = "";
	    	message += ext+'파일은 업로드 할 수 없습니다.';
	    	//message += "\n";
	    	message += "(pdf와 이미지(png,jpg,jpeg)만 가능합니다.)";
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
	
	// 입력 확인 및 저장 요청 함수
	function fn_tmp_insert() {
		const resultItemArr = [];
		const itemImageArr = [];
	    var title = document.getElementById("title").value.trim();
	    var excuteDate = document.getElementById("excuteDate").value.trim();
	    const inputMode = document.querySelector('input[name="inputMode"]:checked')?.value;
	    // var storeCodes = document.getElementById("storeCodeValues_1").value.trim();
	    // var productCodes = document.getElementById("productCodeValues_1") ? document.getElementById("productCodeValues_1").value.trim() : "";

	    if (!chkNull(title)) {
	        alert("제목을 입력해 주세요.");
	        document.getElementById("title").focus();
	        return;
	    }
	    
		// ✅ 컬럼 선택 유효성 검사
		const columnSelects = document.querySelectorAll('#columnHeaderRow select');
		const hasUnselectedColumn = Array.from(columnSelects).some(select => select.value === "");

		if (inputMode !== 'upload') {
			if (hasUnselectedColumn) {
				const proceed = confirm("컬럼 헤더가 선택되지 않은 컬럼은 저장되지 않습니다.\n그래도 진행하시겠습니까?");
				if (!proceed) return;
			}			
		}
		
	    var formData = new FormData();
	    // ✅ 헤더 정보 (lab_new_product_result)
	    formData.append("title", title);
	    formData.append("excuteDate", excuteDate);
	    //formData.append("productCodes", productCodes);

	    for (var i = 0; i < attatchFileArr.length; i++) {
	        formData.append("file", attatchFileArr[i]);
	    }
	    
	 	// 1. 컬럼 코드 순서 추출
	    let columnCodes = Array.from(columnSelects).map(select => select.value);

		// 업로드 모드이고, 컬럼 선택된 게 하나도 없거나 모두 빈값일 경우
		if (inputMode === 'upload') {
		  formData.append("columnStates", ""); // ✅ 완전히 빈 문자열로 서버 전송
		} else {
		  formData.append("columnStates", columnCodes.join(','));
		}
	    
		// 2. 셀데이터 추출
		const rows = document.querySelectorAll('#columnBodyRows tr');

		rows.forEach((row, rowIndex) => {
		  const rowItems = [];
		  const cells = row.querySelectorAll('td');

		  for (let colIndex = 1; colIndex < cells.length; colIndex++) {
		    const td = cells[colIndex];
		    const input = td.querySelector('input');
		    const columnCode = columnCodes[colIndex - 1]; // ex: "col1", "" (빈값)

		    // ✅ 컬럼이 선택되지 않은 경우 무시
		    if (!input || !columnCode) continue;

		    if (input.type === "file" && input.files.length > 0) {
		      const file = input.files[0];

		      formData.append("imageFiles", file); // 실제 이미지 파일 전송
		      itemImageArr.push({ rowNo: rowIndex }); // 이미지 위치만 저장

		      rowItems.push({
		        rowNo: rowIndex,
		        columnCode,
		        columnValue: ""
		      });
		    } else {
		      rowItems.push({
		        rowNo: rowIndex,
		        columnCode,
		        columnValue: input.value
		      });
		    }
		  }

		  resultItemArr.push(rowItems);
		});

	    // JSON 직렬화 후 append
	    formData.append("resultItemArr", JSON.stringify(resultItemArr));
	    formData.append("itemImageArr", JSON.stringify(itemImageArr));
	    formData.append("status", "TMP");
	    
	  	$('#lab_loading').show();
	    $.ajax({
	        type: "POST",
	        url: "../newProductResult/insertNewProductResultAjax",
	        data: formData,
	        processData: false,
	        contentType: false,
	        cache: false,
	        dataType: "json",
	        success: function(result) {
	            if (result.RESULT === 'S' && result.IDX > 0) {
	                if (document.getElementById("apprLine").options.length > 0) {
	                    var apprFormData = new FormData();
	                    apprFormData.append("docIdx", result.IDX);
	                    apprFormData.append("apprComment", document.getElementById("apprComment").value);
	                    apprFormData.append("apprLine", $("#apprLine").selectedValues());
	                    apprFormData.append("refLine", $("#refLine").selectedValues());
	                    apprFormData.append("title", title);
	                    apprFormData.append("docType", document.getElementById("docType").value);
	                    apprFormData.append("status", "N");

	                    $.ajax({
	                        type: "POST",
	                        url: "../approval/insertApprTmpAjax",
	                        dataType: "json",
	                        data: apprFormData,
	                        processData: false,
	                        contentType: false,
	                        cache: false,
	                        success: function(data) {
	                            if (data.RESULT === 'S') {
	                            	alert(title + "가 정상적으로 생성되었습니다.");
	        	                    $('#lab_loading').hide();
	        	                    fn_goList();
	                            } else {
	                            	alert("저장 중 오류가 발생하였습니다.\n" + result.MESSAGE);
	            	                $('#lab_loading').hide();
	                            }
	                        },
	                        error: function() {
	                        	alert("저장 중 오류가 발생하였습니다.\n" + result.MESSAGE);
	        	                $('#lab_loading').hide();
	                        }
	                    });
	                } else {
	                    alert(title + "가 정상적으로 생성되었습니다.");
	                    $('#lab_loading').hide();
	                    fn_goList();
	                }
	            } else {
	                alert("저장 중 오류가 발생하였습니다.\n" + result.MESSAGE);
	                $('#lab_loading').hide();
	            }
	        },
	        error: function() {
	            alert("저장 요청 중 오류가 발생하였습니다.");
	            $('#lab_loading').hide();
	        }
	    });
	}
	// 입력 확인 및 저장 요청 함수
	function fn_insert() {
		const resultItemArr = [];
		const itemImageArr = [];
	    var title = document.getElementById("title").value.trim();
	    var excuteDate = document.getElementById("excuteDate").value.trim();
	    const inputMode = document.querySelector('input[name="inputMode"]:checked')?.value;
	    // var storeCodes = document.getElementById("storeCodeValues_1").value.trim();
	    // var productCodes = document.getElementById("productCodeValues_1") ? document.getElementById("productCodeValues_1").value.trim() : "";

	    if (!chkNull(title)) {
	        alert("제목을 입력해 주세요.");
	        document.getElementById("title").focus();
	        return;
	    } else if (!chkNull(excuteDate)) {
	        alert("시행월을 입력해 주세요.");
	        document.getElementById("excuteDate").focus();
	        return;
	    } else if (inputMode === 'manual' && document.querySelectorAll('#columnBodyRows tr').length === 0) {
	        alert("내용 테이블에 최소 한 개의 행이 필요합니다.");
	        return;
	    } else if (attatchFileArr.length == 0) {
	        alert("첨부파일을 등록해주세요.");
	        return;
	    } else if( !chkNull($("#apprTxtFull").val()) ) {
			alert("결재라인을 등록해주세요.");
			return;
		} 

	 	// 1. 유효성 검사: 선택되지 않은 컬럼이 있는지 확인
	    const columnSelects = document.querySelectorAll('#columnHeaderRow select');
	    if(inputMode === 'manual'){
		    for (let select of columnSelects) {
		      if (select.value === "") {
		        alert("모든 컬럼의 항목을 선택해 주세요.");
		        select.focus();
		        return;
		      }
		    }	    	
	    }
	    
	    var formData = new FormData();
	    // ✅ 헤더 정보 (lab_new_product_result)
	    formData.append("title", title);
	    formData.append("excuteDate", excuteDate);
	    //formData.append("productCodes", productCodes);

	    for (var i = 0; i < attatchFileArr.length; i++) {
	        formData.append("file", attatchFileArr[i]);
	    }
	    
	 	// 1. 컬럼 코드 순서 추출
	    let columnCodes = Array.from(columnSelects).map(select => select.value);

		// 업로드 모드이고, 컬럼 선택된 게 하나도 없거나 모두 빈값일 경우
		if (inputMode === 'upload') {
		  formData.append("columnStates", ""); // ✅ 완전히 빈 문자열로 서버 전송
		} else {
		  formData.append("columnStates", columnCodes.join(','));
		}
	    
	    // 2. 셀데이터 추출
	    const rows = document.querySelectorAll('#columnBodyRows tr');
	 	// 테이블 데이터 loop
	    rows.forEach((row, rowIndex) => {
	      const rowItems = [];
	      const cells = row.querySelectorAll('td');

	      for (let colIndex = 1; colIndex < cells.length; colIndex++) {
	        const td = cells[colIndex];
	        const input = td.querySelector('input');
	        const columnCode = columnCodes[colIndex - 1];
	        if (!input) continue;

	        if (input.type === "file" && input.files.length > 0) {
	          const file = input.files[0];

	          formData.append("imageFiles", file); // 이미지 파일 실제 전송
	          itemImageArr.push({ rowNo: rowIndex }); // 이미지의 위치만 전달

	          // text 테이블에는 fileName 대신 빈값 or null 가능
	          rowItems.push({
	            rowNo: rowIndex,
	            columnCode,
	            columnValue: ""  // or null
	          });
	        } else {
	          rowItems.push({
	            rowNo: rowIndex,
	            columnCode,
	            columnValue: input.value
	          });
	        }
	      }

	      resultItemArr.push(rowItems);
	    });

	    // JSON 직렬화 후 append
	    formData.append("resultItemArr", JSON.stringify(resultItemArr));
	    formData.append("itemImageArr", JSON.stringify(itemImageArr));
	    formData.append("status", "REG");
	    
		$('#lab_loading').show();
	    $.ajax({
	        type: "POST",
	        url: "../newProductResult/insertNewProductResultAjax",
	        data: formData,
	        processData: false,
	        contentType: false,
	        cache: false,
	        dataType: "json",
	        success: function(result) {
	            if (result.RESULT === 'S' && result.IDX > 0) {
	                if (document.getElementById("apprLine").options.length > 0) {
	                    var apprFormData = new FormData();
	                    apprFormData.append("docIdx", result.IDX);
	                    apprFormData.append("apprComment", document.getElementById("apprComment").value);
	                    apprFormData.append("apprLine", $("#apprLine").selectedValues());
	                    apprFormData.append("refLine", $("#refLine").selectedValues());
	                    apprFormData.append("title", title);
	                    apprFormData.append("docType", document.getElementById("docType").value);
	                    apprFormData.append("status", "N");

	                    $.ajax({
	                        type: "POST",
	                        url: "../approval/insertApprAjax",
	                        dataType: "json",
	                        data: apprFormData,
	                        processData: false,
	                        contentType: false,
	                        cache: false,
	                        success: function(data) {
	                            if (data.RESULT === 'S') {
	                                alert("결재상신이 완료되었습니다.");
	                                $('#lab_loading').hide();
	                                fn_goList();
	                            } else {
	                                alert("결재선 상신 오류가 발생하였습니다." + data.MESSAGE);
	                                $('#lab_loading').hide();
	                                fn_goList();
	                            }
	                        },
	                        error: function() {
	                            alert("결재 요청 중 오류가 발생하였습니다.");
	                            $('#lab_loading').hide();
	                            fn_goList();
	                        }
	                    });
	                } else {
	                    alert(title + "가 정상적으로 생성되었습니다.");
	                    $('#lab_loading').hide();
	                    fn_goList();
	                }
	            } else {
	                alert("저장 중 오류가 발생하였습니다.\n" + result.MESSAGE);
	                $('#lab_loading').hide();
	            }
	        },
	        error: function() {
	            alert("저장 요청 중 오류가 발생하였습니다.");
	            $('#lab_loading').hide();
	        }
	    });
	}

	function fn_goList() {
		location.href = '/newProductResult/list';
	}
	
	function fn_apprSubmit(){
		if( $("#apprLine option").length == 0 ) {
			alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 결재상신 해 주세요.");
			return;
		} else {
			var apprTxtFull = "";
			$("#apprLine").selectedTexts().forEach(function( item, index ){
				if( apprTxtFull != "" ) {
					apprTxtFull += " > ";
				}
				apprTxtFull += item;
			});
			$("#apprTxtFull").val(apprTxtFull);
			var refTxtFull = "";
			$("#refLine").selectedTexts().forEach(function( item, index ){
				if( refTxtFull != "" ) {
					refTxtFull += ", ";
				}
				refTxtFull += item;
			});
			$("#refTxtFull").html("&nbsp;"+refTxtFull);
		}
		closeDialog('approval_dialog');
	}
	
	function fn_copySearch() {
		openDialog('dialog_search');
	}
	
	function fn_closeSearch() {
		closeDialog('dialog_search');
		$("#searchValue").val("");
		$("#searchCategory1").removeOption(/./);
		$("#searchCategory2").removeOption(/./);
		$("#searchCategory2_div").hide();
		$("#searchCategory3").removeOption(/./);
		$("#searchCategory3_div").hide();
		$("#productLayerBody").html("<tr><td colspan=\"4\">검색해주세요</td></tr>");
	}
	
	function fn_search() {
		var URL = "../newProductResult/searchNewProductResultListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				searchValue : $("#searchValue").val()
			},
			dataType:"json",
			success:function(result) {
				//productLayerBody
				var jsonData = {};
				jsonData = result;
				$('#productLayerBody').empty();
				if( jsonData.length == 0 ) {
					var html = "";
					$("#productLayerBody").html(html);
					html += "<tr><td align='center' colspan='5'>데이터가 없습니다.</td></tr>";
					$("#productLayerBody").html(html);
				} else {
					jsonData.forEach(function(item){
						var row = '<tr onClick="fn_copy(\''+item.RESULT_IDX+'\')">';
						row += '<td></td>';
						row += '<td class="tgnl">'+item.TITLE+'</td>';
						row += '<td>'+item.EXCUTE_DATE+'</td>';
						row += '</tr>';
						$('#productLayerBody').append(row);
					})
				}
			},
			error:function(request, status, errorThrown){
				var html = "";
				$("#productLayerBody").html(html);
				html += "<tr><td align='center' colspan='5'>오류가 발생하였습니다.</td></tr>";
				$("#productLayerBody").html(html);
			}			
		});
	}
	
	function fn_copy(idx) {
		var URL = "../newProductResult/selectNewProductResultDataAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"idx" : idx
			},
			dataType:"json",
			success: function(result) {
			    const data = result.newProductResultData.data;
			    const columnState = data.COLUMN_STATE ? data.COLUMN_STATE.split(',') : [];

			    // ✅ 1. 제목 및 시행월
			    document.getElementById("title").value = data.TITLE || "";
			    document.getElementById("excuteDate").value = data.EXCUTE_DATE || "";
			    
			    if( columnState.length > 0 ) {
	                $("#manual").prop("checked", true); 
	                toggleInputMode("manual");
	             }

			    // ✅ 2. 컬럼 초기화 후 재생성
			    const headerRow = document.getElementById('columnHeaderRow');
			    headerRow.innerHTML = ""; // 전체 헤더 초기화
			    columnCount = 0; // 글로벌 변수 초기화
			    initFixedColumns(); // 체크박스 포함 기본 구조 생성

			    // ✅ 기존 컬럼들 제거 후 정확히 지정된 것만 생성
			    const baseHeaderLength = 1; // 체크박스 TH 제외한 index 보정용
			    const selects = document.querySelectorAll('#columnHeaderRow select');

			    for (let i = 0; i < columnState.length; i++) {
			        if (i >= selects.length) createColumn(); // 부족하면 추가
			        const select = document.querySelectorAll('#columnHeaderRow select')[i];
			        if (select) {
			            select.value = columnState[i];
			            select.dispatchEvent(new Event('change'));
			        }
			    }

			    // ✅ 3. 행 개수 생성
			    const maxRowNo = Math.max(...(result.itemList.map(item => item.ROW_NO)));
			    const body = document.getElementById('columnBodyRows');
			    body.innerHTML = ""; // 기존 row 전부 제거
			    for (let i = 0; i <= maxRowNo; i++) {
			        createRow();
			    }

			    // ✅ 4. 값 매핑 (TEXT)
			    result.itemList.forEach(item => {
			        const rowIndex = item.ROW_NO;
			        const colIndex = columnState.indexOf(item.COLUMN_CODE);
			        if (colIndex === -1) return;

			        const row = document.querySelectorAll('#columnBodyRows tr')[rowIndex];
			        if (!row) return;

			        const td = row.children[colIndex + 1]; // +1 for 체크박스
			        if (!td) return;

			        // 이미지 input이면 스킵
			        if (td.querySelector('input[type="file"]')) return;

			        const input = td.querySelector('input[type="text"]');
			        if (input) {
			            input.value = item.COLUMN_VALUE;
			        }
			    });

			    // ✅ 5. 이미지/첨부파일은 복사하지 않음
			    document.getElementById("attatch_file").innerHTML = "";
			    attatchFileArr = [];
			    attatchFileTypeArr = [];

			    fn_closeSearch();
			},
			error:function(request, status, errorThrown){
				
			}			
		});
	}
	
// ---------------------------------------- STORE POP -----------------------------------------	
	function openMultiSelectDialog(targetType, idx) {
	    window._multiSelectTarget = {
	        type: targetType, // 'store' 또는 'product'
	        idx: idx
	    };

	    document.getElementById("dialog_store").style.display = "block";

	    // 데이터가 이미 로드된 경우엔 필터 없이 다시 표시
	    if (_multiSelectCache[targetType]?.length > 0) {
	        renderMultiSelectTable(_multiSelectCache[targetType]);
	        return;
	    }

	    // AJAX로 데이터 로드
	    $.ajax({
	        type: "POST",
	        url: "../common/codeListAjax",
	        data: { groupCode: targetType.toUpperCase() }, // 'STORE', 'PRODUCT'
	        dataType: "json",
	        success: function (data) {
	            _multiSelectCache[targetType] = data.RESULT;
	            renderMultiSelectTable(data.RESULT);
	        },
	        error: function () {
	            alert(targetType + " 정보를 불러오는데 실패했습니다.");
	        }
	    });
	}

	function renderMultiSelectTable(list) {
	    const { type, idx } = window._multiSelectTarget;
	    var selectedEl = document.getElementById(type + "CodeValues_" + idx);
	    var selectedCodesStr = selectedEl ? selectedEl.value : "";
	    const selectedCodes = selectedCodesStr.split(',').map(code => code.trim());

	    const tbody = document.getElementById("storeLayerBody");
	    tbody.innerHTML = "";

	    if (!list || list.length === 0) {
	        tbody.innerHTML = "<tr><td colspan='3'>검색 결과가 없습니다.</td></tr>";
	        document.getElementById("storeCount").textContent = "0";
	        return;
	    }

	    list.forEach(item => {
	        const isChecked = selectedCodes.includes(item.itemCode);

	        const row = document.createElement("tr");
	        row.innerHTML =
	            "<td><input type='checkbox' style='width:20px; height:20px;' name='multiChk' value='" + item.itemCode + "' data-name='" + item.itemName + "'" + (isChecked ? " checked" : "") + "></td>" +
	            "<td>" + item.itemCode + "</td>" +
	            "<td>" + item.itemName + "</td>";
	        tbody.appendChild(row);
	    });

	    document.getElementById("storeCount").textContent = list.length;
	}

	function chooseMultiSelect() {
	    const { type, idx } = window._multiSelectTarget;
	    const checked = document.querySelectorAll("input[name='multiChk']:checked");

	    const tokenBox = document.getElementById(type + "TokenBox_" + idx);
	    const hiddenInput = document.getElementById(type + "CodeValues_" + idx);

	    tokenBox.innerHTML = '';
	    const selectedCodes = [];

	    checked.forEach(item => {
	        const code = item.value;
	        const name = item.getAttribute("data-name");
	        selectedCodes.push(code);

	        const token = document.createElement("span");
	        token.className = "store-token";
	        token.setAttribute("data-code", code);
	        token.style = `
	            display: flex;
	            align-items: center;
	            background: #e0e0e0;
	            border-radius: 12px;
	            padding: 4px 8px;
	            margin-right: 5px;
	            font-size: 13px;
	        `;

	        const removeBtn = document.createElement("span");
	        removeBtn.textContent = "✕";
	        removeBtn.style = `
	            font-weight: bold;
	            margin-right: 6px;
	            cursor: pointer;
	            color: #666;
	        `;
	        removeBtn.onclick = function () {
	            token.remove();
	            updateHiddenCodes(type, idx);
	        };

	        token.appendChild(removeBtn);
	        token.append(name);
	        tokenBox.appendChild(token);
	    });

	    hiddenInput.value = selectedCodes.join(',');
	    closeDialog('dialog_' + type);
	}

	function updateHiddenCodes(type, idx) {
	    const tokens = document.querySelectorAll('#'+type+'TokenBox_'+idx+' .brand-token');
	    const codes = [...tokens].map(t => t.getAttribute("data-code"));
	    document.getElementById(type+'CodeValues_'+idx).value = codes.join(',');
	}

	function searchMultiSelectKeyword() {
	    const keyword = document.getElementById("searchStoreValue").value.trim().toLowerCase();
	    const list = _multiSelectCache[window._multiSelectTarget.type];

	    const filtered = list.filter(item =>
	        item.itemCode.toLowerCase().includes(keyword) ||
	        item.itemName.toLowerCase().includes(keyword)
	    );

	    renderMultiSelectTable(filtered);
	}
	function clearStoreToken(idx) {
		const tokenBox = document.getElementById("storeTokenBox_" + idx);
		const hiddenInput = document.getElementById("storeCodeValues_" + idx);

		if (tokenBox) tokenBox.innerHTML = '';
		if (hiddenInput) hiddenInput.value = '';
	}
	function clearProductToken(idx) {
		const tokenBox = document.getElementById("productTokenBox_" + idx);
		const hiddenInput = document.getElementById("productCodeValues_" + idx);

		if (tokenBox) tokenBox.innerHTML = '';
		if (hiddenInput) hiddenInput.value = '';
	}
	
	function bindStoreDialogEnter(e) {
	    if (e.key === 'Enter') {
	        searchStore();
	    }
	}
	
	function searchStore() {
	    var keyword = document.getElementById("searchStoreValue").value.trim().toLowerCase();
	    var list = _multiSelectCache["store"] || [];

	    var filtered = list.filter(function (item) {
	        return item.itemCode.toLowerCase().includes(keyword) ||
	               item.itemName.toLowerCase().includes(keyword);
	    });

	    renderMultiSelectTable(filtered);
	}

	function bindProductDialogEnter(e) {
	    if (e.key === 'Enter') {
	        searchProduct();
	    }
	}

	function searchProduct() {
	    var keyword = document.getElementById("searchProductValue").value.trim().toLowerCase();
	    var list = _multiSelectCache["product"] || [];

	    var filtered = list.filter(function (item) {
	        return item.itemCode.toLowerCase().includes(keyword) ||
	               item.itemName.toLowerCase().includes(keyword);
	    });

	    renderMultiSelectTable(filtered);
	}

// ---------------------------------------- STORE POP -----------------------------------------
// 동적 테이블 관련 함수 시작
let columnCount = 0; // 현재 컬럼 수
const MAX_COLUMNS = 6;
const MAX_ROWS = 20;

function createColumn() {
	  const columnOptions = _multiSelectCache.column || [];
	  const maxAvailableColumns = columnOptions.length;

	  if (columnCount >= MAX_COLUMNS) {
	    alert("최대 6개의 컬럼까지만 추가할 수 있습니다.");
	    return;
	  }

	  columnCount++;
	  const headerRow = document.getElementById('columnHeaderRow');
	  const th = document.createElement('th');
	  th.dataset.colIndex = columnCount;

	  const container = document.createElement('div');
	  container.className = 'search_box';
	  container.style.display = 'flex';
	  container.style.alignItems = 'center';
	  container.style.justifyContent = 'center'; // ✅ 중앙 정렬
	  container.style.gap = '5px';

	  // < 버튼
	  const leftBtn = document.createElement('button');
	  leftBtn.className = 'btn_col_arrow';
	  leftBtn.innerHTML = '&lt;';
	  leftBtn.type = 'button';
	  leftBtn.style.cursor = 'pointer';
	  leftBtn.onclick = () => moveColumn(th, -1);

	  // 셀렉트박스
	  const selectBox = document.createElement('div');
	  selectBox.className = 'selectbox';

	// 셀렉트박스 생성
	  const select = document.createElement('select');
	  select.name = 'columnState_' + columnCount;
	  select.style.opacity = '1';
	  select.style.position = 'static';
	  select.style.zIndex = 'auto';
	  select.style.minWidth = '60px';
	  select.style.maxWidth = '120px';
	  select.style.width = 'auto';

	  // ✅ 1. "-- 선택 --" 기본 옵션 먼저 추가
	  const defaultOption = document.createElement('option');
	  defaultOption.value = "";
	  defaultOption.textContent = "-- 선택 --";
	  select.appendChild(defaultOption);

	  // ✅ 2. 실제 옵션 목록 추가
	  columnOptions.forEach(opt => {
	    const option = document.createElement('option');
	    option.value = opt.itemCode;
	    option.textContent = opt.itemName;
	    select.appendChild(option);
	  });

	  // ✅ 초기 선택은 항상 "-- 선택 --"
	  select.selectedIndex = 0;
	  select.dataset.prevIndex = select.selectedIndex;

	  selectBox.appendChild(select);

	  // X 버튼
	  const delBtn = document.createElement('button');
	  delBtn.textContent = 'X';
	  delBtn.type = 'button';
	  delBtn.style.border = 'none';
	  delBtn.style.background = 'transparent';
	  delBtn.style.color = 'red';
	  delBtn.style.cursor = 'pointer';
	  delBtn.onclick = function () {
	    const currentColumnCount = headerRow.querySelectorAll('th').length - 1;
	    if (currentColumnCount <= 1) {
	      alert('최소 한 개의 컬럼은 남아있어야 합니다.');
	      return;
	    }

	    if (confirm('해당 컬럼이 삭제됩니다. 입력하신 내용 모두 사라집니다.')) {
	      const colIndex = Array.from(headerRow.children).indexOf(th);
	      th.remove();
	      const rows = document.querySelectorAll('#columnBodyRows tr');
	      rows.forEach(row => {
	        const tds = row.querySelectorAll('td');
	        if (tds[colIndex]) tds[colIndex].remove();
	      });
	      columnCount--;
	      refreshSelectOptions();
	    }
	  };

	  // > 버튼
	  const rightBtn = document.createElement('button');
	  rightBtn.className = 'btn_col_arrow';
	  rightBtn.innerHTML = '&gt;';
	  rightBtn.type = 'button';
	  rightBtn.style.cursor = 'pointer';
	  rightBtn.onclick = () => moveColumn(th, 1);

	  // 조립
	  container.appendChild(leftBtn);
	  container.appendChild(selectBox);
	  container.appendChild(delBtn);
	  container.appendChild(rightBtn);
	  th.appendChild(container);
	  headerRow.appendChild(th);

	  // 본문 row에 셀 추가
	  const rows = document.querySelectorAll('#columnBodyRows tr');
	  for (let j = 0; j < rows.length; j++) {
	    const td = document.createElement('td');
	    td.innerHTML = '<input type="text" name="cell_' + j + '_' + columnCount + '" style="width:100%;">';
	    rows[j].appendChild(td);
	  }

	  select.dataset.prevIndex = select.selectedIndex; // 초기 선택값 저장
	  select.onchange = function () {
	    handleColumnSelectChange(this);
	  };

	  const selectedText = select.options[select.selectedIndex]?.text;
	  if (selectedText?.includes("이미지")) {
	    const colIndex = Array.prototype.indexOf.call(th.parentElement.children, th);
	    updateColumnToFileInput(colIndex, true);
	  }
	  
	  // 마지막에 추가
	  refreshSelectOptions();
	}


function initFixedColumns() {
  const headerRow = document.getElementById('columnHeaderRow');
  headerRow.innerHTML = ""; // 기존 초기화
  columnCount = 0;

  // ✅ 체크박스 컬럼
  const checkboxTh = document.createElement('th');
  checkboxTh.style.textAlign = 'center';
  checkboxTh.style.width = '26px';  
  checkboxTh.style.padding = '7px 13px';  

  const checkDiv = document.createElement('div');
  checkDiv.className = 'search_box';

  const input = document.createElement('input');
  input.type = 'checkbox';
  input.id = 'toggleAll';
  input.onclick = function () { toggleAllRows(this); };

  const label = document.createElement('label');
  label.setAttribute('for', 'toggleAll');
  label.appendChild(document.createElement('span'));

  checkDiv.appendChild(input);
  checkDiv.appendChild(label);
  checkboxTh.appendChild(checkDiv);
  headerRow.appendChild(checkboxTh);

  // ✅ 순차 분배 방식
  const columnOptions = _multiSelectCache.column || [];
  const usedCodes = [];

  for (let i = 0; i < 4; i++) {
    columnCount++;

    const th = document.createElement('th');

    const container = document.createElement('div');
    container.className = 'search_box';
    container.style.display = 'flex';
    container.style.alignItems = 'center';
    container.style.justifyContent = 'center';  // ✅ 가운데 정렬
    container.style.gap = '5px';

    // < 버튼
    const leftBtn = document.createElement('button');
    leftBtn.className = 'btn_col_arrow';
    leftBtn.innerHTML = '&lt;';
    leftBtn.type = 'button';
    leftBtn.style.cursor = 'pointer';
    leftBtn.onclick = () => moveColumn(th, -1);

 // 셀렉트박스
    const selectBox = document.createElement('div');
    selectBox.className = 'selectbox';

    const select = document.createElement('select');
    select.name = 'columnState_' + columnCount;
    select.style.minWidth = '60px';
    select.style.maxWidth = '120px';
    select.style.width = 'auto';
    select.style.opacity = '1';
    select.style.position = 'static';
    select.style.zIndex = 'auto';

    // ✅ 디폴트 옵션 추가
    const defaultOption = document.createElement('option');
    defaultOption.value = "";
    defaultOption.textContent = "-- 선택 --";
    select.appendChild(defaultOption);

    // ✅ 모든 옵션 추가
    columnOptions.forEach(opt => {
      const option = document.createElement('option');
      option.value = opt.itemCode;
      option.textContent = opt.itemName;
      select.appendChild(option);
    });

    select.selectedIndex = 0;
    select.dataset.prevIndex = select.selectedIndex;

    // ✅ change 이벤트 등록
    select.onchange = function () {
      handleColumnSelectChange(this);
    };

    // ✅ selectBox 안에 select 추가 후,
    selectBox.appendChild(select);

    // X 버튼
    const delBtn = document.createElement('button');
    delBtn.textContent = 'X';
    delBtn.type = 'button';
    delBtn.style.border = 'none';
    delBtn.style.background = 'transparent';
    delBtn.style.color = 'red';
    delBtn.style.cursor = 'pointer';
	delBtn.onclick = function () {
	   const currentColumnCount = headerRow.querySelectorAll('th').length - 1;
	   if (currentColumnCount <= 1) {
	     alert('최소 한 개의 컬럼은 남아있어야 합니다.');
	     return;
	   }
	   
	   if (confirm('해당 컬럼이 삭제됩니다. 입력하신 내용 모두 사라집니다.')) {
	     const colIndex = Array.from(headerRow.children).indexOf(th);
	     th.remove();
	     const rows = document.querySelectorAll('#columnBodyRows tr');
	     rows.forEach(row => {
	       const tds = row.querySelectorAll('td');
	       if (tds[colIndex]) tds[colIndex].remove();
	     });
	     columnCount--;
	     refreshSelectOptions();
	   }
	 };

    // > 버튼
    const rightBtn = document.createElement('button');
    rightBtn.className = 'btn_col_arrow';
    rightBtn.innerHTML = '&gt;';
    rightBtn.type = 'button';
    rightBtn.style.cursor = 'pointer';
    rightBtn.onclick = () => moveColumn(th, 1);

    // 조립
    container.appendChild(leftBtn);
    container.appendChild(selectBox);
    container.appendChild(delBtn);
    container.appendChild(rightBtn);

    th.appendChild(container);
    headerRow.appendChild(th);

    
  }

  refreshSelectOptions(); // 초기화 이후 한 번 전체 옵션 정리
}


function initColumns(count) {
  for (let i = 0; i < count; i++) {
    createColumn();
  }
}


function createRow() {
  const tbody = document.getElementById('columnBodyRows');
  const rowIndex = tbody.rows.length;

  if (rowIndex >= MAX_ROWS) {
    alert("최대 20개의 행까지만 추가할 수 있습니다.");
    return;
  }

  const tr = document.createElement('tr');

  // ✅ 첫 번째 셀: 커스텀 체크박스 (.search_box 스타일 적용)
  const checkTd = document.createElement('td');
  checkTd.style.textAlign = 'center';

  const checkDiv = document.createElement('div');
  checkDiv.className = 'search_box';

  const input = document.createElement('input');
  const checkboxId = 'row_select_' + rowIndex;
  input.type = 'checkbox';
  input.id = checkboxId;
  input.name = checkboxId;

  const label = document.createElement('label');
  label.setAttribute('for', checkboxId);

  const span = document.createElement('span');
  label.appendChild(span);

  checkDiv.appendChild(input);
  checkDiv.appendChild(label);
  checkTd.appendChild(checkDiv);
  tr.appendChild(checkTd);

  // ✅ 나머지 컬럼 셀 생성
  const colCount = document.querySelectorAll('#columnHeaderRow th').length - 1; // 첫 번째 체크박스 제외
  for (let i = 1; i <= colCount; i++) {
    const td = document.createElement('td');
    td.innerHTML = '<input type="text" name="cell_' + rowIndex + '_' + i + '" style="width:100%;">';
    tr.appendChild(td);
  }

  tbody.appendChild(tr);
  
//✅ 이후 이미지 컬럼을 찾아 업데이트
  const headers = document.querySelectorAll('#columnHeaderRow th');
  for (let i = 1; i < headers.length; i++) {
    const select = headers[i].querySelector('select');
    if (select && select.options[select.selectedIndex].text.indexOf('이미지') !== -1) {
      updateColumnToFileInput(i, true);  // i번째 열을 이미지 input으로 변경
    }
  }
}

function toggleAllRows(checkbox) {
  var checkboxes = document.querySelectorAll('#columnBodyRows input[type="checkbox"]');
  for (var i = 0; i < checkboxes.length; i++) {
    checkboxes[i].checked = checkbox.checked;
  }
}

function addColumnHeader(colIndex, columnOptions) {
	  const headerRow = document.getElementById('columnHeaderRow');
	  const th = document.createElement('th');
	  th.dataset.colIndex = colIndex;

	  const container = document.createElement('div');
	  container.className = 'search_box';
	  container.style.display = 'flex';
	  container.style.alignItems = 'center';
	  container.style.gap = '5px';

	  const selectBox = document.createElement('div');
	  selectBox.className = 'selectbox';

	  const select = document.createElement('select');
	  select.name = 'columnState_' + colIndex;
	  select.style.opacity = '1';
	  select.style.position = 'static';

	  for (let j = 0; j < columnOptions.length; j++) {
	    const option = document.createElement('option');
	    option.value = columnOptions[j].itemCode;
	    option.textContent = columnOptions[j].itemName;
	    select.appendChild(option);
	  }

	  selectBox.appendChild(select);

	  // ❌ 삭제 버튼 추가
	  const delBtn = document.createElement('button');
	  delBtn.textContent = 'X';
	  delBtn.type = 'button';
	  delBtn.style.border = 'none';
	  delBtn.style.background = 'transparent';
	  delBtn.style.color = 'red';
	  delBtn.style.cursor = 'pointer';
	  delBtn.onclick = function () {
	    if (confirm('해당 컬럼이 삭제됩니다. 입력하신 내용 모두 사라집니다.')) {
	      const colIndex = Array.from(th.parentElement.children).indexOf(th);
	      th.remove();

	      const rows = document.querySelectorAll('#columnBodyRows tr');
	      rows.forEach(row => {
	        const tdList = row.querySelectorAll('td');
	        if (tdList[colIndex]) {
	          tdList[colIndex].remove();
	        }
	      });

	      columnCount--;
	    }
	  };

	  container.appendChild(selectBox);
	  container.appendChild(delBtn);

	  th.appendChild(container);
	  headerRow.appendChild(th);
	}
	
function deleteRow() {
  const tbody = document.getElementById('columnBodyRows');
  const rows = tbody.querySelectorAll('tr');
  let removed = false;

  for (let i = rows.length - 1; i >= 0; i--) {
    const checkbox = rows[i].querySelector('input[type="checkbox"]');
    if (checkbox && checkbox.checked) {
      tbody.removeChild(rows[i]);
      removed = true;
    }
  }

  if (!removed) {
    alert("삭제할 행을 선택해주세요.");
  }
}

function updateColumnToFileInput(colIndex, isImageColumn) {
	  const rows = document.querySelectorAll('#columnBodyRows tr');
	  rows.forEach(function (row, rowIdx) {
	    const td = row.querySelectorAll('td')[colIndex];
	    if (td) {
	      // ✅ 기존에 이미지가 등록되어 있으면 건너뜀
	      if (isImageColumn) {
	        const existingInput = td.querySelector('input[type="file"]');
	        if (existingInput && existingInput.files.length > 0) {
	          return; // 이미지 이미 등록되어 있음
	        }

	        td.innerHTML =
	          '<div style="display: flex; flex-direction: column; align-items: center;">' +
	            '<div style="position: relative; display: inline-block; width: 150px; height: 150px;">' +
	              '<div style="position: absolute; top: 4px; right: 4px; z-index: 3;">' +
	                '<img src="/resources/images/btn_table_header01_del02.png" ' +
	                'onclick="fn_deleteImageFile(this, event)" style="cursor: pointer;">' +
	              '</div>' +
	              '<img id="preview" src="/resources/images/img_noimg3.png" ' +
	              'style="width: 100%; height: 100%; border:1px solid #e1e1e1; border-radius:5px; object-fit: contain;">' +
	            '</div>' +
	            '<div class="add_file2" style="width:100%; text-align:center; margin-top: 8px;" onclick="fn_fileDivClick(event)">' +
	              '<input type="file" name="cell_' + rowIdx + '_' + colIndex + '" id="fileImageInput_' + rowIdx + '_' + colIndex + '" ' +
	              'accept="image/*" style="display:none;" onchange="fn_changeImageFile(this)">' +
	              '<label style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>' +
	            '</div>' +
	          '</div>';
	      } else {
	        td.innerHTML =
	          '<input type="text" name="cell_' + rowIdx + '_' + colIndex + '" style="width:100%;">';
	      }
	    }
	  });
	}

function fn_fileDivClick(e) {
	  e.stopPropagation();
	  const fileInput = e.currentTarget.querySelector('input[type="file"]');
	  if (fileInput) {
	    fileInput.click(); // 하나의 click으로만 제어
	  }
	}

function fn_changeImageFile(input) {
  if (input.files && input.files[0]) {
    var reader = new FileReader();
    reader.onload = function (readerEvent) {
      const preview = input.closest('td').querySelector('img#preview');
      if (preview) {
        preview.src = readerEvent.target.result;
      }
    };
    reader.readAsDataURL(input.files[0]);
  }
}

function fn_deleteImageFile(element, e) {
  e.stopPropagation(); // 클릭 이벤트 버블링 방지

  const td = element.closest('td');
  if (!td) return;

  const preview = td.querySelector('img#preview');
  const fileInput = td.querySelector('input[type="file"]');

  if (preview) preview.src = "/resources/images/img_noimg3.png";
  if (fileInput) fileInput.value = "";
}
function refreshSelectOptions() {
	  const allSelects = document.querySelectorAll('#columnHeaderRow select');

	  allSelects.forEach(select => {
	    const currentValue = select.value;

	    select.innerHTML = '';

	    // ✅ 항상 "-- 선택 --" 먼저 추가
	    const defaultOption = document.createElement('option');
	    defaultOption.value = '';
	    defaultOption.textContent = '-- 선택 --';
	    select.appendChild(defaultOption);

	    // ✅ 선택된 값을 포함해서 무조건 전체 옵션 다시 보여줌
	    _multiSelectCache.column.forEach(option => {
	      const opt = document.createElement('option');
	      opt.value = option.itemCode;
	      opt.textContent = option.itemName;
	      select.appendChild(opt);
	    });

	    // ✅ 이전 선택값 복원
	    select.value = currentValue;
	    select.dataset.prevIndex = select.selectedIndex;
	  });
	}


function moveColumn(th, direction) {
	  const headerRow = document.getElementById('columnHeaderRow');
	  const allThs = Array.from(headerRow.children);
	  const colIndex = allThs.indexOf(th); // 이동할 대상 th 인덱스

	  // 체크박스 컬럼 제외
	  if (colIndex <= 0) return;

	  const targetIndex = colIndex + direction;

	  // 범위 체크 (맨 좌측, 우측이면 무시)
	  if (targetIndex <= 0 || targetIndex >= allThs.length) return;

	  // th 이동
	  const targetTh = allThs[targetIndex];
	  if (direction === -1) {
	    headerRow.insertBefore(th, targetTh);
	  } else {
	    headerRow.insertBefore(th, targetTh.nextSibling);
	  }

	  // tbody의 각 tr의 td도 같이 이동
	  const rows = document.querySelectorAll('#columnBodyRows tr');
	  rows.forEach(row => {
	    const tds = Array.from(row.children);
	    const td = tds[colIndex];
	    const targetTd = tds[targetIndex];
	    if (direction === -1) {
	      row.insertBefore(td, targetTd);
	    } else {
	      row.insertBefore(td, targetTd.nextSibling);
	    }
	  });

	  // ✅ 옵션 재정렬
	  refreshSelectOptions();
	}
function handleColumnSelectChange(select) {
	  const selectedText = select.options[select.selectedIndex].text;

	  // ✅ 선택 안된 경우 (첫 번째 '-- 선택 --')
	  if (select.value === "") {
	    return;
	  }

	  // 1. 이미지 중복 방지
	  if (selectedText.includes("이미지")) {
	    const allSelects = document.querySelectorAll('#columnHeaderRow select');
	    let imageCount = 0;
	    allSelects.forEach(s => {
	      if (s !== select && s.options[s.selectedIndex].text.includes("이미지")) {
	        imageCount++;
	      }
	    });

	    if (imageCount > 0) {
	      alert("이미지 컬럼은 하나만 선택할 수 있습니다.");
	      select.selectedIndex = select.dataset.prevIndex || 0;
	      return;
	    }
	  }

	  // 2. 동일한 코드 이름 중복 방지
	  const allSelects = document.querySelectorAll('#columnHeaderRow select');
	  const currentText = selectedText;
	  let duplicate = false;
	  allSelects.forEach(s => {
	    if (s !== select && s.options[s.selectedIndex].text === currentText) {
	      duplicate = true;
	    }
	  });

	  if (duplicate) {
	    alert("중복된 컬럼이 있습니다.");
	    select.selectedIndex = select.dataset.prevIndex || 0;
	    return;
	  }

	  // 3. 이미지 input 변환
	  const colIndex = Array.prototype.indexOf.call(select.closest('tr').children, select.closest('th'));
	  const isImageColumn = selectedText.includes("이미지");
	  updateColumnToFileInput(colIndex, isImageColumn);

	  // 4. 이전 선택값 저장
	  select.dataset.prevIndex = select.selectedIndex;
	}
// 동적 테이블 관련 함수 끝

function toggleInputMode(mode) {
  const tableSection = document.getElementById("dynamicTableSection");
  const prevBtn = document.getElementById("prevBtn");
  if (mode === 'manual') {
    tableSection.style.display = '';
    prevBtn.style.display = '';
  } else {
    tableSection.style.display = 'none';
    prevBtn.style.display = 'none';
  }
}

function fn_previewDataBinding(popup) {
	const $doc = popup.document;
	const columnSelects = document.querySelectorAll('#columnHeaderRow select');

	// ✅ 유효한 컬럼만 추출 (value가 있는 경우만)
	const validColumnDefs = [];
	columnSelects.forEach(select => {
		if (select.value) {
			validColumnDefs.push({
				code: select.value,
				name: select.options[select.selectedIndex].textContent
			});
		}
	});

	const dynamicColCount = validColumnDefs.length;

	// ✅ 제목 / 시행월 채우기 (colspan 적용)
	$doc.getElementById("prev_title").innerText = document.getElementById("title").value;
	$doc.getElementById("prev_title").setAttribute("colspan", dynamicColCount);
	$doc.getElementById("prev_excuteDate").innerText = document.getElementById("excuteDate").value;
	$doc.getElementById("prev_excuteDate").setAttribute("colspan", dynamicColCount);
	$doc.getElementById("prev_dynamicTableTd").setAttribute("colspan", dynamicColCount);
	$doc.getElementById("prev_file").setAttribute("colspan", dynamicColCount);

	// ✅ <colgroup> 생성 (thead, tbody 이전에!)
	const colgroup = $doc.getElementById("prev_colgroup");
	colgroup.innerHTML = "";
	for (let i = 0; i < dynamicColCount; i++) {
		const col = $doc.createElement("col");
		col.style.width = (100 / dynamicColCount) + "%";
		colgroup.appendChild(col);
	}
	
	// ✅ 헤더 구성
	const thead = $doc.getElementById("prev_dynamicThead");
	thead.innerHTML = ""; // 초기화
	validColumnDefs.forEach(col => {
		const th = $doc.createElement("th");
		th.innerText = col.name;
		thead.appendChild(th);
	});
	
	const inputMode = document.querySelector('input[name="inputMode"]:checked')?.value;
	if (inputMode !== 'upload') {
		// ✅ 본문 구성
		const prevTbody = $doc.getElementById("prev_dynamicTbody");
		prevTbody.innerHTML = ""; // 초기화
		const rows = document.querySelectorAll("#columnBodyRows tr");

		rows.forEach((row, rowIdx) => {
			const tr = $doc.createElement("tr");
			const cells = row.querySelectorAll("td");

			for (let colIndex = 0; colIndex < validColumnDefs.length; colIndex++) {
				const td = $doc.createElement("td");
				const realIndex = Array.from(columnSelects).findIndex(sel => sel.value === validColumnDefs[colIndex].code);
				const cell = cells[realIndex + 1]; // +1 to skip checkbox column
				const input = cell.querySelector("input");

				if (input?.type === "file") {
					const img = cell.querySelector("img#preview");
					const newImg = $doc.createElement("img");
					newImg.src = img?.src || "/resources/images/img_noimg3.png";
					newImg.style.width = "98%";
					newImg.style.height = "150px";
					newImg.style.objectFit = "contain";
					newImg.style.border = "1px solid #ddd";
					td.style.padding = "0px";
					td.appendChild(newImg);
				} else {
					td.innerText = input?.value || "";
				}

				tr.appendChild(td);
			}

			prevTbody.appendChild(tr);
		});
	} else {
		$doc.getElementById("prev_content").style.display = 'none';
	}
	
	// ▼▼▼ [첨부파일] 미리보기 바인딩 추가 시작 ▼▼▼
    // 파일명 안전 이스케이프
    const esc = (s) => String(s)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;");

    // 1) <input type="file" name="files"> 들에서 선택된 파일명 수집
    const fileNames = [];
    document.querySelectorAll('input[type="file"][name="files"]').forEach(input => {
      // 같은 input에 여러 파일이 선택될 수도 있음
      Array.from(input.files || []).forEach(f => {
        if (f && f.name) fileNames.push(f.name);
      });
    });

    // 2) 이미 페이지의 파일 목록(UI)에서 표시 중인 항목도 수집 (드래그&드롭 등으로 추가된 케이스)
    //    - <ul id="attatch_file"><li>...파일명...</li></ul> 형태 가정
    const $ul = document.getElementById("attatch_file");
    if ($ul) {
      $ul.querySelectorAll("li").forEach(li => {
        // li 안에 a/span이 있든 그냥 텍스트든 전부 텍스트로 인식
        const t = (li.textContent || "").trim();
        if (t) fileNames.push(t);
      });
    }

    // 3) 중복 제거 + 공백 제거
    const uniqueNames = Array.from(new Set(
      fileNames.map(s => s.trim()).filter(Boolean)
    ));

    // 4) 미리보기 페이지에 반영
    const $prevFile = $doc.getElementById("prev_file");
    const $prevFileWrap = $doc.getElementById("wrapper_prev_file"); // 있으면 사용, 없으면 무시

    if (uniqueNames.length > 0) {
      // <br/>로 줄바꿈하여 넣기
      $prevFile.innerHTML = uniqueNames.map(n => esc(n)).join("<br/>");
      if ($prevFileWrap) $prevFileWrap.style.display = "table-row"; // 또는 "block" (미리보기 마크업에 맞게)
    } else {
      // 아무 파일도 없으면 숨기거나 대시 처리
      // ① 숨김
      if ($prevFileWrap) $prevFileWrap.style.display = "none";
      // ② 혹은 표시 유지 시 대시
      // $prevFile.textContent = "-";
    }
    // ▲▲▲ [첨부파일] 미리보기 바인딩 추가 끝 ▲▲▲
}

function fn_openPreview() {
	var url = "/preview/newProductPrevPopup";

	// 팝업 창 열기
	var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes");

	// 팝업이 완전히 열린 뒤에 데이터 전달
	popup.onload = function () {
		// 여기서 fn_openPreview() 호출해서 팝업 DOM에 값 세팅
		fn_previewDataBinding(popup);
	};
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
				
			</div>
		</h2>
		<div class="group01 mt20">
			<div class="title2"  style="display: flex; justify-content:space-between; width: 100%;">
				<span class="txt">기본정보</span>
				<div class="pr15">
					<button id="prevBtn" class="btn_small_search" onclick="fn_copySearch()" >불러오기</button>
					<button id="prevBtn" class="btn_small_search" onclick="fn_openPreview()">미리보기</button>
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
							<th style="border-left: none;">제목<span class="mandatory">*</span></th>
							<td colspan="3"><input type="text" name="title" id="title" style="width: 90%;"/></td>
						</tr>
						<tr>
							<th style="border-left: none;">결재라인</th>
							<td colspan="3">
								<input class="" id="apprTxtFull" name="apprTxtFull" type="text" style="width: 450px; float: left" readonly>
								<button class="btn_small_search ml5" onclick="apprClass.openApprovalDialog()" style="float: left">결재</button>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">참조자</th>
							<td colspan="3">
								<div id="refTxtFull" name="refTxtFull"></div>								
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">시행월<span class="mandatory">*</span></th>
							<td colspan="3"><input type="text" id="excuteDate" readonly placeholder="시행월 선택 (예: 2024-05)" style="width: 170px;"></td>
						</tr>
						<!-- 
						<tr>
							<th style="border-left: none;">매장명</th>
							<td colspan="3">
								<div style="display:flex; gap:10px; margin-top:20px;">
									<div id="storeTokenBox_1" class="token-box" style="flex: 1; display: flex; flex-wrap: wrap; gap: 5px;"></div>
									<button type="button" onclick="openMultiSelectDialog('store', 1)" class="btn_small_search ml5">조회</button>
									<button type="button" onclick="clearStoreToken(1)" class="btn_small_search ml5">초기화</button>
									<input type="hidden" id="storeCodeValues_1" name="storeCodeValues_1">
								</div>
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">제품명</th>
							<td colspan="3">
								<div style="display:flex; gap:10px; margin-top:20px">
									<div id="productTokenBox_1" class="token-box" style="flex: 1; display: flex; flex-wrap: wrap; gap: 5px;"></div>
									<button type="button" onclick="openMultiSelectDialog('product', 1)" class="btn_small_search ml5">조회</button>
									<button type="button" onclick="clearProductToken(1)" class="btn_small_search ml5">초기화</button>
									<input type="hidden" id="productCodeValues_1" name="productCodeValues_1">
								</div>
							</td>
						</tr>	
						 -->					
						<tr>
						  <th style="border-left: none;">입력 방식</th>
						  <td colspan="3">
						    <input type="radio" name="inputMode" id="upload" value="upload" checked onchange="toggleInputMode(this.value)">
						    <label for="upload"><span></span>업로드</label>
						    <input type="radio" name="inputMode" id="manual" value="manual" onchange="toggleInputMode(this.value)">
						    <label for="manual"><span></span>직접 입력</label>
						  </td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<div id="dynamicTableSection">
				<div class="title2 mt20"  style="width:100%; display: flex; justify-content: space-between;">
					<span class="txt">내용</span>
					<div style="display: flex; align-items: center; justify-content: flex-end; gap: 6px;">
					  <button class="btn_con_search" onclick="createColumn()">컬럼 추가</button>
					  <span style="color: #9a9a9a; padding: 0 10px;">|</span>
					  <button class="btn_con_search" onclick="createRow()">로우 추가</button>
					  <button class="btn_con_search" onclick="deleteRow()">로우 삭제</button>
					</div>
				</div>
				<div class="main_tbl">
					<table id="dynamicTable" class="tbl05 insert_proc01">
					  <colgroup>
					  	<col width="26px">
					  </colgroup>
					  <thead>
					    <tr id="columnHeaderRow">
					    </tr>
					  </thead>
					  <tbody id="columnBodyRows">
	
					  </tbody>
					</table>
				</div>
			</div>
			
			<div class="title2 mt20"  style="width:90%;"><span class="txt">파일첨부</span></div>
			<div class="list_detail">
				<ul style="">
					<li>
						<dt style="width: 20%">첨부파일</dt>
						<dd style="width: 80%;">
							<div class="add_file" id="add_file2" style="width:100%">
								<span id="upFile">
									<span class="file_load" id="fileSpan2" style="display: none;"><input type="file" name="files" id="file2" onchange="addFile(this, '00')" style="display:none"><label for="file2">첨부파일 등록 <img src="/resources/images/icon_add_file.png"></label></span>
									<span class="file_load" id="fileSpan3"><input type="file" name="files" id="file3" onchange="addFile(this, '00')" style="display:none"><label for="file3">첨부파일 등록 <img src="/resources/images/icon_add_file.png"></label></span>
								</span>
							</div>
							<div id="fileList" class="file_box_pop" style="height: 120px; width: 100%; border-top-left-radius: 0px; border-top-right-radius: 0px; border-top: 1px solid rgb(221, 221, 221); box-sizing: border-box;" ondrop="drop(event)" ondragover="allowDrop(event)" ondragend="drogEnd(event)" ondragleave="drogEnd(event)">
								<ul id="attatch_file">
								</ul>	
							</div>
						</dd>
					</li>
				</ul>
			</div>
			<!-- <div class="title2 mt20" style="width:10%; display: inline-block;">
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
			</div> -->
							
			<div class="main_tbl">
				<div class="btn_box_con5">
					<button class="btn_admin_gray" onClick="fn_goList();" style="width: 120px;">목록</button>
				</div>
				<div class="btn_box_con4">
					<!-- 
					<button class="btn_admin_red">임시/템플릿저장</button>
					<button class="btn_admin_navi">임시저장</button>
					 -->
					<button class="btn_admin_gray" onclick="fn_tmp_insert()">임시 저장</button>
					<button class="btn_admin_sky" onclick="fn_insert()">결재</button>
					<button class="btn_admin_gray" onclick="fn_goList()">취소</button>
				</div>
				<hr class="con_mode" />
			</div>
		</div>
	</section>
</div>

<table id="tmpTable" class="tbl05" style="display:none">
	<tbody id="tmpChangeTbody" name="tmpChangeTbody">
		<tr id="tmpChangeRow_1" class="temp_color">
			<td>
				<input type="checkbox" id="change_1"><label for="change_1"><span></span></label>
			</td>
			<td>
				<input type="text" name="itemDiv" style="width: 99%" class="req code_tbl"/>							
			</td>
			<td>
				<textarea style="width:95%; height:50px" placeholder="기존정보를 입력하세요." name="itemCurrent" id="itemCurrent" class="req code_tbl"></textarea>
			</td>
			<td>
				<textarea style="width:95%; height:50px" placeholder="변경정보를 입력하세요." name="itemChange" id="itemChange" class="req code_tbl"></textarea>
			</td>
			<td>
				<input type="text" name="itemNote" style="width: 99%" class="req code_tbl"/>
			</td>
		</tr>
	</tbody>
</table>

<!-- 결재 상신 레이어  start-->
<div class="white_content" id="approval_dialog">
	<input type="hidden" id="docType" value="RESULT"/>
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
			<span class="title">메뉴 품질 점검 결과 보고서 결재 상신</span>
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

<!-- 문서 검색 레이어 start-->
<div class="white_content" id="dialog_search">
	<div class="modal" style="	width: 700px;margin-left:-360px;height: 550px;margin-top:-300px;">
		<h5 style="position:relative">
			<span class="title">메뉴 품질 점검 결과 보고서 검색</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('dialog_search')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li>
					<dt>보고서검색</dt>
					<dd>
						<input type="text" value="" class="req" style="width:302px; float: left" name="searchValue" id="searchValue" placeholder="제목으로 검색하십시오."/>
						<button class="btn_small_search ml5" onclick="fn_search()" style="float: left">조회</button>
					</dd>
				</li>
			</ul>
		</div>
		<div class="main_tbl" style="height: 300px; overflow-y: auto">
			<table class="tbl07">
				<colgroup>
					<col width="40px">
					<col/>
					<col width="23%">
				</colgroup>
				<thead>
					<tr>
						<th></th>
						<th>제목</th>
						<th>시행월</th>
					<tr>
				</thead>
				<tbody id="productLayerBody">
					<tr>
						<td colspan="4">검색해주세요</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</div>
<!-- 문서 검색 레이어 close-->