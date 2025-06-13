var WebCube_xmlhttp = {};
var BrowserType;
var CurrentBrowser = "IE";
var WebCube_ajaxCnt = 0;
var WebCube_URL = "http://127.0.0.1:4567/";
var WebCube_maxCnt = 10; 			//ProtectUrl 함수 재귀호출 횟수 
var WebCube_reloadTime = 700; 		// ProtectUrl 재귀호출 타임
var SetupCheckResult = -1;				//설치 예외 리턴 값

/////////////////////////////////////////////////////////////////////////////////////////////////////////

window.onload = StartPolicy;
var SyncRetCode;
var WebCubeObj = {};
var domain = location.host;

//ProtectURL 저장 변수
//20.02.07 보호대상 URL 변수 값 도메인+포트까지로 변경
WebCubeObj.PolicyPageUrl = domain;

//CmdMethod 설정하는 함수
WebCubeObj.CmdMethod = function(s1, s2, s3, s4, s5, s6, s7)
{	
	var cmdStr = 'CmdMethod('+s1+',"'+escape(s2)+'",'+s3+',"'+escape(s4)+'",'+s5+','+s6+',"'+escape(s7)+'")';		
	SendCommandFunc(cmdStr);
	return SyncRetCode;		
};

//SetPolicy 설정하는 함수
WebCubeObj.SetPolicy = function(spStr)
{	
	var CmdStr = 'SetPolicy("' + escape(spStr) + '")';
	SyncCommnadFunc(CmdStr);			
};

// 특정 클래스 위에서 마우스 팝업 허용
WebCubeObj.SetHtmlPolicy = function(spStr)
{	
	var cmdStr = 'SetHtmlPolicy("' + escape(spStr) + '","")';
	SendCommandFunc(cmdStr);
};

// 임시 인터넷 폴더 보호
WebCubeObj.ProtectCacheFile = function(spStr)
{	
	var cmdStr = 'ProtectCacheFile("' + escape(spStr) + '","")';
	SendCommandFunc(cmdStr);	
};

// 임시 인터넷 파일 보호 시 가상 드라이브로 보호하지 않는 예외 확장자 등록
WebCubeObj.FileexpandExcept = function(spStr)
{
	var cmdStr = 'FileexpandExcept("' + escape(spStr) + '","")';
	SendCommandFunc(cmdStr);	
};

// URL이 변경되지 않는 웹페이지의 경우 해당 페이지 입력
WebCubeObj.SetCurrentPageID = function(spStr)
{	 
	var cmdStr = 'SetCurrentPageID("' + escape(spStr) + '","")';
	SendCommandFunc(cmdStr);	
};

// 팝업메뉴 차단 기능 제어
WebCubeObj.EnablePopupMenu = function(spStr)
{	
	var cmdStr = 'EnablePopupMenu("' + escape(spStr) + '","")';
	SendCommandFunc(cmdStr);	
};

// FileexpandExcept로 등록된 확장자 초기화
WebCubeObj.FileexpandInit = function(spStr)
{	
	var cmdStr = 'FileexpandInit("' + escape(spStr) + '","")';
	SendCommandFunc(cmdStr);	
};

// Activex 의 버전을 올리지 않고 최신파일로 업그레이드 하기 위한 함수
WebCubeObj.UpdateModule = function(spStr)
{	
	var cmdStr = 'UpdateModule("' + escape(spStr) + '","")';
	SendCommandFunc(cmdStr);	
};

// 원격 접속, 화면 캡춰, 클립보드 정책을 제어하는 StartRemote_Server 함수
WebCubeObj.StartRemoteService = function(spStr)
{	
	var cmdStr = 'StartRemoteService("' + escape(spStr) + '","")';
	SendCommandFunc(cmdStr);	
};

// 클라이언트의 맥주소를 리턴받는 함수
WebCubeObj.GetWebCubeInfo = function(spStr, spStr1)
{	
	var cmdStr = 'GetWebCubeInfo("' + escape(spStr) + '","")';
	SendCommandFunc(cmdStr);
	return SyncRetCode;	
};

