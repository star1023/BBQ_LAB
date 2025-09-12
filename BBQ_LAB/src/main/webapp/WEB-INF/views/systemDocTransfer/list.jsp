<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>문서 이관</title>
<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}

.search_box ul li {
	display: inline-block;
	width: auto;
}

.mainTable {
	border : 1px solid #ccc;
}

/* 각 행 전역 설정: 배지 자리 확보 + 기준점 지정 */
#jsTree1 li.jstree-node,
#jsTree2 li.jstree-node {
  position: relative;
  padding-right: 10px;          /* 배지 공간 (필요시 조절) */
  border-bottom: 1px solid #eee;/* 행 구분선 */
}

/* 폴더(1레벨)도 구분선 유지하고 싶지 않으면 아래처럼 약하게: */
/*
#jsTree1 li.jstree-node > a.jstree-anchor.jstree-clicked { background: #f9fafb; }
#jsTree1 > ul > li.jstree-node { border-color: #f3f4f6; }
*/

/* 상태 배지: li의 data-status를 사용해 오른쪽에 뱃지 렌더 */
#jsTree1 li.has-status::after,
#jsTree2 li.has-status::after {
  content: attr(data-status);
  position: absolute;
  right: 12px;                  /* 컨테이너 오른쪽 여백 */
  top: 50%;
  transform: translateY(-50%);
  padding: 3px 8px;
  font-size: 12px;
  line-height: 1;
  border-radius: 9999px;
  border: 1px solid transparent;
  white-space: nowrap;          /* 줄바꿈 방지 */
}

/* 상태별 색상 */
#jsTree1 li.status-draft::after,      #jsTree2 li.status-draft::after      { background:#9ca3af; color:#fff; border-color:#9ca3af; } /* 임시저장 */
#jsTree1 li.status-registered::after, #jsTree2 li.status-registered::after { background:#3b82f6; color:#fff; border-color:#3b82f6; } /* 등록 */
#jsTree1 li.status-approving::after,  #jsTree2 li.status-approving::after  { background:#f59e0b; color:#111; border-color:#f59e0b; } /* 결재중 */
#jsTree1 li.status-rejected::after,   #jsTree2 li.status-rejected::after   { background:#dc2626; color:#fff; border-color:#dc2626; } /* 반려 */
#jsTree1 li.status-done::after,       #jsTree2 li.status-done::after       { background:#16a34a; color:#fff; border-color:#16a34a; } /* 완료 */
#jsTree1 li.status-partial::after,    #jsTree2 li.status-partial::after    { background:#8b5cf6; color:#fff; border-color:#8b5cf6; } /* 부분승인 */
#jsTree1 li.status-erpdone::after,    #jsTree2 li.status-erpdone::after    { background:#0ea5e9; color:#fff; border-color:#0ea5e9; } /* ERP반영완료 */
#jsTree1 li.status-other::after,      #jsTree2 li.status-other::after      { background:#6b7280; color:#fff; border-color:#6b7280; } /* 기타 */

/* 기본: 배경 초기화 */
#jsTree1 .jstree-wholerow,
#jsTree2 .jstree-wholerow { background: transparent !important; }

/* 1레벨(카테고리/헤더) */
#jsTree1 > ul > li > .jstree-wholerow,
#jsTree2 > ul > li > .jstree-wholerow {
  background: #f8fafc !important;   /* 더 밝게 */
}

/* 2레벨(아이템/문서) */
#jsTree1 > ul > li ul > li > .jstree-wholerow,
#jsTree2 > ul > li ul > li > .jstree-wholerow {
  background: #f1f5f9 !important;   /* 살짝 더 어둡게 */
}

/* 행 호버/선택 시 가독성 유지 */
#jsTree1 .jstree-wholerow-hovered,
#jsTree2 .jstree-wholerow-hovered { background: #e5e7eb !important; }  /* hover */
#jsTree1 .jstree-wholerow-clicked,
#jsTree2 .jstree-wholerow-clicked { background: #dbeafe !important; }  /* selected */

/* 이미 넣어둔 구분선/배지 유지 (필요시 색만 조절) */
#jsTree1 li.jstree-node,
#jsTree2 li.jstree-node { border-bottom: 1px solid #eee; padding-right: 10px; }

/* 공통 버튼 */
.transfer-btn{
  width:32px; height:32px;
  border-radius:6px;
  border: 1px solid #ccc;
  font-size: 22px;
  color:#666;
  cursor:pointer;
}

/* hover / active */
.transfer-btn:hover{
  background:#f7f7f7;
  border-color:#bdbdbd;
  color:#555;
}
.transfer-btn:active{
  background:#ededed;
  border-color:#a9a9a9;
  color:#111;
}
</style>

