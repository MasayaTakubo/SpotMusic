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
    <%
        // セッションから"userId"を取得
        String userId = (String) session.getAttribute("userId");
    %>
    <h1>Chat Room</h1>
    <h1>${sessionScope.userId }</h1>
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
        <form action="FrontServlet" method="POST"  onsubmit="return reloadMessage(event);">
            <textarea name="message" id="message" placeholder="Type your message here..." required></textarea>
            <input type="hidden" name="relationId" value="1"> <!-- ダミーデータ -->
            <input type="hidden" name="userId" value="${sessionScope.userId }"> <!-- ダミーデータ -->
            <input type="hidden" name="command" value="AddMessage">
            <button type="submit" id="send">Send</button>
        </form>
    </div>

    <script>
        const chatBox = document.getElementById('chat-box');
        const messageInput = document.getElementById('message');
        const sendButton = document.getElementById('send');
        
        // チャットボックスを常にスクロールダウン
        chatBox.scrollTop = chatBox.scrollHeight;

        // 編集メッセージ（非同期）
        function editMessage(event, messageId) {
            event.preventDefault();
            const form = event.target;
            const message = form.message.value;

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
                const messageDiv = document.getElementById(`message-${messageId}`);
                messageDiv.querySelector('.content').innerText = message;
            })
            .catch(error => console.error('Error:', error));
        }

        // 削除メッセージ（非同期）
        function deleteMessage(event, messageId) {
            event.preventDefault();

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
                const messageDiv = document.getElementById(`message-${messageId}`);
                messageDiv.remove();
            })
            .catch(error => console.error('Error:', error));
        }

        // BroadcastChannelの初期化
        const channel = new BroadcastChannel('chat_channel');

        document.querySelector('form').addEventListener('submit', (event) => {
            event.preventDefault();
            const message = messageInput.value;
            if (message) {
                const data = {
                    user: '${sessionScope.userId}', // ユーザー名を動的に挿入
                    text: message,
                    time: new Date().toLocaleTimeString()
                };
                channel.postMessage(data); // メッセージを送信
                addMessageToBox(data); // 自分の画面にも表示
                messageInput.value = ''; // 入力欄をクリア
            }
        });

        //送信処理
        sendButton.addEventListener('click', (event) => {
	    event.preventDefault();
	    const message = messageInput.value;
	    if (message) {
	        fetch('FrontServlet', {
	            method: 'POST',
	            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
	            body: new URLSearchParams({
	                command: 'AddMessage',
	                message: message,
	                userId: '${sessionScope.userId}'
	            })
	        })
	        .then(response => response.json())
	        .then(data => {
	            channel.postMessage(data); // 他のブラウザにメッセージを送信
	            addMessageToBox(data); // 自分の画面にも表示
	            messageInput.value = ''; // 入力欄をクリア
	        })
	        .catch(error => console.error('Error:', error));
	    }
	});

                


        // メッセージ受信処理
        channel.onmessage = (event) => {
            addMessageToBox(event.data);
        };

        // チャットボックスにメッセージを追加
        function addMessageToBox(message) {
            const newMessage = document.createElement('div');
            newMessage.classList.add('chat-message');
            newMessage.innerHTML = `
                <div>
                    <span class="user"><strong>${message.user}</strong></span>
                    <span class="time">[${message.time}]</span>
                </div>
                <div class="content">${message.text}</div>
            `;
            chatBox.appendChild(newMessage);
            chatBox.scrollTop = chatBox.scrollHeight; // スクロールを下に
        }
    </script>
</body>
</html>
