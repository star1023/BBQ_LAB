<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page session="false" %>
<script type="text/javascript">
$(document).ready(function(){
	loadItemList();
});

function loadItemList() {
	var URL = "../code/itemListAjax";
	var groupCode = '${groupCode}';
	$.ajax({
		type:"POST",
		url:URL,
		data:{"groupCode":groupCode},
		dataType:"json",
		success:function(result) {
			var html = "";
			$("#list").html(html);
			if( result.length <= 0 ) {
				html += "<tr><td align='center' colspan='7'>데이터가 없습니다.</td></tr>";
			} else {
				$("#itemSize").val(result.length);
				var index = 1;					
				$.each(result, function(key,value){
					html += "<tr>";
					html += "	<td>"+value.groupCode+"</td>";	
					html += "	<td><input type=\"hidden\" name=\"itemCode_"+index+"\" id=\"itemCode_"+index+"\" value=\""+value.itemCode+"\">"+value.itemCode+"</td>";
					html += "	<td><input type=\"text\" name=\"itemName_"+index+"\" id=\"itemName_"+index+"\" value=\""+value.itemName+"\" style=\"width:95%;\"></td>";
					html += "	<td><input type=\"text\" name=\"description_"+index+"\" id=\"description_"+index+"\" value=\""+value.description+"\" style=\"width:95%;\"></td>";
					html += "	<td>"+value.regDate+"</td>";
					html += "	<td>";
					html += "		<ul class=\"list_ul\">";
					html += "			<li> <button class=\"btn_doc\" onClick=\"javascript:moveItem('"+value.itemCode+"','"+value.orderNo+"','UP')\"><img src=\"/resources/images/icon_arrow_up.png\"> 위로</button></li>";
					html += "			<li> <button class=\"btn_doc\" onClick=\"javascript:moveItem('"+value.itemCode+"','"+value.orderNo+"','DOWN')\"><img src=\"/resources/images/icon_arrow_down.png\"> 아래로</button></li>";
					html += "			<li> <button class=\"btn_doc\" onClick=\"javascript:updateItem('"+index+"')\"><img src=\"/resources/images/icon_doc03.png\"> 수정</button></li>";
					html += "			<li> <button class=\"btn_doc\" onClick=\"javascript:deleteItem('"+index+"')\"><img src=\"/resources/images/icon_doc04.png\"> 삭제</button></li>";
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
			html += "<tr><td align='center' colspan='8'>오류가 발생하였습니다.</td></tr>";
			$("#list").html(html);
		}			
	});	
}
function addCodeItem() {
	var URL = "../code/itemInsertAjax";
	if ( !chkNull($("#itemCode").val()) ) {
        alert('아이템코드를 입력하세요.');
        $("#itemCode").focus();
        return false;
    } else if ( !chkNull($("#itemName").val()) ) {
        alert('아이템코드명을 입력하세요.');
        $("#itemName").focus();
        return false;
    } else if ( !chkNull($("#description").val()) ) {
        alert('아이템 코드 설명을 입력하세요.');
        $("#description").focus();
        return false;
    } else {
    	var groupCode = '${groupCode}';
		var itemCode = $("#itemCode").val();
		var itemName = $("#itemName").val();
		var description = $("#description").val();
    	$.ajax({
			type:"POST",
			url:URL,
			data:{"groupCode":groupCode,"itemCode":itemCode,"itemName":itemName,"description":description},
			dataType:"json",
			success:function(data) {
				if(data.RESULT == 'Y'){
		        	clear();
		        	alert("등록되었습니다.");	
		        	loadItemList();
		        } else if( data.RESULT == 'F' ){
					alert(data.MESSAGE);
		        } else {
		        	alert("오류가 발생하였습니다.");
		        }
			},
			error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.");
			}			
		});	
    }
}

function updateItem(index) {
	var groupCode = '${groupCode}';
	var itemCode = $("#itemCode_"+index).val();
	var itemName = $("#itemName_"+index).val();
	var description = $("#description_"+index).val();
	
	var URL = "../code/itemUpdateAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{"groupCode":groupCode,"itemCode":itemCode,"itemName":itemName,"description":description},
		dataType:"json",
		success:function(data) {
			if(data.RESULT == 'Y'){
	        	alert("수정되었습니다.");	
	        	loadItemList();
	        } else if( data.RESULT == 'F' ){
				alert(data.MESSAGE);
	        } else {
	        	alert("오류가 발생하였습니다.");
	        }
		},
		error:function(request, status, errorThrown){
			alert("오류가 발생하였습니다.");
		}			
	});	
}

