<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>アルバム詳細</title>
    <style>
        body {
            background: linear-gradient(to bottom, #222, #111);
            color: white;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }

        .music-container {
            max-width: 800px;
            margin: auto;
            background: #222;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0px 0px 10px rgba(255, 255, 255, 0.1);
        }

        .song-list ul {
            list-style: none;
            padding: 0;
        }

        .song-list li {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #333;
            padding: 15px;
            margin-bottom: 10px;
            border-radius: 8px;
        }

        .song-info {
            flex-grow: 1;
        }

        .song-image {
            width: 50px;
            height: 50px;
            border-radius: 5px;
            margin-right: 15px;
        }

        .action-button {
            background: #444;
            color: white;
            border: none;
            padding: 10px 15px;
            cursor: pointer;
            border-radius: 5px;
            transition: 0.3s;
            width:100%;
            margin-top:5px;
            margin-bottom:5px;
        }

        .action-button:hover {
       		background-color:rgba(222,222,222,0.3);
            color:rgb(222,222,222);
      
        }

        .dropdown {
            background: #444;
            color: white;
            border: none;
            padding: 8px;
            border-radius: 5px;
        }
        .list{
        	width:20%;
        	
        }
        select{
        width:100%;}
    </style>
</head>
<body>
<h2>アルバム詳細</h2>
<div class="music-container">
    <div class="album-info">
        <h2>${playlist.playlistName}</h2>
        <c:if test="${not empty albumImageUrl}">
            <img src="${albumImageUrl}" alt="${playlist.playlistName}のカバー画像">
        </c:if>
    </div>

    <div class="song-list">
        <ul>
            <c:forEach var="track" items="${sessionScope.trackList}">
                <li>
                    <div class="song-info">
                        <strong>${track.trackName}</strong>  
                        <span> - ${track.artistName}</span>
                    </div>

                    <c:if test="${not empty track.trackImageUrl}">
                        <img src="${track.trackImageUrl}" alt="${track.trackName}" class="song-image">
                    </c:if>

                    <div class="list">
                        <c:if test="${empty sessionScope.userPlaylists}">
                            <p class="error-message">プレイリストが取得できていません。</p>
                        </c:if>

                        <c:if test="${not empty sessionScope.userPlaylists}">
                            <form action="FrontServlet" method="post" target="hidden_iframe">
                                <input type="hidden" name="command" value="addTrack">
                                <input type="hidden" name="trackId" value="${track.trackId}">
                                <select name="playlistId" class="dropdown">
                                    <c:forEach var="playlist" items="${sessionScope.userPlaylists}">
                                        <option value="${playlist.playlistId}">${playlist.playlistName}</option>
                                    </c:forEach>
                                </select>
                                <button type="submit" class="action-button">追加</button>
                                <button type="button" class="action-button" onclick="playTrack('${track.trackId}', '${track.trackName}')">再生</button>
                            </form>
                        </c:if>
                    </div>
                </li>
            </c:forEach>
        </ul>
    </div>
</div>

<iframe name="hidden_iframe" style="display: none;"></iframe>

</body>
</html>
