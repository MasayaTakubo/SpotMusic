DROP TABLE IF EXISTS blocked_user;
DROP TABLE IF EXISTS message;
DROP TABLE IF EXISTS playlists;
DROP TABLE IF EXISTS relation;
DROP TABLE IF EXISTS users;

CREATE TABLE USERS (
    USER_ID VARCHAR(30) PRIMARY KEY,
    ACCESS_TOKEN TEXT,
    REFRESH_TOKEN TEXT,
    EXPIRES_IN INT,
    USER_NAME VARCHAR(255)
);


CREATE TABLE RELATION (
    RELATION_ID INT AUTO_INCREMENT PRIMARY KEY,
    USER1_ID VARCHAR(30) NOT NULL,
    USER2_ID VARCHAR(30) NOT NULL,
    STATUS ENUM('PENDING', 'CANCEL', 'ACCEPT') DEFAULT 'PENDING',
    
    FOREIGN KEY (USER1_ID) REFERENCES USERS(USER_ID),
    FOREIGN KEY (USER2_ID) REFERENCES USERS(USER_ID)
);



CREATE TABLE PLAYLISTS (
    PLAYLIST_ID VARCHAR(22) PRIMARY KEY,
    USER_ID VARCHAR(30),
    NAME VARCHAR(255),
    DESCRIPTION TEXT,
    URL VARCHAR(255),
    FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
);




CREATE TABLE MESSAGE (
    MESSAGE_ID INT PRIMARY KEY AUTO_INCREMENT,
    RELATION_ID INT NOT NULL,
    USER_ID VARCHAR(30),
    SEND_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    SEND_MESSAGE VARCHAR(500),
    
    FOREIGN KEY (RELATION_ID) REFERENCES relation(RELATION_ID),
    FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
);

CREATE TABLE blocked_user (
    BLOCK_ID INT PRIMARY KEY AUTO_INCREMENT,
    BLOCKER_ID VARCHAR(30),
    BLOCKED_ID VARCHAR(30),
    BLOCK_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BLOCKER_ID) REFERENCES USERS(USER_ID),
    FOREIGN KEY (BLOCKED_ID) REFERENCES USERS(USER_ID)
);

CREATE TABLE COMMENT (
    COMMENT_ID   INT AUTO_INCREMENT PRIMARY KEY, 
    PLAYLIST_ID  VARCHAR(255) NOT NULL,
    USER_ID      VARCHAR(255) NOT NULL, 
    SEND_COMMENT TEXT NOT NULL,    
    SEND_TIME    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT FK_COMMENT_USER FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID) 
);


COMMIT;