<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="<c:url value='/css/login.css' />">
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <title>Spotify</title>
    <style>
        body {
            background-color: black;
            background-image: url('<c:url value="/img/music.png"/>');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow: hidden;
        }

    </style>
</head>
<body>
    <div class="formLogin">
        <img src="<c:url value='/img/logo.png' />" alt="logo" class="logo">

        <div class="login">
            <form id="loginForm" action="/SpotMusic/auth" method="get" onsubmit="return handleLogin(event)">
                <input type="hidden" name="command" value="MyPlayListCommand">
                <button type="submit" class="loginButton">Spotifyアカウントでログイン<i class='bx bx-log-in'></i></button>
            </form>
            <div id="progressContainer">
                <div id="progressBar"></div>
                <div id="progressText">0%</div>
            </div>
        </div>
        <div class="line"></div>

        <div class="signup">
            <p>アカウントがありませんか？</p>
            <button type="button" onclick="window.open('https://www.spotify.com/signup/', '_blank')">SignUp</button>
        </div>
    </div>

    <script>
        function handleLogin(event) {
            event.preventDefault();
            const progressContainer = document.getElementById('progressContainer');
            const progressBar = document.getElementById('progressBar');
            const progressText = document.getElementById('progressText');
            const form = document.getElementById('loginForm');
            let progress = 0;

            progressContainer.style.display = 'block';

            const interval = setInterval(() => {
                progress += 5;
                progressBar.style.width = progress + '%';
                progressText.textContent = progress + '%';

                if (progress >= 100) {
                    clearInterval(interval);
                    form.submit();
                }
            }, 100);

            return false;
        }
    </script>
</body>
</html>
