<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>プレイリスト詳細</title>
    <link rel="stylesheet" type="text/css" href="<c:url value='/css/styles.css' />">
</head>
<body>
    <h1>プレイリスト詳細</h1>

    <div>
        <!-- プレイリスト画像 -->
        <c:if test="${not empty playlist['images']}">
            <img src="${playlist['images'][0]['url']}" alt="プレイリスト画像" width="200">
        </c:if>
        <c:if test="${empty playlist['images']}">
            <img src="no_image.png" alt="No Image" width="200">
        </c:if>

        <h2>${playlist.name}</h2>

        <!-- 作成者情報の表示 -->
        <c:if test="${not empty playlist['owner']}">
            <p>作成者: ${playlist['owner']}</p>
        </c:if>
        <c:if test="${empty playlist['owner']}">
            <p>作成者情報はありません。</p>
        </c:if>
    </div>

	<h3>収録曲</h3>
	<c:if test="${not empty tracks}">
	    <ul>
	        <c:forEach var="track" items="${tracks}">
	            <li>
	                <c:if test="${not empty track['image']}">
	                    <img src="${track['image']}" alt="アルバム画像" width="50">
	                </c:if>
	                <c:if test="${empty track['image']}">
	                    <img src="no_image.png" alt="No Image" width="50">
	                </c:if>
	                ${track['track_number']}. ${track['name']}
	            </li>
	        </c:forEach>
	    </ul>
	</c:if>
	<c:if test="${empty tracks}">
	    <p>収録曲が見つかりませんでした。</p>
	</c:if>


    <a href="javascript:history.back()" class="back-button">戻る</a>
</body>
</html>
