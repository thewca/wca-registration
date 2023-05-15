# OVERVIEW

Load testing is done through "Locust", a framework that allows us to define tests using Python.

This implementation doesn't deviate much from the documentation. Specifically:
- (Quickstart)[https://docs.locust.io/en/stable/quickstart.html]
- (Writing a locustfile)[https://docs.locust.io/en/stable/writing-a-locustfile.html]

When testing on staging, the following URL should be specified as "host" in the Web UI: https://staging.worldcubeassociation.org

When monitoring server performance under load, there are a few options:
- NewRelic dashboard
- AWS Dashboard
- running "htop" on the server itself (this is what I usually use)


# SETUP & USAGE

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

# TODO

## Initial setup
x Set up virtualenv
x Install locust
x Visit homepage (basic locust script)
x Log in using hardcoded credentials
x Try and submit a registration to staging using Locust (only 1 user)
    x Figure out what the registration payload is
        x Capture form sent by my browser when registering for a competition
        x Check if event ID's change per-competition?
    - Figure out how to specify registration form parameters
        - Hardcode them for each comp
        - Programmatically generate them/extract them from the html
x Try and submit registrations for 2 users reading from a dict
x Generate a bunch of registration information and put it in a CSV, then run locust tests based on it


## Overcoming errors

Issue: 
- can't spawn users fast enough
- running into OSError101 (no connection)


Solution 1:
- run it through mobile data, see if that helps

Solution 2: Run it from a server
- Figure out how to run locust cli only

Solution 3: Run across multiple machines / cores
