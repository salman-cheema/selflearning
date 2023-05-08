import boto3
import os
import sqlalchemy as sa
from sqlalchemy import create_engine
import pandas as pd
from connection import postgres_connection
s3 = boto3.resource('s3')

def main():
    df = pd.read_sql_query('select * from ports',con=postgres_connection())
    s3.Bucket(os.environ["S3_BUCKET"]).download_file(os.environ["S3_OBJECT_KEY"], '/tmp/file')
    # reading csv files
    # df=pd.read_csv('/tmp/file')
    # Insert to table
    # df.to_sql("company",con=postgres_connection(),if_exists='append',index=False)
    print(df)
    print(os.environ["S3_BUCKET"])
    print(os.environ["S3_OBJECT_KEY"])

main()