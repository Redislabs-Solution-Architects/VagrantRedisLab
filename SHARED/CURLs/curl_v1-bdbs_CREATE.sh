#!/bin/bash

test "$1" = '' && echo "Execution is: ./$0 <DB-NAME> <DB_PORT>"
test "$1" = '' && exit 1
test "$2" = '' && echo "Execution is: ./$0 <DB-NAME> <DB_PORT>"
test "$2" = '' && exit 1

source /root/redis-env-vars.sh

DB_NAME="$1"
DB_PORT="$2"
MEMORY_SIZE=1073741824  # Size in bytes (e.g., 1GB)

DB_PARAMS='{ "name": "'"${DB_NAME}"'",
  "port": '${DB_PORT}',
  "memory_size": '"${MEMORY_SIZE}"',
  "replication": true,
  "data_persistence": "aof",
  "aof_policy": "appendfsync-every-sec",
  "sharding": true,
  "shard_key_regex": [
    {
      "regex": ".*\\{(?<tag>.*)\\}.*"
    },
    {
      "regex": "(?<tag>.*)"
    }
  ],
  "shards_count": 2
}'

CURL="curl -o $0.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '$DB_PARAMS' https://$REDIS_cluster_fqdn:9443/v1/bdbs"

echo " . . Executing: $CURL"
bash -c "$CURL"
cat $0.json | jq

exit 0

# The below may vary based on the Redis REST API.
{
  "acl": [],
  "aof_policy": "appendfsync-every-sec",
  "authentication_admin_pass": "9lBcOiuGSmLx6bAcY9ms2LM8fCX57ReMK2YYHAyKUcoQZgV9",
  "authentication_redis_pass": "",
  "authentication_sasl_pass": "",
  "authentication_sasl_uname": "",
  "authentication_ssl_client_certs": [],
  "authentication_ssl_crdt_certs": [],
  "authorized_subjects": [],
  "auto_upgrade": false,
  "background_op": [
    {
      "status": "idle"
    }
  ],
  "backup": false,
  "backup_failure_reason": "",
  "backup_history": 0,
  "backup_interval": 0,
  "backup_interval_offset": 0,
  "backup_progress": 0.0,
  "backup_status": "",
  "bigstore": false,
  "bigstore_ram_size": 0,
  "client_cert_subject_validation_type": "disabled",
  "conns": 5,
  "conns_type": "per-thread",
  "crdt": false,
  "crdt_causal_consistency": false,
  "crdt_config_version": 0,
  "crdt_ghost_replica_ids": "",
  "crdt_guid": "",
  "crdt_modules": "[]",
  "crdt_repl_backlog_size": "auto",
  "crdt_replica_id": 0,
  "crdt_replicas": "",
  "crdt_sources": [],
  "crdt_sync": "disabled",
  "crdt_sync_connection_alarm_timeout_seconds": 0,
  "crdt_sync_dist": true,
  "crdt_syncer_auto_oom_unlatch": true,
  "crdt_xadd_id_uniqueness_mode": "strict",
  "created_time": "2025-02-27T18:08:04Z",
  "data_internode_encryption": false,
  "data_persistence": "aof",
  "dataset_import_sources": [],
  "db_conns_auditing": false,
  "default_user": true,
  "dns_address_master": "",
  "dns_suffixes": [],
  "email_alerts": false,
  "endpoints": [
    {
      "addr": [
        "192.168.69.102"
      ],
      "addr_type": "external",
      "dns_name": "redis-10002.rc1.example.com",
      "oss_cluster_api_preferred_endpoint_type": "ip",
      "oss_cluster_api_preferred_ip_type": "internal",
      "port": 10002,
      "proxy_policy": "single",
      "uid": "1:1"
    }
  ],
  "enforce_client_authentication": "disabled",
  "eviction_policy": "volatile-lru",
  "flush_on_fullsync": true,
  "generate_text_monitor": false,
  "gradual_src_max_sources": 1,
  "gradual_src_mode": "disabled",
  "gradual_sync_max_shards_per_source": 1,
  "gradual_sync_mode": "auto",
  "group_uid": 0,
  "hash_slots_policy": "16k",
  "implicit_shard_key": false,
  "import_failure_reason": "",
  "import_progress": 0.0,
  "import_status": "",
  "internal": false,
  "last_changed_time": "2025-02-27T18:08:04Z",
  "master_persistence": false,
  "max_aof_file_size": 322122547200,
  "max_aof_load_time": 3600,
  "max_client_pipeline": 200,
  "max_connections": 0,
  "max_pipelined": 2000,
  "memory_size": 107374182,
  "metrics_export_all": false,
  "mkms": true,
  "module_list": [],
  "mtls_allow_outdated_certs": false,
  "mtls_allow_weak_hashing": false,
  "name": "test2",
  "oss_cluster": false,
  "oss_cluster_api_preferred_endpoint_type": "ip",
  "oss_cluster_api_preferred_ip_type": "internal",
  "oss_sharding": false,
  "port": 10002,
  "proxy_policy": "single",
  "rack_aware": false,
  "recovery_wait_time": -1,
  "redis_cluster_enabled": false,
  "redis_version": "7.4",
  "repl_backlog_size": "auto",
  "replica_sources": [],
  "replica_sync": "disabled",
  "replica_sync_connection_alarm_timeout_seconds": 0,
  "replica_sync_dist": true,
  "replication": false,
  "resp3": true,
  "roles_permissions": [],
  "sched_policy": "cmp",
  "shard_block_crossslot_keys": false,
  "shard_block_foreign_keys": true,
  "shard_key_regex": [
    {
      "regex": ".*\\{(?<tag>.*)\\}.*"
    },
    {
      "regex": "(?<tag>.*)"
    }
  ],
  "shard_list": [
    1,
    2
  ],
  "sharding": true,
  "shards_count": 2,
  "shards_placement": "dense",
  "skip_import_analyze": "disabled",
  "slave_buffer": "auto",
  "slave_ha": false,
  "slave_ha_priority": 0,
  "snapshot_policy": [],
  "ssl": false,
  "status": "active",
  "support_syncer_reconf": true,
  "sync": "disabled",
  "sync_dedicated_threads": 5,
  "sync_sources": [],
  "syncer_log_level": "info",
  "syncer_mode": "distributed",
  "tags": [],
  "throughput_ingress": 0,
  "tls_mode": "disabled",
  "topology_epoch": 2,
  "tracking_table_max_keys": 1000000,
  "type": "redis",
  "uid": 1,
  "version": "7.4.0",
  "wait_command": true
}