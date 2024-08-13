#!/bin/bash

# Define variables
ROLE_NAME="EventBridgeStopEC2Role"
POLICY_NAME="EC2StopPolicy"
TRUST_POLICY_FILE="trust-policy.json"
EC2_STOP_POLICY_FILE="ec2-stop-policy.json"

# Create trust policy JSON file
cat <<EOL > $TRUST_POLICY_FILE
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOL

# Create EC2 stop policy JSON file
cat <<EOL > $EC2_STOP_POLICY_FILE
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:StopInstances"
            ],
            "Resource": "*"
        }
    ]
}
EOL

# Create IAM role with trust policy
echo "Creating IAM role..."
aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file://$TRUST_POLICY_FILE

# Attach policy to the role
echo "Attaching policy to the role..."
aws iam put-role-policy --role-name $ROLE_NAME --policy-name $POLICY_NAME --policy-document file://$EC2_STOP_POLICY_FILE

# Clean up temporary files
echo "Cleaning up temporary files..."
rm -f $TRUST_POLICY_FILE $EC2_STOP_POLICY_FILE

echo "IAM role creation and policy attachment complete."
