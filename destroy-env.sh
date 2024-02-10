#!/bin/bash

# Get a list of instance IDs
IDS=$(aws ec2 describe-instances --output=json | jq -r '.Reservations[].Instances[].InstanceId')

# Get the Elastic Load Balancer (ELB) ARN
ELBARN=$(aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn" --output json | jq -r '.[]')

# Get the Target Group ARN
TARGETARN=$(aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupArn" --output json | jq -r '.[]')

# Get RDS instance identifiers (excluding read replicas)
RDS_INSTANCE_IDS=$(aws rds describe-db-instances --query "DBInstances[?ReadReplicaSourceDBInstanceIdentifier == null].DBInstanceIdentifier" --output text)

# Get RDS read replica identifiers
READ_REPLICA_IDS=$(aws rds describe-db-instances --query "DBInstances[?ReadReplicaSourceDBInstanceIdentifier != null].DBInstanceIdentifier" --output text)

# Get EC2 Launch Template names
LAUNCH_TEMPLATE_NAMES=$(aws ec2 describe-launch-templates --query "LaunchTemplates[*].LaunchTemplateName" --output text)

# Get Auto Scaling Group names
ASG_NAMES=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[*].AutoScalingGroupName" --output text)

# Delete EC2 instances using a for loop
for INSTANCE_ID in $IDS; do
  echo "Terminating EC2 instance: $INSTANCE_ID"
  aws ec2 terminate-instances --instance-ids $INSTANCE_ID
done

# Wait for instances to be terminated
echo "Waiting for instances to be terminated..."
aws ec2 wait instance-terminated --instance-ids $IDS

# Delete Elastic Load Balancer
echo "Deleting Elastic Load Balancer..."
aws elbv2 delete-load-balancer --load-balancer-arn $ELBARN

sleep 60

# Delete Target Group
echo "Deleting Target Group..."
aws elbv2 delete-target-group --target-group-arn $TARGETARN

# Delete RDS read replicas using a for loop
for READ_REPLICA_ID in $READ_REPLICA_IDS; do
  echo "Deleting RDS read replica: $READ_REPLICA_ID"
  aws rds delete-db-instance --db-instance-identifier $READ_REPLICA_ID --skip-final-snapshot
done

# Delete RDS instances using a for loop
for RDS_INSTANCE_ID in $RDS_INSTANCE_IDS; do
  echo "Deleting RDS instance: $RDS_INSTANCE_ID"
  aws rds delete-db-instance --db-instance-identifier $RDS_INSTANCE_ID --skip-final-snapshot
done

# Delete Launch Templates using a for loop
for LAUNCH_TEMPLATE_NAME in $LAUNCH_TEMPLATE_NAMES; do
  echo "Deleting EC2 Launch Template: $LAUNCH_TEMPLATE_NAME"
  aws ec2 delete-launch-template --launch-template-name $LAUNCH_TEMPLATE_NAME
done

echo "Deleting Auto Scaling Group: $ASG_NAME"
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $ASG_NAMES --force-delete

# Get a list of S3 bucket names
S3_BUCKET_NAMES=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

# Loop through each bucket and delete objects, then delete the bucket
for BUCKET_NAME in $S3_BUCKET_NAMES; do
  echo "Deleting objects in S3 bucket: $BUCKET_NAME"
  aws s3 rm s3://$BUCKET_NAME --recursive

  echo "Deleting S3 bucket: $BUCKET_NAME"
  aws s3 rb s3://$BUCKET_NAME --force
done

echo "S3 bucket deletion script execution completed."


SECRET_ID=$(aws secretsmanager list-secrets --query 'SecretList[*].ARN')
aws secretsmanager delete-secret \
    --secret-id $SECRET_ID \
    --force-delete-without-recovery
echo "secret deleted"

# Print completion message
echo "Termination script execution completed."