#!/usr/bin/env python3

import yaml
import requests
import json
import argparse
import re
import os
import sys

def read_key(path):
   try:
      with open(path, 'r') as f:
         text = f.read().rstrip()
      return text
   except FileNotFoundError:
      print("Could not read key from: %s" % path)
      sys.exit(1)


def read_yaml(path):
   try:
      with open(path) as f:
         return yaml.safe_load(f)

   except Exception as ex:
      print("Could not read from yaml config: %s" % path)
      print(ex)
      sys.exit(1)


def main():
   parser = argparse.ArgumentParser(description="control lights/switches from command line")

   subparsers = parser.add_subparsers(dest="command")
   switch_subparser = subparsers.add_parser("switch", help="switch a light on or off")
   state_group = switch_subparser.add_mutually_exclusive_group(required=True)
   state_group.add_argument("--on", action="store_true", help="turn on")
   state_group.add_argument("--off", action="store_true", help="turn off")
   switch_subparser.add_argument("--name", type=str, help="friendly name of the device", required=True)

   _ = subparsers.add_parser("list", help="list devices")
   args = parser.parse_args()


   token = read_key(os.path.join(os.path.expanduser("~"), ".keys", "homeassistant"))

   if sys.platform == 'win32':
      config = read_yaml(os.path.join(os.path.expanduser("~"), "AppData", "Local", os.path.basename(__file__).replace(".", "-"), "config.yaml"))
   else:
      config = read_yaml(os.path.join(os.path.expanduser("~"), ".config", os.path.basename(__file__).replace(".", "-"), "config.yaml"))

   #print(config)

   res = requests.get("http://%s/api/states" % config["baseurl"], headers={"Authorization": "Bearer %s" % token})

   if res.status_code != 200:
      print(f"status code is: {res.status_code}")
      sys.exit(1)

   entities = [{"friendly_name": entity["attributes"]["friendly_name"].rstrip(), "entity_id": entity["entity_id"], "state": entity["state"]}
      for entity in res.json()]
   light_devices = [entity for entity in entities if re.search(r'^(lamp|light|switch)', entity["entity_id"], re.IGNORECASE)]


   if args.command == "switch":
      service = "turn_on" if args.on else "turn_off"

   elif args.command == "list":
      print(json.dumps(light_devices, indent=2))
      return # we're done

   else:
      parser.print_help()
      return


   try:
      device = [device for device in light_devices if device["friendly_name"] == args.name][0]
   except IndexError:
      print(f"unknown device: {args.name}")
      sys.exit(1)

   device_entity_id = device["entity_id"]
   domain = device["entity_id"].split(".")[0]

   print("calling service: %s %s" % (domain, service))
   data = {"entity_id": device_entity_id}


   res = requests.post("http://%s/api/services/%s/%s" % (config["baseurl"], domain, service),
      data=json.dumps(data),
      headers={"Authorization": "Bearer %s" % token})


   if res.status_code != 200:
      print(f"status code is: {res.status_code}")
      sys.exit(1)
   print(json.dumps(res.json(), indent=2))

if __name__ == "__main__":
   main()
