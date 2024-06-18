# Portman / Newman Demo

A Demo/Tutorial on the use of Portman/Newman to create tests from OAS3 documents with live Terraform stack for hands-on experience.

For reference:

- [Portman](https://github.com/apideck-libraries/portman): Creating scripted PostMan collections from a OAS.yaml file

- [Newman](https://github.com/postmanlabs/newman): Running the Postman collection scripts through CLI

## Setup:

You will need these tools installed on your machine:

- aws-cli
- terraform
  ```
  brew install terraform
  ```
- portman
  ```
  npm install -g @apideck/portman
  ```
- newman
  ```
  npm install -g newman
  ```
- newman-reporter-html (Not essential but produces a nice visual report)
  ```
  npm install -g newman-reporter-html
  ```

To run this demo, first deploy the 'Bogus API' with the following process, using Terraform:

- Connect to a (Sandbox) AWS Profile that you can deploy to safely (i.e. you can run `aws s3 ls`)
- Build and deploy using [build.sh](build.sh) _(or do the steps in that script manually if you prefer)_.
  This script builds the Lambdas an executes the Terraform steps to deploy but prompts the user for the final "yes"
  unless you enter the "-a" commandLine option. The only required option is "-s <STAGE>"... here is the full list of options:

  ./build.sh -s \<STAGE\> -r \<REGION\> -t -a

  - -s is the deployment stage: REQUIRED (e.g. -s dev)
  - -r is the deployment region: Default = us-east-1
  - -t Build Terraform only (No src build): Default = Build all
  - -a turns on auto-approve for Terraform Apply: Default = No auto-approve

  So for a normal deployment to **dev**,

  ```
  ./build.sh -s dev
  ```

- Note the output from the deployment:

  ```
  api_key = <sensitive>
  base_url = "<BASE_URL>"
  user_pool_client_id = "<USER_POOL_CLIENT_ID>"
  user_pool_id = "<USER_POOL_ID>"
  ```

- And retrieve the obfuscated apiKey that was generated in the process:
  ```
  terraform output api_key
  ```
- Navigate to the `contractTest` directory for the rest of this exercise
- Copy the [`bogusApiEnv.json.example`](contractTest/bogusApiEnv.json.example) file to `devBogusApiEnv.json` and plug these four values into the placeholders.

  You will also need to set the `<USER_EMAIL>` and `<USER_PASSWORD>` in `devBogusApiEnv.json` after you create your main test user... in the steps that follow.

- Change the `baseUrl` value in [`portman-cli-options.yml`](contractTest/portman-cli-options.yml) to the newly-created `<BASE_URL>` as well.

If you ever loose the values you can always get them from the AWS Console or just run:

```
# From the root directory
terraform show
terraform output api_key
```

For future convenience, set these environment variables:

```
USER_POOL_ID=<USER_POOL_ID>
USER_POOL_CLIENT_ID=<USER_POOL_CLIENT_ID>
PASSWORD=<USER_PASSWORD>
```

You need at least one CONFIRMED user to run with a `<USER_EMAIL>` and `<USER_PASSWORD>` to plug into your configured `devBogusApiEnv.json`.

To create that main user, and maybe a few more if you are experimenting, run the [userCreate.sh](contractTest/userCreate.sh) script. It uses `aws cognito-idp admin-*` commands to create / delete users... Of course, if you have a better/favorite way to accomplish this, knock yourself out 😊

As an example to create 4 users with these names (emails) and all having the same password...

- Bogus1 User1 (bogus1@user1.com)
- Bogus2 User2 (bogus2@user2.com)
- Bogus3 User3 (bogus3@user3.com)
- Bogus4 User4 (bogus4@user4.com)

Execute this command:

```
./userCreate.sh -c $USER_POOL_CLIENT_ID -u $USER_POOL_ID -p $PASSWORD -n 4
```

Then to delete only `bogus2@user2.com` and `bogus3@user3.com`, (note the -d parameter) enter:

```
./userCreate.sh -c $USER_POOL_CLIENT_ID -u $USER_POOL_ID -n 2 -s 2 -d
```

If you want to have a different name say, Joe[1234] Cool[1234] (joe[1234]@cool[1234].com), supply -f and -l

```
./userCreate.sh -c $USER_POOL_CLIENT_ID -u $USER_POOL_ID -p $PASSWORD -n 4 -f Joe -l Cool
```

## Run The Tests:

You can execute the tests using either Postman or Newman.

To generate the tests from the [oas3.yml](contractTest/oas3.yml) definition and existing portman configuration run:

```
portman --cliOptionsFile portman-cli-options.yml
```

This will output the file `bogusApiExec.json` Postman Collection complete with tests.
Execute the same command whenever changes have been made to the [oas3.yml](contractTest/oas3.yml) or `portman-XXX.yml` files.

_NOTE: If you just want to quickly create a testable Postman collection from the [oas3.yml](contractTest/oas3.yml) file has `out-of-the-box` ContractTests for each endpoint, run this command:_

```
portman -l oas3.yml
```

_This will create a Postman collection at `./tmp/converted/<The API Name in camelCase>.json>` and is really a good starting point creating Newman tests. Just drag-and-drop this file into Postman for inspection._

There are three files that are generated or manually created that fully define the test environment:
| FileName | Description | Genesis |
| --- | --- | --- |
| devBogusApiEnv.json | Environment variables used by the exec an setup collections | Manually created from copy of [bogusApiEnv.json.example](contractTest/bogusApiEnv.json.example) |
| bogusApiExec.json | Postman Collection containing all of the Contract, Variation and Integration tests | Autogenerated output from `portman` |
| bogusApiSetup.json | Postman Collection containing the initial setup tests to run before executing the first test | Static, manually created and checked in to repo |

## Early Warning Of Expected Failing Tests:

You will most likely see 6 failed tests when you run entire test collection with Postman or Newman. This is is because each of the endpoints that is covered by a Cognito JWT Authorization has an associated test to see that a "Token Is Expired" error happens when a token is actually expired. There is is a bit of chicken-an-egg problem here in that the token that is tested must be a token that originates on the Cognito UserPool/Client that was created in the initial deploy of this stack in your AWS account.

So, in order to create an expired token for the 6 tests to pass, you have to first plug a valid JWT `{{bearerToken}}` value from either the `TEST_BogusAPI` environment (when running tests in Postman) or the `devEnvOut.json` file (when running tests with Newman) into the `<EXPIRED_TOKEN>` value for the `expiredBearerToken` key in `devBogusApiEnv.json`.

But this can only happen after an initial test run has been executed. And the test will continue to fail until the token that was initially created actually expires at exactly one hour after first `{{bearerToken}}` was created.

### Postman:

To run in Postman, just drag-and-drop these three files into Postman:

- devBogusApiEnv.json
- bogusApiExec.json
- bogusApiSetup.json

Then, in Postman, select the `TEST_BogusAPI` environment and run the `Bogus API Setup` Collection followed by the `Bogus API Test` Collection.

_NOTE: Endpoints that are not simple enough to work unaltered as basic a `Contract Test` are intentionally removed from that section and covered in some other `Variation` or `Integration` test as needed. Any endpoints that were not covered in the `Contract Test` test section will show up in a separate folder matching the "operationId" associated with that endpoint. These can either be removed (if you don't want to look at them) or ignored. They don't have any defined tests so they are NO-OPs._

### Newman:

To run in Neman (if the previous setup steps were completed correctly), you should just be able to just run the test script:

```
APINAME=bogusApi ./test.sh -s dev -v -f
```

If you installed `newman-reporter-html` earlier, there should be a timestamped `newman-run-report.html` report under the `newman` directory.

# Cleanup:

When you are all done having fun with this stack, remember to destroy the lot with:

```
# From the root directory
# Note that the region variable is required if deployed to any region other than the default (us-east-1)
terraform destroy -var region=${REGION}
```
### Infrastructure model
![mlbyce_newman-portman-demo](https://github.com/mlbyce/newman-portman-demo/assets/173192552/25ac8511-138d-4820-a0e5-86efbaaa6137)
