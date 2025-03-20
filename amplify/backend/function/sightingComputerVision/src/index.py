import json
import boto3

# Initialize the Rekognition client
rekognition = boto3.client('rekognition')

def lambda_handler(event, context):
    # Extract bucket name and image key from the event
    # For an S3 trigger, event structure might differ; adjust as needed
    bucket = event['bucket']
    image_key = event['imageKey']

    # Parameters for Rekognition DetectLabels API
    rekognition_params = {
        'Image': {
            'S3Object': {
                'Bucket': bucket,
                'Name': image_key
            }
        },
        'MaxLabels': 10,  # Limit to 10 labels; adjust as needed
        'MinConfidence': 70  # Minimum confidence threshold (70%); tweak for accuracy
    }

    # Call Rekognition to detect labels
    response = rekognition.detect_labels(**rekognition_params)

    # Filter labels to focus on animals and plants
    relevant_categories = ['Animal', 'Plant', 'Tree', 'Flower', 'Bird', 'Fish', 'Pet', 'Wildlife']
    filtered_labels = [
        {'Name': label['Name'], 'Confidence': round(label['Confidence'], 2)}
        for label in response['Labels']
        if any(category in label['Name'] for category in relevant_categories) or label['Name'] in relevant_categories
    ]

    # If no specific animal/plant labels found, return top labels as fallback
    if not filtered_labels:
        filtered_labels = [
            {'Name': label['Name'], 'Confidence': round(label['Confidence'], 2)}
            for label in response['Labels'][:5]  # Top 5 labels as fallback
        ]

    # Prepare the response
    result = {
        'statusCode': 200,
        'body': json.dumps({
            'labels': filtered_labels,
            'message': f'Analyzed image: {image_key} from bucket: {bucket}'
        }),
        'headers': {
            'Content-Type': 'application/json'
        }
    }

    return result