
//-----------------------------------------------------ActiveX-------------------------------------------------------------------------

if(((navigator.userAgent.toLowerCase().indexOf("trident") > -1) || (navigator.userAgent.toLowerCase().indexOf("msie") > -1)) && WebCube_MODE_IE == "A")
{
	StartAxtiveX();	
}

//////////////////////////////////////////////////////////
//
// 전역 변수
//
//////////////////////////////////////////////////////////
var isInitOCX = false; // OCX가 초기화 여부
var isInstallActiveX = -1; //ActiveX 설치 여부 -1 : 알수 없음, 0  : 설치안됨, 1  : 설치됨
var nLoop = 0; //재귀호출 횟수

//onerror 이벤트에 정의되어 있음(IE에서 이벤트 발생 시킴)
function NoneActiveX()
{
	setBlock("", WebCube_SetupUI);
}

//onreadystatechange 이벤트 발생시 호출되는 함수 (IE가 발생시킴)
function SetActiveXState()
{
	if (isInstallActiveX != 0 && Obj.readyState == 4)
	{
		isInstallActiveX = 1;
	}
}

// ActiveX 설치여부를 확인
function chkActiveX()
{
	if (isInstallActiveX != 1)
	{
		if (isInstallActiveX == 0)
		{
			setBlock("", WebCube_SetupUI);
			return;
		}
		else
		{
			
			if (typeof(Obj)=="object" && Obj.readyState == 4)
			{
				isInstallActiveX = 1;				
			}
			else
			{
				nLoop++;
				if (nLoop < 3)
				{
					setTimeout("chkActiveX()", 500);
				}
				else
				{
					return false;
				}	
			}
		}
	}
	
	if (isInstallActiveX==1){
		// ActiveX is ready buy not initialized yet.
		// ActiveX 가 설치되어 있다는 뜻임.		
		//document.location='main.asp';
	}
}
function StartAxtiveX()
{
	var clintInfoObj = window.clientInformation;
	var browser = clintInfoObj.platform;
	var str;
	
	if((clintInfoObj.appVersion.toLowerCase().indexOf("x64") < 0) &&(clintInfoObj.appVersion.toLowerCase().indexOf("wow64") < 0))
	{
		//alert('32비트OS에 32비트Borwser');
		str = '<object classid="CLSID:29BC57E0-018D-46D2-B233-338B779C169C" '+
		'width="0" height="0" id="Obj" codebase="WebCube/components/WebCube.cab#version='+WebCubeVersion+'" ' +
		'VIEWASTEXT onerror="NoneActiveX()" onreadystatechange="SetActiveXState()"></object>';
	}
	else
	{
		if(browser.toLowerCase() != "win64") 
		{
			//alert('64비트OS에 32비트Borwser');
			str = '<object classid="CLSID:29BC57E0-018D-46D2-B233-338B779C169C" '+
			'width="0" height="0" id="Obj" codebase="WebCube/components/WebCubewow.cab#version='+WebCubeVersion+'" ' +
			'VIEWASTEXT onerror="NoneActiveX()" onreadystatechange="SetActiveXState()"></object>';			
		}
		else
		{
			//alert('64비트OS에 64비트Borwser');
			str = '<object classid="CLSID:29BC57E0-018D-46D2-B233-338B779C169C" '+
			'width="0" height="0" id="Obj" codebase="WebCube/components/WebCube64.cab#version='+WebCubeVersion+'" ' +
			'VIEWASTEXT onerror="NoneActiveX()" onreadystatechange="SetActiveXState()"></object>';
		}
	}
	document.write(str);
		
}