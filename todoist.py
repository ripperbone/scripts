#!/usr/bin/env python3


import logging
import os
import sys
import requests


def read_key(path):
   text = None
   try:
      with open(path, 'r') as f:
         text = f.read().rstrip()
   except FileNotFoundError:
      logging.error("Could not read key from: %s" % path)
      sys.exit(1)

   return text


logging.basicConfig(filename="/var/log/todoist/todoist.log", encoding="utf-8", level=logging.INFO,
   format="[ %(asctime)s ] %(levelname)s %(message)s")

# log to stdout in addition to file
logging.getLogger().addHandler(logging.StreamHandler(sys.stdout))


def main():
   if len(sys.argv) < 2:
      logging.error("Task argument was not provided")
      sys.exit(1)
   task = sys.argv[1]

   TOKEN = read_key(os.path.join(os.path.expanduser("~"), ".keys", "todoist"))

   logging.info(f"Adding task: {task}")

   res = requests.post("https://api.todoist.com/rest/v2/tasks",
      json={"content": task, "due_string": "today"},
      headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"})

   if res.status_code == 200:
      logging.info("Success! Status code 200.")
   else:
      logging.error(res.status_code)
      logging.error(res.content)


if __name__ == "__main__":
   main()
