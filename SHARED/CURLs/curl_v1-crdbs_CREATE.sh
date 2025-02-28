#!/bin/bash

test "$1" = '' && echo "Execution is: ./$0 <DB-NAME> <DB_PORT>"
test "$1" = '' && exit 1
test "$2" = '' && echo "Execution is: ./$0 <DB-NAME> <DB_PORT>"
test "$2" = '' && exit 1

source /root/redis-env-vars.sh

DB_NAME="$1"
DB_PORT="$2"
MEMORY_SIZE=1073741824  # Size in bytes (e.g., 1GB)

DB_PARAMS='{
    "default_db_config": {
        "name": "'$DB_NAME'",
        "port": '$DB_PORT',
        "memory_size": 1073741824,
        "replication": true,
        "data_persistence": "aof",
        "aof_policy": "appendfsync-every-sec",
        "shards_count": 2,
        "sharding": true,
        "shard_key_regex": [
          {
          "regex": ".*\\{(?<tag>.*)\\}.*"
          },
          {
          "regex": "(?<tag>.*)"
          }
        ]
    },
    "encryption": true,
    "instances": [
        {
            "cluster": {
                "url": "https://'$REDIS_cluster_fqdn':9443",
                "credentials": {
                    "username": "'$REDIS_cluster_admin'",
                    "password": "'$REDIS_cluster_password'"
                },
                "name": "'$REDIS_cluster_fqdn'"
            },
            "compression": 6
        },
        {
            "cluster": {
                "url": "https://rc2.example.com:9443",
                "credentials": {
                    "username": "'$REDIS_cluster_admin'",
                    "password": "'$REDIS_cluster_password'"
                },
                "name": "rc2.example.com"
            },
            "compression": 6
        }
    ],
    "name": "'$DB_NAME'"
}'

CURL="curl -o $0.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '$DB_PARAMS' https://$REDIS_cluster_fqdn:9443/v1/crdbs"

echo " . . Executing: $CURL"
bash -c "$CURL"
cat $0.json | jq

exit 0

# The below may vary based on the Redis REST API.

