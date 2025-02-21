<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SpotMusic - Web Player：すべての人に音楽を</title>
    <link rel="stylesheet" type="text/css" href="<c:url value='/css/userList.css' />">
</head>
<body>
<h2>ユーザー一覧</h2>


<div class="custom-table">
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
                                    <button type="button" onclick="deleteRelation('${relationId}', '${sessionScope.userId}')">フレンド申請解除</button>                                
                                </c:if>
                                <c:if test="${user1Id == userId}">
                                    <p>フレンド申請が来ています</p>
                                </c:if>
                            </c:when>
                            <c:otherwise>
                                <button type="button" onclick="addRelation('${sessionScope.userId}', '${userId}')">フレンド申請送信</button>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${blocked}">
                                <button type="button" onclick="removeBlock('${blockId}','${sessionScope.userId}')">ブロック解除</button>
                            </c:when>
                            <c:otherwise>
                                <button type="button" onclick="addBlockUser('${userId}', '${sessionScope.userId}')">ブロック</button>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:if>
        </c:forEach>
    </table>
    <button type="button" onclick="friendlist()">フレンドリストへ</button>
</div>

<br><br>
</body>
</html>
