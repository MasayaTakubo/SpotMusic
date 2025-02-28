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
/* 送信ボタン */
	#sendButton {
	    width: 100%;
	    background-color: #222 !important;
	    color: #fff !important;
	    font-size: 16px !important;
	    font-weight: bold !important;
	    padding: 12px 20px !important;
	    border: none !important;
	    border-radius: 8px !important;
	    cursor: pointer !important;
	    transition: background-color 0.3s, transform 0.1s !important;
	    margin-top: 10px !important;
	}
	
	#sendButton:hover {
	    background-color: #444 !important;
	}
	
	#sendButton:active {
	    transform: scale(0.95) !important;
	}

/* コメントセクション全体 */
.comment-section {
    display: flex;
    justify-content: space-between;
    align-items: stretch;
    width: 70%;
    margin: 40px auto;
    gap: 20px;
}

/* コメント入力フォームとコメント一覧 */
.comment-input-container,
.comment-list-container {
    flex: 1;
    background: #222;
    padding: 20px;
    border-radius: 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
    min-height: 400px;
    max-height: 400px;
}

.comment-input-container {
    width: 100%;
    max-width: 100%;
    display: flex;
    flex-direction: column;
    align-items: stretch;
}

/* コメント入力エリア */
#commentInput {
    width: 100%;
    height: 250px;
    padding: 10px;
    border-radius: 8px;
    border: 1px solid #ccc;
    resize: none;
    font-size: 16px;
    flex-grow: 1;
    box-sizing: border-box;
}

/* 送信ボタン */
#sendButton {
    width: 100%;
    background-color: #1DB954;
    color: white;
    font-size: 18px;
    font-weight: bold;
    padding: 12px 20px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    transition: background-color 0.3s, transform 0.1s;
    margin-top: 15px;
}

#sendButton:hover {
    background-color: #17a444;
}

#sendButton:active {
    transform: scale(0.95);
}

/* コメント一覧 */
.comment-list-container {
    overflow: hidden;
    width: 100%;
}

#commentList {
    list-style: none; 
    padding-left: 0; 
    margin: 0; 
    /* スクロールエリアの高さが必要なら指定 */
    max-height: 330px; 
    overflow-y: auto;
}

/* LI の左パディングをなくし、左揃えに */
#commentList li {
    padding: 0; 
    margin-bottom: 10px; /* コメント同士の余白 */
    text-align: left;
    color: #fff;
    border-bottom: 1px solid #444;
}

#commentList li:last-child {
    border-bottom: none;
}

/* ユーザー名 */
#commentList li strong {
    color: #fff;
    font-size: 16px;
}

/* スクロールバーのデザイン (Chrome, Edge) */
#commentList::-webkit-scrollbar {
    width: 8px;
}

#commentList::-webkit-scrollbar-track {
    background: #222;
    border-radius: 10px;
}

#commentList::-webkit-scrollbar-thumb {
    background: #888;
    border-radius: 10px;
}

#commentList::-webkit-scrollbar-thumb:hover {
    background: #bbb;
}

#commentList li .comment-text {
        max-width: 20ch;         
        white-space: pre-wrap;
}

    </style>
</head>
<body>
    <%
        // セッションからuserIdを取得
        String userId = (String) session.getAttribute("userId");
        // セッションスコープからトラック情報を取得
        List<TrackBean> trackList = (List<TrackBean>) session.getAttribute("trackList");
    %>

<c:if test="${not empty trackList}">
    <ul class="track-list">
	    <h4>プレイリストのトラック一覧</h4>
        <c:forEach var="track" items="${trackList}" varStatus="status">
            <li>
                <c:if test="${not empty track.trackImageUrl}">
                    <img src="${track.trackImageUrl}" alt="${fn:escapeXml(track.trackName)}">
                </c:if>
                <div class="track-info">
                    <strong>${fn:escapeXml(track.trackName)}</strong>
                    <span>${fn:escapeXml(track.artistName)}</span>
                </div>
                <button onclick="console.log('クリック: trackIndex=', ${status.index}); playTrack('${track.trackId}', '${track.trackName}', '${param.playlistId}', ${status.index})">再生</button>
                <button class="delete-btn" onclick="removeTrack('${param.playlistId}', '${track.trackId}', this)">🗑️</button>
            </li>
        </c:forEach>
    </ul>
</c:if>

<c:if test="${empty trackList}">
    <p>トラック情報が見つかりません。</p>
</c:if>

<div class="comment-section">
    <!-- 左側：コメント入力フォーム -->
    <div class="comment-input-container">
        <h5>コメントを入力</h5>
        <form action="FrontServlet" method="POST" id="commentForm">
            <textarea name="comment" id="commentInput" placeholder="コメントを入力してください..." required></textarea>
            <input type="hidden" name="playlistId" id="playlistId" value="${param.playlistId}">
            <input type="hidden" name="userId" id="userId" value="${sessionScope.userId}">
            <input type="hidden" name="userName" id="userName" value="${sessionScope.user_name}">
            <input type="hidden" name="command" value="AddComment">
            <button id="sendButton" type="submit">送信</button>
        </form>
    </div>
    
    <!-- 右側：コメント一覧 -->
	<div class="comment-list-container">
	    <h6>コメント一覧</h6>
	    <c:if test="${not empty comments}">
	        <ul id="commentList">
	            <c:forEach var="cmt" items="${comments}">
	                <li class="commentText">
	                    <strong>${fn:escapeXml(cmt.userName)}</strong>&nbsp;
	                    <small>${fn:escapeXml(cmt.sendTime)}</small><br>
	                    <span style="white-space: pre-wrap;">${fn:escapeXml(cmt.sendComment)}</span>
	                </li>
	            </c:forEach>
	        </ul>
	    </c:if>
	    <c:if test="${empty comments}">
	        <p>まだコメントがありません。</p>
	    </c:if>
	</div>
</div>
<script>
$(document).ready(function(){
    $("#commentForm").submit(function(event){

    	// コメント入力がスペースまたは改行のみかどうかをチェック
        
        if ($("#commentInput").val().trim() === "" || commentInput.match(/^(\n|\s)*$/)) {
            // 空または改行のみのコメントの場合、送信を防ぐ
            alert("コメントを入力してください。");
            return false;  // フォームの送信をキャンセル
        }
        
        event.preventDefault();

        $.ajax({
            type: "POST",
            url: "FrontServlet",
            data: $(this).serialize(),
            dataType: "json",
            success: function(response) {
                console.log("レスポンス:", response);
                $("#commentInput").val("");
                updateComments(response);
            },
            error: function(xhr, status, error) {
                console.error("エラー:", xhr.responseText);
                alert("コメントの送信に失敗しました。");
            }
        });
    });

    function updateComments(comments) {
        let commentList = $("#commentList");
        commentList.empty();

        if (comments.length === 0) {
            commentList.append("<p>まだコメントがありません。</p>");
            return;
        }

        comments.forEach(comment => {
            commentList.append(
                <li>
                    <strong>${comment.userName}</strong>&nbsp;<small>${comment.sendTime}</small><br>
                    <span style="white-space: pre-wrap;">${comment.sendComment}</span>
                </li>
            );
        });
    }
});
</script>
<script>
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