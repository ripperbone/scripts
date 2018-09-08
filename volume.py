#!/usr/bin/env python3

import subprocess
import sys
import argparse

def can_run_applescript():
  return subprocess.call(['which', 'osascript']) == 0

def set_volume(level):
  print('Setting volume to %s' % level)
  return subprocess.call(['osascript', '-e', 'set volume output volume %s' % level]) == 0


def main():
  parser = argparse.ArgumentParser(description='Volume control')
  parser.add_argument('--mute', action='store_true', help='turn sound off')
  parser.add_argument('--low', action='store_true', help='turn sound on low')
  parser.add_argument('--high', action='store_true', help='turn sound on high')
  parser.add_argument('--level', type=int, help='specify a numeric volume level') 
  args = parser.parse_args()

  if not can_run_applescript():
    print('No applescript interpreter. Exiting...')
    sys.exit(1)

  if args.mute:
    set_volume(0)
  elif args.low:
    set_volume(25)
  elif args.high:
    set_volume(70)
  elif args.level:
    set_volume(args.level)



if __name__ == "__main__":
  main()
