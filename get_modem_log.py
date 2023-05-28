#!/usr/bin/env python3

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.common.exceptions import SessionNotCreatedException

import datetime
import os
import subprocess
import sys
import tempfile
from time import sleep


def get_login_info():
   with open(os.path.join(os.path.expanduser("~"), ".keys", "modem")) as f:
      credentials = f.read().strip().split("/")
   if len(credentials) != 2:
      raise Exception(f"size of credentials expected to be: 2 was: {len(credentials)}")
   return {"username": credentials[0], "password": credentials[1]}

def get_modem_log(login_username, login_password):
   chrome_options = Options()
   chrome_options.add_argument("--incognito")
   chrome_options.add_argument("--kiosk-printing")
   chrome_options.add_argument("--headless")
   chrome_options.add_argument("--start-maximized")
   chrome_options.add_argument("--disable-gpu")
   chrome_options.add_argument("--no-sandbox")
   driver = webdriver.Chrome(options=chrome_options, service=Service("/snap/bin/chromium.chromedriver"))

   url = "http://192.168.100.1/MotoSnmpLog.asp"
   logout_url = "http://192.168.100.1/logout.asp"
   driver.get(logout_url)

   driver.get(url)
   username = driver.find_element(By.NAME, "loginUsername")
   username.send_keys(login_username)

   password = driver.find_element(By.NAME, "loginText")
   password.click()

   password_text = driver.find_element(By.NAME, "loginPassword")
   password_text.send_keys(login_password)

   login_button = driver.find_element(By.CSS_SELECTOR, ".moto-login-button")
   login_button.click()

   # we are not redirected after logging in, so get the page again
   driver.get(url)

   body = driver.find_element(By.TAG_NAME, "body")

   scroll_width = body.get_attribute("scrollWidth")
   scroll_height = body.get_attribute("scrollHeight")
   print(scroll_width)
   print(scroll_height)
   driver.set_window_size(int(scroll_width) + 100, int(scroll_height) + 100)
   screenshot_path = os.path.join(tempfile.gettempdir(), "get_modem_log_screenshot.png")
   driver.save_screenshot(screenshot_path)
   print("saving to %s" % screenshot_path)
   sleep(3)

   output_pdf_dir = os.path.expanduser("~/Documents/modem_logs")
   output_pdf_file = "modem_log_%s.pdf" % datetime.datetime.now().strftime("%Y%m%d_%H%M")
   output_pdf_path = os.path.join(output_pdf_dir, output_pdf_file)
   print("saving to %s" % output_pdf_path)
   # convert to PDF and put in output directory
   if os.path.isfile(screenshot_path):
      subprocess.run(["convert", "-density", "300", screenshot_path, output_pdf_path], capture_output=True)
   else:
      print("No file found at %s" % screenshot_path, file=sys.stderr)
      sys.exit(1)

   sleep(2)
   if not os.path.isfile(output_pdf_path):
      print("No file found at %s" % output_pdf_path, file=sys.stderr)
      sys.exit(1)


def main():

   info = get_login_info()
   try:
      get_modem_log(info["username"], info["password"])
      sys.exit(0)
   except SessionNotCreatedException as ex:
      print("Got SessionNotCreatedException. Try changing chrome options?", file=sys.stderr)
      print(ex, file=sys.stderr)
      sys.exit(1)
   except Exception as ex:
      print(ex, file=sys.stderr)
      sys.exit(1)


if __name__ == "__main__":
   main()
