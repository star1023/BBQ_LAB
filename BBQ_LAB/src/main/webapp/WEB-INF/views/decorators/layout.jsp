<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<%@ page import="java.util.Date" %>

<html>
  <head>
    <!--title><sitemesh:write property='title'/></title-->
    <title>BBQ세계식문화과학기술원</title>    
    <sitemesh:write property='head'/>
    <link rel="shortcut icon" href="../resources/images/favicon.ico"/>
    <link href="../resources/css/common.css" rel="stylesheet" type="text/css" />
	<link href="../resources/css/board.css" rel="stylesheet" type="text/css" />
	<link href="../resources/css/layout.css" rel="stylesheet" type="text/css" />
	<link href="../resources/css/theme.css" rel="stylesheet" type="text/css" />
	<link href="../resources/css/loading.css" rel="stylesheet" type="text/css" />
	<link href="../resources/css/tooltip/tooltipster.bundle.min.css" rel="stylesheet" type="text/css" />
	<link href="../resources/css/tooltip/plugins/tooltipster/sideTip/themes/tooltipster-sideTip-light.min.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="../resources/js/jquery-ui-1.12.1/jquery-ui.min.css">
    <link href="../resources/css/jquery.timepicker.min.css" rel="stylesheet" type="text/css" />
	  <!-- TreeGrid css start -->
	  <link href="../resources/css/cnc_treegrid.css?v=2" rel="stylesheet" type="text/css" />
	  <link href="../resources/css/component.css?v=<%=System.currentTimeMillis() %>" rel="stylesheet" type="text/css" />
	  <!-- TreeGrid css end -->
    
    <script type="text/javascript" src="../resources/js/jquery-3.3.1.js"></script>
    <script type="text/javascript" src="../resources/js/jquery-3.3.1.js"></script>
	<script type="text/javascript" src="../resources/js/jquery.form.js"></script>
	<script type="text/javascript" src="../resources/js/jquery.loading.js"></script>
	<script type="text/javascript" src="../resources/js/jquery.selectboxes.js"></script>
	<script type="text/javascript" src="../resources/js/jquery-ui-1.12.1/jquery-ui.min.js"></script>
	<script type="text/javascript" src="../resources/js/classie.js"></script>
	<script type="text/javascript" src="../resources/js/modernizr.custom.js"></script>
	<script type="text/javascript" src="../resources/js/percent.js"></script>
	<script type="text/javascript" src="../resources/js/star.js"></script>
	<script type="text/javascript" src="../resources/js/common.js"></script>
	<script type="text/javascript" src="../resources/js/tooltip/tooltipster.bundle.min.js"></script>
	<script type="text/javascript" src="../resources/js/jquery.timepicker.min.js"></script>
	  <!-- TreeGrid javascript start -->
	  <script type="text/javascript" src="../resources/js/treegrid/GridE.js"></script>
	  <script type="text/javascript" src="../resources/js/treegrid/GridToolBarBtn.js"></script>
	  <!-- TreeGrid javascript end -->
	<script type="text/javascript"> 
		$(document).ready(function(){
			initTimer();
			var selectTarget = $('.selectbox select');
		 	selectTarget.on('blur', function(){
			$(this).parent().removeClass('focus');			
	 		});
			selectTarget.change(function(){
				var select_name = $(this).children('option:selected').text();
				$(this).siblings('label').text(select_name);
			});
		});
	</script> 
	<!-- 스크롤됬을때 메뉴 디자인 변경 --> 
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
						fixNext.addClass("pd_top_80");
					}else{
						barThis.removeClass("top_bar_fix");
						fixNext.removeClass("pd_top_80");
					}
	
				});
	
			})
	</script>
	<script>function stepchage(id,step){document.getElementById(id).className = step;}</script>
	<script>
		// 사용자로부터 마우스 또는 키보드 이벤트가 없을경우의   자동로그아웃까지의 대기시간, 분단위
		var iMinute = 180;
		 
		var iSecond = iMinute * 60 ;
		var timerchecker = null;
		 
		initTimer=function()
		{
			//사용자부터 마우스 또는 키보드 이벤트가 발생했을경우자동로그아웃까지의 대기시간을 다시 초기화
		    if(window.event)
		    {
				iSecond = iMinute * 60 ;
				clearTimeout(timerchecker);
		    }
		    if(iSecond > 0)
		    {
		    	 //$("#timer").html("&nbsp;" + Lpad(rHour, 2) + "시간 " + Lpad(rMinute, 2)+ "분 " + Lpad(rSecond, 2) + "초 ");
		    	 //alert("&nbsp;" + Lpad(rHour, 2) + "시간 " + Lpad(rMinute, 2)+ "분 " + Lpad(rSecond, 2) + "초 ");
		    	/////지정한 시간동안 마우스, 키보드 이벤트가 발생되지 않았을 경우
		      	iSecond--;
				timerchecker = setTimeout("initTimer()", 1000); // 1초 간격으로 체크
		   	}
		   	else
		   	{
		    	clearTimeout(timerchecker);				
				location.href = "../user/logout"; // 로그아웃 처리 페이지
			}
		}
		document.onclick = initTimer; /// 현재 페이지의 사용자 마우스 클릭이벤트 캡춰
		document.onkeypress = initTimer;/// 현재 페이지의 키보트 입력이벤트 캡춰
		document.onmousemove = initTimer;
		</script>
  </head>
  <body class="content_theme01" id="content_d">
  <div class="theme01" id="theme">
	<div class="wrap">
	<!-- wrap_in01/02 -->
	<!-- 클래스명 숫자에 따라 넓이값변경-->
		<div class="wrap_in01" id="width_wrap">		
		  	<jsp:include page="header.jsp" flush="true" />
		  	<div class="" id="body">
		    <sitemesh:write property='body'/>
		    </div>
		    <jsp:include page="footer.jsp" flush="true" />
    	</div>
  	</div> 
  	</div>
  	<div id="timer"></div> 
  </body>
</html>