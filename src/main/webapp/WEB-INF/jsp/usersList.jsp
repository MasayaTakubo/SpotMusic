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
            <th>ブロック</th>
        </tr>
		<c:forEach var="userId" items="${messages.users}">
		    <c:if test="${userId != sessionScope.userId}">
		        <tr>
		            <td>${userId}</td>
		            <td>
		                <c:set var="friendStatus" value="none" />
		                <c:forEach var="friend" items="${messages.isfriend}">
		                    <c:if test="${friend.user1Id == userId || friend.user2Id == userId}">
		                        <c:set var="friendStatus" value="${friend.status}" />
		                        <c:set var="relationId" value="${friend.relationId}" />
		                        <c:set var="user1Id" value="${friend.user1Id}" />
		                    </c:if>
		                    
		                </c:forEach>
		                <c:choose>
		                    <c:when test="${friendStatus == 'ACCEPT'}">
		                        フレンドです
		                    </c:when>
		                    <c:when test="${friendStatus == 'CANCEL'}">
		                        フレンド申請は拒否されました
		                    </c:when>
		                    <c:when test="${friendStatus == 'PENDING'}">
		                    <c:if test="${user1Id != userId}">
		                        <form action="FrontServlet" method="post">
		                            <input type="hidden" name="userId" value="${sessionScope.userId}">
		                            <input type="hidden" name="relationId" value="${relationId}">
		                            <input type="hidden" name="command" value="DeleteRelation">
		                            <button type="submit">フレンド申請解除</button>
		                        </form>
		                    </c:if>
		                    <c:if test="${user1Id == userId}">
		                    	<p>フレンド申請が来ています</p>
		                    </c:if>
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
            		<td>
					   <form action="FrontServlet" method="POST">
			               <input type="hidden" name="relationId" value="${relation.relationId}">
			               <input type="hidden" name="userId" value="${sessionScope.userId}">
			               <input type="hidden" name="command" value="AddBlock">
			               <button type="submit">ブロック</button>
			           </form>
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
