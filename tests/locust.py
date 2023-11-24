# In locust.py

from locust import HttpUser, task, constant
import random

class QuickstartUser(HttpUser):
    wait_time = constant(0)
    host = "http://k3s.nmatheus.cloud"

    @task(5)
    def test_get_method(self):
        self.client.get("/")
