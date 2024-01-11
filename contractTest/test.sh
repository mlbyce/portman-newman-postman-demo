#!/bin/bash

set -e

function warn() { printf "\033[31m$1\033[0m\n"; }
function usage() {
    warn "USAGE: $0 -s [ dev | stg | prd ] [-v] [-f]";
    warn "  Where -v enables Verbose output";
    warn "  And -f Forces the Setup collection to be run";
    warn ""
    warn "  APINAME must be set in the environment with the following files defined:";
    warn "  - <APINAME>Exec.json";
    warn "  - <APINAME>Setup.json";
    warn "  - <STAGE><APINAME>Env.json";
    exit 1;
}

while getopts vfs: option
do
  case "${option}" in
    f) FORCE=1 ;;
    s) STAGE=${OPTARG} ;;
    v) VERBOSE="--verbose" ;;
  esac
done

if [[ -z $STAGE || ($STAGE != "dev" && $STAGE != "stg" && $STAGE != "prd") || -z $APINAME ]]; then
  usage;
fi

echo Testing with STAGE = $STAGE;
ENVFILE=${STAGE}EnvOut.json;
if [[ ! -e $ENVFILE || $FORCE ]]; then
  echo Setting Up Test Environment;
  newman run ${APINAME}Setup.json \
      -e ${STAGE}${APINAME}Env.json $VERBOSE \
      --export-environment $ENVFILE \
      --reporters cli --reporter-cli-no-banner $(test $VERBOSE || echo --reporter-silent);
fi

BEARER_TOKEN=$(jq '.values | map(select(.key == "bearerToken"))[0].value' < $ENVFILE | sed 's/\"//g')

if [[ -z $BEARER_TOKEN || $BEARER_TOKEN == "null" ]]; then
  printf "\n\033[31mFailed to generate an AuthToken for this test run.\033[0m\n";
  exit 1;
fi

newman run ${APINAME}Exec.json \
  -e $ENVFILE $VERBOSE \
  --env-var "bearerToken=$BEARER_TOKEN" \
  --folder "Contract Tests" \
  --folder "Variation Tests" \
  --folder "Integration Tests" \
  -r cli,html --reporter-cli-no-banner 
  # --r cli,json --reporter-cli-no-banner --reporter-json-export ${STAGE}Report.json
