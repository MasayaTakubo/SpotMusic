<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>アルバム詳細</title>
    <link rel="stylesheet" type="text/css" href="<c:url value='/css/album.css' />">
</head>
<body>
<h2>アルバム詳細</h2>
<div class="album-container">
    <div class="album-info">
        <h2>${playlist.playlistName}</h2>
        <c:if test="${not empty albumImageUrl}">
            <img src="${albumImageUrl}" alt="${playlist.playlistName}のカバー画像">
        </c:if>
    </div>

    <div class="track-list">
        <ul>
            <c:forEach var="track" items="${sessionScope.trackList}">
                <li>
                    <div class="track-info">
                        <strong>${track.trackName}</strong>  
                        <span> - ${track.artistName}</span>
                    </div>

                    <button onclick="playTrack('${track.trackId}', '${track.trackName}')">再生</button>

                    <c:if test="${not empty track.trackImageUrl}">
                        <img src="${track.trackImageUrl}" alt="${track.trackName}" class="track-image">
                    </c:if>

                    <c:if test="${empty sessionScope.userPlaylists}">
                        <p class="error-message">プレイリストが取得できていません。</p>
                    </c:if>

                    <c:if test="${not empty sessionScope.userPlaylists}">
                        <form action="FrontServlet" method="post" target="hidden_iframe" class="playlist-form">
                            <input type="hidden" name="command" value="addTrack">
                            <input type="hidden" name="trackId" value="${track.trackId}">
                            <select name="playlistId">
                                <c:forEach var="playlist" items="${sessionScope.userPlaylists}">
                                    <option value="${playlist.playlistId}">${playlist.playlistName}</option>
                                </c:forEach>
                            </select>
                            <button type="submit">追加</button>
                        </form>
                    </c:if>
                </li>
            </c:forEach>
        </ul>
    </div>
</div>

<iframe name="hidden_iframe" style="display: none;"></iframe>

</body>
</html>
