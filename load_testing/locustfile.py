from locust import HttpUser, task, between
from bs4 import BeautifulSoup
import re

credentials = {
    "username": "2019HOBB02",
    "password": "WCA"
        }

class TestUser(HttpUser):

    # @task
    # def visit_homepage(self):
    #     self.client.get("/")

    @task
    def on_start(self):
        # Logs the user in
        response = self.client.get("/users/sign_in")
        auth_token = self.extract_auth_token(response.text)

        response = self.client.post("/users/sign_in", data={
            "authenticity_token": auth_token,
            "user[login]": credentials["username"],
            "user[password]": credentials["password"],
            "user[remember_me]": "0",
            "commit": "Sign in"
            })

        # Navigate to registration page and extract auth token
        response = self.client.get("/competitions/WiltshireSummer2023/register")
        auth_token = self.extract_auth_token(response.text)

        # Build a dict of form input data
        print(self.get_default_registration_data(response))

    # Specify "1" to only perform this task once. Note that if more user tasks are added, this will become a weight on how likely the task is to be performed.
    # @task(1)
    # def register_for_comp(self):
    #     # Navigate to registration page and extract auth token
    #     response = self.client.get("/competitions/WiltshireSummer2023/register")
    #     auth_token = self.extract_auth_token(response.text)

    #     # Build a dict of form input data
    #     print(self.get_default_registration_data(response))




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



        # Use a regular expression to extract the authenticity token from the HTML response
        # match = re.search(r'<input[^>]+name="authenticity_token"[^>]+value="([^"]+)"', html)
        # if match:
        #     return match.group(1)
        # else:
        #     raise ValueError("Could not extract authenticity token from page")

    def get_default_registration_data(self, html):
        # create a dict to hold the form data
        registration_data = {}

        # Convert html to a BeautifulSoup object
        soup = BeautifulSoup(html, 'html.parser')

        # get the div containing the registration form
        form_div = soup.find('div', {'id': 'registration_competition_events'})

        # get spans containing the event checkboxes
        event_spans = form_div.find_all('span', {'class': 'events-checkbox'})

        # loop through the spans and extract the input values
        for event_span in event_spans:
            inputs = event_span.find_all('input')
            for input_tag in inputs:
                name = input_tag['name']
                value = input_tag['value']
                registration_data[name] = value

        # now form_data contains a dict of input names and values
        return registration_data
