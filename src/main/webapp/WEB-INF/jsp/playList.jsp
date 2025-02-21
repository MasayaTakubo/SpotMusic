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
/* 送信ボタンを黒白デザインに変更 */
	#sendButton {
	    width: 100%;
	    background-color: #222 !important; /* ダークグレー */
	    color: #fff !important; /* 白文字 */
	    font-size: 16px !important;
	    font-weight: bold !important;
	    padding: 12px 20px !important;
	    border: none !important;
	    border-radius: 8px !important;
	    cursor: pointer !important;
	    transition: background-color 0.3s, transform 0.1s !important;
	    margin-top: 10px !important;
	}
	
	/* ホバー時は少し明るいグレー */
	#sendButton:hover {
	    background-color: #444 !important;
	}
	
	/* クリック時に縮小 */
	#sendButton:active {
	    transform: scale(0.95) !important;
	}


/* コメント*/
/* コメントセクション全体 */
.comment-section {
    display: flex;
    justify-content: space-between;
    align-items: stretch; /* 高さを均等に揃える */
    width: 70%;
    margin: 40px auto;
    gap: 20px;
}

/* コメント入力フォームとコメント一覧を同じ大きさに */
.comment-input-container,
.comment-list-container {
    flex: 1;
    background: #222;
    padding: 20px;
    border-radius: 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
    min-height: 400px; /* 高さを統一 */
    max-height: 400px; /* 必要に応じて調整 */
}

.comment-input-container {
    width: 100%; /* 横幅を最大に */
    max-width: 100%; /* 最大幅制限を解除 */
    display: flex;
    flex-direction: column;
    align-items: stretch; /* 中身をフル幅に */
}

/* コメント入力エリアの高さを調整 */
#commentInput {
    width: 100%;
    height: 250px; /* 高さをさらに広げる */
    padding: 10px; /* 余白を少し減らす */
    border-radius: 8px;
    border: 1px solid #ccc;
    resize: none;
    font-size: 16px; /* 文字サイズを大きく */
    flex-grow: 1; /* 上下いっぱいに広がる */
    box-sizing: border-box;
}

/* 送信ボタンの配置 */
#sendButton {
    width: 100%;
    background-color: #1DB954;
    color: white;
    font-size: 18px; /* ボタンの文字を少し大きく */
    font-weight: bold;
    padding: 12px 20px; /* ボタンのサイズを調整 */
    border: none;
    border-radius: 8px;
    cursor: pointer;
    transition: background-color 0.3s, transform 0.1s;
    margin-top: 15px; /* 入力欄との間の余白を調整 */
}

#sendButton:hover {
    background-color: #17a444;
}

#sendButton:active {
    transform: scale(0.95);
}

/* コメントリストを統一サイズにしてスクロールバーを1つに */
.comment-list-container {
    overflow: hidden; /* 二重スクロール防止 */
}

#commentList {
    list-style: none;
    padding: 0;
    margin: 0;
    overflow-y: auto;
    flex-grow: 1;
    width: 100%;
    max-height: 330px; /* スクロールの最大高さ */
}

/* 各コメントのスタイル */
#commentList li {
    padding: 10px;
    border-bottom: 1px solid #444;
    color: #fff;
    font-size: 14px;
}

/* 最後のコメントの下線を削除 */
#commentList li:last-child {
    border-bottom: none;
}

/* ユーザー名を強調 */
#commentList li strong {
    color: #fff; /* 白色で統一 */
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



    </style>
</head>
<body>
    <%
	  	//セッションからuserIdを取得
		String userId = (String) session.getAttribute("userId");
    	//セッションからuser_nameを取得
    	//String userName = (String) session.getAttribute("user_name");
        // セッションスコープからトラック情報を取得
        List<TrackBean> trackList = (List<TrackBean>) session.getAttribute("trackList");
    %>

<c:if test="${not empty trackList}">
<ul class="track-list">
	    <h4>プレイリストのトラック一覧</h4>
    <c:forEach var="track" items="${trackList}" varStatus="status">
        <li>
            <!-- トラック画像 -->
            <c:if test="${not empty track.trackImageUrl}">
                <img src="${track.trackImageUrl}" alt="${fn:escapeXml(track.trackName)}">
            </c:if>

            <!-- トラック情報 -->
            <div class="track-info">
                <strong>${fn:escapeXml(track.trackName)}</strong>
                <span>${fn:escapeXml(track.artistName)}</span>
            </div>
                <button onclick="console.log('クリック: trackIndex=', ${status.index}); playTrack('${track.trackId}', '${track.trackName}', '${param.playlistId}', ${status.index})">再生</button>
        
                <button class="delete-btn" onclick="removeTrack('${param.playlistId}', '${track.trackId}', this)">
                    🗑️
                </button>
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
                <c:forEach var="comment" items="${comments}">
                    <li>
                        <strong>${fn:escapeXml(comment.userName)}</strong>: ${fn:escapeXml(comment.sendComment)}<br>
                        <small>${comment.sendTime}</small>
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
                    <strong>${comment.userName}</strong>: ${comment.sendComment}<br>
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
