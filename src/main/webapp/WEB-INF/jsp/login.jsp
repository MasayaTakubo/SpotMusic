<%@ page language="java" contentType="text/html; charset=Windows-31J" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>login</title>
    <style>
        textarea {
            resize: none; /* サイズ変更を無効化 */
            width: 300px; /* 固定幅 */
            height: 100px; /* 固定高さ */
        }
    </style>
</head>
<body>
<h1>LOGIN</h1>
    <form action="FrontServlet" method="POST">
        <!-- ユーザーID入力 -->
        <input type="text" name="userId" placeholder="Enter your user ID" required><br><br>
		<input type="hidden" name="command" value="ChatCommand">
        <!-- 送信ボタン -->
        <button type="submit">login</button>
    </form>
</body>
</html>
