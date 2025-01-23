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
            <th>ユーザー1</th>
            <th>ユーザー2</th>
            <th>ボタン</th>
        </tr>
	    <c:forEach var="relation" items="${requestScope.messages}">
	    <c:if test="${relation.status == 'PENDING'}">
        <tr>
            <td>${relation.user1Id}</td>
            <td>${relation.user2Id}</td>
            <td>
		    <c:if test="${relation.user1Id != sessionScope.userId}">
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
     		 </td>
        </tr>
    </c:if>
    </c:forEach>
    </table>
    <p>フレンド</p>
    <table border="1">
        <tr>
            <th>ユーザー1</th>
            <th>ユーザー2</th>
            <th>ボタン</th>
            <th>チャットページ</th>
        </tr>
	    <c:forEach var="relation" items="${requestScope.messages}">
	    <c:if test="${relation.status == 'ACCEPT'}">
           <tr>
               <td>${relation.user1Id}</td>
               <td>${relation.user2Id}</td>
               <td>
                <form action="FrontServlet" method="POST">
                    <input type="hidden" name="relationId" value="${relation.relationId}">
                    <input type="hidden" name="userId" value="${sessionScope.userId}">
                    <input type="hidden" name="command" value="CancelRelation">
                    <button type="submit">ブロック</button><!-- ブロック関係のCommand -->
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
