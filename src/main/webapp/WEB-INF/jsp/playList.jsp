<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ page import="bean.TrackBean" %>
<%@ page import="java.util.List" %>
<%@ page import="bean.CommentBean" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
   	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" type="text/css" href="<c:url value='/css/delete.css' />">
    <title>プレイリスト詳細</title>
    <style>
	    #sendButton {
		    background-color: #1DB954; /* Spotify風の緑 */
		    color: white; /* 文字色 */
		    font-size: 16px; /* 文字サイズ */
		    font-weight: bold; /* 文字を太く */
		    padding: 10px 20px; /* 内側の余白 */
		    border: none; /* 枠線なし */
		    border-radius: 8px; /* 角丸 */
		    cursor: pointer; /* マウスオーバー時のカーソル */
		    transition: background-color 0.3s, transform 0.1s; /* アニメーション */
		}
		
		/* ホバー時のスタイル */
		#sendButton:hover {
		    background-color: #17a444; /* 少し濃い緑 */
		}
		
		/* クリック時のスタイル */
		#sendButton:active {
		    transform: scale(0.95); /* 押した時に少し縮む */
}
    </style>
</head>
<body>
    <h2>プレイリストのトラック一覧</h2>

    <%
	  	//セッションからuserIdを取得
		String userId = (String) session.getAttribute("userId");
        // セッションスコープからトラック情報を取得
        List<TrackBean> trackList = (List<TrackBean>) session.getAttribute("trackList");
    %>

<c:if test="${not empty trackList}">
    <ul class="track-list">
	<c:forEach var="track" items="${trackList}" varStatus="status">
	    <li>
	        <strong>トラック名:</strong> ${fn:escapeXml(track.trackName)}<br> 
	        <strong>アーティスト名:</strong> ${fn:escapeXml(track.artistName)}<br>
	
	        <!-- 画像がある場合のみ表示 -->
	        <c:if test="${not empty track.trackImageUrl}">
	            <img src="${track.trackImageUrl}" alt="${fn:escapeXml(track.trackName)}" width="100" />
	        </c:if>
	
	           <button onclick="console.log('クリック: trackIndex=', ${status.index}); playTrack('${track.trackId}', '${track.trackName}', '${param.playlistId}', ${status.index})">再生</button>
	        
	        
	        
	
	        <!-- メニュー用のボタン -->
	        <div class="track-menu">
	            <button class="menu-btn" onclick="toggleMenu(this)">&#x22EE;</button>
	            <div class="menu-content">
	                <button onclick="removeTrack('${param.playlistId}', '${track.trackId}', this)">削除</button>
	            </div>
	        </div>
	    </li>
	</c:forEach>


    </ul>
</c:if>


						

    <c:if test="${empty trackList}">
        <p>トラック情報が見つかりません。</p>
    </c:if>
<h3>コメントを入力</h3>
<form action="FrontServlet" method="POST" id="commentForm">
    <textarea name="comment" id="commentInput" placeholder="コメントを入力してください..." required></textarea>
    <input type="hidden" name="playlistId" id="playlistId" value="${param.playlistId}">
    <input type="hidden" name="userId" id="userId" value="${sessionScope.userId}">
    <input type="hidden" name="command" value="AddComment">
    <button id="sendButton" type="submit">送信</button>
</form>

<hr>

<h2>コメント一覧</h2>
<c:if test="${not empty comments}">
 <ul id="commentList">
    <c:forEach var="comment" items="${comments}">
        <li>
            <strong>${fn:escapeXml(comment.userId)}</strong>: ${fn:escapeXml(comment.sendComment)}<br>
            <small>${comment.sendTime}</small>
        </li>
    </c:forEach>
</ul>
</c:if>
    
<c:if test="${empty comments}">
    <p>まだコメントがありません。</p>
</c:if>


    
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
        
</script>
<script>
//main.jspでの処理を呼び出される側でも記述(JSが動かない)
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
</body>
</html>
