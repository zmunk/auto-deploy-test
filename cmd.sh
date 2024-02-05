#!/bin/bash
export AWS_DEFAULT_PROFILE=nexus

STACK_NAME="test-stack-2"
PARAMETER_FILE="cfn-params.json"

# upload contents of dist to s3 bucket
if [ "$1 $2" = "upload dist" ]; then
    BUCKET_NAME=$(./$0 stack output S3BucketName)
    if [ -z "$BUCKET_NAME" ]; then exit 1; fi
    aws s3 sync dist s3://$BUCKET_NAME
    exit 0
fi

if [ "$1 $2" = "create stack" ]; then
    aws cloudformation create-stack \
        --on-failure DO_NOTHING \
        --stack-name "$STACK_NAME" \
        --template-body "file://template.yaml" \
        --parameters file://$PARAMETER_FILE \
        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

    echo "after stack has been created don't forget to run 'cmd upload dist'"
    exit 0
fi

if [ "$1 $2" = "update stack" ]; then
    aws cloudformation update-stack \
        --stack-name "$STACK_NAME" \
        --template-body file://template.yaml \
        --parameters file://$PARAMETER_FILE \
        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
    exit 0
fi

if [ "$1 $2" = "clear bucket" ]; then
    BUCKET_NAME=$(./$0 stack output S3BucketName)
    OUTPUT=$(aws s3 rm s3://$BUCKET_NAME --recursive 2>&1)
    if [ $? != 254 ]; then
        echo $OUTPUT
    fi
    exit 0
fi

if [ "$1 $2" = "delete stack" ]; then
    ./$0 clear bucket
    aws cloudformation delete-stack \
        --stack-name "$STACK_NAME"
    exit 0
fi

function echo_overwrite() {
    echo -en "\r                                                     "
    echo -en "\r\r$1"
}

if [ "$1 $2" = "stack status" ]; then
    if [ "$3" = "--single" ]; then
        RUN_ONCE=true
    else
        RUN_ONCE=false
    fi

    echo -en "retrieving status ..."
    while true; do
        OUTPUT=$(aws cloudformation describe-stacks \
            --stack-name "$STACK_NAME" \
            --query "Stacks[0].StackStatus" \
            --output text 2>&1)
        if [ $? = 254 ]; then
            echo_overwrite "stack does not exist"
        else
            echo_overwrite $OUTPUT
        fi
        if [ $RUN_ONCE = true ]; then
            echo ""
            exit 0
        fi
        sleep 1
    done
    exit 0
fi

if [ "$1 $2" = "stack logs" ]; then
    aws cloudformation describe-stack-events \
        --stack-name "$STACK_NAME" \
        --query "StackEvents[].[ResourceStatus, ResourceStatusReason, ResourceType]" \
        --output text
    exit 0
fi

if [ "$1 $2" = "stack outputs" ]; then
    aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --query "Stacks[0].Outputs" \
        --output text
    exit 0
fi

if [ "$1 $2" = "stack output" ]; then
    KEY=$3
    if [ -z "$KEY" ]; then exit 1; fi
    aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --query "Stacks[0].Outputs[?OutputKey=='$KEY'].OutputValue" \
        --output text
    exit 0
fi

echo "invalid arguments: $@"

exit 1
