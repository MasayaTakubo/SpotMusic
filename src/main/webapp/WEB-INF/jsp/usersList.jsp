<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Users List</title>
</head>
<body>
    <h1>Users List</h1>
    <h1>${sessionScope.userId}</h1>
    <table border="1">
        <tr>
            <th>User ID</th>
            <th>Action</th>
        </tr>
        <c:forEach var="userId" items="${messages}">
            <c:if test="${userId != sessionScope.userId}">
                <tr>
                    <td>${userId}</td>
                    <td>
                        <form action="FrontServlet" method="post">
                            <input type="hidden" name="user1Id" value="${sessionScope.userId}">
                            <input type="hidden" name="user2Id" value="${userId}">
                            <input type="hidden" name="command" value="AddRelation">
                            <button type="submit">フレンド申請送信</button>
                        </form>
                    </td>
                </tr>
            </c:if>
        </c:forEach>
    </table>
    <h2>フレンドリスト</h2>
    <form action="FrontServlet" method="POST">
        <input type="hidden" name="command" value="FriendList">
        <button type="submit">フレンドリストへ</button>
    </form>
    <br><br>
</body>
</html>
