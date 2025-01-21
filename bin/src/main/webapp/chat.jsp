<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Chat Room</title>
</head>
<body>
<div class="chat-container">
    <h1>Chat Room</h1>
    <div class="chat-box">
        <c:forEach var="message" items="${messages}">
            <div class="chat-message">
                <span>${message.userId}:</span> ${message.sendMessage} 
                <small>(${message.sendTime})</small>
            </div>
        </c:forEach>
    </div>
    <form action="FrontServlet" method="post" class="chat-input">
        <input type="hidden" name="command" value="AddMessage" />
        <input type="hidden" name="relationId" value="${relationId}" />
        <input type="hidden" name="userId" value="${userId}" />
        <textarea name="message" placeholder="Type your message here" required></textarea>
        <button type="submit">Send</button>
    </form>
</div>
</body>
</html>
