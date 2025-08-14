import json
import requests
import logging

def lambda_handler(event, context):
    url = "https://worldtimeapi.org/api/timezone/America/Phoenix"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        datetime_value = data.get("datetime")

        log_message = f"Current datetime: {datetime_value}"
        print(log_message)

        return {
            'statusCode': 200,
            'body': json.dumps({'message': log_message})
        }
    else:
        print(f"Failed to get data: {response.status_code}")
        return {
            'statusCode': response.status_code,
            'body': json.dumps({'error': 'API request failed'})
        }