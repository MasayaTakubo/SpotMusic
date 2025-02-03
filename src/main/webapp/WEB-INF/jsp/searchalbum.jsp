<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>アルバム詳細</title>
    <link rel="stylesheet" type="text/css" href="<c:url value='/css/styles.css' />">
</head>
<body>
    <h1>アルバム詳細</h1>

    <c:if test="${not empty album}">
        <div>
            <!-- アルバム画像 -->
			<c:if test="${not empty album.images}">
			    <img src="${album.images[0].url}" width="200">
			</c:if>

            <c:if test="${empty album['images']}">
                <img src="no_image.png" alt="No Image" width="200">
            </c:if>

            <h2>${album['name']}</h2>
            <p>リリース日: ${album['release_date']}</p>
        </div>

	<h3>収録曲</h3>
	<ul>
	    <c:forEach var="track" items="${tracks}">
	        <li>${track['track_number']}. ${track['name']}</li>
	    </c:forEach>
	</ul>

    </c:if>

    <c:if test="${empty album}">
        <p>アルバムが見つかりませんでした。</p>
    </c:if>

    <a href="javascript:history.back()" class="back-button">戻る</a>
</body>
</html>
