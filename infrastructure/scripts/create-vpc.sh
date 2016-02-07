#!/usr/bin/env bash

set -e

source $(dirname $0)/setenv.sh $@

STACK_NAME=$STACK_PREFIX-vpc

aws cloudformation create-stack --stack-name $STACK_NAME \
    --template-url $S3_URL/infrastructure/vpc.template \
    --parameters ParameterKey=SecondOctet,ParameterValue=$SECOND_OCTET \
    --disable-rollback --profile $PROFILE > /dev/null

wait-for-stack-completion

RESULT=$(describe-stack)

echo "export VPC_ID=$(get-output-value VPCId)"
