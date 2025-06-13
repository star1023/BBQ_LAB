<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page session="false" %>
<script type="text/javascript">
$(document).ready(function(){
	loadGroupList();
});

function loadGroupList() {
	var URL = "../code/groupListAjax";
	$.ajax({
		type:"POST",
		url:URL,
		dataType:"json",
		success:function(result) {
			var html = "";
			$("#list").html(html);
			if( result.length <= 0 ) {
				html += "<tr><td align='center' colspan='6'>데이터가 없습니다.</td></tr>";
			} else {
				var index = 1;
				$.each(result, function(key,value){
					html += "<tr>";
					html += "	<Td><input type=\"hidden\" name=\"groupCode_"+index+"\" id=\"groupCode_"+index+"\" value=\""+value.groupCode+"\"><a href=\"javascript:goItemList('"+value.groupCode+"')\">"+value.groupCode+"</a></td>";					
					html += "	<Td><input type=\"text\" name=\"groupName_"+index+"\" id=\"groupName_"+index+"\" value=\""+value.groupName+"\" style=\"width:95%\"></td>";
					html += "	<Td><input type=\"text\" name=\"description_"+index+"\" id=\"description_"+index+"\" value=\""+value.description+"\" style=\"width:95%\"></td>";
					html += "	<td>"+value.regUserId+"</td>";
					html += "	<td>"+value.regDate+"</td>";
					html += "	<td>";
					html += "		<ul class=\"list_ul\">";
					html += "			<li> <button class=\"btn_doc\" onClick=\"javascript:updateCodeGroup('"+index+"')\"><img src=\"/resources/images/icon_doc03.png\"> 수정</button></li>";
					html += "			<li> <button class=\"btn_doc\" onClick=\"javascript:deleteCodeGroup('"+index+"')\"><img src=\"/resources/images/icon_doc04.png\"> 삭제</button></li>";
					//html += "		<button type=\"button\" class=\"btn_table_nomal\" onClick=\"javascript:updateCodeGroup('"+index+"')\">수정</button>"; 
					//html += "		<button type=\"button\"  class=\"btn_table_gray\" onClick=\"javascript:deleteCodeGroup('"+index+"')\"><img src=\"../resources/images/icon_del.png\">삭제</button>";
					html += "		</ul>";
					html += "	</td>";
					html += "</tr>";
					index++;
				});
			}
			$("#list").html(html);
		},
		error:function(request, status, errorThrown){
			var html = "";
			$("#list").html(html);
			html += "<tr><td align='center' colspan='6'>오류가 발생하였습니다.</td></tr>";
			$("#list").html(html);
		}			
	});	
}

//상세보기
function goItemList(groupCode){
	window.location.href = "../code/itemList?groupCode="+groupCode;	
}

function updateCodeGroup(index) {
	var URL = "../code/gruopUpdateAjax";
	$.ajax({
		type:"POST",
		url:URL,
		dataType: 'json',
		data:{"groupCode":$("#groupCode_"+index).val(),"groupName":$("#groupName_"+index).val(),"description":$("#description_"+index).val()},
		success: function(data) {
	        if(data.RESULT == 'Y'){
	        	alert("수정되었습니다.");
	        } else if( data.RESULT == 'F' ){
				alert(data.MESSAGE);
	        } else {
	        	alert("오류가 발생하였습니다.");
	        }
	        loadGroupList();
	    }
	});
}

function deleteCodeGroup(index){
	$("#groupCode").val($("#groupCode_"+index).val());
	var URL = "../code/gruopDeleteAjax";
	$.ajax({
		type:"POST",
		url:URL,
		dataType: 'json',
		data:{"groupCode":$("#groupCode_"+index).val()},
		success: function(data) {
	        if(data.RESULT == 'Y'){
	        	alert("삭제되었습니다.");
	        } else if( data.RESULT == 'F' ){
				alert(data.MESSAGE);
	        } else {
	        	alert("오류가 발생하였습니다.");
	        }
	        loadGroupList();
	    }
	});
}

