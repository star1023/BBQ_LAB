<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page session="false" %>
<title>사용자 관리</title>
<script type="text/javascript">
	var idFlag ;
	$(document).ready(function(){
		getUserList('1');
		
		bindSearchEnter('searchValue');
		
		$('#userId').keyup(function(event){
			if($('#userId').val().length<4){
				$('#checkId').html('<font color="red" font-size="10px">글자수는 4글자 이상으로 설정해주세요.</font>');
				idFlag = false;
			}else{
		 		$.ajax({
					type: 'post',
					url: '/user/checkId',
					data: {
	    				"userId" : $("#userId").val()    				
	    			},
					dataType: 'json',					
					async : true,
					success: function (data) {
						if(data.RESULT == 'F'){
							$('#checkId').html('<font color="red" font-size="10px">이미 사용중인 아이디 입니다.</font>');
							idFlag = false;
						} else if(data.RESULT == 'S') {
							$('#checkId').html('<font color="blue" font-size="10px">사용가능한 아이디입니다.</font>');
							idFlag = true;						
						}
					},error: function(XMLHttpRequest, textStatus, errorThrown){
						$('#checkId').html('');
					}
				});
			}
		});
	});
	
	function bindSearchEnter(elementId){
		document.getElementById(elementId).addEventListener("keydown", function(e){
			if(e.keyCode == 13)
				getUserList(1);
		})
	}
	
	//사용자권한관리 리스트 ajax
	function getUserList(pageNo){
		$.ajax({
			type: 'POST',
			url: '../user/userListAjax',
			data: {
				searchValue : $("#searchValue").val(),
				deptCode : $("#dept").selectedValues()[0],
				teamCode : $("#team").selectedValues()[0],
				userGrade : $("#grade").selectedValues()[0],
				pageNo : pageNo
			},
			dataType: 'json',
			async : true,
			success: function (data) {
				if(data.RESULT == 'F'){
					alert("리스트 로딩 중 오류 발생");
					return;
				}
				var html = '';
				data.list.forEach(function (item) {
					if(item.isDelete == 'Y'){
						html += "<tr class='m_visible'>"
					} else {
						html += "<tr>"
					}
					
					html += "	<td>"+item.userName+"</td>";
					html += "	<td>"+item.userId+"</td>";
					html += "	<td>"+nvl(item.roleName,'')+"</td>";
					html += "	<td>"+nvl(item.OBJTTX,'')+"</td>";
					html += "	<td>"+nvl(item.TITL_TXT,'')+"</td>";
					html += "	<td>"+nvl(item.RESP_TXT,'')+"</td>";
					if( item.isAdmin == 'Y' ) {
						html += "	<td>관리자</td>";
					} else {
						html += "	<td>&nbsp;</td>";
					}
					html += "	<td>"+item.regDate+"</td>";
					html += "	<td>";
					html += "		<ul class=\"list_ul\">";
					html += "		<li><button class=\"btn_doc\" onClick=\"javascript:selectUpdateUser('"+item.userId+"')\"><img src=\"/resources/images/icon_doc03.png\">수정</button></li>";
					
					if(item.EMSTAT != '3'){
						html += "		<li><button class=\"btn_doc\" onClick=\"javascript:deleteUser('"+item.userId+"')\"><img src=\"/resources/images/icon_doc04.png\">퇴직처리</button></li>";
					} else {
						html += "		<li><button class=\"btn_doc\" onClick=\"javascript:restoreUser('"+item.userId+"')\"><img src=\"/resources/images/icon_doc17.png\">재직처리</button></li>";
					}
					
					if( item.isDelete != 'Y' && item.isLock == 'Y' ){
						html += "		<li><button class=\"btn_doc\" onClick=\"javascript:unlockUser('"+item.userId+"')\"><img src=\"/resources/images/icon_unlock.png\">잠금해제</button></li>";	
					}
					html += "		<li><button class=\"btn_doc\" onClick=\"javascript:fn_pwdInit('"+item.userId+"')\"><img src=\"/resources/images/icon_doc17.png\">비번초기화</button></li>";
					html += "		</ul>";
					html += "	</td>";
					html += "</tr>"					
				});
				
				$('#userList').html(html);
				//페이징
				$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
				$('#pageNo').val(data.navi.pageNo);
			},error: function(XMLHttpRequest, textStatus, errorThrown){
				alert('리스트 로딩 중 오류가 발생 하였습니다. 잠시 후 다시 시도 해주십시오.\n' +'errorCode : ' + textStatus );
				submitBool = true;
			}
		});
	}
	// 페이징
	function paging(pageNo){
		getUserList(pageNo);
	}	
	
	//파라미터 조회
	function getParam(pageNo){
		PARAM.pageNo = pageNo || '${paramVO.pageNo}';
		return $.param(PARAM);
	}
	
	//사용자 수정 페이지 이동
	function selectUpdateUser(userId){
		
		$.ajax({
			type: 'POST',
			url: '../user/selectUserAjax',
			data: {
				userId : userId
			},
			dataType: 'json',
			async : true,
			success: function (data) {
				if( data.userId != '' ) {
					$("#userName").val(data.userName);
					$("#userNameTxt").html(data.userName);
					$("#userId").val(data.userId);
					$("#userIdTxt").html(data.userId);
					$("#emailTxt").html(data.email);
					$("#orgTxt").html(data.OBJTTX);
					$("#titleTxt").html(data.TITL_TXT);
					$("#respTxt").html(data.RESP_TXT);
					$("#userRole").selectOptions(""+data.roleCode);
					$("#userRole_label").html($("#userRole").selectedTexts());
					openDialog('open');
				} else {
					alert("삭제된 사용자 입니다.");	
					getUserList('1');
				}
			},error: function(){
	            //에러발생을 위한 code페이지
	           	alert("오류가 발생하였습니다.");
			}                               
		});  
		
	}
	
	function updateUser() {
		/*
		if( !chkNull($("#userName").val()) ) {
        	alert("이름을 입력해주세요.");
        	$("#userName").focus();
        	return false;
        } else if( !chkNull($("#email").val()) ) {
        	alert("이메일 아이디를 입력해주세요.");
        	$("#email").focus();
        	return false;
        } else if( !chkEmail($("#email").val()) ) {
        	alert("이메일 형식이 올바르지 않습니다. \n 메일아이디@aspnc.com 형식으로 입력해주세요.");
        	$("#email").focus();
        	return false;
        } else if(idFlag == false){
        	alert('아이디 중복확인을 해주세요.');
        	return false;
        }else {
        	var isAdmin =  ($('input:checkbox[id="isAdmin"]').is(":checked"))? "Y" :"N" ; 
        	$.ajax({
    			type: 'POST',
    			url: '../user/updateUserAjax',
    			data: {
    				userName : $("#userName").val(),
    				userId : $("#userId").val(),
    				email : $("#email").val(),
    				deptCode : $("#deptCode").selectedValues()[0],
    				teamCode : $("#teamCode").selectedValues()[0],
    				userGrade : $("#userGrade").selectedValues()[0],
    				isAdmin : isAdmin
    			},
    			dataType: 'json',
    			async : true,
    			success: function (data) {
    				alert("사용자 정보가 변경되었습니다.");
    				getUserList('1');
    			},error: function(){
    	            //에러발생을 위한 code페이지
    	           	alert("오류가 발생하였습니다.");
				}                               
			});    			
        }
		*/
		$.ajax({
			type: 'POST',
			url: '../user/updateUserAjax',
			data: {
				"userId" : $("#userId").val(),
				"userRole" : $("#userRole").selectedValues()[0]
			},
			dataType: 'json',
			async : true,
			success: function (data) {
				alert("사용자 정보가 변경되었습니다.");
				closePopup('open');
				getUserList('1');
			},error: function(){
	            //에러발생을 위한 code페이지
	           	alert("오류가 발생하였습니다.");
			}                               
		}); 
	}
	
	//퇴직처리
	function deleteUser(userId){
		$.ajax({
			type: 'POST',
			url: '../user/deleteUserAjax',
			data: {
				userId : userId
			},
			dataType: 'json',
			async : true,
			success: function (data) {
				if(data.RESULT == 'F'){
					alert("사용자 퇴직처리시 오류가 발생했습니다.");
					return;
				} else {
					alert("사용자 퇴직처리 되었습니다.");
					getUserList($("#pageNo").val());
				}
			},error: function(XMLHttpRequest, textStatus, errorThrown){
				alert('작업 중 오류가 발생 하였습니다. 잠시 후 다시 시도 해주십시오.\n' +'errorCode : ' + textStatus );
			}
		});
	}
	
	//재적처리
	function restoreUser(userId){
		$.ajax({
			type: 'POST',
			url: '../user/restoreUserAjax',
			data: {
				userId : userId
			},
			dataType: 'json',
			async : true,
			success: function (data) {
				if(data.RESULT == 'F'){
					alert("사용자 재직처리시 오류가 발생했습니다.");
					return;
				} else {
					alert("사용자 재직처리 되었습니다.");
					//window.location.reload();
					getUserList($("#pageNo").val());
				}
			},error: function(XMLHttpRequest, textStatus, errorThrown){
				alert('작업 중 오류가 발생 하였습니다. 잠시 후 다시 시도 해주십시오.\n' +'errorCode : ' + textStatus );
				submitBool = true;
			}
		});
	}
	
	// 사용자 잠금해제
	function unlockUser(userId){
		$.ajax({
			type: 'POST',
			url: '../user/unlockUserAjax',
			data: {
				userId : userId
			},
			dataType: 'json',
			async : true,
			success: function (data) {
				if(data.RESULT == 'F'){
					alert("사용자 잠금해제시 오류가 발생했습니다.");
					return;
				} else {
					alert("사용자 잠금해제처리 되었습니다.");
					getUserList($("#pageNo").val());
				}
			},error: function(XMLHttpRequest, textStatus, errorThrown){
				alert('처리중 오류가 발생 하였습니다. 잠시 후 다시 시도 해주십시오.\n' +'errorCode : ' + textStatus );
			}
		});
	}
	
	function goClear() {
		$("#searchValue").val("");
		$("#dept").selectOptions("");
		$("#team").selectOptions("");
		$("#grade").selectOptions("");
		$("#deptL").html("부서");
		$("#teamL").html("팀");
		$("#gradeL").html("권한");
		getUserList('1');
	}
	
	function goSearch() {
		getUserList('1');
	}
	
	function inserUser() {
		if( !chkNull($("#userName").val()) ) {
        	alert("이름을 입력해주세요.");
        	$("#userName").focus();
        	return false;
        } else if( !chkNull($("#userId").val()) ) {
        	alert("아이디를 입력해주세요.");
        	$("#userId").focus();
        	return false;
        } else if( !chkNull($("#email").val()) ) {
        	alert("이메일 아이디를 입력해주세요.");
        	$("#email").focus();
        	return false;
        } else if( !chkEmail($("#email").val()) ) {
        	alert("이메일 형식이 올바르지 않습니다. \n 메일아이디@aspnc.com 형식으로 입력해주세요.");
        	$("#email").focus();
        	return false;
        } else if(idFlag == false){
        	alert('아이디 중복확인을 해주세요.');
        	return false;
        }else {
        	var isAdmin =  ($('input:checkbox[id="isAdmin"]').is(":checked"))? "Y" :"N" ; 
        	$.ajax({
    			type: 'POST',
    			url: '../user/inserUserAjax',
    			data: {
    				userName : $("#userName").val(),
    				userId : $("#userId").val(),
    				email : $("#email").val(),
    				deptCode : $("#deptCode").selectedValues()[0],
    				teamCode : $("#teamCode").selectedValues()[0],
    				userGrade : $("#userGrade").selectedValues()[0],
    				isAdmin : isAdmin
    			},
    			dataType: 'json',
    			async : true,
    			success: function (data) {
    				alert("사용자 등록 성공");
    				$("#userName").val("");
    				$("#userId").val("");
    				$("#email").val("");
    				$("#deptCode").selectOptions("");
    				$("#teamCode").selectOptions("");
    				$("#userGrade").selectOptions("");
    				$("#deptCode_label").html("선택하세요");
    				$("#teamCode_label").html("선택하세요");
    				$("#userGrade_label").html("선택하세요");
    				$('input:checkbox[id="isAdmin"]').prop("checked",false);
    				$('#checkId').html('');
    				getUserList('1');
    			},error: function(){
    	            //에러발생을 위한 code페이지
    	           	alert("오류가 발생하였습니다.");
				}                               
			});    			
        }
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
	
	function chkEmail(str) {
	    var regExp = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
	    if (regExp.test(str)) return true;
	    else return false;
	}
	
	function closePopup(dName) {
		$("#userName").val("");
		$("#userNameTxt").html("");
		$("#userId").val("");
		$("#userIdTxt").html('');
		$("#email").val("");
		$("#emailTxt").html('');
		$("#orgTxt").html("");
		$("#titleTxt").html("");
		$("#respTxt").html("");
		$("#userRole").selectOptions("");
		$("#userRole_label").html($("#userRole").selectedTexts());
		closeDialog(dName);
	}
	
	function fn_pwdInit(userId) {
		$.ajax({
			type: 'POST',
			url: '../user/pwdInitAjax',
			data: {
				"userId" : userId
			},
			dataType: 'json',
			async : true,
			success: function (data) {
				if(data.RESULT == 'F'){
					alert("비밀번호 초기화 오류가 발생했습니다.");
					return;
				} else {
					alert("비밀번호가 초기화 되었습니다.");
					getUserList($("#pageNo").val());
				}
			},error: function(XMLHttpRequest, textStatus, errorThrown){
				alert('처리중 오류가 발생 하였습니다. 잠시 후 다시 시도 해주십시오.\n' +'errorCode : ' + textStatus );
			}
		});
	}
	
</script>
<input type="hidden" name="pageNo" id="pageNo" value="${paramVO.pageNo}">
<div class="wrap_in" id="fixNextTag">
	<span class="path">
		사용자관리&nbsp;&nbsp;<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		관리자&nbsp;&nbsp;<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">BBQ 연구소</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative">
			<span class="title_s">user management</span>
			<span class="title">사용자 관리</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button type="button" class="btn_circle_red" onClick="openDialog('open');">&nbsp;</button>
					</li>
				</ul>
			</div>
		</h2>
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
				<div class="search_box" >
					<ul>
						<li style=" width:100%">
							<dt>검색조건</dt>
							<dd style="width:700px;">
								<div class="selectbox ml5" style="width:180px;">  
									<label for="dept" id="deptL">부서</label> 
									<select id="dept" name="dept">
										<option value="">전체</option>
										<c:forEach  items="${deptList}" var = "dept">
											<option value="${dept.itemCode}">${dept.itemName}</option>
										</c:forEach>										
									</select>
								</div>
								
								<div class="selectbox ml5" style="width:180px;">  
									<label for="team" id="teamL">팀</label> 
									<select id="team" name="team">
										<option value="">전체</option>
										<c:forEach  items="${teamList}" var = "team">
										<option value="${team.itemCode}">${team.itemName}</option>
										</c:forEach>
									</select>
								</div>
								
								<div class="selectbox ml5" style="width:180px;">  
									<label for="grade" id="gradeL">권한</label> 
									<select id="grade" name="grade">
										<option value="">전체</option>
										<c:forEach  items="${gradeList}" var = "grade">
										<option value="${grade.itemCode}">${grade.itemName}</option>
										</c:forEach>
									</select>
								</div>
							</dd>
						</li>
						<li style=" width:100%">
							<dt>검색어</dt>
							<dd style="width:700px;">
								<input type="text" class="ml5" name="searchValue" id="searchValue" style="width:180px;"/>
							</dd>
						</li>
						
					</ul>
					<div class="fr pt5 pb10">
						<button type="button" class="btn_con_search"  onClick="goSearch();"><img src="/resources/images/btn_icon_search.png" style="vertical-align:middle;"/> 검색</button>
						<button type="button" class="btn_con_search" onClick="goClear();"><img src="/resources/images/btn_icon_refresh.png" style="vertical-align:middle;"/> 검색 초기화</button>
					</div>
				</div>
				<div class="main_tbl">
					<table class="tbl01">
						<colgroup>
							<col width="10%">
							<col width="8%">
							<col width="10%">
							<col width="15%">
							<col width="10%">
							<col width="8%">
							<col width="8%">
							<col width="12%">
							<col />
						</colgroup>
						<thead>
							<tr>
								<th>이름</th>
								<th>아이디</th>
								<th>권한</th>
								<th>부서</th>
								<th>직책</th>
								<th>직급</th>
								<th>관리자</th>
								<th>생성일</th>
								<th>사용자설정</th>
							</tr>
						</thead>
						<tbody  id="userList">
						</tbody>
					</table>
					<div class="page_navi mt10" id="page_navi">
					</div>
				</div>
				<div class="btn_box_con">
					<!-- <button type="button" class="btn_admin_red" onClick="openDialog('open');">사용자 등록</button>  -->
				</div>
				<hr class="con_mode"/>
			</div>
	</section>	
</div>	

<!-- 자재 생성레이어 start-->
<div class="white_content" id="open">
	<div class="modal" style="	width: 700px;margin-left:-350px;height: 450px;margin-top:-200px;">
		<h5 style="position:relative">
			<span class="title">사용자 수정</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closePopup('open')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
			<ul>
				<li class="pt10">
					<dt>이름</dt>
					<dd>
						<input type="hidden" name="userName" id="userName"/> 
						<div id="userNameTxt"></div>
					</dd>
				</li>
				<li>
					<dt>아이디</dt>
					<dd>
						<input type="hidden" name="userId" id="userId"/>
						<span id="userIdTxt"></span>
					</dd>
				</li>
				<li>
					<dt>메일 주소</dt>
					<dd>
						<input type="hidden"  name="email" id="email"/>
						<span id="emailTxt"></span>
					</dd>
				</li>
				<li>
					<dt>부서</dt>
					<dd>
						<div id="orgTxt"></div>
					</dd>
				</li>
				<li>
					<dt>직책</dt>
					<dd class="pr20 pb10">
						<div id="titleTxt"></div>
					</dd>
				</li>
				<li>
					<dt>직급</dt>
					<dd class="pr20 pb10">
						<div id="respTxt"></div>
					</dd>
				</li>
				<li>
					<dt>권한</dt>
					<dd class="pr20 pb10">
							<div class="selectbox" style="width:150px"> 
								<label for="userRole" id="userRole_label">선택하세요</label>
								<select name="userRole" id="userRole">
									<option value="">선택하세요</option>
									<c:forEach  items="${roleList}" var="role">
									<option value="${role.ROLE_IDX}">${role.ROLE_NAME}</option>
									</c:forEach>
								</select>
							</div>							
						</dd>
				</li>
			</ul>
		</div>
		<div class="btn_box_con">
			<!--  <button class="btn_admin_red" id="create" onclick="javascript:inserUser();">저장</button> --> 
			<button class="btn_admin_red" id="update" onclick="javascript:updateUser();">수정</button> 
			<button class="btn_admin_gray" onclick="closePopup('open')"> 취소</button>
		</div>
	</div>
</div>
<!-- 자재 생성레이어 close-->
