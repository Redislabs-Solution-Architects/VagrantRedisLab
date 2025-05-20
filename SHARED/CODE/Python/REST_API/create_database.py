import requests
import getopt
import sys

argumentList = sys.argv[1:]

# Options
options = "h:n:p:u:a:"

# Long options
long_options = ["host=", "name=", "port=","user=","password="]

try:
    # Parsing argument
    arguments, values = getopt.getopt(argumentList, options, long_options)
    # checking each argument
    for currentArgument, currentValue in arguments:
        if currentArgument in ("-h", "--host"):
            host = currentValue
            print(("Host: % s") % (currentValue))
        elif currentArgument in ("-n", "--name"):
            name = currentValue
            print(("Name: % s") % (name))
        elif currentArgument in ("-p", "--port"):
            port = currentValue
            print(("Port: % s") % (port))
        elif currentArgument in ("-u", "--user"):
            user = currentValue
            print(("User: % s") % (user))
        elif currentArgument in ("-a", "--password"):
            password = currentValue
            print(("Password: % s") % (password))
except getopt.error as err:
    # output error, and return with an error code
    print(str(err))


headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
}

json_data = {
    'name': name,
    'port': int(port),
    'memory_size': 1073741824,
    'replication': True,
    'data_persistence': 'aof',
    'aof_policy': 'appendfsync-every-sec',
    'sharding': True,
    'shard_key_regex': [
        {
            'regex': '.*\\{(?<tag>.*)\\}.*',
        },
        {
            'regex': '(?<tag>.*)',
        },
    ],
    'shards_count': 1,
}

print(json_data)


response = requests.post(
    'https://' + host + ':9443/v1/bdbs',
    headers=headers,
    json=json_data,
    verify=False,
    auth=(user, password),
)

print(response.content)
