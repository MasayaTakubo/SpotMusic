<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.util.List"%>
<!DOCTYPE html>
<html lang="ja">
<!-- jQueryをCDNから読み込む -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>アーティスト詳細情報</title>

<style>
    .load-album-btn {
        background-color: #4CAF50; /* 背景色（緑色） */
        color: white; /* 文字色（白色） */
        border: none; /* 枠線なし */
        padding: 10px 20px; /* 内側の余白 */
        text-align: center; /* 文字を中央揃え */
        text-decoration: none; /* 下線なし */
        display: inline-block; /* インラインブロック */
        font-size: 16px; /* フォントサイズ */
        margin: 4px 2px; /* マージン（余白） */
        cursor: pointer; /* ポインタ（マウスカーソル） */
        border-radius: 8px; /* 角丸 */
        transition: background-color 0.3s ease; /* 背景色が変わるアニメーション */
    }

    /* ホバー時に背景色を変化させる */
    .load-album-btn:hover {
        background-color: #45a049; /* 背景色を少し濃い緑に */
    }

    /* フォーカス時にボタンが光る */
    .load-album-btn:focus {
        outline: none; /* フォーカス時のアウトラインを消す */
        box-shadow: 0 0 8px rgba(0, 128, 0, 0.5); /* 緑色の光を追加 */
    }

    /* アクティブ時（クリック時）の効果 */
    .load-album-btn:active {
        background-color: #3e8e41; /* クリック時に背景色をさらに濃く */
    }
</style>

</head>
<body>
	<div class="content">
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
        <!-- リンクに変更 -->
        <a href="javascript:void(0);" class="load-album-link" data-playlist-id="${playlist.playlistId}">
            ${playlist.playlistName}
        </a>

        <!-- プレイリストのアルバム画像を表示 -->
        <c:if test="${not empty playlist.albumImageUrl}">
            <br>
            <img src="${playlist.albumImageUrl}" alt="アルバム画像" style="width:100px;height:auto;">
        </c:if>
    </c:forEach>
</ul>
</div>

<!-- スクリプトを <body> タグの最後に置く -->
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
</body>

</html>
