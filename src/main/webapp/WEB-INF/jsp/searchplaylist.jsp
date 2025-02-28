<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>プレイリスト詳細</title>

    <style>
		body{
		background-color:black;
		} 
		
.new-playlist-container {
    display: flex;
    align-items: center;
    gap: 20px;
    padding: 20px;
    background: #181818;
    border-radius: 12px;
    justify-content: center;
    box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.5);
}

.new-playlist-image img {
    width: 220px;
    border-radius: 12px;
    object-fit: cover;
}

.new-playlist-info h2, .new-playlist-info p {
    color: #ddd;
    margin: 5px 0;
}

.new-track-list-container {
    list-style: none;
    padding: 25px;
    display: flex;
    flex-wrap: wrap;
    gap: 25px;
    justify-content: center;
    background: #222;
    border-radius: 12px;
}

.new-track-item {
    background: #2e2e2e;
    padding: 18px;
    border-radius: 12px;
    text-align: center;
    width: 200px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    transition: transform 0.2s ease-in-out;
}


.new-track-image {
    width: 160px;
    height: 160px;
    border-radius: 6px;
    object-fit: cover;
}

.new-playlist-select,
.new-track-actions button {
    width: 100%;
    margin-top: 8px;
    padding: 10px;
    border: none;
    border-radius: 6px;
    background-color: #444;
    color: white;
    cursor: pointer;
    transition: background 0.3s;
}

.new-track-actions button:hover {
    background-color: #666;
}

.new-track-actions {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-top: 12px;
}    
    </style>
</head>

<body>
    <h1>プレイリスト</h1>

    <div class="new-playlist-container">
        <div class="new-playlist-image">
            <c:if test="${not empty playlist['images']}">
                <img src="${playlist['images'][0]['url']}" alt="プレイリスト画像" class="new-playlist-image">
            </c:if>
            <c:if test="${empty playlist['images']}">
                <img src="<c:url value='/img/no_image.png' />" alt="No Image" class="new-playlist-image">
            </c:if>
        </div>
        <div class="new-playlist-info">
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
        <div class="new-track-list-container">
            <c:forEach var="track" items="${tracks}">
                <div class="new-track-item">
                    <c:choose>
                        <c:when test="${not empty track.image}">
                            <img src="${track.image}" alt="Track Image" class="new-track-image">
                        </c:when>
                        <c:otherwise>
                            <img src="<c:url value='/img/no_image.png' />" alt="No Image" class="new-track-image">
                        </c:otherwise>
                    </c:choose>
                    <p class="new-track-name">
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
                    <form class="new-track-actions" action="FrontServlet" method="post" target="hidden_iframe">
                        <input type="hidden" name="command" value="addTrack">
                        <input type="hidden" name="trackId" value="${track.id}">
                        <select name="playlistId" class="new-playlist-select">
                            <c:forEach var="playlist" items="${userPlaylists}">
                                <option value="${playlist.id}">${playlist.name}</option>
                            </c:forEach>
                        </select>
                        <button class="new-add-track-btn" type="submit">追加</button>
                        <button class="new-play-track-btn" type="button" onclick="playTrack('${track.id}', '${track.name}')">再生</button>
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
