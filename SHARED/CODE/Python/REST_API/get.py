import requests
import json

# Set the API endpoint URL
url = "https://rc1.example.com:9443/v1/bdbs"
username = 'redis@redis.com'
password = 'redis'

try:
    # Send a GET request to the API endpoint
    response = requests.get(url, verify=False,auth=(username, password))

    # Check if the request was successful
    if response.status_code == 200:
        # Parse the JSON response
        data = json.loads(response.text)
        print(json.dumps(data, indent=4))
    else:
        print(f"Error: {response.status_code}")
except requests.exceptions.RequestException as e:
    print(f"Request error: {e}")