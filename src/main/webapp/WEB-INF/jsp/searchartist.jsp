<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>アーティスト詳細</title>
</head>
<body>
    <h1>アーティスト詳細</h1>

    <c:if test="${not empty artist}">
        <div>
            <!-- アーティスト画像 -->
            <c:if test="${not empty artist.images}">
                <img src="${artist.images[0].url}" alt="アーティスト画像" width="200">
            </c:if>
            <c:if test="${empty artist.images}">
                <img src="<c:url value='/img/no_image.png' />" alt="No Image" width="200">
            </c:if>

            <h2>${artist.name}</h2>
            <p>フォロワー: ${artist.followers}</p>
        </div>

        <!-- フォロー/リフォローフォーム -->
		<form id="followForm" action="FrontServlet" method="post" target="hidden_iframe">
		    <input type="hidden" name="command" value="followArtist"> <!-- コマンド指定 -->
		    <input type="hidden" name="artistId" value="${artist.id}">
		    <input type="hidden" id="followAction" name="action" value="${sessionScope.isFollowed ? 'unfollow' : 'follow'}">
		    <button type="submit" id="followButton">
		        ${sessionScope.isFollowed ? 'フォロー解除' : 'フォロー'}
		    </button>
		</form>
		
		<iframe name="hidden_iframe" style="display:none;"></iframe>

		<h3>人気曲</h3>
		<c:if test="${not empty top_tracks}">
		    <ul>
		        <c:forEach var="track" items="${top_tracks}">
		            <li>
		                <!-- トラックの画像 -->
<%-- 				       <c:choose>
				            <c:when test="${not empty track.image}">
				                <img src="${track.image}" alt="アルバム画像" width="100">
				            </c:when>
				            <c:otherwise>
				                <img src="<c:url value='/img/no_image.png' />" alt="No Image" width="100">
				            </c:otherwise>
				        </c:choose> --%>
		
		                ${track.name}
		
		                <!-- プレイリスト追加フォーム -->
					<form class="add-track-form" action="FrontServlet" method="post" target="hidden_iframe">
					    <input type="hidden" name="command" value="addTrack">
					    <input type="hidden" name="trackId" value="${track.id}">
					    <select name="playlistId">
					        <c:forEach var="playlist" items="${userPlaylists}">
					            <option value="${playlist.id}">${playlist.name}</option>
					        </c:forEach>
					    </select>
					    <button class="add-button" type="submit">追加</button>
					    <button type="button" onclick="playTrack('${track.id}', '${track.name}')">再生</button>
					</form>
		            </li>
		        </c:forEach>
		    </ul>
		</c:if>
		<c:if test="${empty top_tracks}">
		    <p>人気曲が見つかりませんでした。</p>
		</c:if>



        <!-- アルバム一覧 -->
        <h3>アルバム一覧</h3>
        <c:if test="${not empty albums}">
            <ul>
                <c:forEach var="album" items="${albums}">
                    <li>
                        <a href="/SpotMusic/FrontServlet?command=SpotifySearchCommand&action=album&id=${album.id}">${album.name}</a>
                    </li>
                </c:forEach>
            </ul>
        </c:if>
        <c:if test="${empty albums}">
            <p>アルバムが見つかりませんでした。</p>
        </c:if>
    </c:if>

    <c:if test="${empty artist}">
        <p>アーティストが見つかりませんでした。</p>
    </c:if>


<script>
function updateFollowButtonFromSearchArtist(artistId) {
    var timestamp = new Date().getTime();  // キャッシュ防止用のタイムスタンプ

    $.ajax({
        type: "GET",
        url: "/SpotMusic/SpotifyCheckFollowStatusServlet",
        data: { id: artistId, fromSearchArtistPage: true, ts: timestamp },  // `ts` パラメータを追加
        success: function(isFollowed) {
            var followButton = document.getElementById("followButton");
            var followAction = document.getElementById("followAction");

            if (followButton && followAction) {
                var trimmedResponse = isFollowed.trim();
                
                if (trimmedResponse === "true") {
                    followButton.innerText = "フォロー解除";
                    followAction.value = "unfollow";
                } else if (trimmedResponse === "false") {
                    followButton.innerText = "フォロー";
                    followAction.value = "follow";
                } else {
                    console.warn("予期しないレスポンス:", isFollowed);
                    followButton.innerText = "フォロー (未確認)";
                    followAction.value = "follow";
                }
            }
        },
        error: function() {
            console.error("フォロー状態の取得に失敗しました");
        }
    });
}


</script>

</body>
</html>
