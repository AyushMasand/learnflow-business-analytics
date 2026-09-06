from sqlalchemy import text
from ingestion.config import get_engine

def db_exists(engine,database_name):
    with engine.begin() as conn:
        result = conn.execute(text(
            """
                SELECT 
                    1
                FROM sys.databases
                WHERE name = :database_name
            """
        ),{"database_name" : database_name})

        return result.scalar() is not None

def create_database(engine,database_name):
    with engine.connect() as conn:
        conn = conn.execution_options(isolation_level = 'AUTOCOMMIT')
        conn.execute(text(f"CREATE DATABASE {database_name}"))

def intialize_db() :
    engine = get_engine('master')

    database_name = 'LearnFlow'

    if not db_exists(engine,database_name):

        print(f"Database {database_name} doesn\'t exists...Creating database.....")

        create_database(engine,database_name)

        print(f"database {database_name} created successfully....")

    else :

        print(f"Database {database_name} already exists....")

    return get_engine(database_name)

if '__main__' == __name__:
    intialize_db()