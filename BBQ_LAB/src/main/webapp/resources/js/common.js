//숫자 + 도트만  입력 가능
function clearNoNum(obj){
	var needToSet = false;
	var numStr = obj.value;
	var temps = numStr.split("."); //소수점 체크를 위해 입력값을 '.'을 기준으로 나누고 temps는 배열이됨
	var CaretPos = doGetCaretPosition(obj); //input field에서의 캐럿의 위치를 확인
	if(2 < temps.length){ //배열 사이즈가 2보다 크면, '.' 가 두개 이상인 경우임.
		var tempIdx = 0;
		numStr = "";
		for(i=0;i<temps.length;i++) {
			numStr += temps[i];   //최종 문자에 현재 스트링을 합한다.
		}
		needToSet = true;
		alert("소수점은 두개이상 입력 하시면 안됩니다.");
	} 
	if((/[^\d.]/g).test(numStr)) {  //숫자 '.'  이외 엔 없는지 확인 후 있으면 replace
		numStr = numStr.replace(/[^\d.]/g,"");
		CaretPos--;
		alert("입력은 숫자와 소수점 만 가능 합니다.");
		//('.')
		needToSet = true;
	} 
	if ((/^\./g).test(numStr)){ //첫번째가 '.' 이면 .를 삭제
		numStr = numStr.replace(/^\./g, "");
		alert("소수점이 첫 글자이면 안됩니다.");
		needToSet = true;
	}
	if(needToSet) { //변경이 필요할 경우에만 셋팅함.
		obj.value = numStr;
		setCaretPosition(obj, CaretPos)
	}
}

//숫자만 입력 가능
function clearNoNumNoDot(obj){
	var needToSet = false;
	var numStr = obj.value;
	var CaretPos = doGetCaretPosition(obj); //input field에서의 캐럿의 위치를 확인
	if((/[^\d]/g).test(numStr)) {  //숫자 '.'  이외 엔 없는지 확인 후 있으면 replace
		numStr = numStr.replace(/[^\d]/g,"");
		CaretPos--;
		alert("입력은 숫자만 가능 합니다.");
		needToSet = true;
	} 
	if(needToSet) { //변경이 필요할 경우에만 셋팅함.
		obj.value = numStr;
		setCaretPosition(obj, CaretPos)
	}
}

//input field에서의 캐럿의 위치를 리턴함.
function doGetCaretPosition (ctrl){
	var CaretPos = 0;
	if (document.selection){//IE
		ctrl.focus ();
		var Sel = document.selection.createRange ();
		Sel.moveStart ('character', -ctrl.value.length);
		CaretPos = Sel.text.length;
	}else if (ctrl.selectionStart || ctrl.selectionStart == '0'){// Firefox support
		CaretPos = ctrl.selectionStart;
	}
	return (CaretPos);
}

