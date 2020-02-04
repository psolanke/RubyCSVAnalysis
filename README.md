# RubyCSVAnalysis
This script processes a csv file and outputs the result back in a csv file.
Sample Input: AccessData.csv
Command to execute:
```
ruby main.rb AccessData.csv AccessData2.csv
```
The command line can take n number of csv files and processes them all together
The results will be put in a result folder in the project root folder
It produces 2 types of results:
1. IP address related data:
   Aggregated data for every IP address like,
   a. Total number of hits from the IP address
   b. Total number of GET requests from the IP address
   c. Total number of POST requests from the IP address
   d. Total number of PUT requests from the IP address
   e. Total number of DELETE requests from the IP address
<img src="doc_images/ip_addr_results.png">
<hr>
2. Response code related data:
   Aggregated data for response codes for all requests
<img src="doc_images/response_code_results.png">
