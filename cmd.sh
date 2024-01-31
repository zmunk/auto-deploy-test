#!/bin/bash
export AWS_DEFAULT_PROFILE=nexus

STACK_NAME="test-stack-1"

if [ "$1 $2" = "create stack" ]; then
    aws cloudformation create-stack \
        --on-failure DO_NOTHING \
        --stack-name "$STACK_NAME" \
        --template-body "file://template.yaml" \
        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
    exit 0
fi

if [ "$1 $2" = "update stack" ]; then
    aws cloudformation update-stack \
        --stack-name "$STACK_NAME" \
        --template-body file://template.yaml \
        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
    exit 0
fi

if [ "$1 $2" = "delete stack" ]; then
    aws cloudformation delete-stack \
        --stack-name "$STACK_NAME"
    exit 0
fi

if [ "$1 $2" = "stack status" ]; then
    aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --query "Stacks[0].StackStatus" \
        --output text
    exit 0
fi

if [ "$1 $2" = "stack logs" ]; then
    aws cloudformation describe-stack-events \
        --stack-name "$STACK_NAME" \
        --query "StackEvents[].[ResourceStatus, ResourceStatusReason, ResourceType]" \
        --output text
    exit 0
fi

echo "invalid arguments: $@"

exit 1
