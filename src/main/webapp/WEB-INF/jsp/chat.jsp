<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
    </style>
</head>
<body>
    <%
        // セッションから"userId"を取得
        String userId = (String) session.getAttribute("userId");
        // リクエストからレスポンスに渡されたメッセージリスト（JSON形式）を取得
        String jsonResponse = (String) request.getAttribute("messages");
    %>
    <h1>Chat Room</h1>
    <h1>${sessionScope.userId }</h1>
    <div id="chat-box" class="chat-box"></div>
    <!-- メッセージ送信フォーム -->
    <div class="chatWindow">
        <form action="FrontServlet" method="POST" id="chatForm" onsubmit="return false;">
            <textarea name="message" id="messageInput" placeholder="Type your message here..." required></textarea>
            <input type="hidden" name="relationId" id="relationId" value="${param.relationId}">
            <input type="hidden" name="userId" id="userId" value="${sessionScope.userId }">
            <input type="hidden" name="command" value="AddMessage">
            <button id="sendButton" type="button">Send</button> <!-- IDとタイプ修正 -->
        </form>
    </div>

    <script>
        // サーバーから受け取ったJSONメッセージをパースして表示
        //ChatCommandからのデータ
        const messages = <%= jsonResponse != null ? jsonResponse : "[]" %>;
        // チャットウィンドウにメッセージを表示
	    const chatBox = document.getElementById('chat-box');
		messages.forEach(message => {
	        addMessageToBox(message);
	    });
        // BroadcastChannelの作成
        const channel = new BroadcastChannel('chat_channel');
        const messageInput = document.getElementById('messageInput');
        const sendButton = document.getElementById('sendButton');
        const userId = document.getElementById('userId').value; // セッションから渡されたuserIdを取得
        const relationId = document.getElementById('relationId').value;
        // メッセージ送信イベント
		sendButton.addEventListener('click', function () {
		    const message = messageInput.value;
		    if (message.trim()) {
		    	fetch('FrontServlet', {
		    	    method: 'POST',
		    	    headers: {
			    	    'Accept': 'application/json',
		    	        'Content-Type': 'application/x-www-form-urlencoded'
			    	},
		    	    body: new URLSearchParams({
		    	        command: 'AddMessage',
		    	        message: message,
		    	        userId: userId,
		    	        relationId: relationId
		    	    })
		    	})
		    	.then(response => {
		    	    if (!response.ok) {
		    	        throw new Error('Network response was not ok');
		    	    }
		    	    return response.json();
		    	})
		    	.then(data => {
			    	chatBox.innerHTML = '';
		    	    messageInput.value = '';
		    	    channel.postMessage(data);
		    	    data.forEach(message => addMessageToBox(message));
		    	})
		    	.catch(error => console.error('Error:', error));
		    }
		});
        // 他タブからのメッセージ受信イベント
		channel.onmessage = function (event) {
		    if (typeof event.data === 'object') {
			    chatBox.innerHTML='';
		    	event.data.forEach(message => addMessageToBox(message));
		    } else {
		        console.error('Received data is not an object:', event.data);
		    }
		};
        // 画面にメッセージを追加
        /*
		function addMessageToBox(message) {
	        const messageElement = document.createElement('div');
	        messageElement.classList.add('chat-message');
	        messageElement.innerHTML = `
	            <span class="user">${message.userId}</span> <br>
	            <span class="message">${message.sendMessage}</span><br>
	            <span class="time">${message.sendTime}</span><br>
	        `;
	        chatBox.appendChild(messageElement);
	        chatBox.scrollTop = chatBox.scrollHeight;
	        console.log('UserId:', message.userId);
	        console.log('Message:', message.sendMessage);
	        console.log('Time:', message.sendTime);
	    }*/
	    function addMessageToBox(message) {
	        const messageContainer = document.createElement('div');
	        messageContainer.classList.add('chat-message');
	        const userSpan = document.createElement('span');
	        userSpan.classList.add('user');
	        userSpan.textContent = message.userId;
	        const messageSpan = document.createElement('span');
	        messageSpan.classList.add('message');
	        messageSpan.textContent = message.sendMessage;
	        const timeSpan = document.createElement('span');
	        timeSpan.classList.add('time');
	        timeSpan.textContent = message.sendTime;
	        messageContainer.appendChild(userSpan);
	        messageContainer.appendChild(document.createElement('br'));
	        messageContainer.appendChild(messageSpan);
	        messageContainer.appendChild(document.createElement('br'));
	        messageContainer.appendChild(timeSpan);
	        messageContainer.appendChild(document.createElement('br'));
	        chatBox.appendChild(messageContainer);
	        chatBox.scrollTop = chatBox.scrollHeight;
		}
    </script>
</body>
</html>