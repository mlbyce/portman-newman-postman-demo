#!/bin/bash

set -e

function warn() { printf "\033[31m$1\033[0m\n"; }
function usage() {
    warn "$1"
    warn ""
    warn "USAGE: $0 -u <USER_POOL_ID> -p <PASS> -c <NUMBER_OF_USERS> -s <START_COUNT> -n <FIRST_NAME> -d <LAST_NAME> -d"
    warn " Where..."
    warn "  -u is the Cognito IDP user-pool-id"
    warn "  -p is the user password"
    warn "  -c is the number of users to create or delete"
    warn "     Default = 1"
    warn "  -s is the starting index for user creation/deletion"
    warn "     Default = 1"
    warn "  -d if present deletes the emails instead of creating them"
    warn "  -f is the base first name for each user. Also used to create email"
    warn "     Default = Bogus... produces Bogus[123..x].User[123..x] with email bogus[123..x]@user[123..x]"
    warn "  -l is the domain \(and base lastName\) name for each user"
    warn "     Default = User... produces Bogus[123..x].User[123..x] with email bogus[123..x]@user[123..x]"
    warn ""
    warn "Uses aws-cli to create and confirm multiple cognito \(idp\) users"
    exit 1;
}

#DEFAULTS:
COUNT=1
START=1
FIRST=Bogus
LAST=User

while getopts du:p:c:s:f:l: option
do
  case "${option}" in
    d) DELETE_USER=1 ;;
    u) USER_POOL_ID=${OPTARG} ;;
    p) PASSWORD=${OPTARG} ;;
    c) COUNT=${OPTARG} ;;
    s) START=${OPTARG} ;;
    f) FIRST=${OPTARG} ;;
    l) LAST=${OPTARG} ;;
  esac
done

if [[ -z $USER_POOL_ID || (-z $DELETE_USER && -z $PASSWORD) ]]; then
  usage "You Must Provide a UserPoolID and Password ";
fi

echo Creating/Deletiing $COUNT users with:
echo USER_POOL_ID = $USER_POOL_ID
echo FirstName = $FIRST
echo LastName = $LAST
echo Password = $PASSWORD

for i in $(seq $START $((START + COUNT - 1))); do
    FN=$FIRST$i
    LN=$LAST$i
    EMAIL=$(echo "$FN@$LN.com" | tr '[:upper:]' '[:lower:]')

    if [[ $DELETE_USER ]]
    then
      echo "DELETING $EMAIL"
      aws cognito-idp admin-delete-user --user-pool-id $USER_POOL_ID --username $EMAIL
    else
      echo "Creating user = $FN $LN ($EMAIL)"
      aws cognito-idp admin-create-user --user-pool-id $USER_POOL_ID --username $EMAIL --user-attributes Name=given_name,Value=$FN Name=family_name,Value=$LN Name=email,Value=$EMAIL
      aws cognito-idp admin-set-user-password --user-pool-id $USER_POOL_ID --username $EMAIL --password $PASSWORD --permanent
      echo "Complete $EMAIL"
    fi
done
