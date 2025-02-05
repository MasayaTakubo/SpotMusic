<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ユーザーリスト</title>
</head>
<body>
    <h1>ユーザーリスト</h1>
    <h1>${sessionScope.user_name}</h1>
    
    <table border="1">
        <tr>
            <th>ユーザー名</th>
            <th>Action</th>
            <th>ブロック</th>
        </tr>
		<c:forEach var="user" items="${messages.users}">
			<c:set var="userId" value="${user.userId}"/>
		    <c:if test="${userId != sessionScope.userId}">
		    	<c:set var="blocked" value="false"/>
	            <c:forEach var="block" items="${messages.blockusers}">
	                <c:if test="${userId == block.blockedId}">
	                    <c:set var="blocked" value="true"/>
	                    <c:set var="blockId" value="${block.blockId}"/>
	                </c:if>
	            </c:forEach>
		        <tr>
		            <td>${user.userName}</td>
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
	                        <c:choose>
	                            <c:when test="${blocked}">
	                            	<input type="hidden" name="userId" value="${sessionScope.userId}"/>
	                                <input type="hidden" name="blockId" value="${blockId}"/>
	                                <input type="hidden" name="command" value="RemoveBlock"/>
	                                <button type="submit">ブロック解除</button>
	                            </c:when>
	                            <c:otherwise>
					                <input type="hidden" name="blockedId" value="${userId}">
					                <input type="hidden" name="blockerId" value="${sessionScope.userId}">
	                                <input type="hidden" name="command" value="AddBlockUser"/>
	                                <button type="submit">ブロック</button>
	                            </c:otherwise>
	                        </c:choose>
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
