<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>エラーページ</title>
    <link rel="stylesheet" type="text/css" href="css/error.css">
</head>
<body>
    <div class="container">
        <h1>エラーが発生しました</h1>
        <p>下のボタンから戻ってください。</p>
        <button type="button" onclick="history.back()">戻る</button>
    </div>
</body>
</html>
