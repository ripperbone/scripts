#!/usr/bin/env python3


import requests
import re
import datetime
import argparse
import sys


overwatch_url = 'https://playoverwatch.com/en-us/news/patch-notes'
overwatch_experimental_url = 'https://playoverwatch.com/en-us/news/patch-notes/experimental'

def str_to_date(date_string):
   return datetime.datetime.strptime(date_string, '%B %d, %Y')


def check_patch_notes(url, verbose=False):
   res = requests.get(url)

   if res.status_code != 200:
      print('Could not reach url %s' % url)
      sys.exit(1)

   #Do regex search through HTML to find date strings
   #Map each date string into a datetime object
   #Do set() to remove duplicates since the dates appear in the HTML twice
   #Sort the dates to make sure we're comparing the most recent date we found in the HTML with today's date

   matches = sorted(set(list(map(str_to_date, re.findall('[A-z]+ \d{1,2}, \d{4}', res.text)))))

   if len(matches) == 0:
      print("No dates found to compare. This doesn't seem right.")
      sys.exit(1)

   if matches[-1].date() == datetime.datetime.today().date():
      print("Overwatch patch notes have changed. See %s" % url)
   else:
      if verbose:
         print("The last overwatch patch note change was: %s. See %s" % (matches[-1].date().strftime('%B %d, %Y'), url))


def main():
   parser = argparse.ArgumentParser(description="Check Overwatch patch notes")
   parser.add_argument('-v', '--verbose', action='store_true', help='Include more detail in output')
   args = parser.parse_args()

   check_patch_notes(overwatch_url, verbose=args.verbose)
   #check_patch_notes(overwatch_experimental_url, verbose=args.verbose)
   sys.exit(0)

if __name__ == "__main__":
   main()
