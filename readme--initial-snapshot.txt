步驟 1：從 Master 匯出資料 (Backup)
您可以使用 mysqldump 將 Master 的資料庫（例如 testdb 或全部資料庫）導出成 SQL 檔案。

請在 Master 機器上執行以下指令（假設資料要匯出到 ./data/master_dump.sql）：

```
# 包含資料、結構以及自動加上鎖定點 (Master 建議加上 --master-data=2 記錄當下的 binlog 點)
docker exec -it mysql-master mysqldump -u root -proot_secure_password \
  --databases testdb \
  --routines --triggers --events \
  --master-data=2 \
  > ./data/master_dump.sql
```

(註：如果想匯出所有資料庫，可以把 --databases testdb 改成 --all-databases)

💡 如何取得對應的 Binlog 點？
打開剛剛導出的 ./data/master_dump.sql 檔案，用文字編輯器或 head 搜尋 CHANGE MASTER TO，您會看到類似下面幾行的註解：

```
-- CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000005', MASTER_LOG_POS=483;
```

請記下這組 File 與 Position，這代表這個 SQL 備份檔對應到 Master 的哪個時間點。


步驟 2：將備份檔傳送到 Slave 機器並匯入 (Restore)
傳送檔案：將 ./data/master_dump.sql 傳送到 Slave 機器的對應目錄下（假設放在 Slave 的 ./data/ 目錄）。

匯入到 Slave：在 Slave 機器上執行以下指令，將 SQL 匯入：

```
docker exec -i mysql-slave mysql -u root -proot_secure_password < ./data/master_dump.sql
```

(匯入完成後，Slave 的資料就會跟 Master 在備份當下的狀態完全一模一樣)

步驟 3：在 Slave 設定並啟動 Replication
因為我們在步驟 1 已經透過 --master-data=2 知道了匯入當下的 Binlog 位置，現在只需要讓 Slave 從這個點開始繼續追後續的變更。

進入 Slave 容器：

Bash
docker exec -it mysql-slave mysql -u root -proot_secure_password
在 MySQL 介面中執行（將 <MASTER_HOST_IP> 換成 Master 的 IP，並填入剛剛從 dump 檔中看到的 File 與 Position）：

SQL
-- 1. 停止舊的複製狀態（如果有）
STOP SLAVE;

-- 2. 設定 Master 連線資訊與起始點
CHANGE MASTER TO
  MASTER_HOST='<MASTER_HOST_IP>',
  MASTER_USER='repl_user',
  MASTER_PASSWORD='repl_password',
  MASTER_LOG_FILE='mysql-bin.000005',  -- 填入 dump 檔中記錄的檔名
  MASTER_LOG_POS=483;                -- 填入 dump 檔中記錄的 position

-- 3. 啟動 Slave
START SLAVE;


步驟 4：驗證同步是否正常
在 Slave 檢查狀態：

SQL
SHOW SLAVE STATUS\G
確認以下兩項是否皆為 Yes：

Slave_IO_Running: Yes

Slave_SQL_Running: Yes

並且可以檢查 Seconds_Behind_Master 是否為 0（或正在追趕），代表 Master 過去的資料與之後即時的異動都能完美同步到 Slave 了！
