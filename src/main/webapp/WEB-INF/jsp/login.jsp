
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
    <p>Spotifyアカウントでログインするか、ユーザーIDを入力してください。</p>

    <!-- Spotifyアカウントでログイン -->
    <form action="/SpotMusic/auth" method="get">
        <input type="hidden" name="command" value="MyPlayListCommand">
        <button type="submit">Spotifyアカウントでログイン</button>
    </form>
    <br><br>
    
    <!-- Spotifyアカウント登録へのボタン -->
    <p>
        アカウント登録<br>
        <button type="button" onclick="window.open('https://www.spotify.com/signup/', '_blank')">サインアップ</button>
    </p>
    <br>

    <!-- ユーザーIDでログイン -->
    <h2>ユーザーIDでログイン</h2>
    <form action="FrontServlet" method="POST">
        <input type="text" name="userId" placeholder="Enter your user ID" required><br><br>
        <input type="hidden" name="command" value="ChatCommand">
        <button type="submit">ログイン</button>
    </form>
    <br><br>
    
    <h2>フレンドリスト</h2>
    <form action="FrontServlet" method="POST">
        <input type="text" name="userId" placeholder="Enter your user ID" required><br><br>
        <input type="hidden" name="command" value="FriendList">
        <button type="submit">フレンドリストへ</button>
    </form>
    <br><br>
    
    
    <h2>ユーザーリスト</h2>  
    <form action="FrontServlet" method="POST">
        <input type="text" name="userId" placeholder="Enter your user ID" required><br><br>
        <input type="hidden" name="command" value="UsersList">
        <button type="submit">ログイン</button>
</body>
</html>
