#!/bin/bash

echo "Existing databases:"
./curl_v1-bdbs_list_uids.sh

read -p "Enter UID to delete BDB: " DEL_UID

echo "Deleting DB $DEL_UID..."
./curl_v1-bdbs_DELETE_ID.sh $DEL_UID

echo "Existing databases after deletion:"
./curl_v1-bdbs_list_uids.sh