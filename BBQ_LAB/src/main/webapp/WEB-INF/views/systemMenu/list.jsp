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
	
	function fn_loadAllMenu(){
		var URL = "../systemMenu/selectAllMenuListAjax"; 
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
		var oldTree = $("#jsTree").jstree(true);
		if( oldTree ) {
			oldTree.destroy();
		}
		$("#jsTree").jstree(
			{ 
				'core' : {
					'data' : data
					, 'check_callback': function (operation, node, parentNode, renameNodeText, more) {
		                // operation can be 'create_node', 'rename_node', 'delete_node', 'move_node' or 'copy_node'
		                // in case of 'rename_node' node_position is filled with the new node name
		                
		                
		                switch (operation) {
		                    case 'create_node':
		                        // 생성이 안되는 곳이면 이곳에서 체크		                        
		                        break;
		                    case 'rename_node':
				                var pId = parentNode.id;
				                var id = node.id;
				                var menuName = renameNodeText;
				                var level = node.parents.length;
				                console.log(pId);
				                console.log(id);
				                fn_insertMenu( pId, id, menuName, level );
		                        break;
		                    case 'delete_node':
		                    	//console.log("operation : "+operation);
				                //console.log(node);
				                //console.log(parentNode);
				                //console.log("renameNodeText : "+renameNodeText);
				                //console.log("more : "+more);
				                var id = node.id;
				                fn_delete(id);
				                break;
		                    case 'move_node' :
		                  		if( more.ref === undefined ) {
		                  			//console.log("operation : "+operation);
				                	//console.log(node);
				                	//console.log(parentNode);
				                	//console.log("renameNodeText : "+renameNodeText);
				                	//console.log(more);
				                	var id = node.id;
				                	var pId = parentNode.id;
				                	var level = node.parents.length;
		                  		}
		                    	break;
	                	}
		            }
				},
				"contextmenu": {
		            "items": function ($node) {
		                //var tree = $("#tree").jstree(true);
		                return {
		                    "create": {
		                        "separator_before": false,
		                        "separator_after": true,
		                        "_disabled": false,
		                        "label": "신규생성",
		                        "action": function (data) {
		                            var inst = $.jstree.reference(data.reference),
		                                obj = inst.get_node(data.reference);
		                            inst.create_node(obj, {}, "last", function (new_node) {
		                                setTimeout(function () { inst.edit(new_node); }, 0);
		                            });
		                        }
		                    },
		                    "remove": {
		                        "separator_before": false,
		                        "icon": false,
		                        "separator_after": false,
		                        "_disabled": false,
		                        "label": "삭제",
		                        "action": function (data) {
		                            var inst = $.jstree.reference(data.reference),
		                                obj = inst.get_node(data.reference);
		                            if( obj.parent != '#' ) {
		                            	if (inst.is_selected(obj)) {
			                                inst.delete_node(inst.get_selected());
			                            }
			                            else {
			                                inst.delete_node(obj);
			                            }
		                            } else {
		                            	alert("삭제할 수 없습니다.");
		                            }
		                        }
		                    }
		                };
		            }
		        },
				"plugins" : [ "wholerow", "contextmenu" ]
		   	}
		).bind("loaded.jstree",function(){
			 $(this).jstree("open_all");
		}).bind('select_node.jstree', function(e,data){
			fn_updateForm(data.node.id);
	    });
		//.bind("refresh.jstree",function(){
		//	
		//});
	}	
	
	function fn_insertMenu( pId, id, menuName, level ){
		$('#lab_loading').show();
		$.ajax({
			type:"POST",
			url:"../systemMenu/insertMenu2Ajax",
			data:{ 
				"pId" : pId
				, "id" : id
				, "menuName" : menuName
				, "level" : level
			},
			dataType:"json",
			success:function(data) {
				if( data.RESULT != 'S' ) {
					alert("오류가 발생했습니다.\n다시 등록해주세요.");
					//location.reload(true);
				} else {
					//fn_loadAllMenu();	
				}				
				fn_loadAllMenu();	
			},
			error:function(request, status, errorThrown){
			},
			complete:function(){
				$('#lab_loading').hide();
			}			
		});
	}
	
	function fn_loadList(pageNo) {
		$.ajax({
			type:"POST",
			url:"../systemMenu/menuListAjax",
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
						html += "	<td>"+item.menuName+"</td>";
						html += "	<td>"+nvl(item.pMenuName,'')+"</td>";
						html += "	<td>"+item.eMenuName+"</td>";
						html += "	<td>"+item.level+"</td>";
						html += "	<td>"+item.displayOrder+"</td>";
						html += "	<td>"+item.url+"</td>";
						html += "	<td>"+item.displayYn+"</td>";
						html += "	<td>";
						html += "		<ul class=\"list_ul\">";
						html += "			<li> <button class=\"btn_doc\" onClick=\"javascript:fn_updateForm('"+item.menuId+"')\"><img src=\"/resources/images/icon_doc03.png\"> 수정</button></li>";
						html += "			<li> <button class=\"btn_doc\" onClick=\"javascript:fn_delete('"+item.menuId+"')\"><img src=\"/resources/images/icon_doc04.png\"> 삭제</button></li>";
						html += "		</ul>";
						html += "	</td>";
						html += "</tr>";
					});				
				} else {
					$("#list").html(html);
					html += "<tr><td align='center' colspan='7'>데이터가 없습니다.</td></tr>";
				}			
				$("#list").html(html);
				$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
				$('#pageNo').val(data.navi.pageNo);
			},
			error:function(request, status, errorThrown){
				var html = "";
				$("#list").html(html);
				html += "<tr><td align='center' colspan='7'>오류가 발생하였습니다.</td></tr>";
				$("#list").html(html);
				$('.page_navi').html(data.navi.prevBlock+data.navi.pageList+data.navi.nextBlock);
				$('#pageNo').val(data.navi.pageNo);
			}			
		});	
	}
	
	function fn_changeLevel() {
		if( $("#level").selectedValues()[0] == "2" ) {
			var URL = "../systemMenu/pMenuListAjax";
			$.ajax({
				type:"POST", 
				url:URL,
				data:{
					"level" : $("#level").selectedValues()[0]
				},
				dataType:"json",
				async:false,
				success:function(data) {
					var list = data;
					$("#pMenuId").removeOption(/./);
					$("#pMenuId").addOption("", "전체", false);
					$("#pMenuId").attr("disabled", false);
					$.each(list, function( index, value ){ //배열-> index, value
						$("#pMenuId").addOption(value.menuId, value.menuName, false);
					});
				},
				error:function(request, status, errorThrown){
					alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
					$("#pMenuId").removeOption(/./);
					$("#pMenuId_label").html("선택");
					$("#pMenuId").attr("disabled", true);
				}			
			});			
		} else {
			$("#pMenuId").removeOption(/./);
			$("#pMenuId_label").html("선택");
			$("#pMenuId").attr("disabled", true);
		}
	}
	
	function fn_insert(){
		if( $("#level").selectedValues()[0] == '' ) {
			alert("메뉴 레벨을 선택해주세요.");
			$("#level").focus();
			return;
		} 
		
		if( $("#level").selectedValues()[0] > 1 ) {
			if( $("#pMenuId").selectedValues()[0] == '' ) {
				alert("메뉴 레벨을 선택해주세요.");
				$("#level").focus();
				return;
			}
		}
		
		if( !chkNull($("#menuName").val()) ) {
			alert("메뉴명을 입력하여 주세요.");
			$("#menuName").focus();
			return;
		} 
		
		if( !chkNull($("#eMenuName").val()) ) {
			alert("영문 메뉴명을 입력하여 주세요.");
			$("#menuName").focus();
			return;
		} 
		
		if( !chkNull($("#displayOrder").val()) ) {
			alert("표시순서를 입력하여 주세요.");
			$("#displayOrder").focus();
			return;
		} 
		
		if( !chkNull($("#url").val()) ) {
			alert("URL을 입력하여 주세요.");
			$("#url").focus();
			return;
		} 
		$('#lab_loading').show();
		var URL = "../systemMenu/insertMenuAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"level":$("#level").selectedValues()[0]
				,"pMenuId": $("#pMenuId").selectedValues()[0]
				,"menuName": $("#menuName").val()
				,"eMenuName": $("#eMenuName").val()
				,"displayOrder": $("#displayOrder").val()
				,"url": $("#url").val()
				,"useYn": $("input[name='useYn']:checked").val()
				,"displayYn": $("input[name='displayYn']:checked").val()
			},
			dataType:"json",
			success:function(result) {
				if( result.RESULT == 'S' ) {
					alert("등록되었습니다.");
					fn_clearDialog();
					fn_loadList(1);
					fn_loadAllMenu();
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
	
	function fn_updateForm(menuId) {
		$('#lab_loading').show();
		var URL = "../systemMenu/selectMenuDataAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"menuId":menuId
			},
			dataType:"json",
			success:function(data) {
				if( data.menuId == '' || data.menuId == null ) {
					alert("삭제된 메뉴입니다.");					
				} else {
					$("#menuId").val(data.menuId);
					$("#level").selectOptions(""+data.level);
					$("#level_label").html($("#level option:checked").text());
					//$("#manageTp option:checked").text()
					if( data.level > 1 ) {
						fn_changeLevel();
						$("#pMenuId").selectOptions(""+data.pMenuId);
						$("#pMenuId_label").html($("#pMenuId option:checked").text());
					} else {
						$("#pMenuId").removeOption(/./);
					}
					$("#menuName").val(data.menuName);
					$("#eMenuName").val(data.eMenuName);
					$("#displayOrder").val(data.displayOrder);
					$("#url").val(data.url);
					$("input[name='useYn'][value='"+data.useYn+"']").prop("checked",true);
					$("input[name='displayYn'][value='"+data.displayYn+"']").prop("checked",true);
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
		if( !chkNull($("#menuName").val()) ) {
			alert("메뉴명을 입력하여 주세요.");
			$("#menuName").focus();
			return;
		} 
		
		if( !chkNull($("#eMenuName").val()) ) {
			alert("영문 메뉴명을 입력하여 주세요.");
			$("#menuName").focus();
			return;
		} 
		
		if( !chkNull($("#displayOrder").val()) ) {
			alert("표시순서를 입력하여 주세요.");
			$("#displayOrder").focus();
			return;
		} 
		
		if( !chkNull($("#url").val()) ) {
			alert("URL을 입력하여 주세요.");
			$("#url").focus();
			return;
		} 
		$('#lab_loading').show();
		var URL = "../systemMenu/updateMenuAjax";
		$.ajax({
			type:"POST",
			url:URL,
			data:{
				"menuId":$("#menuId").val()
				,"level":$("#level").selectedValues()[0]
				,"pMenuId": $("#pMenuId").selectedValues()[0]
				,"menuName": $("#menuName").val()
				,"eMenuName": $("#eMenuName").val()
				,"displayOrder": $("#displayOrder").val()
				,"url": $("#url").val()
				,"useYn": $("input[name='useYn']:checked").val()
				,"displayYn": $("input[name='displayYn']:checked").val()
			},
			dataType:"json",
			success:function(result) {
				if( result.RESULT == 'S' ) {
					alert("수정되었습니다.");
					fn_clearDialog();
					fn_loadList(1);
					fn_loadAllMenu();
				} else {
					fn_loadAllMenu();
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
	
	
	function fn_delete(menuId) {
		$('#lab_loading').show();
		var URL = "../systemMenu/deleteMenuAjax";
		$.ajax({
			type:"POST", 
			url:URL,
			data:{
				"menuId" : menuId
			},
			dataType:"json",
			async:false,
			success:function(result) {
				if( result.RESULT == 'S' ) {
					alert("삭제되었습니다.");
					fn_loadList(1);
					//location.reload(true);
					fn_loadAllMenu();
				} else {
					fn_loadAllMenu();
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
		$("#menuId").val("");
		$("#level").selectOptions("");
		$("#level_label").html("선택");
		$("#pMenuId").removeOption(/./);
		$("#pMenuId_label").html("선택");
		$("#pMenuId").attr("disabled", true);
		$("#menuName").val("");
		$("#eMenuName").val("");
		$("#displayOrder").val("");
		$("#url").val("");
		$("input[name='useYn'][value='Y']").prop("checked",true);
		$("input[name='displayYn'][value='Y']").prop("checked",true);
		$("#create").show();
		$("#update").hide();
	}
	
	
	function chkNum(obj) {
		var numStr = obj.value;
	    var regex = /^[0-9]*$/; // 숫자만 체크
	    if( !regex.test(numStr) ) {
	    	numStr = numStr.replace(/[^\d]/g,"");
	    	$(obj).val(numStr);
	    	alert("숫자만 입력가능합니다.");	    	
	    	return;
	    }	    
	}
	
	function paging(pageNo) {
		fn_loadList(pageNo);
	}
	
</script>
<div class="wrap_in" id="fixNextTag">
	<span class="path">메뉴관리&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">System Menu management</span>
			<span class="title">메뉴관리</span>
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
			<div class="main_tbl">
				<table class="tbl01">
					<colgroup id="list_colgroup">
						<col width="15%">
						<col width="15%">
						<col width="15%">
						<col width="8%">
						<col width="8%">
						<col width="17%">
						<col width="8%">
						<col width="14%">
					</colgroup>
					<thead id="list_header">
						<tr>
							<th>메뉴명</th>
							<th>상위메뉴명</th>
							<th>영문메뉴명</th>
							<th>메뉴레벨</th>
							<th>표시순서</th>
							<th>URL</th>
							<th>표시여부</th>
							<th>설정</th>
						<tr>
					</thead>
					<tbody id="list">						
					</tbody>
				</table>
				<div class="page_navi  mt10">
				</div>
			</div>
			<div style="height: 420px; width:300px; overflow-x: hidden; overflow-y: auto;">
				<div id="jsTree"></div> 
			</div>
			<div class="main_tbl">
				<div class="list_detail">
					<ul>
						<li class="pt10" style="display:none">
							<dt>Level</dt>
							<dd>
								<div class="selectbox req" style="width:147px;">  
									<label for="level" id="level_label">선택</label> 
									<select id="level" id="level" onChange="fn_changeLevel();">
										<option value="">선택</option>
										<option value="1">1레벨</option>
										<option value="2">2레벨</option>
										<!--option value="3">3레벨</option-->
									</select>
								</div>
							</dd>
						</li>
						<li style="display:none">
							<dt>상위코드</dt>
							<dd>
								<div class="selectbox" style="width:147px;">  
									<label for="pMenuId" id="pMenuId_label">선택</label> 
									<select id="pMenuId" id="pMenuId" disabled>
									</select>
								</div>								
							</dd>
						</li>
						<li>
							<dt>메뉴명</dt>
							<dd>
								<input type="hidden" name="menuId" id="menuId">
								<input type="text"  style="width:302px;" class="req" name="menuName" id="menuName" placeholder="한글메뉴명"/>
							</dd>
						</li>
						<li>
							<dt>영문메뉴명</dt>
							<dd>
								<input type="text"  style="width:302px;" class="req" name="eMenuName" id="eMenuName" placeholder="영문메뉴명"/>
							</dd>
						</li>
						<li>
							<dt>표시순서</dt>
							<dd>
								<input type="text"  style="width:302px;" class="req" name="displayOrder" id="displayOrder" placeholder="숫자만 입력하세요." onkeyup="chkNum(this)"/>
							</dd>
						</li>
						<li>
							<dt>URL</dt>
							<dd>
								<input type="text"  style="width:302px;" class="req" name="url" id="url" placeholder="메뉴실행 URL"/>
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
							<dt>메뉴표시여부</dt>
							<dd>
								<input type="radio" name="displayYn" id="r3" value="Y" checked/><label for="r3"><span></span>표시</label>
								<input type="radio" name="displayYn" id="r4" value="N"/><label for="r4"><span></span>미표시</label>
							</dd>
						</li>
					</ul>
				</div>
			</div>
			<div class="btn_box_con">
				<button class="btn_admin_red" id="create" onclick="javascript:fn_insert();" style="display:none">메뉴등록</button> 
				<button class="btn_admin_red" id="update" onclick="javascript:fn_update();" style="display:none">메뉴수정</button>
				<button class="btn_admin_gray" onclick="closeDialog('open')" style="display:none"> 취소</button>
			</div>
	 		<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
	</section>
</div>

<!-- 메뉴 생성 레이어 start-->
<!--
<div class="white_content" id="open">
	<input type="hidden" name="menuId" id="menuId">
	<div class="modal" style="	width: 550px;margin-left:-350px;height: 400px;margin-top:-200px;">
		<h5 style="position:relative">
			<span class="title">메뉴 수정</span>
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
					<dt>메뉴코드</dt>
					<dd>
						<input type="text" value="" class="req" style="width:302px;" name="menuCode" id="menuCode"  placeholder="메뉴코드"/> 
					</dd>
				</li>
				
				<li class="pt10" style="display:none">
					<dt>Level</dt>
					<dd>
						<div class="selectbox req" style="width:147px;">  
							<label for="level" id="level_label">선택</label> 
							<select id="level" id="level" onChange="fn_changeLevel();">
								<option value="">선택</option>
								<option value="1">1레벨</option>
								<option value="2">2레벨</option>								
							</select>
						</div>
					</dd>
				</li>
				<li style="display:none">
					<dt>상위코드</dt>
					<dd>
						<div class="selectbox" style="width:147px;">  
							<label for="pMenuId" id="pMenuId_label">선택</label> 
							<select id="pMenuId" id="pMenuId" disabled>
							</select>
						</div>
					</dd>
				</li>
				<li>
					<dt>메뉴명</dt>
					<dd>
						<input type="text"  style="width:302px;" class="req" name="menuName" id="menuName" placeholder="한글메뉴명"/>
					</dd>
				</li>
				<li>
					<dt>영문메뉴명</dt>
					<dd>
						<input type="text"  style="width:302px;" class="req" name="eMenuName" id="eMenuName" placeholder="영문메뉴명"/>
					</dd>
				</li>
				<li>
					<dt>표시순서</dt>
					<dd>
						<input type="text"  style="width:302px;" class="req" name="displayOrder" id="displayOrder" placeholder="숫자만 입력하세요." onkeyup="chkNum(this)"/>
					</dd>
				</li>
				<li>
					<dt>URL</dt>
					<dd>
						<input type="text"  style="width:302px;" class="req" name="url" id="url" placeholder="메뉴실행 URL"/>
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
					<dt>메뉴표시여부</dt>
					<dd>
						<input type="radio" name="displayYn" id="r3" value="Y" checked/><label for="r3"><span></span>표시</label>
						<input type="radio" name="displayYn" id="r4" value="N"/><label for="r4"><span></span>미표시</label>
					</dd>
				</li>
			</ul>
		</div>
		<div class="btn_box_con">
			<button class="btn_admin_red" id="create" onclick="javascript:fn_insert();">메뉴등록</button> 
			<button class="btn_admin_red" id="update" onclick="javascript:fn_update();" style="dispaly:none">메뉴수정</button>
			<button class="btn_admin_gray" onclick="closeDialog('open')"> 취소</button>
		</div>
	</div>
</div>
 -->
<!-- 자재 생성레이어 close-->