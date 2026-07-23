#!/usr/bin/env bash
#https://sipb.mit.edu/doc/safe-shell/
set -eu -o pipefail
shopt -s failglob

dname=$(dirname $0)

main() {
    set -a
    [ -f .env ] && . .env
    set +a

    local hostip="$1"
    local port="$2"
    local logfile="$3"
    local logpos="$4"

    sqlcmd="
       CHANGE MASTER TO MASTER_HOST='$hostip', MASTER_PORT=$port, MASTER_USER='$REPL_USER', MASTER_PASSWORD='$REPL_PASS', MASTER_LOG_FILE='$logfile', MASTER_LOG_POS=$logpos;
       -- 啟動 Slave
       START SLAVE;

       SHOW SLAVE STATUS\G
    "
    echo "$sqlcmd" | $dname/my.sh
}


main "$@"
