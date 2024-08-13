#!/bin/bash

# Variables
INSTANCE_ID="i-1234567890abcdef0"  # Replace with your EC2 instance ID
TIMESTAMP=$(date +"%Y%m%d%H%M%S")  # Current timestamp in YYYYMMDDHHMMSS format
AMI_NAME="chatbot_test_server-AMI-${INSTANCE_ID}-${TIMESTAMP}"  # AMI name with prefix, instance ID, and timestamp
AMI_DESCRIPTION="AMI created from EC2 instance $INSTANCE_ID on $TIMESTAMP"
LAUNCH_TEMPLATE_ID="lt-0abcd1234efgh5678"  # Replace with your Launch Template ID

# Create the AMI
CREATE_AMI_OUTPUT=$(aws ec2 create-image --instance-id $INSTANCE_ID --name "$AMI_NAME" --description "$AMI_DESCRIPTION" --query 'ImageId' --output text)

# Print the AMI ID
echo "AMI ID: $CREATE_AMI_OUTPUT"

# Create a new version of the Launch Template
NEW_VERSION_OUTPUT=$(aws ec2 create-launch-template-version --launch-template-id $LAUNCH_TEMPLATE_ID \
  --source-version \$Latest \
  --version-description "New version with AMI $CREATE_AMI_OUTPUT" \
  --launch-template-data "{\"ImageId\":\"$CREATE_AMI_OUTPUT\"}" \
  --query 'LaunchTemplateVersion.VersionNumber' --output text)

# Print the new Launch Template Version
echo "New Launch Template Version: $NEW_VERSION_OUTPUT"
