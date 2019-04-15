# to install locust: pip install locustio

import random
import string
import datetime

import warnings
warnings.filterwarnings("ignore") # used to suppress STDERR messages

from locust import HttpLocust, TaskSet, task
class UserBehavior(TaskSet):
    def on_start(self):
        self.client.verify = False
        self.attack()
    
    @task
    def index(self):
        self.attack()
    
    def attack(self):
        psw = ''.join([random.choice(string.ascii_letters + string.digits) for n in range(32)])
        time = str(datetime.datetime.now().time())
        payload = {
            "user": "Malicious Locust",
            "body": "I hacked your passowrd: " + psw + " at time " + time
        }
        self.client.post("/pweets", payload)

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 5000
    max_wait = 15000