<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>  <!-- ✅ 이거 추가 -->
<title>메뉴 품질 점검 결과 보고서</title>
<link href="../resources/css/mfg.css" rel="stylesheet" type="text/css">
<link href="../resources/css/common.css" rel="stylesheet" type="text/css">
<link href="../resources/css/tree.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/resources/editor/build/ckeditor.js"></script>
<script src="/resources/js/jquery.ui.monthpicker.js"></script>
<script type="text/javascript" src="/resources/js/appr/apprClass.js?v=<%= System.currentTimeMillis()%>"></script>
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
<script>
var _multiSelectCache = {
	column : []
}

$(document).ready(function(){
	// ✅ 강제로 최대화 상태로 설정
	stepchage('width_wrap', 'wrap_in02');
	setPersonalization('widthMode', 'wrap_in02');
	//history.replaceState({}, null, location.pathname);
	fn.autoComplete($("#keyword"));	
	
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
	
	$.ajax({
	    type: "POST",
	    url: "../common/codeListAjax",
	    data: { 'groupCode': 'COLUMN' },
	    dataType: "json",
	    success: function (data) {
	        _multiSelectCache.column = data.RESULT;
	        console.log(_multiSelectCache);
	        initDynamicTable();
	    },
	    error: function () {
	        alert(" 정보를 불러오는데 실패했습니다.");
	    }
	});
});
var resultItemList = [];
<c:forEach var="item" items="${itemList}">
    resultItemList.push({
        "ROW_NO": ${item.ROW_NO},
        "COLUMN_CODE": '${item.COLUMN_CODE}',
        "COLUMN_VALUE": '${item.COLUMN_VALUE}'
    });
</c:forEach>
var resultImageList = [];
<c:forEach var="img" items="${itemImageList}">
    resultImageList.push({
        "ROW_NO": ${img.ROW_NO},
        "FILE_PATH": '${img.FILE_PATH}',
        "ORG_FILE_NAME" : '${img.ORG_FILE_NAME}',
        "FILE_NAME": '${img.FILE_NAME}'
    });
