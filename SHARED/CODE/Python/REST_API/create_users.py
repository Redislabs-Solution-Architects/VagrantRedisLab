import requests
import getopt
import sys

argumentList = sys.argv[1:]

# Options
options = "h:u:a:"

# Long options
long_options = ["host=", "user=", "password="]

try:
    # Parsing argument
    arguments, values = getopt.getopt(argumentList, options, long_options)
    # checking each argument
    for currentArgument, currentValue in arguments:
        if currentArgument in ("-h", "--host"):
            host = currentValue
            print(("Host: % s") % (currentValue))
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

json_data = [{
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'password': 'redis',
    'role_uids': [
        2,
    ],
}, {
    'name': 'Mike Smith',
    'email': 'mike.smith@example.com',
    'password': 'redis',
    'role_uids': [
        3,
    ],
}, {
    'name': 'Cary Johnson',
    'email': 'cary.johnson@example.com',
    'password': 'redis',
    'role_uids': [
        1,
    ],
}
]

# Email: john.doe@example.com, Name: John Doe, Role: db_viewer
# Email: mike.smith@example.com, Name: Mike Smith, Role: db_member
# Email: cary.johnson@example.com, Name: Cary Johnson, Role: admin

# labuser@load:~/CODE$ ./roles.sh
# [{"management":"none","name":"DB Member","uid":3},{"management":"admin","name":"Admin","uid":1},{"management":"db_viewer","name":"DB Viewer","uid":2}]
# labuser@load:~/CODE$

for pl in json_data:
    response = requests.post(
        'https://' + host + ':9443/v1/users',
        headers=headers,
        json=pl,
        verify=False,
        auth=(user, password),
    )
    print(response.content)


response = requests.get(
    'https://' + host + ':9443/v1/users',
    headers=headers,
    json=pl,
    verify=False,
    auth=(user, password),
)

for out in response.json():
    print(out["name"] + ', ' + out["role"] + ', ' + out["email"])
