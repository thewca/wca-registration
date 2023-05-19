# OVERVIEW

Load testing is done through "Locust", a framework that allows us to define tests using Python.

This implementation doesn't deviate much in principle from the documentation. Specifically:
- (Quickstart)[https://docs.locust.io/en/stable/quickstart.html]
- (Writing a locustfile)[https://docs.locust.io/en/stable/writing-a-locustfile.html]

Some complexities above what is covered in the documentation above are:
- some more complex logic is used in `locustfile.py` to ensure that duplicate WCA IDs are not selected (giving each worker its own subset of WCA IDs, and then apportioning those among each worker's virtual user using the worker's unique greenlet index)
- load shape is used in `poc_locustfile.py` to test autoscaling. See the documentation: https://docs.locust.io/en/stable/custom-load-shape.html

When testing on staging, the following URL should be specified as "host" in the Web UI: https://staging.worldcubeassociation.org

When testing the registration microservice, the host is: https://registration.worldcubeassociation.org

When monitoring server performance under load, there are a few options:
- NewRelic dashboard
- AWS Dashboard
- running "htop" on the server itself (this is what I usually use)


# SETUP & USAGE

## Switching between headless and web UI

Assuming you are using `docker compose up --scale worker=4` to run the load tests, this is a case of changing the "command" under the "master" service in docker-compose.yml:
* Headless: `-f /mnt/locust/locustfile.py --master -H http://master:8089 --headless -u 1000 -r 200 --expect-workers=4 --run-time 30`
* With web UI: `-f /mnt/locust/locustfile.py --master -H http://master:8089`

Note that headless also includes a runtime constraint, so that errors are shown.

Locust supports saving results as a CSV if better output is needed: https://docs.locust.io/en/stable/retrieving-stats.html

## With docker

_Note that this runs the correct containers, but I haven't gotten tests with it working - I'm getting failures that indicate a lack of internet connection.

Source: https://docs.locust.io/en/stable/running-in-docker.html

1. you might need to run `docker pull locustio/locust` - not sure on this yet

2. Clone this repo and cd into `load_testing`

3. Build the image: `docker build -t wca-locust .`

4. Run the image (specify number of workers with `--scale worker={num_workers}`): `docker compose up --scale worker=4`

5. (Optional) If running a file not called "locustfile.py", specify it by changing the filename following the `-f` flag in the "command" section of the the docker-compose file. you can also create a new docker-compose file (eg, `docker-compose.poc.yml`, and it with `docker-compose -f docker-compose.poc.yml up --scale worker={num_workers}`)

## Manual Setup

Ideally you will need pyenv installed. With pyenv installed, run the following command in this directory:

```bash
cd wca-registration
pyenv virtualenv 3.10.2 load-testing
pyenv local load-testing
pip install requirements.txt
cd load_testing
```

Once locust is installed, you can run it by running `locust` in the console. Then open the port it specifies in your browser (usually 0.0.0.0:8089). From there you can enter your hostname ("https://staging.worldcubeassociation.org" if you want to test on staging), your peak users, and users spawned per second. 

Note that you may have to increase the amount of files your OS allows to be open at once in order to run more than 1000 virtual users - a console warning will prompt you towards instructions to achieve this on your OS.  
