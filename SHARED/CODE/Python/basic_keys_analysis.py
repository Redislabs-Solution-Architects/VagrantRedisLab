#!/usr/bin/env python3

# This Python script is a utility for analyzing Redis keys based on certain criteria such as idle time and size.
# Execution results would display the biggest key in terms of size, the key with highes idletime as well as
# a bunch of keys as per input parametes --size and --idletime
# E.g.
# $ python basic_keys_analysis.py -h redis-10001.rc1.example.com -p 10001 -s 400 -m 10
# ----------------------------------------------------------------
# host='redis-10001.rc1.example.com'
# port=10001
# size=400
# idletime=3600
# maxcount=10
# tls=False
# ----------------------------------------------------------------
# max_key_name='key' max_key_size=4144 max_key_type='string'
# oldest_key_name='memtier-6294639' oldest_key_idletime=62678 oldest_key_type='string'
# ----------------------------------------------------------------
# Old keys found:
# memtier-2592512, memtier-643398, memtier-719857, memtier-9300768, memtier-9069551, memtier-3378050, memtier-1045503, memtier-8639055, memtier-9049380, memtier-690350
# ----------------------------------------------------------------
# Big keys found:
# key
# $
import redis
# import time
import getopt
import sys


# Function to analyze redis keys.
def basic_keys_analysis(r, pattern: str = '*', max_idle: int = 3600, max_count: int = 100, max_size: int = 1048576):
    old_keys: list[str] = []
    big_keys: list[str] = []
    cursor = '0'  # this to trick the loop condition.
    max_key_name: str = ''
    max_key_size: int = 0
    max_key_type: str = ''
    oldest_key_name: str = ''
    oldest_key_idletime: int = 0
    oldest_key_type: str = ''
    while cursor != 0:
        cursor, keys = r.scan(cursor, match=pattern)
        for index, key in enumerate(keys):
            idle_time = r.object('idletime', key)
            # Fill array with keys that have been idle for more than max_idle seconds
            if idle_time > max_idle and len(old_keys) < max_count:
                old_keys.append(key)
            # Find the oldest key that has been idle for more than the rest of keys
            if idle_time > oldest_key_idletime:
                oldest_key_name = key
                oldest_key_idletime = idle_time
                oldest_key_type = r.type(key)
            memory_usage = r.memory_usage(key)
            # Fill array with keys that bigger than max_size
            if memory_usage >= max_size and len(big_keys) < max_count:
                big_keys.append(key)
            # Find the key with the highest memory usage
            if memory_usage > max_key_size:
                max_key_name = key
                max_key_size = memory_usage
                max_key_type = r.type(key)
    print(f'{max_key_name=} {max_key_size=} {max_key_type=}')
    print(f'{oldest_key_name=} {oldest_key_idletime=} {oldest_key_type=}')
    return old_keys, big_keys


def print_help() -> None:
    print('Usage:')
    print(f'  redis-key-analyzer.py [-h|--host <host> ] [-p|--port <port>] [-s|--size <size>] '
          f'[-i|--idletime <idletime>] [-t|--tls] [--username <username>] [--password <password>]')
    print('Options:')
    print('  -h, --host         host of the redis server (required)')
    print('  -p, --port         port of the redis server (default: 6379)')
    print('  -s, --size         size to scan (default: 1048576 bytes)')
    print('  -i, --idletime     idletime threshold in seconds (default: 3600s)')
    print('  -m, --maxcount     maxcount (default: 100)')
    print('  -t, --tls          use TLS connection')
    print('  --username         username for the redis server')
    print('  --password         password for the redis server')


if __name__ == '__main__':
    argumentList = sys.argv[1:]
    try:
        # Parsing argument
        arguments, values = getopt.getopt(argumentList, "h:p:s:i:m:t:u:w", [
                                          "help", "host=", "port=", "size=", "idletime=", "maxcount=", "tls", "username=", "password="])
        # defaults
        host: str = None
        port: int = 6379
        # size:list[int] = [1048576]
        size: int = 1048576
        idletime: int = 3600
        maxcount: int = 100
        tls: bool = False
        username: str = None
        password: str = None
        # checking each argument
        for currentArgument, currentValue in arguments:
            if currentArgument in ("-h", "--host"):
                host = currentValue
            elif currentArgument in ("-p", "--port"):
                port = int(currentValue)
            elif currentArgument in ("-s", "--size"):
                # size = [int(x) for x in currentValue.split(",")]
                size = int(currentValue)
            elif currentArgument in ("-i", "--idletime"):
                idletime = int(currentValue)
            elif currentArgument in ("-m", "--maxcount"):
                maxcount = int(currentValue)
            elif currentArgument in ("-t", "--tls"):
                tls = True
            elif currentArgument in ("-u", "--username"):
                username = currentValue
            elif currentArgument in ("-w", "--password"):
                password = currentValue
            elif currentArgument in ("-t", "--tls"):
                tls = True
            elif currentArgument == '--help':
                print_help()
                sys.exit(0)

        if host is None:
            print("Error: Host is required option")
            print_help()
            sys.exit(1)

        print('----------------------------------------------------------------')
        print(f'{host=}')
        print(f'{port=}')
        print(f'{size=}')
        print(f'{idletime=}')
        print(f'{maxcount=}')
        print(f'{tls=}')
        print('----------------------------------------------------------------')

    except getopt.GetoptError:
        print_help()
        sys.exit(2)

    # Establishing a Redis connection
    try:
        r = redis.Redis(host=host, port=port, username=username,
                        password=password, ssl=tls, decode_responses=True)
        r.ping()
    except Exception as e:
        print(f"Failed to connect to Redis: {e}")
        sys.exit(1)

    # Analyzing the Redis database for old and big keys
    old_keys, big_keys = basic_keys_analysis(
        r, pattern='*', max_idle=idletime, max_count=maxcount, max_size=size)
    # print(old_keys)
    if old_keys:
        print('----------------------------------------------------------------')
        print("Old keys found:")
        print(", ".join(map(str, old_keys)))
    else:
        print(f'No keys found bigger or equal to {idletime=}.')
    if big_keys:
        print('----------------------------------------------------------------')
        print("Big keys found:")
        print(", ".join(map(str, big_keys)))
    else:
        print(f'No keys found bigger or equal to {size=}.')
