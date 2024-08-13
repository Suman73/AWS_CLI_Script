
#!/bin/bash

# Variables
LAUNCH_TEMPLATE_ID=""  # Replace with your Launch Template ID
AUTOSCALING_GROUP_NAME=""  # Replace with your Auto Scaling Group Name

# Get the latest launch template version
LATEST_VERSION=$(aws ec2 describe-launch-templates --launch-template-ids $LAUNCH_TEMPLATE_ID --query 'LaunchTemplates[0].LatestVersionNumber' --output text)

# Update the default version of the Launch Template to the latest version
aws ec2 modify-launch-template --launch-template-id $LAUNCH_TEMPLATE_ID --default-version $LATEST_VERSION

echo "Default version of Launch Template updated to version $LATEST_VERSION"

# Start an instance refresh in the Auto Scaling Group
aws autoscaling start-instance-refresh --auto-scaling-group-name $AUTOSCALING_GROUP_NAME \
  --preferences '{"MinHealthyPercentage":100,"InstanceWarmup":300}' \
  --desired-configuration "{\"LaunchTemplate\":{\"LaunchTemplateId\":\"$LAUNCH_TEMPLATE_ID\",\"Version\":\"$LATEST_VERSION\"}}" \
  --strategy "Rolling" \
  --query 'InstanceRefreshId' --output text

echo "Instance refresh started for Auto Scaling Group $AUTOSCALING_GROUP_NAME with new launch template version $LATEST_VERSION"
