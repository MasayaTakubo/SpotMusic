<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Date" %>
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
		    display: flex;
		    flex-direction: column;
		    background-color: #f8f9fa; /* チャット全体の背景 */
		}
		
		/* メッセージの1行全体を左右に寄せる */
		.chat-message {
		    display: flex;
		    width: 100%;
		    margin: 5px 0;
		}
		
		/* 他のユーザーのメッセージ（左寄せ） */
		.chat-message.left {
		    justify-content: flex-start;
		}
		
		/* 自分のメッセージ（右寄せ） */
		.chat-message.right {
		    justify-content: flex-end;
		}
		
		/* メッセージの内容部分 */
		.chat-message .message {
		    max-width: 70%;
		    padding: 10px;
		    border-radius: 10px;
		    word-break: break-word;
		    font-size: 14px;
		}
		
		/* 他のユーザーのメッセージ */
		.chat-message.left .message {
		    background-color: #e0e0e0; /* ライトグレー */
		    color: #333;
		}
		
		/* 自分のメッセージ */
		.chat-message.right .message {
		    background-color: #a0e7ff; /* ライトブルー */
		    color: #004466;
		}
		
		/* ユーザー名 */
		.chat-message .user {
		    font-weight: bold;
		    color: #007bff; /* 青 */
		}
		
		/* 送信時間 */
		.chat-message .time {
		    font-size: 0.8em;
		    color: #888; /* グレー */
		    margin-left: 5px;
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
    <h1>ログインユーザー：${sessionScope.user_name }</h1>
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
        chatBox.scrollTop = chatBox.scrollHeight;
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
		function escapeHTML(str) {
		    return str.replace(/&/g, "&amp;")
		              .replace(/</g, "&lt;")
		              .replace(/>/g, "&gt;")
		              .replace(/"/g, "&quot;")
		              .replace(/'/g, "&#039;");
		}

		function addMessageToBox(message) {
		    const blockTime = new Date("${param.blockTime}");
		    const messageTime = new Date(message.sendTime);
		    
		    if (messageTime > blockTime) {
		        return;
		    }

		    const messageContainer = document.createElement('div');
		    messageContainer.classList.add('chat-message');

		    // ログインユーザーの ID を取得（JSP から埋め込む）
		    const loggedInUserId = "${sessionScope.userId}";

		    // ログインユーザーのメッセージなら右寄せ、それ以外は左寄せ
		    if (message.userId === loggedInUserId) {
		        messageContainer.classList.add('right');
		    } else {
		        messageContainer.classList.add('left');
		    }

		    const userSpan = document.createElement('span');
		    userSpan.classList.add('user');
		    userSpan.textContent = userMap[message.userId] || message.userId;

		    const messageSpan = document.createElement('span');
		    messageSpan.classList.add('message');
		    messageSpan.innerHTML = escapeHTML(message.sendMessage).replace(/\n/g, '<br>');

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