<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="userUtil" uri="/WEB-INF/tld/userUtil.tld"%>
<%@ page import="kr.co.genesiskorea.util.UserUtil" %> 
<% 
	String userId = UserUtil.getUserId(request);
%>    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<script type="text/javascript" src="../resources/js/jquery-3.3.1.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
		const eventSource = new EventSource('/subscribe/<%=userId%>');
        eventSource.addEventListener("sse", function (event) {
            console.log(event.data);
			/*
            const data = JSON.parse(event.data);

            (async () => {
                // 브라우저 알림
                const showNotification = () => {
                    
                    const notification = new Notification('코드 봐줘', {
                        body: data.content
                    });
                    
                    setTimeout(() => {
                        notification.close();
                    }, 10 * 1000);
                    
                    notification.addEventListener('click', () => {
                        window.open(data.url, '_blank');
                    });
                }

                // 브라우저 알림 허용 권한
                let granted = false;

                if (Notification.permission === 'granted') {
                    granted = true;
                } else if (Notification.permission !== 'denied') {
                    let permission = await Notification.requestPermission();
                    granted = permission === 'granted';
                }

                // 알림 보여주기
                if (granted) {
                    showNotification();
                }
            })();            
            */
        })
	});
</script>
</head>
<body>
	<%=userId%>
</body>
</html>