function deleteItem(index){
	var groupCode = '${groupCode}';
	var itemCode = $("#itemCode_"+index).val();
	var URL = "../code/itemDeleteAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{"groupCode":groupCode,"itemCode":itemCode},
		dataType:"json",
		success:function(data) {
			if(data.RESULT == 'Y'){
	        	alert("삭제되었습니다.");	
	        	loadItemList();
	        } else if( data.RESULT == 'F' ){
				alert(data.MESSAGE);
	        } else {
	        	alert("오류가 발생하였습니다.");
	        }
		},
		error:function(request, status, errorThrown){
			alert("오류가 발생하였습니다.");
		}			
	});	
}

function moveItem( itemCode,orderNo,mode ) {
	var groupCode = '${groupCode}';
	var itemCode = itemCode;
	if( mode == 'UP' ) {
		if( orderNo > 1 ) {
			$.ajax({
				type:"POST",
				url:"../code/itemOrderUpdateAjax",
				dataType:"json",
				data:{"groupCode":groupCode,"itemCode":itemCode,"mode":mode},
				success:function(data) {
					loadItemList();
				}		
	 	 	 });
		} else {
			alert("첫번째 항목입니다.");
		}
	} else if( mode == 'DOWN' ) {
		if( orderNo < $("#itemSize").val() ) {
			$.ajax({
				type:"POST",
				url:"../code/itemOrderUpdateAjax",
				dataType:"json",
				data:{"groupCode":groupCode,"itemCode":itemCode,"mode":mode},
				success:function(data) {
					loadItemList();
				}		
	 	 	 });
		} else {
			alert("마지막 항목입니다.");
		}
	}
}


function clear() {
	  $("#itemCode").val("");
	  $("#itemName").val("");
	  $("#description").val("");
}

function groupList() {
	window.location.href = "../code/groupList";	
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
<title>아이템관리</title>
<input type="hidden" name="itemSize" id="itemSize">
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
						<button class="btn_circle_red" onClick="location.href='#open'">&nbsp;</button>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="main_tbl">
				<table class="tbl01">
					<colgroup>
						<col width="10%">
						<col width="10%">
						<col width="20%">
						<col width="25%">
						<col width="10%">
						<col width="25%">
					</colgroup>
					<thead>
						<tr>
							<th>그룹코드</th>
							<th>아이템코드</th>
							<th>아이템코드 명</th>
							<th>아이템코드 설명</th>
							<th>작성일</th>
							<th>&nbsp;</th>
						</tr>
					</thead>
					<tbody id="list">
					</tbody>
				</table>
			</div>
			<div class="btn_box_con5">
				<button class="btn_admin_gray" onClick="javascript:groupList();"  style="width:120px;">목록</button>
			</div>
			<div class="btn_box_con4"> 
				<button type="button" class="btn_admin_red" onclick="openDialog('open');">아이템코드 생성</button>				
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
			<span class="title">아이템코드 생성</span>
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
						<input type="hidden" name="groupCode" id="groupCode"  value="${groupCode}"/>
						${groupCode}
					</dd>
				</li>
				<li>
					<dt>아이템코드</dt>
					<dd>
						<input type="text" class="req" style="width:200px;" placeholder="코드 입력" name="itemCode" id="itemCode"/>
					</dd>
				</li>
				<li>
					<dt>아이템코드명</dt>
					<dd>
						<input type="text" class="req" style="width:200px;" placeholder="코드명 입력" name="itemName" id="itemName"/>
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
			<button class="btn_admin_red"onclick="javascript:addCodeItem();">아이템코드 생성</button>
			<button class="btn_admin_gray" onClick="closeDialog('open')">생성 취소</button>
		</div>
	</div>
</div>
<!-- 코드추가 생성레이어 close-->
