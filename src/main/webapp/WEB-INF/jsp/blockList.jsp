<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ブロックリスト</title>
</head>
<body>
<h1>ブロックリスト</h1>
<h1>${sessionScope.userName}がブロックしている相手のリスト</h1>
    <table border="1">
        <tr>
            <th>ブロックした相手のユーザーId</th>
            <th>ブロック解除</th>
        </tr>
        <c:forEach var="block" items="${messages}">
		<tr>
			<th>${block.blockedId}</th>
			<th>
			    <form action="FrontServlet" method="POST">
			    	<input type="hidden" name="userId" value="${sessionScope.userId}">
			    	<input type="hidden" name="blockId" value="${block.blockId}">
			        <input type="hidden" name="command" value="RemoveBlock">
			        <button type="submit">ブロック解除</button>
			    </form>
			</th>
		</tr>
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