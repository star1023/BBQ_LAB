/**************************************

이벤트명 : CtrlStatus()

내   용 :
- SetProtect 메소드가 호출된 후 발생하며, OCX의 현재 상태를 코드로 리턴해주는 이벤트

- 리턴 코드가 오류인 경우 setMessage() 함수 호출

- 리턴 코드가 정상인 경우 parent.mainFrm 프레임에 원하는 페이지 호출

- 리턴 코드는 nCode : 0 , nResult : 0 인 경우 정상. 그외 코드는 오류임

***************************************/
//	setMessage(0);
	if(nCode == 0 && nResult != 0) 
	{
	    ShowErrorMessage(nResult);
	} 
	else 
	{
		console.log("ActiveX1 -- 23");
		if(WebCube_Go_NextPage)location.href = WebCube_NextPage;
	}
