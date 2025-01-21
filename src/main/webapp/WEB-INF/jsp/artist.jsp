<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page import="java.util.List"%>
<%@ page import="bean.SpotifyPlayListBean"%>
<%@ page import="bean.TrackBean"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Spotify情報表示</title>
</head>
<body>
	<h1>アーティスト詳細情報</h1>
	<p>
		<strong>名前:</strong> ${artistBean.artistName}
	</p>
	<p>
		<strong>ジャンル:</strong> ${artistBean.artistGenres}
	</p>
	<p>
		<strong>フォロワー数:</strong> ${artistBean.followers}
	</p>

	<h2>人気曲ランキング</h2>
    <ul>
        <c:forEach var="track" items="${artistBean.topTracks}">
            <li>${track.trackName} <a href="${track.previewUrl}" target="_blank">[試聴]</a></li>
        </c:forEach>
    </ul>

	<h2>プレイリスト</h2>
	<ul>
		<c:forEach var="playlist" items="${artistBean.playlists}">
			<li><a
				href="/SpotMusic/FrontServlet?command=AlbumDetails&albumId=${playlist.playlistId}">${playlist.playlistName}</a></li>
		</c:forEach>
		<!-- <a
				href="/SpotMusic/FrontServlet?command=PlayListDetails&playlistId=${playlist.playlistId}">${playlist.playlistName}</a><br>
		 -->
	</ul>

</body>
</html>
