#!/usr/bin/env python3

import os
import subprocess
import argparse
import sys
from pathlib import PureWindowsPath


def main():

   if sys.platform == 'win32':
      path_to_vim = PureWindowsPath('c:/Program Files/Git/usr/bin/vim')
   else:
      path_to_vim = 'vim'

   parser = argparse.ArgumentParser(description="open git staged files in vim")
   parser.add_argument("-e", dest="exts_to_exclude", action="append", help="specify file extensions to ignore")

   args = parser.parse_args()

   process = subprocess.run(['git', 'diff', '--staged', '--name-only'], stdout=subprocess.PIPE)

   changed_files = process.stdout.decode('utf-8').strip().split('\n')
   changed_files = list(filter(lambda x: len(x) > 0, changed_files))

   files_to_edit = changed_files
   if args.exts_to_exclude is not None:
      exts_to_exclude = list(map(lambda x: x if x.startswith('.') else f".{x}", args.exts_to_exclude))
      files_to_edit = list(filter(lambda x: os.path.splitext(x)[1] not in exts_to_exclude, changed_files))

   if len(files_to_edit) > 0:
      print(files_to_edit)
      os.system("\"%s\" -p %s" % (path_to_vim, ' '.join(files_to_edit)))


if __name__ == "__main__":
   main()
