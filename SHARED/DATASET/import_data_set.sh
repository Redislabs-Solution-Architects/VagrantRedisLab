#!/bin/bash

# Create 2 DBs without and with Search/JSON modules

test "$1" = '' && echo "Execution is: $0 FQDN PORT"
test "$1" = '' && exit 1
test "$2" = '' && echo "Execution is: $0 FQDN PORT"
test "$2" = '' && exit 1

# To avoid RATE LIMITER
IP=$(dig +short $1)

for f in import_movies.redis import_theaters.redis import_users.redis; do
    file_out="./load_data.redis"
    cat /dev/null >$file_out
    file="./$f"
    echo "Working on: $f"
    array_name=("/" "-" "\\" "|")
    while read -r line; do
        echo redis-cli -h $IP -p $2 $line >>$file_out
        #    sleep 2
        i=$((++i % 4))
        printf "${array_name[$i]}"
        printf "\b"
    done <"$file"

    while read -r line; do
        bash -c "$line" >/dev/null || exit 1
        i=$((++i % 4))
        printf "${array_name[$i]}"
        printf "\b"
    done <"$file_out"

done

rm -f ./$file_out
