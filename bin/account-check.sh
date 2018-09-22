#!/bin/bash -e


LOCAL_AWS_ACCOUNT=$(cat ./AWS_ACCOUNT.txt)
REMOTE_AWS_ACCOUNT=$(aws sts get-caller-identity | jq -r '.Account')
echo "LOCAL AWS ACCOUNT: ${LOCAL_AWS_ACCOUNT}"
echo "REMOTE AWS ACCOUNT: ${REMOTE_AWS_ACCOUNT}"

[ "${LOCAL_AWS_ACCOUNT}" == "${REMOTE_AWS_ACCOUNT}" ] && echo "aws accounts match" || echo "aws accounts do not match"
