## Python test script to obtain voluntary codes from the Benefacts API
import json
import csv
import re
import requests
import os
from time import sleep
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

outputfilepath_csv = datapath + ddate + '/' + 'taxefficientgifts_' + ddate + '.csv'
outputfilepath_json = datapath + ddate + '/' + 'taxefficientgifts_' + ddate + '.json'
inputfilepath = outputfilepath_json
print(outputfilepath_csv)
print(outputfilepath_json)
print(inputfilepath)

'''
Open bapitoken.txt in read mode, print to the screen and create an object that stores the API access request
'''
tokenfile = open(tokenpath, "r")
bapitoken = tokenfile.read()
print(bapitoken)

# Define a function to perform Tax Efficient Gifts API request #

def taxeff_request():

	headers = {'Ocp-Apim-Subscription-Key': bapitoken,}
	params = urllib.parse.urlencode({})
	
	conn = http.client.HTTPSConnection('api.benefacts.ie')
	conn.request("GET", "/public/v1/taxEfficientGifts?%s" % params, "{body}", headers)
	response = conn.getresponse()
	print(response.status, response.headers)
	bdata = response.read().decode('utf-8')
	data = json.loads(bdata)
	#print(data)
	return data
	conn.close()


# Create a folder for the download to be saved in #
try:
	os.mkdir(datapath+ddate)
except:
	print('Folder already exists')

data = taxeff_request()  # Call the function to request data from the API

## Export the json data to a .json file
with open(outputfilepath_json, 'w') as taxgiftsjson:
        json.dump(data, taxgiftsjson)

#Read JSON data into the regchar variable (i.e. a Python object)
with open(inputfilepath, 'r') as f:
	taxgift = json.load(f)

with open(outputfilepath_csv, 'w', newline='') as outCSVfile:

	outputfieldnames = ('charityid', 'name')
	writer = csv.writer(outCSVfile, outputfieldnames)
	writer.writerow(outputfieldnames)

	# Create a variable to count records
	recordcount = 0

	#charid = []
	#name = []

	for org in taxgift:
		writer.writerow(org.values())
		recordcount +=1

	print('_________________________________________________________________________________________________________________')
	print('                                                                          ')
	print('                                                                          ')
	print(" ---------- Finished searching through list of organisations that qualify for tax-efficient donations ---------- ")
	print('                                                                          ')
	print('                                                                          ')
	print('_________________________________________________________________________________________________________________')
	print('                                                                          ')
	print('                                                                          ')
	print("Number of observations in data: " + str(recordcount))