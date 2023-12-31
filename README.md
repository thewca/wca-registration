# RapidReg - The WCA Registration System

This is the registration system for the World Cube Association and is currently
under development. For more info about the WCA visit the main repo [here](https://github.com/thewca/worldcubeassociation.org).

## How to run

### Running server locally

Run

```
docker compose -f docker-compose.dev.yml up
```

The frontend will then be running at http://localhost:3002/.

### Running tests

If you are running tests for development purposes (ie you want to run them multiple times and check passes/fails), do the following:

1. Run the server locally (see instructions above)

2. Open a command prompt in the registration-handler container:

   2.1: Run `docker ps` and note the {container-id} of the wca_registration_handler (eg, "4ac2f5ba2a83")

   2.2: Run `docker exec -it {container-id} bash`

3. Inside the docker container, run `bundle exec rspec`

If you want to the test suite once-off, run

```
docker compose -f "docker-compose.test.yml" up wca_registration_handler --abort-on-container-exit
```

## Tests and API Docs

### Running Tests

Connect to the docker container, then use one of the following:

- All tests: `bundle exec rspec`
- A specific folder only: `bundle exec rspec spec/requests/registrations/{file-name}`
- Only success or fail tests in a specific file: `bundle exec rspec spec/requests/registrations/{file-name} -e "{success or fail}`

### RSwag and SwaggerUI

We use [RSwag](https://github.com/rswag/RSwag) to generate the API docs from the structure of our spec (test) files.

- `/swagger/v1` contains the `swagger.yaml` files which define our API spec.
- `swagger.yaml` is automatically generated when you run `rake rswag:specs:swaggerize` in the docker container (see "Running the tests" for instructions to run a command in the docker container)
- With the server running, you can go to localhost:/3001/api-docs to view the swagger-ui

_NOTE:_ Using RSwag can make test definitions appear convoluted. For example:

- You cannot stub requests with WebMock in a `response` block - you have to add a `context` block before the `response` block where the request is stubbed. If you have 4 consecutive tests with 4 different stubbed endpoints, you have to add a `context` block before each test defined in a `response`. It is annoying, but it is the price we pay for the convenience of RSwag

### Running certain tests only

Tests are grouped by "context" into success/fail groups. Add the `-e` flag to run tests matching search terms. So:

- To run success tests only: `bundle exec rspec -e success`
- To run failure tests only: `bundle exec rspec -e failure`

### Resources for Generating Hashes with FactoryBot

https://medium.com/@josisusan/factorygirl-as-json-response-a70f4a4e92a0

## Populating Registrations in Staging Environment

We use a rake task to import registrations into the DynamoDB database. The import bypasses all validations, so it is possible to create registrations in invalid states this way. 

1. Generate the CSV(s)
    1. You'll probably need to generate multiple versions, currently we do the following:
        1. "Base" version with 5 registrations for each registration status - this is imported into all competitions, except the special cases defiend below
        1. 50, 100, 500, 1000, 3000 registrations - we generate files with the specified number of registrations, and import them into competitions
    1. Go to https://docs.google.com/spreadsheets/d/1lWsonsWxDzkEMmcmmcBvyki31V5ktwfh9d8nSedZcxQ/edit#gid=842709564 to generate CSVs
2. Connect to the staging registration handler
    1. AWS Console -> Elastic Container Service -> wca-registration-staging
    2. Tasks -> copy ID of the task in the task list
    3. Run the command `aws ecs execute-command --cluster wca-registration-staging --task {task-id} --container staging-handler --interactive --command "/bin/bash"`
        1. {task-id} is in the ARN, highlighted in the following example: arn:aws:ecs:us-west-2:**285938427530**:cluster/wca-registration-staging
        1. You need to install aws-cli for this to work
3. Now that we're connected to the container, we will need to:
    1. Copy across the rake task and CSVs (so far I've done this by creating the files with vi and manually copying across the raw text of the rake task/CSV)
    2. Run the rake task for each set of CSVs (changing the list of competitions and CSV name for each set of registrations you want to import)

