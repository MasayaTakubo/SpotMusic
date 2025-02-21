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
body, html {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
    background-color: #f1f1f1;
    height: 100%;
    overflow: hidden; /* ページ全体のスクロールを防ぐ */
}

h1 {
    text-align: center;
    color: #007bff;
}

h3 {
    position: absolute;
    top: 10px;
    left: 20px;
    font-size: 16px;
    color: #333;
    margin: 0;
}

.chat-container {
    display: flex;
    flex-direction: column;
    height: 100vh; /* 画面全体を埋める */
    overflow: hidden; /* コンテンツがはみ出てもスクロールしない */
}

.chat-box {
    flex: 1;
    overflow-y: auto; /* ここだけスクロール可能にする */
    background-color: #f8f9fa;
    display: flex;
    flex-direction: column-reverse;
    padding: 15px;
}

.chat-message {
    display: flex;
    flex-direction: column;
    width: 100%;
    margin: 10px 0;
    font-size: 14px;
}

.chat-message.left {
    align-items: flex-start;
}

.chat-message.right {
    align-items: flex-end;
}

.chat-message .message {
    max-width: 70%;
    padding: 10px;
    border-radius: 10px;
    word-break: break-word;
    font-size: 14px;
    line-height: 1.4;
}

.chat-message.left .message {
    background-color: #e0e0e0;
    color: #333;
}

.chat-message.right .message {
    background-color: #a0e7ff;
    color: #004466;
}

.chat-message .user {
    font-weight: bold;
    color: #007bff;
    margin: 0;
}

.chat-message .time {
    font-size: 0.8em;
    color: #888;
    margin: 0;
}

.chatWindow {
    position: relative;
    width: 100%;
    background-color: #fff;
    padding: 10px;
    border-top: 1px solid #ccc;
}

textarea {
    width: 100%;
    padding: 10px;
    font-size: 14px;
    border-radius: 5px;
    border: 1px solid #ccc;
    margin-bottom: 10px;
    resize: none;
    outline: none;
    box-sizing: border-box;
}

button {
    background-color: #007bff;
    color: white;
    border: none;
    padding: 10px;
    font-size: 14px;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s;
}

button:hover {
    background-color: #0056b3;
}

button:disabled {
    background-color: #d6d6d6;
    cursor: not-allowed;
}

.close-tab-button {
    position: absolute;
    top: 10px;
    right: 20px;
    font-size: 12px;
}

.friend-list-button:hover {
    background-color: #218838;
}

.warning-message {
    color: red;
    text-align: center;
    font-size: 1.2em;
    margin-top: 20px;
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
<button type="button" class="close-tab-button" onclick="closeTab()">ページを閉じる</button>

<div class="chat-container">
    <h1>Chat Room</h1>
    <h3>ログインユーザー：${sessionScope.user_name }</h3>

    <div id="chat-box" class="chat-box">
        <!-- メッセージ表示部分 -->
    </div>

    <c:set var="isBlock" value="${param.isBlock}" />
    <div class="chatWindow">
    <c:if test="${isBlock eq 'true'}">
        <p class="warning-message">ブロック中のため、メッセージを送信できません。</p>
    </c:if>
        <form action="FrontServlet" method="POST" id="chatForm" onsubmit="return false;">
            <textarea name="message" id="messageInput" placeholder="Type your message here..." required></textarea>
            <input type="hidden" name="relationId" id="relationId" value="${param.relationId}">
            <input type="hidden" name="userId" id="userId" value="${sessionScope.userId}">
            <input type="hidden" name="command" value="AddMessage">
            <button id="sendButton" name="sendButton" type="submit" ${isBlock eq 'true' ? 'disabled' : ''}>送信</button>
        </form>
    </div>
</div>

    <script>

    function closeTab() {
        window.close();
    }
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

		    // ユーザー名を表示
		    const userSpan = document.createElement('span');
		    userSpan.classList.add('user');
		    if (message.userId !== loggedInUserId) {  // 自分のメッセージでは名前を表示しない
		        userSpan.textContent = userMap[message.userId] || message.userId;
		    }

		    // メッセージ内容
		    const messageSpan = document.createElement('span');
		    messageSpan.classList.add('message');
		    messageSpan.innerHTML = escapeHTML(message.sendMessage).replace(/\n/g, '<br>');

		    // メッセージ送信時刻
		    const timeSpan = document.createElement('span');
		    timeSpan.classList.add('time');
		    const date = new Date(message.sendTime);
		    const formattedTime = date.toLocaleString('ja-JP', {
		        year: 'numeric',
		        month: '2-digit',
		        day: '2-digit',
		        hour: '2-digit',
		        minute: '2-digit',
		        second: '2-digit',
		        hour12: false // 24時間表示
		    });
		    timeSpan.textContent = formattedTime;

		    // メッセージの組み立て
		    messageContainer.appendChild(userSpan);
		    //messageContainer.appendChild(document.createElement('br'));
		    messageContainer.appendChild(messageSpan);
		    //messageContainer.appendChild(document.createElement('br'));
		    messageContainer.appendChild(timeSpan);
		    //messageContainer.appendChild(document.createElement('br'));

		    // チャットボックスに追加
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