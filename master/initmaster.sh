#!/usr/bin/env bash
#https://sipb.mit.edu/doc/safe-shell/
set -eu -o pipefail
shopt -s failglob

dname=$(dirname $0)

main() {
    set -a
    [ -f .env ] && . .env
    set +a

    sqlcmd="
    CREATE USER '$REPL_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$REPL_PASS';
    GRANT REPLICATION SLAVE ON *.* TO '$REPL_USER'@'%';
    FLUSH PRIVILEGES;
    SHOW MASTER STATUS;
    "

    echo "$sqlcmd" | $dname/my.sh
}


main "$@"