function insertProc(){
 	if ( !chkNull($("#groupCode").val()) ) {
        alert('그룹코드를 입력하세요.');
        $("#groupCode").focus();
        return;
    } else if ( !chkNull($("#groupName").val()) ) {
        alert('그룹코드명을 입력하세요.');
        $("#groupName").focus();
        return;
    } else if ( !chkNull($("#description").val()) ) {
        alert('그룹코드 설명을 입력하세요.');
        $("#description").focus();
        return;
    } else {
    	var URL = "../code/gruopInsertAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{"groupCode":$("#groupCode").val(),"groupName":$("#groupName").val(),"description":$("#description").val()},
			dataType:"json",
			async:false,
			success:function(data) {
				if(data.RESULT == 'Y'){
		        	clear();
		        	alert("등록되었습니다.");	
		        	loadGroupList();
		        	closeDialog('open');
		        } else if( data.RESULT == 'F' ){
					alert(result.MESSAGE);
		        } else {
		        	alert("오류가 발생하였습니다.");
		        }
			},
			error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
			}			
		});
    }	
}

function clear() {
	$("#groupCode").val("");
	$("#groupName").val("");
	$("#description").val("");
}

// 그룹코드 대문자로
function toUpper(obj){
	var str = obj.value;
	obj.value = str.toUpperCase();
}

function chkNull(ObjSrc) {
	var str = ObjSrc;
	var blank_flg = false;
	if(str == null || str == "") return false;
		for(cnt=0;cnt<str.length;cnt++) {
			if( str.charAt(cnt) != " "){
				blank_flg = true;
			}
		}
	if(!blank_flg) return false;
	return true;
}
</script>
<title>코드관리</title>
<div class="wrap_in" id="fixNextTag">
	<span class="path">코드관리&nbsp;&nbsp;<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;관리자&nbsp;&nbsp;<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;<a href="#">BBQ연구소</a></span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative">
			<span class="title_s">Code management</span>
			<span class="title">코드관리</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_circle_red" onClick="openDialog('open')">&nbsp;</button>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="main_tbl">
				<table class="tbl01">
					<colgroup>
						<col width="15%">
						<col width="25%">
						<col width="25%">
						<col width="10%">
						<col width="10%">
						<col width="15%">
					</colgroup>
					<thead>
						<tr>
							<th>그룹코드ID</th>
							<th>그룹코드명</th>
							<th>그룹코드 설명</th>
							<th>작성자</th>
							<th>작성일</th>
							<th>&nbsp;</th>
						</tr>
					</thead>
					<tbody id="list">
					</tbody>
				</table>
			</div>
			<div class="btn_box_con"> 
				<button type="button" class="btn_admin_red" onclick="openDialog('open');">그룹코드 생성</button>
			</div>
			<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
		<!-- 컨텐츠 close-->	
	</section>
</div>

<!--코드추가 생성레이어 open-->
<!-- 클래스 옆에 적힌 스타일 값을 인라인으로 작성해서 팝업 사이즈를 직접 조정 -->
<div class="white_content" id="open">
	<div class="modal" style="	margin-left:-355px;width:710px;height: 400px;margin-top:-200px">
		<h5 style="position:relative">
			<span class="title">그룹코드 생성</span>
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
				<li class="pt10">
					<dt>그룹코드</dt>
					<dd>
						<input type="text" class="req" style="width:200px;" placeholder="그룹코드 입력" name="groupCode" id="groupCode" onkeyup="toUpper(this);"/>
					</dd>
				</li>
				<li>
					<dt>코드명</dt>
					<dd>
						<input type="text" class="req" style="width:200px;" placeholder="코드명 입력" name="groupName" id="groupName"/>
					</dd>
				</li>
				<li>
					<dt>설명</dt>
					<dd>
						<input type="text"  style="width:502px;" name="description" id="description"/>
					</dd>
				</li>
			</ul>
		</div>
		<div class="btn_box_con">
			<button class="btn_admin_red"onclick="javascript:insertProc();">그룹코드 생성</button>
			<button class="btn_admin_gray" onClick="closeDialog('open')">생성 취소</button>
		</div>
	</div>
</div>
<!-- 코드추가 생성레이어 close-->
