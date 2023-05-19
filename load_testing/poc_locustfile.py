from locust import HttpUser, task, between
from locust import LoadTestShape
import random
import csv
import time

competition_id = "HessenOpen2023" # Can be any competition_id from WCA website (wca.org/competitions/{competition_id})


# Read in the list of WCA IDs
wca_ids = []
with open("wca_id_list.csv", "r") as id_list:
    reader = csv.reader(id_list)
    for row in reader:
        wca_ids.append(row[0])

# Global test options
one_registration_per_user = False
use_demand_shape = True

class TestUser(HttpUser):
    def on_start(self):
        self.endpoint = "//register"
        self.registered = False

    @task
    def submit_registration(self):
        """Submits a registration to the /register endpoint using multipart form data."""

        self.wca_id = wca_ids.pop(random.randint(0, len(wca_ids)))

        while self.registered and one_registration_per_user:
            time.sleep(1)

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





class StagesShape(LoadTestShape):
    """
    A simply load test shape class that has different user and spawn_rate at
    different stages.

    Keyword arguments:

        stages -- A list of dicts, each representing a stage with the following keys:
            duration -- When this many seconds pass the test is advanced to the next stage
            users -- Total user count
            spawn_rate -- Number of users to start/stop per second
            stop -- A boolean that can stop that test at a specific stage

        stop_at_end -- Can be set to stop once all stages have run.
    """

    if use_demand_shape:

        # Currently specifying this manually is ok - but if we want to edit it a lot, or have more stages, creating a function will be the right way to go.
        stages = [ 
            {"duration": 60, "users": 6, "spawn_rate": 1},
            {"duration": 120, "users": 13, "spawn_rate": 1},
            {"duration": 180, "users": 20, "spawn_rate": 1},
            {"duration": 240, "users": 26, "spawn_rate": 1},
            {"duration": 300, "users": 33, "spawn_rate": 1},
            {"duration": 360, "users": 40, "spawn_rate": 1},
            {"duration": 420, "users": 46, "spawn_rate": 1},
            {"duration": 480, "users": 53, "spawn_rate": 1},
            {"duration": 540, "users": 60, "spawn_rate": 1},
            {"duration": 600, "users": 66, "spawn_rate": 1},
            {"duration": 660, "users": 73, "spawn_rate": 1},
            {"duration": 720, "users": 80, "spawn_rate": 1},
            {"duration": 780, "users": 86, "spawn_rate": 1},
            {"duration": 840, "users": 93, "spawn_rate": 1},
            {"duration": 900, "users": 100, "spawn_rate": 1},
            {"duration": 11000, "users": 100, "spawn_rate": 1}, # Final stage just lets us run at max demand for a while before quitting
        ]

        def tick(self):
            run_time = self.get_run_time()

            for stage in self.stages:
                if run_time < stage["duration"]:
                    tick_data = (stage["users"], stage["spawn_rate"])
                    return tick_data

            return None
