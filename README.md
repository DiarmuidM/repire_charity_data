# Republic of Ireland Charity Data

### Diarmuid McDonnell (d.mcdonnell.1@bham.ac.uk)
This repository contains Python and Stata syntax to collect, clean and analyse Republic of Ireland charity data. Its purpose is to make existing open datasets easily accessible to charity scholars and researchers.

## Background

Data relating to the Republic of Ireland charity sector is being made increasingly available by two key actors:
* [Charities Regulator (An Rialalai Carthanas)](http://www.charitiesregulatoryauthority.ie/)
* [Benefacts](https://benefacts.ie/)

These organisations produce open datasets containing detailed information about the characteristics, financial profile, geographical distribution, and activities of charities based in the Republic of Ireland. These datasets have been underemployed in scholarship and research, one of the main reasons for which is the need for intermediate programming and data analysis skills in order to work with the data. The repository addresses this barrier by providing Python and Stata scripts that undertake the collecting, cleaning and analysis of the datasets.

## Repository

The syntax folder contains the following scripts:
* __repire_charityregister.py__ - downloads the Charity Register from the Charities Regulator's [website](https://www.charitiesregulatoryauthority.ie/en/cra/pages/search_a_charity).
* __benefacts_taxefficientgifts.py__ - downloads a list of registered charities that are eligible to claim tax efficient gifts from Revenue: Irish Tax and Customs.
* __benefacts_volcodemembers.py__ - downloads a list fo registered charities that comply with a number of voluntary codes (e.g. fundraising, SORP).
* __benefacts_volcodes.py__ - downloads a list of voluntary codes that registered charities can comply with.
* __downloaddate_function.py__ - returns the current date in order to name the files that are downloaded.
* __stata_ditty_function.py__ - produces a short poem about my favourite statistical software package.
* __repire_master.py__ - executes all of the above scripts in a single go.

In addition there is a folder containing two Stata do files (scripts):
* __repire_datacleaning.do__ - takes the downloaded data and gets it ready for analysis (e.g. deals with duplicate records, missing values, creates new variables etc).
* __repire_dataanalysis.do__ - produces some basic quantitative analyses using the cleaned datasets.

## Pre-requisites

You must have Python and Stata installed on your machine. Python is an open source programming language that can be downloaded and installed using the [Anaconda distribution](https://anaconda.org/anaconda/python).
Stata is a proprietary statistical software package and you must [purchase a licence](https://www.stata.com/products/which-stata-is-right-for-me/) to use it.

The data provided by Benefacts is accessible via an API, which you need to request access to: see its [developer documentation](https://developer.benefacts.ie/) for how to do to register for access.

I recommended using [Sublime Text](https://www.sublimetext.com/3) to write and run the Python scripts, but there are other text editors/IDEs available.

## Final comments

This repository is likely to be updated on a semi-regular basis. If you would like to collaborate on developing the repository further, or have an idea for a research project employing these datasets, then don't hesitate to get in [contact](d.mcdonnell.1@bham.ac.uk).
