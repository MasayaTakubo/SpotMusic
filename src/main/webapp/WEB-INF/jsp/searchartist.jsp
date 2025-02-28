<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>アーティスト詳細</title>
    
    <style>
		.artist-container {
    display: flex;
    align-items: center;
    gap: 20px; 
}

.artist-image img {
    width: 300px;
    height: 300px;
    border-radius:50% ;
    box-shadow: 0 0 10px rgba(255,255,255,0.8);
    margin-left:20px;
}
.artist-info{
	display: flex;
	flex-direction: column;
	align-items: flex-start;
	
}

.artist-info h2 {
    margin: 0;
    font-size: 80px;
    font-weight: bold;
}

.artist-info p {
    margin: 5px 0;
    font-size: 25px;
    font-weight: bold;
}

#followForm {
    margin-top: 10px;
}

#followButton {
    background-color: rgb(222,222,222);
    color: rgb(34,34,34);
    border: none;
    padding: 10px 15px;
    font-size: 16px;
    cursor: pointer;
    border-radius: 20px;
   font-weight: bold;
}

#followButton:hover {
    background-color:white;
}

.track-container {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    padding: 10px;
    list-style: none;
    justify-content: flex-start;
}

.track-box {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 150px;
    background: #333;
    padding: 10px;
    border-radius: 8px;
    text-align: center;
    color: white;
}

.track-box img {
    width: 130px;
    height: 130px;
    border-radius: 5px;
}

.track-box p {
    font-size: 12px;
    margin: 5px 0 0;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    width: 100%;
}

.ttrack-form {
    display: flex;
    flex-direction: column;
    align-items: center;
}

.ttrack-form select,
.ttrack-form button {
    width: 100%;
    margin-top: 5px;
    padding: 8px;
    border: none;
    border-radius: 5px;
    background-color: #444;
    color: white;
    cursor: pointer;
}

.ttrack-form button:hover {
    background-color: #666;
}


		    
    </style>
</head>
<body>
     <h1>アーティスト詳細情報</h1>

    <c:if test="${not empty artist}">
        <div class="artist-container">
       
        <div class="artist-image">
            <c:if test="${not empty artist.images}">
                <img src="${artist.images[0].url}" alt="アーティスト画像">
            </c:if>
            <c:if test="${empty artist.images}">
                <img src="<c:url value='/img/no_image.png' />" alt="No Image">
            </c:if>
        </div>

       
        <div class="artist-info">
            <h2>${artist.name}</h2>
            <p><i class='bx bxs-heart'></i> ${artist.followers}</p>

           
            <form id="followForm" action="FrontServlet" method="post" target="hidden_iframe">
                <input type="hidden" name="command" value="followArtist">
                <input type="hidden" name="artistId" value="${artist.id}">
                <input type="hidden" id="followAction" name="action" value="${sessionScope.isFollowed ? 'unfollow' : 'follow'}">
                <button type="submit" id="followButton">
                    ${sessionScope.isFollowed ? 'リフォロー解除' : 'フォロー'}
                </button>
            </form>
        </div>
    </div>

    <iframe name="hidden_iframe" style="display:none;"></iframe>

		<h1>人気曲</h1>
		<c:if test="${not empty top_tracks}">
    <ul class="track-container">
        <c:forEach var="track" items="${top_tracks}">
            <li class="track-box">
                <!-- トラックの画像 -->
                <c:choose>
                    <c:when test="${not empty track.image}">
                        <img src="${track.image}" alt="アルバム画像">
                    </c:when>
                    <c:otherwise>
                        <img src="<c:url value='/img/no_image.png' />" alt="No Image">
                    </c:otherwise>
                </c:choose>

                <p>${track.name}</p>

                <!-- プレイリスト追加フォーム  -->
                <form class="ttrack-form" action="FrontServlet" method="post" target="hidden_iframe">
                    <input type="hidden" name="command" value="addTrack">
                    <input type="hidden" name="trackId" value="${track.id}">
                    <select name="playlistId">
                        <c:forEach var="playlist" items="${userPlaylists}">
                            <option value="${playlist.id}">${playlist.name}</option>
                        </c:forEach>
                    </select>
                    <button  type="submit">追加</button>
                    <button  type="button" onclick="playTrack('${track.id}', '${track.name}')">再生</button>
                </form>
            </li>
        </c:forEach>
    </ul>
</c:if>

<c:if test="${empty top_tracks}">
    <p>人気曲が見つかりませんでした。</p>
</c:if>



<%--         <!-- アルバム一覧 -->
        <h3>アルバム一覧</h3>
        <c:if test="${not empty albums}">
            <ul class="a">
                <c:forEach var="album" items="${albums}">
                    <li>
                        <a href="/SpotMusic/FrontServlet?command=SpotifySearchCommand&action=album&id=${album.id}">${album.name}</a>
                    </li>
                </c:forEach>
            </ul>
        </c:if>
        <c:if test="${empty albums}">
            <p>アルバムが見つかりませんでした。</p>
        </c:if> --%>
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
                    followButton.innerText = "リフォロー解除";
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
