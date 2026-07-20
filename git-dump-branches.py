#!/usr/bin/env python3

import subprocess

def main():
   proc = subprocess.run(['git', 'branch'], stdout=subprocess.PIPE)

   branches = [branch.strip() for branch in proc.stdout.decode('utf-8').strip().split('\n')]

   filtered_branches = [branch for branch in branches if not branch.startswith('*') and branch not in ['master']]
   print(filtered_branches)

   for branch in filtered_branches:
      subprocess.run(['git', 'branch', "-D", branch])

if __name__ == "__main__":
   main()
