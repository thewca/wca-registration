from locust import HttpUser, task, between
import time

competition_id = "HessenOpen2023"

class TestUser(HttpUser):
    def on_start(self):
        self.endpoint = "//register"
        self.registered = False
        self.wca_id = "2021SMIT02"
        

    @task
    def submit_registration(self):
        while self.registered:
            time.sleep(1)

        # registration_data = {
        #         "competitor_id":self.wca_id,
        #         "competition_id":competition_id,
        #         "event_ids":["3x3", "4x4"]
        #         }

        # headers = {
        #     "Content-Type":"application/json"
        #         }

        boundary = "---------------------------123456789012345678901234567890"

        headers = {
            "Content-Type": f"multipart/form-data; boundary={boundary}"
        }

        payload = (
            f"--{boundary}\r\n"
            f"Content-Disposition: form-data; name=\"competitor_id\"\r\n\r\n"
            f"{self.wca_id}\r\n"
            f"--{boundary}\r\n"
            f"Content-Disposition: form-data; name=\"competition_id\"\r\n\r\n"
            f"{competition_id}\r\n"
            f"--{boundary}\r\n"
            f"Content-Disposition: form-data; name=\"event_ids[]\"\r\n\r\n"
            f"4x4\r\n"
            f"--{boundary}--\r\n"
        )

        self.client.post(f"{self.endpoint}", headers=headers, data=payload)



        # self.client.post(f"{self.endpoint}", headers=headers, data=registration_data)
        self.registered = True
