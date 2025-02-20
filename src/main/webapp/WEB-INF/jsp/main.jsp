<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.util.List"%>
<%@ page import="bean.SpotifyPlayListBean"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="bean.TrackBean"%>
<!DOCTYPE html>
<html lang="ja">
<!-- jQueryをCDNから読み込む -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link rel="stylesheet" type="text/css" href="<c:url value='/css/styles.css' />">
<link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SpotMusic - Web Player：すべての人に音楽を</title>
<link rel="stylesheet" type="text/css"
	href="<c:url value='/css/player.css' />">
<link rel="stylesheet" type="text/css"
	href="<c:url value='/css/delete.css' />">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">

<script src="https://sdk.scdn.co/spotify-player.js"></script>

<style>
#track-duration {
    display: none;
}
#album-name{
	display: none;
}
</style>



</head>
<body>
	<div class="header">
	<div class="logo">
	    <!-- リロード用アイコン -->
	    <a href="javascript:void(0)" onclick="reloadFollowedArtists()" class="reload-link">
	        <img src="<c:url value='/img/spotify.png' />" alt="ロゴを配置" class="reload-icon">
	    </a>
	</div>
<div class="home">
    		<a href="javascript:void(0);" onclick="loadHome()" class="homeBtn"><i class='bx bx-home-alt' ></i></a>
<div class="find">  
<form onsubmit="event.preventDefault(); loadSearchPage();" class="findForm">
    <input type="text" id="searchQuery" name="query" class="search" placeholder="何を再生したいですか？" required>
    <button class="search-button" type="submit"><i class='bx bx-search'></i></button>
</form>
</div>  
</div>
    
    <div class="actions">
        <!-- アカウントアイコン -->
        <div class="account-container">
<img src="<c:url value='/img/profile-user.png' />" alt="アイコン" class="account-icon" id="account-icon">
            <ul class="account-menu" id="account-menu">
            	<li>ログイン中のユーザー:<%= session.getAttribute("user_name") %></li>
                <li>
				  <a href="https://www.spotify.com/jp/account/overview/?utm_source=spotify&utm_medium=menu&utm_campaign=your_account" target="_blank" rel="noopener noreferrer">アカウント</a>
				</li>
                <li><a href="javascript:void(0);" onclick="friendlist()">フレンドリスト</a></li>
               <hr>
                <li><a href="javascript:void(0);" onclick="logout()">ログアウト</a></li>
            </ul>
        </div>
    </div>
</div>
<div class="main">
    <!-- 左側: プレイリスト -->
    <div class="sidebar">
		<!-- (プレイリスト作成用)非表示の iframe を用意し、フォーム送信をその中で処理 -->
		<iframe name="hidden_iframe" style="display: none;"></iframe>
		
        <div class="listIcon"><i class='bx bxs-playlist'></i><h2>マイプレイリスト</h2>
        <!-- プレイリスト作成ボタン -->
		<button id="showPlaylistForm" class="plus-button">+</button>
	</div>

		<!-- プレイリスト作成フォーム (デフォルトは非表示) -->
		<form id="playlistForm" action="FrontServlet" method="post"
			target="hidden_iframe" style="display:none; ">
			<input type="hidden" name="command"
				value="SpotifyCreatePlaylistCommand"> <input type="hidden"
				name="responseType" value="html">
			<!-- HTML レスポンスを要求 -->
			<div class="addPL">
			<label for="playlistName"></label> 
			
			<input type="text"
				id="playlistName"placeholder="新しプレイリスト名" name="playlistName" required  >
			<button type="submit">作成</button>
			</div>
			
		</form>
		<!--  ここまで -->


<%
    List<SpotifyPlayListBean> playlistBeans = (List<SpotifyPlayListBean>) session.getAttribute("playlistBeans");
    List<String> trackIds = new ArrayList<>();
    if (playlistBeans != null) {
        for (SpotifyPlayListBean playlist : playlistBeans) {
            for (TrackBean track : playlist.getTrackList()) {
                trackIds.add(track.getTrackId());
            }
        }
    }
    session.setAttribute("trackIds", trackIds);
    session.setAttribute("currentTrackIndex", 0);
    
%>
<div class="libList">
<div>
    <c:forEach var="playlist" items="${playlistBeans}">
    	<div class="MyPlayList">
       
            <button onclick="loadPlaylistPage('${playlist.playlistId}')" >

            <c:choose>
                <c:when test="${not empty playlist.imageUrl and fn:length(playlist.imageUrl) > 0}">
                    <img class="playlist-img" src="${playlist.imageUrl}" alt="Playlist Image"  />
                </c:when>
                <c:otherwise>
                    <img src="${pageContext.request.contextPath}/img/no_image.png" alt="No Image" />
                </c:otherwise>
            </c:choose>
            <div class="buttonPL">
                <div class="name"> ${playlist.playlistName}</div>
                <%-- <div class="id"> ${playlist.playlistId}</div> --%>
             </div>
            </button>
            
            
			<form action="FrontServlet" method="post" target="hidden_iframe">
			    <input type="hidden" name="command" value="SpotifyDeletePlaylistCommand">
			    <input type="hidden" name="playlistId" value="${playlist.playlistId}">
			    <input type="hidden" name="trackId" value="${track.trackId}">
			    <input type="hidden" name="responseType" value="html"> <!-- HTML レスポンスを要求 -->
			    <button class="delete"type="submit"><i class='bx bx-minus-circle'></i></button>
			</form>
			
		</div>            
        
    </c:forEach>
