#!/usr/bin/env python3

import requests
import json
import socket
import argparse
import sys


def set_volume(config, client_id, volume=None, mute=False):

   volume_params = {"muted": mute}
   if volume is not None:
      volume_params["percent"] = volume

   headers = {"Content-Type": "application/json"}
   params = json.dumps({
      "id": 1, "jsonrpc": "2.0", "method": "Client.SetVolume", "params": {"id": client_id, "volume": volume_params}})
   res = requests.post("http://%s:%d/jsonrpc" % (config["host"], config["port"]), data=params, headers=headers)
   print(res.text)


def get_client_status(config, client_id):
   headers = {"Content-Type": "application/json"}
   params = json.dumps({"id": 1, "jsonrpc": "2.0", "method": "Client.GetStatus", "params": {"id": client_id}})
   res = requests.post("http://%s:%d/jsonrpc" % (config["host"], config["port"]), data=params, headers=headers)
   return res.json()


def get_status(config):
   headers = {"Content-Type": "application/json"}
   params = json.dumps({"id": 1, "jsonrpc": "2.0", "method": "Server.GetStatus"})
   res = requests.post("http://%s:%d/jsonrpc" % (config["host"], config["port"]), data=params, headers=headers)
   return res.json()


def get_clients(config):
   # Look up client id by hostname
   results = {}
   for group in get_status(config)["result"]["server"]["groups"]:
      for client in group["clients"]:
         results[client["host"]["name"]] = client["id"]

   return results


def get_this_client(config):
   return get_clients(config)[get_this_client_name()]


def get_this_client_name():
   return socket.gethostname()


def main():
   parser = argparse.ArgumentParser(description="Mute or unmute snapcast clients")
   subparsers = parser.add_subparsers(dest="command")
   mute_subparser = subparsers.add_parser("mute", help="Mute client sound")
   mute_group = mute_subparser.add_mutually_exclusive_group(required=True)
   mute_group.add_argument("--me", action="store_true", help="the current client")
   mute_group.add_argument("--all", action="store_true", help="all clients")
   mute_group.add_argument("--client", type=str, help="specify a client by name")

   unmute_subparser = subparsers.add_parser("unmute", help="Unmute client sound")
   unmute_group = unmute_subparser.add_mutually_exclusive_group(required=True)
   unmute_group.add_argument("--me", action="store_true", help="the current client")
   unmute_group.add_argument("--all", action="store_true", help="all clients")
   unmute_group.add_argument("--client", type=str, help="specify a client by name")

   _ = subparsers.add_parser("list", help="List clients")

   set_volume_subparser = subparsers.add_parser("volume", help="Set volume")
   set_volume_group = set_volume_subparser.add_mutually_exclusive_group(required=True)
   set_volume_group.add_argument("--me", action="store_true", help="the current client")
   set_volume_group.add_argument("--all", action="store_true", help="all clients")
   set_volume_group.add_argument("--client", type=str, help="specify a client by name")
   set_volume_subparser.add_argument("--level", type=int, help="the volume level percent to set", required=True)

   args = parser.parse_args()

   config = {"host": "localhost", "port": 1780}

   if args.command == "list":
      results = {}
      for client_name, client_id in get_clients(config).items():
         results[client_name] = get_client_status(config, client_id)["result"]["client"]["config"]["volume"]
      print(json.dumps(results, indent=2))

   elif args.command == "unmute":
      if args.all:
         for client_name, client_id in get_clients(config).items():
            print(client_name)
            set_volume(config, client_id=client_id, mute=False)

      elif args.me:
         set_volume(config, client_id=get_this_client(config), mute=False)

      elif args.client:
         for client_name, client_id in get_clients(config).items():
            if client_name == args.client:
               print(client_name)
               set_volume(config, client_id=client_id, mute=False)

   elif args.command == "mute":
      if args.all:
         for client_name, client_id in get_clients(config).items():
            print(client_name)
            set_volume(config, client_id=client_id, mute=True)

      elif args.me:
         set_volume(config, client_id=get_this_client(config), mute=True)

      elif args.client:
         for client_name, client_id in get_clients(config).items():
            if client_name == args.client:
               print(client_name)
               set_volume(config, client_id=client_id, mute=True)

   elif args.command == "volume":
      if args.level not in range(1, 101):
         print("Level %d is out of the expected value range." % args.level)
         sys.exit(1)

      if args.all:
         for client_name, client_id in get_clients(config).items():
            print(client_name)
            set_volume(config, client_id=client_id, volume=args.level)

      elif args.me:
         this_client_id = get_this_client(config)
         print(get_this_client_name())
         set_volume(config, client_id=this_client_id, volume=args.level)

      elif args.client:
         for client_name, client_id in get_clients(config).items():
            if client_name == args.client:
               print(client_name)
               set_volume(config, client_id=client_id, volume=args.level)


if __name__ == "__main__":
   main()
