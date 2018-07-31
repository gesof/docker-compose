#!/bin/bash


function deploy_to_host() {
    DOCKERHOST=$1

    echo ""
    echo "================= Processing host ${DOCKERHOST}"
    #read -rsp $'Press any key to continue...\n' -n1 key

    echo "Stop docker:"
    ssh -f root@$DOCKERHOST 'cd /home/checkemail/docker-compose; sudo -u checkemail docker-compose down'

    echo "Update docker from GIT"
    ssh -f root@$DOCKERHOST 'su checkemail; cd /home/checkemail/docker-compose; git fetch --all; git reset --hard origin/master' 2>&1
    #read -rsp $'Press any key to continue...\n' -n1 key

    echo "Copy environment vars"
    scp web-variables.env root@$DOCKERHOST:/home/checkemail/docker-compose/
    #read -rsp $'Press any key to continue...\n' -n1 key

    echo "Copy entrypoint script"
    scp entrypoint.sh root@$DOCKERHOST:/home/checkemail/docker-compose/
    #read -rsp $'Press any key to continue...\n' -n1 key

    echo "Update PHP sources:"
    ssh -f root@$DOCKERHOST 'cd /home/checkemail; sudo -u checkemail hg pull; sudo -u checkemail hg update'
    #read -rsp $'Press any key to continue...\n' -n1 key

    echo "Update docker images"
    ssh -f root@$DOCKERHOST 'docker pull iordachej/php:7.2-fpm-alpine3.7-sf4'
    #read -rsp $'Press any key to continue...\n' -n1 key

    echo "Run docker:"
    ssh -f root@$DOCKERHOST 'cd /home/checkemail/docker-compose; sudo -u checkemail docker-compose up -d'
    #read -rsp $'Press any key to FINISH...\n' -n1 key
}


while IFS='' read -r line || [[ -n "$line" ]]; do
    #echo "Text read from file: $line"
    [ -z "$line" ] && continue
    deploy_to_host $line
    #read -rsp $'Press any key to continue...\n' -n1 key
done < "$1"