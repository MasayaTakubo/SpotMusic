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

    <div class="album-info">
        <h2>${playlist.playlistName}</h2>
        <p>アーティスト: ${artistBean.artistName}</p>
        <c:if test="${not empty albumImageUrl}">
            <img src="${albumImageUrl}" alt="${playlist.playlistName}のカバー画像" style="width:300px; height:auto;">
        </c:if>
    </div>

<div class="track-list">
    <h3>トラックリスト</h3>
    <ul>
        <c:forEach var="track" items="${sessionScope.trackList}">
            <li>
                <strong>${track.trackName}</strong>  
                <span> - ${track.artistName}</span>
                <button onclick="playTrack('${track.trackId}', '${track.trackName}')">再生</button>

                <c:if test="${not empty track.trackImageUrl}">
                    <img src="${track.trackImageUrl}" alt="${track.trackName}" style="width:50px; height:auto;">
                </c:if>

                <!-- プレイリスト取得エラー時のメッセージ -->
                <c:if test="${empty sessionScope.userPlaylists}">
                    <p style="color: red;">プレイリストが取得できていません。</p>
                </c:if>

                <!-- プレイリスト追加フォーム -->
			<c:if test="${not empty sessionScope.userPlaylists}">
			    <form action="FrontServlet" method="post" target="hidden_iframe">
			        <input type="hidden" name="command" value="addTrack"> <!-- コマンド指定 -->
			        <input type="hidden" name="trackId" value="${track.trackId}">
			        <select name="playlistId">
			            <c:forEach var="playlist" items="${sessionScope.userPlaylists}">
			                <option value="${playlist.playlistId}">${playlist.playlistName}</option>
			            </c:forEach>
			        </select>
			        <button type="submit">プレイリストに追加</button>
			    </form>
			</c:if>

            </li>
        </c:forEach>
    </ul>
</div>

<iframe name="hidden_iframe" style="display: none;"></iframe>

</body>
</html>
