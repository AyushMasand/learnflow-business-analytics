from ingestion.database import intialize_db
from sqlalchemy import text

def create_schema(engine):
    with engine.begin() as conn:
        conn.execute(text("""
                IF NOT EXISTS(
                    SELECT 
                        1
                    FROM sys.schemas
                    where name = 'raw'
                )
                BEGIN 
                    EXEC('CREATE SCHEMA raw')
                END
            """))

def create_tables(engine):

    with engine.begin() as conn:

        conn.execute(text("""
            CREATE TABLE raw.users (
                user_id VARCHAR(20) NOT NULL,
                signup_date DATETIME NOT NULL,
                country VARCHAR(50),
                age_group VARCHAR(20),
                acquisition_channel VARCHAR(50),
                device_type VARCHAR(30),
                learning_goal VARCHAR(100),
                skill_level VARCHAR(30)
            )
        """))

        conn.execute(text("""
            CREATE TABLE raw.courses (
                course_id VARCHAR(20) NOT NULL,
                course_name VARCHAR(200),
                category VARCHAR(100),
                difficulty VARCHAR(30),
                estimated_hours INT,
                is_premium BIT
            )
        """))

        conn.execute(text("""
            CREATE TABLE raw.lessons (
                lesson_id VARCHAR(20) NOT NULL,
                course_id VARCHAR(20),
                lesson_number INT,
                lesson_title VARCHAR(200),
                duration_minutes INT
            )
        """))

        conn.execute(text("""
            CREATE TABLE raw.sessions (
                session_id VARCHAR(30) NOT NULL,
                user_id VARCHAR(20),
                session_start DATETIME,
                session_end DATETIME,
                device_type VARCHAR(30)
            )
        """))

        conn.execute(text("""
            CREATE TABLE raw.events (
                event_id VARCHAR(30) NOT NULL,
                user_id VARCHAR(20),
                session_id VARCHAR(30),
                event_timestamp DATETIME,
                event_name VARCHAR(100),
                course_id VARCHAR(20),
                lesson_id VARCHAR(20),
                device_type VARCHAR(30),
                event_value DECIMAL(18,2)
            )
        """))

        conn.execute(text("""
            CREATE TABLE raw.subscriptions (
                subscription_id VARCHAR(30) NOT NULL,
                user_id VARCHAR(20),
                [plan] VARCHAR(50),
                start_date DATETIME,
                end_date DATETIME,
                monthly_price DECIMAL(10,2),
                status VARCHAR(30)
            )
        """))

        conn.execute(text("""
            CREATE TABLE raw.marketing (
                campaign_id VARCHAR(30),
                date DATE NOT NULL,
                channel VARCHAR(50) NOT NULL,
                campaign VARCHAR(100),
                spend DECIMAL(14,2),
                impressions BIGINT,
                clicks BIGINT
            )
        """))

        conn.execute(text("""
            CREATE TABLE raw.etl_load_log (
                load_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                source_file VARCHAR(255) NOT NULL,
                target_table VARCHAR(100) NOT NULL,
                file_size_bytes BIGINT,
                file_modified_time DATETIME,
                rows_read BIGINT,
                rows_inserted BIGINT,
                rows_skipped BIGINT,
                load_start_time DATETIME,
                load_end_time DATETIME,
                status VARCHAR(20),
                error_message VARCHAR(2000)
            )
        """))

        


if "__main__" == __name__:

    engine = intialize_db()
    print(f"connected to learnflow db...")

    create_schema(engine)
    print("schema created successfully...")

    create_tables(engine)
    print('tables created successfully.....')