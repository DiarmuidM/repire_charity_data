## Python master script that runs all of the scripts in the Rep. of Ireland charity data project

from time import sleep
import os
import os.path
from downloaddate_function import downloaddate
from stata_ditty_function import stata_ditty
import subprocess

# Launch a little ditty
print('                       ')
stata_ditty()


# Get today's date
ddate = downloaddate()	
print('The date is ' + ddate)

# Create folders for the working and clean data #

cleandata = 'C:/Users/mcdonndz-local/Desktop/data/repire_charity_data/data_clean/'
workdata = 'C:/Users/mcdonndz-local/Desktop/data/repire_charity_data/data_working/'

# Create folders to store the clean and working .dta files
try:
	os.mkdir(cleandata+ddate)
	os.mkdir(workdata+ddate)
except:
	print('Folder already exists')


# Run python scripts in order: #

import repire_charityregister
print('Finished executing repire_charityregister.py')
print('                                             ')
print('---------------------------------------------')
print('                                             ')
sleep(10)

import benefacts_volcodemembers
print('Finished executing benefacts_volcodemembers.py')
print('                                             ')
print('---------------------------------------------')
print('                                             ')
sleep(10)

import benefacts_taxefficientgifts
sleep(10)
print('Finished executing benefacts_taxefficientgifts.py')
print('                                                  ')
print('                                                  ')
print('                                                  ')
print('                                                  ')
print('All of the python scripts have been executed on ' + ddate + '. Go see the data folder for proof they have worked.')
print('                                                  ')
print('                                                  ')
print('                                                  ')
print('                                                  ')


# Run Stata syntax #

# Define a function for executing do files

def dostata(dofile, *params):
    cmd = ["C:/Program Files (x86)/Stata15/StataSE-64","/e","do", dofile]
    for param in params:
        cmd.append(param)
    return (subprocess.call(cmd, cwd=r'C:/Users/mcdonndz-local/Desktop/github/repire_charity_data/logs/'))

# Execute the do files

try:
	dostata('C:/Users/mcdonndz-local/Desktop/github/repire_charity_data/syntax/stata/repire_datacleaning.do', ddate)
	dostata('C:/Users/mcdonndz-local/Desktop/github/repire_charity_data/syntax/stata/repire_dataanalysis.do', ddate)
	print('-------------------------------------------------------------------------------------------------------------')
	print('                                                                                                             ')
	print('                                                                                                             ')
	print('Stata do files run successfully: go see the log files at C:/Users/mcdonndz-local/Desktop/github/benefacts_nonprofit_data_ireland/logs/')
	print('                                                                                                             ')
	print('                                                                                                             ')
except:
	print('Stata launch unsuccesful')