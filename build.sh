#!/bin/bash
set -e

for i in $(find . -type f -not -path "*/\.git/*" -not -path "*node_modules*" | grep package.json); do
    echo $i;
    cd $(dirname $i);
    yarn;
    cd -;
done;

terraform init
terraform plan
terraform apply # --auto-approve
