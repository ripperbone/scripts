#!/usr/bin/env python3

import argparse
import json
import logging
from logging.handlers import SysLogHandler
import os
import sys
import requests
from time import sleep


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
syslogFormatter = logging.Formatter("%(filename)s:%(lineno)d %(levelname)s %(message)s")
# set up sysout logging
streamHandler = logging.StreamHandler(sys.stdout)
rootLogger.addHandler(streamHandler)


TOKEN = read_key(os.path.join(os.path.expanduser("~"), ".keys", "todoist"))


def add_task(task, project_id=None):
   logging.info(f"Adding task: {task}")

   request_body = {"content": task, "due_string": "today"}

   if project_id is not None:
      request_body["project_id"] = project_id

   counter = 3
   while counter > 0:
      res = requests.post("https://api.todoist.com/api/v1/tasks",
         json=request_body,
         headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"})

      if res.status_code == 200:
         logging.info(f"Adding task: {task} -> Success. Status code 200.")
         break
      else:
         logging.error(f"Task {task} failed: {res.status_code}")
         logging.error(res.content)
         counter -= 1
         logging.error(f"Retrying... attempts left is {counter}")
         sleep(10)


def get_projects():
   logging.info("Listing projects...")

   res = requests.get("https://api.todoist.com/api/v1/projects",
      headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"})

   if res.status_code == 200:
      return res.json()
   else:
      logging.error(res.status_code)
      logging.error(res.content)


def get_tasks(project_id):
   logging.info("Listing tasks...")

   res = requests.get(f"https://api.todoist.com/api/v1/tasks?project_id={project_id}&limit=100",
      headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"})

   if res.status_code == 200:
      return res.json()
   else:
      logging.error(res.status_code)
      logging.error(res.content)


def close_task(task_id):
   logging.info(f"Closing task {task_id}...")

   res = requests.post(f"https://api.todoist.com/api/v1/tasks/{task_id}/close",
      headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"})

   if res.status_code in [200, 204]:
      logging.info(f"Task {task_id} closed")
   else:
      logging.error(res.status_code)
      logging.error(res.content)



def main():
   parser = argparse.ArgumentParser(description="script for adding Todoist tasks")
   parser.add_argument("--log", type=str, help="log output to file")
   parser.add_argument("--syslog", action="store_true", help="log output to syslog")
   subparsers = parser.add_subparsers(dest='sub_command')
   add_parser = subparsers.add_parser("add")
   add_parser.add_argument("tasks", nargs='+', type=str, help="the description of the task")
   add_parser.add_argument("--project_id", type=str, help="the id of the project for the task")
   subparsers.add_parser("projects")
   list_parser = subparsers.add_parser("list")
   list_parser.add_argument("--project_id", type=str, help="the id of the project to list tasks")
   close_parser = subparsers.add_parser("close")
   close_parser.add_argument("task_id", type=str, help="the id of the task to close")

   args = parser.parse_args()

   if args.log is not None:
      fileHandler = logging.FileHandler(args.log)
      fileHandler.setFormatter(logFormatter)
      rootLogger.addHandler(fileHandler)

   if args.syslog is True:
      syslogHandler = SysLogHandler(facility=SysLogHandler.LOG_DAEMON, address="/dev/log")
      syslogHandler.setFormatter(syslogFormatter)
      rootLogger.addHandler(syslogHandler)

   if args.sub_command == "add":
      for task in args.tasks:
         add_task(task, args.project_id)
   elif args.sub_command == "projects":
      projects = get_projects()
      for project in projects["results"]:
         print("%s\t%s" % (str(project['id']), project['name']))
   elif args.sub_command == "list":
      if args.project_id is None:
         for project in filter(lambda p: p["inbox_project"] is True, get_projects()["results"]):
            tasks = get_tasks(project['id'])
            print(json.dumps(tasks, indent=4))
            for task in tasks["results"]:
               print("%s\t%s" % (str(task['id']), task['content']))

            if tasks["next_cursor"] is not None:
               print("> %d tasks" % len(tasks["results"]))
      else:
         tasks = get_tasks(args.project_id)
         for task in tasks["results"]:
            print("%s\t%s" % (str(task['id']), task['content']))

         if tasks["next_cursor"] is not None:
            print("> %d tasks" % len(tasks["results"]))

   elif args.sub_command == "close":
      close_task(args.task_id)
   else:
      parser.print_help()


if __name__ == "__main__":
   main()
