#!/bin/bash
set -eou pipefail

# parameters
if [ $# -gt 0 ]; then
   PROFILE="$1"
else
   PROFILE="lite"
fi

# pull and build all modules
bash pull-all.sh
bash build-all.sh $PROFILE