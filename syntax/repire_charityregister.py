## Python script to download a monthly snapshot of two copies of the Rep. of Ireland Charity Register:
#	- http://www.charitiesregulatoryauthority.ie/en/cra/pages/search_a_charity (main - Charity Regulator)
#	- https://api.benefacts.ie/v1/openData/organisations/charities/?format=csv (supplementary - Benefacts)

# The Regulator's dataset also contains annual returns in the second tab.

# Diarmuid McDonnell
# Created: 26 February 2018
# Last edited: 26 February 2018

import itertools
import json
import csv
import re
import requests
import os
import os.path
import errno
import urllib
from time import sleep
from bs4 import BeautifulSoup
from downloaddate_function import downloaddate

# Run the downloaddate function to get the date 'benefacts_master.py' was executed.
ddate = downloaddate()

projpath = 'C:/Users/mcdonndz-local/Desktop/github/repire_charity_data/'
datapath = 'C:/Users/mcdonndz-local/Desktop/data/repire_charity_data/data_raw/'

print(projpath)
print(datapath)


# Create a folder for the download to be saved in #
try:
	os.mkdir(datapath+ddate)
except:
	print('Folder already exists')

# Define urls where Charity Registers can be downloaded #

cr_search_url = 'http://www.charitiesregulatoryauthority.ie/en/cra/pages/search_a_charity' # returns Charity Search webpage
#cr_url = 'http://www.charitiesregulatoryauthority.ie/en/CRA/Public%20Register%20November%202017.xlsx/Files/Public%20Register%20November%202017.xlsx' # returns a xlsx
bene_url = 'https://api.benefacts.ie/v1/openData/organisations/charities/?format=csv' # returns a csv
bene_codes_url = 'https://api.benefacts.ie/v1/openData/subsectors' # returns a json

# Request data from urls #

# Charities Regulator data

r = requests.get(cr_search_url, allow_redirects=True)
soup = BeautifulSoup(r.text, 'html.parser')
print(soup)
links = soup.find_all('a')
print(links)
for link in links:
   print(link.get('href'))
reglink = soup.select_one("a[href*=Public]")

plink = reglink['href'] # Extract the href part of the <a> element.
print(plink)
print(type(plink))

ilink = 'http://www.charitiesregulatoryauthority.ie' # Create initial part of the link
flink = ilink + plink # Build full link to Register
cr_url = flink.replace(" ", "%20")
print(cr_url)
print(type(cr_url))


r = requests.get(cr_url, allow_redirects=True)
print(r.status_code, r.headers) # I want to take the date information and use it to name the file and folder
#print(r.content)

# Write the r.content to a file in the newly created folder #
crreg = datapath + ddate + '/' + 'cr_charityregister_' + ddate + '.xlsx'
print(crreg)
outcsv = open(crreg, 'wb')
outcsv.write(r.content)
outcsv.close()


############################################################################################################


# Benefacts data

r = requests.get(bene_url, allow_redirects=True)
print(r.status_code, r.headers) # I want to take the date information and use it to name the file and folder
#print(r.content)

# Write the r.content to a file in the newly created folder #
benereg = datapath + ddate + '/' + 'bene_charityregister_' + ddate + '.csv'
print(benereg)
outcsv = open(benereg, 'wb')
outcsv.write(r.content)
outcsv.close()

##########

r = requests.get(bene_codes_url, allow_redirects=True)
print(r.status_code, r.headers) # I want to take the date information and use it to name the file and folder
print(r.content)
bdata = r.content.decode('utf-8')
print(bdata)
data = json.loads(bdata)
print(data)

benecodes = datapath + ddate + '/' + 'bene_sectorcodes_' + ddate + '.json'

## Export the json data to a .json file
with open(benecodes, 'w') as benecodesjson:
        json.dump(data, benecodesjson)

#Read JSON data into the regchar variable (i.e. a Python object)
with open(benecodes, 'r') as f:
	data = json.load(f)
print(data)	

# Open a csv and write to it
benecodes_csv = datapath + ddate + '/' + 'bene_sectorcodes_' + ddate + '.csv'

with open(benecodes_csv, 'w', newline='') as outcode:
	varnames = data[0].keys()
	writer = csv.DictWriter(outcode, varnames)
	print(data)
	print('---------------------')
	print('                     ')
	writer.writeheader()
	writer.writerows(data)