// 암호화 정책 사용 루틴
WebCubeObj.SetEnc = function(spStr, b)
{	
	var cmdStr = 'SetEnc(' + spStr + ')';
	SendCommandFunc(cmdStr, b);
	
	if(b && !WebCube_UseDefaultPolicy)
	{
		console.log("WebCubeAgent_I -- 108");
		if(WebCube_Go_NextPage)location.href = WebCube_NextPage;
	}
};

WebCubeObj.Command = "";

//CmdMethod, SetPolicy, SetProtect 문자를 조합하고 StartPolicy 실행
WebCubeObj.SetProtect = function(spStr)
{	
	var cmdStr = 'SetProtect(' + spStr + ')';
	SendCommandFunc(cmdStr);
	
	if(SyncRetCode == 0)
	{
		console.log("WebCubeAgent_I -- 123");
		if(WebCube_Go_NextPage)location.href = WebCube_NextPage;
	}
	else if(SyncRetCode.substr(0,1) == "-")
	{
		ShowErrorMessage(SyncRetCode.split("-")[1]);
	}		
};	

function SendCommandFunc(cmdStr, b)
{	
	if(WebCube_UseAdminPage)
	{	
		WebCubeObj.Command += cmdStr;
		if(cmdStr.substr(0,10) == "SetProtect" || b)
		{
			SyncCommnadFunc(cmdStr);
			return SyncRetCode;
		}
		else
		{
			SyncRetCode = 0;
		}
	}
	else
	{	
		SyncRetCode = undefined;
		SyncCommnadFunc(cmdStr);	
	}
}

//20.06.18 MAC OS 체크 함수
function WebCube_CheckMAC()
{
		if (WebCube_MODE_MAC == "M")
		{
			location.href = WebCube_MacOS;
			return;
		}
		else if (WebCube_MODE_MAC == "P")
		{
			console.log("WebCubeAgent_I -- 165");
			if(WebCube_Go_NextPage)location.href = WebCube_NextPage;
			return;
		} 
		else (WebCube_MODE_MAC == "X")
		{
			ShowErrorMessage(505);
			return;
		}
}
	
function CheckMode()
{
	if(CurrentBrowser == "IE")
	{
		if(WebCube_MODE_IE == "A")
		{
			return 0;
		}
		else if(WebCube_MODE_IE != "N")
		{
			return 499;
		}
		
	}
	else
	{
		if(WebCube_MODE_M != "N")
		{
			return 499;
		}
	}
}

function ocxStart()
{	
	WebCubeObj = Obj;
	InputPolicyInfo();	
}

//21.11.10 설치 예외처리 함수
function WebCube_SetupCheck()
{
	try
	{
		var strParam = WebCube_AdminPageObj.setupByPass;
		strParam += "?";
		strParam += "domain=" + WebCube_AdminPageObj.domain;
		strParam += "&";
		strParam += "company=" + WebCube_AdminPageObj.company;
		strParam += "&";
		strParam += "module=" + WebCube_AdminPageObj.module;
		strParam += "&";
		strParam += "id=" + WebCube_AdminPageObj.id;

		WebCube_xmlhttp.Setup = GetAjaxObj();
		WebCube_xmlhttp.Setup.open("GET",strParam ,false);
		WebCube_xmlhttp.Setup.onreadystatechange = function(){
			
			if(WebCube_xmlhttp.Setup.readyState == 4 && WebCube_xmlhttp.Setup.status == 200)
			{
				if('Y' == WebCube_xmlhttp.Setup.responseText)
				{
					console.log("WebCubeAgent_I -- 227");
					if(WebCube_Go_NextPage)location.href = WebCube_NextPage;
					SetupCheckResult = 0;
				}
				else
				{
					SetupCheckResult = -1;
				}
			}
			else if(WebCube_xmlhttp.Setup.readyState == 4 && (WebCube_xmlhttp.Setup.status == 0 || WebCube_xmlhttp.Setup.status >= 200))
			{
				SetupCheckResult = -1;
			}
		};
		WebCube_xmlhttp.Setup.send();		
	}
	catch(e)
	{
		SetupCheckResult = -2;
	}
}

