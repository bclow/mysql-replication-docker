#!/usr/bin/env bash
#https://sipb.mit.edu/doc/safe-shell/
set -eu -o pipefail
shopt -s failglob

dname=$(dirname $0)

main() {
    local ddir="$1"

    mkdir -p $ddir/data/var/lib/mysql
    #mkdir -p $ddir/data/root 
    #touch $ddir/data/root/.mysql_history
    sudo chown -R 999:999 $ddir/data/
    sudo chmod -R 755 $ddir/data/


}

main $dname/master
main $dname/slave

