//Setup 이미지 동적 생성
function getLangCode()
{
	var getLang = navigator.userLanguage || navigator.language;
	
	getLang = getLang.toLowerCase();	// 19.06.11 소문자로 변경
	getLang = getLang.substring(0, 2);	// 19.06.11 앞의 2글자만 받아오기
	
	return getLang;
}

var bSetup = false;
function setBlock(param, param1)
{
	if(bSetup)
		return;
	bSetup = true;
	
	try{
		WebCubeWaitMsg(false);	
	}catch(e){}
		
	if(param == null || param == "")
		param = "first";
	
	var msg;
	if(param == "update")
		msg = "<br>보안 프로그램의 <font color=brown>최신 버전</font>이 업데이트 됐습니다.<BR><font color=brown>다운로드 후 재설치</font>를 하셔야 정상적인 이용이 가능합니다.<br><br>";
	else if(param == "timeout"){
		msg = "<br>서버와의 통신이 원활하지 않습니다.<BR><font color=brown>F5키를 눌러 새로고침</font>해 주시기 바랍니다.<BR>새로고침 후에도 <font color=orange>계속 문제 시 재설치</font>해 주시기 바랍니다.<br><br>";
	}
	else	
		msg = "<br>고객님의 안전한 사용을 위하여 보안프로그램을 설치하셔야 합니다.<br><br>";
	
	//Case SetupUI 4
	var NewMsg;
	if(param == "update")
		NewMsg = "<font color=dimgray>보안 프로그램의 <font color=brown>최신 버전</font>이 업데이트 됐습니다.<BR><font color=brown>다운로드 후 재설치</font>를 하셔야 정상적인 이용이 가능합니다.</font>";
	else if(param == "timeout"){
		NewMsg = "<font color=dimgray>서버와의 통신이 원활하지 않습니다.<BR><font color=brown>F5키를 눌러 새로고침</font>해 주시기 바랍니다.<BR>새로고침 후에도 <font color=orange>계속 문제 시 재설치</font>해 주시기 바랍니다.</font>";
	}
	else	
		NewMsg = "<font color=dimgray>고객님의 안전한 사용을 위하여 <br><font color=brown>보안프로그램을 설치</font>하셔야 합니다.</font>";		
	
	var str;	
	var SetupFile = "WebCubeAgentSetup.exe";
	if(CurrentBrowser == "IE" && WebCube_MODE_IE == "A"){
		var clintInfoObj = window.clientInformation;
		var browser = clintInfoObj.platform;
		//alert(navigator.appVersion);
		if((clintInfoObj.appVersion.toLowerCase().indexOf("x64") < 0) &&(clintInfoObj.appVersion.toLowerCase().indexOf("wow64") < 0))
		{
			SetupFile = "WebCubeSetup.exe";
		}
		else
		{
			if(browser.toLowerCase() != "win64") 
			{
				SetupFile = "WebCubeSetupwow.exe";
			}
			else
			{
				SetupFile = "WebCubeSetup64.exe";
			}
		}
	}

	if(getLangCode() == "ko"){	// 19.06.11 한글일때 설치UI
		if(param1 == 0){
			str = '<BR><BR><BR><BR>';
			str += '<TABLE border=2 bordercolor=#6083C3 width=600 align=center>';
			str += '<TR height=30 bgcolor=#6083C3>';
			str += '<TD align=center>';
			str += '<font color=#FFFFFF face=돋움><B>';
			str += msg;
			str += '</B></font></TD></TR><TR><TD align=center>';	
			str += '<BR><FONT color=#5274BE face=돋움 size=5 style=font-weight:bold>웹 보안 프로그램 다운로드</FONT><BR><BR>';
			
			str += '<a href="' + WebCube_SetupFilePath + SetupFile + '">';

			str += '<img src="' + WebCube_ImageFilePath + 'bt_download.png" border="0" style="cursor:hand;"></a><BR><BR>';					
			str += '<FONT color=#5274BE><B>본 사이트는 웹 보안 프로그램이 설치되어야만 이용하실 수 있습니다.<BR>';
			str += '고객님의 정보 보호를 위하여 웹 보안 프로그램을 설치해 주시기 바랍니다.<BR></FONT>';
			str += '&nbsp;&nbsp;<IMG src="' + WebCube_ImageFilePath + 'plugin_bg.gif" width=150 height=50></TD></TR></TABLE></html>';	
		}	
		else if(param1 == 1){
			//19.10.11 설치페이지 리다이렉션시 다운로드창 자동실행
			//location.href = "./WebCube/components/WebCubeAgentSetup.exe";
			str = '<link href="'+WebCube_ImageFilePath + 'pantople.css" rel="stylesheet">';
			str += '<div id="bg">';		
			str += '<img src="'+WebCube_ImageFilePath + 'teruten1_bg.jpg" alt="bg"></div>';
			if(param == "update" || param == "timeout"){
				str += '<div id="msg">';
				str += '<font color=#999999 face="돋움" fontSize="20"><B>';
				str += msg;
				str += '</B></font></div>';
			}
			str += '<div id="bt">';
			str += '<a href="' + WebCube_SetupFilePath + SetupFile + '">';
			str += '<img src="'+WebCube_ImageFilePath + 'teruten1_bt.png" style="cursor:hand;" alt="bt"></a></div>';	
		}
		else if(param1 == 2){
			str = '<link href="'+WebCube_ImageFilePath + 'pantople.css" rel="stylesheet">';
			str += '<div id="bg1">';		
			str += '<img src="'+WebCube_ImageFilePath + 'teruten2_bg.jpg" alt="bg"></div>';
			if(param == "update" || param == "timeout"){
				str += '<div id="msg1">';
				str += '<font color=#999999 face="돋움" fontSize="20"><B>';
				str += msg;
				str += '</B></font></div>';
			}
			str += '<div id="bt1">';
			str += '<a href="' + WebCube_SetupFilePath + SetupFile + '">';
			str += '<img src="'+WebCube_ImageFilePath + 'teruten2_bt.png" style="cursor:hand;" alt="bt"></a></div>';
		}
		//iframe 구조 또는 별도 설치페이지가 필요할때 SetupUI 3
		else if(param1 == 3){
			top.location.href = "./WebCube/setup.htm"
			return;
		}
		//브라우저 크기에 따른 반응형 설치페이지 SetupUI 4
		else if(param1 == 4){
			str = '<link href="'+WebCube_ImageFilePath + 'pantople.css" rel="stylesheet">';
			str += '<div id="bg2">';		
			str += '<img src="'+WebCube_ImageFilePath + 'teruten3_bg.png" alt="bg">';			
			if(param == "update" || param == "timeout"){
				str += '<div id="msg2">';
				str += NewMsg;
				str += '</B></font></div>';
			}else{
				str += '<div id="msg2">';
				str += NewMsg;				
				str += '</div>';							
			}
			str += '<div id="bt2">';
			str += '<a href="' + WebCube_SetupFilePath + SetupFile + '">';
			str += '<img src="'+WebCube_ImageFilePath + 'teruten1_bt.png" style="cursor:hand;" alt="bt"></a></div>';							
			str += '</div>';				
		}	
	}	
	else{	//19.06.11 한글 아닐때 설치UI 
		if(getLangCode() == "ja"){
			str = '<BR><BR><BR><BR>';
			str += '<TABLE border=2 bordercolor=#6083C3 width=600 align=center>';
			str += '<TR height=30 bgcolor=#6083C3>';
			str += '<TD align=center>';
			str += '<font color=#FFFFFF face=돋움><B>';
			str += 'お客様の安全なご使用のためにセキュリティプログラムをインストールしております。';
			str += '</B></font></TD></TR><TR><TD align=center>';	
			str += '<BR><FONT color=#5274BE face=돋움 size=5 style=font-weight:bold>Webセキュリティプログラムのダウンロード</FONT><BR><BR>';
			
			str += '<a href="' + WebCube_SetupFilePath + SetupFile + '">';

			str += '<img src="' + WebCube_ImageFilePath + 'bt_download.png" border="0" style="cursor:hand;"></a><BR><BR>';					
			str += '<FONT color=#5274BE><B>このサイトは、Webセキュリティプログラムがインストールされてからご利用いただけます。<BR>';
			str += 'お客様の情報保護のたWebセキュリティプログラムをインストールしてください。<BR></FONT>';
			str += '&nbsp;&nbsp;<IMG src="' + WebCube_ImageFilePath + 'plugin_bg.gif" width=150 height=50></TD></TR></TABLE></html>';
			
		}else if(getLangCode() == "zh"){
			str = '<BR><BR><BR><BR>';
			str += '<TABLE border=2 bordercolor=#6083C3 width=600 align=center>';
			str += '<TR height=30 bgcolor=#6083C3>';
			str += '<TD align=center>';
			str += '<font color=#FFFFFF face=돋움><B>';
			str += '为使用者提供安全的使用环境,安装安全软件中.';
			str += '</B></font></TD></TR><TR><TD align=center>';	
			str += '<BR><FONT color=#5274BE face=돋움 size=5 style=font-weight:bold>下载Web安全软件</FONT><BR><BR>';
			
			str += '<a href="' + WebCube_SetupFilePath + SetupFile + '">';

			str += '<img src="' + WebCube_ImageFilePath + 'bt_download.png" border="0" style="cursor:hand;"></a><BR><BR>';					
			str += '<FONT color=#5274BE><B>只有安装Web安全软件才可使用本网站.<BR>';
			str += '为保护使用者的信息安全,请安装Web安全软件<BR></FONT>';
			str += '&nbsp;&nbsp;<IMG src="' + WebCube_ImageFilePath + 'plugin_bg.gif" width=150 height=50></TD></TR></TABLE></html>';	
		}else{
			str = '<BR><BR><BR><BR>';
			str += '<TABLE border=2 bordercolor=#6083C3 width=600 align=center>';
			str += '<TR height=30 bgcolor=#6083C3>';
			str += '<TD align=center>';
			str += '<font color=#FFFFFF face=돋움><B>';
			str += 'Installing security module for your safe use of the program.';
			str += '</B></font></TD></TR><TR><TD align=center>';	
			str += '<BR><FONT color=#5274BE face=돋움 size=5 style=font-weight:bold>Download web security program</FONT><BR><BR>';
			
			str += '<a href="' + WebCube_SetupFilePath + SetupFile + '">';

			str += '<img src="' + WebCube_ImageFilePath + 'bt_download.png" border="0" style="cursor:hand;"></a><BR><BR>';					
			str += '<FONT color=#5274BE><B>This site cannot be used without the web security program<BR>';
			str += 'Please install the web security program for safety of your information.<BR></FONT>';
			str += '&nbsp;&nbsp;<IMG src="' + WebCube_ImageFilePath + 'plugin_bg.gif" width=150 height=50></TD></TR></TABLE></html>';			
		}
	}
		
	var div = document.createElement("div");
	div.align = "center";
	div.innerHTML = str;
	div.style.display = "block";
	window.top.document.body.innerHTML = div.outerHTML;
	//document.body.appendChild(div);
}