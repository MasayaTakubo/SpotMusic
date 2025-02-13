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

<h1>${sessionScope.user_name}がブロックしている相手のリスト</h1>
    <table border="1">
        <tr>
            <th>ブロックした相手のユーザー名</th>
            <th>ブロック解除</th>
        </tr>
        <c:forEach var="block" items="${messages.blockusers}">
		<tr>
			<c:forEach var="user" items="${messages.users}">
                <c:if test="${user.userId eq block.blockedId}">
                    <th>${user.userName}</th>
                </c:if>
            </c:forEach>
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
    		<button type="button" onclick="friendlist()">フレンドリストへ</button>

    <br><br>
</body>
</html>