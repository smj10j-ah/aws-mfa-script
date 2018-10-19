#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

ALIAS_PATH="${DIR}/alias.sh"

echo "source '${ALIAS_PATH}'" >> ~/.bash_profile