</div>
</div>
<iframe name="hidden_iframe" style="display: none;"></iframe>
</div>
<div class="resizer resizer-1"></div>
	<div class="content">
	<h2>フォロー中のアーティスト</h2>
		<div class="flAr">
		
		<%
		List<String> followedArtistNames = (List<String>) session.getAttribute("followedArtistNames");
		List<String> followedArtistImages = (List<String>) session.getAttribute("followedArtistImages");
		if (followedArtistNames == null) {
			followedArtistNames = new java.util.ArrayList<>();
		}
		if (followedArtistImages == null) {
			followedArtistImages = new java.util.ArrayList<>();
		}
		%>

		<c:choose>
			<c:when test="${not empty followedArtistNames}">
				<ul>
					<!-- アーティストの情報をループで表示 -->
					<c:forEach var="artistName" items="${followedArtistNames}"
						varStatus="status">
						<li>
							<!-- アーティストの画像と名前を表示 --> <c:if
								test="${not empty followedArtistImages[status.index]}">
								
									
							</c:if> 
							<a href="javascript:void(0);"
							onclick="loadArtistPage('${sessionScope.artistIds[status.index]}')">
							<img src="${followedArtistImages[status.index]}"
									alt="${artistName}" />
								${artistName} </a>
								
						</li>
					</c:forEach>
				</ul>
			</c:when>
			
			<c:otherwise>
			
				<p>フォロー中のアーティストが見つかりませんでした。</p>
			</c:otherwise>
		</c:choose>
		</div>
		



		<!-- 最近再生履歴の表示 -->
		<h2>最近再生された曲</h2>
		
		<c:if test="${not empty recentryDatas}">
			<div class="songList">
					<c:forEach var="entry" items="${recentryDatas}">
						
							
							
							<button onclick="playTrack('${entry.value.id}', '${entry.key}')"><c:if test="${not empty entry.value.image}">
									<img src="${entry.value.image}" alt="Track Image"></c:if>
								${entry.key}<!-- トラック名 -->
							</button>


						
					</c:forEach>
			</div>
		</c:if>
		<c:if test="${empty recentryDatas}">
			<p>No recently played tracks found.</p>
		</c:if>



		<!-- Top Mix Tracksの表示 -->
		<h2>Top Artist</h2>
		<div class="TopAr">
		<c:if test="${not empty artistDetails}">
			

				
					<c:forEach var="entry" items="${artistDetails}">
					
							<!-- アーティスト名 -->
							<a href="javascript:void(0);"
								onclick="loadArtistPage('${entry.value.id}')"> <!-- 画像URL -->
							<c:if test="${not empty entry.value.image}">
									<img src="${entry.value.image}" alt="Artist Image">
								</c:if>${entry.key}
							</a>

							
					
					</c:forEach>
				
			
		</c:if>

		<c:if test="${empty artistDetails}">
			<p>No recently played artists found.</p>
		</c:if>

</div>



		<!-- 新着のデータの表示 -->
		<h2>新着アルバム</h2>
		
		<c:if test="${not empty newRelease}">
		<div class="Album">
			
					<c:forEach var="entry" items="${newRelease}">
						
							
							<a href="javascript:void(0);" class="load-album-link"
								data-playlist-id="${entry.value.id}">
								<img src="${entry.value.image}" alt="Cover Image">
								 ${entry.key}
							 </a>
						
					</c:forEach>
		</div>
				
		</c:if>
		<c:if test="${empty newRelease}">
			<p>No recommended tracks found.</p>
		</c:if>


	</div>
	<div class="resizer resizer-2"></div>
	<!-- 右側: 詳細情報パネル -->
	<div class="property-panel" id="propertyPanel">
	<div class="track">
		<h2>トラック詳細</h2>
		<img id="current-track-image-2" src="" alt="トラック画像"
     style="display: none;">
		<!-- <p id="track-detail">再生中のトラック詳細が表示されます。</p> -->
		<strong><p id="now-playing2"></p>
			<p id="artist-name">artist:</p>
			<p id="album-name">album:</p>
			
			<!-- 消すとイメージ画像が消えたのでいったんそのままにしています。--> 
			<p id="track-duration"></p></strong>
			<p><span id="release-date"></span></p>
  
    </div>
    </div>
 </div>


	</div>

	<div id="player-container">
		<!-- 左側: 曲名表示 -->
		<div id="player-left">
			<img id="current-track-image" src="" alt="トラック画像"
				style="display: none;">
			<p id="now-playing">
				現在再生中: <span id="current-track">なし</span>
			</p>
		</div>

		<!-- 中央: プレイヤーコントロール -->
		<div id="player-controls">
			<button id="repeat-track">
				<i class="fas fa-redo"></i>
			</button>
			<button id="prev">
				<i class="fas fa-step-backward"></i>
			</button>
			<button id="play-pause">
				<i class="fas fa-play"></i>
			</button>
			<button id="next">
				<i class="fas fa-step-forward"></i>
			</button>
			<button id="shuffle-toggle">
				<i class="fas fa-random"></i>
			</button>
		</div>
		<!-- シークバーと再生時間 -->
		<div id="seek-container">
			<span id="current-time">0:00</span> <input type="range" id="seek-bar"
				value="0" min="0" max="100"> <span id="total-time">0:00</span>
		</div>

		<!-- 右側: 音量調整 -->
		<div id="player-right">
			<button id="mute-toggle">
				<i class="fas fa-volume-up"></i>
			</button>
			<input type="range" id="progress-bar" value="50" min="0" max="100">
		</div>
	</div>
		<script>
//リロード処理
function reloadFollowedArtists() {
    fetch('/SpotMusic/SpotifyCheckFollowStatusServlet')
        .then(response => response.text())
        .then(data => {
            console.log("フォローリストを再取得しました");

            // **データ取得後、ページを完全リロード**
            window.location.reload(true); // キャッシュをクリアして完全リロード
        })
        .catch(error => {
            console.error('フォローリストの更新に失敗しました:', error);

            // **エラー時もページをリロード (最新データ取得を試す)**
            window.location.reload(true);
        });
}
// フォロー状態を取得し、ボタンを更新する関数
function updateFollowButton(artistId) {
    fetch("/SpotMusic/SpotifyCheckFollowStatusServlet?id=" + artistId + "&fromArtistPage=true")
        .then(response => response.text())
        .then(isFollowed => {
            var followButton = document.getElementById("followButton");
            var followAction = document.getElementById("followAction");

            if (followButton && followAction) {  // 要素が存在するか確認
                if (isFollowed.trim() === "true") {
                    followButton.innerText = "リフォロー解除";
                    followAction.value = "unfollow";
                } else {
                    followButton.innerText = "フォロー";
                    followAction.value = "follow";
                }
            }
        })
        .catch(error => console.error("フォロー状態取得エラー:", error));
}
function updateFollowButtonFromSearchArtist(artistId) {
    fetch("/SpotMusic/SpotifyCheckFollowStatusServlet?id=" + artistId + "&fromSearchArtistPage=true")
        .then(response => response.text())
        .then(isFollowed => {
            var followButton = document.getElementById("followButton");
            var followAction = document.getElementById("followAction");

            if (followButton && followAction) {  // 要素が存在するか確認
                if (isFollowed.trim() === "true") {
                    followButton.innerText = "リフォロー解除";
                    followAction.value = "unfollow";
                } else {
                    followButton.innerText = "フォロー";
                    followAction.value = "follow";
                }
            }
        })
        .catch(error => console.error("フォロー状態取得エラー:", error));
}


