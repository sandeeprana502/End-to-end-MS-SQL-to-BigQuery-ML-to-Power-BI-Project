# Customer Churn Prediction — End-to-End ML Pipeline

## Overview
An end-to-end machine learning pipeline that predicts customer churn
using AdventureWorks DW database, BigQuery ML, and Power BI.

## Architecture
AdventureWorksDW (SQL Server)
        │
        ▼
Python ETL (pyodbc + pandas)
        │
        ▼
Google BigQuery (20 tables)
        │
        ├──► BigQuery ML (Logistic Regression)
        │         │
        │         ▼
        │    Churn Predictions
        │
        ▼
Power BI Semantic Model
        │
        ▼
Power BI Dashboard


## Tech Stack
- **Database**: SQL Server (AdventureWorksDW2019)
- **ETL**: Python, pyodbc, pandas
- **Data Warehouse**: Google BigQuery
- **ML**: BigQuery ML — Logistic Regression
- **BI**: Power BI Desktop
- **Integration**: Power Apps, Power Automate

## ML Model Details
| Metric | Value |
|--------|-------|
| Model type | Logistic Regression |
| Training split | 80% train / 20% eval |
| Features | RFM + customer profile (15 features) |

## Features Used
- Recency Days (days since last purchase)
- Order Count
- Total Spend
- Average Order Value
- Customer Tenure Days
- Active Years
- Yearly Income
- Total Children
- Children at Home
- Education
- Occupation
- House Owner Flag
- Cars Owned
- Gender
- Country

## BigQuery Tables Created
| Table | Description |
|-------|-------------|
| CustomerChurnFeatures | RFM features + churn label |
| CustomerChurnTrain | 80% training set |
| CustomerChurnEval | 20% evaluation set |
| CustomerChurnModel | Trained logistic regression model |
| CustomerChurnPredictions | Final predictions with risk tier |

## Power BI Dashboard
Shows:
- Overall churn rate
- Risk tier distribution (High/Medium/Low)
- Customer churn probability table
- Churn by country and occupation
- Revenue at risk from high-risk customers

## Setup Instructions

### 1. Clone the repo
git clone 

### 2. Install dependencies
pip install -r requirements.txt

### 3. Configure credentials
- Add your BigQuery service account JSON key
- Update SQL Server connection in etl/load_to_bigquery.py

### 4. Run ETL
python etl/load_to_bigquery.py

### 5. Run SQL scripts in order
Run sql/01 through sql/06 in BigQuery Console

### 6. Open Power BI
Open powerbi/ChurnDashboard.pbix