<script type="text/javascript" src="../resources/js/jstree.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
		fn_loadTeam1();
		fn_loadTeam2();
		
	    // 왼쪽 담당자 선택 → 문서 조회 → 트리 렌더
	    $(document).on('change', '#searchUser1', function(){
	      const userId = ($("#searchUser1").selectedValues ? $("#searchUser1").selectedValues()[0] : $("#searchUser1").val()) || "";
	      if (userId) {
	        fetchUserDocs(userId);              // 문서 조회 + 트리 렌더
	        $('#sourceUserId').val(userId);     // (선택) 소스 사용자 hidden 보관
	      } else {
	        fn_createJSTree1([]);               // 선택 해제 시 트리 비우기
	        $('#sourceUserId').val('');
	      }
	    });
	    
	    /* 버튼에 이벤트 연결 */
	    $(document).on("click", ".to-right", moveSelectedRight);
	    $(document).on("click", ".to-left",  moveSelectedLeft);

	    /* 페이지 진입 시 오른쪽 트리 빈 상태로 한 번 렌더(선택사항) */
	    $(function(){
	      rebuildRightTree();
	    });
	    
		/* 포커스 시 현재 값을 저장해 둔다 (취소 시 복구용) */
		$(document).on('focus', '#searchTeam1', function(){
		  prevTeam1 = getSelectedOne('#searchTeam1') || "";
		});
		$(document).on('focus', '#searchUser1', function(){
		  prevUser1 = getSelectedOne('#searchUser1') || "";
		});

		/* 왼쪽 팀 변경 */
		$(document).off('change', '#searchTeam1');
		$(document).on('change', '#searchTeam1', function(){
		  // 오른쪽에 이미 담긴 문서가 있으면 경고
		  if (rightDocs.length > 0) {
		    if (!confirm("보내는 팀/담당자를 변경하면 오른쪽 선택이 초기화됩니다.\n계속할까요?")) {
		      // 취소 → 원래 값 복구
		      setSelectValue('#searchTeam1', prevTeam1);
		      return;
		    }
		    resetRightTree(); // 오른쪽 초기화
		  }

		  // 팀이 바뀌면 담당자 목록 재로딩 + 선택 초기화
		  fn_loadUser1();
		  setSelectValue('#searchUser1', "");
		  // 왼쪽 문서 트리는 담당자 선택 후 fetchUserDocs에서 다시 그림
		  fn_createJSTree1([]); // 팀만 바꿨고 담당자 미선택이면 좌측 비움
		});

		/* 왼쪽 담당자 변경 */
		$(document).off('change', '#searchUser1');
		$(document).on('change', '#searchUser1', function(){
		  var userId = getSelectedOne('#searchUser1') || "";
		  if (rightDocs.length > 0) {
		    if (!confirm("보내는 팀/담당자를 변경하면 오른쪽 선택이 초기화됩니다.\n계속할까요?")) {
		      // 취소 → 원래 값 복구
		      setSelectValue('#searchUser1', prevUser1);
		      return;
		    }
		    resetRightTree(); // 오른쪽 초기화
		  }
		  if (userId) {
		    fetchUserDocs(userId);      // 좌측 트리 재조회
		    $('#sourceUserId').val(userId);
		  } else {
		    fn_createJSTree1([]);       // 담당자 비우면 좌측 트리 비움
		    $('#sourceUserId').val('');
		  }
		});
	});

	function fn_loadTeam1() {
		var URL = "../common/teamListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"pTeamId" : "10000713"
			},
			dataType:"json",
			async:false,
			success:function(data) {
				var list = data;
				$("#searchTeam1").removeOption(/./);
				$("#searchTeam1").addOption("", "선택", false);
				$("#searchTeam_label1").html("선택");
				$.each(list, function( index, value ){ //배열-> index, value
					$("#searchTeam1").addOption(value.TEAM_ID, value.TEAM_NAME, false);
				});
			},
			error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	}
	
	function fn_loadTeam2() {
		var URL = "../common/teamListAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"pTeamId" : "10000713"
			},
			dataType:"json",
			async:false,
			success:function(data) {
				var list = data;
				$("#searchTeam2").removeOption(/./);
				$("#searchTeam2").addOption("", "선택", false);
				$("#searchTeam_label2").html("선택");
				$.each(list, function( index, value ){ //배열-> index, value
					$("#searchTeam2").addOption(value.TEAM_ID, value.TEAM_NAME, false);
				});
			},
			error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	}
	
	function fn_loadUser1() {
		  const teamVal = $("#searchTeam1").selectedValues()[0];
		  if (teamVal) {
		    $.ajax({
		      type: "POST",
		      url: "../common/userListAjax",
		      data: { "teamId": teamVal },
		      dataType: "json",
		      async: false,
		      success: function(data) {
		        $("#searchUser1").removeOption(/./);
		        $("#searchUser1").addOption("", "전체", false);
		        $("#searchUser_label1").html("전체");
		        $.each(data, function(index, value) {
		          $("#searchUser1").addOption(value.USER_ID, value.USER_NAME + "(" + value.RESP_TXT + ")", false);
		        });
		        // 담당자 박스 보이기
		        $("#searchUser_li1").show();
		      },
		      error: function() {
		        alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		      }
		    });
		  } else {
		    // 팀이 비어 있으면 담당자 숨기고 초기화
		    $("#searchUser1").removeOption(/./);
		    $("#searchUser1").addOption("", "전체", false);
		    $("#searchUser_label1").html("전체");
		    $("#searchUser_li1").hide();
		  }
		}

		function fn_loadUser2() {
		  const teamVal = $("#searchTeam2").selectedValues()[0];
		  if (teamVal) {
		    $.ajax({
		      type: "POST",
		      url: "../common/userListAjax",
		      data: { "teamId": teamVal },
		      dataType: "json",
		      async: false,
		      success: function(data) {
		        $("#searchUser2").removeOption(/./);
		        $("#searchUser2").addOption("", "전체", false);
		        $("#searchUser_label2").html("전체");
		        $.each(data, function(index, value) {
		          $("#searchUser2").addOption(value.USER_ID, value.USER_NAME + "(" + value.RESP_TXT + ")", false);
		        });
		        $("#searchUser_li2").show();
		      },
		      error: function() {
		        alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		      }
		    });
		  } else {
		    $("#searchUser2").removeOption(/./);
		    $("#searchUser2").addOption("", "전체", false);
		    $("#searchUser_label2").html("전체");
		    $("#searchUser_li2").hide();
		  }
		}

		function fetchUserDocs(userId) {
		  $.ajax({
		    type: "POST",
		    url: "../systemDocTransfer/selectUserDocsAjax", // 컨트롤러 URL에 맞게 수정
		    data: { userId: userId },
		    dataType: "json",
		    success: function(res) {
	    	  var docs = res.docs || [];
	    	  var adapted = docs.map(function(d){
	    	    return {
	    	      docId: d.IDX,
	    	      title: d.TITLE,
	    	      typeCode: d.DOC_TYPE,
	    	      typeName: d.TYPE_NAME,
	    	      docNo: d.DOC_NO || "",        // [null] -> 빈문자열로
	    	      statusText: d.STATUS_TXT || "" // 상태 표시 필요시 사용
	    	    };
	    	  });

	    	  // 제목에 상태를 붙이고 싶으면 아래처럼:
	    	  // adapted.forEach(a => a.title = a.title + (a.statusText ? ' ['+a.statusText+']' : ''));

	    	  var data = buildTreeDataFromDocs(adapted);
	    	  fn_createJSTree1(data);
	    	},
		    error: function() {
		      alert("문서 조회 중 오류가 발생했습니다.\n다시 시도해주세요.");
		      fn_createJSTree1([]);
		    }
		  });
		}

		function buildTreeDataFromDocs(docs) {
		  function safeStr(v){ return (v==null ? "" : String(v)); }
		  function typeId(code){ return "type_" + code; }
		  function docNodeId(type, id){ return "doc_" + type + "_" + id; }

		  var statusClassMap = {
		    "임시저장":"draft", "등록":"registered", "결재중":"approving",
		    "반려":"rejected", "완료":"done", "부분승인":"partial", "ERP반영완료":"erpdone"
		  };

		  var data = [], typeMap = {};
		  (docs || []).forEach(function(d){
		    var tCode = safeStr(d.typeCode || "UNKNOWN");
		    var tName = safeStr(d.typeName || tCode);

		    if (!typeMap[tCode]) {
		      var tid = typeId(tCode);
		      typeMap[tCode] = tid;
		      data.push({
		        id: tid, parent: "#", text: tName,
		        icon: "fa fa-folder", state: { opened: true },
		        li_attr: { "data-type": tCode }
		      });
		    }

		    var status = safeStr(d.statusText || "");
		    var statusCls = status ? ("has-status status-" + (statusClassMap[status] || "other")) : "";

		    data.push({
		      id: docNodeId(tCode, d.docId),
		      parent: typeMap[tCode],
		      text: d.title || d.docName || ("DOC-" + d.docId),
		      icon: "fa fa-file",
		      li_attr: {
		        "data-docid": d.docId,
		        "data-docno": safeStr(d.docNo || ""),
		        "data-type": tCode,
		        "data-status": status,
		        "class": status ? statusCls : ""
		      }
		      // a_attr 안 써도 됨 (이제 li에서 렌더링)
		    });
		  });
		  return data;
		}

		function fn_createJSTree1(data) {
		  var treeId = "#jsTree1";
		  if ($.jstree.reference(treeId)) {
		    $(treeId).jstree("destroy");
		  }

		  // 1레벨 정렬 우선순위
		  var order = {
		    "PROD": 1,   // 제품완료보고서
		    "MENU": 2,   // 메뉴완료보고서
		    "DESIGN": 3, // 상품설계변경보고서
		    "REPORT": 4, // 관능/품질평가보고서
		    "PLAN": 5,   // 출장계획보고서
		    "TRIP": 6,   // 출장결과보고서
		    "RESEARCH": 7, // 시장조사결과보고서
		    "RESULT": 8, // 메뉴품질점검결과보고서
		    "CHEMICAL": 9, // 이화학검사의뢰서
		    "PACKAGE": 10, // 표시사항기재양식
		    "RECIPE": 11,  // 사전원가서
		    "NOTICE": 12   // 공지사항
		  };

		  $(treeId).jstree({
		    core: { data: data, check_callback: true, multiple: true },
		    checkbox: {
		    	keep_selected_style: false,
		        three_state: true,      // 부모/자식 상태 연동
		        whole_node: true,       // 행(라벨) 클릭 시 체크 토글
		        cascade: "up+down"      // 부모→자식, 자식→부모 모두 전파
		        // 만약 "부모만 클릭하면 자식 체크, 자식 클릭시 부모 영향 X" 원하면 "down" 으로
		    },
		    sort: function(a, b) {
		      var na = this.get_node(a), nb = this.get_node(b);

		      // 루트(1레벨)끼리는 지정 순서대로
		      if (na.parent === "#" && nb.parent === "#") {
		        var ta = (na.li_attr && na.li_attr["data-type"]) || "";
		        var tb = (nb.li_attr && nb.li_attr["data-type"]) || "";
		        var wa = order[ta] || 999, wb = order[tb] || 999;
		        if (wa !== wb) return wa - wb;
		        return na.text.localeCompare(nb.text, "ko");
		      }

		      // 같은 부모 밑(=2레벨)은 IDX(=data-docid) 숫자 오름차순
		      if (na.parent === nb.parent && na.parent !== "#") {
		        var ia = parseInt((na.li_attr && na.li_attr["data-docid"]) || "", 10);
		        var ib = parseInt((nb.li_attr && nb.li_attr["data-docid"]) || "", 10);
		        if (!isNaN(ia) && !isNaN(ib) && ia !== ib) return ia - ib;
		        // 숫자 없거나 같으면 텍스트로 보조 정렬
		        return na.text.localeCompare(nb.text, "ko");
		      }

		      // 그 외 기본
		      return na.text.localeCompare(nb.text, "ko");
		    },
		    plugins: ["wholerow", "checkbox", "contextmenu", "sort"]
		  }).on("loaded.jstree", function(){
		    $(this).jstree("open_all");
		  });
		}

		/* =========================
		   전역 전송 목록(오른쪽 트리 데이터)
		   ========================= */
		var rightDocs = [];           // {docId, title, typeCode, typeName, docNo, statusText} 배열
		var rightDocMap = {};         // dedup용 키맵: typeCode|docId => true

		function makeKey(d){ return (d.typeCode || "UNKNOWN") + "|" + d.docId; }

		/* 왼쪽 jsTree에서 체크된 문서(리프) → doc 객체로 변환 */
		function collectCheckedDocsFromLeft() {
		  var inst = $("#jsTree1").jstree(true);
		  if (!inst) return [];

		  // 리프(문서)만 수집: 부모 폴더 체크도 자동으로 자식이 포함됨
		  var nodes = inst.get_bottom_checked(true) || [];
		  var out = [];

		  for (var i=0; i<nodes.length; i++) {
		    var n = nodes[i];
		    var docId = n.li_attr && n.li_attr["data-docid"];
		    if (!docId) continue; // 폴더는 skip

		    var parent = inst.get_node(n.parent);
		    var typeCode = (n.li_attr && n.li_attr["data-type"]) ||
		                   (parent && parent.li_attr && parent.li_attr["data-type"]) || "UNKNOWN";
		    var typeName = parent ? parent.text : typeCode;

		    out.push({
		      docId: docId,
		      title: n.text,
		      typeCode: typeCode,
		      typeName: typeName,
		      docNo: (n.li_attr && n.li_attr["data-docno"]) || "",
		      statusText: (n.li_attr && n.li_attr["data-status"]) || ""
		    });
		  }
		  return out;
		}

		/* 오른쪽 jsTree에서 체크된 문서(리프) → key 목록 */
		function collectCheckedKeysFromRight() {
		  var inst = $("#jsTree2").jstree(true);
		  if (!inst) return [];

		  var nodes = inst.get_bottom_checked(true) || [];
		  var keys = [];

		  for (var i=0; i<nodes.length; i++) {
		    var n = nodes[i];
		    var docId = n.li_attr && n.li_attr["data-docid"];
		    if (!docId) continue;

		    var parent = inst.get_node(n.parent);
		    var typeCode = (n.li_attr && n.li_attr["data-type"]) ||
		                   (parent && parent.li_attr && parent.li_attr["data-type"]) || "UNKNOWN";

		    keys.push(typeCode + "|" + docId);
		  }
		  return keys;
		}

		/* 오른쪽 트리 그리기 */
		function fn_createJSTree2(data) {
		  var treeId = "#jsTree2";
		  if ($.jstree.reference(treeId)) {
		    $(treeId).jstree("destroy");
		  }

		  var order = {
		    "PROD":1,"MENU":2,"DESIGN":3,"REPORT":4,"PLAN":5,"TRIP":6,
		    "RESEARCH":7,"RESULT":8,"CHEMICAL":9,"PACKAGE":10,"RECIPE":11,"NOTICE":12
		  };

		  $(treeId).jstree({
		    core: { data: data, check_callback: true, multiple: true },
		    checkbox: {
		      keep_selected_style: false,
		      three_state: true,
		      whole_node: true,
		      cascade: "up+down",
		      tie_selection: false
		    },
		    sort: function(a, b) {
		      var na = this.get_node(a), nb = this.get_node(b);

		      if (na.parent === "#" && nb.parent === "#") {
		        var ta = (na.li_attr && na.li_attr["data-type"]) || "";
		        var tb = (nb.li_attr && nb.li_attr["data-type"]) || "";
		        var wa = order[ta] || 999, wb = order[tb] || 999;
		        if (wa !== wb) return wa - wb;
		        return na.text.localeCompare(nb.text, "ko");
		      }
		      if (na.parent === nb.parent && na.parent !== "#") {
		        var ia = parseInt((na.li_attr && na.li_attr["data-docid"]) || "", 10);
		        var ib = parseInt((nb.li_attr && nb.li_attr["data-docid"]) || "", 10);
		        if (!isNaN(ia) && !isNaN(ib) && ia !== ib) return ia - ib;
		        return na.text.localeCompare(nb.text, "ko");
		      }
		      return na.text.localeCompare(nb.text, "ko");
		    },
		    plugins: ["wholerow", "checkbox", "contextmenu", "sort"]
		  }).on("loaded.jstree", function(){
		    $(this).jstree("open_all");
		  });
		}

		/* 오른쪽 트리 데이터로부터 jsTree용 data 생성 후 렌더 */
		function rebuildRightTree() {
		  var data = buildTreeDataFromDocs(rightDocs);
		  fn_createJSTree2(data);
		}

		/* 버튼 핸들러: > 이동 (왼쪽 → 오른쪽) */
		function moveSelectedRight() {
		  var picked = collectCheckedDocsFromLeft();
		  if (!picked.length) return;

		  for (var i=0; i<picked.length; i++) {
		    var d = picked[i];
		    var key = makeKey(d);
		    if (!rightDocMap[key]) {
		      rightDocMap[key] = true;
		      rightDocs.push(d);
		    }
		  }
		  rebuildRightTree();

		  // 선택 해제(옵션)
		  var inst1 = $("#jsTree1").jstree(true);
		  if (inst1) inst1.uncheck_all();
		}

		/* 버튼 핸들러: < 회수 (오른쪽에서 선택 제거) */
		function moveSelectedLeft() {
		  var keys = collectCheckedKeysFromRight();
		  if (!keys.length) return;

		  // map에서 제거
		  for (var i=0; i<keys.length; i++) delete rightDocMap[keys[i]];

		  // 배열 갱신
		  rightDocs = rightDocs.filter(function(d){ return !!rightDocMap[makeKey(d)]; });

		  rebuildRightTree();
		}
		
		/* ---- 공통 헬퍼: selectedValues() 사용/미사용 모두 대응 ---- */
		function getSelectedOne(selector) {
		  var $el = $(selector);
		  try {
		    var arr = ($el.selectedValues && typeof $el.selectedValues === "function") ? $el.selectedValues() : null;
		    if (arr && arr.length) return arr[0];
		  } catch(e) {}
		  return $el.val() || "";
		}

		/* ---- 문서 이관 실행 ---- */
		function fn_update(transferComment, alwaysCb) {
		  var targetTeamId = getSelectedOne("#searchTeam2");
		  var targetUserId = getSelectedOne("#searchUser2");
		  var sourceUserId = getSelectedOne("#searchUser1") || "";
		
		  var allDocs = rightDocs.slice();
		
		  var payload = {
		    sourceUserId: sourceUserId,
		    targetTeamId: targetTeamId,
		    targetUserId: targetUserId,
		    transferComment: transferComment || "",
		    docs: allDocs.map(function(d){
		      return {
		        docId: String(d.docId),
		        typeCode: d.typeCode || "UNKNOWN",
		        typeName: d.typeName || "",
		        docNo: d.docNo || "",
		        title: d.title || "",
		        statusText: d.statusText || ""
		      };
		    })
		  };
		
		  $.ajax({
			  type: "POST",
			  url: "../systemDocTransfer/transferDocsAjax",
			  data: JSON.stringify(payload),
			  contentType: "application/json; charset=UTF-8",
			  dataType: "json",
			  success: function(res){
			    if (res && (res.RESULT === 'S' || res.RESULT === 'P')) {
			      alert(res.RESULT === 'S' ? "문서 이관이 완료되었습니다." : "일부 문서만 이관되었습니다.");
			      // ✅ 좌/우 트리 갱신
			      resetRightTree();   // 우측 비우고
			      refreshLeftTree();  // 좌측은 from 사용자 기준 재조회
			      var inst1 = $("#jsTree1").jstree(true);
			      if (inst1) inst1.uncheck_all();
			    } else {
			      alert("이관 실패: " + (res && res.MESSAGE ? res.MESSAGE : "알 수 없는 오류"));
			      console.error("[fn_update] server error payload:", res);
			    }
			  },
			  error: function(xhr, status, err){
			    alert("이관 중 오류가 발생했습니다. 콘솔 로그를 확인해주세요.");
			    console.error("[fn_update] transport error:", status, err, xhr && xhr.responseText);
			  },
			  complete: function(){
			    if (typeof alwaysCb === 'function') alwaysCb();
			  }
			});
		}
		
		/* ===== 모달 열기/닫기 ===== */
		function openTransferDialog() {
		  $('#transferComment').val('');
		  $('#dialog_transfer').show();
		  setTimeout(function(){ $('#transferComment').focus(); }, 0);
		  $(document).on('keydown.transferDialog', function(e){
		    if (e.key === 'Escape') closeDialog('dialog_transfer');
		  });
		}
		function closeDialog(id) {
		  $('#'+id).hide();
		  $(document).off('keydown.transferDialog');
		}

		/* ===== 모달 확인: 사유 + 핵심 재검사 후 fn_update ===== */
		$(document).on('click', '#btnConfirmTransfer', function(){
		  // 1) 사유 유효성 (필수/길이 등 정책에 맞게)
		  var comment = ($('#transferComment').val() || '').trim();
		  if (!comment) { alert('이관 사유를 입력해주세요.'); $('#transferComment').focus(); return; }
		  if (comment.length < 2) { alert('이관 사유를 2자 이상 입력해주세요.'); $('#transferComment').focus(); return; }

		  // 2) 핵심 입력 재검사 (모달 열린 사이 값이 바뀌었을 수 있음)
		  var v = validateCoreInputs();
		  if (!v.ok) { alert(v.msg); return; }

		  // 3) 진행
		  closeDialog('dialog_transfer');
		  fn_update(comment);
		});
		
		/* ===== 핵심 입력 유효성 검사 (팀/담당자/오른쪽 문서) ===== */
		function validateCoreInputs() {
		  var targetTeamId = getSelectedOne("#searchTeam2");
		  var targetUserId = getSelectedOne("#searchUser2");
		  if (!targetTeamId) return { ok:false, msg:"받을 팀을 선택해주세요." };
		  if (!targetUserId) return { ok:false, msg:"받을 담당자를 선택해주세요." };
		  if (!rightDocs || rightDocs.length === 0) return { ok:false, msg:"이관할 문서를 오른쪽으로 이동해주세요." };
		  return { ok:true };
		}

		/* ===== 모달 오픈 전에: from/to 선택 + 오른쪽 문서 존재 필수 ===== */
		function validateBeforeModal() {
		  var sourceUserId = getSelectedOne("#searchUser1"); // from
		  var targetTeamId = getSelectedOne("#searchTeam2"); // to(team)
		  var targetUserId = getSelectedOne("#searchUser2"); // to(user)
		
		  if (!sourceUserId) return { ok:false, msg:"보내는 담당자를 선택해주세요." };
		  if (!targetTeamId) return { ok:false, msg:"받을 팀을 선택해주세요." };
		  if (!targetUserId) return { ok:false, msg:"받을 담당자를 선택해주세요." };
		  if (!rightDocs || rightDocs.length === 0) return { ok:false, msg:"오른쪽에 이관할 문서가 없습니다." };
		
		  // (선택) 동일 사용자 이관 방지
		  if (sourceUserId === targetUserId) return { ok:false, msg:"보내는 담당자와 받는 담당자가 같습니다." };
		
		  return { ok:true };
		}

		/* ===== 버튼 클릭: 사전 유효성 통과 시에만 모달 오픈 ===== */
		function onClickOpenTransfer() {
		  var v = validateBeforeModal();
		  if (!v.ok) { alert(v.msg); return; }
		  openTransferDialog();
		}

		/* ===== 모달 확인: 사유 + 핵심 재검사 후 진행 ===== */
		$(document).on('click', '#btnConfirmTransfer', function(){
		  // 1) 사유 검사
		  var comment = ($('#transferComment').val() || '').trim();
		  if (!comment) { alert('이관 사유를 입력해주세요.'); $('#transferComment').focus(); return; }
		  if (comment.length < 2) { alert('이관 사유를 2자 이상 입력해주세요.'); $('#transferComment').focus(); return; }

		  // 2) 핵심 재검사 (모달 열려있는 동안 값이 바뀌었을 수 있음)
		  var v = validateBeforeModal();
		  if (!v.ok) { alert(v.msg); return; }

		  // 3) 진행
		  closeDialog('dialog_transfer');
		  fn_update(comment);
		});
		
		/* ===== 모달 확인: 사유 + 핵심 재검사 후 fn_update ===== */
		function onConfirmTransferClick(){
		  // 1) 사유 유효성
		  var comment = ($('#transferComment').val() || '').trim();
		  if (!comment) { alert('이관 사유를 입력해주세요.'); $('#transferComment').focus(); return; }
		  if (comment.length < 2) { alert('이관 사유를 2자 이상 입력해주세요.'); $('#transferComment').focus(); return; }

		  // 2) 핵심 재검사
		  var v = validateCoreInputs();
		  if (!v.ok) { alert(v.msg); return; }

		  // 3) 더블클릭 방지
		  var $btn = $('#btnConfirmTransfer');
		  if ($btn.data('busy')) return;
		  $btn.data('busy', true).prop('disabled', true);

		  // 4) 진행
		  closeDialog('dialog_transfer');
		  fn_update(comment, function always(){
		    $btn.data('busy', false).prop('disabled', false);
		  });
		}

		/* 페이지 초기 1회만 바인딩 */
		$(function(){
		  // 중복 바인딩 방지
		  $(document).off('click', '#btnConfirmTransfer');
		  $(document).on('click', '#btnConfirmTransfer', onConfirmTransferClick);
		});
		
		function resetRightTree() {
		  rightDocs = [];
		  rightDocMap = {};
		  rebuildRightTree();
		}
		
		/* ===== 좌측 트리 재조회 (현재 선택된 from 사용자 기준) ===== */
		function refreshLeftTree() {
		  var sourceUserId = getSelectedOne("#searchUser1");
		  if (sourceUserId) {
		    fetchUserDocs(sourceUserId);   // 소유자 변경 반영해서 다시 그리기
		  } else {
		    fn_createJSTree1([]);          // 선택이 비어있으면 좌측 비움
		  }
		}
		
		/* ===== 왼쪽 선택 변경 시, 오른쪽에 문서가 있으면 확인/초기화 ===== */
		var prevTeam1 = "", prevUser1 = "";

		/* 공통: select 값 설정 + label 텍스트 동기화 */
		function setSelectValue(selector, val){
		  var $el = $(selector);
		  try {
		    if ($el.selectedValues && typeof $el.selectedValues === 'function') {
		      $el.selectedValues([val]);      // 커스텀 플러그인 대응
		    } else {
		      $el.val(val);
		    }
		  } catch(e){}
		  // label 갱신 (label id 규칙: searchTeam_label1 / searchUser_label1)
		  var id = selector.replace('#','');
		  var labelId = id === 'searchTeam1' ? '#searchTeam_label1'
		             : id === 'searchUser1' ? '#searchUser_label1' : '';
		  if (labelId) $(labelId).text($("#"+id+" option:selected").text() || "선택");
		}
