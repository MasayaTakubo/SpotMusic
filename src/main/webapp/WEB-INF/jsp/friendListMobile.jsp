<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.util.List"%>
<%@ page import="bean.SpotifyPlayListBean"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="bean.TrackBean"%>
<%@ page import="bean.PlayListBean"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>フレンドリスト</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
<div class="content">
    <h1>フレンドリスト</h1>
    <h1>${sessionScope.user_name}</h1>
    <p>申請中のユーザー</p>
    <table border="1">
        <tr>
            <th>ユーザー名</th>
            <th>状態</th>
            <th>ボタン</th>
        </tr>
	    <c:forEach var="relation" items="${messages.relations}">
	    <c:if test="${relation.status eq 'PENDING'}">
        <tr>
            <c:choose>
                <c:when test="${relation.user1Id != sessionScope.userId}">
                    <td>
                        <c:forEach var="user" items="${messages.users}">
                            <c:if test="${user.userId eq relation.user1Id}">
                                ${user.userName}
                            </c:if>
                        </c:forEach>
                    </td>
                </c:when>
                <c:when test="${relation.user2Id != sessionScope.userId}">
                    <td>
                        <c:forEach var="user" items="${messages.users}">
                            <c:if test="${user.userId eq relation.user2Id}">
                                ${user.userName}
                            </c:if>
                        </c:forEach>
                    </td>
                </c:when>
            </c:choose>
            <c:choose>
                <c:when test="${relation.user1Id != sessionScope.userId}">
                       <td>フレンド申請が来ました</td>
                </c:when>
                <c:when test="${relation.user2Id != sessionScope.userId}">
                       <td>フレンド申請を行いました</td>
                </c:when>
            </c:choose>
		    <c:if test="${relation.user1Id != sessionScope.userId}">
		    
		    <td>
				<button type="button" onclick="acceptRelation('${relation.relationId}', '${sessionScope.userId}')">承認</button>


				<button type="button" onclick="cancelRelation('${relation.relationId}')">拒否</button>

             </td>
             </c:if>
             <c:if test="${relation.user1Id == sessionScope.userId}">
             <td>
					<button type="button" onclick="deleteRelation('${relation.relationId}', '${sessionScope.userId}')">フレンド申請取消</button>

             </td>
             </c:if>
        </tr>
    </c:if>
    </c:forEach>
    </table>
    <p>フレンド</p>
	<table border="1">
		<th>ユーザー名</th>
		<th>Action</th>
		<th>チャット</th>
	    <c:forEach var="relation" items="${messages.relations}">
	        <c:if test="${relation.status eq 'ACCEPT'}">
	            <c:set var="blocked" value="false"/>
	            <c:set var="blockTime" value="" />
	            <c:forEach var="block" items="${messages.blockusers}">
	                <c:if test="${(relation.user1Id == sessionScope.userId and relation.user2Id == block.blockedId) or 
	                              (relation.user2Id == sessionScope.userId and relation.user1Id == block.blockedId)}">
	                    <c:set var="blocked" value="true"/>
	                    <c:set var="blockId" value="${block.blockId}"/>
	                    <c:set var="blockTime" value="${block.blockTime}" />
	                </c:if>
	            </c:forEach>
	            <tr>
                    <c:choose>
		                <c:when test="${relation.user1Id != sessionScope.userId}">
		                    <td>
		                        <c:forEach var="user" items="${messages.users}">
		                            <c:if test="${user.userId eq relation.user1Id}">
		                                ${user.userName}
		                            </c:if>
		                        </c:forEach>
		                    </td>
		                </c:when>
		                <c:when test="${relation.user2Id != sessionScope.userId}">
		                    <td>
		                        <c:forEach var="user" items="${messages.users}">
		                            <c:if test="${user.userId eq relation.user2Id}">
		                                ${user.userName}
		                            </c:if>
		                        </c:forEach>
		                    </td>
		                </c:when>
		            </c:choose>
	                <td>
	                    <form action="FrontServlet" method="POST">
	                        <input type="hidden" name="userId" value="${sessionScope.userId}"/>
	                        <c:choose>
					<c:when test="${blocked}">
					    <button type="button" onclick="removeBlock('${blockId}','${userId}')">ブロック解除</button>
					</c:when>
	                            
	                            <c:otherwise>
								    <button type="button" onclick="addBlock('${userId}', '${relation.relationId}')">ブロック</button>
								</c:otherwise>
	                            
	                        </c:choose>
	                    </form>
	                </td>
	                <td>
