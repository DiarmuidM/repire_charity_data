# Republic of Ireland Charity Data - Notes

This markdown file describes some important aspects of the contents and limitations of the open datasets. Readers should refer to Benefacts excellent guide to Irish nonprofit data, from which most of the content to this file was gleaned: [https://analysis2018.benefacts.ie/report/about-the-data](https://analysis2018.benefacts.ie/report/about-the-data)

## The Register of Charities

The Public Register of Charities is less detailed than the version that can be searched via the Charities Regulatory Authority's website. As Benefacts highlights:

_The Charities Regulatory Authority publishes an open data file on its website, periodically updated, including some but not all of the data provided on the online register of charities: the names of charity trustees are not included in the open data file, nor are the numbers of reported employees. A summary of the gross expenditure and total income for every charity is provided, but the Authority does not publish the financial statements of unincorporated charities filed under the provisions of Section 54.1 of the Charities Act, 2009._ (Benefacts, 2018)

Information on trustees and reported number of employees can be searched via the interface on the website but this would be cumbersome and costly in terms of time (it is left to potential users to consider the ethical and possibly legal implications of scraping this information).

## Benefacts Database of Irish Nonprofits

Open data are richer and more revealing when they are linked with other relevant sources of information. This project uses Benefacts Database of Irish Nonprofits - accessed via its API - to procure additional information on registered charities. However, Benefacts does not possess additional information for every registered charity:

_because they are State agencies or intermediaries and therefore fall outside the definition of nonprofit used in compiling the Database of Irish Nonprofits. Benefacts has consulted the regularly‑updated list of public bodies published by the Central Statistics Office in identifying entities not in scope, although it distinguishes between public bodies that are controlled by Government and quasi‑public bodies that have some degree of autonomy from Government. For more on the latter, see below._ (Benefacts, 2018)
