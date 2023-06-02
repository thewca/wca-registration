from locust import HttpUser, task, between


class EndpointTester(HttpUser):
    wait_time = between(1,3)
    def on_start(self):
        self.comp_name = "CubingUSANationals2023"

    @task
    def wcif_public_request(self):
        self.client.get(f"api/v0/competitions/{self.comp_name}/wcif/public") 