<form action="FrontServlet" method="POST" target="_blank">
    <input type="hidden" name="relationId" value="${relation.relationId}"/>
    <input type="hidden" name="userId" value="${sessionScope.userId}"/>
    <input type="hidden" name="command" value="ChatCommand"/>
    <input type="hidden" name="isBlock" value="${blocked}"/>
    <button type="submit">ログイン</button>
</form>



	                </td>
	            </tr>
	        </c:if>
	    </c:forEach>
	</table>
	<ul>
		<c:forEach var="playlistBeans" items="${messages.friendsList}">
	    <c:forEach var="playlist" items="${playlistBeans}">
	        <li>
	            <button onclick="loadPlaylistPage('${playlist.playlistId}')">
	            	<strong>ユーザー名  ：</strong>
	            	<c:forEach var="user" items="${messages.users}">
                        <c:if test="${user.userId eq playlist.userId}">
                            ${user.userName}<br>
                        </c:if>
                    </c:forEach>
	                <strong>プレイリストID：</strong> ${playlist.playlistId}<br>
	            </button>
	        </li><br>
	    </c:forEach>
	    </c:forEach>
	</ul>
	


    <p>フレンド申請をキャンセルしたユーザー</p>
	<table border="1">
	    <tr>
	        <th>ユーザー名</th>
	    </tr>
	    <c:forEach var="relation" items="${messages.relations}">
	        <c:if test="${relation.status eq 'CANCEL'}">
	        <tr>
	            <c:choose>
	                <c:when test="${relation.user1Id != sessionScope.userId}">
	                    <td>
	                        <c:forEach var="user" items="${messages.users}">
	                            <c:if test="${user.userId eq relation.user1Id}">
	                                ${user.userName}
	                            </c:if>
	                        </c:forEach>
	                    </td>
	                </c:when>
	                <c:when test="${relation.user2Id != sessionScope.userId}">
	                    <td>
	                        <c:forEach var="user" items="${messages.users}">
	                            <c:if test="${user.userId eq relation.user2Id}">
	                                ${user.userName}
	                            </c:if>
	                        </c:forEach>
	                    </td>
	                </c:when>
	            </c:choose>
	        </tr>
	        </c:if>
	    </c:forEach>
	</table>
		<button type="button" onclick="userList()">ユーザーリストへ</button>
		<button type="button" onclick="blockList()">ブロックリストへ</button>
		
		
	</div>
			<script>
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
		<script>
	function submitLoginForm() {
		alert("チェック");
	    const userId = document.getElementById('userId').value;
	    const relationId = document.getElementById('relationId').value;
	    const isBlock = document.getElementById('isBlock').value;
	    const blockTime = document.getElementById('blockTime').value;
	    const url = '/SpotMusic/FrontServlet';
	    const contentDiv = document.querySelector('.content');

	    // クエリパラメータを作成
	    const params = new URLSearchParams();
	    params.append('command', 'ChatCommand');
	    params.append('userId', userId);
	    params.append('relationId', relationId);
	    params.append('isBlock', isBlock);
	    params.append('blockTime', blockTime);

	    console.log("送信データ:", params.toString());

	    // fetchで非同期リクエストを送信
	    fetch(url, {
	        method: 'POST',
	        headers: {
	            'Content-Type': 'application/x-www-form-urlencoded'
	        },
	        body: params
	    })
	    .then(response => {
	        if (!response.ok) {
	            throw new Error('サーバーエラー: ' + response.status);
	        }
	        return response.text();
	    })
	    .then(data => {
	        contentDiv.innerHTML = data; // レスポンスデータをcontent divに挿入
	        console.log("チャットページがロードされました！");

	        // メニューのイベントを再適用
	        document.querySelectorAll(".menu-btn").forEach(button => {
	            button.addEventListener("click", function() {
	                toggleMenu(this);
	            });
	        });

	        console.log("toggleMenu イベントを再適用しました");
	    })
	    .catch(error => {
	        console.error('エラー発生:', error);
	        contentDiv.innerHTML = '<p>チャットページの取得に失敗しました。</p>';
	    });
	}

	
