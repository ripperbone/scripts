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
rootLogger.addHandler(streamHandler)


TOKEN = read_key(os.path.join(os.path.expanduser("~"), ".keys", "todoist"))


def add_task(task, project_id=None):
   logging.info(f"Adding task: {task}")

   request_body = {"content": task, "due_string": "today"}

   if project_id is not None:
      request_body["project_id"] = project_id

   res = requests.post("https://api.todoist.com/rest/v2/tasks",
      json=request_body,
      headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"})

   if res.status_code == 200:
      logging.info(f"Adding task: {task} -> Success. Status code 200.")
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

   res = requests.delete(f"https://api.todoist.com/rest/v2/tasks/{task_id}",
      headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"})

   if res.status_code == 204:
      logging.info(f"Task {task_id} deleted")
   else:
      logging.error(res.status_code)
      logging.error(res.content)


def main():
   parser = argparse.ArgumentParser(description="script for adding Todoist tasks")
   parser.add_argument("--log", type=str, help="log output to file")
   subparsers = parser.add_subparsers(dest='sub_command')
   add_parser = subparsers.add_parser("add")
   add_parser.add_argument("task", type=str, help="the description of the task")
   add_parser.add_argument("--project_id", type=str, help="the id of the project for the task")
   subparsers.add_parser("projects")
   list_parser = subparsers.add_parser("list")
   list_parser.add_argument("--project_id", type=str, help="the id of the project to list tasks")
   close_parser = subparsers.add_parser("close")
   close_parser.add_argument("task_id", type=str, help="the id of the task to close")
   delete_parser = subparsers.add_parser("delete")
   delete_parser.add_argument("task_id", type=str, help="the id of the task to delete")

   args = parser.parse_args()

   if args.log is not None:
      fileHandler = logging.FileHandler(args.log)
      fileHandler.setFormatter(logFormatter)
      rootLogger.addHandler(fileHandler)

   if args.sub_command == "add":
      add_task(args.task, args.project_id)
   elif args.sub_command == "projects":
      for project in get_projects():
         print("%s\t%s" % (str(project['id']), project['name']))
   elif args.sub_command == "list":
      if args.project_id is None:
         for project in filter(lambda p: p["is_inbox_project"] is True, get_projects()):
            for task in get_tasks(project['id']):
               print("%s\t%s" % (str(task['id']), task['content']))
      else:
         for task in get_tasks(args.project_id):
            print("%s\t%s" % (str(task['id']), task['content']))

   elif args.sub_command == "close":
      close_task(args.task_id)
   elif args.sub_command == "delete":
      delete_task(args.task_id)
   else:
      parser.print_help()


if __name__ == "__main__":
   main()
