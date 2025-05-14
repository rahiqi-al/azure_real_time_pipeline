import azure.functions as func
import requests
import json

def main(req: func.HttpRequest) -> func.HttpResponse:
    review = req.get_json()
    if review.get("sentiment") == "negative":
        slack_webhook_url = "https://hooks.slack.com/services/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"  
        slack_payload = {
            "text": f"Negative Review: {review['title']}\n{review['body']}\nAirline: {review['airline']}\nRating: {review['rating']}"
        }
        response = requests.post(slack_webhook_url, json=slack_payload)
        if response.status_code != 200:
            print(f"Failed to send Slack notification: {response.text}")
    return func.HttpResponse("Notification processed")