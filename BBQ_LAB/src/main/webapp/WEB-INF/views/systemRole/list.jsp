<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="kr.co.genesiskorea.util.*" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="dateUtil" uri="/WEB-INF/tld/dateUtil.tld"%>
<title>메뉴관리</title>
<style>
.positionCenter{
	position: absolute;
	transform: translate(-50%, -45%);
}
</style>

<script type="text/javascript">
$(document).ready(function(){
	fn_loadList(1);
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
				data.list.forEach(function (item) {
					html += "<tr>";
					html += "	<td>"+item.ROLE_ID+"</td>";
					html += "	<td>"+item.ROLE_NAME+"</td>";
					html += "	<td>"+item.ROLE_DESC+"</td>";
					html += "	<td>"+item.REG_DATE+"</td>";
					html += "	<td>";
					html += "		<ul class=\"list_ul\">";
					html += "			<li> <button class=\"btn_doc\" onClick=\"javascript:fn_updateForm('"+item.ROLE_IDX+"')\"><img src=\"/resources/images/icon_doc03.png\"> 수정</button></li>";
					html += "			<li> <button class=\"btn_doc\" onClick=\"javascript:fn_delete('"+item.ROLE_IDX+"')\"><img src=\"/resources/images/icon_doc04.png\"> 삭제</button></li>";
					html += "		</ul>";
					html += "	</td>";
					html += "</tr>";
				});				
			} else {
				$("#list").html(html);
				html += "<tr><td align='center' colspan='5'>데이터가 없습니다.</td></tr>";
			}			
			$("#list").html(html);
			$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
			$('#pageNo').val(data.navi.pageNo);
		},
		error:function(request, status, errorThrown){
			var html = "";
			$("#list").html(html);
			html += "<tr><td align='center' colspan='5'>오류가 발생하였습니다.</td></tr>";
			$("#list").html(html);
			$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
			$('#pageNo').val(data.navi.pageNo);
		}			
	});	
}

