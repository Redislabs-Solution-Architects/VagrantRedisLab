#!/bin/bash

while true; do
    echo "Existing databases:"
    ./curl_v1-crdbs_list_guids.sh

    read -p "Enter GUID to delete BDB (Ctrl+c to exit): " DEL_GUID

    echo "Deleting DB $DEL_GUID..."
    ./curl_v1-crdbs_DELETE_GUID.sh $DEL_GUID
done
