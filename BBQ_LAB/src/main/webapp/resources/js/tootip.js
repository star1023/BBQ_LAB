$(function(){
  var title_;
	var class_;
	var imgTag;

	$("a").hover(function(e) { 							// <a> hover 시 : mouseEnter

		title_ = $(this).attr("title");				// title을 변수에 저장
		class_ = $(this).attr("class");				// class를 변수에 저장
		$(this).attr("title","");							// title 속성 삭제 ( 기본 툴팁 기능 방지 )

		if(class_ == "img"){									// class_ 가 img라면,
			imgTag = "<img src='"+title_+"' width='100px' height:'100px' />"	// title_을 주소로 가진 <img>를 변수 imgTag에 저장
		}

		$("body").append("<div id='tip'></div>");		// div#tip 생성
																								// class_ 값에 따라 이미지 or 텍스트 출력 구분
			if (class_ == "img") {
				$("#tip").html(imgTag);
				$("#tip").css("width","100px");
			} else {
				$("#tip").css("width","300px");
				$("#tip").text(title_);
			}

			var pageX = $(this).offset().left -20;
			var pageY = $(this).offset().top - $("#tip").innerHeight();
			$("#tip").css({left : pageX + "px", top : pageY + "px"}).fadeIn(10);

	}, function() {													// <a> hover 시 : mouseLeave

		$(this).attr("title", title_);				// title 속성 반환
		$("#tip").remove();										// div#tip 삭제

	});
});