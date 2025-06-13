<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="strUtil" uri="/WEB-INF/tld/strUtil.tld"%>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ page session="false" %>
<title>원료관리</title>
<link href="../resources/css/tree.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="../resources/js/jstree.js"></script>
<script type="text/javascript">
$(document).ready(function(){
	fn_loadList(1);
});


var selectedArr = new Array();

function fn_loadList(pageNo) {
	var URL = "../material/selectErpMaterialListAjax";
	var viewCount = $("#viewCount").selectedValues()[0];
	if( viewCount == '' ) {
		viewCount = "10";
	}
	$("#list").html("<tr><td align='center' colspan='7'>조회중입니다.</td></tr>");
	$('.page_navi').html("");
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"searchType" : $("#searchType").selectedValues()[0]
			, "searchValue" : $("#searchValue").val()
			, "viewCount":viewCount
			, "pageNo":pageNo},
		dataType:"json",
		success:function(data) {
			var html = "";
			if( data.totalCount > 0 ) {
				$("#list").html(html);
				data.list.forEach(function (item) {
					html += "<tr>";
					html += "	<td>"+nvl(item.SAP_CODE,'&nbsp;')+"</td>";
					html += "	<td><div class=\"ellipsis_txt tgnl\"><a href=\"#\" onClick=\"fn_view('"+item.SAP_CODE+"')\">"+nvl(item.NAME,'&nbsp;')+"</div></td>";
					html += "	<td>"+item.UNIT+"</td>";
					html += "	<td>"+nvl(item.KEEP_CONDITION_TXT,'&nbsp;')+"</td>";
					html += "	<td>";
					if( item.TOTAL_WEIGHT != "" ) {
						html += nvl(item.TOTAL_WEIGHT,'&nbsp;');
						if( item.TOTAL_WEIGHT_UNIT != "" ) {
							html += " ("+nvl(item.TOTAL_WEIGHT_UNIT,'&nbsp;')+")";
						}
					}
					html += "	</td>";
					html += "	<td><div class=\"ellipsis_txt tgnl\">"+nvl(item.STANDARD,'&nbsp;')+"</div></td>";
					html += "	<td>"+nvl(item.EXPIRATION_DATE,'&nbsp;')+"</td>";
					html += "</tr>"					
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

function fn_goSearch(){
	fn_loadList(1);
}

function paging(pageNo) {
	fn_loadList(pageNo);
}

function fn_view(sapCode) {
	var URL = "../material/selectErpMaterialDataAjax";
	$.ajax({
		type:"POST",
		url:URL,
		data:{
			"sapCode" : sapCode
		},
		dataType:"json",
		async:false,
		success:function(data) {
			$("#sapCodeTxt").html(data.SAP_CODE);
			$("#nameTxt").html(data.NAME);
			$("#unitTxt").html(data.UNIT);
			$("#keepTxt").html(data.KEEP_CONDITION_TXT);
			$("#weightTxt").html(data.TOTAL_WEIGHT);
			$("#standardTxt").html(data.STANDARD);
			$("#sizeTxt").html(data.WIDTH+"("+data.WIDTH_UNIT+")"+" / "+data.LENGTH+"("+data.LENGTH_UNIT+")"+" / "+data.HEIGHT+"("+data.HEIGHT_UNIT+")");
			$("#originTxt").html(data.ORIGIN);
			$("#expDateTxt").html(data.EXPIRATION_DATE);
			$("#cdTxt").html(data.CD_ACCT);
			openDialog('open3');
		},
		error:function(request, status, errorThrown){
				alert("오류가 발생하였습니다.\n다시 시도하여 주세요.");
		}			
	});
}

function fn_searchClear() {
	$("#searchType").selectOptions("");
	$("#searchType_label").html("선택");
	$("#searchValue").val("");
	$("#viewCount").selectOptions("");
	$("#viewCount_label").html("선택");
}
</script>
<input type="hidden" name="pageNo" id="pageNo" value="">
<div class="wrap_in" id="fixNextTag">
	<span class="path">상품조회&nbsp;&nbsp;
		<img src="/resources/images/icon_path.png" style="vertical-align:middle"/>&nbsp;&nbsp;
		<a href="#">${strUtil:getSystemName()}</a>
	</span>
	<section class="type01">
	<!-- 상세 페이지  start-->
		<h2 style="position:relative"><span class="title_s">SAP Material management</span>
			<span class="title">상품조회</span>
			<div  class="top_btn_box">
				<ul>
					<li>
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
						<dt>키워드</dt>
						<dd >
							<!-- 초기값은 보통으로 -->
							<div class="selectbox" style="width:100px;">  
								<label for="searchType" id="searchType_label">선택</label> 
								<select name="searchType" id="searchType">
									<option value="">선택</option>
									<option value="searchName">원료명</option>
									<option value="searchSapCode">원료코드</option>
								</select>
							</div>
							<input type="text" name="searchValue" id="searchValue" value="" style="width:180px; margin-left:5px;">
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
					<button type="button" class="btn_con_search" onClick="javascript:fn_goSearch();"><img src="/resources/images/btn_icon_search.png" style="vertical-align:middle;"/> 검색</button>
					<button type="button" class="btn_con_search" onClick="javascript:fn_searchClear();"><img src="/resources/images/btn_icon_refresh.png" style="vertical-align:middle;"/> 검색 초기화</button>					
				</div>
			</div>
			<div class="main_tbl">
				<table class="tbl01">
					<colgroup id="list_colgroup">
						<col width="10%">
						<col />
						<col width="15%">
						<col width="10%">
						<col width="10%">
						<col width="22%">
						<col width="15%">
					</colgroup>
					<thead id="list_header">
						<tr>
							<th>상품코드</th>
							<th>싱픔명</th>
							<th>품목단위</th>
							<th>보관조건</th>
							<th>중량</th>
							<th>규격</th>
							<th>유통기한</th>
						<tr>
					</thead>
					<tbody id="list">						
					</tbody>
				</table>
				<div class="page_navi  mt10">
				</div>
			</div>
			<div class="btn_box_con"> 
			</div>
	 		<hr class="con_mode"/><!-- 신규 추가 꼭 데려갈것 !-->
		</div>
	</section>
</div>

<!-- 자재 조회레이어 start-->
<div class="white_content" id="open3">
	<div class="modal" style="	width: 800px;margin-left:-400px;height: 450px;margin-top:-200px;">
		<h5 style="position:relative">
			<span class="title">상품 상세 정보</span>
			<div  class="top_btn_box">
				<ul>
					<li>
						<button class="btn_madal_close" onClick="closeDialog('open3')"></button>
					</li>
				</ul>
			</div>
		</h5>
		<div class="list_detail">
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
							<th style="border-left: none;">상품코드</th>
							<td id="sapCodeTxt">

							</td>
							<th style="border-left: none;">상품명</th>
							<td id="nameTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">품목단위</th>
							<td colspan="3" id="unitTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">보관조건</th>
							<td id="keepTxt">

							</td>
							<th style="border-left: none;">중량</th>
							<td id="weightTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">규격</th>
							<td colspan="3" id="standardTxt">
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">사이즈(W/L/H)</th>
							<td colspan="3" id="sizeTxt">
							</td>
						</tr>
						<tr>
							<th style="border-left: none;">원산지</th>
							<td id="originTxt">

							</td>
							<th style="border-left: none;">소비기한</th>
							<td id="expDateTxt">

							</td>
						</tr>
						<tr>
							<th style="border-left: none;">부가가치세 코드</th>
							<td id="cdTxt" colspan="3">

							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>			
		<div class="btn_box_con">
			<button class="btn_admin_gray" onclick="closeDialog('open3')"> 닫기</button>
		</div>
	</div>
</div>
<!-- 자재 생성레이어 close-->