{
      "causal_consistency": false,
      "default_db_config": {
        "aof_policy": "appendfsync-every-sec",
        "data_persistence": "aof",
        "memory_size": 1073741824,
        "name": "crdb",
        "port": 10001,
        "replication": true,
        "shard_key_regex": [
          {
            "regex": ".*\\{(?<tag>.*)\\}.*"
          },
          {
            "regex": "(?<tag>.*)"
          }
        ],
        "sharding": true,
        "shards_count": 2,
        "tls_mode": "replica_ssl"
      },
      "encryption": true,
      "featureset_version": 8,
      "ghost_instance_ids": [],
      "guid": "cedf9f4f-6a59-4c2f-8698-06ebebed9604",
      "instances": [
        {
          "client_cert": "",
          "client_key": "",
          "cluster": {
            "credentials": {
              "password": "",
              "username": "redis@redis.com"
            },
            "name": "rc1.example.com",
            "url": "https://rc1.example.com:9443"
          },
          "compression": 6,
          "db_config": {
            "authentication_admin_pass": "3Zr3eKdEjjFcy1YXYZANiGYF2wue2ZmT39MA6sTEvmMB874X"
          },
          "db_uid": "1",
          "id": 1,
          "server_cert": "-----BEGIN CERTIFICATE-----\nMIIFcTCCA1mgAwIBAgIBATANBgkqhkiG9w0BAQsFADBTMRgwFgYDVQQDDA9yYzEu\nZXhhbXBsZS5jb20xEDAOBgNVBAsMB3JlZGlzZGIxJTAjBgNVBAoMHFJlZGlzTGFi\ncyBFbnRlcnByaXNlIENsdXN0ZXIwHhcNMjUwMjI4MTcwNjU3WhcNMjYwMjI4MTcw\nNjU3WjBTMRgwFgYDVQQDDA9yYzEuZXhhbXBsZS5jb20xEDAOBgNVBAsMB3JlZGlz\nZGIxJTAjBgNVBAoMHFJlZGlzTGFicyBFbnRlcnByaXNlIENsdXN0ZXIwggIiMA0G\nCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC5kUQaSEUK1+s3lyJ6RurZjve3Cpp/\nfedndqFuKZzTfpZ3dVafUXp9JtmhMl59b99GByJrXOYxEjjqBt+2IjiLcm1uAkIS\nF1i1wM+zABKF7/H1RUumJulZMhVsSr8nFBhj4l1CMsWmr2w5PtpcA9jUO++DLHAD\n4ymOEWgrBknz6Zqu8Fi0ivACXNLXj59FOcYK4Ppz7ukz+LGtg18/0BHzd2tNp2fd\n61ucoN3lw0QV/2at4MH4+SodEZh9kI8BDywa/mDeKgpEdQqJ2xu+8/cav7d5ce6R\nuUASqJz/0KLoDcXFiJkFDKu3qeeftD4Ids/T+JjeYXTXPFuBcpOiCP1hDYACZI5y\nAsNOJNHedaSysMI/LsVSu75+jRyqp28dhNRb4n5b2rKq+7q+40NWc89Ub7lfpPbj\nNfKpseZuZkAaPC5vDU7ccX+7R/wk0mqc8xzgUvHwFv2MuMvbA9jzwuPLUkVT6Sop\n9GsMJJCoCwPqYN+diOTFSvxrsOcewEAAvrsoMKfUSeeOYCH/f2dnasdlCVV9gSXG\n5mJ3LZF/ZWrBsmhkR+YqBHVKfbJJ9G2IqNswbTVX2kWBsUmzYHQzYUotqMP1nSN7\nvblirMLEycPly0LSWH00PHvaIE60drvGsWsNXBHB2lbL1FqGKOsVzbFxJeYajg6G\niT+DZEYp9n7QvQIDAQABo1AwTjAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUH\nAwIwLQYDVR0RBCYwJIIPcmMxLmV4YW1wbGUuY29tghEqLnJjMS5leGFtcGxlLmNv\nbTANBgkqhkiG9w0BAQsFAAOCAgEAsymOnPlrLtymu3c4gXq03nIMjyRAd870nUk9\niwjZyO+2pIlcs25YyMhfEelaEjk739QWb8qkzDIFXUHq7Z53373I4I+7PajZYOxG\nzG6FXE3pwEbLAs88UgIj2TtWZMjirEaaczJONvPnXdrnB6b0S2+vyQ9pL4zKEyQx\nnNtxBiHBkqE8899zUYrYWr/+xvynFYLn+cDyjraS26Z0FRok1WD2Hbh/uGyhvnW6\nKfdZs0Onm8oHJxa8nPihOLnM9pxvuJI3pltlUAcSlLSXX+5qYDpb5u1LTkiQB5Yl\nitZzqLQnvjGrmbol+Ppy/IHjglRJJjOrtk6JpPxt1sedDfvnzsvVgA6jZ2OPafi/\noYT8CG0hrNrY6JbEELYHdr5Vm3RTbW6OkWONxOYvDXedjfVgaTYzn0mhnsOiq1Ap\ncr/fPY50YTP3KGvedeM1To1ntCGypoe4j4J2q8YMCD6vEMMNU6ULipkln3PCKtCx\njP1ti5JUkpoGdZqPRj3SkLXgCDEaOC+Ej3lef/PuCufn0vXosJLA57aU5ie1A+4X\nkbw6k8NEXpIwKYeTa8hpOzkeXBGbd6Gv4XI8JnbVNBRTTN9WWsTkBjWzGede/emi\nDATij5HCqcwXeO4GG/PyMnP9LK696EUDeMGZVdGDTMiXJPustsAWxjE1YNcNY8pT\n6gi+16Q=\n-----END CERTIFICATE-----\n"
        },
        {
          "client_cert": "",
          "client_key": "",
          "cluster": {
            "credentials": {
              "password": "",
              "username": "redis@redis.com"
            },
            "name": "rc2.example.com",
            "url": "https://rc2.example.com:9443"
          },
          "compression": 6,
          "db_config": {
            "authentication_admin_pass": "xMhf1wVRJ4zZdlr0YuMw9nenAnJztHhpaaprnlpOiboM1rr4"
          },
          "id": 2,
          "server_cert": "-----BEGIN CERTIFICATE-----\nMIIFcTCCA1mgAwIBAgIBATANBgkqhkiG9w0BAQsFADBTMRgwFgYDVQQDDA9yYzIu\nZXhhbXBsZS5jb20xEDAOBgNVBAsMB3JlZGlzZGIxJTAjBgNVBAoMHFJlZGlzTGFi\ncyBFbnRlcnByaXNlIENsdXN0ZXIwHhcNMjUwMjI4MDA0ODQ5WhcNMjYwMjI4MDA0\nODQ5WjBTMRgwFgYDVQQDDA9yYzIuZXhhbXBsZS5jb20xEDAOBgNVBAsMB3JlZGlz\nZGIxJTAjBgNVBAoMHFJlZGlzTGFicyBFbnRlcnByaXNlIENsdXN0ZXIwggIiMA0G\nCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC1bSQfA4/k02pSEVmBa4dy7ItDEkQn\nxGpKnuoVPUrJOzoQJLwzgmiOY4+eqhisLB5xA+TiRyS1Bsf/wZj7ypiNET/QHbr3\nUgk2UjYFK0lxaYB35EPOQAuuWmof45pVjIAesYnK+KgJzyKhwlXCzYkHugEDAHQT\nr7j6t+dQyopXl8laLNMgycwzF3AvtqbgiR5zcyM5NlJaL/vnk3ArEHiXM+Sthh+N\nvpmZ8qI7CbvzwKXsaxhU5C+rB+D7/K6vr5PcAZDKP1Ia80SEPPEg7nmMFG6dtI5e\nHcvuI+paghbYbFvvWnyEA0+nWs59Sn0H30IDpGm2nnr+V8HzzbXQzUPPAP5MjgL3\nrSKAH8GeONH+S6Ooiye2D/Q5BuXWsSkJkzG9/h700wZ3yrItbkNUa142VspQb/7K\nJ9Z49bv0pUn9y+55YAdVFdzMEq5NIn9papl3r8jIjxn/G3URS7eM/PVvK44c4LBd\neqV0vBO2RaRKnvN+e/o81B4Jy4TABtqb5rDO8yYcacR/QppQiOnzfAVjqSGbHYCy\nd3N9aWKLCeLRK/SSzDgAhxFhhF655F/Qoa9CgtxoiQP0NjQgJkVxBkbs71BvT+6y\nL4Nc00rsycyBq0/wlMZfqI0qk9dcdVSmQXPX4fMn+4UU6MBg9WQi2Pbrgpp3jdBS\nLEKSbwrSJbhmSwIDAQABo1AwTjAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUH\nAwIwLQYDVR0RBCYwJIIPcmMyLmV4YW1wbGUuY29tghEqLnJjMi5leGFtcGxlLmNv\nbTANBgkqhkiG9w0BAQsFAAOCAgEAtOETiW7LSi/ih3y8hEZMM3ixD9qoVMTKW59/\nfjU6XQCWtPPg9Id30eNDhEzf8RYy5NxX99MNnwTq1wrqzgw/d1SwED6+mRuug+Ib\nv9WcamMXvgFs+C1yDDh7QPtfRtiu48j8cQ958J85nU72z+P30ZfsXbLQswW2Ac2D\nhraSC9BaVWpbIHc6OUpHfJI2u9TTRiMfeInG8S73p6aecQDM6GihAweK8eGFDobx\nvUDXWc8PsbkvNbd40RDuVa1VMJ1Yr31yhLg12JB3yflt1ga/87qb+q4iF3UuHqDW\n23Mpsc3WdVnsrCcWeJen1pQhQcYAT+PGif5pks2Eqzn0YMu/ylbZwFJt0XjwgO8R\nT+uX602K9dRVd5ObELPATqMdh6Czn0bssxkpi9uDLSd1eD6+SdRzXsdwvscZD65n\nRE84zQoYiZwPhubsB6S6Tjg6Bn2j6rtZPIXFKNBpZ0NiTaNBDCKraMGVn3+Ap3Hq\nUymMVJwOncurfhq9jd8Yiuzs8juiv9Ufngd0xcccZT4UrDPLknLvRCucAkzVJaWh\n4JjkI1GwVqhcRGash7Um5CVWaMBC+k/cMyw1cjRd0mgCRo0Xcx77prnP0XXspgMx\nvIajafqMglo7SkDbtqoQbGjNBGlbwrTxOSfUCacy4AnHAeEavQCsuyy7AdpSNWac\n4acJZkA=\n-----END CERTIFICATE-----\n"
        }
      ],
      "local_databases": [
        {
          "bdb_uid": "1",
          "id": 1
        }
      ],
      "managed_by": "",
      "modules": [],
      "name": "crdb",
      "protocol_version": 1
    }