function StartPolicy()
{	
	//21.11.10 설치 예외처리 루틴 
	if(WebCube_DoNotSetup == true)
	{
		WebCube_SetupCheck();
		
		if(SetupCheckResult == 0)
		{
			return;
		}
	}
	//20.06.18 접속 기기 확인
	var MobileFilter = "win16|win32|win64|mac os|macintel";
	
	if(navigator.platform)
	{
		if(0 > MobileFilter.indexOf(navigator.platform.toLowerCase()))
		{
			//모바일로 접속한 경우 바이패스         
			//alert("모바일");     
			if ( WebCube_MODE_MOBILE == "P") 
			{
				console.log("WebCubeAgent_I -- 272");
				if(WebCube_Go_NextPage)location.replace(WebCube_NextPage);
				//alert("바이패스");
				return;
			}
		}
	}
		
	//20.06.25 MAC OS 체크 후 해당 변수값에 따라 리다이렉션
	var convertType = navigator.userAgent.toLowerCase();

	if (convertType.indexOf("mac os") > -1)
	{
		WebCube_CheckMAC();
		return;
	}
	
	WebCubeWaitMsg(true);

	BrowserType = CheckBrowser();
	
	if(BrowserType > 500)
	{
		ShowErrorMessage(BrowserType);
		return;
	}
	else if(BrowserType >= 6 && BrowserType <= 11)
	{
		CurrentBrowser = "IE";
	}
	else if(BrowserType == 100)
	{
		ShowErrorMessage(499);
		return;
	}
	else
	{
		CurrentBrowser = BrowserType;
	}
	
	var ret = CheckMode();
	if(ret == 499)
	{		
		ShowErrorMessage(ret);
		return;
	}//else if(ret == 0)	//ActiveX 사용으로 더 이상 진행안함
		//return;
		
	if(location.protocol.substring(4,5) == "s")
	{
		WebCube_URL = "https://127.0.0.1:4568/";	
	}
		VersionCheck();
}

function SyncCommnadFunc(cmdStr)
{	
	var Command = 'SetUrl(' + WebCubeObj.PolicyPageUrl + ')';
	
	Command += "Browser(" + CurrentBrowser + ")";
	
	if(WebCube_UseAdminPage)
	{	
		var AdminPageUserInfoStr = '{"AdminPageUrl":"' + WebCube_AdminPageObj.AdminPageUrl + '",';
		AdminPageUserInfoStr += '"module":"' + WebCube_AdminPageObj.module + '",';
		AdminPageUserInfoStr += '"id":"' + WebCube_AdminPageObj.id + '",';
		AdminPageUserInfoStr += '"domain":"' + WebCube_AdminPageObj.domain + '",';
		AdminPageUserInfoStr += '"company":"' + WebCube_AdminPageObj.company + '"}';
		Command += "AdminPageSetInfo(" + AdminPageUserInfoStr + ")";

		if(typeof(WebCube_ServerWaitTime) == "number")
		{
			Command += 'ServerWaitTime(' + WebCube_ServerWaitTime + ')';
		}
		
		if(WebCube_EncryptParam)
		{
			Command += 'EncryptParam(Y)';
		}
		
		if(WebCube_UseDefaultPolicy)
		{
			if(WebCube_ShowDefaultPolicyNotify)
			{
				Command += 'ShowNotify("' + escape(WebCube_DefaultPolicyNotifyMessage) + '",' + WebCube_DefaultPolicyNotifyMessageShowTime + ')'
					 + 'NotifySize(' + WebCube_DefaultPolicyNotifyMessageWidth + ',' + WebCube_DefaultPolicyNotifyMessageHeight + ')';
			}
			Command += 'DefaultPolicy{' + WebCubeObj.Command + '}';
		}
	}
	else
	{
		Command += cmdStr;
	}
	
	var AjaxObj = GetAjaxObj();

	try
	{
		AjaxObj.open("POST",WebCube_URL + "WebCube/RetCmd?" + Command, false);
		AjaxObj.onreadystatechange = function()
		{	
			if(AjaxObj.readyState == 4 && AjaxObj.status == 200)
			{
				
				WebCubeWaitMsg(false);
				
				SyncRetCode = AjaxObj.responseText.split("SyncRetCode(")[1].split(")")[0];				
				
			}
			else if(AjaxObj.readyState == 4 && (AjaxObj.status == 0 || AjaxObj.status >= 200))
			{
				setBlock("", WebCube_SetupUI);	
			}
		};
		AjaxObj.send();		
	}
	catch(e)
	{
		setBlock("", WebCube_SetupUI);
	}
}

