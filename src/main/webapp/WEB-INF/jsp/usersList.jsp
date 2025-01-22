<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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
		<c:forEach var="userId" items="${messages.users}">
		    <c:if test="${userId != sessionScope.userId}">
		        <tr>
		            <td>${userId}</td>
		            <td>
		                <c:set var="isFriend" value="false" />
		                <c:forEach var="friend" items="${messages.isfriend}">
		                    <c:if test="${friend.user1Id == userId || friend.user2Id == userId}">
		                        <c:set var="isFriend" value="true" />
		                    </c:if>
		                </c:forEach>
		                <c:choose>
		                    <c:when test="${isFriend}">
		                        申請済み
		                    </c:when>
		                    <c:otherwise>
		                        <form action="FrontServlet" method="post">
		                            <input type="hidden" name="user1Id" value="${sessionScope.userId}">
		                            <input type="hidden" name="user2Id" value="${userId}">
		                            <input type="hidden" name="command" value="AddRelation">
		                            <button type="submit">フレンド申請送信</button>
		                        </form>
		                    </c:otherwise>
		                </c:choose>
		            </td>
		        </tr>
		    </c:if>
		</c:forEach>

    </table>
    <form action="FrontServlet" method="POST">
    	<input type="hidden" name="userId" value="${sessionScope.userId}">
        <input type="hidden" name="command" value="FriendList">
        <button type="submit">フレンドリストへ</button>
    </form>
    <br><br>
</body>
</html>
