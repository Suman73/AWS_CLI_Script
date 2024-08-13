#!/bin/bash

# Variables
INSTANCE_ID=""  # Replace with your EC2 instance ID
LAUNCH_TEMPLATE_ID=""  # Replace with your Launch Template ID
AUTOSCALING_GROUP_NAME=""  # Replace with your Auto Scaling Group Name
TIMESTAMP=$(date +"%Y%m%d%H%M%S")  # Current timestamp in YYYYMMDDHHMMSS format
AMI_NAME="chatbot_test_server-AMI-${INSTANCE_ID}-${TIMESTAMP}"  # AMI name with prefix, instance ID, and timestamp
AMI_DESCRIPTION="AMI created from EC2 instance $INSTANCE_ID on $TIMESTAMP"

# Create the AMI
CREATE_AMI_OUTPUT=$(aws ec2 create-image --instance-id $INSTANCE_ID --name "$AMI_NAME" --description "$AMI_DESCRIPTION" --query 'ImageId' --output text)

# Print the AMI ID
echo "AMI ID: $CREATE_AMI_OUTPUT"

# Wait for the AMI to be available
echo "Waiting for AMI to become available..."
aws ec2 wait image-available --image-ids $CREATE_AMI_OUTPUT
echo "AMI is now available."

# Create a new version of the Launch Template
NEW_VERSION_OUTPUT=$(aws ec2 create-launch-template-version --launch-template-id $LAUNCH_TEMPLATE_ID \
  --source-version \$Latest \
  --version-description "New version with AMI $CREATE_AMI_OUTPUT" \
  --launch-template-data "{\"ImageId\":\"$CREATE_AMI_OUTPUT\"}" \
  --query 'LaunchTemplateVersion.VersionNumber' --output text)
  
# Print the new Launch Template Version
echo "New Launch Template Version: $NEW_VERSION_OUTPUT"

# Get the latest launch template version
LATEST_VERSION=$(aws ec2 describe-launch-templates --launch-template-ids $LAUNCH_TEMPLATE_ID --query 'LaunchTemplates[0].LatestVersionNumber' --output text)

# Update the default version of the Launch Template to the latest version
aws ec2 modify-launch-template --launch-template-id $LAUNCH_TEMPLATE_ID --default-version $LATEST_VERSION
echo "Default version of Launch Template updated to version $LATEST_VERSION"




# Start an instance refresh in the Auto Scaling Group
INSTANCE_REFRESH_ID=$(aws autoscaling start-instance-refresh --auto-scaling-group-name $AUTOSCALING_GROUP_NAME \
  --preferences '{"MinHealthyPercentage":100,"InstanceWarmup":300}' \
  --desired-configuration "{\"LaunchTemplate\":{\"LaunchTemplateId\":\"$LAUNCH_TEMPLATE_ID\",\"Version\":\"$LATEST_VERSION\"}}" \
  --strategy "Rolling" \
  --query 'InstanceRefreshId' --output text)

echo "Instance refresh started for Auto Scaling Group $AUTOSCALING_GROUP_NAME with new launch template version $LATEST_VERSION"
echo "Instance Refresh ID: $INSTANCE_REFRESH_ID"
