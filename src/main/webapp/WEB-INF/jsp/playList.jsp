<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
</head>
<body>
    <h2>プレイリストのトラック一覧higa</h2>

    <%
    	//セッションからuserIdを取得
    	String userId = (String) session.getAttribute("userId");
        // セッションスコープからトラック情報を取得
        List<TrackBean> trackList = (List<TrackBean>) session.getAttribute("trackList");
        //リクエストからコメントを取得
	%>

    <c:if test="${not empty trackList}">
        <ul>
            <c:forEach var="track" items="${trackList}">
                <li>
                    <strong>トラック名:</strong> ${track.trackName}<br>
                    <strong>アーティスト名:</strong> ${track.artistName}
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

