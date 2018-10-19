#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

setToken() {
    #do things with parameters like $1 such as
    "${DIR}/mfa.sh" $1 $2
    RES=$?
    if [[ $RES -eq 0 ]]; then
        source ~/.token_file
        echo "Your creds have been set in your env."
    fi
}
alias mfa=setToken
