import os
from sqlalchemy import create_engine

dbname = os.environ["DB_NAME"]
user = os.environ["DB_USER"]
host = os.environ["DB_HOST"]
password = os.environ["RATES_RW_PASSWORD"]


def postgres_connection():
    db_string = "postgresql://"+user+":"+password+"@"+host+":5432/"+dbname
    engine = create_engine(db_string)
    return engine