</script>
	
	<script>
// プレイリストの詳細を受け取った場合
// プレイリストの詳細を表示する関数


document.addEventListener("DOMContentLoaded", function () {
    const params = new URLSearchParams(window.location.search);
    const playlistId = params.get("playlistId");
    const commentAdded = params.get("commentAdded");

    if (commentAdded === "true" && playlistId) {
        console.log("コメントが追加されました。プレイリストを再読み込みします。");
        loadPlaylistPage(playlistId);
    } else if (commentAdded === "true") {
        console.warn("コメントは追加されましたが、playlistId が取得できませんでした。");
    }
});
    
function loadPlaylistPage(playlistId) {
    if (!playlistId) {
        console.error('playlistId が指定されていません');
        return;
    }

    const url = "/SpotMusic/FrontServlet?command=PlayListDetails&playlistId=" + encodeURIComponent(playlistId);
    const contentDiv = document.querySelector('.content');

    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text();
        })
        .then(data => {
            contentDiv.innerHTML = data;
            console.log("プレイリストページがロードされました！");

            // **イベントリスナーを再適用**
            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>プレイリスト情報の取得に失敗しました。</p>';
        });
}



</script>

	<script>

//プレイリスト曲削除用


console.log("toggleMenu スクリプトが実行されました！");

//? 事前にグローバルで登録
 window.toggleMenu = function(button) {
     console.log("toggleMenu が呼ばれました");

     let menu = button.nextElementSibling;
     console.log("メニュー要素:", menu);

     // すべてのメニューを閉じる（他のメニューが開いている場合に備える）
     document.querySelectorAll(".menu-content").forEach(m => {
         if (m !== menu) {
             m.style.display = "none";
         }
     });

     // クリックしたメニューをトグル
     if (menu.style.display === "none" || menu.style.display === "") {
         menu.style.display = "block";
     } else {
         menu.style.display = "none";
     }

     console.log("適用後のスタイル:", menu.style.display);
 };

 // ? `document` にクリックイベントを適用
 document.addEventListener("click", function(event) {
     // メニューを開くボタン（menu-btn）がクリックされたら通常のトグル処理
     if (event.target.classList.contains("menu-btn")) {
         toggleMenu(event.target);
         return; // ここで処理を終了（他の処理を実行しない）
     }

     // クリックされた要素が `.menu-content` の内部でない場合、すべてのメニューを閉じる
     document.querySelectorAll(".menu-content").forEach(menu => {
         if (!menu.contains(event.target)) {
             menu.style.display = "none";
         }
     });
 });



 player.addListener('player_state_changed', state => {
	    console.log("プレイヤーの状態更新:", state);  // プレイヤー状態の確認

	    const playPauseButton = document.getElementById('play-pause');
	    const nowPlaying = document.getElementById('now-playing');
	    const currentAlbumImage = document.getElementById('current-album-image');
	    const currentAlbumName = document.getElementById('current-album-name');
	    const currentReleaseDate = document.getElementById('current-release-date');

	    // プレイヤーの状態が無い場合（曲が再生されていない場合）
	    if (!state || !state.track_window || !state.track_window.current_track) {
	        console.log("再生中の曲情報がありません");  // 再生中の曲がない場合
	        nowPlaying.innerText = "なし";
	        playPauseButton.innerHTML = `<i class="fas fa-play"></i>`; // 再生ボタンを表示
	        currentAlbumImage.style.display = "none";
	        currentAlbumName.innerText = "アルバム名: -";
	        currentReleaseDate.innerText = "リリース日: -";
	        return;
	    }

	    const track = state.track_window.current_track;
	    nowPlaying.innerText = track.name || "なし";

	    // 再生/停止ボタンのアイコン更新
	    if (state.paused) {
	        playPauseButton.innerHTML = `<i class="fas fa-play"></i>`;
	    } else {
	        playPauseButton.innerHTML = `<i class="fas fa-pause"></i>`;
	    }

	    // 曲の詳細情報を更新
	    updateCurrentTrackDetails();
	});

//曲の詳細情報（アルバム名、リリース日、アルバム画像）を更新

function updateCurrentTrackDetails() {
    console.log("getCurrentTrackDetails関数を呼び出し中...");  // デバッグ用メッセージ

    fetch("/SpotMusic/spotifyControl?action=getCurrentTrackDetails")
    .then(response => response.json())
    .then(data => {
        console.log("Spotify APIから取得したデータ:", data);  // 追加デバッグ用
        if (data.albumImageUrl) {
            console.log("アルバム画像URL:", data.albumImageUrl);  // 画像URLの確認
            currentAlbumImage.src = data.albumImageUrl;
            currentAlbumImage.style.display = "block";
        } else {
            console.log("アルバム画像URLが取得できませんでした");  // 画像URLがない場合
            currentAlbumImage.style.display = "none";
        }

        // アルバム名・リリース日の更新
        currentAlbumName.innerText = `アルバム名: ${data.albumName || "情報なし"}`;
        currentReleaseDate.innerText = `リリース日: ${data.releaseDate || "情報なし"}`;
    })
    .catch(error => {
        console.error("トラック詳細情報の取得エラー:", error);  // エラーメッセージ
    });
}



</script>


	<script>
    //画像用JavaScript
