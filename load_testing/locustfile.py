from locust import HttpUser, task, between
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


    def extract_auth_token(self, html):
        # Use a regular expression to extract the authenticity token from the HTML response
        match = re.search(r'<input[^>]+name="authenticity_token"[^>]+value="([^"]+)"', html)
        if match:
            return match.group(1)
        else:
            raise ValueError("Could not extract authenticity token from login page")
