<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>アーティスト詳細</title>
    <link rel="stylesheet" type="text/css" href="<c:url value='/css/styles.css' />">
</head>
<body>
    <h1>アーティスト詳細</h1>

    <c:if test="${not empty artist}">
        <div>
            <!-- アーティスト画像 -->
			<c:if test="${not empty artist.images}">
			    <img src="${artist.images[0].url}" alt="アーティスト画像" width="200">
			</c:if>

            <c:if test="${empty artist['images']}">
                <img src="no_image.png" alt="No Image" width="200">
            </c:if>

            <h2>${artist['name']}</h2>
            <!-- フォロワー数の表示 -->
            <p>フォロワー: ${artist['followers']}</p>
        </div>

        <!-- 人気曲 -->
		 <h3>人気曲</h3>
		<c:if test="${not empty top_tracks}">
		    <ul>
		        <c:forEach var="track" items="${top_tracks}">
		            <li>${track['name']}</li>
		        </c:forEach>
		    </ul>
		</c:if>
		<c:if test="${empty top_tracks}">
		    <p>人気曲が見つかりませんでした。</p>
		</c:if>
		
		<h3>アルバム一覧</h3>
		<c:if test="${not empty albums}">
		    <ul>
		        <c:forEach var="album" items="${albums}">
		            <li>
		                <a href="SpotifySearchServlet?action=album&id=${album['id']}">${album['name']}</a>
		            </li>
		        </c:forEach>
		    </ul>
		</c:if>
		<c:if test="${empty albums}">
		    <p>アルバムが見つかりませんでした。</p>
		</c:if>


    </c:if>

    <c:if test="${empty artist}">
        <p>アーティストが見つかりませんでした。</p>
    </c:if>

    <a href="javascript:history.back()" class="back-button">戻る</a>
</body>
</html>
