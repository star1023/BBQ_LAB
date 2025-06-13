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
		fn_loadAllCategory();
	});	
	
	function fn_loadAllCategory(){
		var URL = "../systemCategory/selectCategoryAjax";
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
		                //console.log("operation : "+operation);
		                
		                switch (operation) {
		                    case 'create_node':
		                        // 생성이 안되는 곳이면 이곳에서 체크
		                        
		                        break;
		                    case 'rename_node':
				                var pId = parentNode.id;
				                var id = node.id;
				                var categoryName = renameNodeText;
				                var level = node.parents.length;
				                //console.log("pId : "+pId);
				                //console.log("id : "+id);
				                //console.log("categoryName : "+categoryName);
				                //console.log("level : "+level);
				                fn_insertCategory( pId, id, categoryName, level );
				                break;
		                    case 'delete_node':
		                    	//console.log("operation : "+operation);
				                //console.log(node);
				                //console.log(parentNode);
				                //console.log("renameNodeText : "+renameNodeText);
				                //console.log("more : "+more);
				                var id = node.id;
				                var pId = node.parent;
				                fn_deleteCategory(id, pId);
				                break;
		                    case 'move_node' :
		                    	if( more.ref === undefined ) {
		                  			//console.log("operation : "+operation);
				                	//console.log(node);
				                	//console.log(parentNode);
				                	//console.log("renameNodeText : "+renameNodeText);
				                	//console.log(more);
				                	if(parentNode.id == '#'){ 
				                		//location.reload(true);
				                		fn_loadAllCategory();
				                		break;
				                	}
				                	//console.log("여기를 호출할까?");
				                	var id = node.id;
				                	var pId = parentNode.id;
				                	var level = node.parents.length;
				                	//fn_updateCategory(id, pId, renameNodeText, level);
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
		                    "rename": {
		                        "separator_before": false,
		                        "separator_after": false,
		                        "_disabled": false,
		                        "label": "이름수정",
		                        "action": function (data) {
		                            var inst = $.jstree.reference(data.reference),
		                                obj = inst.get_node(data.reference);
		                            inst.edit(obj);
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
		                    },
		                    "up": {
		                        "separator_before": false,
		                        "icon": false,
		                        "separator_after": false,
		                        "_disabled": false,
		                        "label": "위로이동",
		                        "action": function (data) {
		                        	var inst = $.jstree.reference(data.reference),
	                                obj = inst.get_node(data.reference);
		                        	//console.log(inst);
		                        	//console.log(obj);
		                        	var id = obj.id;
		                        	var pId = obj.parent;
		                        	var text = obj.text;
		                        	//fn_up(id, pId);
		                        	fn_move(id, pId, "UP");
		                        }
		                    },
		                    "down": {
		                        "separator_before": false,
		                        "icon": false,
		                        "separator_after": false,
		                        "_disabled": false,
		                        "label": "아래로이동",
		                        "action": function (data) {
		                        	var inst = $.jstree.reference(data.reference),
	                                obj = inst.get_node(data.reference);
		                        	//console.log(inst);
		                        	//console.log(obj);
		                        	var id = obj.id;
		                        	var pId = obj.parent;
		                        	var text = obj.text;
		                        	//fn_down(id, pId);
		                        	fn_move(id, pId, "DOWN");
		                        }
		                    }
		                };
		            }
		        },
				//"plugins" : [ "wholerow", "contextmenu", "dnd" ]
		        "plugins" : [ "wholerow", "contextmenu" ]
		   	}
		).bind("loaded.jstree",function(){
			 //$(this).jstree("open_all");
		});
		//.bind("refresh.jstree",function(){
		//	
		//});
	}
	
	function fn_insertCategory( pId, id, categoryName, level ) {
		$('#lab_loading').show();
		$.ajax({
			type:"POST",
			url:"../systemCategory/insertCategoryAjax",
			data:{ 
				"pId" : pId
				, "id" : id
				, "categoryName" : categoryName
				, "level" : level
			},
			dataType:"json",
			success:function(data) {
				//console.log(data);
				if( data.RESULT != 'S' ) {
					alert("오류가 발생했습니다.\n다시 등록해주세요.");
					//location.reload(true);					
				} else {
					//fn_loadAllMenu();	
				}
				fn_loadAllCategory();
			},
			error:function(request, status, errorThrown){
			},
			complete:function(){
				$('#lab_loading').hide();
			}
		});
	}
	
	function fn_deleteCategory(id, pId) {
		$('#lab_loading').show();
		$.ajax({
			type:"POST",
			url:"../systemCategory/deleteCategoryAjax",
			data:{ 
				"id" : id
				, "pId" : pId
			},
			dataType:"json",
			success:function(data) {
				//console.log(data);
				if( data.RESULT != 'S' ) {
					alert("오류가 발생했습니다.\n다시 등록해주세요.");
					//location.reload(true);					
				} else {
					//fn_loadAllMenu();
				}
				fn_loadAllCategory();
			},
			error:function(request, status, errorThrown){
			},
			complete:function(){
				$('#lab_loading').hide();
			}		
		});
	}
	
	function fn_updateCategory(id, pId, displayOrder, level){
		$('#lab_loading').show();
		$.ajax({
			type:"POST",
			url:"../systemCategory/updateCategoryAjax",
			data:{
				"id" : id
				, "pId" : pId
				, "displayOrder" : displayOrder
				, "level" : level
			},
			dataType:"json",
			success:function(data) {
				//console.log(data);
				if( data.RESULT != 'S' ) {
					alert("오류가 발생했습니다.\n다시 등록해주세요.");
					//location.reload(true);					
				} else {
					//fn_loadAllMenu();	
				}
				fn_loadAllCategory();
			},
			error:function(request, status, errorThrown){
			},
			complete:function(){
				$('#lab_loading').hide();
			}			
		});
	}
	
	function fn_insert() {
		if( !chkNull($("#categoryName").val()) ) {
			alert("카테고리명을 입력하여 주세요.");
			$("#categoryName").focus();
			return;
		} else {
			$('#lab_loading').show();
			$.ajax({
				type:"POST",
				url:"../systemCategory/insertCategoryAjax",
				data:{
					"pId" : ''
					, "categoryName" : $("#categoryName").val()
					, "level" : '1'
				},
				dataType:"json",
				success:function(data) {
					console.log(data);
					if( data.RESULT != 'S' ) {
						alert("오류가 발생했습니다.\n다시 등록해주세요.");
					} else {
					}
					fn_loadAllCategory();
				},
				error:function(request, status, errorThrown){
				},
				complete:function(){
					$('#lab_loading').hide();
				}			
			});
		}		
	}
	
	function fn_move(id, pId, div){
		$.ajax({
			type:"POST",
			url:"../systemCategory/updateMoveCategoryAjax",
			data:{
				"id" : id
				, "pId" : pId
				, "div" : div				
			},
			dataType:"json",
			success:function(data) {
				if( data.RESULT == 'S' ) {
					alert("수정되었습니다.");
				} else if( data.RESULT == 'F' ) {
					alert(data.MESSAGE);
				} else {
					alert("오류가 발생했습니다.\n다시 등록해주세요.");
				}
				fn_loadAllCategory();
			},
			error:function(request, status, errorThrown){
			}			
		});
	}
	
</script>
<input type="hidden" name="selectedRoleIdx" id="selectedRoleIdx">
<div class="wrap_in" id="fixNextTag">
	<span class="path">카테고리 관리&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">Category management</span>
			<span class="title">카테고리 관리</span>
		</h2>
		<div class="group01" >
			<div class="title"><!--span class="txt">연구개발시스템 공지사항</span--></div>
			<div class="tab02">
			</div>
			<div class="main_tbl">
				<table class="tbl01">
				</table>				
				<div class="page_navi  mt10">
				</div>
			</div>
			<div style="height: 420px; overflow-x: hidden; overflow-y: auto;">
				<div id="jsTree"></div> 
			</div>
			<div class="main_tbl">
				<div class="list_detail">
					<ul>
						<li>
							<dt>카테고리명</dt>
							<dd>
								<input type="text"  style="width:302px;" class="req" name="categoryName" id="categoryName" placeholder="1레벨 카테고리 이름을 입력해주세요."/>
							</dd>
						</li>						
					</ul>
				</div>
			</div>
			<div class="btn_box_con">
				<button class="btn_admin_red" id="create" onclick="javascript:fn_insert();">카테고리 등록</button>
			</div>
	 		<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
		
	</section>
</div>