import pyodbc
import pandas as pd
from google.cloud import bigquery
from google.oauth2 import service_account
import os

from config import (SQL_SERVER, DATABASE, DATASET,
                     PROJECT_ID, SERVICE_ACCOUNT_FILE)

# ── CONFIG ─────────────────────────────────────────────────────────
SQL_SERVER   = SQL_SERVER          # or your server name\instance
DATABASE     = DATABASE
GCP_PROJECT  = PROJECT_ID
BQ_DATASET   = DATASET
KEY_PATH     = SERVICE_ACCOUNT_FILE

# Tables to extract — all Dims and Facts
TABLES = [
    # Dimension tables
    "dbo.DimCustomer",
    "dbo.DimProduct",
    "dbo.DimProductCategory",
    "dbo.DimProductSubcategory",
    "dbo.DimDate",
    "dbo.DimGeography",
    "dbo.DimSalesTerritory",
    "dbo.DimPromotion",
    "dbo.DimEmployee",
    "dbo.DimReseller",
    "dbo.DimCurrency",
    "dbo.DimDepartmentGroup",
    "dbo.DimOrganization",
    # Fact tables
    "dbo.FactInternetSales",
    "dbo.FactResellerSales",
    "dbo.FactProductInventory",
    "dbo.FactSalesQuota",
    "dbo.FactInternetSalesReason",
    "dbo.FactCallCenter",
    "dbo.FactCurrencyRate",
]

# ── CONNECTIONS ────────────────────────────────────────────────────
def get_sql_connection():
    conn_str = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={SQL_SERVER};"
        f"DATABASE={DATABASE};"
        f"Trusted_Connection=yes;"   # Windows Auth
        # If using SQL Auth, replace above with:
        # f"UID=your_username;PWD=your_password;"
    )
    return pyodbc.connect(conn_str)

def get_bq_client():
    credentials = service_account.Credentials.from_service_account_file(KEY_PATH)
    return bigquery.Client(project=GCP_PROJECT, credentials=credentials)

# ── ETL LOGIC ──────────────────────────────────────────────────────
def extract_table(conn, table_name: str) -> pd.DataFrame:
    print(f"  Extracting {table_name}...")
    df = pd.read_sql(f"SELECT * FROM {table_name}", conn)
    print(f"  → {len(df):,} rows, {len(df.columns)} columns")
    return df

def clean_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    """Fix common type issues before loading to BigQuery."""
    for col in df.columns:
        # Convert date columns
        if df[col].dtype == object:
            try:
                df[col] = pd.to_datetime(df[col], errors='ignore')
            except Exception:
                pass
        # BigQuery doesn't like NaT in non-datetime cols
        if df[col].dtype == 'datetime64[ns]':
            df[col] = df[col].where(df[col].notna(), other=None)
    return df

def load_to_bigquery(bq_client, df: pd.DataFrame, table_name: str):
    # Convert "dbo.DimCustomer" → "DimCustomer"
    bq_table_name = table_name.split(".")[-1]
    destination = f"{GCP_PROJECT}.{BQ_DATASET}.{bq_table_name}"

    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,  # replace on each run
        autodetect=True,  # auto-detect schema
    )

    print(f"  Loading to BigQuery: {destination}")
    job = bq_client.load_table_from_dataframe(df, destination, job_config=job_config)
    job.result()  # wait for completion
    print(f"  ✓ Done — {bq_table_name}")

# ── MAIN ───────────────────────────────────────────────────────────
def run_etl():
    print("Connecting to SQL Server...")
    sql_conn = get_sql_connection()

    print("Connecting to BigQuery...")
    bq_client = get_bq_client()

    success = []
    failed  = []

    for table in TABLES:
        try:
            df = extract_table(sql_conn, table)
            df = clean_dataframe(df)
            load_to_bigquery(bq_client, df, table)
            success.append(table)
        except Exception as e:
            print(f"  ✗ FAILED: {table} — {e}")
            failed.append((table, str(e)))

    sql_conn.close()

    print("\n─── ETL Summary ───────────────────────────")
    print(f"  ✓ Success : {len(success)} tables")
    print(f"  ✗ Failed  : {len(failed)} tables")
    if failed:
        for t, err in failed:
            print(f"    • {t}: {err}")

if __name__ == "__main__":
    run_etl()