#!/usr/bin/env bash
#https://sipb.mit.edu/doc/safe-shell/
set -eu -o pipefail
shopt -s failglob

dname=$(dirname $0)

main() {
    set -a
    [ -f .env ] && . .env
    set +a

    local container_name=$(echo $(grep container_name  $dname/docker-compose.yml | cut -d : -f 2))
    local root_pass_var=$(echo $(grep MYSQL_ROOT_PASSWORD $dname/docker-compose.yml | cut -d : -f 2))
    root_pass_var="${root_pass_var#\$}"

    local root_pass=${!root_pass_var}
    local optit="-T "
    if test -t 0
    then
        # 是terminal
        optit="-it "
    fi
   
    # 執行進入容器
    docker compose -f $dname/docker-compose.yml exec $optit -e MYSQL_PWD=$root_pass $container_name mysql -u root  "$@"
}

main "$@"
