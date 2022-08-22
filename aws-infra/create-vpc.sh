#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


VPC_CIDR=${VPC_CIDR:-"172.20.0.0/16"}
SUBNET_CIDR=${SUBNET_CIDR:-"172.20.1.0/24"}
VPC_ENV_FILE=${VPC_ENV_FILE:-vpc_env}


if [ -f "$VPC_ENV_FILE" ]; then
	echo "$VPC_ENV_FILE exists. Please delete it before continuing"
	return 1
fi

#Generate a random 4 digit number to be used with names for uniqueness
UUID=$(cut -c 1-4 < /proc/sys/kernel/random/uuid)

VPC_NAME=${VPC_NAME:-peer-pods-vpc-$UUID}
SUBNET_NAME=${SUBNET_NAME:-peer-pods-subnet-$UUID}
SG_NAME=${SG_NAME:-peer-pods-sg-$UUID}
IGW_NAME=${IGW_NAME:-peer-pods-igw-$UUID}
RT_NAME=${RT_NAME:-peer-pods-rt-$UUID}

echo "Creating VPC with CIDR: $VPC_CIDR and SUBNET: $SUBNET_CIDR"


VPC_ID=$(aws ec2 create-vpc --cidr-block "$VPC_CIDR" --region "$AWS_REGION" \
	--tag-specification ResourceType=vpc,Tags=\[\{Key=Name,Value="$VPC_NAME"\}\] \
       	--query Vpc.VpcId --output text)
echo "VPC ID: " "$VPC_ID"
export VPC_ID="$VPC_ID"
echo "VPC_ID=$VPC_ID" >> "$VPC_ENV_FILE"


echo "Creating Security Group for VPC"
SG_ID=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values="$VPC_ID" \
	--query "SecurityGroups[*].GroupId" --region "$AWS_REGION" --output text)
echo "Security Group ID: " "$SG_ID"
echo "SG_ID=$SG_ID" >> "$VPC_ENV_FILE"

aws ec2 create-tags --resource "$SG_ID" --tags Key=Name,Value="$SG_NAME" --region "$AWS_REGION"

echo "Adding rule to allow SSH access from any source IP"
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr "0.0.0.0/0" --region "$AWS_REGION"

#echo "Adding rule to allow all traffic within the VPC"
#aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol "-1" --source-group "$SG_ID" --region "$AWS_REGION"

echo "Creating Subnet"
SUBNET_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$SUBNET_CIDR" --region "$AWS_REGION" \
       	--tag-specification ResourceType=subnet,Tags=\[\{Key=Name,Value="$SUBNET_NAME"\}\] \
	--query Subnet.SubnetId --output text)
echo "Subnet ID:" "$SUBNET_ID"
export SUBNET_ID="$SUBNET_ID"
echo "SUBNET_ID=$SUBNET_ID" >> "$VPC_ENV_FILE"

echo "Creating Internet Gateway"
IGW_ID=$(aws ec2 create-internet-gateway --region "$AWS_REGION" \
	--tag-specification ResourceType=internet-gateway,Tags=\[\{Key=Name,Value="$IGW_NAME"\}\] \
	--query InternetGateway.InternetGatewayId --output text)

echo "Internet GW ID: " "$IGW_ID"
echo "IGW_ID=$IGW_ID" >> "$VPC_ENV_FILE"

aws ec2 attach-internet-gateway --vpc-id "$VPC_ID" --internet-gateway-id "$IGW_ID" --region "$AWS_REGION"

echo "Creating Route Table"
RT_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --region "$AWS_REGION" \
	--tag-specification ResourceType=route-table,Tags=\[\{Key=Name,Value="$RT_NAME"\}\] \
	--query RouteTable.RouteTableId --output text )

echo "Route table ID: " "$RT_ID"
echo "RT_ID=$RT_ID" >> "$VPC_ENV_FILE"

aws ec2 create-route --route-table-id "$RT_ID" --destination-cidr-block 0.0.0.0/0 \
       	--gateway-id "$IGW_ID" --region "$AWS_REGION"

aws ec2 associate-route-table  --subnet-id "$SUBNET_ID" --route-table-id "$RT_ID" --region "$AWS_REGION"

echo "Enabling public IP for instances in the subnet ($SUBNET_NAME)"
aws ec2 modify-subnet-attribute --subnet-id "$SUBNET_ID" --map-public-ip-on-launch --region "$AWS_REGION"

echo "VPC creation complete"
echo "VPC details available in $VPC_ENV_FILE"
