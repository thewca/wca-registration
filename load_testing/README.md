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
    x Figure out what the registration payload is
        x Capture form sent by my browser when registering for a competition
        x Check if event ID's change per-competition?
    - Figure out how to specify registration form parameters
        - Hardcode them for each comp
        - Programmatically generate them/extract them from the html
- Try and submit registrations for 2 users reading from a dict
- Generate a bunch of registration information and put it in a CSV, then run locust tests based on it


authenticity_token=6M3eNZfhf1uwaUI-qvLN1caRHgZmacfSI-YCulIs5yC4tHJzIrv3EaXekNPI-q5rbuRxg6GyvNKJaZfrCvg85w
&reistration[registration_competition_events_attributes][0][competition_event_id]=86897
&registration[registration_competition_events_attributes][0][_destroy]=1
&registration[registration_competition_events_attributes][0][_destroy]=0
&registration[registration_competition_events_attributes][0][id]=
&registration[registration_competition_events_attributes][1][competition_event_id]=86912
&registration[registration_competition_events_attributes][1][_destroy]=1
&registration[registration_competition_events_attributes][1][id]=
&registration[registration_competition_events_attributes][2][competition_event_id]=86913
&registration[registration_competition_events_attributes][2][_destroy]=1
&registration[registration_competition_events_attributes][2][id]=
&registration[registration_competition_events_attributes][3][competition_event_id]=86914
&registration[registration_competition_events_attributes][3][_destroy]=1
&registration[registration_competition_events_attributes][3][id]=
&registration[registration_competition_events_attributes][4][competition_event_id]=86915
&registration[registration_competition_events_attributes][4][_destroy]=1
&registration[registration_competition_events_attributes][4][id]=
&registration[registration_competition_events_attributes][5][competition_event_id]=86916
&registration[registration_competition_events_attributes][5][_destroy]=1
&registration[registration_competition_events_attributes][5][id]=
&registration[registration_competition_events_attributes][6][competition_event_id]=86917
&registration[registration_competition_events_attributes][6][_destroy]=1
&registration[registration_competition_events_attributes][6][id]=
&registration[registration_competition_events_attributes][7][competition_event_id]=86918
&registration[registration_competition_events_attributes][7][_destroy]=1
&registration[registration_competition_events_attributes][7][id]=
&registration[registration_competition_events_attributes][8][competition_event_id]=86919
&registration[registration_competition_events_attributes][8][_destroy]=1
&registration[registration_competition_events_attributes][8][id]=
&registration[comments]=
&commit=Register%21


From script:
auth_token=NWMxdaHNDw_2FllbWl1NlF6kSUV_DQtVMTb892hQycpFy3xs1vUC9MLMa4KFvmjry5hgxlRPU2z62xrnhexyKw&registration%5Bregistration_competition_events_attributes%5D%5B0%5D%5Bcompetition_event_id%5D=86897&registration%5Bregistration_competition_events_attributes%5D%5B0%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B0%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B1%5D%5Bcompetition_event_id%5D=86912&registration%5Bregistration_competition_events_attributes%5D%5B1%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B1%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B2%5D%5Bcompetition_event_id%5D=86913&registration%5Bregistration_competition_events_attributes%5D%5B2%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B2%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B3%5D%5Bcompetition_event_id%5D=86914&registration%5Bregistration_competition_events_attributes%5D%5B3%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B3%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B4%5D%5Bcompetition_event_id%5D=86915&registration%5Bregistration_competition_events_attributes%5D%5B4%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B4%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B5%5D%5Bcompetition_event_id%5D=86916&registration%5Bregistration_competition_events_attributes%5D%5B5%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B5%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B6%5D%5Bcompetition_event_id%5D=86917&registration%5Bregistration_competition_events_attributes%5D%5B6%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B6%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B7%5D%5Bcompetition_event_id%5D=86918&registration%5Bregistration_competition_events_attributes%5D%5B7%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B7%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B8%5D%5Bcompetition_event_id%5D=86919&registration%5Bregistration_competition_events_attributes%5D%5B8%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B8%5D%5Bid%5D=&registration%5Bcomments%5D=&commit=Register%21
authenticity_token=08nnJbazSpinLmV6i0khtc2ixyCWAutwWgqNmCTbuoD3CeiJYR4Q38rTRYNWyR_PKaJ_RbEGxtVXWLIXGeXz_A&registration%5Bregistration_competition_events_attributes%5D%5B0%5D%5Bcompetition_event_id%5D=86897&registration%5Bregistration_competition_events_attributes%5D%5B0%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B0%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B0%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B1%5D%5Bcompetition_event_id%5D=86912&registration%5Bregistration_competition_events_attributes%5D%5B1%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B1%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B1%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B2%5D%5Bcompetition_event_id%5D=86913&registration%5Bregistration_competition_events_attributes%5D%5B2%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B2%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B2%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B3%5D%5Bcompetition_event_id%5D=86914&registration%5Bregistration_competition_events_attributes%5D%5B3%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B3%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B3%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B4%5D%5Bcompetition_event_id%5D=86915&registration%5Bregistration_competition_events_attributes%5D%5B4%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B4%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B4%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B5%5D%5Bcompetition_event_id%5D=86916&registration%5Bregistration_competition_events_attributes%5D%5B5%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B5%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B5%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B6%5D%5Bcompetition_event_id%5D=86917&registration%5Bregistration_competition_events_attributes%5D%5B6%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B6%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B6%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B7%5D%5Bcompetition_event_id%5D=86918&registration%5Bregistration_competition_events_attributes%5D%5B7%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B7%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B7%5D%5Bid%5D=&registration%5Bregistration_competition_events_attributes%5D%5B8%5D%5Bcompetition_event_id%5D=86919&registration%5Bregistration_competition_events_attributes%5D%5B8%5D%5B_destroy%5D=1&registration%5Bregistration_competition_events_attributes%5D%5B8%5D%5B_destroy%5D=0&registration%5Bregistration_competition_events_attributes%5D%5B8%5D%5Bid%5D=&registration%5Bcomments%5D=&commit=Register%21