//input field에 캐럿의 위치를 지정함.
function setCaretPosition(ctrl, pos){
	if(ctrl.setSelectionRange){
		ctrl.focus();
		ctrl.setSelectionRange(pos,pos);
	}else if (ctrl.createTextRange){
		var range = ctrl.createTextRange();
		range.collapse(true);
		range.moveEnd('character', pos);
		range.moveStart('character', pos);
		range.select();
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

function nvl(str, defaultStr){
    
    if(typeof str == "undefined" || str == null || str == "" || str == "null")
        str = defaultStr ;
     
    return str ;
}

function openDialog(elementID){
	$('#'+elementID).fadeIn(200);
}

function closeDialog(elementID){
	$('#'+elementID).hide();
}

function applyDatePicker(elementId){
	$('#'+elementId).datepicker({
		dateFormat: 'yy-mm-dd',
		buttonImage: '/resources/images/btn_calendar.png',
		buttonImageOnly: true,
		buttonText: "선택",  
		showOn: 'both',
		showMonthAfterYear: true,
		showOtherMonths: false,
		dayNames: ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'],
		dayNamesMin: ['일', '월', '화', '수', '목', '금', '토'],
		monthNames: [ "1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],
		monthNamesShot: [ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
		showOtherMonths: true,
		yearSuffix: "년",
		beforeShow: function(input) {
		    var i_offset= $(input).offset(); //클릭된 input의 위치값 체크
		    var height = $(document).scrollTop();
		    var top_offset = i_offset.top-height+input.offsetHeight;
		    
		    setTimeout(function(){
		    	$('#ui-datepicker-div').css({'top':top_offset, 'bottom':''});
		    })
		}
	})
	$('.ui-datepicker-trigger').css('margin-left', '5px');
	$('.ui-datepicker-trigger').css('cursor', 'pointer');
}

function applyMonthPicker(elementId){
	$('#'+elementId).datepicker({
		dateFormat: 'yy-mm',
		buttonImage: '/resources/images/btn_calendar.png',
		buttonImageOnly: true,
		buttonText: "선택",
		showOn: 'both',
		showMonthAfterYear: true,
		showOtherMonths: false,
		dayNames: ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'],
		dayNamesMin: ['일', '월', '화', '수', '목', '금', '토'],
		monthNames: [ "1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],
		monthNamesShot: [ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
		showOtherMonths: true,
		yearSuffix: "년",
		// changeMonth: true,
		// changeYear: true,
		beforeShow: function(input) {
			var i_offset= $(input).offset(); //클릭된 input의 위치값 체크
			var height = $(document).scrollTop();
			var top_offset = i_offset.top-height+input.offsetHeight;

			setTimeout(function(){
				$('#ui-datepicker-div').css({'top':top_offset, 'bottom':''});
			})
		}
	})
	$('.ui-datepicker-trigger').css('margin-left', '5px');
	$('.ui-datepicker-trigger').css('cursor', 'pointer');
}

function appendInput(form, name, value){
	var a = document.createElement('input');
	a.setAttribute('name', name);
	a.setAttribute('value', value);
	$(form).append(a);
}

function getCurrentDate(){
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();

	if(dd<10) {
	    dd='0'+dd
	} 

	if(mm<10) {
	    mm='0'+mm
	} 

	today = yyyy+'-'+mm+'-'+dd;
	
	return today;
}

function restoreStr(str){
	//str = str.replace(/\n/gi, "<BR>");
	str = str.replace(/\r/gi, "");
	str = str.replace(/\&plusmn;/gi, "±");
	str = str.replace(/\&excl;/gi, "!");
	str = str.replace(/\&num\;/gi, "#");
	str = str.replace(/\&dollar\;/gi, "$");
	str = str.replace(/\&percnt\;/gi, "%");
	str = str.replace(/\&lpar\;/gi, "(");
	str = str.replace(/\&rpar\;/gi, ")");
	str = str.replace(/\&ast\;/gi, "*");
	str = str.replace(/\&midast\;/gi, "*");
	str = str.replace(/\&plus\;/gi, "+");
	str = str.replace(/\&comma\;/gi, ",");
	str = str.replace(/\&period\;/gi, ".");
	str = str.replace(/\&sol\;/gi, "/");
	str = str.replace(/\&colon\;/gi, ":");
	str = str.replace(/\&semi\;/gi, ";");
	str = str.replace(/\&equals\;/gi, "=");
	str = str.replace(/\&quest\;/gi, "?");
	str = str.replace(/\&commat\;/gi, "@");
	str = str.replace(/\&lsqb\;/gi, "[");
	str = str.replace(/\&lbrack\;/gi, "[");
	str = str.replace(/\&rsqb\;/gi, "]");
	str = str.replace(/\&rbrack\;/gi, "]");
	str = str.replace(/\&Hat\;/gi, "^");
	str = str.replace(/\&lowbar\;/gi, "_");
	str = str.replace(/\&lcub\;/gi, "");
	str = str.replace(/\&lbrace\;/gi, "{");
	str = str.replace(/\&rcub\;/gi, "}");
	str = str.replace(/\&rbrace\;/gi, "}");
	str = str.replace(/\&rarr\;/gi, "→");
	str = str.replace(/\&darr\;/gi, "↓");
	str = str.replace(/\&larr\;/gi, "←");
	str = str.replace(/\&uarr\;/gi, "↑");
	str = str.replace(/\&gt\;/gi, ">");
	str = str.replace(/\&lt\;/gi, "<");
	str = str.replace(/\&quot\;/gi, '"');
	
	return str;
}

function restoreStrAmp(str) {
	str = str.replace(/&amp;/gi, "&");
	return str;
}