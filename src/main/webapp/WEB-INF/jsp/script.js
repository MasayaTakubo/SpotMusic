/**
 * これはartist.jspで定義されているscriptを呼び出すためのファイルです。
 * 
 */

function loadAlbumPage(albumId) {
    console.log("loadAlbumPage called with albumId:", albumId);  // デバッグ用
    const url = "/SpotMusic/FrontServlet?command=AlbumDetails&albumId=" + albumId;
    console.log("Fetch URL:", url);  // デバッグ用

    const contentDiv = document.querySelector('.content');
    fetch(url)
    .then(response => response.text())
    .then(data => {
        contentDiv.innerHTML = data;
    })
    .catch(error => {
        console.error('Error loading album page:', error);
        contentDiv.innerHTML = '<p>アルバム情報の取得に失敗しました。</p>';
    });
}