function VersionCheck()
{	
	try
	{
		WebCube_xmlhttp.Version = GetAjaxObj();
		WebCube_xmlhttp.Version.open("POST",WebCube_URL + "WebCube/Version" ,false);
		WebCube_xmlhttp.Version.onreadystatechange = function()
		{		
			if(WebCube_xmlhttp.Version.readyState == 4 && WebCube_xmlhttp.Version.status == 200)
			{	
				if(WebCubeAgentVersion > WebCube_xmlhttp.Version.responseText)
				{	//설치된 버전보다 서버 버전이 더 높은 경우 업데이트
					setBlock("update", WebCube_SetupUI);	
				}
				else //정상
				{
					InputPolicyInfo();
				}

			}
			else if(WebCube_xmlhttp.Version.readyState == 4 && (WebCube_xmlhttp.Version.status == 0 || WebCube_xmlhttp.Version.status >= 200))
			{ 	
				setBlock("", WebCube_SetupUI);	
			}
		};
		WebCube_xmlhttp.Version.send();		
	}
	catch(e)
	{
		setBlock("", WebCube_SetupUI);
	}
}

//브라우저 체크(IE 버전, 엣지, 스윙 브라우저)
function CheckBrowser()
{
	/*if(navigator.userAgent.toLowerCase().match(/windows/i)){
	}else */
	
	if(navigator.userAgent.toLowerCase().match(/android/i))
	{
		return 503;
	}
	else if(navigator.userAgent.toLowerCase().match(/iphone|ipad|ipod/i))
	{
		return 504;
	}
	else if(navigator.userAgent.toLowerCase().match(/mac os/i))
	{
		return 505;
	}
	if(navigator.userAgent.toLowerCase().indexOf("swing") > -1 )
	{
		return 501;
	}
	//20.3.30 네이버 웨일브라우저, 크롬기반 브라우저로 접속시 "506" 리턴	 , 21.11.10 MS 엣지 추가
	else if(navigator.userAgent.toLowerCase().indexOf("whale") > -1 || navigator.userAgent.toLowerCase().indexOf("vivaldi") > -1
			|| navigator.userAgent.toLowerCase().indexOf("midori") > -1 || navigator.userAgent.toLowerCase().indexOf("maxthon") > -1
			|| navigator.userAgent.toLowerCase().indexOf("ubrowser") > -1) 
	{
		return 506;		
	}
	else if(navigator.userAgent.toLowerCase().indexOf("edge") > -1)
	{
		//return "EDGE";
		return 506;
	}
	else if(navigator.userAgent.toLowerCase().indexOf("edg") > -1)
	{
		return "EDGEC";		
	}
	else if(navigator.userAgent.toLowerCase().indexOf("trident") > -1 )
	{
		var trident = navigator.userAgent.match(/Trident\/(\d.\d)/i);
		switch (trident[1]) 
		{
			case "8.0" :
				return 11;
			case "7.0" :
				return 11;
			case "6.0" :
				return 10;
			case "5.0" :
				return 9;
			case "4.0" :
				return 8;
			default :
				return 11;
		}
	}
	else if(navigator.appVersion.toLowerCase().indexOf("msie 6") > -1)
	{
		return 6;
	}
	else if(navigator.appVersion.toLowerCase().indexOf("msie 7") > -1)
	{
		return 7;
	}
	else if(navigator.appVersion.toLowerCase().indexOf("w-browser") > -1)
	{
		return "W-Browser";
	}
	else if(navigator.userAgent.toLowerCase().indexOf("chrome") > -1 && navigator.vendor.toLowerCase().indexOf("google") > -1
		&& navigator.userAgent.toLowerCase().indexOf("opr") <= -1 && navigator.userAgent.toLowerCase().indexOf("x64") > -1)
	{
		return "Chrome64";
	}
	else if(navigator.userAgent.toLowerCase().indexOf("chrome") > -1 && navigator.vendor.toLowerCase().indexOf("google") > -1
		&& navigator.userAgent.toLowerCase().indexOf("opr") <= -1)
	{
		return "Chrome";
	}
	else if(navigator.userAgent.toLowerCase().indexOf("mozilla") > -1 && navigator.userAgent.toLowerCase().indexOf("firefox") > -1
		&& navigator.userAgent.toLowerCase().indexOf("opr") <= -1)
	{
		return "Firefox";
	}
	else if(navigator.userAgent.toLowerCase().indexOf("mozilla") > -1 && navigator.userAgent.toLowerCase().indexOf("safari") > -1
		&& navigator.userAgent.toLowerCase().indexOf("opr") <= -1)
	{
		return "Safari";
	}
	else if(navigator.userAgent.toLowerCase().indexOf("mozilla") > -1 && navigator.userAgent.toLowerCase().indexOf("opr") > -1)
	{
		return "Opera";		
	}
	else
	{
		return 100;
	}			  
}

