<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ page import="bean.TrackBean" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>プレイリスト詳細</title>
</head>
<body>
    <h2>プレイリストのトラック一覧</h2>

    <%
        // セッションスコープからトラック情報を取得
        List<TrackBean> trackList = (List<TrackBean>) session.getAttribute("trackList");
    %>

<c:if test="${not empty trackList}">
    <ul class="track-list">
        <c:forEach var="track" items="${trackList}">
            <li>
                <strong>トラック名:</strong> ${fn:escapeXml(track.trackName)}<br> 
                <strong>アーティスト名:</strong> ${fn:escapeXml(track.artistName)}<br>
                
                <!-- 画像URLが設定されている場合のみ表示 -->
                <c:if test="${not empty track.trackImageUrl and (fn:startsWith(track.trackImageUrl, 'http://') or fn:startsWith(track.trackImageUrl, 'https://'))}">
                    <img src="${track.trackImageUrl}" alt="${fn:escapeXml(track.trackName)}" width="100" />
                </c:if>
                
				<button onclick="playTrack('${track.trackId}', '${track.trackName}')">再生</button>

            </li>
        </c:forEach>
    </ul>
</c:if>


						

    <c:if test="${empty trackList}">
        <p>トラック情報が見つかりません。</p>
    </c:if>

    <br>
</body>
</html>