</script>
<input type="hidden" name="selectedRoleIdx" id="selectedRoleIdx">
<div class="wrap_in" id="fixNextTag">
	<span class="path">문서 이관&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Document Transfer</span>
			<span class="title">문서 이관</span>
		</h2>
		<div class="group01" >
			<div style="padding: 5px;">
				<div style="width:100%; display: flex; justify-content: space-between;">
					<div class="title2"  style="width:48%;">
						<span class="txt">보내는 문서</span>
					</div>
					<div></div>
					<div class="title2"  style="width:48%;">
						<span class="txt">받을 문서</span>
					</div>
				</div>
			</div>
			<div style="width:100%; display:flex; justify-content: space-between; align-items: center;">
				<div class="mainTable" style="width:48%; display:flex; justify-content: space-between; flex-direction: column; align-items: center;">
					<div class="search_box">
						<ul style="height: 70px;">
							<li id="searchTeam_li1">
								<dt>팀</dt>
								<dd >
									<!-- 초기값은 보통으로 -->
									<div class="selectbox" style="width:180px;">  
										<label for="searchTeam1" id="searchTeam_label1">선택</label> 
										<select name="searchTeam1" id="searchTeam1" onChange="fn_loadUser1()">
										</select>
									</div>
								</dd>
							</li>
							<li id="searchUser_li1" style="display:none">
								<dt>담당자</dt>
								<dd >
									<!-- 초기값은 보통으로 -->
									<div class="selectbox" style="width:180px;">  
										<label for="searchUser1" id="searchUser_label1">선택</label> 
										<select name="searchUser1" id="searchUser1">
										</select>
									</div>
								</dd>
							</li> 
						</ul>
					</div>
					<div style="width:100%; height: 500px; overflow-x: hidden; overflow-y: auto;">
						<div id="jsTree1"></div> 
					</div>
				</div>
				<div style="width:4%; display:flex; justify-content: center; flex-direction: column; align-items: center; gap:40px;">
					<button type="button" class="transfer-btn to-right" aria-label="오른쪽으로 이동">›</button>
					<button type="button" class="transfer-btn to-left"  aria-label="왼쪽으로 이동">‹</button>
				</div>
				<div class="mainTable" style="width:48%; display:flex; justify-content: space-between; flex-direction: column; align-items: center;">
					<div class="search_box">
						<ul style="height: 70px;">
							<li id="searchTeam_li2">
								<dt>팀</dt>
								<dd >
									<!-- 초기값은 보통으로 -->
									<div class="selectbox" style="width:180px;">  
										<label for="searchTeam2" id="searchTeam_label2">선택</label> 
										<select name="searchTeam2" id="searchTeam2" onChange="fn_loadUser2()">
										</select>
									</div>
								</dd>
							</li>
							<li id="searchUser_li2" style="display:none">
								<dt>담당자</dt>
								<dd >
									<!-- 초기값은 보통으로 -->
									<div class="selectbox" style="width:180px;">  
										<label for="searchUser2" id="searchUser_label2">선택</label> 
										<select name="searchUser2" id="searchUser2">
										</select>
									</div>
								</dd>
							</li> 
						</ul>
					</div>
					<div style="width:100%; height: 500px; overflow-x: hidden; overflow-y: auto;">
						<div id="jsTree2"></div> 
					</div>
				</div>
			</div>
			<div class="btn_box_con"> 
				<button class="btn_admin_red" onclick="onClickOpenTransfer()">문서 이관</button>
			</div>
	 		<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
	</section>
</div>

<!-- 문서 이관 사유 모달 -->
<div class="white_content" id="dialog_transfer" style="display:none;">
  <div class="modal" style="width: 480px; margin-left: -240px; height: 320px; margin-top: -160px;">
    <h5 style="position:relative"><span class="title">문서 이관 사유</span></h5>
    <div style="margin-top: 16px;">
      <textarea id="transferComment" rows="6" style="width:100%; box-sizing:border-box; resize:vertical;"
        placeholder="예) 담당자 변경으로 인한 소유자 이관"></textarea>
    </div>
    <div style="margin-top: 16px; text-align:right; display:flex; gap:8px; justify-content:flex-end;">
		<button class="btn_admin_red" id="btnConfirmTransfer" type="button">문서이관</button>
		<button class="btn_admin_gray" type="button" onclick="closeDialog('dialog_transfer')">취소</button>
    </div>
  </div>
</div>