#!/usr/bin/env python3

import argparse
import requests
import sys
import logging
import os

rootLogger = logging.getLogger()
rootLogger.setLevel(logging.INFO)
logFormatter = logging.Formatter("[ %(asctime)s ] %(levelname)s %(message)s")

# set up sysout logging
streamHandler = logging.StreamHandler(sys.stdout)
rootLogger.addHandler(streamHandler)


def add_task(task):
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


def read_key(path):
   text = None
   try:
      with open(path, 'r') as f:
         text = f.read().rstrip()
   except FileNotFoundError:
      logging.error("Could not read key from: %s" % path)
      sys.exit(1)

   return text


def get_weather():
   API_KEY = read_key(os.path.join(os.path.expanduser("~"), ".keys", "openweatherapi"))
   lat = "43.010"
   lon = "-88.2319"

   res = requests.get(f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&units=metric&appid={API_KEY}")

   if res.status_code == 200:
      return res.json()
   else:
      logging.error("Error getting the weather. Status code: %d" % res.status_code)
      return None


def main():
   parser = argparse.ArgumentParser(description="add reminders to wash car when the weather is nice")
   parser.add_argument("--log", type=str, help="log output to file")

   args = parser.parse_args()

   if args.log is not None:
      fileHandler = logging.FileHandler(args.log)
      fileHandler.setFormatter(logFormatter)
      rootLogger.addHandler(fileHandler)

   weather_json = get_weather()

   if weather_json is None:
      sys.exit(1)
   else:
      try:
         temp_current = int(float(weather_json["main"]["temp"]))
      except ValueError as e:
         logging.error("Not a number!")
         logging.error(e)
         sys.exit(1)

      if temp_current > 0:
         logging.info("Wash car. Temp is %d°C" % temp_current)
         add_task("Wash car. Temp is %d°C" % temp_current)
      else:
         logging.info("Don't wash the car. Temp is %d°C" % temp_current)


if __name__ == "__main__":
   main()
