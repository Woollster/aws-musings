#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-public

if [[ $JUMP_BOX_KEY_NAME == "" ]] ; then
    JUMP_BOX_KEY_NAME=$(cat $(dirname $0)/../public-infrastructure.yml \
        | shyaml get-value Parameters.JumpBoxKeyName.Default)
fi
if [[ $JUMP_BOX_SSH_CIDR_IP == "" ]] ; then
    JUMP_BOX_SSH_CIDR_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)/32
    >&2 echo "WARNING: ssh to the jump box will only be accessible from the current public IP address ($JUMP_BOX_SSH_CIDR_IP)."
    >&2 echo "  Set JUMP_BOX_SSH_CIDR_IP to restrict access."
fi

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $AWS_MUSINGS_S3_URL/infrastructure/public-infrastructure.yml \
    --parameters ParameterKey=AWSMusingsS3URL,ParameterValue=$AWS_MUSINGS_S3_URL \
        ParameterKey=DNSZone,ParameterValue=$DNS_ZONE \
        ParameterKey=FullyQualifiedExternalParentDNSZone,ParameterValue=$FULLY_QUALIFIED_EXTERNAL_PARENT_DNS_ZONE \
        ParameterKey=FullyQualifiedInternalParentDNSZone,ParameterValue=$FULLY_QUALIFIED_INTERNAL_PARENT_DNS_ZONE \
        ParameterKey=InternalKeyName,ParameterValue=$INTERNAL_KEY_NAME \
        ParameterKey=JumpBoxEIPAddress,ParameterValue=$JUMP_BOX_EIP_ADDRESS \
        ParameterKey=JumpBoxKeyName,ParameterValue=$JUMP_BOX_KEY_NAME \
        ParameterKey=JumpBoxSSHCIDRIP,ParameterValue=$JUMP_BOX_SSH_CIDR_IP \
        ParameterKey=SecondOctet,ParameterValue=$SECOND_OCTET \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
        ParameterKey=VPNGatewayId,ParameterValue=$VPN_GATEWAY_ID \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion

RESULT=$(describe-stack)

echo "export JUMP_BOX_PUBLIC_IP_ADDRESS=$(get-output-value JumpBoxPublicIPAddress)"
echo "export NETWORK_ACL_ID=$(get-output-value NetworkACLId)"
echo "export NAT_INSTANCE_ID=$(get-output-value NATInstanceId)"
echo "export PUBLIC_ROUTE_TABLE_ID=$(get-output-value PublicRouteTableId)"
