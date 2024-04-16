from fastapi import FastAPI
import asyncpg
from aiobotocore.session import get_session
import boto3
import json
import csv

AWS_REGION = "eu-west-1"
SECRET_NAME = "denislavs-tasks"

app = FastAPI()

def get_secret():
    client = boto3.client("secretsmanager", region_name=AWS_REGION)
    response = client.get_secret_value(SecretId=SECRET_NAME)
    secret = response["SecretString"]
    return secret

async def get_database_connection():
    secret = get_secret()
    credentials = json.loads(secret)
    username = credentials["username"]
    password = credentials["password"]
    return await asyncpg.connect(
        user=username,
        password=password,
        host=credentials["db_host"],
        port=5432,
        database=credentials["db_relation"]
    )

async def load_data():
    conn = await get_database_connection()
    try:
        await conn.execute(
            """
            CREATE TABLE IF NOT EXISTS dummy_records (
                id SERIAL PRIMARY KEY,
                usernames TEXT
            )
            """
        )
        count = await conn.fetchval("SELECT COUNT(*) FROM dummy_records")
        if count == 0:
            with open("dummy_records.csv", newline="") as csvfile:
                reader = csv.reader(csvfile)
                next(reader)
                for row in reader:
                    await conn.execute(
                        """
                        INSERT INTO dummy_records (usernames) VALUES ($1)
                        """,
                        row[0] 
                    )
            return {"message": "Data loaded successfully"}
        else:
            return {"message": "Data already exists in the table"}
    finally:
        await conn.close()

@app.get("/postgres")
async def read_postgres_records():
    conn = await get_database_connection()
    try:
        query = "select usernames from dummy_records"
        records = await conn.fetch(query)
        return records
    finally:
        await conn.close()

@app.get("/s3")
async def read_s3_files():
    session = get_session()
    secret = get_secret()
    config = json.loads(secret)
    bucket_name = config['bucket']
    async with session.create_client("s3") as s3_client:
        response = await s3_client.list_objects_v2(Bucket=bucket_name)
        files = []
        for obj in response.get("Contents", []):
            files.append(obj["Key"])
        return files

if __name__ == "__main__":
    import uvicorn
    import asyncio

    asyncio.run(load_data())

    uvicorn.run(app, host="0.0.0.0", port=8080)
