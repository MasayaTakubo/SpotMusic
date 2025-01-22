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
    <table border="1">
        <tr>
            <th>ユーザー1</th>
            <th>ユーザー2</th>
            <th>関係性</th>
            <th>ボタン</th>
            <th>チャットページ</th>
        </tr>
        <c:forEach var="relation" items="${requestScope.messages}">
            <tr>
                <td>${relation.user1Id}</td>
                <td>${relation.user2Id}</td>
                <td>${relation.status}</td>
                <td>
                	<c:if test="${relation.user1Id != sessionScope.userId}">
			            <c:if test="${relation.status == 'PENDING'}">
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
			            </c:if>
			            <c:if test="${relation.status == 'ACCEPT'}">
			                <form action="FrontServlet" method="POST">
			                    <input type="hidden" name="relationId" value="${relation.relationId}">
			                    <input type="hidden" name="userId" value="${sessionScope.userId}">
			                    <input type="hidden" name="command" value="CancelRelation">
			                    <input type="submit" value="拒否">
			                </form>
			            </c:if>
			            <c:if test="${relation.status == 'CANCEL'}">
			            <form action="FrontServlet" method="POST">
			                    <input type="hidden" name="relationId" value="${relation.relationId}">
			                    <input type="hidden" name="userId" value="${sessionScope.userId}">
			                    <input type="hidden" name="command" value="AcceptRelation">
			                    <input type="submit" value="承認">
			                </form>
			            </c:if>
			        </c:if>
		        </td>
                <td>
		            <c:if test="${relation.status == 'ACCEPT'}">
		                <form action="FrontServlet" method="POST">
		                	<input type="hidden" name="relationId" value="${relation.relationId}">
		                	<input type="hidden" name="userId" value="${sessionScope.userId}">
					        <input type="hidden" name="command" value="ChatCommand">
					        <button type="submit">ログイン</button>
					    </form>
					    <br><br>
		            </c:if>
		        </td>
            </tr>
        </c:forEach>
    </table>
</body>
</html>
