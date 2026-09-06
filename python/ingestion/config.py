from sqlalchemy import create_engine

SERVER = r"mssql+pyodbc://@localhost\SQLEXPRESS/"
DRIVER = "?driver=ODBC+Driver+17+for+SQL+Server"

def get_engine(DATABASE_NAME):
    engine = create_engine(f"{SERVER}"
                           f"{DATABASE_NAME}"
                           f"{DRIVER}"
                           "&trusted_conn=yes"
            )

    return engine