<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<head>
    <title>検索結果</title>
<!-- <link rel="stylesheet" type="text/css" href="<c:url value='/css/styles.css' />"> -->    
	
</head>
<body>
<div class="content">
<!-- タブメニュー -->
<c:set var="noImageUrl" value="${fn:escapeXml(pageContext.request.contextPath)}/img/no_image.png" />
<div class="tab-menu">
    <button class="active" onclick="showTab('all')">すべて</button>
    <button onclick="showTab('tracks')">曲</button>
    <button onclick="showTab('albums')">アルバム</button>
    <button onclick="showTab('artists')">アーティスト</button>
    <button onclick="showTab('playlists')">プレイリスト</button>
</div>

<!-- すべての結果（デフォルト） -->
<div id="all" class="tab-content active">
    <h2>すべて</h2>

    <!-- 曲のリスト -->
    <c:if test="${not empty tracks}">
        <h3>曲</h3>
        <ul class="track-list">
            <c:forEach var="track" items="${tracks}">
                <li class="track-item">
                    <c:choose>
                        <c:when test="${not empty track.image}">
                            <img src="${track.image}" alt="アルバム画像" width="50">
                        </c:when>
                        <c:otherwise>
                            <img src="<c:url value='/img/no_image.png' />" alt="No Image" width="50">
                        </c:otherwise>
                    </c:choose>

                    ${track.track_number}. ${track.name}

                    <!-- プレイリスト追加フォーム -->
                    <form class="add-track-form" action="SpotifyAddTrackServlet" method="post" target="hidden_iframe">
                        <input type="hidden" name="trackId" value="${track.id}">
                        <select name="playlistId">
                            <c:forEach var="playlist" items="${userPlaylists}">
                                <option value="${playlist.id}">${playlist.name}</option>
                            </c:forEach>
                        </select>
                        <button type="button" onclick="playTrack('${track.id}', '${track.name}')">再生</button>
                        <button class="add-button" type="submit">追加</button>
                    </form>
                </li>
            </c:forEach>
        </ul>
    </c:if>

    <!-- アルバムのリスト -->
    <c:if test="${not empty albums}">
        <h3>アルバム</h3>
        <ul class="album-list">
			<c:forEach var="album" items="${albums}">
			    <li class="album-item">
			        <a href="javascript:void(0);" 
			           onclick="loadAlbumDetail('${album.id}')">
			            <img src="${not empty album.images ? album.images[0].url : noImageUrl}" width="100">
			            ${album.name}
			        </a>
			    </li>
			</c:forEach>

        </ul>
    </c:if>

    <!-- アーティストのリスト -->
    <c:if test="${not empty artists}">
        <h3>アーティスト</h3>
        <ul class="artist-list">
			<c:forEach var="artist" items="${artists}">
			    <li class="artist-item">
			        <a href="javascript:void(0);" 
			           onclick="loadArtistDetail('${artist.id}')">
			            <img src="${not empty artist.images ? artist.images[0].url : noImageUrl}" width="100">
			            ${artist.name}
			        </a>
			    </li>
			</c:forEach>

        </ul>
    </c:if>

    <!-- プレイリストのリスト -->
    <c:if test="${not empty playlists}">
        <h3>プレイリスト</h3>
        <ul class="playlist-list">
			<c:forEach var="playlist" items="${playlists}">
			    <li class="playlist-item">
			        <a href="javascript:void(0);" 
			           onclick="loadPlaylistDetail('${playlist.id}')">
			            <img src="${not empty playlist.images ? playlist.images[0].url : noImageUrl}" width="100">
			            ${playlist.name}
			        </a>
			    </li>
			</c:forEach>

        </ul>
    </c:if>
</div>

<!-- 曲のみ -->
<div id="tracks" class="tab-content">
    <h2>曲</h2>
    <c:if test="${not empty tracks}">
        <ul class="track-list">
            <c:forEach var="track" items="${tracks}">
                <li class="track-item">
                    <c:choose>
                        <c:when test="${not empty track.image}">
                            <img src="${track.image}" alt="アルバム画像" width="50">
                        </c:when>
                        <c:otherwise>
                            <img src="<c:url value='/img/no_image.png' />" alt="No Image" width="50">
                        </c:otherwise>
                    </c:choose>

                    ${track.track_number}. ${track.name}

                    <!-- プレイリスト追加フォーム -->
                    <form class="add-track-form" action="SpotifyAddTrackServlet" method="post" target="hidden_iframe">
                        <input type="hidden" name="trackId" value="${track.id}">
                        <select name="playlistId">
                            <c:forEach var="playlist" items="${userPlaylists}">
                                <option value="${playlist.id}">${playlist.name}</option>
                            </c:forEach>
                        </select>
                        <button type="submit">追加</button>

                        
                    </form>
                </li>
            </c:forEach>
        </ul>
    </c:if>
</div>

<!-- アルバムタブ -->
<div id="albums" class="tab-content">
    <h2>アルバム</h2>
    <c:if test="${not empty albums}">
        <ul class="album-list">
			<c:forEach var="album" items="${albums}">
			    <li class="album-item">
			        <a href="javascript:void(0);" 
			           onclick="loadAlbumDetail('${album.id}')">
			            <img src="${not empty album.images ? album.images[0].url : noImageUrl}" width="100">
			            ${album.name}
			        </a>
			    </li>
			</c:forEach>

        </ul>
    </c:if>
    <c:if test="${empty albums}">
        <p>アルバムが見つかりませんでした。</p>
    </c:if>
