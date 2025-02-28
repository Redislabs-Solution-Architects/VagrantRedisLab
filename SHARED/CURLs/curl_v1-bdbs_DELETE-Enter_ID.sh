#!/bin/bash

while true; do
    echo "Existing databases:"
    ./curl_v1-bdbs_list_uids.sh

    read -p "Enter UID to delete BDB (Ctrl+c to exit): " DEL_UID

    echo "Deleting DB $DEL_UID..."
    ./curl_v1-bdbs_DELETE_ID.sh $DEL_UID
done