import requests
import getopt
import sys

argumentList = sys.argv[1:]

# Options
options = "h:i:u:a:"

# Long options
long_options = ["host=", "id=", "user=","password="]

try:
    # Parsing argument
    arguments, values = getopt.getopt(argumentList, options, long_options)
    # checking each argument
    for currentArgument, currentValue in arguments:
        if currentArgument in ("-h", "--host"):
            host = currentValue
            print(("Host: % s") % (currentValue))
        elif currentArgument in ("-i", "--id"):
            id = currentValue
            print(("Id: % s") % (id))
        elif currentArgument in ("-u", "--user"):
            user = currentValue
            print(("User: % s") % (user))
        elif currentArgument in ("-a", "--password"):
            password = currentValue
            print(("Password: % s") % (password))
except getopt.error as err:
    # output error, and return with an error code
    print(str(err))

response = requests.delete(
    'https://' + host + ':9443/v1/bdbs/' + id,
    verify=False,
    auth=(user, password),
)

print(response.content)
