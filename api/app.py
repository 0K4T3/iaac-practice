import os

import boto3
from fastapi import FastAPI, Response
from mangum import Mangum


AWS_ENDPOINT = os.getenv('AWS_ENDPOINT')
AWS_REGION = os.getenv('AWS_REGION')
LOCALSTACK_HOSTNAME = os.getenv('LOCALSTACK_HOSTNAME')
AWS_ENDPOINT = f'http://{LOCALSTACK_HOSTNAME}:4566'
DynamoDB = boto3.resource(
    'dynamodb',
    region_name=AWS_REGION,
    endpoint_url=AWS_ENDPOINT,
)


app = FastAPI()


@app.get('/users')
async def get_users() -> Response:
    test_table = DynamoDB.Table('Users')
    users = test_table.scan()['Items']
    return {
        'users': users,
    }


@app.post('/users/{user_id}')
async def post_user(user_id: str) -> Response:
    test_table = DynamoDB.Table('Users')
    test_table.put_item(
        Item={
            'UserId': user_id,
        }
    )
    users = test_table.scan()['Items']
    return {
        'users': users,
    }


@app.delete('/users/{user_id}')
async def delete_user(user_id: str) -> Response:
    test_table = DynamoDB.Table('Users')
    test_table.delete_item(
        Key={
            'UserId': user_id,
        }
    )
    users = test_table.scan()['Items']
    return {
        'users': users,
    }


lambda_handler = Mangum(app)
