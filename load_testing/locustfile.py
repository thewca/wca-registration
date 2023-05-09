from locust import HttpUser, task, between
import random
from bs4 import BeautifulSoup
import time
import csv

debug = True
target_comp = "/competitions/WiltshireSummer2023"
wca_ids = []

with open("wca_id_list.csv", "r") as id_list:
    reader = csv.reader(id_list)
    for row in reader:
        wca_ids.append(row[0])

print(wca_ids)



class TestUser(HttpUser):

    def on_start(self):
        self.registered = False 

        # Pop credentials from list
        wca_id = wca_ids.pop(random.randint(0, len(wca_ids)))
        print(wca_id)

        # Logs the user in
        response = self.client.get("/users/sign_in")
        auth_token = self.extract_auth_token(response.text)

        response = self.client.post("/users/sign_in", data={
            "authenticity_token": auth_token,
            "user[login]": wca_id,
            "user[password]": "wca",
            "user[remember_me]": "0",
            "commit": "Sign in"
            })

        if debug:
            # create soup from response and write it to a file
            soup = BeautifulSoup(response.text, "html.parser")
            with open("login_soup.html", "w") as f:
                f.write(soup.prettify())

    @task
    def register_for_comp(self):
        while self.registered:
            # Sleep the worker if user is already registered - could just return, but that will tank CPU performance as it will keep trying to run this task
            # Process needs to be manually killed in console with Ctrl+C
            time.sleep(1)

        # Navigate to registration page and extract auth token
        response = self.client.get(f"{target_comp}/register")
        registration_data = {
                "authenticity_token": self.extract_auth_token(response.text)
                }

        # Add event data from registration page
        registration_data = self.add_default_registration_data(response.text, registration_data)

        # Add comment and commit
        registration_data["registration[comments]"] = ""
        registration_data["commit"] = "Register!"

        print("Registration data to be submitted")
        for key in registration_data:
            print(f"{key}: {registration_data[key]}")

        response = self.client.post(f"{target_comp}/registrations", data = registration_data)

        self.registered = True

    def extract_auth_token(self, html):
        # Convert html to a BeautifulSoup object
        soup = BeautifulSoup(html, 'html.parser')

        # find the input called "authenticity_token"
        inputs = soup.find_all('input')
        for input in inputs:
            if input["name"] == "authenticity_token":
                return input["value"]
        else: 
            print("No auth token found.")

    def add_default_registration_data(self, html: str, registration_data: dict) -> dict:

        # Convert html to a BeautifulSoup object
        soup = BeautifulSoup(html, 'html.parser')

        if debug:
            # prettify the soup object and write it to a file
            with open("register_soup.html", "w") as f:
                f.write(soup.prettify())

        # get spans containing the event checkboxes
        event_spans = soup.find_all('span', {'class': 'event-checkbox'})

        # loop through the spans and add the input key/value pairs to registration data
        for event_span in event_spans:
            inputs = event_span.find_all('input')
            for input_tag in inputs:
                name = input_tag['name']

                # Special case for the "id" tag, as if the registration is being submitted for the first time it won't have a "value" field.
                if name.find("id") > -1:
                    try:
                        value = input_tag['value']
                    except KeyError:
                        print("no value found in tag keys")
                        value = ""
                else:
                    value = input_tag['value']

                registration_data[name] = value

        # now form_data contains a dict of input names and values
        return registration_data
