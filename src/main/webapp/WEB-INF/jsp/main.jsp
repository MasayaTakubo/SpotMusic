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
        // セッションスコープからプレイリストBeansを取得
        List<SpotifyPlayListBean> playlistBeans = (List<SpotifyPlayListBean>) session.getAttribute("playlistBeans");
    %>

    <!-- プレイリスト情報を表示 -->
    <ul>
        <c:forEach var="playlist" items="${playlistBeans}">
            <li>
                <strong>プレイリスト名:</strong> ${playlist.playlistName}<br>
                <strong>プレイリストID:</strong> ${playlist.playlistId}<br>
                <strong>トラック一覧:</strong>
                <ul>
                    <c:forEach var="track" items="${playlist.trackList}">
                        <li>
                            <strong>トラック名:</strong> ${track.trackName} <br>
                            <strong>アーティスト名:</strong> ${track.artistName}<br>
                            <strong>トラックID:</strong> ${track.trackId}<br>
                            
                            <!-- トラック再生ボタン -->
                            <button onclick="playTrack('${track.trackId}')">再生</button>
                        </li>
                    </c:forEach>
                </ul>
            </li>
        </c:forEach>
    </ul>
    
    <!-- プレイヤー -->
        <div id="player">
        <h2>再生プレイヤー</h2>
        <p id="now-playing">現在再生中: <span id="current-track">なし</span></p>
        <div id="controls">
            <button id="prev">前の曲</button>
            <button id="play-pause">再生/停止</button>
            <button id="next">次の曲</button>
        </div>
        <div>
 <!--            <label for="volume-slider">音量調整:</label> -->
            <input type="range" id="progress-bar" value="50" min="0" max="100">

        </div>
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
	    <h1>Spotify API情報取得結果</h1>
	
	    <c:if test="${not empty error}">
	        <p style="color: red;">エラー: ${error}</p>
	    </c:if>
	
	    <c:if test="${empty error}">
	        <p>Spotify APIの情報取得に成功しました。</p>
	    </c:if>
	
	    <br>
	    <a href="/auth">プレイリストを再取得</a> |
	 </div>

    <!-- ログアウトボタン -->
    <button onclick="logout()">ログアウト</button>

    <script>
    window.onSpotifyWebPlaybackSDKReady = () => {
    const token = '<%= session.getAttribute("access_token") %>';

    if (!token || token === "null") {
        console.error("アクセストークンが無効です。再ログインしてください。");
        alert("アクセストークンが無効です。再ログインしてください。");
        return;
    }

    // プレイヤーの初期化
    const player = new Spotify.Player({
        name: 'Web Playback SDK Player',
        getOAuthToken: cb => { cb(token); },
        volume: 0.5
    });

    // プレイヤーのイベントリスナーを追加
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

    // 再生コントロールイベント
    document.getElementById('play-pause').addEventListener('click', () => {
        controlSpotify('togglePlay', null, null, player);
    });

    // 前の曲イベント
    document.getElementById('prev').addEventListener('click', () => {
        controlSpotify('previousTrack', null, null, player);
    });

    // 次の曲イベント
    document.getElementById('next').addEventListener('click', () => {
        controlSpotify('nextTrack', null, null, player);
    });

    // 音量スライダーイベント
    document.getElementById('progress-bar').addEventListener('input', (e) => {
        const volume = e.target.value / 100; // スライダーの値を0-1に変換
        console.log("設定する音量:", volume); // デバッグ用
        player.setVolume(volume).then(() => {
            console.log("音量が設定されました:", volume);
        }).catch(err => console.error("音量設定エラー:", err));
    });
};

async function controlSpotify(action, trackId = null, deviceId = null, player = null, volume = null) {
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

    // 既存のサーバーAPIを呼び出す処理
    const params = new URLSearchParams();
    params.append("action", action);
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

function playTrack(trackId) {
    console.log("送信するトラック ID: ", trackId);
    controlSpotify("play", trackId);
}

function setupDevice(deviceId) {
    controlSpotify("setup", null, deviceId);
}

function pausePlayback() {
    controlSpotify("pause");
}

function logout() {
    window.location.href = '/SpotMusic/logout';
}
        function logout() {
            // サーバー側のログアウト処理を呼び出し、Spotifyのログアウト画面をポップアップで表示
            window.location.href = '/SpotMusic/logout';
        }
    </script>


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