<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<link rel="stylesheet" type="text/css" href="<c:url value='/css/styles.css' />">
<head>
    <title>検索結果</title>
    

	
</head>
<body>
<div class="SearchPage">

<!-- タブメニュー -->
<c:set var="noImageUrl" value="${fn:escapeXml(pageContext.request.contextPath)}/img/no_image.png" />
<div class="tab-menu">
    <button class="active" onclick="showTab('all')">すべて</button>
    <button class="track" onclick="showTab('tracks')">曲</button>
    <button class="albums"onclick="showTab('albums')">アルバム</button>
    <button class="artits"onclick="showTab('artists')">アーティスト</button>
    <button class="playlists"onclick="showTab('playlists')">プレイリスト</button>
</div>

<!-- すべての結果（デフォルト） -->
<div id="all" class="tab-content active">
  

    <!-- 曲のリスト -->
    <c:if test="${not empty tracks}">
        <div class="track-list">
            <c:forEach var="track" items="${tracks}">
                <div class="track-item">
                	<div class="trackImg">
                    <c:choose>
                        <c:when test="${not empty track.image}">
                            <img src="${track.image}" alt="アルバム画像">
                        </c:when>
                        <c:otherwise>
                            <img src="<c:url value='/img/no_image.png' />" alt="No Image">
                        </c:otherwise>
                    </c:choose>
                    </div>

                    ${track.name}

                    <!-- プレイリスト追加フォーム -->
				<form class="add-track-form" action="FrontServlet" method="post" target="hidden_iframe">
				    <input type="hidden" name="command" value="addTrack">
				    <input type="hidden" name="trackId" value="${track.id}">
				    <select name="playlistId">
				        <c:forEach var="playlist" items="${userPlaylists}">
				            <option value="${playlist.id}">${playlist.name}</option>
				        </c:forEach>
				    </select>
				    <button class="add-button" >追加</button>
				    <button onclick="playTrack('${track.id}', '${track.name}')">再生</button>
				</form>

                </div>
            </c:forEach>
        </div>
    </c:if>

    <!-- アルバムのリスト -->
    <c:if test="${not empty albums}">
        <h3>アルバム</h3>
        <div class="Album">
			<c:forEach var="album" items="${albums}">
			   
			        <a href="javascript:void(0);" 
			           onclick="loadAlbumDetail('${album.id}')">
			            <img src="${album.image}">
			            ${album.name}
			        </a>
			    
			</c:forEach>
</div>

        
    </c:if>

    <!-- アーティストのリスト -->
    <c:if test="${not empty artists}">
        <h3>アーティスト</h3>
        <div class="TopAr">
			<c:forEach var="artist" items="${artists}">
			   
			        <a href="javascript:void(0);" 
			           onclick="loadArtistDetail('${artist.id}')">
			            <img src="${artist.image}">
			            ${artist.name}
			        </a>
			    
			</c:forEach>

        </div>
    </c:if>

    <!-- プレイリストのリスト -->
    <c:if test="${not empty playlists}">
        <h3>プレイリスト</h3>
        <div class="Album">
			<c:forEach var="playlist" items="${playlists}">
			    
			        <a href="javascript:void(0);" 
			           onclick="loadPlaylistDetail('${playlist.id}')">
			            <img src="${playlist.image}">
			            ${playlist.name}
			        </a>
			    
			</c:forEach>

        </div>
    </c:if>
</div>

<!-- 曲のみ -->
<div id="tracks" class="tab-content">
   
    <c:if test="${not empty tracks}">
        <div class="track-list">
            <c:forEach var="track" items="${tracks}">
                <div class="track-item">
                	<div class="trackImg">
                    <c:choose>
                        <c:when test="${not empty track.image}">
                            <img src="${track.image}" alt="アルバム画像">
                        </c:when>
                        <c:otherwise>
                            <img src="<c:url value='/img/no_image.png' />" alt="No Image">
                        </c:otherwise>
                    </c:choose>
                    </div>

                    ${track.name}

                    <!-- プレイリスト追加フォーム -->
				<form class="add-track-form" action="FrontServlet" method="post" target="hidden_iframe">
				    <input type="hidden" name="command" value="addTrack">
				    <input type="hidden" name="trackId" value="${track.id}">
				    <select name="playlistId">
				        <c:forEach var="playlist" items="${userPlaylists}">
				            <option value="${playlist.id}">${playlist.name}</option>
				        </c:forEach>
				    </select>
				    <button type="submit">追加</button>
				    <button type="button" onclick="playTrack('${track.id}', '${track.name}')">再生</button>
				</form>

                </div>
            </c:forEach>
        </div>
    </c:if>
</div>

