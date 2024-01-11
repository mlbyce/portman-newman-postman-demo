#!/bin/bash
set -e

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

terraform init
terraform plan
terraform apply # --auto-approve
