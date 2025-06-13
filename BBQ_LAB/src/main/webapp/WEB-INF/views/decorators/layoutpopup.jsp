<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<html>
  <head>
    <title><sitemesh:write property='title'/></title>
    <sitemesh:write property='head'/>
    <link rel="shortcut icon" href="../resources/images/favicon.ico"/>
    <link rel="stylesheet" href="../resources/js/jquery-ui-1.12.1/jquery-ui.min.css">
    <link href="../resources/css/common.css" rel="stylesheet" type="text/css" />
    <link href="../resources/css/layout_pop.css" rel="stylesheet" type="text/css" />
    <link href="../resources/css/board.css" rel="stylesheet" type="text/css" />
    <link href="../resources/css/print.css" rel="stylesheet" type="text/css" />
    <link href="../resources/css/loading.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../resources/js/jquery-3.3.1.js"></script>
	<script type="text/javascript" src="../resources/js/jquery.form.js"></script>
	<script type="text/javascript" src="../resources/js/jquery.selectboxes.js"></script>
	<script type="text/javascript" src="../resources/js/jquery-ui-1.12.1/jquery-ui.min.js"></script>
	<script type="text/javascript" src="../resources/js/classie.js"></script>
	<script type="text/javascript" src="../resources/js/modernizr.custom.js"></script>
	<script type="text/javascript" src="../resources/js/percent.js"></script>
	<script type="text/javascript" src="../resources/js/star.js"></script>
	<script type="text/javascript" src="../resources/js/common.js"></script>
  </head>
  <body>  
  <script type="text/javascript">
			$(document).ready(function(){
				
				// 로딩 시 스크롤 막기
				$('#fixNextTag').before('<div id="lab_loading" style="display:none"><div class="lab_loader"></div></div>');
				$('#lab_loading').on('scroll touchmove mousewheel', function(event) {
					event.preventDefault();
					event.stopPropagation();
					return false;
				});
				
				var topBar = $("#topBar").offset();
	
				$(window).scroll(function(){
					
					var docScrollY = $(document).scrollTop()
					var barThis = $("#topBar")
					var fixNext = $("#fixNextTag")
	
					if( docScrollY > topBar.top ) {
						barThis.addClass("top_bar_fix");
						//fixNext.addClass("pd_top_80");
					}else{
						barThis.removeClass("top_bar_fix");
						//fixNext.removeClass("pd_top_80");
					}	
				});	
			})
	</script>
	<div id="topBar"></div>
  <div class="wrap_pop" id="fixNextTag">
 		<div class="wrap_in02">
 			<div class="wrap_in" >
    			<sitemesh:write property='body'/>
	  		</div>
		</div>
	</div>	
  </body>