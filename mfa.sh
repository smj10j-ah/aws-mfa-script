#!/bin/bash
#
# Sample for getting temp session token from AWS STS
#
# aws --profile youriamuser sts get-session-token --duration 3600 \
# --serial-number arn:aws:iam::012345678901:mfa/user --token-code 012345
#
# Once the temp token is obtained, you'll need to feed the following environment
# variables to the aws-cli:
#
# export AWS_ACCESS_KEY_ID='KEY'
# export AWS_SECRET_ACCESS_KEY='SECRET'
# export AWS_SESSION_TOKEN='TOKEN'


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# 1 or 2 args ok
if [[ $# -ne 1 && $# -ne 2 ]]; then
  echo "Usage: $0 <MFA_TOKEN_CODE> <AWS_CLI_PROFILE>"
  echo "Where:"
  echo "   <MFA_TOKEN_CODE> = Code from virtual MFA device"
  echo "   <AWS_CLI_PROFILE> = aws-cli profile usually in $HOME/.aws/config"
  [ $PS1 ] && return || exit 1;
fi

echo "Reading config..."
if [ -r "${DIR}/mfa.cfg" ]; then
  . "${DIR}/mfa.cfg"
else
  echo "No config found.  Please create your mfa.cfg.  See README.txt for more info."
  [ $PS1 ] && return || exit 2;
fi


AWS_COMMAND_PATH="$(which aws 2> /dev/null)"
if [[ -z ${AWS_COMMAND_PATH} ]]; then
    if [[ ! -z ${WINDIR} ]]; then
        # Windows
        AWS_COMMAND_PATH="/c/Program Files/Amazon/AWSCLI/bin/aws.cmd" 
    fi
    if [[ -z ${AWS_COMMAND_PATH} ]]; then
        echo "The AWS CLI doesn't appear to be installed"
	[ $PS1 ] && return || exit 3;
    fi
fi
echo "Using AWS CLI found at ${AWS_COMMAND_PATH}"



AWS_CLI_PROFILE="${2:-default}"
MFA_TOKEN_CODE="$1"
ARN_OF_MFA="${!AWS_CLI_PROFILE}"

echo "AWS-CLI Profile: ${AWS_CLI_PROFILE}"
echo "MFA ARN: ${ARN_OF_MFA}"
echo "MFA Token Code: ${MFA_TOKEN_CODE}"

echo "Your Temporary Creds:"
"${AWS_COMMAND_PATH}" --profile "${AWS_CLI_PROFILE}" sts get-session-token --duration 129600 \
  --serial-number "${ARN_OF_MFA}" --token-code "${MFA_TOKEN_CODE}" --output text \
  | awk '{printf("export AWS_ACCESS_KEY_ID=\"%s\"\nexport AWS_SECRET_ACCESS_KEY=\"%s\"\nexport AWS_SESSION_TOKEN=\"%s\"\nexport AWS_SECURITY_TOKEN=\"%s\"\n",$2,$4,$5,$5)}' | tee ~/.token_file
