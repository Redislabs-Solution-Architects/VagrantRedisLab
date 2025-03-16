import redis
import time


def find_old_keys(r, pattern='*', max_idle=10):
    """
    Finds keys in Redis that have been idle for longer than max_idle seconds.

    Args:
        r: Redis connection object.
        pattern: Glob-style pattern to filter keys.
        max_idle: Maximum idle time in seconds.

    Returns:
        A list of old keys.
    """
    old_keys = []
    cursor = '0'
    while cursor != 0:
        cursor, keys = r.scan(cursor, match=pattern)
        for key in keys:
            idle_time = r.object('idletime', key)
            memory_usage = r.memory_usage(key)
            print(memory_usage)
            type = r.type(key)
            print(type.decode('utf-8'))
            if idle_time > max_idle:
                old_keys.append(key)
    return old_keys


if __name__ == '__main__':
    r = redis.Redis(host='redis-10001.rc1.example.com', port=10001, db=0)
    max_idle_time = 1  # seconds

    # Example: Find keys with "user" in their name that are older than max_idle_time
    old_user_keys = find_old_keys(r, pattern='*', max_idle=max_idle_time)
    if old_user_keys:
        print("Old keys found:")
        for key in old_user_keys:
            print(f"- {key.decode('utf-8')}")
    else:
        print("No old keys found.")