function updateCurrentTrackImages() {
    fetch("/SpotMusic/spotifyControl?action=getCurrentTrackImage")
        .then(response => response.json())
        .then(data => {
            if (data.imageUrl) {
                // 1つ目の画像を更新
                document.getElementById('current-track-image').src = data.imageUrl;
                document.getElementById('current-track-image').style.display = "block"; 

                // 2つ目の画像を更新
                document.getElementById('current-track-image-2').src = data.imageUrl;
                document.getElementById('current-track-image-2').style.display = "block"; 
            } else {
                document.getElementById('current-track-image').style.display = "none";
                document.getElementById('current-track-image-2').style.display = "none";
            }
        })
        .catch(error => console.error("現在のトラック画像取得エラー:", error));
}

    //再生プレイヤー用JavaScript
        window.onSpotifyWebPlaybackSDKReady = () => {
            const token = '<%=session.getAttribute("access_token")%>';

            if (!token || token === "null") {
                console.error("アクセストークンが無効です。再ログインしてください。");
                alert("アクセストークンが無効です。再ログインしてください。");
                return;
            }

            const player = new Spotify.Player({
                name: 'Web Playback SDK Player',
                getOAuthToken: cb => { cb(token); },
                volume: 0.5
            });

            player.addListener('ready', ({ device_id }) => {
                console.log('デバイスが準備できました:', device_id);
                setupDevice(device_id);
            });

            player.addListener('not_ready', ({ device_id }) => {
                console.log('デバイスがオフラインになりました:', device_id);
            });

            let trackEnded = false; // フラグ変数を追加
            let trackStarted = false; // 最初の再生を検知
            let lastTrackId = null;   // 現在再生中のトラックIDを記憶

            player.addListener('player_state_changed', state => {
                console.log("☆プレイヤーの状態更新:", state); // デバッグ用ログ

                const playPauseButton = document.getElementById('play-pause');
                const nowPlaying = document.getElementById('now-playing');
                const nowPlaying2 = document.getElementById('now-playing2');
                const artistName = document.getElementById('artist-name');
                const albumName = document.getElementById('album-name');
                const trackDuration = document.getElementById('track-duration');
                const releaseDate = document.getElementById('release-date'); // 追加: リリース日

                // デフォルトの状態（何も再生されていない時）
                if (!state || !state.track_window || !state.track_window.current_track) {
                    nowPlaying.innerText = "なし";
                    nowPlaying2.innerText = "なしAPT";
                    artistName.innerText = "APT";
                    albumName.innerText = "APT";
                    trackDuration.innerText = "APT";
                    releaseDate.innerText = "APT"; // 追加: リリース日もリセット
                    playPauseButton.innerHTML = `<i class="fas fa-play"></i>`; // 再生ボタンを表示
                    return;
                }

                const track = state.track_window.current_track;
                nowPlaying.innerText = track.name || "なし";
                nowPlaying2.innerText = track.name || "なし";
                artistName.innerText = track.artists.map(artist => artist.name).join(", ") || "アーティスト情報なし";
                albumName.innerText = track.album.name || "アルバム情報なし";
                trackDuration.innerText = formatDuration(track.duration_ms) || "0:00";
                releaseDate.innerText = track.album.release_date || ""; // 追加: リリース日を設定

                // 再生/停止ボタンのアイコンを更新
                if (state.paused) {
                    playPauseButton.innerHTML = `<i class="fas fa-play"></i>`; // 一時停止状態なら再生ボタンを表示
                } else {
                    playPauseButton.innerHTML = `<i class="fas fa-pause"></i>`; // 再生中なら停止ボタンを表示
                }

                // **2つの画像を更新**
                updateCurrentTrackImages(); 

                if (!state.paused && state.position > 0) {
                    trackStarted = true;
                    trackEnded = false; // 新しい曲が始まったのでリセット
                    lastTrackId = track ? track.id : null;
                }

                // **曲の終了判定**（最初の再生時はスキップ）
                if (trackStarted && state.paused && state.position === 0 && !state.track_window.next_tracks.length) {
                    if (!trackEnded) {
                        trackEnded = true; // 連続リクエスト防止
                        console.log("曲が終了しました。次の曲へ移行します。");

                        fetch("/SpotMusic/spotifyControl", {
                            method: "POST",
                            headers: { "Content-Type": "application/x-www-form-urlencoded" },
                            body: "action=nextTrack"
                        })
                        .then(response => response.text())
                        .then(() => {
                            trackEnded = false; // 次の曲再生後にフラグをリセット
                        })
                        .catch(error => {
                            console.error("次の曲への移行エラー:", error);
                            trackEnded = false; // エラー時もリセット
                        });
                    }
                }
            });
                        
                       
            // 曲の再生時間（ミリ秒）を「分:秒」の形式に変換する関数
            function formatDuration(ms) {
                const minutes = Math.floor(ms / 60000);
                const seconds = Math.floor((ms % 60000) / 1000);
                return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
            }
                       



            player.connect().then(success => {
                if (success) {
                    console.log("Spotify プレイヤーが接続されました。");

                    // 初回ロード時にSpotifyのシャッフル状態を取得し、UIと同期
                    syncShuffleState();
                } else {
                    console.error("Spotify プレイヤーの接続に失敗しました。");
                    alert("Spotify プレイヤーの接続に失敗しました。");
                }
            });


            document.getElementById('play-pause').addEventListener('click', () => {
                player.togglePlay().then(() => {
                    console.log("再生/停止を切り替えました");
                }).catch(err => console.error("再生/停止切り替えエラー:", err));
            });

            document.getElementById('prev').addEventListener('click', () => {
                console.log("前の曲ボタンが押されました"); 
                fetch("/SpotMusic/spotifyControl", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: "action=previousTrack"
                }).then(response => response.text())
                  .then(data => console.log("前の曲の応答: ", data))
                  .catch(error => console.error("エラー:", error));
            });

            document.getElementById('next').addEventListener('click', () => {
                console.log("次の曲ボタンが押されました");
                fetch("/SpotMusic/spotifyControl", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: "action=nextTrack"
                }).then(response => response.text())
                  .then(data => console.log("次の曲の応答: ", data))
                  .catch(error => console.error("エラー:", error));
            });
			//Mute
		    const muteButton = document.getElementById("mute-toggle");
		    let isMuted = false;
		    let lastVolume = 0.5; // ミュート解除時に戻す音量
		
		    muteButton.addEventListener("click", () => {
		        if (player) {
		            player.getVolume().then(volume => {
		                if (!isMuted) {
		                    lastVolume = volume; // 現在の音量を保存
		                    player.setVolume(0).then(() => {
		                        isMuted = true;
		                        muteButton.classList.add("muted");
		                        muteButton.innerHTML = `<i class="fas fa-volume-mute"></i>`;
		                    });
		                } else {
		                    player.setVolume(lastVolume).then(() => {
		                        isMuted = false;
		                        muteButton.classList.remove("muted");
		                        muteButton.innerHTML = `<i class="fas fa-volume-up"></i>`;
		                    });
		                }
		            }).catch(err => console.error("音量取得エラー:", err));
		        }
		    });
			


			//音量調整
			document.getElementById('progress-bar').addEventListener('input', (e) => {
    			const volume = e.target.value / 100;
    			player.setVolume(volume).then(() => {
        			console.log("音量が設定されました:", volume);
        
        		// ミュート解除時はボタンのアイコンも戻す
        			if (volume > 0) {
            			isMuted = false;
            			muteButton.classList.remove("muted");
            			muteButton.innerHTML = `<i class="fas fa-volume-up"></i>`;
        			}
    			}).catch(err => console.error("音量設定エラー:", err));
			});
			

            //Repeat
            document.getElementById('repeat-track').addEventListener('click', () => {
                fetch("/SpotMusic/spotifyControl", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: "action=toggleRepeat"
                }).then(response => response.text())
                  .then(data => console.log("リピートの応答: ", data))
                  .catch(error => console.error("エラー:", error));
            });
            //shuffle
            document.getElementById('shuffle-toggle').addEventListener('click', () => {
                fetch("/SpotMusic/spotifyControl", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: "action=toggleShuffle"
                })
                .then(response => response.text())
                .then(data => {
                    console.log("シャッフル状態更新:", data);
/*                     alert(data); */
                })
                .catch(error => console.error("シャッフル更新エラー:", error));
            });


            
        }

        async function controlSpotify(action, trackId = null, playlistId = null, deviceId = null, player = null, trackIndex = 0) {
            console.log("送信アクション: " + action);
            console.log("受け取った trackIndex: ", trackIndex);
            

            // プレイヤーが渡された場合は、Spotify Web Playback SDK の操作を優先
            if (player) {
                switch (action) {
                    case 'togglePlay':
                        player.togglePlay().then(() => {
                            console.log("再生/停止を切り替えました");
                        }).catch(err => console.error("再生/停止切り替えエラー:", err));
                        return;
                    case 'previousTrack':
                        player.previousTrack().then(() => {
                            console.log("前の曲に戻りました");
                        }).catch(err => console.error("前の曲エラー:", err));
                        return;
                    case 'nextTrack':
                        player.nextTrack().then(() => {
                            console.log("次の曲に進みました");
                        }).catch(err => console.error("次の曲エラー:", err));
                        return;
                    case 'setVolume':
                        player.setVolume(volume).then(() => {
                            console.log("音量を設定しました:", volume);
                        }).catch(err => console.error("音量設定エラー:", err));
                        return;
                }
            }

            const params = new URLSearchParams();
            params.append("action", action);
            console.log("送信データ:", params.toString());

            if (trackId) {
                params.append("trackId", trackId);
                console.log("送信するトラック ID: ", trackId);
            }

            if (playlistId) {
                params.append("playlistId", playlistId);
                console.log("送信するプレイリスト ID: ", playlistId);
            } else {
                console.log("プレイリスト ID はなし（検索やおすすめの曲）");
            }

            if (deviceId) {
                params.append("deviceId", deviceId);
                console.log("送信するデバイス ID: ", deviceId);
            }

            params.append("trackIndex", trackIndex);
            console.log("送信するトラックインデックス: ", trackIndex);

            try {
                const response = await fetch("/SpotMusic/spotifyControl", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: params,
                });

                if (!response.ok) {
                    const error = await response.text();
                    console.error("Error:", error);
                    alert("エラーが発生しました: " + error);
                } else {
                    console.log(action + " 成功");
                }
            } catch (error) {
                console.error("Request failed:", error);
            }
        }
  

        function playTrack(trackId, trackName, playlistId = null, trackIndex = 0) {
            console.log("送信するトラック ID: ", trackId);
            console.log("開始するトラックのインデックス: ", trackIndex);

            if (playlistId) {
                console.log("送信するプレイリスト ID: ", playlistId);
            } else {
                console.log("プレイリスト ID はなし（検索やおすすめの曲）");
            }

            controlSpotify("play", trackId, playlistId, null, null, trackIndex);

            const propertyPanel = document.getElementById('propertyPanel');
            const trackDetail = document.getElementById('track-detail');
            trackDetail.textContent = `${trackName}`;
            propertyPanel.classList.add('active');
        }


        async function setupDevice(deviceId) {
            console.log("デバイスのセットアップを開始: ", deviceId);
            const params = new URLSearchParams();
            params.append("action", "setup");
            params.append("deviceId", deviceId);

            try {
                const response = await fetch("/SpotMusic/spotifyControl", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: params,
                });

                if (!response.ok) {
                    const error = await response.text();
                    console.error("デバイスセットアップエラー:", error);
                    alert("デバイスのセットアップに失敗しました。Spotifyアプリを開いていますか？");
                } else {
                    console.log("デバイスセットアップ成功");
                }
            } catch (error) {
                console.error("デバイスセットアップ失敗:", error);
            }
        }

