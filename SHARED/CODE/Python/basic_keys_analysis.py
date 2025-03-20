import redis
import time
import getopt
import sys


def basic_keys_analysis(r, pattern='*', max_idle=10):
    old_keys = []
    cursor = '0'
    while cursor != 0:
        cursor, keys = r.scan(cursor, match=pattern)
        for key in keys:
            idle_time = r.object('idletime', key)
            if idle_time > max_idle:
                old_keys.append(key)
                memory_usage = r.memory_usage(key)
                print(memory_usage)
                type = r.type(key)
                print(type.decode('utf-8'))
    return old_keys


if __name__ == '__main__':

    argumentList = sys.argv[1:]

    # Options
    options = "h:si:"

    # Long options
    long_options = ["host=", "size", "idletime"]

    try:
        # Parsing argument
        arguments, values = getopt.getopt(argumentList, options, long_options)
        # checking each argument
        for currentArgument, currentValue in arguments:
            if currentArgument in ("-h", "--host"):
                print(("Host (% s)") % (currentValue))
            elif currentArgument in ("-i", "--idletime"):
                print("Displaying file_name:", sys.argv[0])
            elif currentArgument in ("-o", "--utput"):
                print(("Enabling special output mode (% s)") % (currentValue))
    except getopt.error as err:
        # output error, and return with an error code
        print(str(err))

    r = redis.Redis(host='redis-10001.rc1.example.com', port=10001)
#    r = redis.Redis.from_url(url="redis://default:admin@localhost:6379/0")
#    print(r.ping())

    max_idle_time = 10000  # seconds

    # Example: Find keys with "user" in their name that are older than max_idle_time
    old_user_keys = basic_keys_analysis(r, pattern='*', max_idle=max_idle_time)
    if old_user_keys:
        print("Old keys found:")
        for key in old_user_keys:
            print(f"- {key.decode('utf-8')}")
    else:
        print("No old keys found.")
