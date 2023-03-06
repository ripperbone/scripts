#!/usr/bin/env python3

import argparse
from pathlib import Path
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


rootLogger = logging.getLogger()
rootLogger.setLevel(logging.INFO)
logFormatter = logging.Formatter("[ %(asctime)s ] %(levelname)s %(message)s")

# set up sysout logging
streamHandler = logging.StreamHandler(sys.stdout)
streamHandler.setFormatter(logFormatter)
rootLogger.addHandler(streamHandler)

# set up file logging if the log location exists
log_file = Path("/var/log/todoist/todoist.log")
if log_file.parent.is_dir():
   fileHandler = logging.FileHandler(log_file)
   fileHandler.setFormatter(logFormatter)
   rootLogger.addHandler(fileHandler)

TOKEN = read_key(os.path.join(os.path.expanduser("~"), ".keys", "todoist"))


def add_task(task):
   logging.info(f"Adding task: {task}")

   res = requests.post("https://api.todoist.com/rest/v2/tasks",
      json={"content": task, "due_string": "today"},
      headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"})

   if res.status_code == 200:
      logging.info("Success! Status code 200.")
   else:
      logging.error(res.status_code)
      logging.error(res.content)


def get_projects():
   logging.info("Listing projects...")

   res = requests.get("https://api.todoist.com/rest/v2/projects",
      headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"})

   if res.status_code == 200:
      return res.json()
   else:
      logging.error(res.status_code)
      logging.error(res.content)


def get_tasks(project_id):
   logging.info("Listing tasks...")

   res = requests.get(f"https://api.todoist.com/rest/v2/tasks?project_id={project_id}",
      headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"})

   if res.status_code == 200:
      return res.json()
   else:
      logging.error(res.status_code)
      logging.error(res.content)


def close_task(task_id):
   logging.info(f"Closing task {task_id}...")

   res = requests.post(f"https://api.todoist.com/rest/v2/tasks/{task_id}/close",
      headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"})

   if res.status_code == 204:
      logging.info(f"Task {task_id} closed")
   else:
      logging.error(res.status_code)
      logging.error(res.content)


def delete_task(task_id):
   logging.info(f"Deleting task {task_id}...")

   res = requests.post(f"https://api.todoist.com/rest/v2/tasks/{task_id}/close",
      headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"})

   if res.status_code == 204:
      logging.info(f"Task {task_id} deleted")
   else:
      logging.error(res.status_code)
      logging.error(res.content)


def main():
   parser = argparse.ArgumentParser(description="script for adding Todoist tasks")
   subparsers = parser.add_subparsers(dest='sub_command')
   add_parser = subparsers.add_parser("add")
   add_parser.add_argument("task", type=str, help="the description of the task")
   subparsers.add_parser("projects")
   list_parser = subparsers.add_parser("list")
   list_parser.add_argument("--project_id", type=str, help="the id of the project to list tasks")
   close_parser = subparsers.add_parser("close")
   close_parser.add_argument("task_id", type=str, help="the id of the task to close")
   delete_parser = subparsers.add_parser("delete")
   delete_parser.add_argument("task_id", type=str, help="the id of the task to delete")

   args = parser.parse_args()

   if args.sub_command == "add":
      add_task(args.task)
   elif args.sub_command == "projects":
      for project in get_projects():
         print("%s: %s" % (str(project['id']).rjust(15), project['name']))
   elif args.sub_command == "list":
      if args.project_id is None:
         for project in filter(lambda p: p["is_inbox_project"] is True, get_projects()):
            for task in get_tasks(project['id']):
               print("%s: %s" % (str(task['id']).rjust(15), task['content']))
      else:
         for task in get_tasks(args.project_id):
            print("%s: %s" % (str(task['id']).rjust(15), task['content']))

   elif args.sub_command == "close":
      close_task(args.task_id)
   elif args.sub_command == "delete":
      delete_task(args.task_id)
   else:
      parser.print_help()


if __name__ == "__main__":
   main()