//Spotifyログアウト用JavaScript
	function logout() {
	    window.location.href = '/SpotMusic/FrontServlet?command=Logout';
	}

    </script>
	<script>
    // artist.jspを動的に読み込む関数
    function loadArtistPage(artistId) {
        var contentDiv = document.querySelector('.content');
        var url = '/SpotMusic/FrontServlet?command=ArtistDetails&artistId=' + artistId;

        fetch(url)
            .then(response => response.text())
            .then(data => {
                // 取得したデータを.content内に上書きする
                contentDiv.innerHTML = data;

                // ページのHTML更新後、フォロー状態を再取得
                updateFollowButton(artistId);
            })
            .catch(error => {
                console.error('Error loading artist page:', error);
                contentDiv.innerHTML = '<p>アーティスト情報の取得に失敗しました。</p>';
            });
    }

    // フォロー状態を取得し、ボタンを更新する関数
    function updateFollowButton(artistId) {
        fetch("/SpotMusic/SpotifyCheckFollowStatusServlet?id=" + artistId + "&fromArtistPage=true")
            .then(response => response.text())
            .then(isFollowed => {
                var followButton = document.getElementById("followButton");
                var followAction = document.getElementById("followAction");

                if (followButton && followAction) {  // 要素が存在するか確認
                    if (isFollowed.trim() === "true") {
                        followButton.innerText = "リフォロー解除";
                        followAction.value = "unfollow";
                    } else {
                        followButton.innerText = "フォロー";
                        followAction.value = "follow";
                    }
                }
            })
            .catch(error => console.error("フォロー状態取得エラー:", error));
    }
