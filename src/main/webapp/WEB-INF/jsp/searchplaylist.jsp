<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>プレイリスト詳細</title>
    <link rel="stylesheet" type="text/css" href="<c:url value='/css/searchPlaylist.css' />">
</head>
<body>
    <h1>プレイリスト</h1>

    <div class="playlist-container">
    <div class="playlist-image">
        
        <c:if test="${not empty playlist['images']}">
            <img src="${playlist['images'][0]['url']}" alt="プレイリスト画像" width="200">
        </c:if>
        <c:if test="${empty playlist['images']}">
            <img src="<c:url value='/img/no_image.png' />" alt="No Image" width="200">
        </c:if>
    </div>
    <div class="playlist-info">
        
        <h2>${playlist.name}</h2>
        <c:if test="${not empty playlist['owner']}">
            <p>作成者: ${playlist['owner']}</p>
        </c:if>
        <c:if test="${empty playlist['owner']}">
            <p>作成者情報はありません。</p>
        </c:if>
    </div>
</div>

    
    <c:if test="${not empty tracks}">
        <div class="track-container">
    <c:forEach var="track" items="${tracks}">
        <div class="track-card">
            <c:choose>
                <c:when test="${not empty track.image}">
                    <img src="${track.image}" alt="Track Image" class="track-image">
                </c:when>
                <c:otherwise>
                    <img src="<c:url value='/img/no_image.png' />" alt="No Image" class="track-image">
                </c:otherwise>
            </c:choose>
            <p class="track-name">
			    <c:choose>
			        <c:when test="${fn:length(track['name']) > 8}">
			            ${fn:substring(track['name'], 0, 8)}..
			        </c:when>
			        <c:otherwise>
			            ${track['name']}
			        </c:otherwise>
			    </c:choose>
			</p>

            <!-- プレイリスト追加フォーム -->
            <form class="add-track-form" action="FrontServlet" method="post" target="hidden_iframe">
                <input type="hidden" name="command" value="addTrack">
                <input type="hidden" name="trackId" value="${track.id}">
                <select name="playlistId" class="playlist-select">
                    <c:forEach var="playlist" items="${userPlaylists}">
                        <option value="${playlist.id}">${playlist.name}</option>
                    </c:forEach>
                </select>
                <button class="add-button" type="submit">追加</button>
                <button class="play-button" type="button" onclick="playTrack('${track.id}', '${track.name}')">再生</button>
            </form>
        </div>
    </c:forEach>
</div>
    </c:if>

    <!-- 隠し iframe（リクエスト処理用） -->
    <iframe name="hidden_iframe" style="display: none;"></iframe>

    <c:if test="${empty tracks}">
        <p>収録曲が見つかりませんでした。</p>
    </c:if>

</body>
</html>
