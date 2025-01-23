<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Friend List</title>
</head>
<body>
    <h1>Friend List</h1>
    <h1>${sessionScope.userId}</h1>
    <p>申請中のユーザー</p>
    <table border="1">
        <tr>
            <th>ユーザーID</th>
            <th>^-^</th>
            <th>ボタン</th>
        </tr>
	    <c:forEach var="relation" items="${requestScope.messages}">
	    <c:if test="${relation.status == 'PENDING'}">
        <tr>
            <c:choose>
                <c:when test="${relation.user1Id != sessionScope.userId}">
                       <td>${relation.user1Id}</td>
                </c:when>
                <c:when test="${relation.user2Id != sessionScope.userId}">
                       <td>${relation.user2Id}</td>
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
        <tr>
            <th>ユーザーID</th>
            <th>ボタン</th>
            <th>チャットページ</th>
        </tr>
	    <c:forEach var="relation" items="${requestScope.messages}">
	    <c:if test="${relation.status == 'ACCEPT'}">
           <tr>
	            <c:choose>
	                <c:when test="${relation.user1Id != sessionScope.userId}">
                        <td>${relation.user1Id}</td>
	                </c:when>
	                <c:when test="${relation.user2Id != sessionScope.userId}">
                        <td>${relation.user2Id}</td>
	                </c:when>
	            </c:choose>
               <td>
                <form action="FrontServlet" method="POST">
                    <input type="hidden" name="relationId" value="${relation.relationId}">
                    <input type="hidden" name="userId" value="${sessionScope.userId}">
                    <input type="hidden" name="command" value="AddBlock">
                    <button type="submit">ブロック</button>
                </form>
		        </td>
               <td>
                <form action="FrontServlet" method="POST">
                	<input type="hidden" name="relationId" value="${relation.relationId}">
                	<input type="hidden" name="userId" value="${sessionScope.userId}">
			        <input type="hidden" name="command" value="ChatCommand">
			        <button type="submit">ログイン</button>
			    </form>
			    <br><br>
	        </td>
           </tr>
    </c:if>
    </c:forEach>
    </table>
    <p>フレンド申請をキャンセルしたユーザー</p>
	<table border="1">
	    <tr>
	        <th>ユーザーID</th>
	    </tr>
	    <c:forEach var="relation" items="${requestScope.messages}">
	        <c:if test="${relation.status == 'CANCEL'}">
	            <c:choose>
	                <c:when test="${relation.user1Id != sessionScope.userId}">
	                    <tr>
	                        <td>${relation.user1Id}</td>
	                    </tr>
	                </c:when>
	                <c:when test="${relation.user2Id != sessionScope.userId}">
	                    <tr>
	                        <td>${relation.user2Id}</td>
	                    </tr>
	                </c:when>
	            </c:choose>
	        </c:if>
	    </c:forEach>
	</table>
</body>
</html>
