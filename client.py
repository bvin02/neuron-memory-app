import requests
import json

# URL of the server's endpoint that will receive the JSON data.
url = 'http://127.0.0.1:5000/receive-data'

# Load the JSON data from the file.
with open('content.json', 'r', encoding='utf-8') as file:
    json_data = json.load(file)

# Send a POST request with the JSON data.
response = requests.post(url, json=json_data)

# Print out the status and response text from the server.
print(f"Status code: {response.status_code}")
print("Response from server:")
print(response.text)