</script>

	<script>
    // アルバム情報を動的に読み込む関数
    function loadAlbumPage(albumId) {
        if (!albumId) {
            console.error('albumId が指定されていません');
            return;
        }

        // サーバーにリクエストを送信
        const url = "/SpotMusic/FrontServlet?command=AlbumDetails&albumId=" + encodeURIComponent(albumId);
        const contentDiv = document.querySelector('.content');

        // Fetch APIでリクエストを送信し、結果をページに埋め込む
        fetch(url)
            .then(response => {
                if (!response.ok) {
                    throw new Error('サーバーエラー: ' + response.status);
                }
                return response.text();
            })
            .then(data => {
                contentDiv.innerHTML = data; // 取得したHTMLを表示
            })
            .catch(error => {
                console.error('エラー発生:', error);
                contentDiv.innerHTML = '<p>アルバム情報の取得に失敗しました。</p>';
            });
    }
</script>

	<script>
//シークバー管理JavaScript
    const seekBar = document.getElementById('seek-bar');
    const currentTimeDisplay = document.getElementById('current-time');
    const totalTimeDisplay = document.getElementById('total-time');

    seekBar.addEventListener('change', () => {
        const positionMs = seekBar.value * 1000;
        fetch("/SpotMusic/spotifyControl", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: "action=seek&positionMs=" + positionMs
        }).then(response => response.text())
          .then(data => console.log("シークの応答: ", data))
          .catch(error => console.error("エラー:", error));
    });

    function updateProgress() {
        fetch("/SpotMusic/spotifyControl", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: "action=getPlaybackState"
        })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            if (data && data.item) {
                const progressMs = data.progress_ms || 0;
                const durationMs = data.item.duration_ms || 0;

                // シークバー設定
                seekBar.max = durationMs / 1000;
                seekBar.value = progressMs / 1000;

                // 現在時間と総再生時間の表示
                currentTimeDisplay.textContent = formatTime(progressMs);
                totalTimeDisplay.textContent = formatTime(durationMs);
            } else {
                console.error("無効なデータ: ", data);
                currentTimeDisplay.textContent = "0:00";
                totalTimeDisplay.textContent = "0:00";
            }
        })
        .catch(error => {
            console.error("再生状態の取得エラー:", error);
        });
    }

    // 時間を mm:ss 形式にフォーマットする関数
    function formatTime(ms) {
        const minutes = Math.floor(ms / 60000);
        const seconds = Math.floor((ms % 60000) / 1000);
        return minutes + ":" + (seconds < 10 ? '0' : '') + seconds;
    }

    // 1秒ごとに更新
    setInterval(updateProgress, 1000);
     
</script>

	<script>
//アカウントメニューの開閉
document.getElementById('account-icon').addEventListener('click', () => {
    const menu = document.getElementById('account-menu');
    const isDisplayed = menu.style.display === 'block';
    menu.style.display = isDisplayed ? 'none' : 'block';
});

// 他の場所をクリックした場合にメニューを閉じる
document.addEventListener('click', (event) => {
    const menu = document.getElementById('account-menu');
    const icon = document.getElementById('account-icon');
    if (!icon.contains(event.target) && !menu.contains(event.target)) {
        menu.style.display = 'none';
    }
});
</script>
	<script>
//再生プレイヤー　シャッフルCSS用JavaScript
        document.getElementById('shuffle-toggle').addEventListener('click', function() {
            this.classList.toggle('active');
        });
//再生プレイヤー　リピートCSS用JavaScript
 document.addEventListener("DOMContentLoaded", () => {
	    const repeatButton = document.getElementById('repeat-track');

	    // 初回ロード時に現在のリピート状態を取得し、適用
	    fetch("/SpotMusic/spotifyControl?action=getRepeatState")
	        .then(response => response.json())
	        .then(data => {
	            applyRepeatState(data.repeatState);
	        })
	        .catch(error => console.error("リピート状態取得エラー:", error));

	    // リピートボタンのクリックイベント
	    repeatButton.addEventListener('click', () => {
	        fetch("/SpotMusic/spotifyControl", {
	            method: "POST",
	            headers: {
	                "Content-Type": "application/x-www-form-urlencoded"
	            },
	            body: `action=toggleRepeat`
	        })
	        .then(response => response.json())
	        .then(data => {
	            if (data.repeatState) {
	                applyRepeatState(data.repeatState);
	            }
	        })
	        .catch(error => console.error("リピート設定エラー:", error));
	    });

	    // CSS適用用の関数
	    function applyRepeatState(state) {
	        repeatButton.classList.remove('off', 'playlist', 'track');
	        if (state === "context") {
	            repeatButton.classList.add('playlist');
	        } else if (state === "track") {
	            repeatButton.classList.add('track');
	        } else {
	            repeatButton.classList.add('off');
	        }
	    }
	});
	//シャッフル
	function syncShuffleState() {
    fetch("/SpotMusic/spotifyControl?action=syncShuffleState")
        .then(response => response.json())
        .then(data => {
            if (data.shuffleState !== undefined) {
                applyShuffleState(data.shuffleState);
            }
        })
        .catch(error => console.error("シャッフル状態同期エラー:", error));
}

// シャッフル状態を適用する関数
function applyShuffleState(isShuffle) {
    const shuffleButton = document.getElementById('shuffle-toggle');
    if (isShuffle) {
        shuffleButton.classList.add('active');
    } else {
        shuffleButton.classList.remove('active');
    }
}
	
 </script>
	<script>
document.addEventListener('DOMContentLoaded', function () {
    $(document).on('click', '.load-album-link', function () {
        const albumId = $(this).data('playlist-id'); // data-playlist-idを取得
        console.log("Album ID clicked:", albumId);  // クリックしたIDを確認
        loadAlbumPage(albumId);  // 関数を呼び出し
    });
});

function loadAlbumPage(albumId) {
    console.log("loadAlbumPage called with albumId:", albumId);  // デバッグ用
    const url = "/SpotMusic/FrontServlet?command=AlbumDetails&albumId=" + albumId;
    console.log("Fetch URL:", url);  // デバッグ用

    const contentDiv = document.querySelector('.content');
    fetch(url)
    .then(response => response.text())
    .then(data => {
        contentDiv.innerHTML = data;
    })
    .catch(error => {
        console.error('Error loading album page:', error);
        contentDiv.innerHTML = '<p>アルバム情報の取得に失敗しました。</p>';
    });
}
</script>


	<script>
