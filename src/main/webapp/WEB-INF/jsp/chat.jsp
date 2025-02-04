<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>

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
        Map<String, String> userMap = (Map<String, String>) request.getAttribute("userMap");
    %>
    <h1>Chat Room</h1>
    <h1>ログインユーザー：${sessionScope.userId }</h1>
    <div id="chat-box" name="chat-box" style="border: 1px solid #ccc; padding: 10px; height: 300px; overflow-y: scroll; "></div>
	<!-- css修正する、後でやる -->
	<c:set var="isBlock" value="${param.isBlock}" />
	<!-- ブロック時の警告メッセージ -->
	<c:if test="${isBlock eq 'true'}">
	    <p style="color: red;">ブロック中のため、メッセージを送信できません。</p>
	</c:if>
	<div class="chatWindow">
	    <form action="FrontServlet" method="POST" id="chatForm" onsubmit="return false;">
	        <textarea name="message" id="messageInput" placeholder="Type your message here..." required></textarea>
	        <input type="hidden" name="relationId" id="relationId" value="${param.relationId}">
	        <input type="hidden" name="userId" id="userId" value="${sessionScope.userId}">
	        <input type="hidden" name="command" value="AddMessage">
	        <button id="sendButton" type="submit" ${isBlock eq 'true' ? 'disabled' : ''}>送信</button>
	    </form>
	</div>
    <script>
        // サーバーから受け取ったJSONメッセージをパースして表示
        //ChatCommandからのデータ
        const messages = <%= jsonResponse != null ? jsonResponse : "[]" %>;
        const userMap = <%= new org.json.JSONObject(userMap) %>;
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
	    }*/
	    function addMessageToBox(message) {
	        const messageContainer = document.createElement('div');
	        messageContainer.classList.add('chat-message');
	        const userSpan = document.createElement('span');
	        userSpan.classList.add('user');
	     	// ユーザーIDをユーザー名に置き換え
	        userSpan.textContent = userMap[message.userId] || message.userId;
	        const messageSpan = document.createElement('span');
	        messageSpan.classList.add('message');
	        messageSpan.innerHTML = message.sendMessage.replace(/\n/g, '<br>');
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
		//ロード時にisBlockがtrueならチャットの送信ボタンが押せないようにする
		document.addEventListener("DOMContentLoaded", function () {
	        var isBlock = "${isBlock}";
	        
	        var sendButton = document.getElementById("sendButton");
	        var messageInput = document.getElementById("messageInput");
	
	        if (isBlock === "true") {
	            sendButton.disabled = true;
	            messageInput.disabled = true;
	        }
	    });
    </script>
</body>
</html>