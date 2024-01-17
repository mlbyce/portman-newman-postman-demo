#!/bin/bash
set -e

function warn() { printf "\033[31m$1\033[0m\n"; }
function usage() {
    warn "USAGE: $0 -r <REGION> -s <STAGE> -t"
    warn " Where..."
    warn "  -s is the deployment stage"
    warn "     REQUIRED (e.g. -s dev)"
    warn "  -r is the deployment region"
    warn "     Default = us-east-1"
    warn "  -t Build Terraform only (No src build)"
    warn "     Default = Build all"
    warn "  -a turns on auto-approve for Terraform Apply"
    warn "     Default = No auto-approve"
    warn "  -h Returns this help message"
    exit 1;
}

#DEFAULTS:
REGION=us-east-1

while getopts ahr:s:t option
do
  case "${option}" in
    a) AUTO="--auto-approve" ;;
    h) HELP=1 ;;
    r) REGION=${OPTARG} ;;
    s) STAGE=${OPTARG} ;;
    t) NOCODEBUILD=1 ;;

  esac
done

echo "STAGE = $STAGE"
echo "REGION = $REGION"

if [[ -z $STAGE || $HELP ]]; then
    usage;
fi

if [[ -z $NOCODEBUILD ]]; then
    for i in $(find . -type f -not -path "*/\.git/*" -not -path "*node_modules*" | grep package.json); do
        echo $i;
        pushd $(dirname $i);
        yarn;
        tsc;
        cp -r node_modules dist;
        cd dist;
        esbuild --bundle --platform=node index.js --outfile=out.js;
        rm -rf node_modules;
        mv out.js index.js
        popd;
    done;
fi

terraform init
terraform plan -var region=${REGION} -var stage=${STAGE}
terraform apply -var region=${REGION} -var stage=${STAGE} $AUTO
