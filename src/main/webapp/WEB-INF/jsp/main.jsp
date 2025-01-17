<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.List" %>
<%@ page import="bean.SpotifyPlayListBean" %>
<%@ page import="bean.TrackBean" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Spotify模倣アプリ</title>
    <style>
        body {
            margin: 0;
            display: flex;
            height: 100vh;
            font-family: Arial, sans-serif;
        }
        .sidebar, .content, .property-panel {
            padding: 20px;
            overflow-y: auto;
        }
        .sidebar {
            width: 25%;
            background-color: #f4f4f4;
            border-right: 1px solid #ddd;
        }
        .content {
            width: 50%;
            background-color: #ffffff;
            text-align: center;
        }
        .property-panel {
            width: 25%;
            background-color: #f9f9f9;
            border-left: 1px solid #ddd;
            display: none; /* デフォルトでは非表示 */
        }
        .property-panel.active {
            display: block; /* 音楽再生時に表示 */
        }
        h2 {
            border-bottom: 2px solid #ddd;
            padding-bottom: 10px;
        }
    </style>
</head>
<body>
    <!-- 左側: プレイリスト -->
    <div class="sidebar">
        <h2>プレイリスト</h2>
        <%
            List<SpotifyPlayListBean> playlistBeans = (List<SpotifyPlayListBean>) session.getAttribute("playlistBeans");
            if (playlistBeans == null) {
                playlistBeans = new java.util.ArrayList<>();
            }
        %>
        <ul>
            <c:forEach var="playlist" items="${playlistBeans}">
                <li>
                    <strong>プレイリスト名:</strong>
                    <a href="/SpotMusic/FrontServlet?command=PlayListDetails&playlistId=${playlist.playlistId}">${playlist.playlistName}</a><br>
                    <strong>トラック一覧:</strong>
                    <ul>
                        <c:forEach var="track" items="${playlist.trackList}">
                            <li>
                                <strong>トラック名:</strong> ${track.trackName} <br>
                                <strong>アーティスト名:</strong> ${track.artistName} <br>
                                <form method="post" action="/SpotMusic/PlayTrack">
                                    <input type="hidden" name="trackId" value="${track.trackId}">
                                    <button type="submit">再生</button>
                                </form>
                            </li>
                        </c:forEach>
                    </ul>
                </li>
            </c:forEach>
        </ul>
    </div>

    <!-- 中央: 人気のアーティスト -->
    <div class="content">
        <h2>人気のアーティスト</h2>
        <%
            List<String> followedArtistNames = (List<String>) session.getAttribute("followedArtistNames");
            if (followedArtistNames == null) {
                followedArtistNames = new java.util.ArrayList<>();
            }
        %>
        <ul>
            <c:forEach var="artistName" items="${followedArtistNames}">
                <li><strong>${artistName}</strong></li>
            </c:forEach>
        </ul>
    </div>

    <!-- 右側: 音楽プロパティ -->
    <div class="property-panel <c:if test='${not empty currentTrack}'>active</c:if>'">
        <h2>音楽プロパティ</h2>
        <c:if test="${not empty currentTrack}">
            <%
                TrackBean currentTrack = (TrackBean) session.getAttribute("currentTrack");
            %>
            <p><strong>曲名:</strong> ${currentTrack.trackName}</p>
            <p><strong>アーティスト:</strong> ${currentTrack.artistName}</p>
            <p><strong>アルバム:</strong> ${currentTrack.albumName}</p>
        </c:if>
        <c:if test="${empty currentTrack}">
            <p>現在再生中の音楽はありません。</p>
        </c:if>
    </div>
</body>
</html>
