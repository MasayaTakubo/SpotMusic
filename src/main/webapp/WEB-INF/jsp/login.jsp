<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Spotify</title>
</head>
<body>
    <h1>Spotifyログイン</h1>
	<p>Spotifyにログインするには、以下のボタンをクリックしてください。</p>
    <form action="/SpotMusic/auth" method="get" >
    <input type="hidden" name="command" value="MyPlayListCommand">
         <button type="submit">Spotifyアカウントでログイン</button>
    </form>
    

        
</body>
</html>