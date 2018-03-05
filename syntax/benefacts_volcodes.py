## Python test script to obtain voluntary codes from the Benefacts API
import json
import csv
import re
import requests
import os
import os.path
import errno
import http.client, urllib.request, urllib.parse, urllib.error, base64
from downloaddate_function import downloaddate

## Define the path where my API key is
tokenpath = "C:/Users/mcdonndz-local/Desktop/admin/bapitoken.txt"

projpath = 'C:/Users/mcdonndz-local/Desktop/github/repire_charity_data/'
datapath = 'C:/Users/mcdonndz-local/Desktop/data/repire_charity_data/data_raw/'

print(projpath)
print(datapath)

# Run the downloaddate function to get the date 'benefacts_master.py' was executed.
ddate = downloaddate()

outputfilepath = datapath + 'voluntarycodes_' + ddate + '.json'
print(outputfilepath)

'''
Open bapitoken.txt in read mode, print to the screen and create an object that stores the API access request
'''
tokenfile = open(tokenpath, "r")
bapitoken = tokenfile.read()
print(bapitoken)

# Define a function for Voluntary Codes API request #

def volcodes_request():
	conn = http.client.HTTPSConnection('api.benefacts.ie')
	conn.request("GET", "/public/v1/VoluntaryCodes?%s" % params, "{body}", headers)
	response = conn.getresponse()
	bdata = response.read().decode('utf-8')
	data = json.loads(bdata)
	print(data)
	conn.close()

headers = {
    # Request headers
    'Ocp-Apim-Subscription-Key': bapitoken,
}

params = urllib.parse.urlencode({
})

data = volcodes_request() # Call the function to request data from the API
'''
    File structure: a list with 3 strings. Not a very useful search imho.
'''

## Export the json data to a .json file
with open(outputfilepath, 'w') as volcodesjson:
        json.dump(data, volcodesjson)