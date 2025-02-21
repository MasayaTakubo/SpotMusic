<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>SpotMusic - Web Player：すべての人に音楽を</title>
<link rel="stylesheet" type="text/css" href="<c:url value='/css/blockList.css' />">
</head>
<body>
<h2>ブロックしたユーザー一覧</h2>


<div class="custom-table">
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
                    <button type="button" onclick="removeBlock('${block.blockId}','${userId}')">ブロック解除</button>
                </th>
            </tr>
        </c:forEach>
    </table>
    <button type="button" onclick="friendlist()">フレンドリストへ</button>
</div>

<br><br>
</body>
</html>
