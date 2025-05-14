# ✈️ Real-Time Airline Review Processing Pipeline

This project implements a **real-time data pipeline** for processing airline reviews using **Azure cloud services**. Reviews are ingested through **Azure Event Hubs**, analyzed for sentiment using **Azure Cognitive Services**, stored in **Cosmos DB**, and **negative reviews trigger Slack alerts**. The results are then visualized in **Power BI**.

---

## 📊 Architecture Overview

| Component              | Description                                                                  |
| ---------------------- | ---------------------------------------------------------------------------- |
| **Event Hubs**         | (`rtpipeline-eh`) Ingests real-time review data.                             |
| **Logic Apps**         | (`rtpipeline-logic-app`) Orchestrates data flow based on Event Hub triggers. |
| **Cognitive Services** | (`rtpipeline-text-an`) Performs sentiment analysis (Text Analytics API).     |
| **Cosmos DB**          | (`rtpipeline-cosmosdb`) Stores enriched review data with sentiment scores.   |
| **Slack**              | Sends notifications for negative reviews via webhook.                        |
| **Power BI**           | Visualizes sentiment trends and review insights.                             |

---

## ✅ Prerequisites

Before getting started, ensure you have:

* An **Azure subscription** with access to:

  * Event Hubs
  * Logic Apps
  * Cognitive Services (Text Analytics)
  * Cosmos DB
  * Power BI

* **Terraform** installed for infrastructure provisioning

* **Python 3.8+** installed 

* **Azure CLI** installed and authenticated (Contributor or Owner role)

* A **Slack webhook URL** for notifications

---

## ⚙️ Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/rahiqi-al/azure_real_time_pipeline.git
   cd azure_real_time_pipeline
   ```

2. **Deploy Azure Infrastructure with Terraform**

   ```bash
   terraform init
   terraform apply
   ```

3. **Configure Logic Apps**

   * Import the provided Logic App workflow.
   * Set the triggers and connections for:

     * Event Hub listener
     * Text Analytics
     * Cosmos DB insertion
     * Slack notification

4. **Set Slack Webhook URL**

   * Add your Slack webhook URL in the Logic App workflow using Azure Portal.

5. **Generate Test Review Data**

   ```bash
   python generate_reviews.py
   ```

---

## 🚀 Usage

* Start the pipeline by sending review events to **Event Hubs**.
* Monitor pipeline execution via **Logic Apps** in the Azure Portal.
* Check **Cosmos DB** to verify processed reviews and their sentiment.
* Review **Slack** for alerts on negative sentiment.
* Connect **Power BI** to Cosmos DB to explore and visualize trends.


---

## 📫 Contact

For questions or contributions, feel free to [open an issue](https://github.com/rahiqi-al/azure_real_time_pipeline.git) or submit a pull request.

