# master/ slave
docker compose up -d
./my.sh 第一次起來之後, 大約要等3分鐘, ./my.sh才能ready

# master 

1. 建立repl_user  在master
./initmaster.sh

-- CREATE USER 'repl_user'@'%' IDENTIFIED WITH mysql_native_password BY 'repl_password';
-- GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
-- FLUSH PRIVILEGES;
-- SHOW MASTER STATUS;


2.  記錄 
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      157 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+


# slave

1. 建立與master的通訊
./initslave.sh

-- CHANGE MASTER TO
--   MASTER_HOST='<MASTER_HOST_IP>',
--   MASTER_PORT=<連接埠號碼>,
--   MASTER_USER='repl_user',
--   MASTER_PASSWORD='repl_password',
--   MASTER_LOG_FILE=<TODO>,
--   MASTER_LOG_POS=<TODO>;
-- 
-- -- 啟動 Slave
-- START SLAVE;
-- 
-- SHOW SLAVE STATUS\G

-- Slave_IO_Running: Yes
-- Slave_SQL_Running: Yes


# master
create database hello;
use hello;
CREATE TABLE sync_test (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO sync_test (message) VALUES ('Hello from Master 1!');
INSERT INTO sync_test (message) VALUES ('Hello from Master 2!');

