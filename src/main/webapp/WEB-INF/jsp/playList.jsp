<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
        <ul>
            <c:forEach var="track" items="${trackList}">
                <li>
                    <strong>トラック名: ${track.trackName}</strong><br>
                    <strong>アーティスト名：${track.artistName}</strong>
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
