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
</head>
<body>
    <h2>フレンド一覧</h2>
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
</body>
</html>
