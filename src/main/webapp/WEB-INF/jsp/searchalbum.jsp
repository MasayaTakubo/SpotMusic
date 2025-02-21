<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>アルバム詳細</title>
    <link rel="stylesheet" type="text/css" href="<c:url value='/css/searchAlbum.css' />">

</head>
<body>



<c:if test="${not empty album}">
    
      <div class="album-container">
    <!-- アルバム画像 -->
    <c:choose>
        <c:when test="${not empty album.images}">
            <c:forEach var="image" items="${album.images}" varStatus="loop">
                <c:if test="${loop.index == 0}">
                    <img src="${image.url}" width="200">
                </c:if>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <img src="<c:url value='/img/no_image.png' />" alt="No Image" width="200">
        </c:otherwise>
    </c:choose>

    <div class="album-info">
        <h2>${album.name}</h2>
        <p>リリース日: ${album.release_date}</p>
    </div>
</div>



   
<ul>
        <c:forEach var="track" items="${tracks}">
            <li>
                <c:choose>
                    <c:when test="${not empty track.image}">
                        <img src="${track.image}" width="100">
                    </c:when>
                    <c:otherwise>
                        <img src="<c:url value='/img/no_image.png' />" width="100">
                    </c:otherwise>
                </c:choose>
                ${track.name}

                <!-- プレイリスト追加フォーム -->
				<form class="add-track-form" action="FrontServlet" method="post" target="hidden_iframe">
				    <input type="hidden" name="command" value="addTrack">
				    <input type="hidden" name="trackId" value="${track.id}">
				    <select name="playlistId">
				        <c:forEach var="playlist" items="${userPlaylists}">
				            <option value="${playlist.id}">${playlist.name}</option>
				        </c:forEach>
				    </select>
				    <button class="add-button" type="submit">追加</button>
				    <button type="button" onclick="playTrack('${track.id}', '${track.name}')">再生</button>
				</form>
            </li>
        </c:forEach>
    </ul>
</c:if>


<!-- 隠し iframe（リクエスト処理用） -->
<iframe name="hidden_iframe" style="display: none;"></iframe>


<c:if test="${empty album}">
    <p>アルバムが見つかりませんでした。</p>
</c:if>

</div>
</body>
</html>
