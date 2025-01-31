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
        <c:forEach var="track" items="${trackList}">
            <li>
                <strong>トラック名:</strong> ${fn:escapeXml(track.trackName)}<br> 
                <strong>アーティスト名:</strong> ${fn:escapeXml(track.artistName)}<br>
                
                <!-- 画像URLが設定されている場合のみ表示 -->
                <c:if test="${not empty track.trackImageUrl and (fn:startsWith(track.trackImageUrl, 'http://') or fn:startsWith(track.trackImageUrl, 'https://'))}">
                    <img src="${track.trackImageUrl}" alt="${fn:escapeXml(track.trackName)}" width="100" />
                </c:if>
                
				<button onclick="playTrack('${track.trackId}', '${track.trackName}')">再生</button>

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
            <strong>${comment.userId}</strong>: ${comment.sendComment}<br>
            <small>${comment.sendTime}</small>
        </li>
    </c:forEach>
</ul>
</c:if>
    
<c:if test="${empty comments}">
    <p>まだコメントがありません。</p>
</c:if>


    <br>
    <a href="main.jsp">戻る</a>
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

</body>
</html>
