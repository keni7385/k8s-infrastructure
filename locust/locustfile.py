# to install locust: pip install locustio

import warnings
warnings.filterwarnings("ignore") # used to suppress STDERR messages

from locust import HttpLocust, TaskSet, task
class UserBehavior(TaskSet):
    def on_start(self):
        self.client.verify = False
        self.client.get("/")
    
    @task
    def index(self):
        self.client.get("/")

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 5000
    max_wait = 15000