//정책 url 비교 시 도메인만 비교
function GetDomain(str1, str2)
{	
	var str1Obj = {
		source:str1,
		array:str1.split('/'),
		url:""
	};
	var str2Obj = {
		source:str2,
		array:str2.split('/'),
		url:""
	};
	
	if(str1Obj.array[0] == "http:" || str1Obj.array[0] == "https:" || str1Obj.array[0] == " ttp:")
	{
		str1Obj.url = str1Obj.array[2];		
	}
	else
	{
		str1Obj.url = str1Obj.array[0];
	}
	
	if(str2Obj.array[0] == "http:" || str2Obj.array[0] == "https:" || str1Obj.array[0] == " ttp:")
	{
		str2Obj.url = str2Obj.array[2];		
	}
	else
	{
		str2Obj.url = str2Obj.array[0];
	}
	
	if(str1Obj.url == str2Obj.url)
	{
		return true;
	}
	else
	{		
		return false;
	}
}

//Error Message 생성
function ShowErrorMessage(errMsg)
{
	var msg;
	
	 switch (parseInt(errMsg))
	 {
		case(499) :
			msg = "지원하는 브라우저가 아닙니다. 다른 브라우저를 이용해 주시기 바랍니다.";
			break;
		case(500) :
			msg = "웹페이지 정보가 잘못되었습니다.";
			break;
		case(501) :
			msg = "스윙 브라우저는 지원하지 않습니다. 다른 브라우저를 이용해 주시기 바랍니다.";
			break;
		case(502) :
			msg = "Edge 브라우저는 지원하지 않습니다. 다른 브라우저를 이용해 주시기 바랍니다.";
			break;
		case(503) :
			msg = "ANDROID 에서는 사용이 불가합니다.";
			break;
		case(504) :
			msg = "IOS 에서는 사용이 불가합니다.";
			break;
		case(505) :
			msg = "MAC 에서는 사용이 불가합니다.";
			break;
		case(506) :	//20.3.30 네이버 웨일브라우저, 크롬기반 브라우저로 접속시 설치페이지로 리다이렉션
			msg = "해당 브라우저는 지원하지 않습니다. 익스플로러 또는 크롬 브라우저를 이용해주시기 바랍니다.";
			break;		
		case(205) : // 2.1.0.6 이전 버전
			msg = "Terminal 서비스 사용 오류입니다.";
			break;
		case(206) : // 2.1.0.6 이전 버전
			msg = "Mirror 드라이브 사용 오류입니다.";
			break;
		case(308) : 
			msg = "SetProtect 파라미터가 잘못 되었습니다.";
			break;
		case(310) :
			msg = "Active 스크립트 실행 오류입니다.";
			break;
		case(311) :
			msg = "지원 가능한 브라우저가 아닙니다.";
			break;
		case(312) :
			msg = "캐쉬 관련 오류입니다.";
			break;
		case(313) :
			msg = "인젝션 실패 오류입니다.";
			break;
		case(314) :
			msg = "WebCount.dll 오류입니다.";
			break;
		case(315) :
			msg = "모듈 체크 오류입니다.";
			break;
		case(316) :
			msg = "익스플로러 메뉴 초기화 오류입니다.";
			break;
		case(317) :
			msg = "캡쳐 모듈 오류입니다.";
			break;
		case(318) :
			msg = "API Hook 실패입니다.";
			break;
		case(320) : // 2.1.0.6 이전 버전
			msg = "원격 제어 프로그램 사용 오류입니다.";
			break;
		case(321) :
			msg = "VMWare 사용 오류입니다.";
			break;
		case(322) :
			msg = "Virtual PC 사용 오류입니다.";
			break;
		case(323) :
			msg = "Terminal Service 사용 오류입니다.";
			break;
		case(324) :
			msg = "Mirror 드라이브 사용 오류입니다.";
			break;
		case(325) :
			msg = "원격 프로그램 사용 오류입니다.";
			break;
		case(1001) :
			msg = "관리자 서버로 전송된 데이터가 정확하지 않습니다.";
			break;		
		case(1002) :
			msg = "서버에서 응답이 오지 않습니다. 관리자에게 문의해 주시기 바랍니다.";
			break;
		case(1003) :
			msg = "사용자 정보가 정확하지 않습니다. 사용자 정보를 정확히 입력해 주시기 바랍니다.";
			break;
		case(1005) :
			msg = "복호화 실패!";
			break;
		case(1114) :
			msg = "브라우저가 정상적으로 작동되지 않습니다. 브라우저 종료 후 재실행하여 주시기 바랍니다.";
			break;			
		default :				
			if(WebCube_UseAdminPage)
			{				
				var reasonCode = errMsg.toString().substr(0, 3);
				var operaterCode = errMsg.toString().substr(3, 5);
				
				if(reasonCode == 200)
				{			
					msg = "관리자 DB Error";
					break;
				}
				else if(reasonCode == 300)
				{			
					msg = "관리자 서버 Error";
					break;
				}
				else if(operaterCode == 41)
				{			
					msg = "모듈 정보가 잘못 입력되었습니다.";
					break;
				}
				else if(operaterCode == 42)
				{			
					msg = "도메인 정보가 잘못 입력되었습니다.";
					break;
				}
				else if(operaterCode == 43)
				{			
					msg = "회사코드가 잘못 입력되었습니다.";
					break;
				}
				else if(operaterCode == 48)
				{			
					msg = "서버에서 알 수 없는 오류가 발생되었습니다.";
					break;
				}
				else if(operaterCode == 49)
				{			
					msg = "데이터가 없습니다.";
					break;
				}
				else if(operaterCode == 11)
				{			
					msg = "정책 정보가 잘못되었습니다.";
					break;
				}
				else{								
					msg = "알 수 없는 오류입니다.";
					break;					
				}
			}
			else			
				msg = "접근 오류 입니다.";
	}
	alert(msg + "(error code:" + errMsg + ")");
	setBlock("", WebCube_SetupUI);
}


function GetAjaxObj()
{
	var obj;
	
	if(BrowserType >= 6 && BrowserType <= 7)	// code for IE8이하
	{
		obj = new ActiveXObject("Microsoft.XMLHTTP");
	}
	else	// code for IE9+, Firefox, Chrome, Opera, Safari
	{
		obj = new XMLHttpRequest();
	}
	return obj;
}