</c:forEach>
function fn_apprSubmit(){
	if( $("#apprLine option").length == 0 ) {
		alert("등록된 결재라인이 없습니다. 결재 라인 추가 후 결재상신 해 주세요.");
		return;
	} else {
		//$("#apprLine").removeOption(/./); 
		//$("#refLine").removeOption(/./); 
		var apprTxtFull = "";
		$("#apprLine").selectedTexts().forEach(function( item, index ){
			console.log(item);
			if( apprTxtFull != "" ) {
				apprTxtFull += " > ";
			}
			apprTxtFull += item;
		});
		$("#apprTxtFull").val(apprTxtFull);
		//apprTxtFull
		//refTxtFull
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
function fn_update() {
    const resultItemArr = [];
    const itemImageArr = [];

    var title = document.getElementById("title").value.trim();
    var excuteDate = document.getElementById("excuteDate").value.trim();
    var idx = document.getElementById("idx").value;

    if (!chkNull(title)) {
        alert("제목을 입력해 주세요.");
        document.getElementById("title").focus();
        return;
    } else if (!chkNull(excuteDate)) {
        alert("시행월을 입력해 주세요.");
        document.getElementById("excuteDate").focus();
        return;
    } else if (document.querySelectorAll('#columnBodyRows tr').length === 0) {
        alert("내용 테이블에 최소 한 개의 행이 필요합니다.");
        return;
    } else if (attatchFileArr.length === 0 && $("#attatch_file li").length === 0) {
        alert("첨부파일을 등록해주세요.");
        return;
    }

    const columnSelects = document.querySelectorAll('#columnHeaderRow select');
    for (let select of columnSelects) {
        if (select.value === "") {
            alert("모든 컬럼의 항목을 선택해 주세요.");
            select.focus();
            return;
        }
    }

    var formData = new FormData();

    // ✅ 헤더 정보
    formData.append("idx", idx);
    formData.append("title", title);
    formData.append("excuteDate", excuteDate);

    // ✅ 첨부파일 (신규)
    for (var i = 0; i < attatchFileArr.length; i++) {
        formData.append("file", attatchFileArr[i]);
    }

    // ✅ 삭제된 첨부파일
    $('#deletedFileList option').each(function () {
        formData.append("deletedFileList", $(this).val());
    });

    // ✅ 컬럼 코드 순서
    const columnCodes = Array.from(columnSelects).map(function(select) {
        return select.value;
    });
    formData.append("columnStates", columnCodes.join(','));

    // ✅ 셀 데이터 수집
    const rows = document.querySelectorAll('#columnBodyRows tr');
    rows.forEach(function (row, rowIndex) {
        const rowItems = [];
        const cells = row.querySelectorAll('td');

        for (let colIndex = 1; colIndex < cells.length; colIndex++) {
            const td = cells[colIndex];
            const input = td.querySelector('input');
            const columnCode = columnCodes[colIndex - 1];
            if (!input) continue;

            if (input.type === "file") {
                const file = input.files[0];
                const img = td.querySelector("img#preview");
                const isEmptyPreview = img && img.src.includes("img_noimg3.png");

                if (file) {
                    // 🔄 새로 업로드된 이미지
                    formData.append("imageFiles", file);
                    itemImageArr.push({
                        rowNo: rowIndex,
                        columnCode: columnCode,
                        keepExisting: false
                    });
                } else {
                    // ✅ 기존 이미지 유지 여부 판단
                    itemImageArr.push({
                        rowNo: rowIndex,
                        columnCode: columnCode,
                        keepExisting: !isEmptyPreview
                    });
                }

                rowItems.push({
                    rowNo: rowIndex,
                    columnCode: columnCode,
                    columnValue: ""
                });
            } else {
                // 일반 텍스트 셀 처리
                rowItems.push({
                    rowNo: rowIndex,
                    columnCode: columnCode,
                    columnValue: input.value
                });
            }
        }

        resultItemArr.push(rowItems);
    });

    // ✅ 데이터 직렬화
    formData.append("resultItemArr", JSON.stringify(resultItemArr));
    formData.append("itemImageArr", JSON.stringify(itemImageArr));

    // ✅ 디버깅 로그
    console.log("🔄 [UPDATE] FormData Preview:");
    for (var pair of formData.entries()) {
        console.log(pair[0] + ":", pair[1]);
    }
    
    $('#lab_loading').show();
    $.ajax({
        type: "POST",
        url: "../newProductResult/updateNewProductResult",
        data: formData,
        processData: false,
        contentType: false,
        cache: false,
        dataType: "json",
        success: function (result) {
            if (result.RESULT === 'S' && result.IDX > 0) {
                if (document.getElementById("apprLine").options.length > 0) {
                    var apprFormData = new FormData();
                    apprFormData.append("docIdx", result.IDX);
                    apprFormData.append("apprComment", document.getElementById("apprComment").value);
                    apprFormData.append("apprLine", $("#apprLine").selectedValues());
                    apprFormData.append("refLine", $("#refLine").selectedValues());
                    apprFormData.append("title", title);
                    apprFormData.append("docType", 'RESULT');
                    apprFormData.append("status", "N");

                    $.ajax({
                        type: "POST",
                        url: "../approval/insertApprAjax",
                        dataType: "json",
                        data: apprFormData,
                        processData: false,
                        contentType: false,
                        cache: false,
                        success: function (data) {
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
                        error: function () {
                            alert("결재 요청 중 오류가 발생하였습니다.");
                            $('#lab_loading').hide();
                            fn_goList();
                        }
                    });
                } else {
                    alert("[" + title + "] 문서가 정상적으로 수정되었습니다.");
                    $('#lab_loading').hide();
                    fn_goList();
                }
            } else {
                alert("저장 중 오류가 발생하였습니다.\n" + result.MESSAGE);
                $('#lab_loading').hide();
            }
        },
        error: function () {
            alert("업데이트 요청 중 오류가 발생하였습니다.");
            $('#lab_loading').hide();
        }
    });
}


//////// 동적 테이블 함수 시작 /////////
function initDynamicTable() {
  const columnStateStr = document.getElementById("columnState").value; // ex: "1,2,4,3"
  if (!columnStateStr) return;

  const columnCodes = columnStateStr.split(',');
  const columnDefs = [];

  columnCodes.forEach(code => {
    const matched = (_multiSelectCache.column || []).find(col => col.itemCode === code);
    if (matched) {
      columnDefs.push({ code: matched.itemCode, name: matched.itemName });
    }
  });

  initUpdateColumns(columnDefs);

  const dataRows = buildRowData(columnDefs);
  initUpdateRows(dataRows, columnDefs);
}

function toggleAllRows(checkbox) {
  const checked = checkbox.checked;
  document.querySelectorAll('#columnBodyRows input[type="checkbox"]').forEach(cb => {
    cb.checked = checked;
  });
}
function fn_deleteImageFile(btn, event) {
  event.stopPropagation();
  const td = btn.closest("td");
  if (!td) return;

  const previewImg = td.querySelector("#preview");
  const fileInput = td.querySelector("input[type='file']");

  if (previewImg) {
    previewImg.src = "/resources/images/img_noimg3.png";
  }
  if (fileInput) {
    fileInput.value = "";
  }
}

function fn_fileDivClick(event) {
  const container = event.currentTarget;
  const fileInput = container.querySelector("input[type='file']");
  if (fileInput) {
    fileInput.click();
  }
}

function fn_changeImageFile(input) {
  const file = input.files[0];
  if (!file) return;

  const reader = new FileReader();
  reader.onload = function (e) {
    const td = input.closest("td");
    const previewImg = td.querySelector("#preview");
    if (previewImg) {
      previewImg.src = e.target.result;
    }
  };
  reader.readAsDataURL(file);
}

function buildRowData(columnDefs) {
	  const rowMap = {};

	  resultItemList.forEach(item => {
	    const rowKey = item.ROW_NO;
	    if (!rowMap[rowKey]) rowMap[rowKey] = {};
	    rowMap[rowKey][item.COLUMN_CODE] = item.COLUMN_VALUE;
	  });

	  // 이미지 컬럼 찾기
	  const imageColumn = columnDefs.find(col => col.name.includes("이미지"));
	  const imageColumnCode = imageColumn ? imageColumn.code : null;

	  if (imageColumnCode) {
	    resultImageList.forEach(item => {
	      const rowKey = item.ROW_NO;
	      if (!rowMap[rowKey]) rowMap[rowKey] = {};
	      const fullPath = '/images' + item.FILE_PATH + '/' + item.FILE_NAME;
	      rowMap[rowKey][imageColumnCode] = fullPath;
	    });
	  }

	  const sortedRowNos = Object.keys(rowMap).sort((a, b) => a - b);

	  // 👉 ROW_NO를 명시적으로 포함하여 반환
	  return sortedRowNos.map(rowNo => ({
	    ROW_NO: Number(rowNo),
	    ...rowMap[rowNo]
	  }));
	}


function initUpdateColumns(columns) {
  // 체크박스 칼럼 초기화
  const headerRow = document.getElementById('columnHeaderRow');
  headerRow.innerHTML = "";
  columnCount = 0;

  const checkboxTh = document.createElement('th');
  checkboxTh.innerHTML = '<div class="search_box"><input type="checkbox" id="toggleAll" onclick="toggleAllRows(this)"><label for="toggleAll"><span></span></label></div>';
  headerRow.appendChild(checkboxTh);

  columns.forEach((col, index) => {
    columnCount++;

    const th = document.createElement('th');
    th.dataset.colIndex = columnCount;

    const container = document.createElement('div');
    container.className = 'search_box';
    container.style.display = 'flex';
    container.style.justifyContent = 'center';
    container.style.alignItems = 'center';
    container.style.gap = '5px';

    // 셀렉트 박스
    const selectBox = document.createElement('div');
    selectBox.className = 'selectbox';

    const select = document.createElement('select');
    select.name = 'columnState_' + columnCount;
    select.style.opacity = '1';
    select.style.position = 'static';
    select.style.zIndex = 'auto';
    select.style.minWidth = '60px';
    select.style.maxWidth = '140px';
    select.style.width = 'auto';

    const defaultOption = document.createElement('option');
    defaultOption.value = '';
    defaultOption.textContent = '-- 선택 --';
    select.appendChild(defaultOption);

    // 실제 옵션들 추가
    (_multiSelectCache.column || []).forEach(opt => {
      const option = document.createElement('option');
      option.value = opt.itemCode;
      option.textContent = opt.itemName;
      if (opt.itemCode === col.code) option.selected = true;
      select.appendChild(option);
    });

    select.dataset.prevIndex = select.selectedIndex;
    select.onchange = function () {
      handleColumnSelectChange(this);
    };

    selectBox.appendChild(select);

    // 삭제 버튼, 이동 버튼
    const delBtn = document.createElement('button');
    delBtn.textContent = 'X';
    delBtn.type = 'button';
    delBtn.style.color = 'red';
    delBtn.style.background = 'transparent';
    delBtn.style.border = 'none';
    delBtn.style.cursor = 'pointer';
    delBtn.onclick = function () {
   	  if (!confirm("컬럼을 삭제하시겠습니까?\n입력하신 데이터는 모두 사라집니다.")) return;
      const idx = Array.from(headerRow.children).indexOf(th);
      th.remove();
      document.querySelectorAll('#columnBodyRows tr').forEach(row => {
        const tds = row.querySelectorAll('td');
        if (tds[idx]) tds[idx].remove();
      });
      columnCount--;
      refreshSelectOptions();
    };

    const leftBtn = document.createElement('button');
    leftBtn.innerHTML = '&lt;';
    leftBtn.type = 'button';
    leftBtn.className = 'btn_col_arrow';
    leftBtn.onclick = () => moveColumn(th, -1);

    const rightBtn = document.createElement('button');
    rightBtn.innerHTML = '&gt;';
    rightBtn.type = 'button';
    rightBtn.className = 'btn_col_arrow';
    rightBtn.onclick = () => moveColumn(th, 1);

    container.appendChild(leftBtn);
    container.appendChild(selectBox);
    container.appendChild(delBtn);
    container.appendChild(rightBtn);

    th.appendChild(container);
    headerRow.appendChild(th);
  });

  refreshSelectOptions();
}

function initUpdateRows(dataRows, columnDefs) {
	  const tbody = document.getElementById('columnBodyRows');
	  tbody.innerHTML = "";

	  dataRows.forEach((rowData, rowIndex) => {
	    const tr = document.createElement('tr');
	    const rowNo = rowData.ROW_NO;

	    const checkTd = document.createElement('td');
	    checkTd.innerHTML =
	      '<div class="search_box" style="display:flex;">' +
	      '<input type="checkbox" id="row_select_' + rowIndex + '" name="row_select_' + rowIndex + '">' +
	      '<label for="row_select_' + rowIndex + '"><span></span></label>' +
	      '</div>';
	    tr.appendChild(checkTd);

	    // 정확한 ROW_NO로 이미지 경로 매칭
	    const rowImageObj = resultImageList.find(img => Number(img.ROW_NO) === rowNo);
	    const imageSrc = (rowImageObj && rowImageObj.FILE_PATH && rowImageObj.FILE_NAME)
	      ? '/images' + rowImageObj.FILE_PATH + '/' + rowImageObj.FILE_NAME
	      : '/resources/images/img_noimg3.png';

	    columnDefs.forEach((col, colIndex) => {
	      const td = document.createElement('td');
	      const colCode = String(col.code);
	      const value = rowData[colCode] || "";

	      if (col.name.includes("이미지")) {
	        td.innerHTML =
	          '<div style="display: flex; flex-direction: column; align-items: center;">' +
	          '<div style="position: relative; width: 150px; height: 150px;">' +
	          '<div style="position: absolute; top: 4px; right: 4px;">' +
	          '<img src="/resources/images/btn_table_header01_del02.png" onclick="fn_deleteImageFile(this, event)" style="cursor: pointer;">' +
	          '</div>' +
	          '<img id="preview" src="' + imageSrc + '" style="width: 100%; height: 100%; border:1px solid #e1e1e1; border-radius:5px; object-fit: contain;">' +
	          '</div>' +
	          '<div class="add_file2" style="text-align:center; margin-top: 8px;" onclick="fn_fileDivClick(event)">' +
	          '<input type="file" name="cell_' + rowIndex + '_' + (colIndex + 1) + '" id="fileImageInput_' + rowIndex + '_' + (colIndex + 1) + '" accept="image/*" style="display:none;" onchange="fn_changeImageFile(this)">' +
	          '<label style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>' +
	          '</div>' +
	          '</div>';
	      } else {
	        td.innerHTML = '<input type="text" name="cell_' + rowIndex + '_' + (colIndex + 1) + '" style="width:100%;" value="' + value + '">';
	      }

	      tr.appendChild(td);
	    });

	    tbody.appendChild(tr);
	  });
	}

function refreshSelectOptions() {
	  const allSelects = document.querySelectorAll('#columnHeaderRow select');

	  allSelects.forEach(select => {
	    const currentValue = select.value;
	    select.innerHTML = '';

	    // 기본 옵션 추가
	    const defaultOption = document.createElement('option');
	    defaultOption.value = '';
	    defaultOption.textContent = '-- 선택 --';
	    select.appendChild(defaultOption);

	    // 전체 옵션 목록 다시 추가
	    (_multiSelectCache.column || []).forEach(option => {
	      const opt = document.createElement('option');
	      opt.value = option.itemCode;
	      opt.textContent = option.itemName;
	      select.appendChild(opt);
	    });

	    // 기존 선택값 복원
	    select.value = currentValue;
	    select.dataset.prevIndex = select.selectedIndex;
	  });
	}
//컬럼 이동 함수
function moveColumn(th, direction) {
  const headerRow = document.getElementById("columnHeaderRow");
  const currentIndex = Array.from(headerRow.children).indexOf(th);
  const newIndex = currentIndex + direction;

  if (newIndex < 1 || newIndex >= headerRow.children.length) return;

  const rows = document.querySelectorAll("#dynamicTable tr");
  rows.forEach(row => {
    const cells = Array.from(row.children);
    const target = cells[newIndex];
    const source = cells[currentIndex];
    if (direction === -1) {
      row.insertBefore(source, target);
    } else {
      row.insertBefore(target, source);
    }
  });
}
function handleColumnSelectChange(selectEl) {
	  const selectedCode = selectEl.value;
	  const selectedText = selectEl.options[selectEl.selectedIndex].textContent;

	  const selectedCodes = Array.from(document.querySelectorAll("#columnHeaderRow select"))
	    .filter(sel => sel !== selectEl)
	    .map(sel => sel.value);

	  if (selectedCodes.includes(selectedCode)) {
	    alert("이미 선택된 항목입니다.");
	    selectEl.selectedIndex = selectEl.dataset.prevIndex;
	    return;
	  }

	  if (selectedText.includes("이미지")) {
	    const hasImageColumn = Array.from(document.querySelectorAll("#columnHeaderRow select"))
	      .filter(sel => sel !== selectEl)
	      .some(sel => sel.options[sel.selectedIndex].textContent.includes("이미지"));

	    if (hasImageColumn) {
	      alert("이미지 항목은 하나만 선택할 수 있습니다.");
	      selectEl.selectedIndex = selectEl.dataset.prevIndex;
	      return;
	    }
	  }

	  if (selectEl.selectedIndex !== Number(selectEl.dataset.prevIndex)) {
	    const confirmChange = confirm("컬럼을 변경하면 해당 컬럼에 대한 정보가 사라집니다.\n계속하시겠습니까?");
	    if (!confirmChange) {
	      selectEl.selectedIndex = selectEl.dataset.prevIndex;
	      return;
	    }

	    // ✅ 변경 전 테이블에서 현재 입력값 추출
	    const oldTableData = [];
	    const rows = document.querySelectorAll('#columnBodyRows tr');
	    rows.forEach(function (tr, rowIndex) {
	      const rowData = { ROW_NO: rowIndex };
	      const cells = tr.querySelectorAll('td');

	      // 컬럼별로 1번 td부터 시작
	      for (let colIndex = 1; colIndex < cells.length; colIndex++) {
	        const input = cells[colIndex].querySelector('input');
	        const sel = document.querySelectorAll("#columnHeaderRow select")[colIndex - 1];
	        const code = sel ? sel.value : "";

	        if (!input || !code) continue;

	        if (input.type === "file") {
	        	  if (input.files.length > 0) {
	        	    alert("이미지 파일은 보안상 자동 복원되지 않습니다.\n컬럼 변경 시 다시 선택해 주세요.");
	        	  }

	        	  // 항상 빈 값으로라도 넣어줘야 테이블 형식이 깨지지 않음
	        	  rowData[code] = ""; 
	        	} else {
	        	  rowData[code] = input.value;
	        	}
	      }
	      
	      oldTableData.push(rowData);
	    });

	    // ✅ 컬럼 리스트 새로 생성
	    const columns = Array.from(document.querySelectorAll("#columnHeaderRow select")).map(function(sel) {
	      return {
	        code: sel.value,
	        name: sel.options[sel.selectedIndex].textContent
	      };
	    });

	    // ✅ 컬럼 재구성
	    initUpdateRows(oldTableData, columns); // buildRowData 없이 기존 데이터 그대로 사용
	  }

	  selectEl.dataset.prevIndex = selectEl.selectedIndex;
	}
//컬럼 추가 함수
function createColumn() {
	const columnOptions = _multiSelectCache.column || [];

	  // 전체 select 수로 현재 생성된 컬럼 개수 파악
	  const totalColumnSelects = document.querySelectorAll('#columnHeaderRow select').length;

	  // ✅ 전체 코드 수 이상이면 제한
	  if (totalColumnSelects >= columnOptions.length) {
	    alert("더 이상 추가할 수 있는 컬럼이 없습니다.");
	    return;
	  }

	  // 최대 8개 제한도 병행
	  if (totalColumnSelects >= 8) {
	    alert("최대 8개의 컬럼까지만 추가할 수 있습니다.");
	    return;
	  }

	  // 이미 선택된 코드만 필터링
	  const selectedCodes = Array.from(document.querySelectorAll('#columnHeaderRow select'))
	    .map(select => select.value)
	    .filter(code => code !== "");

	  const unusedOptions = columnOptions.filter(opt => !selectedCodes.includes(opt.itemCode));

	  if (unusedOptions.length === 0) {
	    alert("더 이상 추가할 수 있는 컬럼이 없습니다.");
	    return;
	  }

	  const newColumn = { itemCode: '', itemName: '-- 선택 --' };

	  // 헤더 추가
	  const headerRow = document.getElementById("columnHeaderRow");
	  const th = document.createElement("th");
	  th.dataset.colIndex = ++columnCount;

	  const container = document.createElement("div");
	  container.className = "search_box";
	  container.style.display = "flex";
	  container.style.alignItems = "center";
	  container.style.justifyContent = "center";
	  container.style.gap = "5px";

	  // 이동 버튼
	  const leftBtn = document.createElement("button");
	  leftBtn.innerHTML = "&lt;";
	  leftBtn.type = "button";
	  leftBtn.className = "btn_col_arrow";
	  leftBtn.onclick = () => moveColumn(th, -1);

	  const rightBtn = document.createElement("button");
	  rightBtn.innerHTML = "&gt;";
	  rightBtn.type = "button";
	  rightBtn.className = "btn_col_arrow";
	  rightBtn.onclick = () => moveColumn(th, 1);

	  // 삭제 버튼
	  const delBtn = document.createElement("button");
	  delBtn.textContent = "X";
	  delBtn.type = "button";
	  delBtn.style.color = "red";
	  delBtn.style.background = "transparent";
	  delBtn.style.border = "none";
	  delBtn.style.cursor = "pointer";
	  delBtn.onclick = function () {
	    deleteColumn(th);
	  };

	  // select box
	  const selectBox = document.createElement("div");
	  selectBox.className = "selectbox";

	  const select = document.createElement("select");
	    select.name = 'columnState_' + columnCount;
	    select.style.opacity = '1';
	    select.style.position = 'static';
	    select.style.zIndex = 'auto';
	    select.style.minWidth = '60px';
	    select.style.maxWidth = '140px';
	    select.style.width = 'auto';


	  const defaultOption = document.createElement("option");
	  defaultOption.value = "";
	  defaultOption.textContent = "-- 선택 --";
	  select.appendChild(defaultOption);

	  _multiSelectCache.column.forEach(opt => {
	    const option = document.createElement("option");
	    option.value = opt.itemCode;
	    option.textContent = opt.itemName;
	    select.appendChild(option);
	  });

	  select.dataset.prevIndex = select.selectedIndex;
	  select.onchange = function () {
	    handleColumnSelectChange(this);
	  };

	  selectBox.appendChild(select);

	  container.appendChild(leftBtn);
	  container.appendChild(selectBox);
	  container.appendChild(delBtn);
	  container.appendChild(rightBtn);

	  th.appendChild(container);
	  headerRow.appendChild(th);

	  // 모든 row에 새 td 추가
	  const tbody = document.getElementById("columnBodyRows");
	  Array.from(tbody.children).forEach((tr, rowIndex) => {
	    const td = document.createElement("td");
	    if (newColumn.itemName.includes("이미지")) {
	      td.innerHTML =
	        '<div style="display: flex; flex-direction: column; align-items: center;">' +
	        '<div style="position: relative; width: 150px; height: 150px;">' +
	        '<div style="position: absolute; top: 4px; right: 4px;">' +
	        '<img src="/resources/images/btn_table_header01_del02.png" onclick="fn_deleteImageFile(this, event)" style="cursor: pointer;">' +
	        '</div>' +
	        '<img id="preview" src="/resources/images/img_noimg3.png" style="width: 100%; height: 100%; border:1px solid #e1e1e1; border-radius:5px; object-fit: contain;">' +
	        '</div>' +
	        '<div class="add_file2" style="text-align:center; margin-top: 8px;" onclick="fn_fileDivClick(event)">' +
	        '<input type="file" name="cell_' + rowIndex + '_' + columnCount + '" id="fileImageInput_' + rowIndex + '_' + columnCount + '" accept="image/*" style="display:none;" onchange="fn_changeImageFile(this)">' +
	        '<label style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>' +
	        '</div>' +
	        '</div>';
	    } else {
	      td.innerHTML = '<input type="text" name="cell_' + rowIndex + '_' + columnCount + '" style="width:100%;">';
	    }
	    tr.appendChild(td);
	  });

	  refreshSelectOptions();
	}

//로우 추가 함수 (이미지 포함 컬럼 대응)
function createRow() {
  const tbody = document.getElementById("columnBodyRows");
  const newRow = document.createElement("tr");
  const rowIndex = tbody.children.length;

  if (rowIndex >= 20) {
    alert("최대 20개의 행까지만 추가할 수 있습니다.");
    return;
  }
  
  const checkTd = document.createElement('td');
  checkTd.innerHTML =
    '<div class="search_box" style="display:flex;">' +
    '<input type="checkbox" id="row_select_' + rowIndex + '" name="row_select_' + rowIndex + '">' +
    '<label for="row_select_' + rowIndex + '"><span></span></label>' +
    '</div>';
  newRow.appendChild(checkTd);

  const selects = document.querySelectorAll("#columnHeaderRow select");
  selects.forEach((select, i) => {
    const td = document.createElement('td');
    const selectedOptionText = select.options[select.selectedIndex].textContent;

    if (selectedOptionText.includes("이미지")) {
      td.innerHTML =
        '<div style="display: flex; flex-direction: column; align-items: center;">' +
        '<div style="position: relative; width: 150px; height: 150px;">' +
        '<div style="position: absolute; top: 4px; right: 4px;">' +
        '<img src="/resources/images/btn_table_header01_del02.png" onclick="fn_deleteImageFile(this, event)" style="cursor: pointer;">' +
        '</div>' +
        '<img id="preview" src="/resources/images/img_noimg3.png" style="width: 100%; height: 100%; border:1px solid #e1e1e1; border-radius:5px; object-fit: contain;">' +
        '</div>' +
        '<div class="add_file2" style="text-align:center; margin-top: 8px;" onclick="fn_fileDivClick(event)">' +
        '<input type="file" name="cell_' + rowIndex + '_' + (i + 1) + '" id="fileImageInput_' + rowIndex + '_' + (i + 1) + '" accept="image/*" style="display:none;" onchange="fn_changeImageFile(this)">' +
        '<label style="cursor: pointer;">이미지파일 등록 <img src="/resources/images/icon_add_file.png"></label>' +
        '</div>' +
        '</div>';
    } else {
      td.innerHTML = '<input type="text" name="cell_' + rowIndex + '_' + (i + 1) + '" style="width:100%;">';
    }
    newRow.appendChild(td);
  });

  tbody.appendChild(newRow);
}
//로우 삭제 함수
function deleteRow() {
  const tbody = document.getElementById("columnBodyRows");
  const checkboxes = tbody.querySelectorAll("input[type=checkbox]:checked");
  checkboxes.forEach(checkbox => {
    const tr = checkbox.closest("tr");
    if (tr) tr.remove();
  });
}
function deleteColumn(th) {
	  if (!confirm("컬럼을 삭제하시겠습니까?\n입력하신 데이터는 모두 사라집니다.")) return;

	  const headerRow = document.getElementById("columnHeaderRow");
	  const idx = Array.from(headerRow.children).indexOf(th);
	  
	  // 헤더 제거
	  th.remove();

	  // 본문 각 row에서 해당 컬럼(td) 제거
	  document.querySelectorAll('#columnBodyRows tr').forEach(row => {
	    const tds = row.querySelectorAll('td');
	    if (tds[idx]) tds[idx].remove();
	  });

	  columnCount--;
	  refreshSelectOptions();
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

function removeTempFile(fileIdx, element) {
    // li 삭제
    $(element).closest('li').remove();

    // select에 삭제 파일 IDX 추가
    $('#deletedFileList').append(
        $('<option>', {
            value: fileIdx,
            selected: true
        })
    );
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

function fn_goList() {
	location.href = '/newProductResult/list';
}
</script>
<div class="wrap_in">
    <span class="path">
        메뉴 품질 점검 결과 보고서&nbsp;&nbsp;
        <img src="/resources/images/icon_path.png" style="vertical-align: middle" />&nbsp;&nbsp;수정
    </span>
    <section class="type01">
        <h2>
            <span class="title_s">Menu Quality Test Report</span>
            <span class="title">메뉴 품질 점검 결과 보고서 수정</span>
        </h2>

        <!-- ✅ 기본 정보 -->
        <input type="hidden" id="idx" name="idx" value="${newProductResultData.data.RESULT_IDX}">
        <div class="group01 mt20">
            <div class="title2"><span class="txt">기본정보</span></div>
            <div class="main_tbl">
                <table class="insert_proc01">
                    <colgroup>
                        <col width="20%">
                        <col width="80%">
                    </colgroup>
                    <tbody>
                        <tr>
                            <th style="border-left: none;">제목</th>
                            <td><input type="text" id="title" name="title" style="width: 90%;" value="${newProductResultData.data.TITLE}"></td>
                        </tr>
                        <tr>
                            <th style="border-left: none;">시행월</th>
                            <td><input type="text" id="excuteDate" name="excuteDate" value="${newProductResultData.data.EXCUTE_DATE}" style="width: 170px;" readonly></td>
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
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ✅ 동적 컬럼/행 테이블 -->
        <input type="hidden" id="columnState" value="${newProductResultData.data.COLUMN_STATE}">
        <div class="group01 mt10">
            <div class="title2" style="width:100%; display:flex; justify-content:space-between;">
                <span class="txt">내용</span>
                <div>
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
                        <tr id="columnHeaderRow"></tr>
                    </thead>
                    <tbody id="columnBodyRows"></tbody>
                </table>
            </div>
        </div>
		
        <!-- ✅ 첨부파일 영역 -->
        <div class="group01 mt10">
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
			<c:if test="${not empty newProductResultData.fileList}">
			<div class="con_file" style="">
				<ul>
					<li class="point_img">
						<dt>기존파일</dt><dd>
							<ul id="attatch_file">
					              <c:forEach var="file" items="${newProductResultData.fileList}">
					              <li data-file-idx="${file.FILE_IDX}">
					                <a href="${file.FILE_PATH}" onclick="removeTempFile('${file.FILE_IDX}', this); return false;">
					                  <img src="/resources/images/icon_del_file.png">
					                </a>&nbsp;${file.ORG_FILE_NAME}
					              </li>
					            </c:forEach>
							</ul>
						</dd>
					</li>
				</ul>
			</div>
		    <!-- 숨겨진 select 박스 -->
			<select name="deletedFileList" id="deletedFileList" multiple style="display: none;"></select>
			</c:if>
        </div>


        <!-- ✅ 버튼 -->
        <div class="main_tbl" style="margin:40px;">
            <div class="btn_box_con5">
                <button class="btn_admin_gray" onclick="fn_goList();" style="width: 120px;">목록</button>
            </div>
            <div class="btn_box_con4">
                <button class="btn_admin_sky" onclick="fn_update()">저장</button>
                <button class="btn_admin_gray" onclick="fn_goList()">취소</button>
            </div>
            <hr class="con_mode" />
        </div>
    </section>
</div>


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