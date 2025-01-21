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
	<h2>プレイリスト</h2>
	<%
	// セッションスコープからプレイリストBeansを取得
	List<SpotifyPlayListBean> playlistBeans = (List<SpotifyPlayListBean>) session.getAttribute("playlistBeans");
	%>

	<!-- プレイリスト情報を表示 -->
	<ul>
		<c:forEach var="playlist" items="${playlistBeans}">
			<li><strong>プレイリスト名:</strong> <a
				href="/SpotMusic/FrontServlet?command=PlayListDetails&playlistId=${playlist.playlistId}">${playlist.playlistName}</a><br>

				<strong>プレイリストID:</strong> ${playlist.playlistId}<br> <strong>トラック一覧:</strong>
				<ul>
					<!-- トラックリストを表示 -->
					<!--  <c:forEach var="track" items="${playlist.trackList}">
                        <li>
                            <strong>トラック名:</strong> ${track.trackName} <br>
                            <strong>アーティスト名:</strong> ${track.artistName}
                        </li>
                    </c:forEach>-->
				</ul></li>
		</c:forEach>
	</ul>

	<h2>フォロー中のアーティスト</h2>
	<%
	// セッションスコープからフォロー中のアーティスト名リストを取得
	List<String> followedArtistNames = (List<String>) session.getAttribute("followedArtistNames");
	%>

	<!-- フォロー中のアーティスト情報を表示 -->
	<ul>
    <c:choose>
        <c:when test="${not empty sessionScope.artistIds}">
            <ul>
                <!-- アーティストIDをループでリンクを生成 -->
                <c:forEach var="artistId" items="${sessionScope.artistIds}" varStatus="status">
                    <li>
                        <a href="/SpotMusic/FrontServlet?command=ArtistDetails&artistId=${artistId}">
                            アーティスト名（ ${sessionScope.artistNames[status.index]} ）
                        </a>
                    </li>
                </c:forEach>
            </ul>
        </c:when>
        <c:otherwise>
            <p>フォロー中のアーティストが見つかりませんでした。</p>
        </c:otherwise>
    </c:choose>
</ul>
	<h1>Spotify API情報取得結果</h1>

	<c:if test="${not empty error}">
		<p style="color: red;">エラー: ${error}</p>
	</c:if>

	<c:if test="${empty error}">
		<p>Spotify APIの情報取得に成功しました。</p>
	</c:if>

	<br>
	<a href="/auth">プレイリストを再取得</a> |

	<!-- ログアウトボタン -->
	<form action="/logout" method="post">
		<button type="submit">ログアウト</button>
	</form>
</body>
</html>
