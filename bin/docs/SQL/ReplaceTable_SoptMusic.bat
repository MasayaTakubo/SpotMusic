@echo off

set MYSQL_USER=info
set MYSQL_PASS=pro
set MYSQL_HOST=localhost

echo Creating SPOTMUSIC database...
mysql -u %MYSQL_USER% -p%MYSQL_PASS% -h %MYSQL_HOST% -e "CREATE DATABASE IF NOT EXISTS SPOTMUSIC;"

echo Using SPOTMUSIC database as info user...
mysql -u %MYSQL_USER% -p%MYSQL_PASS% -h %MYSQL_HOST% -e "USE SPOTMUSIC;"


echo Executing SQL script...
mysql -u %MYSQL_USER% -p%MYSQL_PASS% -h %MYSQL_HOST% SPOTMUSIC < CREATE_AND_DROP_TABLE.sql

echo Done.
pause
