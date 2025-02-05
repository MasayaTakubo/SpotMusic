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
</head>
<style>
	
    body{
    	background-color:black;
        background-image: url('<c:url value="/img/music.png"/>');
        background-size: cover;
       	background-repeat: no-repeat;
        background-position: center;
       	display: flex;
		justify-content:center;
		align-items: center;
    }
</style>
	

</style>
<body>
	<div class="formLogin">
			<img src="<c:url value='/img/logo.png' />" alt="logo" class="logo">
		
			<div class="login">
			    <!-- Spotifyアカウントでログイン -->
			    <form action="/SpotMusic/auth" method="get">
			        <input type="hidden" name="command" value="MyPlayListCommand">
			        <button type="submit" class="loginButton">Spotifyアカウントでログイン<i class='bx bx-log-in'></i></button>
			        
			    </form>
			    
	  		</div>
	    	<div class="signup">
	   			 <!-- Spotifyアカウント登録へのボタン -->
			    
			       <p>アカウントがありませんか？</p> <button type="button" onclick="window.open('https://www.spotify.com/signup/', '_blank')">SignUp</button>
			    
			</div>
			<div class="line"></div>
		
		
			<div class="friendList">
			    
			    <h2>フレンドリスト</h2>
			    <form action="FrontServlet" method="POST">
			        <input type="text" name="userId" placeholder="Enter your user ID" required>
			        <input type="hidden" name="command" value="FriendList">
			        <button type="submit" class="friendListButton"><i class='bx bxs-send'></i></button>
			    </form>
			    
	    	</div>
	    	<div class="userList">
	    
		   	 <h2>ユーザーリスト</h2>  
		    <form action="FrontServlet" method="POST">
		        <input type="text" name="userId" placeholder="Enter your user ID" required>
		        <input type="hidden" name="command" value="UsersList">
		        <button type="submit" class="userListButton"><i class='bx bxs-send'></i></button>
	        </div>
        
   </div>
</body>
</html>
