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

'''
Open bapitoken.txt in read mode, print to the screen and create an object that stores the API access request
'''
tokenfile = open(tokenpath, "r")
bapitoken = tokenfile.read()
print(bapitoken)

# Define a function for Voluntary Code Members API request #

def volcodesmembers_request(code):
	conn = http.client.HTTPSConnection('api.benefacts.ie')
	conn.request("GET", "/public/v1/VoluntaryCodeMembers/" + code + "?%s" % params, "{body}", headers)
	response = conn.getresponse()
	print(response.status, response.headers)
	bdata = response.read().decode('utf-8')
	data = json.loads(bdata)
	#print(data)
	print(len(data))
	return data
	conn.close() # Takes one argument: the voluntary code to search for

headers = {
    # Request headers
    'Ocp-Apim-Subscription-Key': bapitoken,
}

params = urllib.parse.urlencode({
})

# Create a list of the voluntary codes.

volcodes = ['GOVERNANCECODE', 'ICTR', 'SORP']

for code in volcodes:

	outputfilepath_json = datapath + ddate + '/' + 'voluntarycodemembers_' + code + '_' + ddate + '.json'
	print(outputfilepath_json)

	data = volcodesmembers_request(code) # Call the function to perform the API request

	## Export the json data to a .json file
	with open(outputfilepath_json, 'w') as volcodesjson:
		json.dump(data, volcodesjson)
	print('I am sleeping for 5 seconds: back soon!')	
	sleep(5)	
	#break
	'''
	    File structure: a list with n dictionaries, each of which has two items (id and name).

	    The results: 271 organisations are compliant with Governance Code, 380 with Fundraising Code, and none with SORP. Hard to know if these figures
	    are correct; certainly SORP doesn't seem true.
	'''

# Read in the jsons for each code and export to csv.

for code in volcodes:

	outputfilepath_json = datapath + ddate + '/' + 'voluntarycodemembers_' + code + '_' + ddate + '.json'
	outputfilepath_csv = datapath + ddate + '/' + 'voluntarycodemembers_' + code + '_' + ddate + '.csv'
	inputfilepath = outputfilepath_json
	print(outputfilepath_csv)
	print(outputfilepath_json)
	print(inputfilepath)


	#Read JSON data into the regchar variable (i.e. a Python object)
	with open(inputfilepath, 'r') as f:
		compliant = json.load(f)

	with open(outputfilepath_csv, 'w', newline='') as outCSVfile:

		outputfieldnames = ('charityid', 'name')
		writer = csv.writer(outCSVfile, outputfieldnames)
		writer.writerow(outputfieldnames)

		# Create a variable to count records
		recordcount = 0

		#charid = []
		#name = []

		for org in compliant:
			writer.writerow(org.values())
			recordcount +=1

		print('__________________________________________________________________________')
		print('                                                                          ')
		print('                                                                          ')
		print(" ---------- Finished searching through list of compliant organisations ---------- ")
		print('                                                                          ')
		print('                                                                          ')
		print('__________________________________________________________________________')
		print('                                                                          ')
		print('                                                                          ')
		print("Number of observations in data: " + str(recordcount))
