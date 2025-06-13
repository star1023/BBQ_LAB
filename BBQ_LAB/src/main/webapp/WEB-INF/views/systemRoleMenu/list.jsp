<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>메뉴관리</title>
<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
</style>

<script type="text/javascript" src="../resources/js/jstree.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
		fn_loadList(1);
		fn_loadAllMenu();
	});
	
	function fn_loadList(pageNo) {
		$.ajax({
			type:"POST",
			url:"../systemRole/roleListAjax",
			data:{ 
				"pageNo" : pageNo
			},
			dataType:"json",
			success:function(data) {
				var html = "";
				if( data.totalCount > 0 ) {
					$("#list").html(html);
					data.list.forEach(function (item, idx) {
						html += "<tr id=\"roleTr_"+idx+"\" name=\"roleTr\" onclick=\"fn_selectRole('"+item.ROLE_IDX+"', 'roleTr_"+idx+"')\">";
						html += "	<td>"+item.ROLE_ID+"</td>";
						html += "	<td>"+item.ROLE_NAME+"</td>";
						html += "	<td>"+item.ROLE_DESC+"</td>";
						html += "	<td>"+item.REG_DATE+"</td>";
						html += "</tr>";
					});				
				} else {
					$("#list").html(html);
					html += "<tr><td align='center' colspan='4'>데이터가 없습니다.</td></tr>";
				}			
				$("#list").html(html);
				$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
				$('#pageNo').val(data.navi.pageNo);
			},
			error:function(request, status, errorThrown){
				var html = "";
				$("#list").html(html);
				html += "<tr><td align='center' colspan='4'>오류가 발생하였습니다.</td></tr>";
				$("#list").html(html);
				$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
				$('#pageNo').val(data.navi.pageNo);
			}			
		});	
	}
	
	function fn_loadAllMenu(){
		var URL = "../systemRoleMenu/selectAllMenuAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				
			},
			dataType:"json",
			success:function(data) {
				fn_createJSTree(data);
			},
			error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
	}
	
	function fn_createJSTree(data) {
		$("#jsTree").jstree(
			{ 
				'core' : {
					'data' : data
					, "check_callback" : true
				},
				"checkbox" : {
					"keep_selected_style" : false
					//,"whole_node" : false
					//,"three_state" : false
					//,"tie_selection" : false
				},
				"plugins" : [ "wholerow", "checkbox", "contextmenu" ]
		   	}
		).bind("loaded.jstree",function(){
			 $(this).jstree("open_all");
		}).bind("refresh.jstree",function(){
			$(this).jstree('deselect_all',null,true);
			if( $("#selectedRoleIdx").val() != '' ) {
				$.ajax({
					type:"POST",
					url:"../systemRoleMenu/selectRoleMenuListAjax",
					data:{ 
						"selectedRoleIdx" : $("#selectedRoleIdx").val()
					},
					dataType:"json",
					success:function(data) {
						console.log(data);
						data.forEach(function (item) {
							if( item.IS_ROOT == 'N' ) {
								$("#jsTree").jstree(true).select_node(""+item.MENU_IDX);
							}
						});
					},
					error:function(request, status, errorThrown){
					}			
				});
			}
			//$(this).jstree(true).select_node("4");
			//console.log($("#selectedRoleIdx").val());
		});
	}
	
	
	function fn_selectRole( roieIdx, idx) {
		document.getElementsByName('roleTr').forEach(function(tr){
			if(tr.id == idx)
				tr.style.backgroundColor = '#fff3cd';
			else
				tr.style.backgroundColor = '#fff';
		});
		$("#selectedRoleIdx").val(roieIdx);
		$("#jsTree").jstree(true).refresh();
	}
	
	function fn_insert() {
		if( !chkNull($("#selectedRoleIdx").val()) ) {
			alert("변경할 권한을 선택해주세요.");
			return;
		}
		
		const selectedMenu = [];
		var arrSelected = $("#jsTree").jstree('get_selected',null,true);
		console.log(arrSelected);
		$.each(arrSelected, function() {
			var parent = $("#jsTree").jstree('get_parent', this);
			console.log("parent : "+parent);
			if( parent != '#' ) {
				selectedMenu.push(this.toString());
				//if( !selectMenu.includes(parent.toString()) ) {
				//	selectMenu.push(parent.toString());	
				//}	
			}
			if( !selectedMenu.includes(this.toString()) ) {
				//selectMenu.push(this.toString());	
			}
		});
		
		if( selectedMenu.length == 0 ) {
			alert("선택된 메뉴가 없습니다. 메뉴를 지정해주세요.");
			return;
		}
		
		$('#lab_loading').show();
		var URL = "../systemRoleMenu/updateRoleMenuAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"selectedRoleIdx":$("#selectedRoleIdx").val()
				, "selectedMenu" : selectedMenu
			},
			traditional: true,
			dataType:"json",
			success:function(result) {
				console.log(result);
				if( result.RESULT == 'S' ) {
					alert("수정되었습니다.");
				} else {
					alert("오류가 발생하였습니다.\n"+result.Message);
				}
			},
			error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			},
			complete:function(){
				$('#lab_loading').hide();
			}			
		});	
	}
</script>
<input type="hidden" name="selectedRoleIdx" id="selectedRoleIdx">
<div class="wrap_in" id="fixNextTag">
	<span class="path">권한별 메뉴 관리&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Role&Menu management</span>
			<span class="title">권한별 메뉴 관리</span>
		</h2>
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="tab02">
			</div>
			<div class="main_tbl">
				<table class="tbl01">
					<colgroup id="list_colgroup">
						<col width="10%">
						<col width="15%">						
						<col />
						<col width="10%">
					</colgroup>
					<thead id="list_header">
						<tr>
							<th>권한코드</th>
							<th>권한명</th>
							<th>권한 설명</th>
							<th>등록일</th>
						<tr>
					</thead>
					<tbody id="list">
					</tbody>
				</table>				
				<div class="page_navi  mt10">
				</div>
				
			</div>
			<div style="height: 220px; overflow-x: hidden; overflow-y: auto;">
				<div id="jsTree"></div> 
			</div>
			<div class="btn_box_con"> 
				<button class="btn_admin_red" onclick="fn_insert()">등록</button>
			</div>
	 		<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
		
	</section>
</div>