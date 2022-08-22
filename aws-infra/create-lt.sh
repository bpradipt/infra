#!/usr/bin/env bash
# Create EC2 launch template
set -o errexit
set -o nounset
set -o pipefail


VPC_ENV_FILE=${VPC_ENV_FILE:-vpc_env}
LT_NAME=${LT_NAME:-kata}
INSTANCE_TYPE=${INSTANCE_TYPE:-t3.small}



echo "Creating EC2 launch template ($LT_NAME)"

aws ec2 create-launch-template --launch-template-name kata --version-description version1 \
  --launch-template-data "{\"NetworkInterfaces\":[{\"DeviceIndex\":0,\"AssociatePublicIpAddress\":true,\"Groups\":[\"$SG_ID\"],\"SubnetId\":\"$SUBNET_ID\",\"DeleteOnTermination\":true}],\"ImageId\":\"$POD_VM_AMI_ID\",\"InstanceType\":\"$INSTANCE_TYPE\",\"KeyName\":\"$KP_NAME\"}" --region "$AWS_REGION"