function friendlist() {
    const url = '/SpotMusic/FrontServlet?command=FriendList&userId=' + encodeURIComponent('${sessionScope.user_id}');
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
            console.log("フレンドリストページがロードされました！");

            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>フレンドリストの取得に失敗しました。</p>';
        });
}


function userList() {
    const userId = encodeURIComponent('${sessionScope.user_id}'); // user_idを取得
    const url = '/SpotMusic/FrontServlet?command=UsersList&userId=' + userId;
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
            console.log("ユーザーリストページがロードされました！");

            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>ユーザーリストの取得に失敗しました。</p>';
        });
}
function blockList() {
    const userId = encodeURIComponent('${sessionScope.user_id}'); // user_idを取得
    console.log(userId);
    const url = '/SpotMusic/FrontServlet?command=BlockList&userId=' + userId;
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
            console.log("ブロックリストページがロードされました！");

            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>ブロックリストの取得に失敗しました。</p>';
        });
}

function removeBlock(blockId, userId) {
    if (!blockId) {
        console.error("エラー: blockId が未指定です");
        return;
    }
    if (!userId) {
        console.error("エラー: userId が未指定です");
        return;
    }

    const encodedBlockId = encodeURIComponent(blockId);
    const encodedUserId = encodeURIComponent(userId);
    const command = "RemoveBlock";

    const url = '/SpotMusic/FrontServlet?command='+ command + '&blockId=' + encodedBlockId + '&userId=' + encodedUserId;
    const contentDiv = document.querySelector('.content');

    console.log("送信URL:", url); // デバッグ用

    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text();
        })
        .then(data => {
            contentDiv.innerHTML = data;
            console.log("ブロック解除が成功しました！");

            // メニューのイベントを再適用
            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>ブロック解除に失敗しました。</p>';
        });
}

function addBlock(userId, relationId) {
    if (!userId) {
        console.error("エラー: userId が未指定です");
        return;
    }
    if (!relationId) {
        console.error("エラー: relationId が未指定です");
        return;
    }

    const encodedUserId = encodeURIComponent(userId);
    const encodedRelationId = encodeURIComponent(relationId);
    const command = "AddBlockFriend";

    const url = '/SpotMusic/FrontServlet?command='+ command + '&userId=' + encodedUserId + '&relationId=' + encodedRelationId;
    const contentDiv = document.querySelector('.content');

    console.log("送信URL:", url); // デバッグ用

    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text();
        })
        .then(data => {
            contentDiv.innerHTML = data;
            console.log("ブロックが成功しました！");

            // メニューのイベントを再適用
            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>ブロックに失敗しました。</p>';
        });
}

function deleteRelation(relationId, userId) {
    if (!relationId) {
        console.error("エラー: relationId が未指定です");
        return;
    }
    if (!userId) {
        console.error("エラー: userId が未指定です");
        return;
    }

    const encodedRelationId = encodeURIComponent(relationId);
    const encodedUserId = encodeURIComponent(userId);
    const command = "DeleteRelation";

    const url = '/SpotMusic/FrontServlet?command='+ command + '&userId=' + encodedUserId + '&relationId=' + encodedRelationId;
    const contentDiv = document.querySelector('.content');

    console.log("送信URL:", url); // デバッグ用

    fetch(url, { method: "POST" }) // POSTリクエストとして送信
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text();
        })
        .then(data => {
            contentDiv.innerHTML = data;
            console.log("フレンド申請の取消が成功しました！");

            // メニューのイベントを再適用
            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>フレンド申請の取消に失敗しました。</p>';
        });
}

