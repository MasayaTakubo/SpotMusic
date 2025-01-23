<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
                    <!-- プレイリスト名をクリックした時に詳細を表示 -->
                    <button onclick="loadPlaylistPage('${playlist.playlistId}')">
                        ${playlist.playlistName}
                        ${playlist.playlistId}
                        
                    </button>
                </li>
            </c:forEach>
        </ul>
    </div>

    <!-- 中央: コンテンツ -->
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
                    <c:forEach var="artistId" items="${sessionScope.artistIds}" varStatus="status">
                        <li>
                            <a href="javascript:void(0);" onclick="loadArtistPage('${artistId}')">
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

        <!-- デフォルトのコンテンツ (最近再生したトラックやレコメンドなど) -->
        <h2>最近再生したトラック</h2>
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
                            <td>${entry.value}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
        <c:if test="${empty recomendDatas}">
            <p>No recommended tracks found.</p>
        </c:if>
    </div>

    <!-- 右側: 詳細情報パネル -->
    <div class="property-panel" id="propertyPanel">
        <h2>トラック詳細</h2>
        <p id="track-detail">再生中のトラック詳細が表示されます。</p>
		<div id="player-controls">
		    <h3>プレイヤー</h3>
		    <p>再生時間: <span id="current-time">0:00</span> / <span id="total-time">0:00</span></p>
		    <input type="range" id="seek-bar" value="0" min="0" max="100">            
		    <p id="now-playing">現在再生中: <span id="current-track">なし</span></p>
		    <button id="prev">前の曲</button>
		    <button id="play-pause">再生/停止</button>
		    <button id="next">次の曲</button>
		    <input type="range" id="progress-bar" value="50" min="0" max="100">
		    <button id="repeat-track">リピート</button>
		    <button id="shuffle-track">シャッフル</button>
		</div>

    </div>

<script>
    // プレイリストの詳細を受け取った場合
// プレイリストの詳細を表示する関数
function loadPlaylistPage(playlistId) {
    if (!playlistId) {
        console.error('playlistId が指定されていません');
        return;
    }

    // サーバーにリクエストを送信
    const url = "/SpotMusic/FrontServlet?command=PlayListDetails&playlistId=" + encodeURIComponent(playlistId);
    const contentDiv = document.querySelector('.content');

    // Fetch APIでリクエストを送信し、結果をページに埋め込む
    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text(); // レスポンスとしてHTMLを受け取る
        })
        .then(data => {
            contentDiv.innerHTML = data; // 取得したHTMLを表示
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>プレイリスト情報の取得に失敗しました。</p>';
        });
}




</script>

    
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

            let trackEnded = false; // フラグ変数を追加

            player.addListener('player_state_changed', state => {
                if (!state) return;

                const track = state.track_window.current_track;
                document.getElementById('now-playing').innerText = track ? track.name : "なし";

                // 曲が終了した場合の処理
                if (state.paused && state.position === 0 && !state.track_window.next_tracks.length) {
                    if (!trackEnded) {
                        trackEnded = true;  // 連続リクエストを防止
                        console.log("曲が終了しました。次の曲へ移動します。");
                        
                        fetch("/SpotMusic/spotifyControl", {
                            method: "POST",
                            headers: {
                                "Content-Type": "application/x-www-form-urlencoded"
                            },
                            body: "action=nextTrack"
                        }).then(response => response.text())
                          .then(data => {
                              console.log("次の曲へ移行: ", data);
                              trackEnded = false;  // 次の曲が始まったらフラグをリセット
                          })
                          .catch(error => {
                              console.error("エラー:", error);
                              trackEnded = false;  // エラー時もフラグをリセット
                          });
                    }
                } else {
                    trackEnded = false;  // 再生中に戻ったらフラグをリセット
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

            //Repeat
            document.getElementById('repeat-track').addEventListener('click', () => {
                fetch("/SpotMusic/spotifyControl", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: "action=repeatTrack&state=track"
                }).then(response => response.text())
                  .then(data => console.log("リピートの応答: ", data))
                  .catch(error => console.error("エラー:", error));
            });
            //Shuffle
            document.getElementById('shuffle-track').addEventListener('click', () => {
                fetch("/SpotMusic/spotifyControl", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: "action=shuffle&state=true"
                }).then(response => response.text())
                  .then(data => console.log("シャッフルの応答: ", data))
                  .catch(error => console.error("エラー:", error));
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
        })
        .catch(error => {
            console.error('Error loading artist page:', error);
            contentDiv.innerHTML = '<p>アーティスト情報の取得に失敗しました。</p>';
        });
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

    // 5秒ごとに更新
    setInterval(updateProgress, 1000);
     
</script>



</body>
</html>