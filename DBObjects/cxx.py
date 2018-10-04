#!/usr/bin/env python
import sys
import requests
import os
from connections import *
script_dir = os.path.dirname(__file__)
statinfo = os.stat(os.path.join(script_dir, "o.txt"))
if statinfo.st_size == 0 :
    print ("Customer file empty")
    sys.exit(0)
resp_t = requests.request("GET", url_t, headers=headers, verify=False)
if resp_t.status_code != requests.codes.ok :
    sys.stderr.write("JWT webservice error: " + str(resp_t.status_code) + "\n")
    sys.exit(0)
headers['X-User-Context'] = resp_t.json()
file2 = open(os.path.join(script_dir, "o2.txt"), "w")
with open(os.path.join(script_dir, "o.txt")) as file1:
 for line in file1:
  nums = line.split(",")
  querystring = {"emt-customer-id":nums[1]}
  response = requests.request("GET", url, headers=headers, params=querystring, verify=False)
  if (response.status_code == requests.codes.ok) and (len(response.json()["customers"]) == 1) and (response.json()["customers"][0]["customerId"] is not None):
   file2.write(nums[0] + "," + str(response.json()["customers"][0]["customerId"]) + "\n")
  else:
   file2.write(nums[0] + ",0\n")
file2.close() 
