import azure.functions as func
import json
import requests
from azure.cosmos import CosmosClient
from azure.cosmos.exceptions import CosmosHttpResponseError

def main(req: func.HttpRequest) -> func.HttpResponse:
    # Parse review from request
    try:
        review = req.get_json()
    except ValueError:
        return func.HttpResponse("Invalid JSON", status_code=400)

    # Text Analytics configuration
    text_analytics_endpoint = "https://westeurope.api.cognitive.microsoft.com/"
    text_analytics_key = "6bmFJB7bBSjLIrXb592pVzZdRC0yPqmeaMosSRoUJOTV1lPBxaOSJQQJ99BEAC5RqLJXJ3w3AAAaACOGCAku"
    headers = {
        "Ocp-Apim-Subscription-Key": text_analytics_key,
        "Content-Type": "application/json"
    }
    sentiment_url = f"{text_analytics_endpoint}/text/analytics/v3.1/sentiment"

    # Call Text Analytics for sentiment
    payload = {
        "documents": [{"id": review["review_id"], "text": review["body"], "language": "en"}]
    }
    response = requests.post(sentiment_url, headers=headers, json=payload)
    if response.status_code != 200:
        return func.HttpResponse(f"Text Analytics error: {response.text}", status_code=500)
    sentiment_result = response.json()
    sentiment = sentiment_result["documents"][0]["sentiment"].lower()  # positive, negative, neutral

    # Add sentiment to review
    review["sentiment"] = sentiment

    cosmos_endpoint = "https://rtpipeline-cosmosdb.documents.azure.com:443/"
    cosmos_key = "zj3z2oTpB3LLqyAP4Wr7lycIusYDjop3pBVLEVnuiD9pdmhSC7DVTyY0LvcKDYejDtjv4t4SkdP3ACDbozkuWw=="
    database_name = "reviewsdb"
    container_name = "reviews"
    client = CosmosClient(cosmos_endpoint, cosmos_key)
    database = client.get_database_client(database_name)
    container = database.get_container_client(container_name)

    # Store review in Cosmos DB
    try:
        container.upsert_item(review)
    except CosmosHttpResponseError as e:
        return func.HttpResponse(f"Cosmos DB error: {e}", status_code=500)

    # Return review with sentiment
    return func.HttpResponse(json.dumps(review), mimetype="application/json", status_code=200)