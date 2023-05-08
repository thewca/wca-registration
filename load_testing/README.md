# OVERVIEW

Load testing is done through "Locust", a framework that allows us to define tests using Python.

# SETUP

Ideally you will need pyenv installed. With pyenv installed, run the following command in this directory:

```bash
pyenv virtualenv 3.10.2 load-testing
pyenv local load-testing
```

# TODO
x Set up virtualenv
x Install locust
x Visit homepage (basic locust script)
x Log in using hardcoded credentials
- Try and submit a registration to staging using Locust (only 1 user)
    - Figure out what the registration payload is
        - Capture form sent by my browser when registering for a competition
        - Check if event ID's change per-competition?
- Try and submit registrations for 2 users reading from a dict
- Generate a bunch of registration information and put it in a CSV, then run locust tests based on it


authenticity_token=6M3eNZfhf1uwaUI-qvLN1caRHgZmacfSI-YCulIs5yC4tHJzIrv3EaXekNPI-q5rbuRxg6GyvNKJaZfrCvg85w&reistration%5Bregistration_competition_events_attributes%5D%5B0%5D%5Bcompetition_event_id%5D=86897&registration%5Bregistration_competition_events_attributes%5D%5B0%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B0%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B0%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B1%5D%5Bcompetition_event_id%5D=86912&registration%5Bregistration_competition_events_attributes%5D%5B1%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B1%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B2%5D%5Bcompetition_event_id%5D=86913&registration%5Bregistration_competition_events_attributes%5D%5B2%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B2%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B3%5D%5Bcompetition_event_id%5D=86914&registration%5Bregistration_competition_events_attributes%5D%5B3%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B3%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B4%5D%5Bcompetition_event_id%5D=86915&registration%5Bregistration_competition_events_attributes%5D%5B4%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B4%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B5%5D%5Bcompetition_event_id%5D=86916&registration%5Bregistration_competition_events_attributes%5D%5B5%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B5%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B6%5D%5Bcompetition_event_id%5D=86917&registration%5Bregistration_competition_events_attributes%5D%5B6%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B6%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B7%5D%5Bcompetition_event_id%5D=86918&registration%5Bregistration_competition_events_attributes%5D%5B7%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B7%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B8%5D%5Bcompetition_event_id%5D=86919&registration%5Bregistration_competition_events_attributes%5D%5B8%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B8%5D%5Bid%5D=&registration%5Bcomments%5D=&commit=Register%21
