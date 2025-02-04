<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>フレンドリスト</title>
</head>
<body>
    <h1>フレンドリスト</h1>
    <h1>${sessionScope.userId}</h1>
    <p>申請中のユーザー</p>
    <table border="1">
        <tr>
            <th>ユーザー名</th>
            <th>状態</th>
            <th>ボタン</th>
        </tr>
	    <c:forEach var="relation" items="${messages.relations}">
	    <c:if test="${relation.status eq 'PENDING'}">
        <tr>
            <c:choose>
                <c:when test="${relation.user1Id != sessionScope.userId}">
                    <td>
                        <c:forEach var="user" items="${messages.users}">
                            <c:if test="${user.userId eq relation.user1Id}">
                                ${user.userName}
                            </c:if>
                        </c:forEach>
                    </td>
                </c:when>
                <c:when test="${relation.user2Id != sessionScope.userId}">
                    <td>
                        <c:forEach var="user" items="${messages.users}">
                            <c:if test="${user.userId eq relation.user2Id}">
                                ${user.userName}
                            </c:if>
                        </c:forEach>
                    </td>
                </c:when>
            </c:choose>
            <c:choose>
                <c:when test="${relation.user1Id != sessionScope.userId}">
                       <td>フレンド申請が来ました</td>
                </c:when>
                <c:when test="${relation.user2Id != sessionScope.userId}">
                       <td>フレンド申請を行いました</td>
                </c:when>
            </c:choose>
		    <c:if test="${relation.user1Id != sessionScope.userId}">
		    <td>
             <form action="FrontServlet" method="POST">
                 <input type="hidden" name="relationId" value="${relation.relationId}">
                 <input type="hidden" name="userId" value="${sessionScope.userId}">
                 <input type="hidden" name="command" value="AcceptRelation">
                 <input type="submit" value="承認">
             </form>
             <form action="FrontServlet" method="POST">
                 <input type="hidden" name="relationId" value="${relation.relationId}">
                 <input type="hidden" name="userId" value="${sessionScope.userId}">
                 <input type="hidden" name="command" value="CancelRelation">
                 <input type="submit" value="拒否">
             </form>
             </td>
             </c:if>
             <c:if test="${relation.user1Id == sessionScope.userId}">
             <td>
             <form action="FrontServlet" method="POST">
                 <input type="hidden" name="relationId" value="${relation.relationId}">
                 <input type="hidden" name="userId" value="${sessionScope.userId}">
                 <input type="hidden" name="command" value="DeleteRelation">
                 <input type="submit" value="フレンド申請取消">
             </form>
             </td>
             </c:if>
        </tr>
    </c:if>
    </c:forEach>
    </table>
    <p>フレンド</p>
	<table border="1">
		<th>ユーザー名</th>
		<th>Action</th>
		<th>チャット</th>
	    <c:forEach var="relation" items="${messages.relations}">
	        <c:if test="${relation.status eq 'ACCEPT'}">
	            <c:set var="blocked" value="false"/>
	            <c:forEach var="block" items="${messages.blockusers}">
	                <c:if test="${(relation.user1Id == sessionScope.userId and relation.user2Id == block.blockedId) or 
	                              (relation.user2Id == sessionScope.userId and relation.user1Id == block.blockedId)}">
	                    <c:set var="blocked" value="true"/>
	                    <c:set var="blockId" value="${block.blockId}"/>
	                </c:if>
	            </c:forEach>
	            <tr>
                    <c:choose>
		                <c:when test="${relation.user1Id != sessionScope.userId}">
		                    <td>
		                        <c:forEach var="user" items="${messages.users}">
		                            <c:if test="${user.userId eq relation.user1Id}">
		                                ${user.userName}
		                            </c:if>
		                        </c:forEach>
		                    </td>
		                </c:when>
		                <c:when test="${relation.user2Id != sessionScope.userId}">
		                    <td>
		                        <c:forEach var="user" items="${messages.users}">
		                            <c:if test="${user.userId eq relation.user2Id}">
		                                ${user.userName}
		                            </c:if>
		                        </c:forEach>
		                    </td>
		                </c:when>
		            </c:choose>
	                <td>
	                    <form action="FrontServlet" method="POST">
	                        <input type="hidden" name="userId" value="${sessionScope.userId}"/>
	                        <c:choose>
	                            <c:when test="${blocked}">
	                                <input type="hidden" name="blockId" value="${blockId}"/>
	                                <input type="hidden" name="command" value="RemoveBlock"/>
	                                <button type="submit">ブロック解除</button>
	                            </c:when>
	                            <c:otherwise>
	                                <input type="hidden" name="relationId" value="${relation.relationId}"/>
	                                <input type="hidden" name="command" value="AddBlockFriend"/>
	                                <button type="submit">ブロック</button>
	                            </c:otherwise>
	                        </c:choose>
	                    </form>
	                </td>
	                <td>
	                    <form action="FrontServlet" method="POST">
	                        <input type="hidden" name="relationId" value="${relation.relationId}"/>
	                        <input type="hidden" name="userId" value="${sessionScope.userId}"/>
	                        <input type="hidden" name="command" value="ChatCommand"/>
	                        <input type="hidden" name="isBlock" value="${blocked}"/>
	                        <button type="submit">ログイン</button>
	                    </form>
	                </td>
	            </tr>
	        </c:if>
	    </c:forEach>
	</table>

    <p>フレンド申請をキャンセルしたユーザー</p>
	<table border="1">
	    <tr>
	        <th>ユーザー名</th>
	    </tr>
	    <c:forEach var="relation" items="${messages.relations}">
	        <c:if test="${relation.status eq 'CANCEL'}">
	        <tr>
	            <c:choose>
	                <c:when test="${relation.user1Id != sessionScope.userId}">
	                    <td>
	                        <c:forEach var="user" items="${messages.users}">
	                            <c:if test="${user.userId eq relation.user1Id}">
	                                ${user.userName}
	                            </c:if>
	                        </c:forEach>
	                    </td>
	                </c:when>
	                <c:when test="${relation.user2Id != sessionScope.userId}">
	                    <td>
	                        <c:forEach var="user" items="${messages.users}">
	                            <c:if test="${user.userId eq relation.user2Id}">
	                                ${user.userName}
	                            </c:if>
	                        </c:forEach>
	                    </td>
	                </c:when>
	            </c:choose>
	        </tr>
	        </c:if>
	    </c:forEach>
	</table>
    <form action="FrontServlet" method="POST">
        <input type="hidden" name="userId" value="${sessionScope.userId}"><br><br>
        <input type="hidden" name="command" value="UsersList">
        <button type="submit">ユーザーリストへ</button>
    </form>
	<form action="FrontServlet" method="POST">
    	<input type="hidden" name="userId" value="${sessionScope.userId}">
        <input type="hidden" name="command" value="BlockList">
        <button type="submit">ブロックリストへ</button>
    </form>
</body>
</html>
