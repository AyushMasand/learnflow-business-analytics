import pandas as pd
from sqlalchemy import text
import os

def discover_files(path):
    csv_files = []
    for file in os.listdir(path):
        if file.endswith('.csv'):
            csv_files.append(file)
    return csv_files




def load_data(file_path,table_name,engine):

    rows_read = 0
    rows_loaded = 0

    with engine.begin() as conn:
        conn.execute(text(f"TRUNCATE TABLE raw.{table_name}"))

        print(f"raw.{table_name} truncated successfully.")

        for chunk in pd.read_csv(file_path,chunksize = 100000):

            if table_name == "events":
                chunk["event_timestamp"] = pd.to_datetime(
                    chunk["event_timestamp"],
                    errors="coerce")

            elif table_name == "subscriptions":
                chunk["start_date"] = pd.to_datetime(chunk["start_date"],errors="coerce")

                chunk["end_date"] = pd.to_datetime(chunk["end_date"],errors="coerce")

            rows_read += len(chunk)

            chunk = chunk.drop_duplicates()

            if table_name == 'courses':
                chunk['is_premium'] = chunk['is_premium'].astype("boolean")

            chunk.to_sql(table_name,con = conn, schema = 'raw',if_exists = 'append',index = False)

            rows_loaded += len(chunk)

            print(f"{len(chunk):,} into raw.{table_name} successfully.")

        return {
            "rows_read" : rows_read,
            "rows_loaded" : rows_loaded
        }