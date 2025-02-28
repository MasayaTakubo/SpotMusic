<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>アルバム詳細</title>
    <style>
    	body {
    background: #111;
    color: white;
    font-family: Arial, sans-serif;
    text-align: center;
}

.music-container {
    display: flex;
    align-items: center;
    gap: 20px;
    padding: 20px;
    background: #1e1e1e;
    border-radius: 10px;
    justify-content: center;
}

.music-container img {
    width: 200px;
    border-radius: 10px;
}

.music-info h2, .music-info p {
    color: white;
}

.music-track-list {
    list-style: none;
    padding: 20px;
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    justify-content: center;
}

.music-track-list li {
    background: #2a2a2a;
    padding: 15px;
    border-radius: 10px;
    text-align: center;
    width: 180px;
    white-space: nowrap;   	
    overflow: hidden;          
    text-overflow: ellipsis; 
}

.music-track-list img {
    width: 150px;
    height: 150px;
    border-radius: 5px;
    object-fit: cover;
}

.music-track-list select,
.music-track-list button {
    width: 100%;
    margin-top: 5px;
    padding: 8px;
    border: none;
    border-radius: 5px;
    background-color: #444;
    color: white;
    cursor: pointer;
}

.music-track-list button:hover {
    background-color: #666;
}
    </style>
</head>
<body>
    <h1>アルバム詳細</h1>
    
    <c:if test="${not empty album}">
        <div class="music-container">
            <c:choose>
                <c:when test="${not empty album.images}">
                    <c:forEach var="image" items="${album.images}" varStatus="loop">
                        <c:if test="${loop.index == 0}">
                            <img src="${image.url}" alt="アルバム画像">
                        </c:if>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <img src="<c:url value='/img/no_image.png' />" alt="No Image">
                </c:otherwise>
            </c:choose>
            <div class="music-info">
                <h2>${album.name}</h2>
                <p>リリース日: ${album.release_date}</p>
            </div>
        </div>
        
        <ul class="music-track-list">
            <c:forEach var="track" items="${tracks}">
                <li>
                    <c:choose>
                        <c:when test="${not empty track.image}">
                            <img src="${track.image}" alt="トラック画像">
                        </c:when>
                        <c:otherwise>
                            <img src="<c:url value='/img/no_image.png' />" alt="No Image">
                        </c:otherwise>
                    </c:choose>
                    <p>${track.name}</p>
                    <form class="S-add-track-form" action="FrontServlet" method="post" target="hidden_iframe">
                        <input type="hidden" name="command" value="addTrack">
                        <input type="hidden" name="trackId" value="${track.id}">
                        <select name="playlistId">
                            <c:forEach var="playlist" items="${userPlaylists}">
                                <option value="${playlist.id}">${playlist.name}</option>
                            </c:forEach>
                        </select>
                        <button  type="submit">追加</button>
                        <button type="button" onclick="playTrack('${track.id}', '${track.name}')">再生</button>
                    </form>
                </li>
            </c:forEach>
        </ul>
    </c:if>
    
    <c:if test="${empty album}">
        <p>アルバムが見つかりませんでした。</p>
    </c:if>
    
    <!-- 隠し iframe（リクエスト処理用） -->
    <iframe name="hidden_iframe" style="display: none;"></iframe>
</body>
</html>
