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
        <!-- 既存メッセージをループで表示 -->
        <c:forEach var="message" items="${requestScope.messages}">
            <div class="chat-message" id="message-${message.messageId}">
                <div>
                    <span class="user">${message.userId}:</span>
                    <span class="time">${message.sendTime}</span>
                </div>
                <div class="content">${message.sendMessage}</div>
                
                <!-- 編集ボックス -->
                <div class="edit-box">
                    <form onsubmit="return editMessage(event, ${message.messageId});">
                        <textarea>${message.sendMessage}</textarea>
                        <button type="submit">Update</button>
                    </form>
                </div>

                <!-- 削除ボックス -->
                <div class="delete-box">
                    <form onsubmit="return deleteMessage(event, ${message.messageId});">
                        <button type="submit">Delete</button>
                    </form>
                </div>
            </div>
        </c:forEach>
    </div>

    <%
        // セッションから"userId"を取得
        String userId = (String) session.getAttribute("userId");
    %>

    <!-- メッセージ送信フォーム -->
    <div class="message-input">
        <textarea id="message-input" placeholder="Type your message here..." required></textarea>
        <button id="send-button">Send</button>
    </div>

    <script>
        // WebSocketを設定
        const socket = new WebSocket("ws://localhost:8080/yourApp/chat");

        // チャットボックスを更新する関数
        function addMessage(message) {
            const chatBox = document.getElementById("chat-box");
            const messageDiv = document.createElement("div");
            messageDiv.classList.add("chat-message");
            messageDiv.setAttribute("id", `message-${message.messageId}`);
            messageDiv.innerHTML = `
                <div>
                    <span class="user">${message.userId}:</span>
                    <span class="time">${message.sendTime}</span>
                </div>
                <div class="content">${message.sendMessage}</div>
                <div class="edit-box">
                    <form onsubmit="return editMessage(event, ${message.messageId});">
                        <textarea>${message.sendMessage}</textarea>
                        <button type="submit">Update</button>
                    </form>
                </div>
                <div class="delete-box">
                    <form onsubmit="return deleteMessage(event, ${message.messageId});">
                        <button type="submit">Delete</button>
                    </form>
                </div>
            `;
            chatBox.appendChild(messageDiv);
            chatBox.scrollTop = chatBox.scrollHeight; // 自動スクロール
        }

        // サーバーからのメッセージ受信
        socket.onmessage = function(event) {
            const message = JSON.parse(event.data);
            addMessage(message);
        };

        // メッセージ送信
        document.getElementById("send-button").addEventListener("click", function() {
            const input = document.getElementById("message-input");
            const message = input.value.trim();
            if (message) {
                const data = JSON.stringify({
                    command: "AddMessage",
                    userId: "<%= userId %>",
                    sendMessage: message,
                    sendTime: new Date().toLocaleTimeString()
                });
                socket.send(data);
                input.value = ""; // 入力欄をクリア
            }
        });

        // メッセージ編集
        function editMessage(event, messageId) {
            event.preventDefault();
            const form = event.target;
            const newMessage = form.querySelector("textarea").value.trim();
            if (newMessage) {
                const data = JSON.stringify({
                    command: "UpdateMessage",
                    messageId: messageId,
                    sendMessage: newMessage
                });
                socket.send(data);
            }
        }

        // メッセージ削除
        function deleteMessage(event, messageId) {
            event.preventDefault();
            const data = JSON.stringify({
                command: "RemoveMessage",
                messageId: messageId
            });
            socket.send(data);
            document.getElementById(`message-${messageId}`).remove();
        }
    </script>
</body>
</html>
