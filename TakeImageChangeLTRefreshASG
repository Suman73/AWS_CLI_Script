#!/bin/bash

# Variables
INSTANCE_ID="i-1234567890abcdef0"  # Replace with your EC2 instance ID
TIMESTAMP=$(date +"%Y%m%d%H%M%S")  # Current timestamp in YYYYMMDDHHMMSS format
AMI_NAME="chatbot_test_server-AMI-${INSTANCE_ID}-${TIMESTAMP}"  # AMI name with prefix, instance ID, and timestamp
AMI_DESCRIPTION="AMI created from EC2 instance $INSTANCE_ID on $TIMESTAMP"

# Create the AMI
CREATE_AMI_OUTPUT=$(aws ec2 create-image --instance-id $INSTANCE_ID --name "$AMI_NAME" --description "$AMI_DESCRIPTION" --query 'ImageId' --output text)

# Print the AMI ID
echo "AMI ID: $CREATE_AMI_OUTPUT"
