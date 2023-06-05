# RapidReg - The WCA Registration System

This is the registration system for the World Cube Association and is currently
under development. For more info about the WCA visit the main repo [here](https://github.com/thewca/worldcubeassociation.org)

## How to run

### Running server locally
Run  `docker compose -f docker-compose.dev.yml up`

### Running tests

If you are running tests for development purposes (ie you want to run them multiple times and check passes/fails), do the following:
1. Run the server locally (see instructions above)
2. Open a command prompt in the registration-handler container:
    2.1: Run `docker ps` and note the {container-id} of the wca_registration_handler (eg, "4ac2f5ba2a83")
    2.2: Run `docker exec -it {container-id} bash`
3. Inside the docker container, run `bundle exec rspec`

If you want to build the new swagger file, 

If you want to the test suite once-off, run `docker compose -f "docker-compose.test.yml" up wca_registration_handler --abort-on-container-exit`

## Tests and API Docs

We use [RSwag](https://github.com/rswag/RSwag) to generate the API docs from the structure of our spec (test) files.
- `/swagger/v1` contains the `swagger.yaml` files which define our API spec.
- `swagger.yaml` is automatically generated when you run `rake rswag:specs:swaggerize` in the docker container (see "Running the tests" for instructions to run a command in the docker container)
- With the server running, you can go to localhost:/3001/api-docs to view the swagger-ui
