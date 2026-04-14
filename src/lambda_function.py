import json
import boto3
import os
import logging
import urllib.parse

# Set up logging for CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS Clients
# Note: These are initialized outside the handler for "warm start" performance
rekognition = boto3.client('rekognition')
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    # 1. Get the Table Name from the environment variable set in lambda.tf
    table_name = os.environ.get('DYNAMO_TABLE')
    table = dynamodb.Table(table_name)
    
    try:
        # 2. Parse S3 Event data
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
        
        logger.info(f"Processing file: {key} from bucket: {bucket}")

        # 3. Call Amazon Rekognition
        # We use detect_labels to identify what is in the image
        response = rekognition.detect_labels(
            Image={
                'S3Object': {
                    'Bucket': bucket,
                    'Name': key
                }
            },
            MaxLabels=10,
            MinConfidence=75  # Only return labels with 75% accuracy or higher
        )

        # 4. Extract label names into a list
        labels = [label['Name'] for label in response['Labels']]
        logger.info(f"Detected labels: {labels}")

        # 5. Store results in DynamoDB
        table.put_item(
            Item={
                'ImageID': key,        # This matches our Terraform Partition Key
                'Bucket': bucket,
                'Labels': labels,
                'Timestamp': context.aws_request_id # Unique ID for the execution
            }
        )

        return {
            'statusCode': 200,
            'body': json.dumps(f"Successfully processed {key}")
        }

    except Exception as e:
        logger.error(f"Error processing image {key}: {str(e)}")
        raise e