</div>

<!-- アーティストタブ -->
<div id="artists" class="tab-content">
    <h2>アーティスト</h2>
    <c:if test="${not empty artists}">
        <ul class="artist-list">
			<c:forEach var="artist" items="${artists}">
			    <li class="artist-item">
			        <a href="javascript:void(0);" 
			           onclick="loadArtistDetail('${artist.id}')">
			            <img src="${not empty artist.images ? artist.images[0].url : noImageUrl}" width="100">
			            ${artist.name}
			        </a>
			    </li>
			</c:forEach>

        </ul>
    </c:if>
    <c:if test="${empty artists}">
        <p>アーティストが見つかりませんでした。</p>
    </c:if>
</div>

<!-- プレイリストタブ -->
<div id="playlists" class="tab-content">
    <h2>プレイリスト</h2>
    <c:if test="${not empty playlists}">
        <ul class="playlist-list">
			<c:forEach var="playlist" items="${playlists}">
			    <li class="playlist-item">
			        <a href="javascript:void(0);" 
			           onclick="loadPlaylistDetail('${playlist.id}')">
			            <img src="${not empty playlist.images ? playlist.images[0].url : noImageUrl}" width="100">
			            ${playlist.name}
			            
			        </a>
			    </li>
			</c:forEach>
        </ul>
    </c:if>
    <c:if test="${empty playlists}">
        <p>プレイリストが見つかりませんでした。</p>
    </c:if>
</div>

<!-- 隠し iframe（リクエスト処理用） -->
<iframe name="hidden_iframe" style="display: none;"></iframe>

<!-- プレイリスト追加モーダル -->
<div id="playlistModal" style="display: none;">
    <h3>プレイリストを選択</h3>
    <select id="playlistSelect">
        <c:forEach var="playlist" items="${userPlaylists}">
            <option value="${playlist.id}">${playlist.name}</option>
        </c:forEach>
    </select>
    <button id="confirmAddButton">追加</button>
</div>


    <a href="javascript:history.back()" class="back-button">戻る</a>
    
        <!-- メッセージ表示 -->
    <c:if test="${not empty message}">
        <p>${message}</p>
    </c:if>
<script>
function showTab(tabName) {
    // すべてのタブコンテンツを非表示にする
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.style.display = "none";
    });

    // すべてのタブボタンのアクティブ状態を解除
    document.querySelectorAll('.tab-menu button').forEach(button => {
        button.classList.remove('active');
    });

    // タブが存在するかチェック
    let targetTab = document.getElementById(tabName);
    if (targetTab) {
        targetTab.style.display = "block";
    } else {
        console.error(`showTab: タブ '${tabName}' が見つかりません。`);
        return;
    }

    // クリックされたタブボタンをアクティブにする
    let activeButton = document.querySelector(`[onclick="showTab('${tabName}')"]`);
    if (activeButton) {
        activeButton.classList.add('active');
    }
}

// 初期表示（デフォルトで「すべて」を表示）
document.addEventListener("DOMContentLoaded", function () {
    showTab('all');
});

function loadAlbumDetail(albumId) {
    console.log("loadAlbumDetail called with ID:", albumId);  // デバッグ用
    const url = "/SpotMusic/SpotifySearchServlet?action=album&id=" + encodeURIComponent(albumId);

    console.log("Fetch URL:", url);  // デバッグ用

    const contentDiv = document.querySelector('.content');
    fetch(url)
    .then(response => response.text())
    .then(data => {
        contentDiv.innerHTML = data;
    })
    .catch(error => {
        console.error('Error loading album details:', error);
        contentDiv.innerHTML = '<p>アルバム情報の取得に失敗しました。</p>';
    });
}
function loadArtistDetail(artistId) {
    console.log("loadArtistDetail called with ID:", artistId);  // デバッグ用
    const url = "/SpotMusic/SpotifyCheckFollowStatusServlet?action=artist&id=" + encodeURIComponent(artistId);

    console.log("Fetch URL:", url);  // デバッグ用

    const contentDiv = document.querySelector('.content');
    fetch(url)
    .then(response => response.text())
    .then(data => {
        contentDiv.innerHTML = data;
    })
    .catch(error => {
        console.error('Error loading artist details:', error);
        contentDiv.innerHTML = '<p>アーティスト情報の取得に失敗しました。</p>';
    });
}

function loadPlaylistDetail(playlistId) {
    console.log("loadPlaylistDetail called with ID:", playlistId);  // デバッグ用
    const url = "/SpotMusic/SpotifySearchServlet?action=playlist&id=" + encodeURIComponent(playlistId);

    console.log("Fetch URL:", url);  // デバッグ用

    const contentDiv = document.querySelector('.content');
    fetch(url)
    .then(response => response.text())
    .then(data => {
        contentDiv.innerHTML = data;
    })
    .catch(error => {
        console.error('Error loading playlist details:', error);
        contentDiv.innerHTML = '<p>プレイリスト情報の取得に失敗しました。</p>';
    });
}

	
</script>


</body>
</html>
