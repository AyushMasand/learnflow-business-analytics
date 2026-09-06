import os 
from ingestion.database import intialize_db



from ingestion.load_data import (discover_files,load_data)

raw_path = 'data/raw'

def main() :

    engine = intialize_db()

    print('database intitiated successfully')

    csv_files = discover_files(raw_path)

    for file_name in csv_files:
        path = os.path.join(raw_path,file_name)

        table_name = file_name.removesuffix('_raw.csv')

        print(f"Starting load : {file_name} is {table_name}")

        result = load_data(path,table_name,engine)

        print(
            f"{file_name} completed."
        )

        print(
            f"Rows read: "
            f"{result['rows_read']:,}"
        )

        print(
            f"Rows loaded: "
            f"{result['rows_loaded']:,}"
        )

if "__main__" == __name__:
    main()
