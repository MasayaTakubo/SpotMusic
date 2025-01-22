<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page import="java.util.List"%>
<%@ page import="bean.SpotifyPlayListBean"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="bean.TrackBean"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Spotify情報表示</title>

    <script src="https://sdk.scdn.co/spotify-player.js"></script>

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

        <ul>
            <c:forEach var="playlist" items="${playlistBeans}">
                <li>
                    <strong>プレイリスト名:</strong> ${playlist.playlistName}<br>
                    <strong>プレイリストID:</strong> ${playlist.playlistId}<br>
                    <ul>
                        <c:forEach var="track" items="${playlist.trackList}">
                            <li>
                                <strong>トラック名:</strong> ${track.trackName}<br>
                                <strong>アーティスト名:</strong> ${track.artistName}<br>
                                <button onclick="playTrack('${track.trackId}', '${track.trackName}')">再生</button>
                            </li>
                        </c:forEach>
                    </ul>
                </li>
            </c:forEach>
        </ul>
    </div>

    <!-- 中央: 人気のアーティスト -->
    <div class="content">
        <h2>フォロー中のアーティスト</h2>
        <%
            List<String> followedArtistNames = (List<String>) session.getAttribute("followedArtistNames");
            if (followedArtistNames == null) {
                followedArtistNames = new java.util.ArrayList<>();
            }
        %>
        
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
        </ul>
        
        
        
        <h1>今回新たにしゅとくしようとしているもの</h1>
         <!-- 最近再生履歴の表示 -->
    <h2>Recently Played Tracks</h2>
    <c:if test="${not empty recentryDatas}">
        <table>
            <thead>
                <tr>
                    <th>Track ID</th>
                
                </tr>
            </thead>
            <tbody>
                <c:forEach var="entry" items="${recentryDatas}">
                    <tr>
                        <td>${entry.key}</td>
                        
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </c:if>
    <c:if test="${empty recentryDatas}">
        <p>No recently played tracks found.</p>
    </c:if>

    <!-- Top Mix Tracksの表示 -->
    <h2>Top Mix Tracks</h2>
    <c:if test="${not empty topMixDatas}">
        <table>
            <thead>
                <tr>
                    <th>Track ID</th>
                    
                </tr>
            </thead>
            <tbody>
                <c:forEach var="entry" items="${topMixDatas}">
                    <tr>
                        <td>${entry.key}</td>
                        
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </c:if>
    <c:if test="${empty topMixDatas}">
        <p>No top mix tracks found.</p>
    </c:if>

    <!-- レコメンドデータの表示 -->
    <h2>Recommended Tracks</h2>
<c:if test="${not empty recomendDatas}">
    <table>
        <thead>
            <tr>
                <th>Track Name</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="entry" items="${recomendDatas}">
                <tr>
                    <td>${entry.value}</td> <!-- トラック名だけ表示 -->
                </tr>
            </c:forEach>
        </tbody>
    </table>
</c:if>
<c:if test="${empty recomendDatas}">
    <p>No recommended tracks found.</p>
</c:if>
    
        
        
        
        
        
        
        
        
        
        

        <h1>Spotify API情報取得結果</h1>
        <c:if test="${not empty error}">
            <p style="color: red;">エラー: ${error}</p>
        </c:if>
        <c:if test="${empty error}">
            <p>Spotify APIの情報取得に成功しました。</p>
        </c:if>
        <br>
        <a href="/auth">プレイリストを再取得</a>
    </div>

    <!-- 右側: 詳細情報パネル -->
    <div class="property-panel" id="propertyPanel">
        <h2>トラック詳細</h2>
        <p id="track-detail">再生中のトラック詳細が表示されます。</p>
        <div id="player-controls">
            <h3>プレイヤー</h3>
            <p id="now-playing">現在再生中: <span id="current-track">なし</span></p>
            <button id="prev">前の曲</button>
            <button id="play-pause">再生/停止</button>
            <button id="next">次の曲</button>
            <input type="range" id="progress-bar" value="50" min="0" max="100">
        </div>
    </div>

    <script>
        window.onSpotifyWebPlaybackSDKReady = () => {
            const token = '<%= session.getAttribute("access_token") %>';

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

            player.addListener('player_state_changed', state => {
                if (state) {
                    const track = state.track_window.current_track;
                    document.getElementById('now-playing').innerText = track ? track.name : "なし";
                }
            });

            player.connect().then(success => {
                if (success) {
                    console.log("Spotify プレイヤーが接続されました。");
                } else {
                    console.error("Spotify プレイヤーの接続に失敗しました。");
                    alert("Spotify プレイヤーの接続に失敗しました。");
                }
            });

            document.getElementById('play-pause').addEventListener('click', () => {
                controlSpotify('togglePlay', null, null, player);
                document.getElementById('propertyPanel').classList.add('active');
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



            document.getElementById('progress-bar').addEventListener('input', (e) => {
                const volume = e.target.value / 100;
                player.setVolume(volume).then(() => {
                    console.log("音量が設定されました:", volume);
                }).catch(err => console.error("音量設定エラー:", err));
            });
        };

        async function controlSpotify(action, trackId = null, deviceId = null, player = null) {
        	console.log("送信アクション: " + action);
        	
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
            if (trackId) params.append("trackId", trackId);
            if (deviceId) params.append("deviceId", deviceId);

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

        function playTrack(trackId, trackName) {
            console.log("送信するトラック ID: ", trackId);
            controlSpotify("play", trackId);
            const propertyPanel = document.getElementById('propertyPanel');
            const trackDetail = document.getElementById('track-detail');
            trackDetail.textContent = `トラック名: ${trackName}`;
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


        function logout() {
            window.location.href = '/SpotMusic/logout';

        }
    </script>


    


</body>
</html>