function acceptRelation(relationId, userId) {
    if (!relationId || !userId) {
        console.error("エラー: relationId または userId が未指定です");
        return;
    }

    const encodedRelationId = encodeURIComponent(relationId);
    const encodedUserId = encodeURIComponent(userId);
    
    const command = "AcceptRelation";
    
    const url = '/SpotMusic/FrontServlet?command='+ command + '&userId=' + encodedUserId + '&relationId=' + encodedRelationId;
    const contentDiv = document.querySelector('.content');

    console.log("送信URL:", url); // デバッグ用

    fetch(url, { method: "POST" })
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text();
        })
        .then(data => {
            contentDiv.innerHTML = data;
            console.log("フレンド申請が承認されました！");

            // メニューのイベントを再適用
            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>フレンド申請の承認に失敗しました。</p>';
        });
}
function cancelRelation(relationId) {
    if (!relationId) {
        console.error("エラー: relationId が未指定です");
        return;
    }
    const encodedRelationId = encodeURIComponent(relationId);
    const command = "CancelRelation";
    
    const url = '/SpotMusic/FrontServlet?command='+ command +  '&relationId=' + encodedRelationId;
    const contentDiv = document.querySelector('.content');

    console.log("送信URL:", url); // デバッグ用

    fetch(url, { method: "POST" })
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text();
        })
        .then(data => {
            contentDiv.innerHTML = data;
            console.log("フレンド申請が拒否されました！");

            // メニューのイベントを再適用
            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>フレンド申請の拒否に失敗しました。</p>';
        });
}
function addRelation(user1Id, user2Id) {
    if (!user1Id || !user2Id) {
        console.error("エラー: user1Id または user2Id が未指定です");
        return;
    }
	const encodedUser1Id = encodeURIComponent(user1Id);
	const encodedUser2Id = encodeURIComponent(user2Id);
    const command = "AddRelation";

    const url = '/SpotMusic/FrontServlet?command='+ command +  '&user1Id=' + encodedUser1Id + '&user2Id=' + encodedUser2Id;
        const contentDiv = document.querySelector('.content');

    console.log("送信URL:", url); // デバッグ用

    fetch(url, { method: "POST" })
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text();
        })
        .then(data => {
            contentDiv.innerHTML = data;
            console.log("フレンド申請が送信されました！");

            // メニューのイベントを再適用
            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>フレンド申請の送信に失敗しました。</p>';
        });
}
function addBlockUser(blockedId, blockerId) {
    if (!blockedId || !blockerId) {
        console.error("エラー: blockedId または blockerId が未指定です");
        return;
    }
	const encodedblockedId = encodeURIComponent(blockedId);
	const encodedblockerId = encodeURIComponent(blockerId);
	
    const command = "AddBlockUser";
    const url = '/SpotMusic/FrontServlet?command='+ command +  '&blockedId=' + encodedblockedId + '&blockerId=' +  encodedblockerId;
    
    const contentDiv = document.querySelector('.content');

    console.log("送信URL:", url); // デバッグ用

    fetch(url, { method: "POST" })
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text();
        })
        .then(data => {
            contentDiv.innerHTML = data;
            console.log("ブロックが成功しました！");

            // メニューのイベントを再適用
            document.querySelectorAll(".menu-btn").forEach(button => {
                button.addEventListener("click", function() {
                    toggleMenu(this);
                });
            });

            console.log("toggleMenu イベントを再適用しました");
        })
        .catch(error => {
            console.error('エラー発生:', error);
            contentDiv.innerHTML = '<p>ブロックに失敗しました。</p>';
        });
}


function sendMessage(relationId, userId) {
    const messageInput = document.getElementById("messageInput");

    if (!relationId || !userId) {
        console.error("エラー: relationId または userId が未指定です");	
        return;
    }

    if (!messageInput || !messageInput.value.trim()) {
        alert("メッセージを入力してください。");
        return;
    }

    const message = messageInput.value.trim();
    const encodedRelationId = encodeURIComponent(relationId);
    const encodedUserId = encodeURIComponent(userId);
    const encodedMessage = encodeURIComponent(message);
    const command = "AddMessage";

    const url = '/SpotMusic/FrontServlet?command=' + command +
                '&relationId=' + encodedRelationId +
                '&userId=' + encodedUserId +
                '&message=' + encodedMessage;

    console.log("送信URL:", url); // デバッグ用

    fetch(url, { method: "POST" })
        .then(response => {
            if (!response.ok) {
                throw new Error('サーバーエラー: ' + response.status);
            }
            return response.text();
        })
        .then(data => {
            console.log("メッセージが送信されました！", data);
            messageInput.value = ""; // 送信後に入力欄をクリア
        })
        .catch(error => {
            console.error('エラー発生:', error);
            alert('メッセージの送信に失敗しました。');
        });
}


</script>
	
</body>
</html>
