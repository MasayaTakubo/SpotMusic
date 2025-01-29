<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page import="java.util.List"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>アーティスト詳細情報</title>

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

</head>
<body>
    <h1>アーティスト詳細情報</h1>

    <!-- アーティスト情報を表示 -->
    <p><strong>名前:</strong> ${artistBean.artistName}</p>
    <p><strong>ジャンル:</strong> ${artistBean.artistGenres}</p>
    <p><strong>フォロワー数:</strong> ${artistBean.followers}</p>

    <!-- アーティスト画像の表示 -->
    <c:if test="${not empty artistBean.artistImageUrl}">
        <p><strong>アーティスト画像:</strong></p>
        <img src="${artistBean.artistImageUrl}" alt="アーティスト画像" style="width:200px;height:auto;">
    </c:if>

    <h2>プレイリスト</h2>
    <ul>
        <c:forEach var="playlist" items="${artistBean.playlists}">
            <li>
                <!-- プレイリスト名を表示 -->
                <button onclick="loadAlbumPage('${playlist.playlistId}')">${playlist.playlistName}</button>

                <!-- プレイリストのアルバム画像を表示 -->
                <c:if test="${not empty playlist.albumImageUrl}">
                    <br>
                    <img src="${playlist.albumImageUrl}" alt="アルバム画像" style="width:100px;height:auto;">
                </c:if>
            </li>
        </c:forEach>
    </ul>

    <!-- アルバム情報の表示エリア -->
    <div class="content">
        <p>アルバム情報がここに表示されます。</p>
    </div>
    
    <a href="javascript:history.back()">前のページに戻る</a>
    
    
</body>
</html>