$(document).ready(function(){
    $("#commentForm").submit(function(event){
        event.preventDefault(); // デフォルトのフォーム送信を防ぐ

        $.ajax({
            type: "POST",
            url: "FrontServlet",
            data: $(this).serialize(),
            dataType: "json", // JSONを期待する
            success: function(response) {
                console.log("レスポンス:", response); // デバッグ用
                $("#commentInput").val(""); // 入力欄をクリア
                updateComments(response);  // コメントを画面更新
            },
            error: function(xhr, status, error) {
                console.error("エラー:", xhr.responseText);
                alert("コメントの送信に失敗しました。");
            }
        });
    });

    function updateComments(comments) {
        let commentList = $("#commentList");
        commentList.empty(); // 一旦リストをクリア

        if (comments.length === 0) {
            commentList.append("<p>まだコメントがありません。</p>");
            return;
        }

        comments.forEach(comment => {
            commentList.append(`
                <li>
                    <strong>${comment.userId}</strong>: ${comment.sendComment}<br>
                    <small>${comment.sendTime}</small>
                    </li>
                    `);
                });
            }
        });


function loadSearchPage() {
    console.log("loadSearchPage called");  // デバッグ用
    const query = document.getElementById("searchQuery").value;
    const url = "/SpotMusic/FrontServlet?command=SpotifySearchCommand&query=" + encodeURIComponent(query);

    console.log("Fetch URL:", url);  // デバッグ用

    const contentDiv = document.querySelector('.content');
    fetch(url)
    .then(response => response.text())
    .then(data => {
        contentDiv.innerHTML = data;
    })
    .catch(error => {
        console.error('Error loading search page:', error);
        contentDiv.innerHTML = '<p>検索ページの取得に失敗しました。</p>';
    });
}

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
                    followButton.innerText = "リフォロー解除";
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
	<script>
//プレイリスト削除JavaScript
function deletePlaylist(playlistId) {
    if (!confirm("本当にこのプレイリストを削除しますか？")) {
        return;
    }

    let formData = new FormData();
    formData.append("command", "SpotifyDeletePlaylistCommand");
    formData.append("playlistId", playlistId);
    formData.append("responseType", "html"); // HTMLレスポンスを要求

    fetch("FrontServlet", {
        method: "POST",
        body: formData
    })
    .then(response => response.text())  // HTML を受け取る
    .then(html => {
        console.log("レスポンスHTML:", html); // デバッグ用
        document.body.innerHTML += html; // HTML のスクリプトを実行
    })
    .catch(error => console.error("エラー:", error));
}


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



</script>
	<script>
//プレイリスト作成ボタン
document.getElementById("showPlaylistForm").addEventListener("click", function() {
    document.getElementById("playlistForm").style.display = "block";
    this.style.display = "none"; // ボタンを非表示にする
});

document.getElementById("playlistForm").addEventListener("submit", function() {
    setTimeout(() => {
        document.getElementById("playlistForm").style.display = "none";
        document.getElementById("showPlaylistForm").style.display = "block"; // 「＋」ボタンを再表示
    }, 500); // 送信後少し待って閉じる
});
</script>


	<script>
function friendlist() {
    const url = '/SpotMusic/FrontServlet?command=FriendList&userId=' + encodeURIComponent('${sessionScope.user_id}');
    const contentDiv = document.querySelector('.content');

    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text();
        })
        .then(data => {
            contentDiv.innerHTML = data;
            console.log("フレンドリストページがロードされました！");

            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>フレンドリストの取得に失敗しました。</p>';
        });
}


function userList() {
    const userId = encodeURIComponent('${sessionScope.user_id}'); // user_idを取得
    const url = '/SpotMusic/FrontServlet?command=UsersList&userId=' + userId;
    const contentDiv = document.querySelector('.content');

    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text();
        })
        .then(data => {
            contentDiv.innerHTML = data;
            console.log("ユーザーリストページがロードされました！");

            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>ユーザーリストの取得に失敗しました。</p>';
        });
}
function blockList() {
    const userId = encodeURIComponent('${sessionScope.user_id}'); // user_idを取得
    const url = '/SpotMusic/FrontServlet?command=BlockList&userId=' + userId;
    const contentDiv = document.querySelector('.content');

    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text();
        })
        .then(data => {
            contentDiv.innerHTML = data;
            console.log("ブロックリストページがロードされました！");

            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>ブロックリストの取得に失敗しました。</p>';
        });
}