<!-- アルバムタブ -->
<div id="albums" class="tab-content">
 
    <div class="Album">
    <c:if test="${not empty albums}">
        
			<c:forEach var="album" items="${albums}">
			    
			        <a href="javascript:void(0);" 
			           onclick="loadAlbumDetail('${album.id}')">
			            <img src="${album.image}">
			            ${album.name}
			        </a>
			    
			</c:forEach>

        
    </c:if>
    <c:if test="${empty albums}">
        <p>アルバムが見つかりませんでした。</p>
    </c:if>
    </div>
</div>

<!-- アーティストタブ -->
<div id="artists" class="tab-content">
 
    <c:if test="${not empty artists}">
        <div class="TopAr">
			<c:forEach var="artist" items="${artists}">
			   
			        <a href="javascript:void(0);" 
			           onclick="loadArtistDetail('${artist.id}')">
			            <img src="${artist.image}">
			            ${artist.name}
			        </a>
			    
			</c:forEach>

        </div>
    </c:if>
    <c:if test="${empty artists}">
        <p>アーティストが見つかりませんでした。</p>
    </c:if>
</div>

<!-- プレイリストタブ -->
<div id="playlists" class="tab-content">
 
    <c:if test="${not empty playlists}">
        <div class="Album">
			<c:forEach var="playlist" items="${playlists}">
			    
			        <a href="javascript:void(0);" 
			           onclick="loadPlaylistDetail('${playlist.id}')">
			            <img src="${playlist.image}">
			            ${playlist.name}
			            
			        </a>
			    
			</c:forEach>
        </div>
    </c:if>
    <c:if test="${empty playlists}">
        <p>プレイリストが見つかりませんでした。</p>
    </c:if>


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


    
    
        <!-- メッセージ表示 -->
    <c:if test="${not empty message}">
        <p>${message}</p>
    </c:if>
</div>
</div>

<script>
function showTab(tabName) {
/*     // すべてのタブコンテンツを非表示にする
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.style.display = "none";
    }); */

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
    console.log("loadAlbumDetail called with ID:", albumId); // デバッグ用

    // URLエンコード処理
    const url = "/SpotMusic/FrontServlet?command=SpotifySearchCommand&action=album&id="+ encodeURIComponent(albumId);

    console.log("Fetch URL:", url); // デバッグ用

    const contentDiv = document.querySelector('.content');
    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return response.text();
        })
        .then(data => {
            console.log("Response received for album details."); // デバッグ用
            contentDiv.innerHTML = data;
        })
        .catch(error => {
            console.error('Error loading album details:', error);
            contentDiv.innerHTML = '<p>アルバム情報の取得に失敗しました。</p>';
        });
}

function loadArtistDetail(artistId) {
    console.log("loadArtistDetail called with ID:", artistId);

    const url = "/SpotMusic/FrontServlet?command=SpotifySearchCommand&action=artist&id=" + encodeURIComponent(artistId);
    console.log("Fetch URL:", url);

    const contentDiv = document.querySelector('.content');

    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return response.text();
        })
        .then(data => {
            console.log("Response received for artist details.");
            contentDiv.innerHTML = data;

            // **searchartist.jsp を描画した後にフォロー状態を取得**
            updateFollowButtonFromSearchArtist(artistId);
        })
        .catch(error => {
            console.error('Error loading artist details:', error);
            contentDiv.innerHTML = '<p>アーティスト情報の取得に失敗しました。</p>';
        });
}

// **フォロー状態を取得し、ボタンを更新する関数**
function updateFollowButtonFromSearchArtist(artistId) {
    var timestamp = new Date().getTime();  // キャッシュ防止用のタイムスタンプ

    $.ajax({
        type: "GET",
        url: "/SpotMusic/SpotifyCheckFollowStatusServlet",
        data: { id: artistId, fromSearchArtistPage: true, ts: timestamp },  // `ts` パラメータを追加
        success: function(isFollowed) {
            var followButton = document.getElementById("followButton");
            var followAction = document.getElementById("followAction");

            if (followButton && followAction) {
                var trimmedResponse = isFollowed.trim();
                
                if (trimmedResponse === "true") {
                    followButton.innerText = "フォロー解除";
                    followAction.value = "unfollow";
                } else if (trimmedResponse === "false") {
                    followButton.innerText = "フォロー";
                    followAction.value = "follow";
                } else {
                    console.warn("予期しないレスポンス:", isFollowed);
                    followButton.innerText = "フォロー (未確認)";
                    followAction.value = "follow";
                }
            }
        },
        error: function() {
            console.error("フォロー状態の取得に失敗しました");
        }
    });
}


function loadPlaylistDetail(playlistId) {
    console.log("loadPlaylistDetail called with ID:", playlistId); // デバッグ用
    const url = "/SpotMusic/FrontServlet?command=SpotifySearchCommand&action=playlist&id=" + encodeURIComponent(playlistId);

    console.log("Fetch URL:", url); // デバッグ用

    const contentDiv = document.querySelector('.content');
    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return response.text();
        })
        .then(data => {
            console.log("Response received for playlist details."); // デバッグ用
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
