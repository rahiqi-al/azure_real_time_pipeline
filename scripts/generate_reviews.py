import random
import time
import uuid
import json
from faker import Faker
from azure.eventhub import EventHubProducerClient, EventData

# Event Hub configuration
EVENT_HUB_CONNECTION_STR = "Endpoint=sb://rtpipeline-eh-ns.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=hsuNt4RBIOTpH+oqwgOU2Ibr4iVN40tp8+AEhNXQ2gI="  
EVENT_HUB_NAME = "rtpipeline-eh"

# Initialize Faker
faker = Faker()

# Sample data
airlines = [
    "Air France", "Royal Air Maroc", "Air Arabia", "Emirates",
    "Saudia", "Ryanair", "Qatar Airways", "Lufthansa",
    "TAP Air Portugal", "KLM", "Turkish Airlines", "EasyJet"
]

sample_titles = [
    "Excellent experience", "Terrible flight", "Smooth journey", "Great service",
    "Awful food", "Lost luggage", "On-time and comfortable", "Never again",
    "Highly recommended", "Mediocre experience", "Delayed and frustrating", "Crew was amazing",
    "Unexpectedly good", "Total disappointment", "Worth every penny", "Terrible customer service"
]

sample_bodies = [
    "The flight was on time and the crew was extremely helpful and friendly.",
    "I had the worst experience ever. The staff was rude and the plane was dirty.",
    "Seats were comfortable and there was plenty of legroom. Great value for the money.",
    "The food served on board was awful. Cold and tasteless.",
    "We departed late but arrived early. Impressive time management.",
    "Customer service was unreachable and offered no help with my issue.",
    "The cabin was clean and the inflight entertainment was decent.",
    "I will never book with this airline again. Completely unprofessional.",
    "Everything went smoothly. Luggage arrived on time and check-in was fast.",
    "Very noisy cabin and poor handling of turbulence.",
    "The flight attendants were polite and always smiling. It made a difference.",
    "They lost my suitcase and it took over a week to get it back.",
    "Boarding process was chaotic and disorganized.",
    "It was a short flight but surprisingly comfortable. Would fly again.",
    "They overbooked the flight and bumped me off. Unacceptable.",
    "Inflight entertainment was outdated and barely worked."
]

def generate_fake_review():
    review_id = str(uuid.uuid4())
    airline = random.choice(airlines)
    title = random.choice(sample_titles)
    body = random.choice(sample_bodies)

    reviewer = faker.name()
    rating = random.randint(1, 5)
    date = faker.date_this_year().strftime("%Y-%m-%d")

    return {
        "review_id": review_id,
        "airline": airline,
        "reviewer": reviewer,
        "rating": rating,
        "date": date,
        "title": title,
        "body": body
    }

# Initialize Event Hub producer
producer = EventHubProducerClient.from_connection_string(
    conn_str=EVENT_HUB_CONNECTION_STR,
    eventhub_name=EVENT_HUB_NAME
)

try:
    while True:
        review = generate_fake_review()
        # Convert review to JSON string
        review_json = json.dumps(review)
        # Create EventData object
        event_data = EventData(review_json)
        # Send event to Event Hub
        with producer:
            producer.send_batch([event_data])
        print(f"Sent review to Event Hub: {review_json}")
        time.sleep(5)
except KeyboardInterrupt:
    print("Stopping the script...")
finally:
    producer.close()