</script>





	<script>
        console.log("スクリプトが読み込まれました");

        document.addEventListener("DOMContentLoaded", () => {
            console.log("DOMContentLoaded イベント発火");

            const currentTrackName = document.getElementById("currentTrackName");
            const currentAlbumName = document.getElementById("currentAlbumName");
            const currentReleaseDate = document.getElementById("currentReleaseDate");
            const currentAlbumImage = document.getElementById("currentAlbumImage");
				
            function fetchCurrentTrackDetails() {
                console.log("fetchCurrentTrackDetails を実行");

                fetch("/SpotMusic/spotifyControl?action=getCurrentTrackDetails")
                    .then(response => {
                        console.log("APIレスポンスステータス:", response.status);
                        return response.json();
                    })
                    .then(data => {
                        console.log("Spotify APIから取得したデータ:", data);
                    })
                    .catch(error => {
                        console.error("トラック詳細情報の取得エラー:", error);
                    });
            }

            fetchCurrentTrackDetails();

            document.getElementById("refreshButton").addEventListener("click", fetchCurrentTrackDetails);
        });


        let lastAlbumId = null; // 前回のアルバムIDを保持

        player.addListener('player_state_changed', state => {
            console.log("＄＄＄プレイヤーの状態更新:", state); // デバッグ用ログ

            const playPauseButton = document.getElementById('play-pause');
            const nowPlaying = document.getElementById('now-playing');
            const nowPlaying2 = document.getElementById('now-playing2');
            const artistName = document.getElementById('artist-name');
            const albumName = document.getElementById('album-name');
            const trackDuration = document.getElementById('track-duration');
            const releaseDate = document.getElementById('release-date'); // 追加: リリース日

            // デフォルトの状態（何も再生されていない時）
            if (!state || !state.track_window || !state.track_window.current_track) {
                nowPlaying.innerText = "なし";
                nowPlaying2.innerText = "なし";
                artistName.innerText = "";
                albumName.innerText = "";
                trackDuration.innerText = "";
                releaseDate.innerText = ""; // 追加: リリース日もリセット
                playPauseButton.innerHTML = `<i class="fas fa-play"></i>`; // 再生ボタンを表示
                return;
            }

            const track = state.track_window.current_track;
            nowPlaying.innerText = track.name || "なし";
            nowPlaying2.innerText = track.name || "なし";
            artistName.innerText = track.artists.map(artist => artist.name).join(", ") || "アーティスト情報なし";
            albumName.innerText = track.album.name || "アルバム情報なし";
            trackDuration.innerText = formatDuration(track.duration_ms) || "0:00";

            // **リリース日を更新**
            if (track.album.id !== lastAlbumId) {
                lastAlbumId = track.album.id; // アルバムIDを更新
                fetchReleaseDate(track.album.id, releaseDate); // 新しいアルバムのリリース日を取得
            }

            // 再生/停止ボタンのアイコンを更新
            if (state.paused) {
                playPauseButton.innerHTML = `<i class="fas fa-play"></i>`; // 一時停止状態なら再生ボタンを表示
            } else {
                playPauseButton.innerHTML = `<i class="fas fa-pause"></i>`; // 再生中なら停止ボタンを表示
            }

            // **2つの画像を更新**
            updateCurrentTrackImages(); 

            if (!state.paused && state.position > 0) {
                trackStarted = true;
                trackEnded = false; // 新しい曲が始まったのでリセット
                lastTrackId = track ? track.id : null;
            }

            // **曲の終了判定**（最初の再生時はスキップ）
            if (trackStarted && state.paused && state.position === 0 && !state.track_window.next_tracks.length) {
                if (!trackEnded) {
                    trackEnded = true; // 連続リクエスト防止
                    console.log("曲が終了しました。次の曲へ移行します。");

                    fetch("/SpotMusic/spotifyControl", {
                        method: "POST",
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: "action=nextTrack"
                    })
                    .then(response => response.text())
                    .then(() => {
                        trackEnded = false; // 次の曲再生後にフラグをリセット
                    })
                    .catch(error => {
                        console.error("次の曲への移行エラー:", error);
                        trackEnded = false; // エラー時もリセット
                    });
                }
            }
        });

        /**
         * **Spotify Web API を使用してアルバムのリリース日を取得**
         */
        function fetchReleaseDate(albumId, releaseDateElement) {
            if (!albumId) {
                releaseDateElement.innerText = "";
                return;
            }

            const accessToken = "YOUR_SPOTIFY_ACCESS_TOKEN"; // ここにアクセストークンをセット

            fetch(`https://api.spotify.com/v1/albums/${albumId}`, {
                method: "GET",
                headers: {
                    "Authorization": `Bearer ${accessToken}`
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data && data.release_date) {
                    releaseDateElement.innerText = data.release_date;
                } else {
                    releaseDateElement.innerText = "";
                }
            })
            .catch(error => {
                console.error("リリース日取得エラー:", error);
                releaseDateElement.innerText = "";
            });
        }

        
    </script>
<script>
//ホームに戻る
    function loadHome() {
        const url = '/SpotMusic/FrontServlet?command=GoToMainCommand';
        const contentDiv = document.querySelector('.content'); // メインの表示エリアのみ更新

        fetch(url)
            .then(response => {
                if (!response.ok) {
                    throw new Error('サーバーエラー: ' + response.status);
                }
                return response.text();
            })
            .then(data => {
                const tempDiv = document.createElement('div'); // 一時的にレスポンスを挿入
                tempDiv.innerHTML = data;

                // `.content` の中身だけを更新
                const newContent = tempDiv.querySelector('.content');
                if (newContent) {
                    contentDiv.innerHTML = newContent.innerHTML; // **headerには影響を与えず、.contentだけ更新**
                }

                console.log("ホームページの .content 部分がロードされました！");
            })
            .catch(error => {
                console.error('エラー発生:', error);
                contentDiv.innerHTML = '<p>ホーム画面の読み込みに失敗しました。</p>';
            });
    }
</script>
<script>
// 曲削除
window.removeTrack = function(playlistId, trackId, button) {
    console.log("removeTrack が呼ばれました");
    $.ajax({
        type: "POST",
        url: "FrontServlet?command=SpotifyRemoveTrack",
        data: { playlistId: playlistId, trackId: trackId },
        success: function(response) {
            $(button).closest("li").remove();
        },
        error: function() {
            alert("削除に失敗しました。");
        }
    });
};

// **ページ読み込み時にフォロー状態を更新**
window.onload = function () {
    var artistId = document.getElementById("artistId") ? document.getElementById("artistId").value : null;
    if (artistId) {
        setTimeout(() => updateFollowButtonFromSearchArtist(artistId), 500); // 0.5秒遅延で実行
    }
};


// **フォローボタンのクリックイベント**
$(document).ready(function () {
    $("#followButton").on("click", function () {
        var artistId = $("#artistId").val();
        var action = $("#followAction").val();
        var endpoint = action === "follow"
            ? "/SpotMusic/SpotifyFollowArtistServlet"
            : "/SpotMusic/SpotifyUnfollowArtistServlet";

        $.ajax({
            type: "POST",
            url: endpoint,
            data: { id: artistId },
            success: function () {
                console.log("フォロー操作成功");
                updateFollowButtonFromSearchArtist(artistId); // 状態を即時更新
            },
            error: function () {
                console.error("フォロー操作失敗");
            }
        });
    });
});
</script>
<script>
const resizer = document.querySelector('.resizer-1');
const sidebar = document.querySelector('.sidebar');
const content = document.querySelector('.content');
let isResizing = false;

resizer.addEventListener('mousedown', (e) => {
    isResizing = true;
    document.addEventListener('mousemove', handleResize);
    document.addEventListener('mouseup', () => {
        isResizing = false;
        document.removeEventListener('mousemove', handleResize);
    });
});

function handleResize(e) {
    if (isResizing) {
        // Tính toán độ rộng mới của sidebar
        const newWidth = window.innerWidth - e.clientX;
        const minWidth = window.innerWidth * 0.05;  // 5%
        const maxWidth = window.innerWidth * 0.18;  // 18%

        // Giới hạn độ rộng của sidebar
        if (newWidth >= minWidth && newWidth <= maxWidth) {
            sidebar.style.width = `${newWidth}px`;
            content.style.width = `calc(100% - ${newWidth}px - 15px)`; // Điều chỉnh độ rộng content

            // Thêm class 'narrow' khi sidebar thu hẹp dưới 5%
            if (newWidth <= minWidth) {
                sidebar.classList.add('narrow');
            } else {
                sidebar.classList.remove('narrow');
            }
        }
    }
}



</script>

</body>
</html>