function fn_insert(){
	if( !chkNull($("#roleId").val()) ) {
		alert("권한아이디를 입력하여 주세요.");
		$("#roleId").focus();
		return;
	} 
	
	if( !chkNull($("#roleName").val()) ) {
		alert("권한명을 입력하여 주세요.");
		$("#roleName").focus();
		return;
	} 
	
	if( !chkNull($("#roleDesc").val()) ) {
		alert("권한 설명을 입력하여 주세요.");
		$("#roleDesc").focus();
		return;
	}
	$('#lab_loading').show();
	var URL = "../systemRole/insertRoleAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"roleId": $("#roleId").val()
			,"roleName": $("#roleName").val()
			,"roleDesc": $("#roleDesc").val()
			,"useYn": $("input[name='useYn']:checked").val()
		},
		dataType:"json",
		success:function(result) {
			console.log(result);
			if( result.RESULT == 'S' ) {
				alert("등록되었습니다.");
				fn_clearDialog();
				fn_loadList(1);
			} else if( result.RESULT == 'F' ) {
				alert(result.MESSAGE);
			} else {
				alert("오류가 발생하였습니다.\n"+result.MESSAGE);
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

function fn_updateForm(roleIdx) {
	$('#lab_loading').show();
	var URL = "../systemRole/selectRoleDataAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"roleIdx":roleIdx
		},
		dataType:"json",
		success:function(data) {
			console.log(data);
			if( data.ROLE_IDX == '' || data.ROLE_IDX == null ) {
				alert("삭제된 권한입니다.");					
			} else {
				$("#roleIdx").val(data.ROLE_IDX);
				$("#roleId").val(data.ROLE_ID);
				$("#roleName").val(data.ROLE_NAME);
				$("#roleDesc").val(data.ROLE_DESC);
				$("input[name='useYn'][value='"+data.useYn+"']").prop("checked",true);
				$("#create").hide();
				$("#update").show();
				openDialog('open');
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

function fn_update(){
	if( !chkNull($("#roleId").val()) ) {
		alert("권한아이디를 입력하여 주세요.");
		$("#roleId").focus();
		return;
	} 
	
	if( !chkNull($("#roleName").val()) ) {
		alert("권한명을 입력하여 주세요.");
		$("#roleName").focus();
		return;
	} 
	
	if( !chkNull($("#roleDesc").val()) ) {
		alert("권한 설명을 입력하여 주세요.");
		$("#roleDesc").focus();
		return;
	}
	$('#lab_loading').show();
	var URL = "../systemRole/updateRoleAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"roleIdx": $("#roleIdx").val()
			,"roleId": $("#roleId").val()
			,"roleName": $("#roleName").val()
			,"roleDesc": $("#roleDesc").val()
			,"useYn": $("input[name='useYn']:checked").val()
		},
		dataType:"json",
		success:function(result) {
			console.log(result);
			if( result.RESULT == 'S' ) {
				alert("수정되었습니다.");
				fn_clearDialog();
				fn_loadList(1);
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


function fn_delete(roleIdx) {
	$('#lab_loading').show();
	var URL = "../systemRole/deleteRoleAjax";
	$.ajax({
		type:"POST", 
		url:URL,
		data:{
			"roleIdx" : roleIdx
		},
		dataType:"json",
		async:false,
		success:function(result) {
			console.log(result);
			if( result.RESULT == 'S' ) {
				alert("삭제되었습니다.");
				fn_loadList(1);
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

function fn_clearDialog(){
	$("#roleIdx").val("");
	$("#roleId").val("");
	$("#roleName").val("");
	$("#roleDesc").val("");
	$("input[name='useYn'][value='Y']").prop("checked",true);
	$("#create").show();
	$("#update").hide();
}

function paging(pageNo) {
	fn_loadList(pageNo);
}
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">권한관리&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Role management</span>
			<span class="title">권한관리</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button type="button" class="btn_circle_red" onClick="fn_clearDialog();openDialog('open')">&nbsp;</button>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="tab02">
			</div>
			<div class="search_box" >
				<ul style="border-top:none">
					<li>
						<dt>구분</dt>
						<dd >
						</dd>
					</li>
					<li>
						<dt>공장</dt>
						<dd >							
						</dd>
					</li>
					<li>
						<dt>키워드</dt>
						<dd >							
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
					<button type="button" class="btn_con_search" onClick="javascript:goSearch();"><img src="/resources/images/btn_icon_search.png" style="vertical-align:middle;"/> 검색</button>
					<button type="button" class="btn_con_search" onClick="javascript:searchClear();"><img src="/resources/images/btn_icon_refresh.png" style="vertical-align:middle;"/> 검색 초기화</button>					
				</div>
			</div>
			<div class="main_tbl">
				<table class="tbl01">
					<colgroup id="list_colgroup">
						<col width="10%">
						<col width="15%">
						<col />
						<col width="10%">
						<col width="10%">
					</colgroup>
					<thead id="list_header">
						<tr>
							<th>권한코드</th>
							<th>권한명</th>
							<th>권한 설명</th>
							<th>등록일</th>
							<th>설정</th>
						<tr>
					</thead>
					<tbody id="list">						
					</tbody>
				</table>
				<div class="page_navi  mt10">
				</div>
			</div>
			<div class="btn_box_con"> 
				<button class="btn_admin_red" onclick="fn_clearDialog();openDialog('open')">등록</button>
			</div>
	 		<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
	</section>
</div>

<!-- 메뉴 생성 레이어 start-->
<div class="white_content" id="open">
	<input type="hidden" name="roleIdx" id="roleIdx">
	<div class="modal" style="	width: 700px;margin-left:-350px;height: 400px;margin-top:-200px;">
		<h5 style="position:relative">
			<span class="title">권한 생성</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('open')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li>
					<dt>퀀한코드</dt>
					<dd>
						<input type="text"  style="width:302px;" class="req" name="roleId" id="roleId" placeholder="권한코드 ID"/>
					</dd>
				</li>
				<li>
					<dt>권한명</dt>
					<dd>
						<input type="text"  style="width:302px;" class="req" name="roleName" id="roleName" placeholder="권한명"/>
					</dd>
				</li>
				<li>
					<dt>사용여부</dt>
					<dd>
						<input type="radio" name="useYn" id="r1" value="Y" checked/><label for="r1"><span></span>사용</label>
						<input type="radio" name="useYn" id="r2" value="N"/><label for="r2"><span></span>미사용</label>
					</dd>
				</li>
				<li>
					<dt>권한설명</dt>
					<dd>
						<textarea type="text"  style="width:500px; height:60px;" class="req" name="roleDesc" id="roleDesc"></textarea>
					</dd>
				</li>
			</ul>
		</div>
		<div class="btn_box_con">
			<button class="btn_admin_red" id="create" onclick="javascript:fn_insert();">등록</button> 
			<button class="btn_admin_red" id="update" onclick="javascript:fn_update();" style="dispaly:none">수정</button>
			<button class="btn_admin_gray" onclick="closeDialog('open')"> 취소</button>
		</div>
	</div>
</div>
<!-- 자재 생성레이어 close-->