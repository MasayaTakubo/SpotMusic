<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>アルバム詳細</title>
</head>
<body>
    <h1>アルバム詳細</h1>

    <!-- アルバムの情報を表示 -->
    <div class="album-info">
        <h2>${playlist.playlistName}</h2>
        <p>アーティスト: ${artistBean.artistName}</p>
        <c:if test="${not empty albumImageUrl}">
            <img src="${albumImageUrl}" alt="${playlist.playlistName}のカバー画像" style="width:300px; height:auto;">
        </c:if>
    </div>

    <!-- トラックリストの表示 -->
    <div class="track-list">
        <h3>トラックリスト</h3>
        <ul>
            <c:forEach var="track" items="${trackList}">
                <li>
                    <strong>${track.trackName}</strong>  
                    <span> - ${track.artistName}</span>
                    <!-- トラックの画像を表示 -->
                    <c:if test="${not empty track.trackImageUrl}">
                        <img src="${track.trackImageUrl}" alt="${track.trackName}" style="width:50px; height:auto;">
                    </c:if>
                </li>
            </c:forEach>
        </ul>
    </div>

</body>

</html>
