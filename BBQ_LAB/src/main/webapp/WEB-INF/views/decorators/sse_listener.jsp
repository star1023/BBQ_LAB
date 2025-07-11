<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userId = (String) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html>
<head>
    <title>SSE Listener</title>
    <script type="text/javascript">
        let eventSource = null;

        function connectSSE(userId) {
            if (!userId) return;

            if (eventSource) {
                eventSource.close();
            }

            eventSource = new EventSource("/subscribe/" + userId);
            eventSource.addEventListener("sse", function (event) {
                console.log("SSE 받은 이벤트:", event.data);

                // 부모 페이지에 이벤트 전달
                if (window.parent && window.parent.mainFrame && window.parent.mainFrame.readNotification) {
                    window.parent.mainFrame.readNotification(event.data);
                }
            });
        }

        window.onload = function () {
            connectSSE("<%=userId%>");
        }
    </script>
</head>
<body>
SSE 연결 유지중...
</body>
</html>