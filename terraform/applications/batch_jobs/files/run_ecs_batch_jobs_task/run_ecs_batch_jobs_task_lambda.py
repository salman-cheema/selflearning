import os
import boto3
import string
import random
import json
import urllib.parse

LAUNCH_TYPE = 'FARGATE'
MAX_LIMIT_OF_CONCURRENT_RUNNERS = 50

def handler(event, context):

    client = boto3.client('ecs')
    sg_for_ecs_task = os.environ['sg_for_ecs_task']
    subnets_for_ecs_task = os.environ['subnets_for_ecs_task']
    cluster_name_for_ecs_task = os.environ['cluster_name_for_ecs_task']
    execution_role_arn_for_ecs_task = \
        os.environ['execution_role_arn_for_ecs_task']
    task_role_arn_for_ecs_task = \
        os.environ['task_role_arn_for_ecs_task']
    # Ideally this should not be a passed as a variable it make code less re-useable
    # We should use our buckets name and ecs task names synchronized so that we can use same lambda with multiple buckets
    task_definition_family_name = \
        os.environ['task_definition_family_name']

    # Parse Bucket name and Object key from the `event` payload while Lambda is expected to have an S3 bucket as a trigger
    bucket = event['Records'][0]['s3']['bucket']['name']
    object_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    list_tasks = client.list_tasks(cluster=cluster_name_for_ecs_task,
                                   desiredStatus='RUNNING',
                                   launchType=LAUNCH_TYPE)
    # I have not implement the SQS here!
    if len(list_tasks['taskArns']) > MAX_LIMIT_OF_CONCURRENT_RUNNERS:
        return {'message': 'LimitExceed. Put the message to SQS Queue and another lambda can read it later on and run task'}

    sg_list_for_ecs_task = json.loads(sg_for_ecs_task)
    subnets_list_for_ecs_task = json.loads(subnets_for_ecs_task)

    response = client.run_task(
        cluster = cluster_name_for_ecs_task,
        count = 1,
        launchType = LAUNCH_TYPE,
        enableExecuteCommand=True,
        platformVersion = "LATEST",
        taskDefinition = task_definition_family_name,
        networkConfiguration = {
            "awsvpcConfiguration": {
                "subnets": subnets_list_for_ecs_task,
                "securityGroups": sg_list_for_ecs_task,
                "assignPublicIp": "DISABLED",
            }
        },
        overrides = {
            "containerOverrides": [
                {
                    "name": task_definition_family_name,
                    "environment": [
                        {
                            "name": "S3_BUCKET", 
                            "value": bucket
                        },
                        {
                            "name": "S3_OBJECT_KEY", 
                            "value": object_key
                        }
                    ],
                }
            ],
            "executionRoleArn": execution_role_arn_for_ecs_task,
            "taskRoleArn": task_role_arn_for_ecs_task,
        },
    )