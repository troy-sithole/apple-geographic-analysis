import requests
import json
import pandas as pd
from google.cloud import bigquery

# Configuration
PROJECT_ID = "apple-geographic-analysis"
DATASET_ID = "sec_edgar_raw"
TABLE_ID = "apple_total_revenue"

# Step 1: Fetch data from the API
print("Fetching Apple Revenue Data From SEC EDGAR...")

url = "https://data.sec.gov/api/xbrl/companyconcept/CIK0000320193/us-gaap/RevenueFromContractWithCustomerExcludingAssessedTax.json"
headers = {
    "User-Agent": "Troy Sithole kristroy.ts@gmailcom"
}

response = requests.get(url, headers=headers)
data = response.json()

# Step 2: Extract Annual 10-K records
records = []

for entry in data["units"]["USD"]:
    if entry.get("form") == "10-K" and entry.get("fp") == "FY":
        records.append({
            "fiscal_year": entry.get("fy"),
            "period_end": entry.get("end"),
            "value_usd_billions": round(entry.get("val") / 1000000000, 3), 
            "filed": entry.get("filed"),
            "accn": entry.get("accn"),
            "frame": entry.get("frame", "")
        })

print(f"Extracted {len(records)} annual revenue records.")

# Step 3: Convert to DataFrame for easier manipulation
df = pd.DataFrame(records)
df = df.drop_duplicates(subset=["fiscal_year"], keep="last") # Keep the latest record for each fiscal year  
df = df[df["fiscal_year"] >= 2021] # Filter for fiscal years 2021 and later
df = df.sort_values("fiscal_year")
print(df)

# Step 4: Load data into BigQuery
print("Loading data into BigQuery...")

client = bigquery.Client(project=PROJECT_ID)
table_ref = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"

schema = [
    bigquery.SchemaField("fiscal_year", "INTEGER"),
    bigquery.SchemaField("period_end", "STRING"),
    bigquery.SchemaField("value_usd_billions", "FLOAT"),
    bigquery.SchemaField("filed", "STRING"),
    bigquery.SchemaField("accn", "STRING"),
    bigquery.SchemaField("frame", "STRING")
]

job = client.load_table_from_dataframe(
    df, table_ref,
    job_config = bigquery.LoadJobConfig(
        write_disposition = "WRITE_TRUNCATE",
        schema = schema
    )
)
job.result()  # Wait for the job to complete
print(f"Loaded {len(df)} rows into {table_ref}.")
print("Done!")