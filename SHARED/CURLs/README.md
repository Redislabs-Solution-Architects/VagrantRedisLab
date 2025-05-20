# CURL library

Edit
```
redis-CURL-vars.sh
```
and fill in the variables for your Redis cluster.

Run
``` 
source ./set_ENV.sh
```
to set up the environment. If not set, then it uses default values from
```
/root/redis-env-vars.sh.
```
If nescessary, scripts display input variables required to run them.
```
[root@rc1-rh8-node1 CURLs]# ./curl_v1-nodes_ID.sh
Execution is: ./curl_v1-nodes_ID.sh <ID>
[root@rc1-rh8-node1 CURLs]#
```
Scripts with "Enter_ID" are interactive, E.g.:
```
[root@rc1-rh8-node1 CURLs]# ./curl_v1-bdbs_DELETE-Enter_ID.sh
Existing databases:
Sourcing configured: /root/SHARED/CURLs/redis-CURL-vars.sh
 . . Executing: curl -o ./curl_v1-bdbs_list_uids.sh.json -s -k -u redis@redis.com:redis -X GET -H 'Accept: application/json' https://rc1.example.com:9443/v1/bdbs
{
  "bdb_uid": 2,
  "name": "TestM"
}
{
  "bdb_uid": 1,
  "name": "Test"
}
Enter UID to delete BDB (Ctrl+c to exit): 2
Deleting DB 2...
Sourcing configured: /root/SHARED/CURLs/redis-CURL-vars.sh
 . . Executing: curl -o ./curl_v1-bdbs_DELETE_ID.sh.json -s -k -u redis@redis.com:redis -X DELETE https://rc1.example.com:9443/v1/bdbs/2
{
  "acl": [],
  "action_uid": "5a42fabf-c603-4950-88d9-3a3148a5d763",
  "aof_policy": "appendfsync-every-sec",
  "authentication_admin_pass": "Abxjgs2l6gtiG0J1Yx3LJYs1Wj6kBEpr1vpy6iUQSabp4lMW",
  "authentication_redis_pass": "",
  "authentication_sasl_pass": "",
  "authentication_sasl_uname": "",
  "authentication_ssl_client_certs": [],
  "authentication_ssl_crdt_certs": [],
  "authorized_subjects": [],
  "auto_upgrade": false,
  "background_op": [
    {
      "name": "SMDeleteBDB",
      "progress": 0,
      "status": "pending"
    }
  ],
...
...
  "syncer_log_level": "info",
  "syncer_mode": "distributed",
  "throughput_ingress": 0,
  "tls_mode": "disabled",
  "topology_epoch": 1,
  "tracking_table_max_keys": 1000000,
  "type": "redis",
  "uid": 2,
  "version": "7.4.0",
  "wait_command": true
}
 . . Waiting to complete action: action_uid
{"action_uid":"5a42fabf-c603-4950-88d9-3a3148a5d763","heartbeat":1747780298,"name":"SMDeleteBDB","object_name":"bdb:2","pending_ops":{},"progress":14.29,"state":"config_security","status":"active"}
 . . Waiting to complete action: action_uid
{"description":"Action 5a42fabf-c603-4950-88d9-3a3148a5d763 does not exist","error_code":"action_not_found"}
Existing databases:
Sourcing configured: /root/SHARED/CURLs/redis-CURL-vars.sh
 . . Executing: curl -o ./curl_v1-bdbs_list_uids.sh.json -s -k -u redis@redis.com:redis -X GET -H 'Accept: application/json' https://rc1.example.com:9443/v1/bdbs
{
  "bdb_uid": 1,
  "name": "Test"
}
Enter UID to delete BDB (Ctrl+c to exit):
[root@rc1-rh8-node1 CURLs]#
```




