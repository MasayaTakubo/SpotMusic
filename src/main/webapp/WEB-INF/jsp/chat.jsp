<%@ page language="java" contentType="text/html; charset=Windows-31J" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chat</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            padding: 20px;
        }
        .chat-box {
            border: 1px solid #ccc;
            padding: 10px;
            height: 300px;
            overflow-y: scroll;
        }
        .chat-message {
            margin-bottom: 10px;
        }
        .chat-message .user {
            font-weight: bold;
        }
        .chat-message .time {
            font-size: 0.8em;
            color: #888;
        }
        .message-input {
            margin-top: 10px;
        }
        .message-input textarea {
            width: 100%;
            height: 50px;
        }
        .edit-box, .delete-box {
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <h1>Chat Room</h1>
    <div class="chat-box" id="chat-box">
        <!-- メッセージをループで表示 -->
        <c:forEach var="message" items="${requestScope.messages}">
            <div class="chat-message" id="message-${message.messageId}">
                <div>
                    <span class="user">${message.userId}:</span>
                    <span class="time">${message.sendTime}</span>
                </div>
                <div class="content">${message.sendMessage}</div>
                
                <!-- 編集ボックス -->
                <div class="edit-box">
                    <form action="FrontServlet" method="POST" onsubmit="return editMessage(event, ${message.messageId});">
                        <input type="hidden" name="command" value="UpdateMessage">
                        <input type="hidden" name="messageId" value="${message.messageId}">
                        <input type="hidden" name="relationId" value="1"> <!-- ダミーデータ -->
                        <textarea name="message" placeholder="Edit your message" required>${message.sendMessage}</textarea>
                        <button type="submit">Update</button>
                    </form>
                </div>

                <!-- 削除ボックス -->
                <div class="delete-box">
                    <form action="FrontServlet" method="POST" onsubmit="return deleteMessage(event, ${message.messageId});">
                        <input type="hidden" name="command" value="RemoveMessage">
                        <input type="hidden" name="messageId" value="${message.messageId}">
                        <input type="hidden" name="relationId" value="1"> <!-- ダミーデータ -->
                        <button type="submit">Delete</button>
                    </form>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- メッセージ送信フォーム -->
    <div class="message-input">
        <form action="FrontServlet" method="POST">
            <textarea name="message" placeholder="Type your message here..." required></textarea>
            <input type="hidden" name="relationId" value="1"> <!-- ダミーデータ -->
            <input type="hidden" name="userId" value="user1"> <!-- ダミーデータ -->
            <input type="hidden" name="command" value="AddMessage">
            <button type="submit">Send</button>
        </form>
    </div>

    <script>
        // チャットボックスを常にスクロールダウン
        const chatBox = document.getElementById('chat-box');
        chatBox.scrollTop = chatBox.scrollHeight;

        // 編集メッセージ（非同期）
        function editMessage(event, messageId) {
            event.preventDefault(); // フォームの送信を防ぐ

            const form = event.target;
            const message = form.message.value;

            // Ajaxを使って編集を非同期に行う
            fetch('FrontServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    command: 'UpdateMessage',
                    messageId: messageId,
                    message: message,
                    relationId: 1
                })
            })
            .then(response => response.json())
            .then(data => {
                // メッセージの内容を更新
                const messageDiv = document.getElementById(`message-${messageId}`);
                messageDiv.querySelector('.content').innerText = message;
            })
            .catch(error => console.error('Error:', error));
        }

        // 削除メッセージ（非同期）
        function deleteMessage(event, messageId) {
            event.preventDefault(); // フォームの送信を防ぐ

            // Ajaxを使って削除を非同期に行う
            fetch('FrontServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    command: 'RemoveMessage',
                    messageId: messageId,
                    relationId: 1
                })
            })
            .then(response => response.json())
            .then(data => {
                // メッセージを画面から削除
                const messageDiv = document.getElementById(`message-${messageId}`);
                messageDiv.remove();
            })
            .catch(error => console.error('Error:', error));
        }
    </script>
</body>
</html>
